% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/microcalibrater.R
\name{feature_select}
\alias{feature_select}
\title{feature_select}
\usage{
feature_select(hp_data_in, recode_bills = F, n_bill = NULL, recode_income = T)
}
\arguments{
\item{hp_data_in}{hp_survey_oo or hp_survey}

\item{recode_bills}{if true an annual bill feature q_ab is introduced with values}

\item{n_bill}{number of bill categories}

\item{recode_income}{if true recode income}
}
\value{
reduced survey dataframe
}
\description{
feature_select does a further feature selection from hp_survey_oo_calibrate before passing to xgb. Features removed include
serial and social grade.Optionally, it also creates new features such as an interaction between heating bill and income
}
\details{
For example
selected features from hp survey dataset before calibration
if recode_bills=T the number of bill categories is reduced to n_bill < 13
}
