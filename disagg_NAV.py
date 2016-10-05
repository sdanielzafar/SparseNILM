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
from statistics import mean
from time import time, sleep
from datetime import datetime
from libDataLoaders import dataset_loader
from libFolding import Folding
from libSSHMM import SuperStateHMM
from libAccuracy import Accuracy
import xml.etree.ElementTree as et
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

print()
print('Testing %s algorithm load disagg...' % algo_name)
acc = Accuracy(len(labels), folds)

#==============================================================================
# print()
# print('Connecting to EMU2 on %s...' % (device))
# emu2 = serial.Serial(dev, 115200, timeout=1)
#==============================================================================

y0 = y1 = -1

while True:
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
        
    power = df[agg_meter_col]
      
    y0 = y1
    y1 = power
    if y0 == -1:
        y0 = y1
   
    print(y0.head())   
    print(y1.head())  
   
    start = time() 
    (p, k, Pt, cdone, ctotal) = disagg_algo(sshmm, [y0, y1])
    elapsed = (time() - start)

    s_est = sshmm.detangle_k(k)
    y_est = sshmm.y_estimate(s_est, breakdown=True)
        
    y_true = hidden[i]
    s_true = sshmm.obs_to_bins(y_true)

    acc.classification_result(fold, s_est, s_true, sshmm.Km)
    acc.measurement_result(fold, y_est, y_true)
        
    unseen = 'no'
    if p == 0.0:
       unseen = 'yes'
              
    y_noise = round(y1 - sum(y_true), 1)
        
    fscore = acc.fs_fscore()
    estacc = acc.estacc()
    scp = sum([i != j for (i, j) in list(zip(hidden[i - 1], hidden[i]))])
    print('Obs %5d%s Δ %4d%s | SCP %2d | FS-fscore %.4f | Est.Acc. %.4f | Time %7.3fms' % (y1, measure, y1 - y0, measure, scp, fscore, estacc, elapsed * 1000))

