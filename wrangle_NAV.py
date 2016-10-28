"""
This script reads in data from separate submeter files and combines 
such that it can be read in by train_SSHMM.py or test_SSHMM.py.

Made for the REDD dataset, but hopefully generalizable 

@author: S Daniel Zafar & Justin E
"""

import sys, os
from datetime import datetime
import pandas as pd
import numpy as np
from math import floor, log10
import functools

print()
print('------------------------------------------------------------------------------')
print('Loading in data --------------------------------------------------------------')
print('----------------------------------------------------- Dan Zafar & Justin E ---')
print()
print('Start Time = ', datetime.now(), '(local time)')
print()

if len(sys.argv) != 4:
    print()
    print('USAGE: %s [data] [name] [houses_ID]  % (sys.argv[0]))')
    print()
    print('       [data]            - Name of dataset eg. REDD, eGauge, Blueline...')
    print('       [name]            - The output file/table name') 
    print('       [houses_ID]       - House names (sep by commas) to be stacked, or All')  
    print()
    exit(1)

print()
print('Parameters:', sys.argv[1:])
(data, name, houses_ID) = sys.argv[1:]
houses_ID = houses_ID.split(',')

if data == "eGauge":
    path = "Y:\\MA Utilities\Residential\\RES 1 -Residential Baseline Study\\Analysis\\NILM\\data\\Blue_Egauge"
    out = "Y:\\MA Utilities\\Residential\\RES 1 -Residential Baseline Study\\Analysis\\NILM\\SparseNILM\\datasets"
    
    
    print("Reading data in long format...")
    eGauge_long = pd.read_csv(path + "\eGauge Training Data.csv", header=0)
    # has columns site_id, dt, end_use, register, and kw
    
    print("Reading in Blueline Data...")
    Blueline = pd.read_csv(path + "\Alternate Blue Line Training Data.csv", header=0)
    BlueType = "kw_most"
    forjoin = Blueline[['site_id','dt',BlueType,'end_use']]
    
    print("\tJoining it to eGauge data...")
    joined = eGauge_long.merge(forjoin, 
                               how = "left",  
                               on=['site_id','dt','end_use'], left_index = True, copy = False)
    eGauge_long = joined.assign(kw = np.where(np.isnan(joined[BlueType]),joined['kw'],joined[BlueType]))
    del eGauge_long[BlueType]


    def round_sigfigs(num):
        if np.isnan(num):
            return(0)
        return round(num, -int(floor(log10(abs(num)))))
    
    print("Processing data...")    
    #print("\tKeeping first sig fig...")
    #eGauge_long['kw'] = eGauge_long['kw'].apply(lambda x: 0 if x ==0 else round_sigfigs(x))
    print("\tRenaming Appliances...")
    map_path = os.path.join(path, "App_Map.csv") 
    app_map = pd.read_csv(map_path, header = 0)
    eGauge_mapped = eGauge_long.merge(app_map, on='end_use')
    print("\tWrangling data...")
    eGauge = eGauge_mapped.pivot_table(index = ['dt','site_id'], 
                                     values = 'kw', 
                                     columns = 'eu')
    
    eGauge.reset_index(level=['site_id','dt'], inplace = True)
    eGauge.rename(columns = {'site_id':'house','dt':'TimeStamp'}, inplace = True)
    eGauge.sort_values(by = ['house','TimeStamp'], inplace = True)
    eGauge.reset_index(drop=True, inplace = True)
    eGauge.fillna(0, inplace = True)
    
    if houses_ID != ['All']:
        for i in houses_ID:
            if i not in eGauge['house'].unique():
                print("\tHouse ID " + i + " is not in the data!")
                exit(1)               
        print("\tKeeping houses:")
        print(houses_ID) 
        eGauge = eGauge[eGauge['house'].isin(houses_ID)]
    else:
        print("\tKeeping all houses...")
    
    print("\nSaving data in to:\n" + out + "...")
    filename = os.path.join(out, name + ".csv")        
    eGauge.reset_index(drop = True).to_csv(filename)
    
    print("\n\nSUCCESS! Completed Data Wrangling")
         

if data == "REDD":
    path = "Y:\\MA Utilities\Residential\\RES 1 -Residential Baseline Study\\Analysis\\NILM\\data\\REDD\\low_freq"
    out = "Y:\\MA Utilities\\Residential\\RES 1 -Residential Baseline Study\\Analysis\\NILM\\SparseNILM\\datasets"
    #out = "Y:\\MA Utilities\Residential\\RES 1 -Residential Baseline Study\\Analysis\\NILM\\data\\REDD\\WrangledREDD\\"
    #houses_ID = ["house_1","house_2"]
    #name = "1&2"
    
    out_df = pd.DataFrame()
    for subdir, dirs, files in os.walk(path):
        for house in sorted(dirs):
            if house in houses_ID:
                print()
                print("Processing: " + house)
                house_path = os.path.join(path, house)
                
                # get the labels info for the house
                labels = pd.read_table(house_path + "\labels.dat",
                                           sep=" ",
                                           index_col=0,
                                           header=None,
                                           names=["label"])
                
                # iterate over the different appliances
                house_df = pd.DataFrame()
                for j in labels.index:
                    channel_file = house_path + "/channel_" + str(j) + ".dat"
                    print("Reading ", "channel_" + str(j) + ".dat")
                    raw_data = pd.read_table(channel_file,
                                             header=None,
                                             index_col=0,
                                             names=[labels["label"][j]], 
                                             sep=" ")
                                             #nrows=1000)
                    raw_data.index = pd.to_datetime(raw_data.index, unit="s")
                    # resampling the data
                    data_min = raw_data.resample('min').mean()
                    house_df = pd.concat([house_df, data_min], axis=1)
                    
                # add up columns with same column name
                house_df = house_df.groupby(house_df.columns, axis=1).sum().round(1)
                                                  
                # add in the house name and set up the time stamps
                house_df.insert(0, "house", house)
                house_df.index.name = "TimeStamp"
                house_df = house_df.reset_index()
                
                if(data == "REDD"):
                    house_df = house_df.rename(columns = {'mains':'MAIN'})
                    # drop the colmns with NA 'MAIN' rows
                    house_df = house_df[np.isfinite(house_df['MAIN'])]
                    house_df = house_df[np.isfinite(house_df['lighting'])]
                
                # setting the table name dynamically so we can append later
                exec(house + " = house_df")
                            
                exec("out_df = pd.concat([out_df, " + house + "], axis=0)")   
                
                # reorder the columns on decreasing % of total load demand
                sub = out_df.drop(['TimeStamp','house'],1)
                ord_cols = out_df[['TimeStamp','house']].columns.values.tolist()
                flat = sub.apply(np.nansum, raw = True, axis = 0).sort_values(ascending = False, axis = 0)
                ord_cols.extend(flat.index.tolist())
                out_df = out_df[ord_cols]
                
                filename = os.path.join(out, name + ".csv")        
                out_df.reset_index(drop = True).to_csv(filename)
        
    

if data == "Blueline":
    print("Please edit this file for Blueline paths")
    exit(1)
if data != "REDD" and data != "Blueline" and data != "eGauge": 
    print("Please use supported data or update this script")
    exit(1)


    
        