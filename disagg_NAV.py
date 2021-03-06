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
import pandas as pd

print()
print('------------------------------------------------------------------------------')
print('Disaggregating House Meter given an existing model----------------------------')
print('-------------------------------------------------------------S Daniel Zafar---')
print()
print('Start Time = ', datetime.now(), '(local time)')
print()

if len(sys.argv) != 5:
    print()
    print('USAGE: %s [modeldb] [datafile] [precision] [measure]' % (sys.argv[0]))
    print()
    print('       [modeldb]       - file name of model (omit file ext).')
    print('       [datafile]       - file name of datafile to be disaggregated (omit file ext).')
    print('       [precision]     - number; e.g. 10 would convert A to dA.')
    print('       [measure]       - the measurement, e.g. A for current')    
    print()
    exit(1)

#==============================================================================
# modeldb = 'eGauge_AC_CDE_FGE_hold511'
# datafile = 'eGauge_AC_CDE_FGE_511_main'
# precision = '10000'
# measure = 'kw'
#==============================================================================
    
print()
print('Parameters:', sys.argv[1:])
(modeldb, datafile, precision, measure) = sys.argv[1:]
algo_name = "SparseViterbi"
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
if folds != 1:
    print('ERROR: please use only single fold models.')
    exit(1)
print('\n\tLoading JSON data into SSHMM object...')
sshmm = SuperStateHMM()
sshmm._fromdict(data)
del jdata
labels = sshmm.labels
print('\tModel lables are: ', labels)

timestamp_col = 'TimeStamp'
agg_meter_col = 'MAIN'

print('Loading the %s data' % datafile)   # read in the aggregate data
df = pd.read_csv(datafile_dir % datafile) 

print('\tSetting timestamp column %s as index.' % timestamp_col)
df = df.set_index(timestamp_col)
#df = df.set_index(timestamp_col).iloc[:100]

print('\tModfity data with precision %d then convert to int...' % precision)
for col in list(df):
    df[col] = df[col] * precision
    df[col] = df[col].astype(int)
        
obs = list(df[agg_meter_col])

# We create and empty output matrix      
y_out = pd.DataFrame(columns = labels)

print("\nPerforming the disaggregation...")
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

    y_out = y_out.append(pd.DataFrame([y_est], columns=labels))
    
    indv_tm_sum += elapsed
    indv_count += 1
    
    if not i % pbar_incro or i == 1:
        pbar += '=' #if i > 1 else ''
        disagg_rate = float(indv_tm_sum) / float(indv_count)
        print('\r\tProgress: [%-20s], Disagg rate: %12.6f sec/sample ' % (pbar[:20], disagg_rate), end='', flush=True)
        sys.stdout.flush()

        
y_out=y_out.set_index(df.index[1:]).reset_index()
y_out['MAIN'] = obs[1:len(obs)]
labels.insert(0,'MAIN')
y_out[labels] = y_out[labels] / precision

if type(y_out['TimeStamp'][y_out.index[1]]) != str:
    y_out['Time'] = pd.to_datetime(y_out['TimeStamp'], unit = 's')

print("Writing out .csv with disaggregated results: \n", csv_dir % modeldb)
y_out.to_csv(csv_dir % modeldb)
print()
print("Success! Disaggregation Completed")

    