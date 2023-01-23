#!/usr/bin/env python
# coding: utf-8

# In[21]:


import pandas as pd
from estnltk import Text, Layer
from gensim.models import Word2Vec
from estnltk.taggers import NerTagger
from estnltk.taggers import VislTagger
from estnltk.taggers import MaltParserTagger
from estnltk.taggers import ConllMorphTagger
from estnltk.taggers import Tagger
import nltk
from nltk.tokenize import sent_tokenize
import spacy


# In[22]:


dataset = pd.read_csv("/Users/hadinowandish/master_csv.csv", low_memory=False)


# In[6]:


title_NER = []
for title in dataset.title.to_list():
    text = Text(str(title))
    text.tag_layer('ner')

    title_NER.append(text.ner)


# In[7]:


dataset['title_NER'] = [x.spans for x in title_NER]


# In[8]:


title_proper_NER = []
for titleProper in dataset.title_proper.to_list():
    text = Text(str(titleProper))
    text.tag_layer('ner')

    title_proper_NER.append(text.ner)


# In[9]:


dataset['title_proper_NER'] = [x.spans for x in title_proper_NER]


# In[10]:


keyword_values_et_NER = []
for keywordvalueset in dataset.keyword_values_et.to_list():
    text = Text(str(keywordvalueset))
    text.tag_layer('ner')

    keyword_values_et_NER.append(text.ner)


# In[13]:


dataset['keyword_values_et_NER'] = [x.spans for x in keyword_values_et_NER]


# In[15]:


keyword_values_en_NER = []
for keywordvaluesen in dataset.keyword_values_en.to_list():
    text = Text(str(keywordvaluesen))
    text.tag_layer('ner')

    keyword_values_en_NER.append(text.ner)


# In[16]:


dataset['keyword_values_en_NER'] = [x.spans for x in keyword_values_en_NER]


# In[17]:


parallel_title_NER = []
for paralleltitle in dataset.parallel_title.to_list():
    text = Text(str(paralleltitle))
    text.tag_layer('ner')

    parallel_title_NER.append(text.ner)


# In[18]:


dataset['parallel_title_NER'] = [x.spans for x in parallel_title_NER]


# In[19]:


dataset


# In[20]:


dataset.to_csv('dataset.csv')


# In[ ]:




