#'  Plot episodes of variable growth and decline episodes for a specific country
#'
#' `plot_episodes` plots growth and decline episodes in a specific variable
#'  over time for a selected country and a selected time frame.
#'
#' This function is a wrapper for ggplot() and produces a plot that shows
#' growth and decline episodes for a selected country over time.
#' The function calls the EpisodeR:get_episode_wo_CI() function to identify episodes, but without controlling for overlapping confidence intervals
#'
#' @param years Vector with two numeric values indicating the minimum and maximum year to be plotted.
#'
#' @param country Character vector containing the country for which episodes should be shown. Only entries from the
#' country_name column in the V-Dem data set are accepted.
#'
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
plot_episodes <- function(years = c(1900, 2021),
                          country = c("Sweden"),
                          start_incl  = 0.01,
                          cum_incl  = 0.1,
                          year_turn = 0.03,
                          variable = "v2xca_academ") {

  eps <-  EpisodeR::get_episode_wo_CI(data = EpisodeR::vdem,
                                      start_incl = start_incl,
                                      cum_incl = cum_incl,
                                      year_turn = year_turn,
                                      variable = variable)

  eps <- eps %>%
    dplyr::group_by(country_id) %>%
    mutate(increase_episode = ifelse(lead(increase_episode == 1), 1, increase_episode),
           decline_episode = ifelse(lead(decline_episode == 1), 1, decline_episode))

  stopifnot(is.numeric(years), length(years) == 2, years[2] > years[1])

  stopifnot(is.character(country))

  if(length(country) > 1)
    stop("Error: More than one country selected")

  if(length(country) == 0)
    stop("Error: No country selected")

  if(!country %in% data$country_name)
    stop("Error: Country not found")

  if(max(years) < min(eps %>% filter(country_name==country) %>% pull(year)) | max(years)>max(eps %>% filter(country_name==country) %>% pull(year)))
    stop("Error: Data not available for time range")

  year <- country_name <- increase_episode <- decline_episode <- overlap_eps <- v2xca_academ <-
    ep_type <- episode <- vdem <- increase_episode_start_year <-increase_episode_end_year <-
    decline_episode_start_year <- decline_episode_end_year <- decline_episode_id <- increase_episode_id <- countries <- NULL

  eps_year <- eps %>%
    dplyr::filter(country_name == country, dplyr::between(year, min(years), max(years))) %>%
    dplyr::filter(increase_episode == 1 | decline_episode == 1)

  if(nrow(eps_year)>1){
    eps_year <- eps_year %>%
      dplyr::mutate(overlap_eps = ifelse(!is.na(decline_episode_id) & !is.na(increase_episode_id), "overlaps", NA)) %>%
      tidyr::pivot_longer(cols = c(decline_episode_id, increase_episode_id, overlap_eps), names_to = "ep_type", values_to = "episode") %>%
      dplyr::select(country_name, year, v2xca_academ, ep_type, episode,
                    decline_episode_start_year, decline_episode_end_year,
                    increase_episode_start_year, increase_episode_end_year) %>%
      dplyr::filter((ep_type == "increase_episode_id") |
                      (ep_type == "decline_episode_id") |
                      ep_type == "overlaps") %>%
      drop_na(episode) %>%
      group_by(year) %>%
      mutate(overlap_eps = n(),
             episode_id = ifelse(ep_type == "decline_episode_id", paste0("Decline: ", decline_episode_start_year, "-", decline_episode_end_year), episode),
             episode_id = ifelse(ep_type == "increase_episode_id", paste0("Growth: ", increase_episode_start_year, "-", increase_episode_end_year), episode_id)) %>%
      ungroup()

    v2xca_academ <- eps %>%
      filter(country_name == country, between(year, min(years), max(years))) %>%
      ungroup() %>%
      select(year, v2xca_academ)

    if(max(eps_year$overlap_eps) > 1) {
      print("Warning: Some episodes overlap!")
    }

    p <-   ggplot2::ggplot() +
      geom_line(data = eps_year, aes(group = episode_id, color = episode_id, linetype = ep_type,x = year, y = v2xca_academ)) +
      geom_line(data = v2xca_academ, aes(x = year, y = v2xca_academ), alpha = 0.35) +
      scale_colour_grey(breaks = levels(factor(eps_year$episode_id[eps_year$episode_id!="overlaps"])),
                        name = "Episode", start = 0.01, end = 0.01) +
      scale_linetype_manual(name = "Episode type", breaks = c("decline_episode_id", "increase_episode_id", "overlaps"),
                            labels = c("Decline", "Growth", "Overlap"),
                            values = c("dashed", "dotted", "solid")) +
      scale_x_continuous(breaks = seq(round(min(years) / 10) * 10, round(max(years) / 10) * 10, 10)) +
      xlab("Year") +  ylab("Academic Freedom Index") + ylim(0,1) +
      theme_bw() +
      guides(color = guide_legend(override.aes = list(size = 0))) +
      ggtitle(sprintf("%s", country))

    if (isTRUE(length(which(eps_year$ep_type == "increase_episode_id")) > 0)){

      if (any(eps_year$year%in%c(eps_year$increase_episode_start_year))) {
        p <- p +  geom_point(data = eps_year, aes(x = year, y = ifelse(year == increase_episode_start_year, v2xca_academ, NA)), shape = 2, alpha = 0.75)

      } else {
        p
      }

      if (any(eps_year$year%in%c(eps_year$increase_episode_end_year))) {
        p <- p +geom_point(data = eps_year, aes(x = year, y = ifelse(year == increase_episode_end_year, v2xca_academ, NA)), shape = 17, alpha = 0.75)
      } else {
        p
      }
    }

    if (isTRUE(length(which(eps_year$ep_type == "decline_episode_id")) > 0)) {

      if (any(eps_year$year%in%c(eps_year$decline_episode_start_year))){
        p <- p +  geom_point(data = eps_year, aes(x = year, y = ifelse(year == decline_episode_start_year, v2xca_academ, NA)), shape = 1, alpha = 0.75)
      } else {
        p
      }
      if (any(eps_year$year%in%c(eps_year$decline_episode_end_year))){
        p<- p+ geom_point(data = eps_year, aes(x = year, y = ifelse(year == decline_episode_end_year, v2xca_academ, NA)), shape = 16, alpha = 0.75)
      } else {
        p
      }
    }
    p


  } else {
    print("No episodes during selected period.")

    polyarchy <- eps %>%
      filter(country_name == country, between(year, min(years), max(years))) %>%
      ungroup() %>%
      select(year, v2xca_academ)

    p <-ggplot2::ggplot() +
      geom_line(data = v2xca_academ, aes(x = as.numeric(year), y = v2xca_academ), alpha = 0.35) +
      scale_x_continuous(breaks = seq(round(min(years) / 10) * 10, round(max(years) / 10) * 10, 10)) +
      xlab("Year") +  ylab("Academic Freedom Index") + ylim(0,1) +
      theme_bw() +
      ggtitle(sprintf("%s", country))

    p

  }
}
