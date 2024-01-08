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
#' @param variable What is the index variable the dataset looks for. By default, the v2xca_academ variable is loaded.
#'
#' @param var_label What is the variable label that should be plotted? By default, the label is "Academic Freedom Index".
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
#' The terms @param country, @param years, @param start_incl, @param cum_incl, and @param year_turn as well as the descriptions of these terms in the function are adapted
#' from the ERT-package available at https://github.com/vdeminstitute/ERT. In the function below, all parts of code that was copied and adapted from the ERT package are tagged.
#' The original ERT package enable users to set additional parameters to customize their definitions of what constitutes an episode of change. These additional parameters are
#' the tolerance parameter, and the cum_turn parameter. In this package, episodes are considered as an episode as long as there is continued increase/decline,
#' while allowing up to 4 years of temporary stagnation. This period of 4 years cannot be set to another value of temporary stagnation (compare the more flexible ERT package).

#' @return The output of this function is a ggplot() object with the number/share of autocratization episodes per year.
#'
#' @import ggplot2
#' @import dplyr
#' @import tidyr
#'
#' @export
plot_episodes <- function(years = c(1900, 2022),
                          country = c("Sweden"),
                          start_incl  = 0.01,
                          cum_incl  = 0.1,
                          year_turn = 0.03,
                          variable = "v2xca_academ",
                          var_label = "Academic Freedom Index") {

  df <-  EpisodeR::get_episode_wo_CI(data = EpisodeR::vdem,
                                      start_incl = start_incl,
                                      cum_incl = cum_incl,
                                      year_turn = year_turn,
                                      variable = variable)

  ## copied and adapted from ERT package ##

  df <- df %>%
    dplyr::group_by(country_id) %>%
    mutate(increase_episode = ifelse(lead(increase_episode == 1), 1, increase_episode),
           decline_episode = ifelse(lead(decline_episode == 1), 1, decline_episode))

  stopifnot(is.numeric(years), length(years) == 2, years[2] > years[1])

  stopifnot(is.character(country))

  if(length(country) > 1)
    stop("Error: More than one country selected")

  if(length(country) == 0)
    stop("Error: No country selected")

  if(!country %in% df$country_name)
    stop("Error: Country not found")

  if(max(years) < min(df %>% filter(country_name==country) %>% pull(year)) | max(years)>max(df %>% filter(country_name==country) %>% pull(year)))
    stop("Error: Data not available for time range")

  year <- country_name <- increase_episode <- decline_episode <- overlap_df <-
    ep_type <- episode <- vdem <- increase_episode_start_year <-increase_episode_end_year <-
    decline_episode_start_year <- decline_episode_end_year <- decline_episode_id <- increase_episode_id <- countries <- NULL

  df_year <- df %>%
    dplyr::filter(country_name == country, dplyr::between(year, min(years), max(years))) %>%
    dplyr::filter(increase_episode == 1 | decline_episode == 1)

  if(nrow(df_year)>1){
    df_year <- df_year %>%
      dplyr::mutate(overlap_df = ifelse(!is.na(decline_episode_id) & !is.na(increase_episode_id), "overlaps", NA)) %>%
      tidyr::pivot_longer(cols = c(decline_episode_id, increase_episode_id, overlap_df), names_to = "ep_type", values_to = "episode") %>%
      dplyr::select(country_name, year, all_of(variable), ep_type, episode,
                    decline_episode_start_year, decline_episode_end_year,
                    increase_episode_start_year, increase_episode_end_year) %>%
      dplyr::filter((ep_type == "increase_episode_id") |
                      (ep_type == "decline_episode_id") |
                      ep_type == "overlaps") %>%
      drop_na(episode) %>%
      group_by(year) %>%
      mutate(overlap_df = n(),
             episode_id = ifelse(ep_type == "decline_episode_id", paste0("Decline: ", decline_episode_start_year, "-", decline_episode_end_year), episode),
             episode_id = ifelse(ep_type == "increase_episode_id", paste0("Growth: ", increase_episode_start_year, "-", increase_episode_end_year), episode_id)) %>%
      ungroup()

    df_var <- df %>%
      filter(country_name == country, between(year, min(years), max(years))) %>%
      ungroup() %>%
      select(year, all_of(variable))

    if(max(df_year$overlap_df) > 1) {
      print("Warning: Some episodes overlap!")
    }

    p <-   ggplot2::ggplot() +
      geom_line(data = df_year, aes(group = episode_id, color = episode_id, linetype = ep_type,x = year, y = get(variable))) +
      geom_line(data = df_var, aes(x = year, y = get(variable)), alpha = 0.35) +
      scale_colour_grey(breaks = levels(factor(df_year$episode_id[df_year$episode_id!="overlaps"])),
                        name = "Episode", start = 0.01, end = 0.01) +
      scale_linetype_manual(name = "Episode type", breaks = c("decline_episode_id", "increase_episode_id", "overlaps"),
                            labels = c("Decline", "Growth", "Overlap"),
                            values = c("dashed", "dotted", "solid")) +
      scale_x_continuous(breaks = seq(round(min(years) / 10) * 10, round(max(years) / 10) * 10, 10)) +
      xlab("Year") +  ylab(paste0(var_label)) + ylim(0,1) +
      theme_bw() +
      guides(color = guide_legend(override.aes = list(size = 0))) +
      ggtitle(sprintf("%s", country))

    if (isTRUE(length(which(df_year$ep_type == "increase_episode_id")) > 0)){

      if (any(df_year$year%in%c(df_year$increase_episode_start_year))) {
        p <- p +  geom_point(data = df_year, aes(x = year, y = ifelse(year == increase_episode_start_year, get(variable), NA)), shape = 2, alpha = 0.75)

      } else {
        p
      }

      if (any(df_year$year%in%c(df_year$increase_episode_end_year))) {
        p <- p +geom_point(data = df_year, aes(x = year, y = ifelse(year == increase_episode_end_year, get(variable), NA)), shape = 17, alpha = 0.75)
      } else {
        p
      }
    }

    if (isTRUE(length(which(df_year$ep_type == "decline_episode_id")) > 0)) {

      if (any(df_year$year%in%c(df_year$decline_episode_start_year))){
        p <- p +  geom_point(data = df_year, aes(x = year, y = ifelse(year == decline_episode_start_year, get(variable), NA)), shape = 1, alpha = 0.75)
      } else {
        p
      }
      if (any(df_year$year%in%c(df_year$decline_episode_end_year))){
        p<- p+ geom_point(data = df_year, aes(x = year, y = ifelse(year == decline_episode_end_year, get(variable), NA)), shape = 16, alpha = 0.75)
      } else {
        p
      }
    }
    p


  } else {
    print("No episodes during selected period.")

    df_select <- df %>%
      filter(country_name == country, between(year, min(years), max(years))) %>%
      ungroup() %>%
      select(year, all_of(variable))

    p <-ggplot2::ggplot() +
      geom_line(data = df_select, aes(x = as.numeric(year), y = get(variable)), alpha = 0.35) +
      scale_x_continuous(breaks = seq(round(min(years) / 10) * 10, round(max(years) / 10) * 10, 10)) +
      xlab("Year") +  ylab(paste0(var_label)) + ylim(0,1) +
      theme_bw() +
      ggtitle(sprintf("%s", country))

    p

  }
}
