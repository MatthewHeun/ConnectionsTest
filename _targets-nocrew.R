
# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("tibble"), 
  # format = "qs", 
  # controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
)

# Run the R scripts in the R/ folder with your custom functions:
# tar_source()

list(
  tar_target(
    name = conns, command = parallelly::availableConnections()
  )
)
