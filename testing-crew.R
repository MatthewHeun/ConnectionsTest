library(targets)
targets_script = "_targets-crew-custom.R"

cat(paste0(
  "available connections in global environment: ", 
  parallelly::availableConnections(),
  "\n\n"
))

tar_destroy()
tar_make(
  script = targets_script,
  callr_arguments = list(
    'cmdargs' = c("--save", "--no-save", "--no-restore", "--max-connections=400")
  )
)

cat(paste0(
  "available connections (using callr_arguments, and custom controller): ", 
  targets::tar_read(conns),
  "\n\n"
))