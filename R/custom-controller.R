
message('processing custom controller code')

custom_launcher_class <- R6::R6Class(
  classname = "custom_launcher_class",
  inherit = crew::crew_class_launcher,
  public = list(
    launch_worker = function(call, name, launcher, worker, instance) {
      bin <- file.path(R.home("bin"), "R")
      processx::process$new(
        command = bin,
        args = c("--max-connections=333", "-e", call),
        cleanup = FALSE
      )
    },
    terminate_worker = function(handle) {
      handle$signal(crew::crew_terminate_signal())
    }
  )
)

#' @title Create a controller with the custom launcher.
#' @export
#' @description Create an `R6` object to submit tasks and
#'   launch workers.
#' @inheritParams crew::crew_controller_local
crew_controller_custom <- function(
    name = "custom controller name",
    workers = 1L,
    host = NULL,
    port = NULL,
    tls = crew::crew_tls(),
    seconds_interval = 0.5,
    seconds_timeout = 30,
    seconds_launch = 30,
    seconds_idle = Inf,
    seconds_wall = Inf,
    retry_tasks = TRUE,
    tasks_max = Inf,
    tasks_timers = 0L,
    reset_globals = TRUE,
    reset_packages = FALSE,
    reset_options = FALSE,
    garbage_collection = FALSE,
    launch_max = 5L
) {
  client <- crew::crew_client(
    name = name,
    workers = workers,
    host = host,
    port = port,
    tls = tls,
    seconds_interval = seconds_interval,
    seconds_timeout = seconds_timeout,
    retry_tasks = retry_tasks
  )
  launcher <- custom_launcher_class$new(
    name = name,
    seconds_interval = seconds_interval,
    seconds_timeout = seconds_timeout,
    seconds_launch = seconds_launch,
    seconds_idle = seconds_idle,
    seconds_wall = seconds_wall,
    tasks_max = tasks_max,
    tasks_timers = tasks_timers,
    reset_globals = reset_globals,
    reset_packages = reset_packages,
    reset_options = reset_options,
    garbage_collection = garbage_collection,
    launch_max = launch_max,
    tls = tls
  )
  controller <- crew::crew_controller(client = client, launcher = launcher)
  controller$validate()
  controller
}

