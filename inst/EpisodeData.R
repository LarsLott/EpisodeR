#' `episode_without_uncertainty_interval` is the data.frame with the default parameters without controlling for uncertainty intervals
#' `episode_with_uncertainty_interval` is the data.frame with the default parameters controlling for uncertainty intervals

data(vdem)

episode_without_uncertainty_interval <- EpisodeR::get_episode_wo_CI()

episode_with_uncertainty_interval <- EpisodeR::get_episode()

# Fix some data types
episode_without_uncertainty_interval$country_id <- as.integer(episode_without_uncertainty_interval$country_id)
episode_without_uncertainty_interval$year <- as.integer(episode_without_uncertainty_interval$year)

# Fix some data types
episode_with_uncertainty_interval$country_id <- as.integer(episode_with_uncertainty_interval$country_id)
episode_with_uncertainty_interval$year <- as.integer(episode_with_uncertainty_interval$year)

usethis::use_data(episode_without_uncertainty_interval, overwrite = TRUE)
usethis::use_data(episode_with_uncertainty_interval, overwrite = TRUE)

write.csv(episode_with_uncertainty_interval, "inst/episode_with_uncertainty_interval.csv")
write.csv(episode_without_uncertainty_interval, "inst/episode_without_uncertainty_interval.csv")
