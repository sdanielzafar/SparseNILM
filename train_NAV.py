#!/usr/bin/env python3
#
# Make a super-state hidden Markov model for evaluation (train_SSHMM.py)
# Copyright (C) 2013-2015 Stephen Makonin. All Right Reserved.
#

import sys, json
from statistics import mean
from time import time
from datetime import datetime
from libDataLoaders import dataset_loader
from libFolding import Folding
from libPMF import EmpiricalPMF
from libSSHMM import SuperStateHMM, frange
import pandas as pd
import numpy as np


print()
print('----------------------------------------------------------------------------------------------------------------')
print('Create & Save a SSHMM for Load Disaggregation Testing/Evaluation -- Copyright (C) 2013-2015, by Stephen Makonin.')
print("-----Modified by S Daniel Zafar: Iterate over multiple houses (in 'house' column)-------------------------------")
print('----------------------------------------------------------------------------------------------------------------')
print()
print('Start Time = ', datetime.now(), '(local time)')
print()

if len(sys.argv) != 9:
    print()
    print('USAGE: %s [modeldb] [dataset] [precision] [max obs] [denoised] [max states] [folds] [ids]' % (sys.argv[0]))
    print()
    print('       [modeldb]    - file name of model (omit file ext).')
    print('       [dataset]    - file name of dataset to use (omit file ext).')
    print('       [precision]  - number; e.g. 10 would convert A to dA.')
    print('       [max obs]    - The max observed value, e.g. 200.1 A.')
    print('       [denoised]   - denoised aggregate reads, else noisy.')
    print('       [max states] - max number of states a each load can have.')
    print('       [folds]      - number usually set to 10, 1 means data same for train/test.')
    print('       [ids]        - e.g. CDE,FGE(,...) -- case sensitive!')
    print()
    exit(1)
    
print()
print('Parameters:', sys.argv[1:])
(modeldb, dataset, precision, max_obs, denoised, max_states, folds, ids) = sys.argv[1:]

modeldb = 'testerr'
dataset = 'eGauge_FRG2_holdF117_c' 
precision = '1000' 
max_obs = '6.721' 
denoised = 'noised' 
max_states = '4' 
folds = '3' 
ids = 'FRG'  
import os
os.chdir('Y:\\MA Utilities\\Residential\\RES 1 -Residential Baseline Study\\Analysis\\NILM\\SparseNILM')

precision = float(precision)
max_obs = float(max_obs)
denoised = denoised == 'denoised'
max_states = int(max_states)
num_folds = int(folds)
ids = ids.split(',')
datasets_dir = './datasets/%s.csv'
logs_dir = './logs/%s.log'
models_dir = './models/%s.json'

#print()
sshmms = []
train_times = []


data = dataset_loader(datasets_dir % dataset, ids, precision, denoised)
if 'house' not in data.columns:
    print("This script requires a dataframe with column 'house'")
    exit(1)
if 'MAIN' not in data.columns:
    print("This script requires a dataframe with column 'MAIN'")
    exit(1)
if len(ids) > 1:
    print("This script is only set up for one appliance at the moment!")
    exit(1)
    
houses = data['house'].drop_duplicates().tolist()
if 0 in houses:
    print("Removing '0' from houses...Check this...")
    houses.remove(0)

max_obs = data['MAIN'].max()    
    
scale_guide = {}
for sel_house in houses:
    print()
    print('Quantizing states from %s...' % sel_house)

    house_data = data.query('house == @sel_house')
    house_pmfs = []
    for id in ids: 
        epsilon = round(55/len(house_data[id]),5)
        house_pmfs.append(EmpiricalPMF(id, max_obs, list(house_data[id]),verbose=False))
        house_pmfs[-1].quantize(max_states, epsilon)
        peaks = [pmf.bin_peaks for pmf in house_pmfs]
        scale = np.asarray(peaks).max()
        print("Scaling by:")
        print(scale)
        scale_guide[sel_house] = scale
        
data["scaler"] = data['house'].map(scale_guide)
data = data.assign(temp = data[id]/data['scaler'])
data[id] = data['temp']
del data['temp'], data['scaler']
data[id].fillna(0,inplace=True)
data[id] = data[id].astype('int64')

print("Saving the scaling factors...")    
scaler = pd.read_csv('scaler.csv')
merge_scale = pd.DataFrame([scale_guide]).T.reset_index()
merge_scale.columns = ['House','Scale']
merge_scale['App'] = id
out = pd.merge(scaler, merge_scale, on=['House', 'App', 'Scale'], how='outer')
out.to_csv('scaler.csv', index=False)

epsilon = round(110/len(data.index),5)   # I don't know where the 110 comes from, neither does Makonin 
folds = Folding(data, num_folds)
    
for (fold, priors, testing) in folds: 
    
    del testing
    tm_start = time() 
    
    print()
    print('\tInitial epsilon is %12.6f' % epsilon)
    print("\tMaximum Obs fed is: ", max_obs)
    print('\tCreating load PMFs and finding load states...')
    print('\t\tMax partitions per load =', max_states)
    pmfs = []
    for id in ids: 
        pmfs.append(EmpiricalPMF(id, max_obs, list(priors[id]),verbose=False))
        pmfs[-1].quantize(max_states, epsilon)
        

    print()
    print('\tCreating compr'
          'essed SSHMM...')
    incro = 1 / precision
    sshmm = SuperStateHMM(pmfs, [i for i in frange(0, max_obs/precision + incro, incro)])
    
    print('\t\tConverting DataFrame in to obs/hidden lists...')
    obs_id = list(priors)[0]
    obs = list(priors[obs_id])
    hidden = [i for i in priors[ids].to_records(index=False)]
    
    sshmm.build(obs, hidden)
    sshmms.append(sshmm)
    
    train_times.append((time() - tm_start) / 60)

print()
print('Train Time was', round(sum(train_times), 2), ' min (avg ', round(sum(train_times) / len(train_times), 2), ' min/fold).')

print()
fn = models_dir % modeldb
print('Converting model %s to JSON for storage in %s...' % (modeldb, fn))
fp = open(fn, 'w')
json.dump(sshmms, fp, default=(lambda o: o._asdict()), sort_keys=True, indent=None, separators=(',', ':'))
fp.close()

report = []
report.append(['Model DB', modeldb])
report.append(['Run Date', datetime.now()])
report.append(['Dataset', dataset])
report.append(['Precision', precision])
report.append(['Max States', max_states])
report.append(['Denoised?', denoised])
report.append(['Model Noise?', ('UNE' in ids)])
report.append(['Folds', folds.folds])
report.append(['IDs', ' '.join(ids)])
report.append(['Train Time', round(sum(train_times), 2)])
report.append(['Avg Time/Fold', round(sum(train_times) / len(train_times), 2)])
report.append(['Avg Load States', round(sum([mean(sshmm.Km) for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['Sum Load States', round(sum([sum(sshmm.Km) for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['Super-States', round(sum([sshmm.K for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['Loads', sshmms[0].M])
report.append(['Obs', sshmms[0].N])
report.append(['Time Len', folds.data_size])
report.append(['P0 Size', round(sum([sshmm.P0.size() for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['P0 Non-Zero', round(sum([sshmm.P0.nonzero() for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['P0 Sparsity', round(sum([sshmm.P0.sparsity() for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['P0 bytes', round(sum([sshmm.P0.bytes() for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['A Size', round(sum([sshmm.A.size() for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['A Non-Zero', round(sum([sshmm.A.nonzero() for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['A Sparsity', round(sum([sshmm.A.sparsity() for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['A bytes', round(sum([sshmm.A.bytes() for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['B Size', round(sum([sshmm.B.size() for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['B Non-Zero', round(sum([sshmm.B.nonzero() for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['B Sparsity', round(sum([sshmm.B.sparsity() for sshmm in sshmms]) / len(sshmms), 1)])
report.append(['B bytes', round(sum([sshmm.B.bytes() for sshmm in sshmms]) / len(sshmms), 1)])

print()
print('-------------------------------- CSV REPORTING --------------------------------')
print()
print(','.join([c[0] for c in report]))
print(','.join([str(c[1]) for c in report]))
print()
print('-------------------------------- ------------- --------------------------------')

print()
print('End Time = ', datetime.now(), '(local time)')
print()
print('DONE!!!')
print()