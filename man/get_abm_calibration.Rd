% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/microcalibrater.R
\name{get_abm_calibration}
\alias{get_abm_calibration}
\title{get_abm_calibration}
\usage{
get_abm_calibration(shap_scores_long, stat = "mean", regularisation = 1)
}
\arguments{
\item{shap_scores_long}{individual shap scores by feature (output from get_shap_scores)}

\item{stat}{statistic - median (default) or mean}

\item{regularisation}{regularisation 0=none, 1= full, > 1 over, < 1 under}
}
\value{
data frame giving partial utilities for abstracted model features and residual (theta) terms and individual weights
}
\description{
returns abm partial utilities for the selected features (q9_1 and qsp21) and barrier (theta) terms in ABM model for each agent. Results are expressed as mean
partial utilities corresponding to each survey response and individual weights for each agent. A regularisation parameter can be
used to ensure that model weights for financial and social variables are > 1, or some negative weights can be tolerated.
}
