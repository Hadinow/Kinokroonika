#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd


# In[2]:


df_master = pd.read_excel("/Users/hadinowandish/Desktop/2022_11_16_Master.xlsx")


# In[4]:


df_geo = pd.read_excel("/Users/hadinowandish/Desktop/2023_01_22_Geo_Location (For Vatson) (1).xlsx")


# In[50]:


ast.literal_eval(df_geo.iloc[2]['film_ids'])


# In[31]:


df_master = df_master.set_index('film_id')


# In[81]:


import ast
import collections as c

all_places = []
for i, row in df_geo.iterrows():
    
    d = {}
    d['Place_Name_ENG'] = row['Place_Name_ENG']
    d['Place_Name_EST'] = row['Place_Name_EST']
    d['Place_Category'] = row['Place_Catagory']
    d['Lat'] = row['Lat']
    d['Lon'] = row['Lon']
    
    d['Years'] = c.Counter()
    
    print(d['Place_Name_ENG'])
    for film_id in ast.literal_eval(row['film_ids']):
        if film_id in df_master.index:
            year = df_master.loc[film_id]['production_year']
            if pd.isnull(year):
                print()
            else:
                d['Years'][int(year)] += 1
    
    all_places.append(d)
        


# In[82]:


all_places


# In[88]:


final_list = []

for place in all_places:
    for year, count in place['Years'].items():
        d = {}
        d['Place_Name_ENG'] = place['Place_Name_ENG']
        d['Place_Name_EST'] = place['Place_Name_EST']
        d['Place_Category'] = place['Place_Category']
        d['Lat'] = place['Lat']
        d['Lon'] = place['Lon']
        d['Year'] = year
        d['Count'] = count
        final_list.append(d)
        


# In[89]:


final_df = pd.DataFrame(final_list)


# In[90]:


final_df


# In[91]:


final_df.to_excel('/Users/hadinowandish/Downloads/2023_01_24_Geo_Location(With_Year).xlsx', index=False)


# In[ ]:




