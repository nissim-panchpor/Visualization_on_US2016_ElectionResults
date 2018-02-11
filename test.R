library(tidyverse)
library(ggplot2)
library(sqldf)
library(ggmap)
library(RColorBrewer)
library(mfx)
library(foreach)
library(doParallel)

#Read both the data files

pres = read.csv("US_County_Level_Presidential_Results_08-16.csv.bz2")

cdata = read.csv("county_data.csv.bz2")

# For each row in Presedential results dataset, seperate out state code and county codes from fips_code
# and add new columns to the dataset
pres = pres %>%
  mutate(state_code = floor(fips_code/1000),
         county_code = fips_code %% 1000)

# Combine the datasets on state followed by county codes using Inner join

data11 = sqldf::sqldf("SELECT
                      p.state_code
                      ,p.county_code
                      ,c.region
                      ,c.division
                      ,c.stname
                      ,c.ctyname
                      ,p.total_2016
                      ,p.dem_2016
                      ,p.gop_2016
                      ,p.oth_2016
                      ,popestimate2016
                      FROM pres p
                      JOIN cdata c
                      on p.state_code = c.state
                      AND p.county_code = c.county")

# Add a new column year with 2016 as value
data11$year = 2016

# Change column names: remove 2016 from the names and give more descriptive names

colnames(data11) = c("state_code","county_code",
                     "mainregion","division","state_name","county_name",
                     "total_votes","dem_votes","gop_votes","other_votes",
                     "population_estimate","year")

# Create factors for region and division columns
data11$mainregion = factor(data11$mainregion)
data11$division = factor(data11$division)

# Create levels for factors created above
levels(data11$mainregion) = c("Northeast","Midwest","South","West")
levels(data11$division) = c("New England","Middle Atlantic","East North Central"
                            ,"West North Central","South Atlantic","East South Central"
                            ,"West South Central","Mountain","Pacific")

data11 = data11 %>%
  mutate(perc_dem = 100*dem_votes/population_estimate)

str(data11)

summary(data11)