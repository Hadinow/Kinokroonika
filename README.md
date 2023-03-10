# Kinokroonika
The Kinokroonika dataset is composed of Estonian newsreel data digitized and stored in the Estonian Film Archive of the Estonian National Archives (EFA - https://www.ra.ee/en/film-photo-audio/film/) and the Estonian Film Database (EFDB - https://www.efis.ee/) that was enriched by the Kinokroonika Exploration Project. Computational Data Enrichment and Distant Viewing of Estonian Newsreels (1922-1997) project. The Kinokroonika project is funded by the Estonian Language and Culture in the Digital Age (EKKD), a national program of the Ministry of Education and Research of the Republic of Estonia for April 2022-February 2023 (funding no EKKD77).
In this project, we performed the following major tasks via python programming language: 
* Name-Entity Recognition (NER)
* Automated Gender Detection of authors and persons detected by NER
* Geo Coordinates of Places
* pairs of co-occurrences

## How to merge two dataframes

```
df_new1 = df_new.append(extract_rows2, ignore_index = True)_
```
## Extract rows with single condition and multiple values

Extract all rows that match with specific values of a dataframe column in pandas python. The python code is as follow:
```
extract_rows2 = Geocoordinate_2[Geocoordinate_2["Place_Catagory"].str.contains("multiple locations|mountains|country|region|river|lake") == True]
```
## Remove range of rows in R
The following R script is used to remove a range of rows based on the index of dataframe.
```
df <- df[-(160:1500), ]
```
## Rearrange the collumns of dataframe in R
In order to relocate the column of dataframe we use the **relocate()** function and **.before** and **.after** to specifiy the location of column.
```
df <- df %>% relocate(ID, .before  = authors_test)
df <- df %>% relocate(ID, .after  = authors_test)
```
