#hp_survey_oo_calibrate <- read_csv("~/Policy/SurveyDataAndAnalysis/Analysis/Preferences/HP/hp_survey_oo_calibrate.csv")
#hp_survey <- read_csv("~/Policy/SurveyDataAndAnalysis/Analysis/Preferences/HP/hp_survey.csv")
#bill_values <- read_csv("~/Policy/SurveyDataAndAnalysis/Analysis/Preferences/HP/heating_bill_values.csv")
#hp_questions_calibrate <- read_csv("~/Policy/SurveyDataAndAnalysis/Analysis/Preferences/HP/hp_questions_calibrate.csv")
#hp_qanda_calibrate <- qanda %>% filter(question_code %in% hp_questions_calibrate$question_code)


#' recode_bill
#'
#' reduces the number of heating bill categories
#'
#' @param hp_data_in input survey data
#' @param n_bill number of heating bill categories
#'
#' @returns a new survey dataframe with annual bills range 1~ < 900, 2~900-1350, 3~1350 to 1650, 4~1650-2100,5~> 2100
#' @export
#'
#' @examples
recode_bill <- function(hp_data_in,n_bill){

  hp_data_in0 <- hp_data_in %>% dplyr::select(-q13)
  hp_data_in1 <- hp_data_in %>% dplyr::select(q13) %>% dplyr::inner_join(bill_values %>% dplyr::rename("q13"=response_code))
  x <- hp_data_in1 %>% dplyr::filter(bill != "Don't know") %>% dplyr::pull(bill) %>% as.numeric() %>% quantile(,probs=seq(0,1,length.out=n_bill+1))
  x <- as.numeric(x)

  hp_data_in1 <- hp_data_in1 %>% dplyr::mutate(q13_new= as.integer(suppressWarnings(cut(as.numeric(bill),breaks=x,labels=1:n_bill))))
  hp_data_in1 <- hp_data_in1 %>% dplyr::mutate(q13_new = dplyr::if_else(is.na(as.numeric(q13_new)),n_bill+1, q13_new))
  #pv_data_in <- pv_data_in %>% dplyr::mutate(q_ab = dplyr::case_when(annual_bill < 1000~1,annual_bill>=1000 & annual_bill < 2000~2,
  #                                          annual_bill > 2000~3))
  hp_data_in1 <- hp_data_in1 %>% dplyr::select(q13_new) %>% dplyr::rename("q13"=q13_new)
  hp_data_in0 %>% dplyr::bind_cols(hp_data_in1) %>% return()
}


recode_eduation <- function(n){

  qanda %>% filter(question_code == "qf")
  n_new <- case_when( n %in% c(1:4,9)~1, !(n %in% c(1:4,9))~n-3)
  return(n_new)
}

recode_income <- function(n, n_income=3){

  if(n_income==5) n_new <- dplyr::case_when( n %in% c(1:2)~1, n %in% 3:4~2, n %in% 5:6~3, n %in% 7:8~4, n %in% 9:11~5, n==12~6)
  if(n_income==3) n_new <- dplyr::case_when( n %in% c(1:3)~1, n %in% 4:6~2, n %in% 7:11~3, n==12~4)
  return(n_new)
}

recode_qanda <- function(){

  qanda_recode <- qanda %>% filter(!(question_code %in% c("qh","qf")))
  #education
  qanda_qf <- qanda %>% filter(question_code == "qf") %>% mutate(response_code=recode_eduation(response_code))
  qanda_qf <- qanda_qf %>% mutate(response = ifelse(response_code==1,"Higher Secondary (Leaving Certificate / A-levels)",response))
  qanda_qf <- qanda_qf %>% distinct()
  #income
  qanda_qh <- qanda %>% filter(question_code == "qh") %>% mutate(response_code=recode_income(response_code))
  qanda_qh <- qanda_qh %>% mutate(response = case_when(response_code==1~"Less than 36,000",
                                                       response_code==2~"26,000- 42,999",
                                                       response_code==3~ "43,000- 68,999",
                                                       response_code==4~ "69,000- 104,999",
                                                       response_code==5~ "More than 105,000",
                                                       response_code==6~"Prefer not to say"))
  qanda_qh <- qanda_qh %>% distinct()

  qanda_qh <- qanda_qh %>% distinct()

  qanda_recode %>% bind_rows(qanda_qh,qanda_qf) %>% return()

}


#' feature_select
#'
#' feature_select does a further feature selection from hp_survey_oo_calibrate before passing to xgb. Features removed include
#' serial and social grade.Optionally, it also creates new features such as an interaction between heating bill and income
#'
#' For example
#' selected features from hp survey dataset before calibration
#' if recode_bills=T the number of bill categories is reduced to n_bill < 13
#'
#' @param hp_data_in hp_survey_oo or hp_survey
#' @param recode_bills if true an annual bill feature q_ab is introduced with values
#' @param n_bill number of bill categories
#' @param recode_income if true recode income
#'
#' @returns reduced survey dataframe
#' @export
#'
#' @examples
feature_select <- function(hp_data_in, recode_bills=F, n_bill=NULL,recode_income=T){

  #pv_data_out <- pv_data_in %>% dplyr::filter(q262 != 1) #remove current adopters
  #hp_data_out <- hp_data_in %>% dplyr::select(-serial) #remove serial
  #hp_data_out <- hp_data_in %>% dplyr::select(-qc1)
  #remove social grade and tariff questions
  #pv_data_out <- pv_data_out %>% dplyr::select(-qd,-q40,-q41,-q43,-q44) #remove social grade, tariff questions
  #remove additional enviro questions
  #hp_data_out <- hp_data_out %>% dplyr::select(-q30_4,-q30_5)
  #remove operating time questions
  #hp_data_out <- hp_data_out %>% dplyr::select(-q20,-q22)
  #future fuel source preference
  #hp_data_out <- hp_data_out %>% dplyr::select(-q23)
  #remove secondary heating source
  #hp_data_out <- hp_data_out %>% dplyr::select(-q128,-q129)
  #perception of cost
  #hp_data_out <- hp_data_out %>% dplyr::select(-q24)
  #recode bills
  hp_data_out <- hp_data_in
  if(recode_bills) hp_data_out <- recode_bill(hp_data_out, n_bill)
  if(recode_income) hp_data_out <- hp_data_out %>% dplyr::mutate(qh=recode_income(qh))
  hp_data_out %>% return()

}


#' transform_to_utils
#'
#' Transforms survey Likert scores for likelihood of pv adoption (1..5) to utilities in range -1,1.
#' The transformation depends on s (utility uncertainty) and epsilon (an initial hypothetical bias estimate).
#' The error in the hypithetical bias estimate is corrected at the micro-calibration stage
#'
#' @param hp_data_in survey data including qsp22_7 (Likert scores for adopting pv)
#' @param s utility uncertainty (default 0.15)
#' @param epsilon degree of hypothetical bias (default 0.7, 1 = no bias). Further hypothetical bias correction is applied at ABM tuning stage.
#'
#' @return modified pv survey dataframe
#' @export
#'
#' @examples
transform_to_utils <-function(hp_data_in,s=0.15,epsilon=0.7){

  #pv_data1 <- pv_data %>% dplyr::select(-ID)
  util_mapping <- map_likertscores_to_utilities(s,epsilon)
  hp_data1 <- hp_data_in %>% dplyr::rowwise() %>% dplyr::mutate(u = util_mapping[[q53_5,"dU"]]) %>% dplyr::select(-q53_5)
  return(hp_data1)
}


#' find_optimum_rounds_from_crossvalidation
#'
#' helper function to find optimum learning complexity for for given learning rate and tree depth
#'
#' @param hp_data_in solar HP survey dataset e.g. hp_survey_oo
#' @param learning_rate eta parameter (default 0.02)
#' @param tree_depth maximum tree depth (default 5)
#' @param k_crossvalidation k-fold cross validation

#'
#' @return n_opt
#' @export
#'
#' @examples
find_optimum_rounds_from_crossvalidation <- function(hp_data_in, learning_rate=0.02, tree_depth=5, k_crossvalidation=5){

  if("ID" %in% names(hp_data_in)) hp_data_in <- hp_data_in %>% dplyr::select(-ID)
  if("serial" %in% names(hp_data_in)) hp_data_in <- hp_data_in %>% dplyr::select(-serial)
  if("HH" %in% names(hp_data_in)) hp_data_in <- hp_data_in %>% dplyr::select(-HH)
  #pv.train <- xgboost::xgb.DMatrix(as.matrix(pv_util[,-dim(pv_util)[2]]),label=as.vector(pv_util$u), missing=NA)
  hp_train <- suppressWarnings(xgboost::xgb.DMatrix(as.matrix(hp_data_in %>% dplyr::select(-u)),label=as.vector(hp_data_in$u), missing=NA))

  #if(!train_on_utilities) #train on Likert scores
  # pv.train <- xgboost::xgb.DMatrix(as.matrix(pv_data1[,-dim(pv_data1)[2]]),label=as.vector(pv_data1$qsp22_7-1), missing=NA)
  #
  paramlist <- list(booster="gbtree",
                    tree_method = "exact",
                    eta=learning_rate,
                    max_depth=tree_depth,
                    gamma=0,
                    subsample=0.9,
                    colsample_bytree = 0.9,
                    objective="reg:squarederror",
                    eval_metric="rmse"
                    #objective="multi:softprob",
                    #eval_metric = "mlogloss"
  )

  bst <- xgboost::xgb.cv(params=paramlist,hp_train,nrounds=500,nfold=k_crossvalidation)

  cv_data <- bst["evaluation_log"] %>% as.data.frame() %>% tibble::as_tibble()
  nopt <- cv_data[,"evaluation_log.test_rmse_mean"][[1]] %>% as.numeric() %>% which.min()
  print(paste("optimal nrounds",nopt))
  return(nopt)

}


#' get_boosted_tree_model
#'
#' creates a cross-validated boosted tree regression model from hp survey data
#'
#' @param hp_data_in input survey data
#' @param learning_rate eta. typical value 0.02
#' @param tree_depth tree depth typical value 5
#' @param k_crossvalidation k-fold cross validation typical value 5
#' @param complexity_factor "over-fitting" enhancement relative to optimal model complexity from cross-validation. Values in range 1-1.5.
#'
#'
#' @return xgboost model
#' @export
#'
#' @examples
#'
get_boosted_tree_model <- function(hp_data_in, learning_rate=0.02, tree_depth=5, k_crossvalidation=5,complexity_factor = 1){

  if("ID" %in% names(hp_data_in)) hp_data_in <- hp_data_in %>% dplyr::select(-ID)
  if("serial" %in% names(hp_data_in)) hp_data_in <- hp_data_in %>% dplyr::select(-serial)
  if("HH" %in% names(hp_data_in)) hp_data_in <- hp_data_in %>% dplyr::select(-HH)
  #pv_util <- transform_to_utils(pv_data_in,s,epsilon)
  hp_train <- suppressWarnings(xgboost::xgb.DMatrix(as.matrix(hp_data_in %>% dplyr::select(-u)),label=as.vector(hp_data_in$u), missing=NA))

  #if(!train_on_utilities) #train on Likert scores
  # pv.train <- xgboost::xgb.DMatrix(as.matrix(pv_data1[,-dim(pv_data1)[2]]),label=as.vector(pv_data1$qsp22_7-1), missing=NA)

  paramlist <- list(booster="gbtree",
                    tree_method = "exact",
                    eta=learning_rate,
                    max_depth=tree_depth,
                    gamma=0,
                    subsample=0.9,
                    colsample_bytree = 0.9,
                    objective="reg:squarederror",
                    eval_metric="rmse"
                    #objective="multi:softprob",
                    #eval_metric = "mlogloss"
  )
  n_opt <- find_optimum_rounds_from_crossvalidation(hp_data_in,learning_rate,tree_depth,k_crossvalidation)
  bst <- suppressWarnings(xgboost::xgboost(data=hp_train,params=paramlist,hp_train,nrounds=complexity_factor*n_opt))
  return(bst)
}


#bst <- get_boosted_tree_model(transform_to_utils(feature_select(hp_survey_oo_calibrate,recode_bills=T,n_bill=5),epsilon=0.7))

#' get_shap_scores
#'
#' @param hp_data_in the pv_survey dataset
#' @param bst xgboost model from get_boosted_tree_model()
#'
#' @returns dataframe long format
#' @export
#'
#' @examples
get_shap_scores <- function(hp_data_in,bst){

  hp_data_long <- hp_data_in
  #hp_data_long$ID <- 1:dim(hp_data_in)[1]
  hp_data_long <- hp_data_long %>% tidyr::pivot_longer(-serial,names_to="question_code",values_to="response_code")
  hp_data_long <- hp_data_long %>% dplyr::left_join(hp_qanda_calibrate,by=c("question_code","response_code"))

  shap_scores <- predict(bst, as.matrix(hp_data_in %>% dplyr::select(-u,-serial)), predcontrib = TRUE, approxcontrib = F) %>% tibble::as_tibble()
  shap_scores$serial <- hp_data_in$serial
  shap_scores_long <- tidyr::pivot_longer(shap_scores,-serial,values_to="shap","names_to"="question_code")
  #add predictions
  preds <- shap_scores_long %>% dplyr::group_by(serial) %>% dplyr::summarise(u_predicted=sum(shap)) #includes BIAS
  #preds$actual <- pv_data$qsp22_7
  shap_scores_long1 <- shap_scores_long  %>% dplyr::inner_join(preds,by="serial")
  shap_scores_long1$u_actual <- sapply(hp_data_in$u, rep, dim(hp_data_in)[2]-1) %>% as.vector()
  #shap_scores_long1$pred <- shap_scores_long1$pred + 1 #+ dplyr::filter(shap_scores,name=="BIAS")$value
  #pv_data1$ID <- 1:dim(pv_data1)[1]
  #shap_scores_long1 <- shap_scores_long1 %>% dplyr::inner_join(pv_data1)
  shap_scores_long1 <-  shap_scores_long1 %>% dplyr::left_join(hp_data_long)
  return(shap_scores_long1)
}

#shap_scores_long <- get_shap_scores(transform_to_utils(feature_select(hp_survey_oo_calibrate,recode_bills=T,n_bill=5),epsilon=0.7),bst)


#' get_abm_calibration
#'
#' returns abm partial utilities for the selected features (q9_1 and qsp21) and barrier (theta) terms in ABM model for each agent. Results are expressed as mean
#' partial utilities corresponding to each survey response and individual weights for each agent. A regularisation parameter can be
#' used to ensure that model weights for financial and social variables are > 1, or some negative weights can be tolerated.
#'
#' @param shap_scores_long individual shap scores by feature (output from get_shap_scores)
#' @param stat statistic - median (default) or mean
#' @param regularisation regularisation 0=none, 1= full, > 1 over, < 1 under
#'
#'
#' @return data frame giving partial utilities for abstracted model features and residual (theta) terms and individual weights
#' @export
#'
#' @examples
get_abm_calibration <- function(shap_scores_long, stat="mean",regularisation=1){
  #
  shap_scores <- shap_scores_long %>% dplyr::select(-question,-response)
  #q52 social
  #q1,q2,q3,q5,q10,q14,q15 financial and roof constraint
  social_code <- "q52"
  #finance_codes <- c("q_ab")
  finance_codes <- "q13"
  #if(energy_burden) finance_codes <- c("q13","burden")
  u_theta <- shap_scores %>% dplyr::filter(!(question_code %in% c(finance_codes,social_code))) %>% dplyr::group_by(serial) %>% dplyr::summarise(shap=sum(shap))
  u_theta$question_code <- "theta"
  u_theta$response_code <- NA

  shap_scores_abm <- shap_scores %>% dplyr::filter(question_code %in% c(finance_codes,social_code)) %>% dplyr::select(-u_predicted,-u_actual)
  #shap_scores_abm <- shap_scores %>% dplyr::filter(question_code %in% c(finance_codes,social_code)) %>% dplyr::select(-u_actual,-shap)

  shap_scores_abm <- shap_scores_abm %>% dplyr::bind_rows(u_theta) #%>% dplyr::arrange(ID)
  shap_scores_abm <- shap_scores_abm %>% dplyr::rename("du"=shap)
  #regularise
  #regularise
  min_shap <- shap_scores_abm %>% dplyr::filter(question_code != "theta") %>% dplyr::group_by(question_code) %>% dplyr::slice_min(du) %>% dplyr::select(question_code,du) %>% dplyr::rename("du_min"=du)
  theta_shift <- min_shap %>% dplyr::pull(du_min) %>% sum()
  min_shap <- min_shap %>% dplyr::bind_rows(tidyr::tibble(question_code="theta",du_min = -theta_shift))

  shap_scores_abm <- shap_scores_abm %>% dplyr::inner_join(min_shap) %>% dplyr::mutate(du=du-regularisation*du_min) %>% dplyr::select(-du_min)

  if(stat=="mean") {shap_scores_mean <- shap_scores_abm %>% dplyr::group_by(question_code,response_code) %>% dplyr::summarise(du_average=mean(du))
  shap_scores_abm <- shap_scores_abm %>% dplyr::inner_join(shap_scores_mean)}
  if(stat=="median") {shap_scores_median <- shap_scores_abm %>% dplyr::group_by(question_code,response_code) %>% dplyr::summarise(du_average=median(du))
  shap_scores_abm <- shap_scores_abm %>% dplyr::inner_join(shap_scores_median)}

  shap_scores_abm <- shap_scores_abm %>% dplyr::mutate(weight=du/du_average)
  return(shap_scores_abm)
}

#get_abm_calibration(shap_scores_long)


#' get_model_weights
#'
#' The agent weights for financial, social and barrier terms
#'
#' @param shap_scores_long shaps scores (partial utilities)
#' @param stat median (default) or mean
#' @param regularisation 0 none, 1 full
#'
#' @return a dataframe with colums ID w_q9_1  w_qsp21 W_theta
#' @export
#'
#' @examples
get_model_weights <- function(shap_scores_long, stat="mean",regularisation = 1){

  shap_scores_abm <- get_abm_calibration(shap_scores_long,stat, regularisation)

  weights_abm <- shap_scores_abm %>% tidyr::pivot_wider(id_cols=c(-du,-response_code,-du_average),values_from=weight,names_from=question_code)
  names(weights_abm)[2:ncol(weights_abm)] <- paste("w_",names(weights_abm)[2:ncol(weights_abm)],sep="")
  return(weights_abm)
}

#get_model_weights(shap_scores_long,regularisation=1)

#' get_empirical_partial_utilities
#'
#' partial (dis) utilities for pv adoption derived from survey
#'
#'
#' @param shap_scores_long shap scores (partial utilities)
#' @param stat median (default) or mean
#' @param regularisation none 0, full 1, over > 1
#'
#' @return dataframe
#' @export
#'
#' @examples
get_empirical_partial_utilities <- function(shap_scores_long,stat="median", regularisation=1){

  shap_scores_abm <- get_abm_calibration(shap_scores_long,stat,regularisation=1)
  if(stat=="mean") partial_utils <- shap_scores_abm %>% dplyr::group_by(question_code,response_code) %>% dplyr::summarise(du_average=mean(du))
  if(stat=="median") partial_utils <- shap_scores_abm %>% dplyr::group_by(question_code,response_code) %>% dplyr::summarise(du_average=median(du))
  return(partial_utils)
}

#get_empirical_partial_utilities(shap_scores_long)

#' pbeta_util
#'
#' Beta function probability generalised to range -1,1
#'
#' @param x real in range -1 to 1
#' @param shape1 "a" shape parameter
#' @param shape2 "b" shape parameter
#'
#' @return generalised beta function value
#' @export
#'
#' @examples
pbeta_util <- function(x,shape1,shape2){
  #beta function generalised to -2,1
  return(pbeta((x+1)/2,shape1,shape2))
}

#' dbeta_util
#'
#' Beta function distribution generalised to interval -1,1
#'
#' @param x in -1,1
#' @param shape1 "a" shape parameter
#' @param shape2 "b" shape parameter
#'
#' @return function value
#' @export
#'
#' @examples
dbeta_util <- function(x,shape1,shape2){
  #beta function generalised to -2,1
  return(stats::dbeta((x+1)/2,shape1,shape2))
}

#' probs_from_shape_params
#'
#' mapping between shape parameters of generalised Beta function and total probability that value > 0
#'
#' @param s standard deviation of Beta distribution
#'
#' @return dataframe
#' @export
#'
#' @examples
probs_from_shape_params <- function(s){

  df <- tidyr::tibble()
  for( a in seq(0.15,300, by=0.1)){
    f <- function(b)  {4*a*b-((a+b+1)*(a+b)^2)*s^2} #its a polynomial
    f1 <- function(b) {4*a*b-b^3*s^2-3*a*b^2*s^2-b^2*s^2-3*a^2*b*s^2-2*a*b*s^2-a^3*s^2-a^2*s^2}
    #  #find roots of cubic polynomial in b given s (sd) and a
    f.roots <- polyroot(c(-a^3*s^2-a^2*s^2,-3*a^2*s^2-2*a*s^2+4*a,-3*a*s^2-s^2,-s^2)) %>% Re()
    #  #f.roots
    i.roots <- polyroot(c(-a^3*s^2-a^2*s^2,-3*a^2*s^2-2*a*s^2+4*a,-3*a*s^2-s^2,-s^2)) %>% Im() %>% round(5)
    #
    #  #real roots only
    b <- f.roots[which(i.roots==0)]
    #positive real roots only
    b <- b[b>0]
    for(b1 in b)
      #  #print(paste("b=",b1,"mean=", 2*a/(a+b1)-1, "  sd=",2*sqrt(a*b1/((a+b1+1)*(a+b1)^2)),"prob=",round(1-pbeta_util(0,a,b1),2) ))
      df <- dplyr::bind_rows(df,tidyr::tibble(s=s,a=a,b=b1,mean= 2*a/(a+b1)-1,prob=round(1-pbeta_util(0,a,b1),3) ))
  }
  return(df)
}


#' shape_params_from_prob
#'
#' returns shape parameters corresponding to an adoption probability (i.e. area of generalised beta distribution > 0)
#'
#' @param df.in dataframe produced by probs_from_shape_params()
#' @param prob value in range 0,1
#'
#' @return shape paramaters (a and b)
#' @export
#'
#' @examples
shape_params_from_prob <- function(df.in,prob){
  #
  return(c(approx(df.in$prob,df.in$a,prob,ties="mean")$y,approx(df.in$prob,df.in$b,prob,ties="mean")$y))
}

#' map_likertscores_to_utilities
#'
#' maps likert scores 1..5 to adoption probabilities and then to expected utility.
#' Epsilon controls the degree and sign of the hypothetical bias correction needed when tuning the ABM
#'
#' @param s agent utility uncertainty (standard deviation of utility at time of survey)
#' @param epsilon probability scale factor (to allow for hypothetical bias) 1= no hypothetical bias. default 0.75.
#'
#' @return a dataframe of shape parameters and expected utility values corresponging to likert probabilities
#' @export
#'
#' @examples
map_likertscores_to_utilities <- function(s=0.15,epsilon=0.75){

  probs <- epsilon*c(0.1,0.3,0.5,0.7,0.9) #hard-wired
  df <- probs_from_shape_params(s)
  distrib_params <- tidyr::tibble()
  for(prob in probs)
    distrib_params <- distrib_params %>% dplyr::bind_rows(tidyr::tibble(s=s,epsilon=epsilon,prob=prob,a=shape_params_from_prob(df,prob)[1],b=shape_params_from_prob(df,prob)[2]))
  distrib_params <- distrib_params %>% dplyr::mutate(dU = 2*a/(a+b)-1)
  distrib_params$likert <- 1:5
  return(distrib_params)
}


