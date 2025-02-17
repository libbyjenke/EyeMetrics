#' EyeMetrics function
#' Written by Libby Jenke
#'
#' @description This function eye tracking data and calculates useful eye tracking metrics for data analysis.
#' The metrics include: number of fixations, number of returns, total fixation time (ms), and total fixation percentage for each area of interest (AOI) for each respondent and for each trial in one's eye tracking data.
#' It also yields the first fixated option for the respondent on each trial.
#' @param fixation_data A data frame containing the eye tracking data. In the data, each row should correspond to a unique fixation.
#' The data must contain the following variables: subjects' identification numbers (`subject_id`), the trial number of each fixation (`trial_number`), AOI numbers of each fixation (`aoi_num`; this should be a column that indicates which AOI each fixation was in), and the duration of each fixation (`fix_duration`).
#' @param trials Indicates the trial(s) that you want output for.
#' @return This function returns a tibble with the following columns: subject ID (`subject_id`), AOI number, number of fixations per AOI per subject (`num_fix`), total fixation time per AOI per subject (`tot_fix_time`), number of returns to each AOI per sujbect (`num_returns`), grand total of fixation time across all AOIS for each subject (`tot_fix_time_subject`), percentage of time spent on each AOI per subject (`percentage_aoi_fix_time`), and the first fixated option per subject (`first_aoi`).
#'
#' @importFrom dplyr |>
#'
#' @export
#'
EyeMetrics <- function(fixation_data, trials) {

  # Filter data for the specified trials
  trial_data <- fixation_data |>
    dplyr::filter(trials %in% trial_number)

  # Calculate number of fixations on each AOI and total fixation time for each respondent
  fix_aoi <- trial_data |>
    group_by(subject_id, aoi_num) |>
    summarise(
      num_fix = n(),
      tot_fix_time = sum(fix_duration),
      .groups = 'drop'
    )

  # Calculate number of returns to each AOI for each respondent in the specified trials
  trial_data <- trial_data |>
    group_by(subject_id) |>
    mutate(
      # Create a new column that flags when AOI changes (TRUE when it changes, FALSE when it stays the same)
      aoi_change = c(TRUE, aoi_num[-1] != aoi_num[-length(aoi_num)])
    )

  returns <- trial_data |>
    group_by(subject_id, aoi_num) |>
    summarise(
      num_returns = sum(aoi_change) - 1,  # Subtract 1 because the first occurrence isn't a return
      .groups = 'drop'
    )

  # Combine results: Join num_fix, tot_fix_time, and num_returns by subject and AOI
  fix_aoi <- fix_aoi |>
    left_join(returns, by = c("subject_id", "aoi_num"))

  # Calculate percentage of total fixation time on each AOI per subject
  fix_aoi <- fix_aoi |>
    group_by(subject_id) |>
    mutate(
      total_fix_time_subject = sum(tot_fix_time),  # total fixation time per subject
      percentage_aoi_fix_time = (tot_fix_time / total_fix_time_subject) * 100  # percentage for each AOI
    )

  # Find the first fixated AOI for each subject in the specified trials
  fixation_data <- fixation_data |>
    group_by(subject_id) |>
    mutate(first_aoi = first(aoi_num))

  fix_aoi$first_aoi <- fixation_data$first_aoi[1]

  return(fix_aoi)
}

