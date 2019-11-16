# Cultural prerequistes of socioeconomic development
Data code and instructions to reproduce the findings for the paper "Cultural prerequistes for socioeconomic development"

please cite:

## directories
data - contains, lookup for WEVS country codes

R - contains all R scripts

python - contains all Python scriprs

timeSeriesForRegression - time series for multi-level time lagged linear regression

figure3Data - contains time averaged Cosmopolitanism and Secular-Rationality data to produce Figure 3.

random_effects – Language category assignments for all nations

## Get raw data
European Values Survey https://www.gesis.org/en/services/data-analysis/international-survey-programs/european-values-study/

World Values Survey http://www.worldvaluessurvey.org/WVSContents.jsp

Louis Putterman ancestry data - https://www.brown.edu/Departments/Economics/Faculty/Louis_Putterman/world%20migration%20matrix.htm

## Derive Secular-Rationality and Cosmopolitanism from raw WEVS data 

For this section you must download the raw World and European Values Survey data. You should use the 68 cultural value questions that have been asked in all WEVS editions since 1990. The WEVS also contains demographic information such as nation. time period and birth date.

Run "ExtractRandC.R" to use weighted principal component analysis to extract the Secular-Rationality (R) and Cosmopolitanism (C) measures from WEVS data.    

## Show that birth decade differences are independent of time period using model comparison

Run "splitSampesByBirthdecadeAndTimeperiod.py" to split the represnaive samples for each nation by birth decade and time period for both Secular-Rationalism and Cosmopolitanism. Then "createDataframeForkfold.py" converts all the nation matrices into a dataframe to be used in the model comparison. Then run "kfoldModelComparison.R" which compares hierachical linear
regressions of increasing complexity, testing whether birth decade differneces are indepdent of time period. Then run "plotKfoldPerformance.py" to plot these results for the supplimentary materials. 

## run hierachical time-lagged regression

Compare the derived birth decade time series for Secular-Rationlism (RAT), Cosmopolitanism (COS), Education (EDS), Life Expectency (LEX), Democracy (DEM) and GDP per capita (GDP) (provided in the folder "time_series_normalized"). Run the file "runTimeLaggedRegressions.R" to fit and save results.

Changing the "adultAge" parameter runs regressions assuming an adult age of either 0-10, 10-20 or 20-30 years.  

## plot figure 1 (regression results) 

Run "plotRegressionResults.py" to recreate figure 1.  

## Figure 3 and analysis for langauge category and cultural values

For this section, you will need to download Louis Puttermans data for the ancestral origins of modern national populations 

We include a file in folder "figure3Data" called "cos_rat.csv", which contains the time averaged Secular-Rationalism and Cosmopolitanism for all nations. Running "createLanagugedf.py" builds the dataframe containing cultural value scores and percent of popluation descended from nations within the Germanic, Italic and Slavic lamgauge families. Running "LanguageCategoryRegression.R" runs the linear regression for measuring the effect of having Slavic, Italic and Germainic speaking ancenstry on compisite cultural values, cosmopolitanism + secular-rationalism. Then, to produce figure 3, first run "createWorldmap.R" to produce figure 3a and then "createFigure3bc.py" to produce figure3b and 3c.
