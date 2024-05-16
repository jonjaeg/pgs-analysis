library(ggplot2)
library(DT)
library(dplyr)
library(kableExtra)
library(gridExtra)

calc_percentile <- function(score, phenotype, quantile = 0.01) {
  result <-  data.frame(score, phenotype) %>% na.omit()
  quantiles = quantile(result$score, seq(0,1, by = quantile))
  max_labels = 1 / quantile
  quantiles_labels = 1:max_labels
  result$percentile <- cut(result$score , breaks = quantiles, labels=quantiles_labels, include.lowest=TRUE)
  result$percentile <- as.numeric(result$percentile)
  return(result)
}

group_by_percentile_median <- function(score, phenotype, quantile = 0.01) {
  percentiles <- calc_percentile(score, phenotype, quantile = quantile)
  result <- percentiles %>%
    group_by(percentile) %>%
    summarize(
      median = median(phenotype),
      quant25 = quantile(phenotype, probs = 0.25),
      quant75 = quantile(phenotype, probs = 0.75)
    )
  return(result)
}

group_by_percentile_cases <- function(score, phenotype, quantile = 0.01) {
  percentiles <- calc_percentile(score, phenotype, quantile = quantile)
  result <- percentiles %>%
    group_by(percentile) %>%
    summarize(
      count = sum(phenotype) / n()
    )
  return(result)
}

group_by_age_cases <- function(score, phenotype, age, quantile = 0.01) {
  result <-  data.frame(score, phenotype, age) %>%
    na.omit() %>%
    group_by(age) %>%
    summarize(
      count = sum(phenotype) / n()
    )
  return(result)
}

group_scores_by_percentile <- function(data, scores, phenotype, quantile = 0.01) {
  phenotype_values <- data[[phenotype]]
  n = length(scores)
  result <- NULL
  for(i in 1:n) {
    score <- scores[i]
    score_values <- data[[score]]
    grouped_by_percentile <- group_by_percentile_median(score_values, phenotype_values, quantile = quantile)
    grouped_by_percentile$score <- score
    result <- rbind(result, grouped_by_percentile)
  }
  return(result)
}

group_scores_by_percentile_cases <- function(data, scores, phenotype, quantile = 0.01) {
  phenotype_values <- data %>% select(all_of(phenotype))
  n = length(scores)
  result <- NULL
  for(i in 1:n) {
    score <- scores[i]
    score_values <- data[[score]]
    grouped_by_percentile <- group_by_percentile_cases(score_values, phenotype_values, quantile = quantile)
    grouped_by_percentile$score <- score
    result <- rbind(result, grouped_by_percentile)
  }
  return(result)
}











#### ab hier Plots


plot_pgs_by_percentile <- function(data, scores, phenotype, quantile = 0.01) {
  
  grouped_scores_by_percentile = group_scores_by_percentile(data, scores, phenotype, quantile = quantile)
  
  phenotype_values <- data[[phenotype]]
  median_value <- median(phenotype_values, na.rm = TRUE)
  
  plot <- ggplot(grouped_scores_by_percentile) + 
    geom_hline(yintercept=median_value, linetype="dashed") +
    geom_segment(aes(x = percentile, y = quant25, xend  =percentile, yend=quant75), color="lightblue") + 
    geom_point(aes(x = percentile, y = median), color='blue', size = 1) +
    ylab(phenotype) +
    xlab("Polygenic Score percentile") +
    theme_bw()
  
  return(plot)
  
}

plot_pgs_by_percentile_cases <- function(data, scores, phenotype, quantile = 0.01) {
  
  grouped_scores_by_percentile = group_scores_by_percentile_cases(data, scores, phenotype, quantile = quantile)
  
  phenotype_values <- data[[phenotype]] %>% na.omit()
  percent_value <- sum(phenotype_values) / length(phenotype_values)
  
  plot <- ggplot(grouped_scores_by_percentile) + 
    geom_hline(yintercept=percent_value, linetype="dashed") +
    geom_point(aes(x = percentile, y = count), color='blue', size = 1) +
    scale_y_continuous(labels = scales::percent, lim = c(0,1)) +
    facet_wrap(~ score ) +
    xlab("Polygenic Score percentile") +
    theme_bw()
  
  return(plot)
  
}
# simply change "quantile" to 0.1! so percentile becomes decile 
plot_pgs_by_decile <- function(data, scores, phenotype, quantile = 0.1) {
  plot <- plot_pgs_by_percentile(data, scores, phenotype, quantile = quantile) +
    xlab("Polygenic Score decile") +
    scale_x_continuous(breaks = seq(1:10))
  return(plot)
}

plot_pgs_by_decile_cases <- function(data, scores, phenotype, quantile = 0.1) {
  plot <- plot_pgs_by_percentile_cases(data, scores, phenotype, quantile = quantile) +
    xlab("Polygenic Score decile") +
    scale_x_continuous(breaks = seq(1:10))
  return(plot)
}

plot_pgs_by_decile_boxplot <- function(data, scores, phenotype, quantile = 0.1) {
  
  phenotype_values <- data[[phenotype]]
  n = length(scores)
  result <- NULL
  for(i in 1:n) {
    score <- scores[i]
    score_values <- data[[score]]
    deciles <- calc_percentile(score_values, phenotype_values, quantile = quantile)
    deciles$score <- score
    result <- rbind(result, deciles)
  }
  
  phenotype_values <- data[[phenotype]]
  median_value <- median(phenotype_values, na.rm = TRUE)
  
  plot <- ggplot(result) +
    geom_hline(yintercept = median_value, linetype = "dashed") +
    geom_boxplot(aes(group = percentile, y = phenotype, x = percentile)) +
    facet_wrap(~ score ) +
    xlab("Polygenic Score decile") +
    scale_x_continuous(breaks = seq(1:10)) +
    theme_bw()
  
  return(plot)
  
}

plot_pgs_densities <-function(data, scores, phenotype = NULL){
  
  n = length(scores)
  result <- NULL
  for(i in 1:n) {
    score <- scores[i]
    score_data <-  data %>% select(all_of(score), all_of(phenotype)) %>% na.omit()  %>% rename(value = all_of(score))
    score_data$score = score
    result <- rbind(result, score_data)
  }
  
  plot <- ggplot(result) + 
    geom_density(aes_string(x="value", color = phenotype)) + 
    facet_wrap(~ score, scales = "free" ) +
    theme_bw()
  
  return(plot)
}


eval_pgs <- function (data, scores, phenotype, covariates = c("")) {
  
  result <- NULL
  n = length(scores)
  for(i in 1:n) {
    score <- scores[i]
    score_data <-  data %>% select(all_of(score), all_of(phenotype), any_of(covariates)) %>% na.omit()  
    formula_null = as.formula(paste0(phenotype, "~ ", score))
    model_null <- summary(lm(formula=formula_null, score_data))
    formula_cov = as.formula(paste0(phenotype, "~ ."))
    model_cov <- summary(lm(formula=formula_cov, score_data))
    result <- rbind(result, 
                    data.frame(score=score,
                               r2 = model_null$r.squared, 
                               r2_cov = model_cov$r.squared,
                               covariates = toString(covariates),
                               samples = dim(score_data)[1]))
  }
  
  return(result %>% arrange(desc(r2)))
  
}


load_pgs <- function (filename, postfix = NULL) {
  result <- read.csv(filename, sep = ',')
  if (!is.null(postfix)){
    result <- result %>% rename_with(.fn = ~paste0(., postfix))
  }
  return(result)
}

load_pgs_test <- function(){
  
}

load_coverage <- function (filename) {
  result <- read.csv(filename, sep = ',')
  return(result)
}

# Experimental!

plot_pgs_by_variable <-function(data, scores, phenotype, variable, quantile = 0.1){
  
  n = length(scores)
  result <- NULL
  for(i in 1:n) {
    score <- scores[i]
    score_data <-  data %>% select(all_of(score), all_of(phenotype), all_of(variable)) %>% na.omit()  %>% rename(value = all_of(score), var = all_of(variable), phenotype = all_of(phenotype))
    quantiles = quantile(score_data$value, c(0,0.1,0.4,0.6,0.9,1))
    quantiles_labels = c("low", "medium_low","median","medium_high","high")
    score_data$group <- cut(score_data$value , breaks = quantiles, labels=quantiles_labels, include.lowest=TRUE)
    score_data$score = score
    result <- rbind(result, score_data)
  }
  
  result <- result %>% group_by(score, group, var) %>%
    summarize(
      percentage = sum(phenotype) / n()
    )
  
  plot <- ggplot(result) + 
    geom_point(aes_string(x="var", color = "group", y="percentage")) +
    scale_y_continuous(labels = scales::percent, lim = c(0,1)) +
    facet_wrap(~ score) +
    theme_bw()
  
  return(plot)
}