# ==========================================================================
# Test get_episode() function
# ==========================================================================

#
# Let's test data inputs for the first argument because the rest is already
# covered by the tests. Ideally, what we would like to get as a result is
#

col_names <- c("country_name", "country_id", "country_text_id",
               "year", "codingstart", "codingend",
               "v2xca_academ", "gapstart1", "gapstart2", "gapstart3",
               "gapend1", "gapend2", "gapend3","v2xca_academ_codelow","v2xca_academ_codehigh")

new_cols <- c("country_id", "country_text_id", "country_name",
              "year", "v2xca_academ", "v2xca_academ_codelow",
              "v2xca_academ_codehigh", "increase_episode", "increase_episode_id",
              "increase_sum", "increase_episode_start_year", "increase_episode_end_year",
              "increase_episode_censored",
              "decline_episode", "decline_episode_id", "decline_sum",
              "decline_episode_start_year", "decline_episode_end_year",
              "decline_episode_censored")

df <- matrix(1:180, ncol = 15, dimnames = list(NULL, col_names))

test_that("Wrong input format", {
  expect_error(get_episode(data = NULL))
  expect_error(get_episode(data = c(1:10)))
  expect_error(get_episode(data = df))
})

df <- as.data.frame(df)
df$year <- 1898:{1898 + 11}

test_that("Variables from script are in the dataset", {
  expect_error(get_episode(data = df[, -4]))
  expect_error(get_episode(data = df[, -5]))
  expect_error(get_episode(data = df[, -6]))
  expect_error(get_episode(data = df[, -7]))
  expect_error(get_episode(data = df[, -14]))
  expect_error(get_episode(data = df[, -15]))
  expect_error(get_episode(data = df[, -16]))
  expect_error(get_episode(data = df[, -17]))
  expect_error(get_episode(data = df[, -18]))
})


rm(col_names, new_cols, df)
