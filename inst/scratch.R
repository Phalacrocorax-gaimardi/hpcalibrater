############
# scratch file
###########

library(tidyverse)
library(pvcalibrater)
library(export)


hp_questions <- read_csv("~/Policy/SurveyDataAndAnalysis/Analysis/Preferences/HP/hp_questions.csv")
#zet survey questions and answers
qanda <- read_csv("~/Policy/SurveyDataAndAnalysis/Data/ZET_survey_2024_qanda.csv")


zet_survey <- readxl::read_xlsx("~/Policy/SurveyDataAndAnalysis/Data/ZET_survey_2024_values.xlsx",sheet=1)
zet_survey_lab <- readxl::read_xlsx("~/Policy/SurveyDataAndAnalysis/Data/ZET_survey_2024_data_labels.xlsx",sheet=1)

hp_survey <- zet_survey %>% dplyr::select(hp_questions$question_code)
dim(hp_survey)
#replace
hp_survey <- hp_survey %>% mutate(across(,~ifelse(. %in% c(-99,-98),NA,.)))
#comb



####################################
# predicting HP likliehood-to-adopt
####################################
hp_questions <- read_csv("~/Policy/SurveyDataAndAnalysis/Analysis/Preferences/HP/hp_questions.csv")
#zet survey questions and answers
qanda <- read_csv("~/Policy/SurveyDataAndAnalysis/Data/ZET_survey_2024_qanda.csv")


zet_survey <- readxl::read_xlsx("~/Policy/SurveyDataAndAnalysis/Data/ZET_survey_2024_values.xlsx",sheet=1)
zet_survey_lab <- readxl::read_xlsx("~/Policy/SurveyDataAndAnalysis/Data/ZET_survey_2024_data_labels.xlsx",sheet=1)

hp_survey <- zet_survey %>% dplyr::select(hp_questions$question_code)
dim(hp_survey)
#replace
hp_survey <- hp_survey %>% mutate(across(,~ifelse(. %in% c(-99,-98),NA,.)))

#if already adopted, label as "very likely to adopt"
#include current adopters as very likely to adopt
hp_survey <- hp_survey %>% mutate(q53_5=replace(q53_5, q263==1 | q264==1,5)) %>% dplyr::select(-q263,-q264,-q265)

dim(hp_survey)
#replace
hp_survey <- hp_survey %>% mutate(across(,~ifelse(. %in% c(-99,-98),NA,.)))

hp_survey$q53_5 %>% table()

#reclass don't knows as neutrals
#
hp_survey <- hp_survey %>% mutate(q53_5 = replace(q53_5,q53_5==6,3))
#hp_survey <- hp_survey %>% filter(!is.na(q53_5) & q53_5 != 7 & q53_5 != 6)
hp_survey$q53_5 %>% table()

dim(hp_survey)
#remove views
hp_survey <- hp_survey %>% dplyr::select(-q56_1,-q56_2,-q57,-q53_1,-q53_2,-q53_3,-q53_4)
#remove bill questions apart from total heating cost
#owner-occupiers


#hp_survey <- hp_survey %>% dplyr::select(-q14,-q15,-q16,-q17,-q18,-q19)
#owner occupiers
write_csv(hp_survey,"~/Policy/SurveyDataAndAnalysis/Analysis/Preferences/HP/hp_survey.csv")
hp_survey_oo <- hp_survey %>% dplyr::filter(q4 %in% 1:2)
#write_csv(hp_survey_oo,"~/Policy/SurveyDataAndAnalysis/Analysis/Preferences/HP/hp_survey_oo.csv")
#remove most likely fuel source
hp_survey_oo_calibrate <- hp_survey_oo %>% dplyr::select(-q23)
#remove enviro identity (strongly correlated with climate concern) and easily attached to material
#hp_survey <- hp_survey %>% dplyr::select(-q30_3,-q30_6)
#remove area lived in (correlated to property type)
#hp_survey <- hp_survey %>% dplyr::select(-qg)
#remove satisfaction with home heating system
hp_survey_oo_calibrate  <- hp_survey_oo_calibrate %>% dplyr::select(-q27)
hp_questions_calibrate <- hp_questions %>% filter(question_code %in% names(hp_survey_oo_calibrate))
#
hp_survey_oo_calibrate  <- hp_survey_oo_calibrate %>% dplyr::select(-q81,-q82,-q83,-q84,-q85,-q86,-q87,-q88,-q89)
hp_questions_calibrate <- hp_questions_calibrate %>% filter(question_code %in% names(hp_survey_oo_calibrate))
#remove secodnary heating source
hp_survey_oo_calibrate  <- hp_survey_oo_calibrate %>% dplyr::select(-q121,-q122,-q123,-q124,-q125,-q126,-q127,-q128,-q129)
hp_questions_calibrate <- hp_questions_calibrate %>% filter(question_code %in% names(hp_survey_oo_calibrate))
#remove bills questions except q13
hp_survey_oo_calibrate  <- hp_survey_oo_calibrate %>% dplyr::select(-q14,-q15,-q16,-q17,-q18,-q19,-q20,-q21)
hp_questions_calibrate <- hp_questions_calibrate %>% filter(question_code %in% names(hp_survey_oo_calibrate))
#remove grants info except whether have received a grant
hp_survey_oo_calibrate  <- hp_survey_oo_calibrate %>% dplyr::select(-q2502,-q2503,-q2504,-q2505,-q2506,-q2507,-q2508,-q2508,-q2509,-q2510)
hp_questions_calibrate <- hp_questions_calibrate %>% filter(question_code %in% names(hp_survey_oo_calibrate))
#remove bill perception
hp_survey_oo_calibrate  <- hp_survey_oo_calibrate %>% dplyr::select(-q24)
hp_questions_calibrate <- hp_questions_calibrate %>% filter(question_code %in% names(hp_survey_oo_calibrate))
dim(hp_questions_calibrate)

hp_survey_oo_calibrate  <- hp_survey_oo_calibrate %>% dplyr::select(-q26_1_3,-q26_1_4,-q26_2_1,-q26_2_2)
hp_questions_calibrate <- hp_questions_calibrate %>% filter(question_code %in% names(hp_survey_oo_calibrate))

hp_survey_oo_calibrate  <- hp_survey_oo_calibrate %>% dplyr::select(-qc1)
hp_questions_calibrate <- hp_questions_calibrate %>% filter(question_code %in% names(hp_survey_oo_calibrate))


hp_survey_oo_calibrate <- hp_survey_oo_calibrate %>% filter(!is.na(q53_5))

dim(hp_survey_oo_calibrate)#42 variables
hp_qanda <- qanda %>% filter(question_code %in% names(hp_survey))

#write_csv(hp_survey_oo_calibrate,"~/Policy/SurveyDataAndAnalysis/Analysis/Preferences/HP/hp_survey_oo_calibrate.csv")
#write_csv(hp_questions_calibrate,"~/Policy/SurveyDataAndAnalysis/Analysis/Preferences/HP/hp_questions_calibrate.csv")
