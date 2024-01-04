## EpisodeR ##

<!-- badges: start -->
<!-- badges: end -->

An R package to load, explore, and work with any index variable in the V-Dem data set - a project of the [V-Dem Institute](https://www.v-dem.net/) - to built episods of growth and decline in a specific index variable. This package was used for the Academic Freedom Growth and Decline Episodes data set introduced in Lott, Lars (2023). *Academic Freedom Growth and Decline Episodes*. Higher Education. DOI: https://doi.org/10.1007/s10734-023-01156-z.

#### Load, explore, and work the episodes data sets ####
* Note: for non-R users I provide the *Academic Freedom Growth and Decline Episodes data set* in this GitHub project as a .csv file.
  * A [csv file](https://github.com/LarsLott/EpisodeR/blob/master/inst/episode_with_uncertainty_interval_test.csv) controlling for statistical uncertainty in the growth and decline episodes 
  * A [csv-file](https://github.com/LarsLott/EpisodeR/blob/master/inst/episode_without_uncertainty_interval_test.csv) not controlling for statistical uncertainty in the growth and decline episodes
* RELEASE: Academic Freedom Growth and Decline Episodes data set 13.0 is based on the V-Dem dataset v13. In the following years, updated *Academic Freedom Growth and Decline Episodes data set* will be provided once a year when updated V-Dem is published. 

#### Functions ####
* `get_episode`: Identify episodes of growth and decline in an index variable in which this index variable systematically grow or decline in respective and connected country-years. This functions controls for overlapping uncertainty intervals, "var_codelow" and "var_codegigh", as suggested by Pelke and Croissant [(cf. Pelke and Croissant 2021)](https://doi.org/10.1111/spsr.12437). A growth episode in an index variable is defined as a cumulative
increase of 0.1 or more on any index variable. A decline episode is defined as a a cumulative drop of 0.1 or more on any index variable. 
* `get_episode_wo_CI`: Identify episodes of growth and decline in an index variable in which this index variable systematically grow or decline in respective and connected country-years. This functions **does not** control for overlapping uncertainty intervals, "var_codelow" and "var_codegigh", as suggested by Pelke and Croissant [(cf. Pelke and Croissant 2021)](https://doi.org/10.1111/spsr.12437). A growth episode in an index variable is defined as a cumulative increase of 0.1 or more on any index variable. A decline episode is defined as a a cumulative drop of 0.1 or more on any index variable.
* `plot_episodes`: Plot  growth and decline episodes over time for a selected country.
* `plot_all_episode`: Plot share or absolute number of all countries in growth and decline episodes of a specific index variable over time.


## Installation

You can install the development version of EpisodeR from [GitHub](https://github.com/larslott/EpisodeR) with:

``` r
# Install the development version of the EpisodeR package 
# (since this package is still an ongoing project, 
# keep checking for updates, new functions, etc.!)

# First, you need to have the devtools package installed
install.packages("devtools")
# now, install the EpisodeR package directly from GitHub
devtools::install_github("https://github.com/larslott/EpisodeR")

# installed. If you have troubles with the installation 
# write to the package maintainer Lars Lott (lars.lott@fau.de).

```

## Example

This is a basic example which shows you how to use the **EpisodeR** package:

```{r example}
library(EpisodeR)
## basic example code
```

You can use `get_episode` to return a data.frame identifying decline and growth episodes of an index variable in which this variable systematically grow or decline in respective and connected country-years.  

```{r cars}
df <- get_episode(data = EpisodeR::vdem,
                  start_incl = 0.01,
                  cum_incl = 0.1,
                  year_turn = 0.03,
                  variable = "v2xca_academ")
```

