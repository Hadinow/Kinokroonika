#!/usr/bin/env python
# coding: utf-8

# In[23]:


import pandas as pd
import ast

df = pd.read_csv("/Users/hadinowandish/Downloads/2022_11_08_Master.csv")

# YOU DON'T NEED THIS PART IF YOU CAN EXTRACT DATA FROM EnvelopingSpan DIRECTLY
#'[][][test]' prefix ='[]'
def remove_prefix(text, prefix):
    if not text:
        return None
    if text.startswith(prefix):
        return remove_prefix(text[len(prefix):], prefix)
    return text 

def remove_suffix(text, prefix):
    if text == "":
        return None
    if text.endswith(prefix):
        return remove_suffix(text[: (-1) * len(prefix)], prefix)
    return text 

def reformat_string(text):
    if not text:
        return None
    
    text = text.replace('EnvelopingSpan', '{"EnvelopingSpan":')
    text = text.replace("'LOC'}])", "'LOC'}])}")
    text = text.replace("'ORG'}])", "'ORG'}])}")
    text = text.replace("'PER'}])", "'PER'}])}")
    text = text.replace('][', ',')
    text = text.replace(',,', ',')
    
    return text

def convert_string_to_list(text):
    if not text:
        return None

    return ast.literal_eval(text)

tmp_list = df['aggregated_loc'].apply(lambda x: remove_prefix(str(x), '[]'))

tmp_list = tmp_list.apply(lambda x: remove_suffix(str(x), '[]'))

tmp_list = tmp_list.apply(lambda x: reformat_string(x))

tmp_list = tmp_list.apply(lambda x: convert_string_to_list(x))

df['aggregated_locations_modified'] = tmp_list


# In[24]:


def reformat_ners(ners):
    if not ners:
        return None
    
    unique_ners = []
    
    for entity in ners:
        pair = (entity['EnvelopingSpan'][1][0]['nertag'], entity['EnvelopingSpan'][0][0])
        unique_ners.append(pair)
    
    return unique_ners

df['aggregated_loc'] = df['aggregated_locations_modified'].apply(lambda x: reformat_ners(x))


# In[25]:


tmp_list = df['title_NER'].apply(lambda x: remove_prefix(str(x), '[]')).        apply(lambda x: remove_suffix(str(x), '[]')).        apply(lambda x: reformat_string(x)).        apply(lambda x: convert_string_to_list(x)).apply(lambda x: reformat_ners(x))

tmp_list


# In[27]:


df['title_NER'] = tmp_list


# In[42]:


tmp_list = df['parallel_title_NER'].apply(lambda x: remove_prefix(str(x), '[]')).        apply(lambda x: remove_suffix(str(x), '[]')).        apply(lambda x: reformat_string(x)).        apply(lambda x: convert_string_to_list(x)).apply(lambda x: reformat_ners(x))

tmp_list


# In[43]:


df['parallel_title_NER'] = tmp_list


# In[30]:


tmp_list = df['title_proper_NER'].apply(lambda x: remove_prefix(str(x), '[]')).        apply(lambda x: remove_suffix(str(x), '[]')).        apply(lambda x: reformat_string(x)).        apply(lambda x: convert_string_to_list(x)).apply(lambda x: reformat_ners(x))

tmp_list


# In[31]:


df['title_proper_NER'] = tmp_list


# In[34]:


tmp_list = df['keyword_values_et_NER'].apply(lambda x: remove_prefix(str(x), '[]')).        apply(lambda x: remove_suffix(str(x), '[]')).        apply(lambda x: reformat_string(x)).        apply(lambda x: convert_string_to_list(x)).apply(lambda x: reformat_ners(x))

tmp_list


# In[35]:


df['keyword_values_et_NER'] = tmp_list


# In[36]:


tmp_list = df['keyword_values_en_NER'].apply(lambda x: remove_prefix(str(x), '[]')).        apply(lambda x: remove_suffix(str(x), '[]')).        apply(lambda x: reformat_string(x)).        apply(lambda x: convert_string_to_list(x)).apply(lambda x: reformat_ners(x))

tmp_list


# In[38]:


df['keyword_values_en_NER'] = tmp_list


# In[46]:


# MEANINGFUL PART
from geopy.geocoders import Nominatim

# MANY LOCATIONS ARE REPEATED, IT MAKES SENSE TO HAVE SEPARATE LIST

def locations_single_film(locations):
    if not locations:
        return []
    
    unique_locations = []
    
    for entity in locations:
        if entity['EnvelopingSpan'][1][0]['nertag'] == 'LOC':
            unique_locations.append(entity['EnvelopingSpan'][0][0])
    
    return unique_locations

def flatten_list(a):
    out = []
    for sublist in a:
        out.extend(sublist)
    return out

locations_list = flatten_list(df['aggregated_locations_modified'].apply(lambda x: locations_single_film(x)))

#UNIQUE LIST
locations_list = list(set(locations_list))


# In[7]:


locations_list


# In[ ]:


# GEOCODING
# This will work better if you'll translate data to English
# Also since there is more than one location per film, it doesn't make sense to store them in one row
geolocator = Nominatim(user_agent="myApp")

location_data = []
for i, loc in enumerate(locations_list):
    print ('Processing: ', i, '/', len(locations_list), loc)
    try: 
        location = geolocator.geocode(loc)
        location_data.append({'Place': loc, 'Lat': location.latitude, 
                              'Lon': location.longitude, 'Address': location.address})
    
    except:
        location_data.append({'Place': loc, 'Lat': '', 
                              'Lon': '', 'Address': ''})
        
location_df = pd.DataFrame(location_data)

location_df.to_csv('locations_info.csv')


# In[45]:


del df['Unnamed: 0']
df.to_csv("/Users/hadinowandish/Downloads/2022_11_16_Master.csv")


# In[41]:


df


# In[ ]:




