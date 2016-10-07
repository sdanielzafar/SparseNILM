#
# Disaggregate house meter data given a trained model
# S Daniel Zafar
# 
# We need to add into the code:
# a) import a dataset from file in correct format, just the mains
# b) output the disaggregated time series information with labels in .csv

# data must be located in the "for_dissag" folder as a .csv
# column with timestamp by be called 'TimeStamp'
# column with the unmetered data must be called 'WHE'


import sys, json
from time import time
from datetime import datetime
from libSSHMM import SuperStateHMM
import pandas

print()
print('-----------------------------------------------------------------------------------------')
print('Test running NILM and report stats each time  -------------------------------------------')
print('-----------------------------------------------------------------------------------------')
print()
print('Start Time = ', datetime.now(), '(local time)')
print()

if len(sys.argv) != 6:
    print()
    print('USAGE: %s [modeldb] [datafile] [precision] [measure] [algo name]' % (sys.argv[0]))
    print()
    print('       [modeldb]       - file name of model (omit file ext).')
    print('       [datafile]       - file name of datafile to be disaggregated (omit file ext).')
    print('       [precision]     - number; e.g. 10 would convert A to dA.')
    print('       [measure]       - the measurement, e.g. A for current')    
    print('       [algo name]     - specifiy the disaggregation algorithm to use.')
    print()
    exit(1)

print()
print('Parameters:', sys.argv[1:])
(modeldb, datafile, precision, measure, algo_name) = sys.argv[1:]
precision = float(precision)
disagg_algo = getattr(__import__('algo_' + algo_name, fromlist=['disagg_algo']), 'disagg_algo')
print('Using disaggregation algorithm disagg_algo() from %s.' % ('algo_' + algo_name + '.py'))

datasets_dir = './datasets/%s.csv'
datafile_dir = './for_dissag/%s.csv'
logs_dir = './logs/%s.log'
models_dir = './models/%s.json'
csv_dir = './csvs/%s.csv'

print()
print('Loading saved model %s from JSON storage (%s)...' % (modeldb, models_dir % modeldb))
fp = open(models_dir % modeldb, 'r')
jdata = json.load(fp)
fp.close()
print('\tLoading JSON data into SSHMM objects...')
sshmms = []
for data in jdata:
    sshmm = SuperStateHMM()
    sshmm._fromdict(data)
    sshmms.append(sshmm)
#del jdata
labels = sshmms[0].labels
print('\tModel lables are: ', labels)

folds = len(jdata)
print(folds)
if folds != 1:
    print('ERROR: please use only single fold models.')
    exit(1)
print('\tLoading JSON data into SSHMM object...')
sshmm = SuperStateHMM()
sshmm._fromdict(data)
del jdata
labels = sshmm.labels
print('\tModel lables are: ', labels)

timestamp_col = 'TimeStamp'
agg_meter_col = 'WHE'

print('Loading the %s data' % datafile)   # read in the aggregate data
df = pandas.read_csv(datafile_dir % datafile) 

print('\tSetting timestamp column %s as index.' % timestamp_col)
df = df.set_index(timestamp_col)

print('\tModfity data with precision %d then convert to int...' % precision)
for col in list(df):
    df[col] = df[col] * precision
    df[col] = df[col].astype(int)
        
obs = list(df[agg_meter_col])
      
# We create and empty output matrix      
y_out = pandas.DataFrame(columns = labels)

print("Performing the disaggregation...")
# The next four lines are for record-keeping
indv_tm_sum = 0.0
indv_count = 0
pbar = ''
pbar_incro = len(obs) // 20
for i in range(1, len(obs)):
    
    y0 = obs[i - 1]
    y1 = obs[i]
    
    start = time() 
    (p, k, Pt, cdone, ctotal) = disagg_algo(sshmm, [y0, y1])
    elapsed = (time() - start)

    s_est = sshmm.detangle_k(k)
    y_est = sshmm.y_estimate(s_est, breakdown=True)

    y_out = y_out.append(pandas.DataFrame([y_est], columns=labels))
    
    indv_tm_sum += elapsed
    indv_count += 1
    
    if not i % pbar_incro or i == 1:
        pbar += '=' #if i > 1 else ''
        disagg_rate = float(indv_tm_sum) / float(indv_count)
        print('\r\tProgress: [%-20s], Disagg rate: %12.6f sec/sample ' % (pbar[:20], disagg_rate), end='', flush=True)
        sys.stdout.flush()

print("Writing out .csv with disaggregated results: ", csv_dir % modeldb, ".csv")
y_out.to_csv(csv_dir % modeldb)

    