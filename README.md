
<!-- README.md is generated from README.Rmd. Please edit that file -->

## EpisodeR

<!-- badges: start -->
<!-- badges: end -->

An R package to load, explore, and work with any index variable in the
V-Dem data set - a project of the [V-Dem
Institute](https://www.v-dem.net/) - to built episodes of growth and
decline in a specific V-Dem index variable. This package was used for
the Academic Freedom Growth and Decline Episodes data set introduced in
Lott (2023).

This package uses code parts of the [ERT
package](https://github.com/vdeminstitute/ERT) (V-Dem Institute (2023)).
All copied and adapted code parts are marked accordingly in the R code
of this package. However, unlike the [ERT
package](https://github.com/vdeminstitute/ERT), this package uses a
different approach to identify episodes of change in a variable. These
differences are documented below.

#### Acknowledgements

I would like to thank the authors of the [ERT
package](https://github.com/vdeminstitute/ERT), namely Seraphine Maerz,
Amanda Edgell, Joshua Krusell, Laura Maxwell, and Sebastian Hellmeier,
who have licensed the [ERT
package](https://github.com/vdeminstitute/ERT) under the GPL-3 license.
This package (EpisodeR) is also licensed under the GPL-3 license.
Without the excellent documentation and work of these colleagues, this
package would not have been possible.

The work of the Episodes of Regime Transformation team has published as
Maerz et al. (2023), Edgell et al. (2022), Wilson et al. (2023), Boese
et al. (2021), among others. The package development has been funded by
a Volkswagen Foundation \[grant number A138109, PI: Katrin Kinzelbach
and Staffan I. Lindberg\] and is part of the [Academic Freedom
Index](https://academic-freedom-index.net/) project.

## EpisodeR package

#### Load, explore, and work the episodes data sets

- Note: for non-R users I provide the *Academic Freedom Growth and
  Decline Episodes data set* in this GitHub project as
  [.csv](https://github.com/LarsLott/EpisodeR/tree/master/inst) files.
- RELEASE: Academic Freedom Growth and Decline Episodes data set 13.0 is
  based on the V-Dem dataset v13. In the following years, updated
  *Academic Freedom Growth and Decline Episodes data set* will be
  provided once a year when updated V-Dem is published.

#### Functions

- `get_episode`: Identify episodes of growth and decline in an index
  variable in which this index variable systematically grows or declines
  in respective and connected country-years. This functions controls for
  overlapping uncertainty intervals, “var_codelow” and “var_codehigh”,
  as suggested by Pelke and Croissant (2021). A growth episode in an
  index variable is defined as a cumulative increase of 0.1 or more on
  any index variable. A decline episode is defined as a a cumulative
  drop of 0.1 or more on any index variable.
- `get_episode_wo_CI`: Identify episodes of growth and decline in an
  index variable in which this index variable systematically grows or
  declines in respective and connected country-years. This functions
  **does not** control for overlapping uncertainty intervals,
  “var_codelow” and “var_codehigh”, as suggested by Pelke and Croissant
  (2021). A growth episode in an index variable is defined as a
  cumulative increase of 0.1 or more on any index variable. A decline
  episode is defined as a a cumulative drop of 0.1 or more on any index
  variable.
- `plot_episodes`: Plot growth and decline episodes over time for a
  selected country.
- `plot_all_episodes`: Plot share or absolute number of all countries in
  growth and decline episodes of a specific index variable over time.

## Differences between ERT package and EpisodeR package

The [ERT package](https://github.com/vdeminstitute/ERT) differs from
this package in important ways. The ERT package is computationally more
efficient and more flexible in what constitutes an episode of change in
a variable. It was one important source of code for this package it
inspired my work for this package. However, two drawbacks come with the
[ERT package](https://github.com/vdeminstitute/ERT):

- It does not enable users to search for episode of regime
  transformation / change other than the Electoral Democracy Index.
- Secondly, the ERT package does not control for overlapping uncertainty
  intervals (before the start of an episode and at the end of an
  episode), as suggested by Pelke and Croissant (2021).

These drawbacks are partially resolved in this package, while it comes
with other important drawbacks: It is computationally inefficient and
less flexible in terms of episode termination and tolerance for
temporary stagnation.

The `EpisodeR` package copied and adapted some code parts of the ERT
package but does not use the most important part of the ERT package (C++
code for finding episodes) to estimate episodes of change data. It
differs most substanially here:

- The ERT package uses C++ language to find episodes of regime
  transformation, while this package uses some loops in R for finding
  these episodes of change in an index variable. The `EpisodeR` package
  is computationally more inefficient compared to the C++ solution from
  the ERT package. To find episodes of change in a variable, this
  package uses code originally used by Pelke and Croissant (2021).
- The ERT package enables users to consider a specific number of years
  as tolerance for stasis or a gradual movement in the opposite
  direction. By default it is set to **five years**. In the `EpisodeR`
  package users cannot change the tolerance parameter and there is a
  temporary stasis on the specific variable with no further
  increase/decline of `start_incl` points in **four years**.

## Installation

You can install the development version of EpisodeR from
[GitHub](https://github.com/larslott/EpisodeR) with:

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

This is a basic example which shows you how to use the **EpisodeR**
package:

``` r
library(EpisodeR)
## basic example code
```

You can use `get_episode` to return a data.frame identifying decline and
growth episodes of an index variable in which this variable
systematically grow or decline in respective and connected
country-years.

``` r
df <- get_episode(data = EpisodeR::vdem,
                  start_incl = 0.01,
                  cum_incl = 0.1,
                  year_turn = 0.03,
                  variable = "v2xca_academ")
```

Vignettes explaining the different functions and how they differ from
the ERT package are available in the Vignettes folder in the GitHub
repository.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-boese_how_2021" class="csl-entry">

Boese, Vanessa A., Amanda B. Edgell, Sebastian Hellmeier, Seraphine F.
Maerz, and Staffan I. Lindberg. 2021. “How Democracies Prevail:
Democratic Resilience as a Two-Stage Process.” *Democratization* 28 (5):
885–907. <https://doi.org/10.1080/13510347.2021.1891413>.

</div>

<div id="ref-edgell_institutional_2022" class="csl-entry">

Edgell, Amanda B., Vanessa A. Boese, Seraphine F. Maerz, Patrik
Lindenfors, and Staffan I. Lindberg. 2022. “The Institutional Order of
Liberalization.” *British Journal of Political Science* 52 (3): 1465–71.
<https://doi.org/10.1017/S000712342100020X>.

</div>

<div id="ref-lott_academic_2023" class="csl-entry">

Lott, Lars. 2023. “Academic Freedom Growth and Decline Episodes.”
*Higher Education*, December.
<https://doi.org/10.1007/s10734-023-01156-z>.

</div>

<div id="ref-maerz_episodes_2023" class="csl-entry">

Maerz, Seraphine F., Amanda B. Edgell, Matthew C. Wilson, Sebastian
Hellmeier, and Staffan I. Lindberg. 2023. “Episodes of Regime
Transformation.” *Journal of Peace Research*.
<https://doi.org/10.1177/00223433231168192>.

</div>

<div id="ref-pelke_conceptualizing_2021" class="csl-entry">

Pelke, Lars, and Aurel Croissant. 2021. “Conceptualizing and Measuring
Autocratization Episodes.” *Swiss Political Science Review* 27 (2):
434–48. <https://doi.org/10.1111/spsr.12437>.

</div>

<div id="ref-institute_vdeminstituteert_2023" class="csl-entry">

V-Dem Institute. 2023. “Vdeminstitute/ERT.”
<https://github.com/vdeminstitute/ERT>.

</div>

<div id="ref-wilson_episodes_2023" class="csl-entry">

Wilson, Matthew C., Juraj Medzihorsky, Seraphine F. Maerz, Patrik
Lindenfors, Amanda B. Edgell, Vanessa A. Boese, and Staffan I. Lindberg.
2023. “Episodes of Liberalization in Autocracies: A New Approach to
Quantitatively Studying Democratization.” *Political Science Research
and Methods* 11 (3): 501–20. <https://doi.org/10.1017/psrm.2022.11>.

</div>

</div>
