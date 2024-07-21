---
title: targets and crew::crew_launcher_local()
format: html
execute:
  echo: fenced
  message: false
  warrning: false
keep-md: true
embed-resources: true
---



This example contains three targets files 

* `targets-nocrew.R`,
* `targets-crew.R`, and 
* `targets-crew-custom.R`

The differ only in what controller is used.

For example, in `_targets-crew.R`, we have

```r
controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
```

But in `_targets-crew-custom.R`, we have

```r
controller = crew_controller_custom(workers = 2, seconds_idle = 60)
```

(See below for the definition of the custom controller.)

#### _targets-crew.R

```r
# _targets-crew.R
library(targets)

# Set target options:
tar_option_set(
  packages = c("tibble"), 
  controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
)

list(
  tar_target(
    name = conns, command = parallelly::availableConnections()
  )
)
```


::: {.cell}

````{.cell-code}
```{{r}}
#| label: setup
library(targets)
```
````
:::


## Without `crew::crew_controller_local()`


::: {.cell}

````{.cell-code}
```{{r}}
#| results: hide
tar_destroy()
tar_make(
  script = "_targets-nocrew.R"
)
```
````
:::

::: {.cell}

````{.cell-code}
```{{r}}
targets::tar_read(conns)
```
````

::: {.cell-output .cell-output-stdout}

```
[1] 128
```


:::
:::

::: {.cell}

````{.cell-code}
```{{r}}
#| results: hide
tar_destroy()
tar_make(
  script = "_targets-nocrew.R",
  callr_arguments = list(
    'cmdargs' = c("--save", "--no-save", "--no-restore", "--max-connections=400")
  )
)
```
````
:::

::: {.cell}

````{.cell-code}
```{{r}}
targets::tar_read(conns)
```
````

::: {.cell-output .cell-output-stdout}

```
[1] 400
```


:::
:::


## With `crew::crew_controller_local()`


::: {.cell}

````{.cell-code}
```{{r}}
#| results: hide
tar_destroy()
tar_make(
  script = "_targets-crew.R"
)
```
````
:::

::: {.cell}

````{.cell-code}
```{{r}}
targets::tar_read(conns)
```
````

::: {.cell-output .cell-output-stdout}

```
[1] 128
```


:::
:::

::: {.cell}

````{.cell-code}
```{{r}}
#| results: hide
tar_destroy()
tar_make(
  script = "_targets-crew.R",
  callr_arguments = list(
    'cmdargs' = c("--save", "--no-save", "--no-restore", "--max-connections=400")
  )
)
```
````
:::

::: {.cell}

````{.cell-code}
```{{r}}
targets::tar_read(conns)
```
````

::: {.cell-output .cell-output-stdout}

```
[1] 128
```


:::
:::


## Issue

It doesn't appear that `crew::crew_controller_local()` allows for passing arguments to the 
R process that it launches.  So a custom controller can be created.
See <https://wlandau.github.io/crew/articles/plugins.html#example>

### Custom launcher & controller

These are in `R/custom-controller.R`


::: {.cell}

````{.cell-code}
```{{r}}
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
```
````
:::

::: {.cell}

````{.cell-code}
```{{r}}
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
```
````
:::

::: {.cell}

````{.cell-code}
```{{r}}
#| results: hide
tar_destroy()
tar_make(
  script = "_targets-crew-custom.R"
)
```
````
:::

::: {.cell}

````{.cell-code}
```{{r}}
targets::tar_read(conns)
```
````

::: {.cell-output .cell-output-stdout}

```
[1] 333
```


:::
:::

::: {.cell}

````{.cell-code}
```{{r}}
#| results: hide
tar_destroy()
tar_make(
  script = "_targets-crew-custom.R",
  callr_arguments = list(
    'cmdargs' = c("--save", "--no-save", "--no-restore", "--max-connections=400")
  )
  
)
```
````
:::