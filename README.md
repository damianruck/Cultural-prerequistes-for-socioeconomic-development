# The cultural prerequistes for WEIRD societies
Data and code for the paper "The cultural prerequistes for WEIRD societies"

## directories
data
R
python

## Get raw data
European Values Survey https://www.gesis.org/en/services/data-analysis/international-survey-programs/european-values-study/

World Values Survey http://www.worldvaluessurvey.org/WVSContents.jsp

Louis Putterman ancestry data - https://www.brown.edu/Departments/Economics/Faculty/Louis_Putterman/world%20migration%20matrix.htm

## Derive Secular-Rationality and Cosmopolitanism from raw WEVS data 

We provide file containing the combined World and European Values Survey data called "WEVS"; it contains the 64 common 
cultural value questions, demogrophic infomrmation, the variables are standarized with missing values mean imputed.  Run 
"ExtractRandC.R" to use weighted principal component analysis to extract Secular-Rationality (R) and Cosmopolitanism (C) 
from WEVS data.    

## Show that birth decade differneces are independent of time period using k-fold cross-validation

Run "seperateBirthdecadeAndTimeperiod.py" to create birthDecade-timePeriod matrices for all nations for both 
Secular-Rationalism and Cosmopolitanism. Then run "kfoldModelComparison.R" which compares hierachical linear regressions 
of increasing complexity to show that assuming birthDecade-timePeriod independence is reasonable.

## create birth decade time series

By running "makeBirthDecadeTrends.py" we average each birth cohort over all time periods (using linear imputation to avoid 
period change bias). This creates normalized birth decade time series files for Secular-Rationalism and Cosmopolitanism.

## run hierachical time-lagged regression

Compare the derived birth decade time series for Secular-Rationlism (RAT) and Cosmopolitanism (COS), with societal varables 
Education (EDS), Life Expectency (LEX), Democracy (DEM) and GDP per capita (GDP) (provided in the folder 
"time_series_normalized"). Run the file "runRegressions.R" to fit and save results.

## plot figure 1 (regression results) 

Run "plotRegressionResults.py" to recreate figure 1

## Figure 3 and analysis for langauge category and cultural values

For this section, you will need to download Louis Puttermans data for the ancestral national origins of modern populations 

We include a file in folder "figure3Data" called "cos_rat.csv", which contains the time averaged Secular-Rationalism and 
Cosmopolitanism for all nations. Running "createLanagugedf.py" builds the dataframe for cultural values and langauge category 
comparisons. Running "lanagugeCategoryRegression.R" runs the linear regression for measuring the effects of slavic, italic 
and germainic languages on cosmopolitanism + secular-rationalism. Then, to produce figure 3, first run "createWorldmap.R" to 
produce figure 3 and then "createFigure3bc.py" to produce figure3b and 3c.










