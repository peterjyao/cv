library("rmarkdown")
library("here")

source_dir <- list("R")
markdown_dir <- list("markdown")
output_dir <- list("output")

source(here::here(source_dir, "make_Rmd_files.R"))

rmd_files <- list.files(
  path = here::here(markdown_dir),
  pattern = "*.Rmd",
  recursive = TRUE)

rmd_files <- setdiff(rmd_files, "_template.Rmd")

invisible(
  lapply(
    here::here(markdown_dir, rmd_files),
    function(x) rmarkdown::render(x, output_dir = here::here(output_dir))
  )
)
