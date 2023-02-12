rm(list=ls())
clearhistory <- function() {
  write("", file=".blank")
  loadhistory(".blank")
  unlink(".blank")
}
library(dplyr)
library(readr)
library(xml2)
library(XML)
library(readxl)
library(purrr)
library(tidyverse)
library(readxl)
setwd("/Users/abii/Documents")
all_files <- list.files('EFIS data export_2022-04/', pattern = "\\.xml$" , full.names = TRUE)
read_data_and_assign_names <- function(file) {
  new_data <- NULL
  tryCatch({
    data <- xmlParse(file)
    xL <- xmlToList(data)
    tmp <- xL$Worksheet$Table[names(xL$Worksheet$Table) == "Row"]
    data_names <- sapply(seq_along(tmp[[1]]), function(x) tmp[[1]][[x]]$Data$text)
    new_data <- data.frame(t(sapply(seq_along(tmp[-1]), function(i)  {
      tmp1 <- tmp[[i + 1]]
      sapply(seq_along(tmp1), function(x) tryCatch(tmp1[[x]]$Data$text, error = function(e) NA))
    })))
    
    names(new_data) <- data_names
    print(head(new_data))
  }, error = function(e) message(sprintf("Cannot workout for file %s", file)))
  
  new_data
}
result <- lapply(all_files, read_data_and_assign_names)
Map(function(x, y) if(NROW(x)) write.csv(x, y, row.names = FALSE), result, sub('xml$', 'csv', all_files))
filter <- dplyr::filter
collapse_in_one_string <- function(x) paste0(unique(na.omit(x)), collapse = ";")
#Install it once
#remotes::install_github("bnosac/nametagger")
library(nametagger)

filter <- dplyr::filter
collapse_in_one_string <- function(x) paste0(unique(na.omit(x)), collapse = ";")

#File 1
file1 <- read_csv('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film.csv')
file1 <- file1 %>%
  select(film_id, film_seq_id, production_year) %>%
  group_by(film_id) %>%
  summarise(across(c(film_seq_id, production_year), collapse_in_one_string), .groups = "drop")

#File 2
file2 <- read_csv('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film_track.csv')

file2 <- file2 %>%
  mutate(language_code = sub('.*_(.*)', '\\1', language_code),
         classificator_code = sub('.*_', '', classificator_code)) %>%
  pivot_wider(names_from = classificator_code,
              values_from = language_code,
              names_glue = 'film_{classificator_code}_lang') %>%
  rename_with(tolower) %>%
  select(film_id, film_presentation_lang, film_voiceover_lang, film_subtitles_lang) %>%
  group_by(film_id) %>%
  summarise(across(.fns = collapse_in_one_string), .groups = "drop")


#File 3
file3 <- read_csv('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film_title_episode.csv')
file3 <- file3 %>%
  select(film_id, title) %>%
  group_by(film_id) %>%
  summarise(across(.fns = collapse_in_one_string), .groups = "drop")


#File 4
file4 <- read_csv('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film_title_parallel.csv')
file4 <- file4 %>%
  select(film_id, parallel_title = title) %>%
  group_by(film_id) %>%
  summarise(across(.fns = collapse_in_one_string), .groups = "drop")


#File 5
file5 <- read_csv('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film_physical_description.csv')
file5 <- file5 %>%
  mutate(classificator_code2 = sub('_TYPE_FILM_FILM', '', classificator_code2)) %>%
  select(film_id, classificator_code2, amount) %>%
  pivot_wider(names_from = classificator_code2, values_from = amount,
              values_fn = collapse_in_one_string) %>%
  rename_with(tolower) %>%
  select(film_id, film_physical_duration, film_physical_metrage, film_physical_notes)

#File 6
file6 <- read_csv('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film_country.csv')
file6 <- file6 %>%
  group_by(film_id) %>%
  summarise(country_id = collapse_in_one_string(country_id))


#File 7
file7 <- read_csv('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film_production.csv')
file7 <- file7 %>%
  filter(classificator_code %in% c('FILM_PRODUCTION_PRODUCTION_COMPANIES', 'FILM_PRODUCTION_COPRODUCERS',
                                   'FILM_PRODUCTION_SOUND_EDITORS', 'FILM_PRODUCTION_CUSTOMERS')) %>%
  select(film_id, classificator_code, company_name) %>%
  pivot_wider(names_from = classificator_code, values_from = company_name,
              values_fn = collapse_in_one_string) %>%
  rename_with(~sub('film_production_', '', tolower(.))) %>%
  rename(production_customers = customers)


#File 8
file8 <- read_csv('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film_music.csv')
file8 <- file8 %>%
  filter(!is.na(music_maker_classificator_code)) %>%
  unite(full_name, first_name, last_name, sep = ' ', na.rm = TRUE) %>%
  unite(birth_death, date_of_birth, date_of_death, sep = '-', na.rm = TRUE) %>%
  group_by(film_id, music_maker_classificator_code) %>%
  summarise(across(.fns = collapse_in_one_string), .groups = "drop") %>%
  pivot_wider(names_from = music_maker_classificator_code, values_from = -film_id,
              names_glue = "{music_maker_classificator_code}_{.value}")

file9 <- read_csv('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film_edition.csv')
file9 <- file9 %>%
  filter(!is.na(classificator_code)) %>%
  select(-lang, -seq) %>%
  pivot_wider(names_from = classificator_code, values_from = title, values_fn = collapse_in_one_string) %>%
  rename(film_variation = FILM_EDITION_TYPE_VARIATION, film_version = FILM_EDITION_TYPE_VERSION)


file10 <- read_csv('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film_screening.csv')
file10 <- file10 %>%
  select(film_id, classificator_code, location, event_info) %>%
  filter(!is.na(classificator_code)) %>%
  mutate(classificator_code = tolower(gsub('FILM_|_TYPE', '', classificator_code))) %>%
  rename(loc = location, date = event_info) %>%
  pivot_wider(names_from = classificator_code, values_from = c(loc, date),
              values_fn = collapse_in_one_string,
              names_glue = "{classificator_code}_{.value}")


file11 <- read_csv('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film_relation.csv')
file11 <- file11 %>%
  filter(!is.na(classificator_code)) %>%
  mutate(classificator_code = recode(classificator_code, 'FILM_RELATION_TYPE_FILM' = 'relation_film',
                                     'FILM_RELATION_TYPE_SERIES' = 'relation_series')) %>%
  group_by(film_id, classificator_code) %>%
  summarise(film_seq_related_id = collapse_in_one_string(film_seq_related_id), .groups = "drop") %>%
  pivot_wider(names_from = classificator_code, values_from = film_seq_related_id)


file12 <- read_excel('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film_maker.xlsx')
file12 <- file12 %>%
  unite(full_name, first_name, last_name, sep = ' ', na.rm = TRUE) %>%
  filter(!is.na(classificator_code)) %>%
  mutate(classificator_code = sub('FILM_MAKER_', '', classificator_code)) %>%
  select(-seq) %>%
  unite(birth_death, date_of_birth, date_of_death, sep = '-', na.rm = TRUE) %>%
  pivot_wider(names_from = classificator_code, values_from = people_id:notes,
              values_fn = collapse_in_one_string)

file13 <- read_excel('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film_keyword.xlsx')
file13_1 <- file13 %>%
  filter(!is.na(keyword_language)) %>%
  select(film_id, keyword_language, keyword_value) %>%
  pivot_wider(names_from = keyword_language, values_from = keyword_value,
              values_fn = collapse_in_one_string, names_prefix = "keyword_values_")

file13_2 <- file13 %>%
  filter(!is.na(keyword_group_language)) %>%
  select(film_id, keyword_group_language, keyword_group_value) %>%
  pivot_wider(names_from = keyword_group_language, values_from = keyword_group_value,
              values_fn = collapse_in_one_string, names_prefix = "keyword_group_")

file13 <- file13_1 %>% inner_join(file13_2, by = 'film_id')

file14 <- read_excel('/Users/abii/Documents/EFIS data export_2022-04/efis.efis_film_translation_1.xlsx')
file14 <- file14 %>%
  group_by(film_id) %>%
  summarise(across(.fns = collapse_in_one_string))

master_csv <- mget(paste0('file', 1:14)) %>% reduce(left_join, by = 'film_id')

#Drop unwanted columns
master_csv <- master_csv %>%
  select(-contains('music_maker_classificator_code')) %>%
  mutate(issue_no = str_extract(title_alternative, '(?<=nr\\.?\\s)\\d+'))

#Remove columns that are empty or NA
drop_columns <- names(master_csv)[colSums(is.na(master_csv) | master_csv == "", na.rm = TRUE) == nrow(master_csv)]
master_csv <- master_csv %>% select(-all_of(drop_columns))
drp<-c('production_customers',
       'FILM_MUSIC_MAKER_TYPE_PERFORMER_year_founded',
       'FILM_MUSIC_MAKER_TYPE_PERFORMER_company_notes',
       'people_id_CONDUCTOR',
       'people_id_AUDIO_TECHNICIAN',
       'people_id_ARTIST_ANIMATOR',
       'people_id_1_ASSITING_CAMERA',
       'people_id_SOUND_RECORDING__ASSITANT',
       'people_id_LIGHTING_DIRECTOR_LD_GAFFER',
       'people_id_PRODUCER',
       'people_id_TRIC_CAMERA',
       'people_id_TECHNITIAN_',
       'people_id_CAMERA_MAN',
       'people_id_WRITER',
       'people_id_DOLLY_GRIP',
       'people_id_ANIMATOR',
       'people_id_AUTHOR' ,
       'people_id_RE_RECORDING_MIXER_DUBBING_MIXER' ,
       'people_id_WRITER_OF_DIALOGUE' ,
       'people_id_REPORTER ',
       'full_name_CONDUCTOR' ,
       'full_name_AUDIO_TECHNICIAN' ,
       'full_name_ARTIST_ANIMATOR' ,
       'full_name_1_ASSITING_CAMERA' ,
       'full_name_SOUND_RECORDING__ASSITANT' ,
       'full_name_LIGHTING_DIRECTOR_LD_GAFFER' ,
       'full_name_PRODUCER',
       'full_name_TRICK_CAMERA',
       'full_name_TECHNITIAN_',
       'full_name_CAMERA_MAN'  ,
       'full_name_WRITER' ,
       'full_name_DOLLY_GRIP' ,
       'full_name_ANIMATOR' ,
       'full_name_AUTHOR' ,
       'full_name_RE_RECORDING_MIXER_DUBBING_MIXER' ,
       'full_name_WRITER_OF_DIALOGUE ',
       'full_name_REPORTER',
       'date_of_birth_CONDUCTOR' ,
       'date_of_birth_AUDIO_TECHNICIAN' ,
       'date_of_birth_ARTIST_ANIMATOR',
       'date_of_birth_1_ASSITING_CAMERA', 
       'date_of_birth_SOUND_RECORDING__ASSITANT' ,
       'date_of_birth_LIGHTING_DIRECTOR_LD_GAFFER',
       'date_of_birth_PRODUCER' ,
       'date_of_birth_TRICK_CAMERA',
       'date_of_birth_TECHNITIAN_',
       'date_of_birth_CAMERA_MAN' ,
       'date_of_birth_WRITER' ,
       'date_of_birth_DOLLY_GRIP',
       'date_of_birth_ANIMATOR',
       'date_of_birth_AUTHOR' ,
       'date_of_birth_RE_RECORDING_MIXER_DUBBING_MIXER' ,
       'date_of_birth_WRITER_OF_DIALOGUE' ,
       'date_of_birth_REPORTER',
       'date_of_death_CONDUCTOR',
       'date_of_death_AUDIO_TECHNICIAN',
       'date_of_death_ARTIST_ANIMATOR' ,
       'date_of_death_1_ASSITING_CAMERA',
       'date_of_death_SOUND_RECORDING__ASSITANT',
       'date_of_death_LIGHTING_DIRECTOR_LD_GAFFER ',
       'date_of_death_PRODUCER', 
       'date_of_death_TRICK_CAMERA',
       'date_of_death_TECHNITIAN_' ,
       'date_of_death_CAMERA_MAN' ,
       'date_of_death_WRITER' ,
       'date_of_death_DOLLY_GRIP' ,
       'date_of_death_ANIMATOR' ,
       'date_of_death_AUTHOR' ,
      'date_of_death_RE_RECORDING_MIXER_DUBBING_MIXER ', 
       'date_of_death_WRITER_OF_DIALOGUE' ,
       'date_of_death_REPORTER' ,
       'num_related_films_CONDUCTOR' ,
       'num_related_films_AUDIO_TECHNICIAN' ,
       'num_related_films_ARTIST_ANIMATOR' ,
       'num_related_films_1_ASSITING_CAMERA',
       'num_related_films_SOUND_RECORDING__ASSITANT',
       'num_related_films_LIGHTING_DIRECTOR_LD_GAFFER',
       'num_related_films_PRODUCER',
       'num_related_films_TRICK_CAMERA',
       'num_related_films_TECHNITIAN_',
       'num_related_films_CAMERA_MAN',
       'num_related_films_WRITER',
       'num_related_films_DOLLY_GRIP',
       'num_related_films_ANIMATOR',
       'num_related_films_AUTHOR',
       'num_related_films_RE_RECORDING_MIXER_DUBBING_MIXER',
       'num_related_films_WRITER_OF_DIALOGUE',
       'num_related_films_REPORTER',
       'notes_CONDUCTOR' ,
       'notes_AUDIO_TECHNICIAN' ,
       'notes_ARTIST_ANIMATOR',
       'notes_1_ASSITING_CAMERA' ,
       'notes_SOUND_RECORDING__ASSITANT',
       'notes_LIGHTING_DIRECTOR_LD_GAFFER' ,
       'notes_PRODUCER',
       'notes_TRICK_CAMERA',
       'notes_TECHNITIAN_',
       'notes_CAMERA_MAN' ,
       'notes_WRITER',
        'notes_DOLLY_GRIP',
       'notes_ANIMATOR',
       'notes_AUTHOR' ,
       'notes_RE_RECORDING_MIXER_DUBBING_MIXER' ,
       'notes_WRITER_OF_DIALOGUE',
       'notes_REPORTER'
)
master_csv<-master_csv[,!(names(master_csv) %in% drp)]
write.csv(master_csv, 'master_csv.csv', fileEncoding = "UTF-8", row.names = FALSE)
#-----------------------------------------------------------------------------------------