
<!-- README.md is generated from README.Rmd. Please edit that file -->

# EyeMetrics

<!-- badges: start -->
<!-- badges: end -->

**EyeMetrics** is an R package that provides metrics for eye tracking
data analyses. Specifically, the package outputs number of fixations,
number of returns, total fixation time (ms), and total fixation
percentage for each area of interest (AOI) for each respondent and for
each trial in one’s eye tracking data. It also yields the first fixated
option for the respondent on each trial.

## Installation

To install the development version from GitHub, use the following
command:

``` r
devtools::install_github("libbyjenke/EyeMetrics")
```

Once installed, load the package using:

``` r
library(EyeMetrics)
library(png)
library(dplyr)
```

## Basic Usage Example

This example comes from Jenke & Sullivan (forthcoming, *Political
Analysis*). We will use the data, **sample_data**, which is in the
package.

The data contain eye tracking data for three participants on one
stimulus screen.

``` r
data(sample_data, package="EyeMetrics")
fixation_data <- sample_data
```

The function has two parameters: fixation_data and trials.

**fixation_data**: This is the eyetracking data, which can be exported
directly from the eye tracking software. In the data, each row should
correspond to a unique fixation. The data must contain the following
variables: subjects’ identification numbers (`subject_id`), the trial
number of each fixation (`trial_number`), AOI numbers of each fixation
(`aoi_num`; this should be a column that indicates which AOI each
fixation was in), and the duration of each fixation (`fix_duration`).

**trial_number**: Indicate which trials you want to calculate metrics
for.

First, set up the data. I rename the variables, define the trial of
interest, and get rid of any NAs for aoi numbers (this may or may not be
the case in your data).

``` r

#Rename variables
fixation_data <- fixation_data |>
  rename(
    subject_id = Respondent.Name,
    aoi_num = AOI.Label,
    fix_duration = Fixation.Duration,
    trials = trial_num
  )
#Make sure that trials is numeric
fixation_data$trials <- as.numeric(fixation_data$trials)

#Define trial number(s) that you want to examine
trial_number <- 1

#Get rid of any 0s for AOI numbers
fixation_data <- fixation_data[!is.na(fixation_data$aoi_num),]


#Now, call the package.
EyeMetrics(fixation_data, trial_number) 
#> # A tibble: 15 × 8
#> # Groups:   subject_id [3]
#>    subject_id aoi_num num_fix tot_fix_time num_returns total_fix_time_subject
#>         <int> <chr>     <int>        <dbl>       <dbl>                  <dbl>
#>  1          1 AOI 1        11        2586.           2                 14014.
#>  2          1 AOI 2         4        1869.           3                 14014.
#>  3          1 AOI 3         4        2117.           2                 14014.
#>  4          1 AOI 4         9        4889.           2                 14014.
#>  5          1 AOI 5         9        2553.           1                 14014.
#>  6          2 AOI 1         3        1089.           0                 13457.
#>  7          2 AOI 2         4        2865.           2                 13457.
#>  8          2 AOI 3         2        2535.           1                 13457.
#>  9          2 AOI 4         5        3328.           1                 13457.
#> 10          2 AOI 5         7        3640.           1                 13457.
#> 11          3 AOI 1         8        2607.           1                 11542.
#> 12          3 AOI 2         4        2091.           3                 11542.
#> 13          3 AOI 3         3        1688.           2                 11542.
#> 14          3 AOI 4         3        3369.           1                 11542.
#> 15          3 AOI 5         6        1788.           0                 11542.
#> # ℹ 2 more variables: percentage_aoi_fix_time <dbl>, first_aoi <chr>
```

## Output

You should see a tibble with the following columns: subject ID
(`subject_id`), AOI number, number of fixations per AOI per subject
(`num_fix`), total fixation time per AOI per subject (`tot_fix_time`),
number of returns to each AOI per subject (`num_returns`), grand total
of fixation time across all AOIS for each subject
(`tot_fix_time_subject`), percentage of time spent on each AOI per
subject (`percentage_aoi_fix_time`), and the first fixated option per
subject (`first_aoi`).
