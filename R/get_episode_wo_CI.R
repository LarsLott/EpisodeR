#' Get episodes of variable growth and decline episodes
#'
#' `get_episode_wo_CI` returns a data.frame identifying decline and growth episodes
#' of an index variable in which this variable systematically grow or decline in respective country-years. This function does not control for overlapping
#' confidence /uncertainty intervals as suggested by Pelke, Lars & Aurel Croissant (2021). Conceptualizing and Measuring Autocratization Episodes.
#' Swiss Political Science Review, 27 (2), 434-448. doi:10.1111/spsr.12437
#'
#' \emph{increase_episode} is an umbrella term for any movement towards more academic freedom
#' \emph{decline_episode} is an umbrella term for any movement away from academic freedom
#'
#' @param data The data based on which the episodes are identified.
#' By default the most recent vdem data set  is loaded.
#'
#' @param variable What is the index variable the dataset looks for. By default, the v2xca_academ variable is loaded.
#'
#' @param start_incl What is the minimum annual change of a variable necessary to trigger an episode? This is the absolute value of the first difference
#' in the variable required for the onset of either a decline or growth episode.
#'
#' @param cum_incl What is the minimum amount of total change on the variable necessary to constitute a manifest episode?
#' A potential episode might be a period involving any amount of changes over a period a period of four years following an annual change equal
#' to the start inclusion (e.g. 0.01). To identify substantial changes, we set a cumulative inclusion threshold.
#' This is the absolute value of the total amount of change needed on the index variable to be considered manifest.
#'
#' @param year_turn  What is the amount of annual change in the opposite direction to trigger the termination of an episode?
#' An episode may end when the case suddenly moves in the opposite direction.
#'
#' The terms @param start_incl, @param cum_incl, and @param year_turn as well as the descriptions of these terms in the function are adapted
#' from the ERT-package available at https://github.com/vdeminstitute/ERT. In the function below, all parts of code that was copied and adapted from the ERT package are tagged.
#' The original ERT package enable users to set additional parameters to customize their definitions of what constitutes an episode of change. These additional parameters are
#' the tolerance parameter, and the cum_turn parameter. In this package, episodes are considered as an episode as long as there is continued increase/decline,
#' while allowing up to 4 years of temporary stagnation. This period of 4 years cannot be set to another value of temporary stagnation (compare the more flexible ERT package).
#'
#' @return A data frame specifying episodes of growth and decline of a specific variable and their outcomes in the most recent V-Dem data set.
#' For further details and explanations on episodes and outcomes please check the respective journal article:
#' Lott, Lars (2023). Academic Freedom Growth and Decline Episodes. Higher Education. DOI: 10.1007/s10734-023-01156-z
#'
#' @import dplyr
#' @import stringr
#' @import tidyr
#' @importFrom hablar s
#' @importFrom plm make.pconsecutive
#' @export

get_episode_wo_CI <- function(data = EpisodeR::vdem,
                        start_incl = 0.01,
                        cum_incl = 0.1,
                        year_turn = 0.03,
                        variable = "v2xca_academ")
{
  tolerance = 4

  ## copied and adapted from ERT package ##

  if(year_turn == 0)
    print("You set year_turn = 0. Did you mean to do this? Doing so means an episode ends when it experiences a year of no annual change on the index variable.")


  ### DATA CLEANING AND PREP ###

  # selecting the variables we need to construct the episodes dataframe
  full.df <- data %>%
    dplyr::select(country_name, country_id, country_text_id, year,
                  codingstart, codingend, matches(variable, ignore.case = FALSE),
                  gapstart1, gapstart2, gapstart3, gapend1, gapend2, gapend3, v2x_regime) %>%
    dplyr::filter(year >= 1900) %>%
    dplyr::arrange(country_text_id, year) %>%
    dplyr::group_by(country_id) %>%
    # make codingstart 1900 or first year thereafter
    dplyr::mutate(codingstart2 = min(hablar::s(ifelse(!is.na(v2x_regime), year, NA))),
                  # tag original sample for later use
                  origsample = 1) %>%
    # we need to deal with gaps in v-dem coding
    # this balances the dataset
    plm::make.pconsecutive(balanced = TRUE, index = c("country_id", "year")) %>%
    dplyr::group_by(country_id) %>%
    # this fills missing variables we need that are constant within countries
    tidyr::fill(c(country_text_id, country_name, codingend, gapstart1, gapend1, gapstart2, gapend2,
                  gapstart3, gapend3)) %>%
    tidyr::fill(c(country_text_id, country_name,codingend, gapstart1, gapend1, gapstart2, gapend2,
                  gapstart3, gapend3), .direction = "up")  %>%
    # here we need to recode the gaps as only during the period prior to and during the gap (for our "uncertain" variables)
    dplyr::mutate(gapstart = ifelse(year <= gapend1, gapstart1, NA),
                  gapend = ifelse(year <= gapend1, gapend1, NA),
                  gapstart = ifelse(!is.na(gapend2) & year > gapend1 & year <= gapend2, gapstart2, gapstart),
                  gapend = ifelse(!is.na(gapend2) & year > gapend1 & year <= gapend2, gapend2, gapend),
                  gapstart = ifelse(!is.na(gapend3) & year > gapend2 & year <= gapend3, gapstart3, gapstart),
                  gapend = ifelse(!is.na(gapend3) & year > gapend2 & year <= gapend3, gapend3, gapend)) %>%

    ## own code by the author of this package ##

    ### CODING THE DECLINE EPISODES of Academic Freedom ###

    group_by(country_name) %>%
    mutate(VAR_1 = get(variable) - lag(get(variable), 1),
           start_auto = ifelse(VAR_1<=-start_incl, 1, NA),
           min_1 = lead(VAR_1, 1),
           min_2 = lead(VAR_1, 2),
           min_3 = lead(VAR_1, 3),
           min_4 = lead(VAR_1, 4),
           auto_end = ifelse(min_1<=-start_incl | min_2<=-start_incl | min_3<=-start_incl | min_4<=-start_incl, 0, 1),
           auto_end2 = ifelse(VAR_1>=year_turn, 1, 0))  %>%

    # start_auto = helper for start episode of X
    # auto_end  = helper for end of an episode of X
    # auto_end_2  = helper 2 for end of an episode of X

    mutate(start_auto_1 = ifelse(lag(start_auto)==1, 1, 0),
           start_auto_2 = ifelse(lag(start_auto, 2)==1, 1, 0),
           start_auto_3 = ifelse(lag(start_auto, 3)==1, 1, 0),
           start_auto_4 = ifelse(lag(start_auto, 4)==1, 1, 0),
           start_auto_four = coalesce(start_auto_1, start_auto_2, start_auto_3, start_auto_4),
           start_auto_four = ifelse(is.na(start_auto_four), 0, start_auto_four))  %>%
    dplyr::select(-c(start_auto_1, start_auto_2, start_auto_3, start_auto_4)) %>%
    dplyr::select(-c(min_1, min_2, min_3, min_4)) %>%
    fill(auto_end)


  # detect and save potential episodes with the help of the function

  full.df <- as.data.frame(full.df)
  for (i in 1:nrow(full.df)) {
    full.df[i,][is.na(full.df[i,]) & full.df$auto_end[i-1] == 0 & full.df$start_auto_four[i] == 1 & full.df$start_auto[i-1] ==1 &
                  full.df$auto_end2[i] != 1] <- 1
  }



  ## Episodes with a total magnitude of cum_incl decline  ##

  # first step: create auto_period ID
  full.df <- full.df %>%
    mutate(start_auto = ifelse(is.na(start_auto), 0, start_auto)) %>%
    group_by(country_name) %>%
    mutate(group_id = cumsum(start_auto != lag(start_auto, default = FALSE))) %>% # group_id for each autocra_period
    mutate(episode_id = str_c(country_name, group_id, sep = "_")) %>%

    # second step: create dummy in which decline was greater than Z

    group_by(episode_id) %>%
    mutate(last_VAR = last(get(variable)),
           last_VAR_codelow = last(get(paste0(variable, "_codelow"))),
           last_VAR_codehigh = last(get(paste0(variable, "_codehigh"))))%>%
    ungroup()%>%
    mutate(auto_dum = last_VAR - lag(last_VAR)) %>%
    dplyr::select(-c(group_id)) %>%
    group_by(episode_id) %>%
    mutate(decline_episode = ifelse(start_auto==1 & first(auto_dum) <= -cum_incl, 1, 0 )) %>%
    rename(decline_sum = auto_dum,
           decline_episode_id = episode_id) %>% # no overlap of confidence intervals before and after episode
    group_by(country_text_id) %>%

    # then we clean out variables for non-manifest episodes
    dplyr::mutate(decline_episode_id = ifelse(decline_episode!=1, NA, decline_episode_id)) %>%
    group_by(decline_episode_id) %>%

    ## copied and adapted from ERT package ##

    # generate the initial end year for the episode
    dplyr::mutate(decline_episode_end_year = ifelse(decline_episode==1, last(year), NA),
                  decline_episode_uncertain = ifelse(decline_episode==1 & codingend-decline_episode_end_year<tolerance, 1, 0),
                  # generate the start year for the potential episode as the first year after the pre-episode year
                  decline_episode_start_year = ifelse(decline_episode==1, first(year), NA)) %>%

    # here we code a dummy for the pre-episode year
    dplyr::mutate(var_pre_ep_year = ifelse(decline_episode==1, ifelse(year == dplyr::first(year), 1, 0), 0),

                  # we create a unique identifier for episodes using the country_text_id, start, and end years
                  decline_episode_id = ifelse(decline_episode==1, paste(country_text_id, decline_episode_start_year, decline_episode_end_year, sep = "_"), NA)) %>%

    dplyr::ungroup() %>%
    # make sure the data is sorted properly
    dplyr::arrange(country_name, year) %>%
    # just to make sure we have a dataframe
    as.data.frame %>%

    # code termination type of decline episode

    # decline episodes end when a cumulative drop happens:
    # cumulative drop: the case experiences a gradual drop <= cum_turn over the tolerance period (or less)

    # first find the last positive change on EDI equal to the start_incl parameter
    # this will become the new end of episodes at some point, once we clean things up
    dplyr::group_by(decline_episode_id) %>%
    dplyr::mutate(last_ch_year = max(hablar::s(ifelse(get(variable)-dplyr::lag(get(variable), n=1)>=start_incl, year, NA))),
                  # here we just replace with NA non-episode years
                  last_ch_year = ifelse(decline_episode==0, NA, last_ch_year))

  # merge these new columns to our full.df
  full.df <- full.df %>%
    # now we can finally code our termination variable
    # first we group by episode
    dplyr::ungroup() %>%
    dplyr::mutate(decline_episode_id = ifelse(decline_episode==1, paste(country_text_id, decline_episode_start_year, decline_episode_end_year, sep = "_"), NA),
                  decline_sum = ifelse(decline_episode!=1, NA, decline_sum),
                  decline_episode_start_year = ifelse(decline_episode!=1, NA, decline_episode_start_year),
                  decline_episode_end_year = ifelse(decline_episode!=1, NA, decline_episode_end_year)) %>%
    dplyr::group_by(country_text_id) %>%
    dplyr::arrange(country_id, year) %>%

    # code censored/ongoing episodes for survival analysis, new dummy variable
    dplyr::mutate(decline_episode_censored = ifelse(decline_episode==1 & decline_episode_uncertain == 1, 1, 0)) %>%

    ## own code by the author of this package ##

    ### CODING THE INCREASE EPISODES of Academic Freedom ###

    dplyr::group_by(country_text_id) %>%
    mutate(VAR_1 = get(variable) - lag(get(variable), 1),
           start_auto = ifelse(VAR_1>=start_incl, 1, NA),
           min_1 = lead(VAR_1, 1),
           min_2 = lead(VAR_1, 2),
           min_3 = lead(VAR_1, 3),
           min_4 = lead(VAR_1, 4),
           auto_end = ifelse(min_1>=start_incl | min_2>=start_incl | min_3>=start_incl | min_4>=start_incl, 0, 1),
           auto_end2 = ifelse(VAR_1<=-year_turn, 1, 0)) %>%

    # start_auto = helper for start episode of X
    # auto_end  = helper for end of an episode of X
    # auto_end_2  = helper 2 for end of an episode of X

    mutate(start_auto_1 = ifelse(lag(start_auto)==1, 1, 0),
           start_auto_2 = ifelse(lag(start_auto, 2)==1, 1, 0),
           start_auto_3 = ifelse(lag(start_auto, 3)==1, 1, 0),
           start_auto_4 = ifelse(lag(start_auto, 4)==1, 1, 0),
           start_auto_four = coalesce(start_auto_1, start_auto_2, start_auto_3, start_auto_4),
           start_auto_four = ifelse(is.na(start_auto_four), 0, start_auto_four))  %>%
    dplyr::select(-c(start_auto_1, start_auto_2, start_auto_3, start_auto_4)) %>%
    dplyr::select(-c(min_1, min_2, min_3, min_4)) %>%
    fill(auto_end)


  # detect and save potential episodes with the help of the function


  full.df <- as.data.frame(full.df)
  for (i in 1:nrow(full.df)) {
    full.df[i,][is.na(full.df[i,]) & full.df$auto_end[i-1] == 0 & full.df$start_auto_four[i] == 1 & full.df$start_auto[i-1] ==1 &
                  full.df$auto_end2[i] != 1] <- 1
  }


  ## Episodes with a total magnitude of cum_turn INCREASE ##

  # first step: create increase_period_id
  full.df <- full.df %>%
    mutate(start_auto = ifelse(is.na(start_auto), 0, start_auto)) %>%
    group_by(country_name) %>%
    mutate(group_id = cumsum(start_auto != lag(start_auto, default = FALSE))) %>% # group_id for each increase_episode
    mutate(episode_id = str_c(country_name, group_id, sep = "_")) %>%

    # second step: create dummy in which decline was greater than Z

    group_by(episode_id) %>%
    mutate(last_VAR = last(get(variable)),
           last_VAR_codelow = last(get(paste0(variable, "_codelow"))),
           last_VAR_codehigh = last(get(paste0(variable, "_codehigh"))))%>%
    ungroup()%>%
    mutate(auto_dum = last_VAR - lag(last_VAR)) %>%
    dplyr::select(-c(group_id)) %>%
    group_by(episode_id) %>%
    mutate(increase_episode = ifelse(start_auto==1 & first(auto_dum) >= cum_incl, 1, 0 )) %>%
    rename(increase_sum = auto_dum,
           increase_episode_id = episode_id) %>% # no overlap of confidence intervals before and after episode
    group_by(country_text_id) %>%
    mutate(lag_variable = lag(get(variable), 1)) %>%

    # then we clean out variables for non-manifest episodes
    dplyr::mutate(increase_episode_id = ifelse(increase_episode!=1, NA, increase_episode_id)) %>%
    group_by(increase_episode_id) %>%

    ## copied and adapted from ERT package ##

    # generate the initial end year for the episode
    dplyr::mutate(increase_episode_end_year = ifelse(increase_episode==1, last(year), NA),
                  increase_episode_uncertain = ifelse(increase_episode==1 & codingend-increase_episode_end_year<tolerance, 1, 0),
                  # generate the start year for the potential episode as the first year after the pre-episode year
                  increase_episode_start_year = ifelse(increase_episode==1, first(year), NA)) %>%

    # here we code a dummy for the pre-episode year
    dplyr::mutate(variable_pre_ep_year_increase = ifelse(increase_episode==1, ifelse(year == dplyr::first(year), 1, 0), 0),

    # we create a unique identifier for episodes using the country_text_id, start, and end years
    increase_episode_id = ifelse(increase_episode==1, paste(country_text_id, increase_episode_start_year, increase_episode_end_year, sep = "_"), NA)) %>%

    dplyr::ungroup() %>%
    # make sure the data is sorted properly
    dplyr::arrange(country_name, year) %>%
    # just to make sure we have a dataframe
    as.data.frame %>%

    # code termination type of decline episode

    # decline episodes end when a cumulautive drop things happens:
    # 1. cumulative drop: the case experiences a gradual drop <= cum_turn over the tolerance period (or less)

    # first find the last positive change on EDI equal to the start_incl parameter
    # this will become the new end of episodes at some point, once we clean things up
    dplyr::group_by(increase_episode_id) %>%
    dplyr::mutate(last_ch_year = max(hablar::s(ifelse(get(variable)-dplyr::lag(get(variable), n=1)>=start_incl, year, NA))),
                  # here we just replace with NA non-episode years
                  last_ch_year = ifelse(increase_episode==0, NA, last_ch_year)) %>%

    # code censored/ongoing episodes for survival analysis, new dummy variable
    dplyr::mutate(increase_episode_censored = ifelse(increase_episode==1 & increase_episode_uncertain == 1, 1, 0))

    ## own code by the author of this package ##

    # merge these new columns to our full.df
  full.df <- full.df %>%

    dplyr::group_by(increase_episode_id) %>%
    dplyr::arrange(increase_episode_id, year) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(increase_episode_id = ifelse(increase_episode==1, paste(country_text_id, increase_episode_start_year, increase_episode_end_year, sep = "_"), NA),
                  increase_sum = ifelse(increase_episode!=1, NA, increase_sum),
                  increase_episode_start_year = ifelse(increase_episode!=1, NA, increase_episode_start_year),
                  increase_episode_end_year = ifelse(increase_episode!=1, NA, increase_episode_end_year),
                  increase_episode_censored = ifelse(increase_episode!=1, NA, increase_episode_censored),
                  decline_episode_id = ifelse(decline_episode!=1, NA, decline_episode_id),
                  decline_sum = ifelse(decline_episode!=1, NA, decline_sum),
                  decline_episode_start_year = ifelse(decline_episode!=1, NA, decline_episode_start_year),
                  decline_episode_end_year = ifelse(decline_episode!=1, NA, decline_episode_end_year),
                  decline_episode_censored = ifelse(decline_episode!=1, NA, decline_episode_censored)) %>%

    dplyr::group_by(country_text_id) %>%
    dplyr::arrange(country_id, year) %>%

    dplyr::filter(!is.na(origsample)) %>%
    dplyr::select(country_id, country_text_id, country_name, variable, paste0(variable, "_codelow"), paste0(variable, "_codehigh"), year,
                  increase_episode, increase_episode_id, increase_sum, increase_episode_start_year, increase_episode_end_year,
                  increase_episode_censored,
                  decline_episode, decline_episode_id, decline_sum, decline_episode_start_year, decline_episode_end_year,
                  decline_episode_censored) %>%
    ungroup()


  {
    return(full.df)
    }
}

