README – Code Documentation for Senior Thesis Project
-----------------------------------------------------

Project Title:
Predicting Poor Mental Health Days Using Behavioral and Demographic Data from BRFSS (2022–2023)

Author:
Abdullah Siddiqui
Advisor: Dr. Sridhar Ramachandran
Course: INFO-I 492 Senior Thesis
Date: October 2025

-----------------------------------------------------
Overview:
This folder contains all R scripts used for data cleaning, exploration, regression modeling, and visualization 
for the Senior Thesis project. The analysis uses the Behavioral Risk Factor Surveillance System (BRFSS) 2022–2023 dataset 
to predict self-reported poor mental health days from behavioral and socioeconomic variables.

-----------------------------------------------------
How to Run the Code:

1. **Requirements**
   - R version 4.3 or later
   - RStudio (recommended)
   - Required R packages:
       tidyverse
       ggplot2
       dplyr
       readr
       car
       caret
       pROC
       reshape2

   Install missing packages using:
   install.packages(c("tidyverse", "ggplot2", "dplyr", "readr", "car", "caret", "pROC", "reshape2"))

2. **Dataset**
   - The project uses `BRFSS2023_subset_clean.csv` located in the root directory.
   - Ensure the dataset is in your R working directory before running the scripts.

3. **Script Execution Order**
   - Step 1: `BRFSS2023_ANALYSIS.R`
       Cleans and preprocesses the dataset, removing missing values and recoding responses.
   - Step 2: `BRFSS2023_correlation.R`
       Performs correlation analysis, generates heatmaps, scatterplots, and crosstabs.
   - Step 3: `BRFSS2023_regression.R`
       Runs baseline linear and logistic regression models predicting poor mental health days.
   - Step 4: `BRFSS2023_regression_week5.R`
       Refines regression models, calculates odds ratios, confidence intervals, and diagnostic plots.
   - Step 5: `BRFSS2023_regression_weeks6.7.R`
       Incorporates interaction effects (education × income), stratified analyses (by sex and age),
       and computes ROC/AUC metrics with confusion matrices.

4. **Outputs**
   - Model summaries and tables are saved in the `/tables` folder.
   - Plots and figures are saved in the `/plots` folder.
   - Text outputs and logs are in the `/outputs` folder.

5. **Results Summary**
   - Logistic regression model achieved an AUC = 0.731.
   - Key predictors of poor mental health days include low income, low education, smoking, and lack of exercise.
   - Education × income interaction: higher education mitigates the negative effects of low income on mental health.

-----------------------------------------------------
Contact:
For any questions or replication requests, please contact:
Abdullah Siddiqui  
Email: absidd@iu.edu 
GitHub: https://github.com/abdullahs1357/SeniorThesis

-----------------------------------------------------
Last Updated: October 2025

---

## 📂 Repository Structure
Draft_Thesis_Submission_AbdullahSiddiqui/
│
├── Code/
│ ├── BRFSS2023_ANALYSIS.R
│ ├── BRFSS2023_correlation.R
│ ├── BRFSS2023_regression.R
│ ├── BRFSS2023_regression_week5.R
│ ├── BRFSS2023_regression_weeks6.7.R
│ └── README.txt
│
├── Graphs/
│ ├── figure1_correlation_heatmap.png
│ ├── figure2_coefficient_plot.png
│ ├── figure3_roc_curve.png
│ └── (other visualizations)
│
├── Tables/
│ ├── logit_interaction_coeffs.csv
│ ├── lm_interaction_coeffs.csv
│ └── stratified_by_age_logit_coeffs.csv
│
├── Documentation/
│ ├── Abdullah_Siddiqui_Thesis_First_Draft.docx
│ └── FutureDirectionsNotes.txt
│
└── Graphics/
