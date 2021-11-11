# Elliot Truslow, Jung Mee Park
# INFO523 Data Mining and Discovery
# November 2021
# Final Project

## ----> Getting Started

# Clear workspace
rm(list=ls())

# Setting working directory
setwd("~/Desktop/Fall 2021/INFO523/Final Project/Data Analysis/Dataset")

# Confirming directory change
getwd()

## ----> Loading in Data

# Load in CVRM sample (.csv)
CVRM_sample <- read.csv(file="info523-CVRM_Sample.csv", header = TRUE)

# Check out structure
str(CVRM_sample)

## ----> Subsetting the data
## Interested in the following variables:
    # Current age                   # Days since last arrest
    # Lives in City or county       # Race
    # Police district of residence  # Sex
    # Live where arrested           # Risk score
    # Arrested by CPD

# Select vars of interest
varlist <- c("currentage", "dayslastarrest_num_et", "urban_yn", "race", "sex", "distlastresidence", "livewherearrested_et", "riskscore", "arrestbycpd_yn") 
CVRM_subset <- CVRM_sample[varlist]

# Print to check
print(CVRM_subset)

# Save subset
save(CVRM_subset, file = "info523-CVRM_Subset.RData")
