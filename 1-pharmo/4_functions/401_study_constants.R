
# lookback window
const$lookback_window <- 365

# permissible gap options in days
const$permissible_gaps <- c(7, 
                            10, 
                            14, 
                            30)

# allowed gap between prescription and diagnosis
const$gap_between_Rx_and_Dx <- 7
const$time_from_dx_to_rx <- 7

# main outcome = number of prescriptions per #(units) person-years
const$units <- 10000

# alpha options for the study
alpha <- 0.05

# calculated z value
const$z <- qnorm(1 - alpha/2)

rm(alpha)

# what count per cell has to be reached for inclusion in analysis
const$min_num_required <- 5
