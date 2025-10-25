##############################################################################
# BRFSS2023_interaction_week6_7.R
# Purpose: Interaction effects, stratified analyses, coeff plots, model eval
# Assumes: BRFSS2023_subset_clean.csv exists in working directory
# Author: Abdullah Siddiqui
##############################################################################

# 0. Setup -------------------------------------------------------------------
library(tidyverse)   # includes dplyr, ggplot2, readr, tidyr
library(broom)       # tidy model outputs
library(pROC)        # ROC / AUC
library(caret)       # confusionMatrix
library(janitor)     # clean names for tables
library(modelr)      # add predictions helpers
# If you do not have a package installed, run install.packages("pkgname")

set.seed(123)

# create folders for outputs if not exist
if (!dir.exists("plots")) dir.create("plots")
if (!dir.exists("outputs")) dir.create("outputs")
if (!dir.exists("tables")) dir.create("tables")

# 1. Load cleaned data ------------------------------------------------------
df <- read_csv("Downloads/BRFSS2023_subset_clean.csv", show_col_types = FALSE)

# Quick check
glimpse(df)

# 2. Prepare variables ------------------------------------------------------
# Ensure categorical variables are factors and create derived vars
df <- df %>%
  mutate(
    # Age group is a label-like variable, convert to factor
    AGEG5YR = as.factor(`_AGEG5YR`),
    SEX = factor(SEXVAR, labels = c("Male","Female")[1:2]), # check labels if needed
    EDUCA_f = factor(EDUCA,
                     levels = c(1,2,3,4,5,6),
                     labels = c("Never","1-8","9-11","HS_grad","Some_college","College_grad")),
    INCOME_f = factor(INCOME3,
                      levels = sort(unique(INCOME3)),
                      labels = paste0("Bin", sort(unique(INCOME3)))),
    EXER = factor(EXERANY2, labels = c("Yes","No")[1:2]),
    SMOKE = case_when(
      SMOKDAY2 == 1 ~ "Every_day",
      SMOKDAY2 == 2 ~ "Some_days",
      SMOKDAY2 == 3 ~ "Not_at_all",
      TRUE ~ NA_character_
    ) %>% factor(levels = c("Every_day","Some_days","Not_at_all")),
    # Binary outcome for logistic regression: frequent distress > 14 days (common threshold)
    frequent_distress = case_when(
      !is.na(MENTHLTH) & MENTHLTH > 14 ~ 1L,
      !is.na(MENTHLTH) & MENTHLTH <= 14 ~ 0L,
      TRUE ~ NA_integer_
    )
  )

# Remove rows with NA in a small set of modeling vars (for ease). You can handle with imputation if needed.
model_df <- df %>%
  select(MENTHLTH, frequent_distress, EDUCA_f, INCOME_f, EXER, SMOKE, SEX, AGEG5YR, ALCDAY4) %>%
  filter(!is.na(frequent_distress), !is.na(EDUCA_f), !is.na(INCOME_f), !is.na(EXER))

# 3. Interaction Models -----------------------------------------------------

# 3.1 Logistic regression with interaction EDUCA * INCOME
logit_inter <- glm(frequent_distress ~ EDUCA_f * INCOME_f + EXER + SMOKE + AGEG5YR + SEX,
                   data = model_df,
                   family = binomial(link = "logit"))

# Save logistic summary
sink("outputs/logit_interaction_summary.txt")
print(summary(logit_inter))
sink()

# Tidy coefficients (exponentiate for odds ratios)
logit_tidy <- broom::tidy(logit_inter, conf.int = TRUE) %>%
  mutate(odds_ratio = exp(estimate),
         OR_low = exp(conf.low),
         OR_high = exp(conf.high))

write_csv(logit_tidy, "tables/logit_interaction_coeffs.csv")

# 3.2 Linear regression for MENTHLTH with same interaction
lm_inter <- lm(MENTHLTH ~ EDUCA_f * INCOME_f + EXER + SMOKE + AGEG5YR + SEX,
               data = model_df)

sink("outputs/lm_interaction_summary.txt")
print(summary(lm_inter))
sink()

lm_tidy <- broom::tidy(lm_inter, conf.int = TRUE)
write_csv(lm_tidy, "tables/lm_interaction_coeffs.csv")

# 4. Coefficient plots ------------------------------------------------------

# Logistic: plot log-odds coefficients (or odds ratios)
logit_plot_df <- logit_tidy %>%
  filter(term != "(Intercept)") %>%
  mutate(term = fct_reorder(term, estimate))

p_logit_coeff <- ggplot(logit_plot_df, aes(x = estimate, y = term)) +
  geom_point() +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
  labs(title = "Logistic Model Coefficients (log-odds)",
       x = "Estimate (log-odds)", y = "") +
  theme_minimal()

ggsave("plots/logit_coefficients.png", p_logit_coeff, width = 9, height = 8)

# Linear: coefficient plot
lm_plot_df <- lm_tidy %>% filter(term != "(Intercept)") %>% mutate(term = fct_reorder(term, estimate))
p_lm_coeff <- ggplot(lm_plot_df, aes(x = estimate, y = term)) +
  geom_point() +
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
  labs(title = "Linear Model Coefficients",
       x = "Estimate (days)", y = "") +
  theme_minimal()

ggsave("plots/lm_coefficients.png", p_lm_coeff, width = 9, height = 8)

# 5. Stratified analyses ----------------------------------------------------

# 5.1 Stratify by sex: run logistic for males and females separately
strat_sex_models <- model_df %>%
  group_by(SEX) %>%
  group_map(~ {
    df_sub <- .x
    mod <- glm(frequent_distress ~ EDUCA_f * INCOME_f + EXER + SMOKE + AGEG5YR,
               data = df_sub, family = binomial)
    broom::tidy(mod, conf.int = TRUE) %>% mutate(SEX = unique(df_sub$SEX))
  }) %>% bind_rows()

write_csv(strat_sex_models, "tables/stratified_by_sex_logit_coeffs.csv")

# 5.2 Stratify by age group: run simple summaries and a few models for major age bins
age_summary <- model_df %>% tabyl(AGEG5YR, frequent_distress) %>% adorn_pct_formatting()
write_csv(model_df %>% group_by(AGEG5YR) %>% summarise(n = n(), mean_mental = mean(MENTHLTH, na.rm=TRUE)), "tables/agegroup_summary.csv")

# run a model for each age group (for a select subset of groups to limit runtime)
age_groups_to_run <- unique(model_df$AGEG5YR)[1:6] # change selection as desired
strat_age_models <- map_dfr(age_groups_to_run, function(ag) {
  df_sub <- filter(model_df, AGEG5YR == ag)
  if (nrow(df_sub) < 100) return(tibble()) # skip tiny groups
  mod <- glm(frequent_distress ~ EDUCA_f * INCOME_f + EXER + SMOKE + SEX, data = df_sub, family = binomial)
  tidy(mod, conf.int = TRUE) %>% mutate(AGEG5YR = ag)
})
write_csv(strat_age_models, "tables/stratified_by_age_logit_coeffs.csv")

# 6. Grouped bar plots and other visuals ------------------------------------

# 6.1 Grouped bar: exercise by education and sex (percent)
plot_df <- model_df %>%
  group_by(EDUCA_f, SEX) %>%
  summarise(n = n(), exercise_yes = sum(EXER == "Yes", na.rm = TRUE)) %>%
  mutate(pct_exercise = exercise_yes / n * 100)

p_grouped_exercise <- ggplot(plot_df, aes(x = EDUCA_f, y = pct_exercise, fill = SEX)) +
  geom_col(position = position_dodge()) +
  labs(title = "Percent Exercising in Past 30 Days by Education and Sex",
       x = "Education", y = "Percent Exercising") +
  theme(axis.text.x = element_text(angle = 25, hjust = 1))

ggsave("plots/grouped_exercise_education_sex.png", p_grouped_exercise, width = 10, height = 6)

# 6.2 Mental health mean by education x income heatmap (for quick visualization)
mh_heat <- model_df %>%
  group_by(EDUCA_f, INCOME_f) %>%
  summarise(mean_MENTHLTH = mean(MENTHLTH, na.rm = TRUE), n = n()) %>%
  filter(!is.na(mean_MENTHLTH), n >= 50)

p_heat <- ggplot(mh_heat, aes(x = INCOME_f, y = EDUCA_f, fill = mean_MENTHLTH)) +
  geom_tile() +
  scale_fill_viridis_c(option = "magma") +
  labs(title = "Mean Poor Mental Health Days by Education × Income",
       x = "Income bin", y = "Education") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

ggsave("plots/mh_edu_income_heatmap.png", p_heat, width = 10, height = 6)

# 7. Model Performance: ROC/AUC & Confusion Matrix ---------------------------

# Predict only on complete cases used in the model
model_df$pred_prob <- predict(logit_inter, newdata = model_df, type = "response")

roc_obj <- pROC::roc(model_df$frequent_distress, model_df$pred_prob, quiet = TRUE)
auc_val <- pROC::auc(roc_obj)

# Save ROC plot
png("plots/logit_interaction_ROC.png", width = 800, height = 600)
plot.roc(roc_obj, main = paste0("ROC Curve (AUC = ", round(auc_val, 3), ")"))
dev.off()

# Confusion matrix at 0.5 cutoff (adjust threshold as needed)
pred_class <- factor(ifelse(model_df$pred_prob >= 0.5, "pos", "neg"), levels = c("pos","neg"))
true_class <- factor(ifelse(model_df$frequent_distress == 1, "pos", "neg"), levels = c("pos","neg"))

conf_mat <- confusionMatrix(pred_class, true_class, positive = "pos")
capture.output(conf_mat, file = "outputs/confusion_matrix_logit.txt")

# 8. Save key outputs and a short summary -----------------------------------

summary_text <- glue::glue(
  "Logistic interaction model AUC = {round(auc_val,3)}\n",
  "Number observations used = {nrow(model_df)}\n",
  "Confusion matrix saved to outputs/confusion_matrix_logit.txt\n",
  "Coefficients saved to tables/logit_interaction_coeffs.csv and tables/lm_interaction_coeffs.csv\n"
)

write_lines(summary_text, "outputs/summary_run_week6_7.txt")

# 9. Quick prints for the console (so you can copy/paste into report) ----------
cat("\n--- Quick Summary ---\n")
cat("Observations used:", nrow(model_df), "\n")
cat("Logit AUC:", round(auc_val,3), "\n")
cat("Logit top-level summary saved to outputs/logit_interaction_summary.txt\n")
cat("LM top-level summary saved to outputs/lm_interaction_summary.txt\n")
cat("Coefficient tables saved to tables/*.csv\n")
cat("Plots saved to plots/*.png\n")

##############################################################################
# End of script
##############################################################################
