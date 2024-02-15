# ACTIVITY: Joins Pivots dataRetrieval {#joinpivotDR}

## Load the tidyverse, dataRetrieval, and patchwork packages.

```{r}
library(tidyverse)
library(dataRetrieval)
library(patchwork)
```

## Problem 1 
Using readWQPqw(), read all the chloride (00940) data for the New River at Radford (03171000, must add USGS- to gage id). Use the head() function to print the beginning of the output from readNWISqw.

```{r}
#set the site number and parameter code
site_number<-"USGS-03171000"
parameter_code <- "00940"

#Read the chloride data using the readNWISqw
newriverwQ <- readWQPqw(site_number, parameter_code)
head(newriverwQ)
view(newriverwQ)
```

## Problem 2_
Using the readNWISdv (daily values) function, download discharge (00060), temperature (00003), and specific conductivity (00095) for the New River at Radford from 2007 to 2009 (regular year). Use renameNWIScolumns() to rename the output of the download. Use head() to show the beginning of the results of your download.

```{r}
site<-"03171000"
parameter_codes <- c("00060", "00003", "00095")
start_date <- "2007-01-01"
end_date <- "2009-12-31"
newphys <- readNWISdv(site, parameter_codes, start_date,end_date)|>
     renameNWISColumns()
head(newphys)
```

## Problem 3
Do a left join on newphys and newriver to add the chloride data to the daily discharge, temp, and conductivity data. hint: you will join on the date. Preview your data below the chunk using head().

```{r}
# Perform left join
newphys_joining <- left_join(newphys, newriverwQ, by = c("Date" = "ActivityStartDate"))

# Display the first few rows
head(newphys_joining)
```

## Problem 4
Create a line plot of Date (x) and Flow (y). Create a scatter plot of Date (x) and chloride concentration (y). Put the graphs on top of each other using the patchwork library.

```{r}
#To create a line plot
line_plot<- ggplot(newphys_joining, aes(x= Date, y=Flow))+
  geom_line()+
  ylab("Flow")+
  xlab(element_blank())+
  labs(title="Flow over Time at New River")+
  theme_classic()

#To create a scatterplot
scatter_plot<-ggplot(newphys_joining, aes(x=Date, y=ResultMeasureValue))+
  geom_point()+
  ylab("concentration(mg/L)")+
  xlab(element_blank())+
  labs(title = "Chloride Concentration over Time at New River")+
  theme_classic()


combined_plot <- line_plot/scatter_plot
combined_plot

```

## Problem 5
Create a scatter plot of Specific Conductivity (y) and Chloride (x). Challenge: what could you do to get rid of the warning this plot generates about NAs.

```{r}
library(dplyr)
newphys_clean <- newphys_joining |>
  filter(! is.na(SpecCond) & ! is.na(ResultMeasureValue))

scatter_plot<-ggplot(newphys_clean, aes(x= ResultMeasureValue, y=SpecCond))+
  geom_point()+
  ylab("Specific Cond. (µs/cm)")+
  xlab("Concentration (mg/L)")+
  labs(title = "Scatter Plot: Chloride Concentration over Time at New River")+
  theme_classic()
scatter_plot

#To address the warning about NAs: The warning likely indicates that there are missing values (NAs) in either the Specific Conductivity or Chloride columns. We can handle NAs by removing them with  na.omit  command which is used to remove rows containing NAs in the specified columns.
  
```

## Problem 6
Read in the GG chem subset data and plot Mg_E1 (x) vs Ca_E1 (y) as points.

```{r}
options(readr.show_col_types = FALSE)
library(readr)
gg_chem <- read_csv("GG_chem_subest.csv")

chem_plot <- ggplot(gg_chem, aes(x = Mg_E1, y = Ca_E1))+
  geom_point()+
  ylab("Calcium(Ca)")+
  xlab("Magnesium(Mg)")+
  labs(title = "Magnesium versus Calcium")+
  theme(plot.title = element_text(hjust=0.5))
  
chem_plot
  
```


## Problem 7
We want to look at concentrations of each element in the \#6 dataset along the stream (Distance), which is difficult in the current format. Pivot the data into a long format, the data from Ca, Mg, and Na \_E1 columns should be pivoted. Make line plots of each element where y is the concentration and x is distance. Use facet_wrap() to create a separate plot for each element and use the "scales" argument of facet_wrap to allow each plot to have different y limits.

```{r}
#To pivot the data
gg_chem_long <- gg_chem |>
  pivot_longer(cols = c("Ca_E1", "Mg_E1",  "Na_E1"), 
               names_to = "Element", values_to = "Concentration")

#To Create line plots
chem_plot <- ggplot(gg_chem_long, aes(x= Distance, y = Concentration, group = Element, color= Element))+
  geom_line()+
  facet_wrap(facets = "Element", nrow = 3, scales = "free_y")+
  theme_minimal()

chem_plot
```
