#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import pandas as pd


# In[ ]:


df = pd.read_csv("/Users/hadinowandish/Downloads/2022_11_16_Master.csv")


# In[ ]:


import re

roles_list = []
for i, row in people_list.iterrows():    
    for colname in people_list.columns[1:]:
        if not pd.notna(row[colname]):
            continue
        elif re.findall('\d', row[colname]):
            continue
        elif ';' in row[colname]:
            for name in row[colname].split(';'):
                if name:
                    d = {}
                    d['film_id'] = row['film_id']
                    d['person'] = name
                    d['role'] = colname.replace('full_name_', '')
                    roles_list.append(d) 
        else:
            d = {}
            d['film_id'] = row['film_id']
            d['person'] = row[colname]
            d['role'] = colname.replace('full_name_', '')
            roles_list.append(d)
        

roles_list   


# In[ ]:


role_df=pd.DataFrame(roles_list)


# In[ ]:


import itertools

edges = []
for g in role_df.groupby('film_id'):
    film_id = g[0]
    pair_order_list = itertools.combinations(list(g[1]['person']),2)
    
    edges_list_film = [{'Source': x[0], 'Target': x[1], 'Film ID': film_id} for x in pair_order_list]
    edges.extend(edges_list_film)

print(len(edges))


# In[ ]:


Pair_Network_Name=pd.DataFrame(edges)


# In[ ]:


Pair_Network_Name.to_csv("/Users/hadinowandish/Downloads/2023_01_11_Pair_Network_Name_df.csv", index=False)

