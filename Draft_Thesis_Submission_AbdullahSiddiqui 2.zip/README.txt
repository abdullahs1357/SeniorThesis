{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 Project Title: Predicting Poor Mental Health Days Using Behavioral and Demographic Data from BRFSS (2022\'962023)\
Author: Abdullah Siddiqui\
Advisor: Dr. Sridhar Ramachandran\
Course: INFO-I 492 Senior Thesis\
\
Overview:\
This project investigates how behavioral and demographic variables (e.g., exercise, education, income, smoking, alcohol use) predict poor mental health days using BRFSS 2022\'962023 data. Analyses were conducted in R using regression and interpretability techniques.\
\
Code Files:\
1. BRFSS2023_ANALYSIS.R \'97 initial exploration and cleaning.\
2. BRFSS2023_correlation.R \'97 correlation and visualization of predictors.\
3. BRFSS2023_regression.R \'97 baseline regression models.\
4. BRFSS2023_regression_week5.R \'97 logistic and linear regression updates.\
5. BRFSS2023_regression_weeks6.7.R \'97 interaction and stratified analyses.\
\
How to Run:\
1. Open RStudio.\
2. Load the dataset \'93BRFSS2023_subset_clean.csv\'94.\
3. Run the scripts in order listed above.\
4. Outputs (plots, summaries, tables) are saved automatically in /Graphs, /Tables, and /Outputs.\
\
Key Results:\
- Logistic regression AUC = 0.731.\
- Predictors: exercise (protective), low income (risk), low education (risk).\
- Interaction (education \'d7 income) significant.\
- Visual outputs: correlation heatmap, ROC curve, coefficient plots.\
\
Repository:\
https://github.com/abdullahs1357/SeniorThesis\
\
Contact:\
abdullahs1357@iu.edu\
}