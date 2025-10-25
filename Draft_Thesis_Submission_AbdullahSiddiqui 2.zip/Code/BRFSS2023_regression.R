#############################################################
# BRFSS2023_regression.R
# Week 4: Linear & Logistic regression + diagnostics
# Author: Abdullah Siddiqui
# Date: Oct 2, 2025
#############################################################

# ---- Load Libraries ----
library(ggplot2)
library(dplyr)
library(readr)
library(car)       # for VIF
library(broom)     # for tidy regression output

# ---- Load Dataset ----
df <- read_csv("~/Downloads/BRFSS2023_subset_clean.csv")

# ---- Create Output Folders ----
if (!dir.exists("plots")) dir.create("plots")
if (!dir.exists("tables")) dir.create("tables")
if (!dir.exists("outputs")) dir.create("outputs")

# ---- Linear Regression ----
lm_model <- lm(MENTHLTH ~ INCOME3 + EDUCA + EXERANY2 + SMOKDAY2 + ALCDAY4 + `_AGEG5YR`,
               data = df)

# Save summary as text
sink("outputs/linear_regression_summary.txt")
print(summary(lm_model))
sink()

# Save coefficients table as CSV
lm_tidy <- broom::tidy(lm_model)
write.csv(lm_tidy, "tables/linear_regression_coeffs.csv", row.names = FALSE)

# Check multicollinearity (VIF)
vif_values <- vif(lm_model)
write.csv(vif_values, "tables/vif_linear.csv")

# Diagnostic plots
png("plots/residuals_vs_fitted.png", width = 800, height = 600)
plot(lm_model, which = 1)   # residuals vs fitted
dev.off()

png("plots/qq_plot.png", width = 800, height = 600)
plot(lm_model, which = 2)   # Q-Q plot
dev.off()

# ---- Logistic Regression ----
# Create binary outcome: frequent distress (>14 days poor mental health)
df$frequent_distress <- ifelse(df$MENTHLTH > 14, 1, 0)

# Logistic regression with backticks around _AGEG5YR
log_model <- glm(frequent_distress ~ INCOME3 + EDUCA + EXERANY2 + SMOKDAY2 + ALCDAY4 + `_AGEG5YR`,
                 data = df, family = binomial)

summary(log_model)


# Save logistic regression summary
sink("outputs/logistic_regression_summary.txt")
print(summary(log_model))
sink()

# Save coefficients table
log_tidy <- broom::tidy(log_model)
write.csv(log_tidy, "tables/logistic_regression_coeffs.csv", row.names = FALSE)

# Odds ratios + CI
odds_ratios <- exp(cbind(OR = coef(log_model), confint(log_model)))
write.csv(odds_ratios, "tables/logistic_odds_ratios.csv")

# ROC-like diagnostic: predicted probabilities
logit_pred <- predict(log_model, type = "response")  # vector of predictions
length(logit_pred)  # should be ~127,865

# Make a new dataframe just for diagnostics
pred_df <- data.frame(predicted_prob = logit_pred)

# Save histogram plot
p1 <- ggplot(pred_df, aes(x = predicted_prob)) +
  geom_histogram(binwidth = 0.05, fill = "steelblue", color = "white") +
  labs(title = "Predicted Probability Distribution (Logistic Regression)",
       x = "Predicted probability of frequent distress", y = "Count") +
  theme_minimal()
ggsave("plots/logistic_predicted_probabilities.png", plot = p1, width = 7, height = 5)


#############################################################
# End of Script
#############################################################
