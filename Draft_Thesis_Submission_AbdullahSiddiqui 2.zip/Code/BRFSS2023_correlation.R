#############################################################
# BRFSS2023_correlation.R
# Week 4: Correlation analysis, scatterplots, cross-tabs
# Author: Abdullah Siddiqui
# Date: Oct 2, 2025
#############################################################

# ---- Load Libraries ----
library(ggplot2)
library(reshape2)
library(dplyr)
library(readr)

# ---- Load Dataset ----
library(readr)
df <- read_csv("~/Downloads/BRFSS2023_subset_clean.csv")

# Inspect dataset structure
str(df)

# ---- Create Output Folders ----
if (!dir.exists("plots")) dir.create("plots")
if (!dir.exists("tables")) dir.create("tables")

# ---- Correlation Matrix ----
# Select only numeric variables
num_vars <- df %>% select_if(is.numeric)

# Compute correlation matrix
cor_matrix <- cor(num_vars, use = "complete.obs")

# Save correlation heatmap
heatmap_data <- melt(cor_matrix)
p1 <- ggplot(heatmap_data, aes(Var1, Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
  theme_minimal() +
  labs(title = "Correlation Heatmap") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave("plots/correlation_heatmap.png", plot = p1, width = 7, height = 6)

# ---- Scatterplots ----
# Income vs. Poor Mental Health Days
p2 <- ggplot(df, aes(x = INCOME3, y = MENTHLTH)) +
  geom_point(alpha = 0.2) +
  geom_smooth(method = "lm", se = FALSE, color = "blue") +
  labs(title = "Income vs. Poor Mental Health Days",
       x = "Income Category", y = "Poor Mental Health Days") +
  theme_minimal()
ggsave("plots/scatter_income_mentalhealth.png", plot = p2, width = 7, height = 5)

# Exercise vs. Poor Mental Health Days
p3 <- ggplot(df, aes(x = factor(EXERANY2), y = MENTHLTH)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Exercise vs. Poor Mental Health Days",
       x = "Exercise (1=Yes, 2=No)", y = "Poor Mental Health Days") +
  theme_minimal()
ggsave("plots/scatter_exercise_mentalhealth.png", plot = p3, width = 7, height = 5)

# ---- Cross-tabulations ----
# Smoking × Exercise
table_smoke_exercise <- table(df$SMOKDAY2, df$EXERANY2)
write.csv(table_smoke_exercise, "tables/crosstab_smoking_exercise.csv")

# Alcohol × Frequent Distress (binary >14 days poor MH)
df$frequent_distress <- ifelse(df$MENTHLTH > 14, 1, 0)
table_alcohol_distress <- table(df$ALCDAY4, df$frequent_distress)
write.csv(table_alcohol_distress, "tables/crosstab_alcohol_distress.csv")

#############################################################
# End of Script
#############################################################

file.show("plots/correlation_heatmap.png")     # opens the image in a viewer
file.show("tables/crosstab_smoking_exercise.csv")  # opens CSV as text

  
