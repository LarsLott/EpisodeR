
# get_episode_wo_CI

<!-- get_episode_wo_CI.md is generated from get_episode_wo_CI.Rmd. Please edit that file -->

In the context of this package, the `get_episode_wo_CI()` function
returns a data.frame in R implementing the episode approach to measure
growth and decline episodes of a V-Dem index variable as suggested in
Lott (2023). The `get_episode_wo_CI()` function does not control for
overlapping uncertainty intervals before the start of an episode and at
the end of an episode. This `get_episode_wo_CI()` function differs from
the approach implemented in the “Episode of Regime Transformation”
approach as published in Maerz et al. (2023) and available at V-Dem
Institute (2023).

## The `get_episode_wo_CI()` function

By default, `get_episode_wo_CI()` returns a data.frame in R implementing
the episode approach to measure growth and decline episodes of the
Academic Freedom Index as suggested in Lott (2023):

``` r
library(EpisodeR)

df <- get_episode_wo_CI()

head(df)
#> # A tibble: 6 × 19
#>   country_id country_text_id country_name v2xca_academ v2xca_academ_codelow
#>        <dbl> <chr>           <chr>               <dbl>                <dbl>
#> 1          3 MEX             Mexico              0.544                0.431
#> 2          3 MEX             Mexico              0.544                0.431
#> 3          3 MEX             Mexico              0.544                0.431
#> 4          3 MEX             Mexico              0.544                0.431
#> 5          3 MEX             Mexico              0.544                0.431
#> 6          3 MEX             Mexico              0.544                0.431
#> # ℹ 14 more variables: v2xca_academ_codehigh <dbl>, year <dbl>,
#> #   increase_episode <dbl>, increase_episode_id <chr>, increase_sum <dbl>,
#> #   increase_episode_start_year <dbl>, increase_episode_end_year <dbl>,
#> #   increase_episode_censored <dbl>, decline_episode <dbl>,
#> #   decline_episode_id <chr>, decline_sum <dbl>,
#> #   decline_episode_start_year <dbl>, decline_episode_end_year <dbl>,
#> #   decline_episode_censored <dbl>
```

The `get_episode_wo_CI` function does not consider measurement
uncertainty in the measurement of the index variables. However, when not
considering measurement uncertainty in the measurement of episodes, the
cutoff point needs to be more demanding to reduce the risks of
measurement error. Users who want to consider measurement uncertainty
into account should use the `get_episode` function from this package.

By using the default values, users get the data.frame presented in Lott
(2023). However, users are also able to customize the default parameters
and use other V-Dem index variables than the Academic Freedom Index.

## Customizing the `get_episode_wo_CI()` function with user-specific parameters and variables

There are different ways users can customize the parameters and set
other V-Dem index variables. Users can use the following arguments:
`data`, `start_incl`, `cum_incl`, `year_turn`, `variable`

### `data`: Change the dataset that should be used

The `data` argument is a way to use another V-Dem dataset than the
dataset coming with the package (latest V-Dem version). Users can also
use `get_episode_wo_CI()` function with other datasets. However, the
function was originally created for working with V-Dem data.

``` r
## vdem12 must be loaded in the environment ##
#df12 <- get_episode_wo_CI(data = vdem12)
#head(df12)
```

### `start_incl`: Set the paramater that is necessary to trigger the start of an episode

The `start_incl` argument enables users to change the parameter that is
necessary to trigger the start of an episode. This is the absolute value
of the first difference. By default, this value is set to 0.01. The
`get_episode_wo_CI()` function follows the potential episode as long as
there is continued increase/decline, while allowing up to four years of
temporary stagnation, meaning no further increase/decline of
`start_incl` points or more on the respective variable.

``` r
df <- get_episode_wo_CI(start_incl = 0.02)
head(df)
#> # A tibble: 6 × 19
#>   country_id country_text_id country_name v2xca_academ v2xca_academ_codelow
#>        <dbl> <chr>           <chr>               <dbl>                <dbl>
#> 1          3 MEX             Mexico              0.544                0.431
#> 2          3 MEX             Mexico              0.544                0.431
#> 3          3 MEX             Mexico              0.544                0.431
#> 4          3 MEX             Mexico              0.544                0.431
#> 5          3 MEX             Mexico              0.544                0.431
#> 6          3 MEX             Mexico              0.544                0.431
#> # ℹ 14 more variables: v2xca_academ_codehigh <dbl>, year <dbl>,
#> #   increase_episode <dbl>, increase_episode_id <chr>, increase_sum <dbl>,
#> #   increase_episode_start_year <dbl>, increase_episode_end_year <dbl>,
#> #   increase_episode_censored <dbl>, decline_episode <dbl>,
#> #   decline_episode_id <chr>, decline_sum <dbl>,
#> #   decline_episode_start_year <dbl>, decline_episode_end_year <dbl>,
#> #   decline_episode_censored <dbl>
```

### `cum_incl`: Set the minimum amount of total change on the index variable necessary to constitute a growth or decline episode

The `cum_incl` argument allows for changing the minimum amount of total
change on the index variable necessary to constitute a growth or decline
episode? To identify substantive growth and decline episodes,
`get_episode_wo_CI()` function calculates the total magnitude of change
from the year before the start of an episode to the end of an episode.
This cumulative increase/drop is set to 0.1 by default (10% of the total
0–1 scale). It thus records only those manifest growth episodes which
add up to a positive change of at least `cum_incl` and as manifest
decline episodes only those which add up to a negative change of at
least `cum_incl`.

``` r
## setting the cumulative inclusion parameter to 0.12 (12% of the total 0-1 scale)
df <- get_episode_wo_CI(cum_incl = 0.12)
head(df)
#> # A tibble: 6 × 19
#>   country_id country_text_id country_name v2xca_academ v2xca_academ_codelow
#>        <dbl> <chr>           <chr>               <dbl>                <dbl>
#> 1          3 MEX             Mexico              0.544                0.431
#> 2          3 MEX             Mexico              0.544                0.431
#> 3          3 MEX             Mexico              0.544                0.431
#> 4          3 MEX             Mexico              0.544                0.431
#> 5          3 MEX             Mexico              0.544                0.431
#> 6          3 MEX             Mexico              0.544                0.431
#> # ℹ 14 more variables: v2xca_academ_codehigh <dbl>, year <dbl>,
#> #   increase_episode <dbl>, increase_episode_id <chr>, increase_sum <dbl>,
#> #   increase_episode_start_year <dbl>, increase_episode_end_year <dbl>,
#> #   increase_episode_censored <dbl>, decline_episode <dbl>,
#> #   decline_episode_id <chr>, decline_sum <dbl>,
#> #   decline_episode_start_year <dbl>, decline_episode_end_year <dbl>,
#> #   decline_episode_censored <dbl>
```

### `year_turn`: Set the parameter that is necessary to trigger the end of an episode

The `year_turn` argument enable users to change the parameter that is
necessary to trigger the end of an episode. By default, this value is
set to 0.03. The `get_episode_wo_CI()` function terminates an episode
when there is a temporary stagnation on the AFI with no further
increase/decline of `start_incl` points in four years or when the AFI
decreases/increases by `year_turn` points, from one year to the next.

``` r
df <- get_episode_wo_CI(year_turn = 0.05)
head(df)
#> # A tibble: 6 × 19
#>   country_id country_text_id country_name v2xca_academ v2xca_academ_codelow
#>        <dbl> <chr>           <chr>               <dbl>                <dbl>
#> 1          3 MEX             Mexico              0.544                0.431
#> 2          3 MEX             Mexico              0.544                0.431
#> 3          3 MEX             Mexico              0.544                0.431
#> 4          3 MEX             Mexico              0.544                0.431
#> 5          3 MEX             Mexico              0.544                0.431
#> 6          3 MEX             Mexico              0.544                0.431
#> # ℹ 14 more variables: v2xca_academ_codehigh <dbl>, year <dbl>,
#> #   increase_episode <dbl>, increase_episode_id <chr>, increase_sum <dbl>,
#> #   increase_episode_start_year <dbl>, increase_episode_end_year <dbl>,
#> #   increase_episode_censored <dbl>, decline_episode <dbl>,
#> #   decline_episode_id <chr>, decline_sum <dbl>,
#> #   decline_episode_start_year <dbl>, decline_episode_end_year <dbl>,
#> #   decline_episode_censored <dbl>
```

### `variable`: Change the index variable that constitutes episodes of change

The `variable` argument enables users to get episodes for any V-Dem
index variable, e.g. the Liberal Democracy Index (LDI), the Vertical
Accountability Index, and the Liberal Component Index. Users should be
extremely cautions in using variables, which are not scaled between 0
and 1, even it is possible to use other variable from the V-Dem
universe.

``` r
df <- get_episode_wo_CI(variable = "v2x_libdem")
head(df)
#> # A tibble: 6 × 19
#>   country_id country_text_id country_name v2x_libdem v2x_libdem_codelow
#>        <dbl> <chr>           <chr>             <dbl>              <dbl>
#> 1          3 MEX             Mexico            0.062              0.047
#> 2          3 MEX             Mexico            0.06               0.045
#> 3          3 MEX             Mexico            0.06               0.045
#> 4          3 MEX             Mexico            0.06               0.045
#> 5          3 MEX             Mexico            0.06               0.045
#> 6          3 MEX             Mexico            0.06               0.045
#> # ℹ 14 more variables: v2x_libdem_codehigh <dbl>, year <dbl>,
#> #   increase_episode <dbl>, increase_episode_id <chr>, increase_sum <dbl>,
#> #   increase_episode_start_year <dbl>, increase_episode_end_year <dbl>,
#> #   increase_episode_censored <dbl>, decline_episode <dbl>,
#> #   decline_episode_id <chr>, decline_sum <dbl>,
#> #   decline_episode_start_year <dbl>, decline_episode_end_year <dbl>,
#> #   decline_episode_censored <dbl>
```

## Comparison to `get_ert()` function from the ERT package

The ERT package from V-Dem Institute (2023) differs from this package in
important ways. The ERT package is computationally more efficient and
more flexible in what constitutes an episode. It was one important
source of code for this package and the work done by Seraphine Maerz,
Amanda Edgell, Matthew Wilson, Sebastian Hellmeier, and Staffan I.
Lindberg, and co-authors inspired my work for this package. However, two
important drawbacks come with the ERT package. It does not enable users
to search for episode of regime transformation / change other than the
Electoral Democracy Score. Secondly, the ERT package does not control
for overlapping uncertainty intervals (before the start of an episode
and at the end of an episode). These drawbacks are partially resolved in
this package, while it comes with another important drawbacks: It is
computationally inefficient and less flexible in terms of episode
termination and tolerance for temporary stagnation.

The `EpisodeR` package copied and adapted some code parts of the ERT
package but does not use the most important part of the ERT package (C++
code for finding episodes) to estimate episodes of change data.

### Differences:

- The ERT package uses C++ language to find episodes of regime
  transformation, while this package uses some loops in R for finding
  these episodes of change in an index variable. The `EpisodeR` package
  is computationally more inefficient compared to the C++ solution from
  the ERT package.
- The ERT package enables users to consider a specific number of years
  as tolerance for stasis or a gradual movement in the opposite
  direction. By default it is set to five years. In the `EpisodeR`
  package users cannot change the tolerance parameter and there is a
  temporary stasis on the specific variable with no further
  increase/decline of `start_incl` points in four years.

## References

<div id="refs" class="references csl-bib-body hanging-indent">

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

<div id="ref-institute_vdeminstituteert_2023" class="csl-entry">

V-Dem Institute. 2023. “Vdeminstitute/ERT.”
<https://github.com/vdeminstitute/ERT>.

</div>

</div>
