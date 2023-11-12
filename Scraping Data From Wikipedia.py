#!/usr/bin/env python
# coding: utf-8

# # Scraping Data from Wikipedia

# In[1]:


from bs4 import BeautifulSoup
import requests
import pandas as pd


# In[2]:


url = 'https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue'
page = requests.get(url)
soup = BeautifulSoup(page.text, 'html')


# In[3]:


soup.find('table', class_ = 'wikitable sortable')


# In[4]:


table = soup.find('table', class_ = 'wikitable sortable')


# In[5]:


table.find_all('th')


# In[6]:


world_titles = table.find_all('th')


# In[7]:


world_titles


# In[8]:


world_table_titles = [title.text.strip() for title in world_titles]

print(world_table_titles)


# In[10]:


df = pd.DataFrame(columns = world_table_titles)

df


# In[11]:


column_data = table.find_all('tr')


# In[12]:


for row in column_data[1:]:
    row_data = row.find_all('td')
    individual_row_data = [data.text.strip() for data in row_data]
    
    length = len(df)
    df.loc[length] = individual_row_data
    


# In[13]:


df


# In[14]:


df.to_csv(r'C:\Users\seans\Desktop\Data Analysis Projects\Pandas Project\Companies.csv', index = False)


# In[ ]:





# In[ ]:





# In[ ]:




