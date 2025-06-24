
<!-- README.md is generated from README.Rmd. Please edit that file -->

# hpcalibrater

<!-- badges: start -->

<!-- badges: end -->

hpcalibrater creates a micro-calibrated ABM model for heat pump uptake
by Irish households.

## Installation

You can install the development version of hpcalibrater like so:

``` r
# install_github()
```

## Example

Survey data for 804 owner-occupiers with 39 features plus HH ID and
stated likelihood-to-adopt.

``` r
library(hpcalibrater)
library(tidyverse)
## basic example code
hp_survey_oo %>% dim()
#> [1] 804  41
```

Survey questions and answers are in:

``` r
hp_questions %>% head()
#> # A tibble: 6 × 2
#>   question        question_code
#>   <chr>           <chr>        
#> 1 Gender          qa           
#> 2 Age             qb           
#> 3 Region          qc2          
#> 4 Social Grade    qd           
#> 5 Work status     qe           
#> 6 Education level qf
```

Futher feature selection before passing to xgboost for model
micro-calibration

``` r
## basic example code
feature_select(hp_survey_oo) %>% dim()
#> [1] 804  32
```

Run GBM

``` r
bst <- get_boosted_tree_model(transform_to_utils(feature_select(hp_survey_oo,recode_bills=T,n_bill=5),epsilon=0.7))
shap_scores_long <- get_shap_scores(transform_to_utils(feature_select(hp_survey_oo,recode_bills=T,n_bill=5),epsilon=0.7),bst)
```

Extract partial utilities from shap_scores_long based on financial
feature (heating bills), social feature ()

``` r
get_empirical_partial_utilities(shap_scores_long)
#> Joining with `by = join_by(question_code)`
#> Joining with `by = join_by(question_code, response_code)`
#> # A tibble: 11 × 3
#> # Groups:   question_code [3]
#>    question_code response_code du_average
#>    <chr>                 <dbl>      <dbl>
#>  1 q13                       1    0.00378
#>  2 q13                       2    0.00380
#>  3 q13                       3    0.00370
#>  4 q13                       4    0.00399
#>  5 q13                       5    0.00756
#>  6 q13                       6    0.00725
#>  7 q52                       1    0.00542
#>  8 q52                       2    0.00320
#>  9 q52                       3    0.0126 
#> 10 q52                       4    0.0150 
#> 11 theta                    NA   -0.0924
```

``` r
get_model_weights(shap_scores_long,regularisation=1) %>% head()
#> Joining with `by = join_by(question_code)`
#> Joining with `by = join_by(question_code, response_code)`
#> # A tibble: 6 × 4
#>      ID w_q52 w_q13 w_theta
#>   <int> <dbl> <dbl>   <dbl>
#> 1     1 0.735 0.781   0.849
#> 2     2 1.00  1.29    0.825
#> 3     3 0.878 0.943   0.655
#> 4     4 1.19  1.33    0.842
#> 5     5 0.870 1.12    0.651
#> 6     6 1.06  1.35    0.920
```

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
