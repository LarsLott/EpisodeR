
# get_episode

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->
<!-- badges: end -->

In the context of this package, the `get_episode()` function returns a
data.frame in R implementing the episode approach to measure growth and
decline episodes of a V-Dem index variable as suggested in Lott (2023).
By doing so, this `get_episode()` function differs from the approach
implemented in the “Episode of Regime Transformation” approach as
published in Maerz et al. (2023) and available at Institute (2023).

## The `get_episode()` function

By default, `get_episode()` returns a data.frame in R implementing the
episode approach to measure growth and decline episodes of the Academic
Freedom Index as suggested in Lott (2023):

``` r
library(EpisodeR)

df <- get_episode()

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

By using the default values, users get the data.frame presented in Lott
(2023). However, users are also able to customize the default parameters
and use other V-Dem index variables than the Academic Freedom Index.

## Customizing the `get_episode()` function with user-specific parameters and variables

There are different ways users can customize the parameters and set
other V-Dem index variables. Users can use the following arguments:
`data`, `start_incl`, `cum_incl`, `year_turn`, `variable`

### `data`: Change the dataset that should be used

The `data` argument is a way to use another V-Dem dataset than the
dataset coming with the package (latest V-Dem version). Users can also
use `get_episode()` function with other datasets. However, the function
was created for working with V-Dem data.

``` r
## vdem12 must be loaded in the environment ##
#df12 <- get_episode(data = vdem12)
#head(df12)
```

### `start_incl`

The `start_incl` argument enable users to change the parameter that is
necessary to trigger the start of an episode. This is the absolute value
of the first difference. By default, this value is set to 0.01. The
`get_episode()` function follows the potential episode as long as there
is continued increase/decline, while allowing up to four years of
temporary stagnation, meaning no further increase/decline of
`start_incl` points or more on the respective variable.

``` r
df <- get_episode(start_incl = 0.02)
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

### `cum_incl`

The `cum_incl` argument allows for changing the minimum amount of total
change on the index variable necessary to constitute a growth or decline
episode? To identify substantive growth and decline episodes,
`get_episode()` function calculates the total magnitude of change from
the year before the start of an episode to the end of an episode. This
cumulative increase/drop is set to 0.1 by default (10% of the total 0–1
scale). It thus records only those manifest growth episodes which add up
to a positive change of at least `cum_incl` and as manifest decline
episodes only those which add up to a negative change of at least
`cum_incl`.

``` r
## setting the cumulative inclusion parameter to 0.12 (12% of the total 0-1 scale)
df <- get_episode(cum_incl = 0.12)
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

### `year_turn`

The `year_turn` argument enable users to change the parameter that is
necessary to trigger the end of an episode. By default, this value is
set to 0.03. The `get_episode()` function terminate an episode when
there is a temporary stagnation on the AFI with no further
increase/decline of `start_incl` points in four years or when the AFI
decreases/increases by `year_turn` points, from one year to the next.

``` r
df <- get_episode(year_turn = 0.05)
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

### `variable`

The `variable` argument enable users to get episodes for any V-Dem index
variable, e.g. the Liberal Democracy Index (LDI), the Vertical
Accountability Index, and the Liberal Component Index. Users should be
extremely cautions in using variables, which are not scaled between 0
and 1, even it is possible to use other variable from the V-Dem
universe.

``` r
df <- get_episode(variable = "v2x_libdem")
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

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-institute_vdeminstituteert_2023" class="csl-entry">

Institute, V.-Dem. 2023. “Vdeminstitute/ERT.”
<https://github.com/vdeminstitute/ERT>.

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

</div>

</div>
