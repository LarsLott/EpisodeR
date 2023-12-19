#'  Plotting the global number/share of countries undergoing growth and decline episodes
#'
#' `plot_all_episode` plots the global number or share of countries undergoing
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
#' @param variable What is the variable the dataset looks for
#'
#' @param start_incl What is the minimum annual change of a variable necessary to trigger an episode? This is the absolute value of the first difference
#' in the variable required for the onset of either a decline or growth episode
#'
#' @param cum_incl What is the minimum amount of total change on the variable necessary to constitute a manifest episode?
#' A potential episode might be a period involving any amount of changes over a period following an annual change equal
#' to the start inclusion (e.g. 0.01). To identify substantial changes, we set a cumulative inclusion threshold.
#' This is the absolute value of the total amount of change needed on the EDI to be considered manifest.
#'
#' @param year_turn  What is the amount of annual change in the opposite direction to trigger the termination of an episode?
#' An episode may end when the case suddenly moves in the opposite direction.
#'
#' @return The output of this function is a ggplot() object with the number/share of autocratization episodes per year.
#'
#' @import ggplot2
#' @import dplyr
#'
#' @export
plot_all_episode <- function(abs = T,
                     years = c(1900, 2022),
                     start_incl  = 0.01,
                     cum_incl  = 0.1,
                     year_turn = 0.03,
                     variable = "v2xca_academ")
  {

  eps <- EpisodeR::get_episode_wo_CI(data = EpisodeR::vdem,
                                     start_incl = start_incl,
                                     cum_incl = cum_incl,
                                     year_turn = year_turn,
                                     variable = variable)

  stopifnot(is.logical(abs), length(abs) == 1)

  stopifnot(is.numeric(years), length(years) == 2, years[2] > years[1])

  #perhaps this is redundant
  if(min(years)<min(eps$year) | max(years)>max(eps$year))
    stop("Error: Data not available for time range")

  if (isTRUE(abs)) {
    eps_year <- eps %>%
      dplyr::filter(between(year, min(years), max(years))) %>%
      {if(nrow(.) == 0) stop("No episodes during selected time period. No plot generated") else .} %>%
      dplyr::group_by(year) %>%
      dplyr::summarise(increase_episodes = sum(increase_episode),
                       decline_episodes = sum(decline_episode)) %>%
      tidyr::pivot_longer(cols = c(increase_episodes, decline_episodes), names_to = "ep_type", values_to = "countries")

  } else {
    eps_year <- eps %>%
      dplyr::filter(between(year, min(years), max(years))) %>%
      dplyr::group_by(year) %>%
      dplyr::summarise(increase_episodes = sum(increase_episode) / length(unique(country_id)),
                       decline_episodes = sum(decline_episode) / length(unique(country_id))) %>%
      tidyr::pivot_longer(cols = c(increase_episodes, decline_episodes), names_to = "ep_type", values_to = "countries")
  }

  p <-  ggplot2::ggplot(data = eps_year, aes(x = year, y = countries, group = ep_type, linetype = ep_type)) +
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
