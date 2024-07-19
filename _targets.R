# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("tibble"), # Packages that your targets need for their tasks.
  # format = "qs", # Optionally set the default storage format. qs is fast.
  #
  # Pipelines that take a long time to run may benefit from
  # optional distributed computing. To use this capability
  # in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller that scales up to a maximum of two workers
  # which run as local R processes. Each worker launches when there is work
  # to do and exits if 60 seconds pass with no tasks to run.
  #
  controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
  #
  # Alternatively, if you want workers to run on a high-performance computing
  # cluster, select a controller from the {crew.cluster} package.
  # For the cloud, see plugin packages like {crew.aws.batch}.
  # The following example is a controller for Sun Grid Engine (SGE).
  # 
  #   controller = crew.cluster::crew_controller_sge(
  #     # Number of workers that the pipeline can scale up to:
  #     workers = 10,
  #     # It is recommended to set an idle time so workers can shut themselves
  #     # down if they are not running tasks.
  #     seconds_idle = 120,
  #     # Many clusters install R as an environment module, and you can load it
  #     # with the script_lines argument. To select a specific verison of R,
  #     # you may need to include a version string, e.g. "module load R/4.3.2".
  #     # Check with your system administrator if you are unsure.
  #     script_lines = "module load R"
  #   )
  #
  # Set other options as needed.
)

# Run the R scripts in the R/ folder with your custom functions:
# tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.


# # Run with the following in the RStudio console:
# parallelly::availableConnections()
# # The answer is 128.
# targets::tar_make() # To run the targets pipeline.
# # Check the answer
# targets::tar_read(conns) # To read the answer.
# # At the RStudio console, the answer is 128.

# # Try from the command line in Terminal
# # Start a new R process with 512 connections.
# mkh2@Mac56347 ConnectionsTest % R --max-connections=512
# # Now type
# parallelly::availableConnections()
# # The answer is 512, as expected.
# # Now type
# targets::tar_destroy() # To destroy the targets cache.
# targets::tar_make()
# targets::tar_read(conns)
# # The answer should be 512, but I get 128.
# # That's because targets starts a new process 
# # in which it runs the pipeline.

# # To get around the new process issue, we can 
# # invoke tar_make() in another way.
# # See https://docs.ropensci.org/targets/reference/tar_make.html
# # for a discussion that says 
# # "Set [callr_function] to NULL 
# #  to run in the current session instead of an external process".
# targets::tar_destroy()
# targets::tar_make(callr_function = NULL)
# targets::tar_read(conns)
# # Now, I get 512, as expected.

# # Try to run in parallel mode by uncommenting the "controller = " line above.
# # targets should create 2 "runners" and execute the pipeline 
# # on one of the runners.
# targets::tar_destroy()
# targets::tar_make(callr_function = NULL)
# targets::tar_read(conns)
# # Answer is 128.
# So it appears that the new (parallel) processes
# do not inherit the number of connections from 
# the parent process.
# Instead, the new (parallel) processes 
# use the default 128 connections.

# Replace the target list below with your own:
list(
  tar_target(
    name = conns, 
    # See https://search.r-project.org/CRAN/refmans/parallelly/html/availableConnections.html
    command = parallelly::availableConnections()
  )
)
