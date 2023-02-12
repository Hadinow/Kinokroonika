#!/usr/bin/env python
# coding: utf-8

# In[1]:


from genderize import Genderize
import gender_guesser.detector as gender
import pandas as pd

# In[2]:


authors_name=pd.read_csv("/Users/hadinowandish/authors_test7.csv")

# In[4]:


authors_name

# In[5]:


gd = gender.Detector()
authors_name['Gender'] = authors_name['authors_test5'].map(lambda x: gd.get_gender(x.split()[0]))

# In[6]:


authors_name['Gender']

# In[7]:


authors_name['Gender'].value_counts() 

# In[8]:


authors_name

# In[10]:


names = [x.split()[0] for x in authors_name['authors_test5']]
g = Genderize().get(names)

# In[11]:


Gend_Det = pd.DataFrame(g) 

# In[12]:


Gend_Det

# In[13]:


Gend_Det.rename(columns={'name':'First_Name'}, inplace=True)

# In[14]:


result = authors_name.join(Gend_Det)

# In[26]:


result

# In[16]:


result["correct_name"], result["correct_gender"], result["birthplace_manual"], result["source_manual"] = "", "", "", ""

# In[17]:


result.rename(columns={'authors_test5':'Full_Name', 'Gender':'Full_Name_Gender', 'gender':'First_Name_Gender'}, inplace=True)

# In[29]:


result= result[["Full_Name", "Full_Name_Gender", "First_Name", "First_Name_Gender", "probability", 
       "correct_name", "correct_gender", "birthplace_manual", "source_manual"]]

# In[30]:


result

# In[31]:


result.to_csv("Authors_Gender_Birthplace.csv", index=False)

# In[ ]:



