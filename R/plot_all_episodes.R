#'  Plotting the global number/share of countries undergoing growth and decline episodes
#'
#' `plot_all_episodes` plots the global number or share of countries undergoing
#' growth and decline episodes in a specific variable in a selected time frame.
#'
#' This function is a wrapper for ggplot() and produces a plot that shows
#' growth and decline episodes over time for a specific variable
#' The function calls the EpisodeR:get_episode_wo_CI() function to identify episodes,
#' but without controlling for overlapping confidence intervals
#'
#' @param abs Logical value: if TRUE, the absolute number of countries in an episode for each year is plotted.
#' If FALSE, the share of countries in percentage undergoing growth or decline is plotted.
#'
#' @param years Vector with two numeric values indicating the minimum and maximum year to be plotted.
#'
#' @param variable What is the index variable the dataset looks for. By default, the v2xca_academ variable is loaded.
#'
#' @param start_incl What is the minimum annual change of a variable necessary to trigger an episode? This is the absolute value of the first difference
#' in the variable required for the onset of either a decline or growth episode
#'
#' @param cum_incl What is the minimum amount of total change on the variable necessary to constitute a manifest episode?
#' A potential episode might be a period involving any amount of changes over a period following an annual change equal
#' to the start inclusion (e.g. 0.01). To identify substantial changes, we set a cumulative inclusion threshold.
#' This is the absolute value of the total amount of change needed on the index variable to be considered manifest.
#'
#' @param year_turn  What is the amount of annual change in the opposite direction to trigger the termination of an episode?
#' An episode may end when the case suddenly moves in the opposite direction.
#'
#' The terms @param abs, @param years, @param start_incl, @param cum_incl, and @param year_turn as well as the descriptions of these terms in the function are adapted
#' from the ERT-package available at https://github.com/vdeminstitute/ERT. In the function below, all parts of code that was copied and adapted from the ERT package are tagged.
#' The original ERT package enable users to set additional parameters to customize their definitions of what constitutes an episode of change. These additional parameters are
#' the tolerance parameter, and the cum_turn parameter. In this package, episodes are considered as an episode as long as there is continued increase/decline,
#' while allowing up to 4 years of temporary stagnation. This period of 4 years cannot be set to another value of temporary stagnation (compare the more flexible ERT package).
#'
#' @return The output of this function is a ggplot() object with the number/share of autocratization episodes per year.
#'
#' @import ggplot2
#' @import dplyr
#' @import tidyr
#'
#' @export
plot_all_episodes <- function(abs = T,
                     years = c(1900, 2023),
                     start_incl  = 0.01,
                     cum_incl  = 0.1,
                     year_turn = 0.03,
                     variable = "v2xca_academ")
  {

  df <- EpisodeR::get_episode_wo_CI(data = EpisodeR::vdem,
                                     start_incl = start_incl,
                                     cum_incl = cum_incl,
                                     year_turn = year_turn,
                                     variable = variable)

  ## copied and adapted from ERT package ##

  stopifnot(is.logical(abs), length(abs) == 1)

  stopifnot(is.numeric(years), length(years) == 2, years[2] > years[1])

  #perhaps this is redundant
  if(min(years)<min(df$year) | max(years)>max(df$year))
    stop("Error: Data not available for time range")

  if (isTRUE(abs)) {
    df_year <- df %>%
      dplyr::filter(between(year, min(years), max(years))) %>%
      {if(nrow(.) == 0) stop("No episodes during selected time period. No plot generated") else .} %>%
      dplyr::group_by(year) %>%
      dplyr::summarise(increase_episodes = sum(increase_episode, na.rm=TRUE ),
                       decline_episodes = sum(decline_episode,  na.rm=TRUE)) %>%
      tidyr::pivot_longer(cols = c(increase_episodes, decline_episodes), names_to = "ep_type", values_to = "countries")

  } else {
    df_year <- df %>%
      dplyr::filter(between(year, min(years), max(years))) %>%
      dplyr::group_by(year) %>%
      dplyr::summarise(increase_episodes = sum(increase_episode,  na.rm=TRUE) / length(unique(country_id)),
                       decline_episodes = sum(decline_episode,  na.rm=TRUE) / length(unique(country_id))) %>%
      tidyr::pivot_longer(cols = c(increase_episodes, decline_episodes), names_to = "ep_type", values_to = "countries")
  }

  p <-  ggplot2::ggplot(data = df_year, aes(x = year, y = countries, group = ep_type, linetype = ep_type)) +
    geom_line() +
    scale_x_continuous(breaks = seq(round(min(years) / 10) * 10, round(max(years) / 10) * 10, 10)) +
    scale_linetype(name = "", breaks = c("increase_episodes", "decline_episodes"), labels = c("Growth Episodes", "Decline Episodes")) +
    xlab("Year") +
    theme_classic() +
    theme(legend.position = "bottom")

  if (isTRUE(abs)) {
    p +  ylab("Number of Countries")
  }  else {
    p +  ylab("Countries (%)")
  }
}
