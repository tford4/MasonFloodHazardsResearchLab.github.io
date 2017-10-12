#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: slawler@dewberry.com
Created on Mon Dec 19 16:14:23 2016
"""
#------------Load Python Modules--------------------#
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import pylab
from matplotlib.dates import DayLocator, HourLocator, DateFormatter
from matplotlib.font_manager import FontProperties
import pandas as pd
import numpy as np
import requests
from bs4 import BeautifulSoup
from datetime import datetime, timezone, timedelta


#--User Input--##
fort22 = '/home/fhrl/Documents/AHPS_Forced_ADCIRC/INPUT/ModFEMAMeshVersion0/RUN/fort.221' #/home/fhrl/Documents/Surge/input/Domain2/fort22/fort.221' for Domain2
plotdir = '/home/fhrl/Documents/PotomicTidalForecastModel/RESULTS'
fort61 = '/home/fhrl/Documents/PotomicTidalForecastModel/RESULTS/WLFort63.txt'
output = '/home/fhrl/Documents/PotomicTidalForecastModel/RESULTS/AHPS.csv'
fort61_Model2 = '/home/fhrl/Documents/AHPS_Forced_ADCIRC/RESULTS/WLFort63.txt'
ETSS = '/home/fhrl/Documents/PotomicTidalForecastModel/RESULTS/ETSS.csv'
ESTOFS = '/home/fhrl/Documents/PotomicTidalForecastModel/RESULTS/ESTOFS.csv'

frequency = '3600s'

#--Stations data
stations = [1, 3, 5, 11, 12]

station_dict = {1:'WASD2',  3:'NCDV2', 5:'LWTV2', 11:'GTND2', 12:'SGSM2'}

# 0.1 added to Dal and 0.05 LW for adjustment(0.253actual)

station_datum_shift  = {1: 0.441, 3: 0.356, 5: 0.303, 11: 0.64, 12: 0.42}               

station_names = {1:'Washington, DC', 3: 'Dalgren', 5: 'Lewisetta, VA', 11: 'Potomac River at George Town, DC', 12: 'St. George Creek at Straits Point, MD'}                
       
                
#---Get Start Date From fort.221
from datetime import datetime

with open(fort22,'r') as f:
    for i in range(0,1):
        line = f.readline().strip().split()
        timestamp = line[3]
        start_date = datetime.strptime(timestamp,'%Y%m%d%H')
        

#--Read in adcirc_data from Result(fort.*)
adcirc_data = pd.read_fwf(fort61, skiprows=3,widths = [15,18], 
                 names = ['station','value'])

adcirc_data['value'] = adcirc_data['value'].apply(pd.to_numeric, errors='coerce')
adcirc_data['station'] = adcirc_data['station'].astype(int)
adcirc_data   = adcirc_data.query('value >= -1000')

adcirc_data_Model2 = pd.read_fwf(fort61_Model2, skiprows=3,widths = [15,18], 
                 names = ['station','value'])

adcirc_data_Model2['value'] = adcirc_data_Model2['value'].apply(pd.to_numeric, errors='coerce')
adcirc_data_Model2['station'] = adcirc_data_Model2['station'].astype(int)
adcirc_data_Model2   = adcirc_data_Model2.query('value >= -1000')

# reading ETSS data

df_etss = pd.read_csv(ETSS,index_col= None)
idxe = pd.date_range(start = start_date, periods = len(df_etss), freq=frequency, tz='utc')
df_etss = df_etss.set_index(idxe)  

# reading ESTOFS data

df_estofs = pd.read_csv(ESTOFS,index_col= None)
idxef = pd.date_range(start = start_date, periods = len(df_estofs), freq='1800s', tz='utc')
df_estofs = df_estofs.set_index(idxef)  


df_ADCIRC = pd.DataFrame()
df_AHPS = pd.DataFrame()
df_ADCIRC_AhpsForced = pd.DataFrame()


for s in stations:
    plt.interactive(False)  
    
    #--ADCIRC DATA Block   
    try:
        df = adcirc_data.query('station == {}'.format(s))  # Get Station adcirc_data
        df_Model2 = adcirc_data_Model2.query('station == {}'.format(s))  # Get Station adcirc_data        
        records = len(df)
        records_Model2 = len(df_Model2)        
        idx = pd.date_range(start = start_date, periods = records, freq=frequency, tz='utc')
        idx1 = pd.date_range(start = start_date, periods = records_Model2, freq=frequency, tz='utc')     
        df = df.set_index(idx)                              # Add datetime
        df_Model2 = df_Model2.set_index(idx1)         
        df['value'] = df['value'] + station_datum_shift[s]  # Datum Shift
        df_Model2['value'] = df_Model2['value'] + station_datum_shift[s]  # Datum Shift        
        name = station_names[s]

        gage = station_dict[s]
       
        df_ADCIRC['{}'.format(gage)] = df['value']
        df_ADCIRC['{}'.format(gage)] = df_ADCIRC['{}'.format(gage)].rename(columns = {'value':'{}'.format(gage)})

        df_ADCIRC_AhpsForced['{}'.format(gage)] = df_Model2['value']
        df_ADCIRC_AhpsForced['{}'.format(gage)] = df_ADCIRC_AhpsForced['{}'.format(gage)].rename(columns = {'value':'{}'.format(gage)})
       
        #print(name)
   
    except:
        print("ADCIRC ERROR on station {}".format(name))
     
    #--AHPS DATA Block    
    try:
    
        
  
        #---Read HTML
        url = r'http://water.weather.gov/ahps2/hydrograph_to_xml.php?gage={}&output=tabular'.format(gage)
        r = requests.get(url)
        data = r.text
        soup = BeautifulSoup(data, "lxml")
        
        #---Data
        data = soup.find_all('table')[0] 
        data_rows = data.find_all('tr')[3:]
        
        #--Get the Current Year in UTC
        year = datetime.now(timezone.utc).strftime("%Y")
        
        
        #--Get the Current Year in UTC
        year = datetime.now(timezone.utc).strftime("%Y")
        
        #--Initialize Dictionaries
        obs_data =  {'Date(UTC)' : [],  'Stage' : []}
        forecast_data = {'Date(UTC)' : [],  'Stage' : []}
        value = 'Observed'              
        for row in data_rows:
            d = row.find_all('td')
            try:
                dtm   = d[0].get_text().split()[0] + '/' + str(year) +' '+ d[0].get_text().split()[1]
                stage = d[1].get_text()
        
                if value == 'Observed':
                    obs_data['Date(UTC)'].append(dtm) 
                    obs_data['Stage'].append(stage)
        
                elif value =='Forecast':
                    forecast_data['Date(UTC)'].append(dtm) 
                    forecast_data['Stage'].append(stage)
        
            except:
                check_value = str(d)
                if 'Forecast  Data ' in check_value:
                    value = 'Forecast'
                    
        #---Create & Format Dataframes
        df_obs = pd.DataFrame.from_dict(obs_data)
        df_obs['Date(UTC)'] = pd.to_datetime(df_obs['Date(UTC)'], format='%m/%d/%Y %H:%M')
        df_obs['Stage'] = df_obs['Stage'].astype(str).str[:-2].astype(np.float)
        df_obs = df_obs.set_index(df_obs['Date(UTC)'] )
        
        df_fcst = pd.DataFrame.from_dict(forecast_data)   
        df_fcst['Date(UTC)'] = pd.to_datetime(df_fcst['Date(UTC)'], format='%m/%d/%Y %H:%M')
        df_fcst['Stage'] = df_fcst['Stage'].astype(str).str[:-2].astype(np.float)
        df_fcst = df_fcst.set_index(df_fcst['Date(UTC)'] )

        # creating dataframe of AHPS forecast and saving as tab separated file
        
        df_AHPS['{}'.format(gage)] = df_fcst['Stage']
        df_AHPS['{}'.format(gage)] = df_AHPS['{}'.format(gage)].rename(columns = {'Stage':'{}'.format(gage)}) 

        #with open('Output.csv','a') as f:
        	#df_fcst.to_csv(f)        
        
	#start, stop = df_obs.index[0], df_fcst.index[-1]
        
        
        #--Initialize Plots
        fig, ax = plt.subplots(figsize=(12,6))
        
        #--Plot AHPS Gage Observed
        x0 = df_obs['Date(UTC)']
        y0 = df_obs['Stage']
        ax.plot(x0 ,y0, color = 'b', linewidth = 2)       # Observed
        
        
        #--Plot AHPS Forecast
        x1 = df_fcst['Date(UTC)']
        y1 = df_fcst['Stage']
        ax.plot(x1 ,y1, color = 'r')         # Forecast
        #print(gage, len(df))   

        x2 = df_etss.index #+ timedelta(hours = 3.0)
        y2 = df_etss['{}'.format(gage)]        
        ax.plot(x2 ,y2, color = 'm')                     #Etss   

        x3 = df_estofs.index #+ timedelta(hours = 3.0)
        y3 = df_estofs['{}'.format(gage)]        
        ax.plot(x3 ,y3, color = 'b')     	 #Estofs 
          
        mpl.rcParams['timezone'] = 'US/Eastern'

        
    except:
        print("AHPS ERROR on station {}".format(name))
               

    try:
        x4 = df.index #+ timedelta(hours = 1.0)
        y4 = df['value'] * 3.28084
        x5 = df_Model2.index + timedelta(hours = 1.5)#2
        y5 = df_Model2['value'] * 3.28084
        ax.plot(x4 ,y4, color = 'green', linewidth = 2.5, marker = '*')       # ADCIRC
        ax.plot(x5 ,y5, color = 'black', linewidth = 2.5)       # AHPS_ADCIRC
        plot_start = df_obs['Date(UTC)'][-1]
        plot_stop = df.index[-1] +timedelta(hours = 24) 
        #--Set Axis Limits
        ax.set_xlim(plot_start, plot_stop)
        #ax.set_ylim(0, major)
        
        plt.title('{}, AHPS Gage: ({})'.format(name, gage))
        plt.xlabel('Eastern Time')
        plt.ylabel('Stage (ft)', fontweight='bold')
        
        #--Plot Formatting
        box = ax.get_position()
        ax.set_position([box.x0, box.y0 + box.height * 0.2,
                         box.width, box.height * 0.8])
        
        fontP = FontProperties()
        fontP.set_size('small')
        
        plt.legend(['AHPS_Observed', 'AHPS_Forecast','ETSS','ESTOFS','ADCIRC_Mason_Forced','ADCIRC_AHPS_forced'],
                  bbox_to_anchor=(0.88, -0.2),prop = fontP,
                  fancybox=False, shadow=False, ncol=5, scatterpoints = 0)
        

        ax.plot(x0 ,y0, color = 'b', marker = 'o')       # Add Points
        ax.plot(x1 ,y1, color = 'r', marker = 'o')       # Add Points
        plt.grid(True)
        plt.gca().xaxis.set_major_formatter(DateFormatter('%I%p\n%a\n%b%d'))
        plt.gca().xaxis.set_major_locator(HourLocator(byhour=range(24), interval=12))

        
        plt.savefig(r'{}/{}.png'.format(plotdir,  gage), dpi = 600)
        plt.close()

    except:
        print("Plotting ERROR on station {}".format(name))     



idx2 = pd.date_range(start = start_date, periods = records, freq=frequency) 
df_ADCIRC = df_ADCIRC.set_index(idx2)

df_ADCIRC.index.names = ['Datetime(UTC)']   
with open('ADCIRC_MasonForced.tsv','w') as f:
    df_ADCIRC.to_csv(f, sep='\t',index=True,header = True)

df_AHPS.index.names = ['Datetime(UTC)']   
with open('AHPS.tsv','w') as f:
    df_AHPS.to_csv(f, sep='\t',index=True,header = True)

idx3 = pd.date_range(start = start_date, periods = records_Model2, freq=frequency) 
df_ADCIRC_AhpsForced = df_ADCIRC_AhpsForced.set_index(idx3)

df_AHPS.index.names = ['Datetime(UTC)']   
with open('ADCIRC_AhpsForced.tsv','w') as f:
    df_ADCIRC_AhpsForced.to_csv(f, sep='\t',index=True,header = True) 

# for file name with timestamp
#with open('{}_ADCIRC_AhpsForced.tsv'.format(timestamp),'w') as f:


