# Kinokroonika
The Kinokroonika dataset is composed of Estonian newsreel data digitized and stored in the Estonian Film Archive of the Estonian National Archives (EFA - https://www.ra.ee/en/film-photo-audio/film/) and the Estonian Film Database (EFDB - https://www.efis.ee/) that was enriched by the Kinokroonika Exploration Project. Computational Data Enrichment and Distant Viewing of Estonian Newsreels (1922-1997) project. The Kinokroonika project is funded by the Estonian Language and Culture in the Digital Age (EKKD), a national program of the Ministry of Education and Research of the Republic of Estonia for April 2022-February 2023 (funding no EKKD77).
In this project, we performed the following major tasks via python programming language: 
* Name-Entity Recognition (NER)
* Automated Gender Detection of authors and persons detected by NER
* Geo Coordinates of Places
* pairs of co-occurrences

## How to merge two dataframe

_df_new1 = df_new.append(extract_rows2, ignore_index = True)_
