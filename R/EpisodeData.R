data(vdem)

episode_without_uncertainty_interval_test <- get_episode_wo_CI()

episode_with_uncertainty_interval_test <- get_episode()

# Fix some data types
episode_without_uncertainty_interval_test$country_id <- as.integer(episode_without_uncertainty_interval_test$country_id)
episode_without_uncertainty_interval_test$year <- as.integer(episode_without_uncertainty_interval_test$year)

# Fix some data types
episode_with_uncertainty_interval_test$country_id <- as.integer(episode_with_uncertainty_interval_test$country_id)
episode_with_uncertainty_interval_test$year <- as.integer(episode_with_uncertainty_interval_test$year)

usethis::use_data(episode_without_uncertainty_interval_test, overwrite = TRUE)
usethis::use_data(episode_with_uncertainty_interval_test, overwrite = TRUE)

write.csv(episode_with_uncertainty_interval_test, "inst/episode_with_uncertainty_interval_test.csv")
write.csv(episode_without_uncertainty_interval_test, "inst/episode_without_uncertainty_interval_test.csv")
