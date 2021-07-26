library("here")

data_dir <- list("data")
markdown_dir <- list("markdown")

# get personal info for yaml header ####

my_dat <- read.csv(here::here(data_dir, "header.csv"))
my_dat$yaml_fields <- paste0(my_dat$parameter, ": \"", my_dat$value, "\"")
my_yaml <- paste(c('---', my_dat$yaml_fields), collapse = "\n")

# hack to make output formats for yaml header ####

formats_df <- data.frame(
  name = c(
    "awesomecv", "hyndman", "latexcv", rep("moderncv", 3), "twentyseconds", 
    rep("markdowncv", 3)),
  theme = c("", "", "classic", "banking", "casual", "classic", "",
            "blmoore", "davewhipp", "kjhealy"),
  type = c(rep("pdf", 7), rep("html", 3))
)

process_name <- function(name, theme, type) {
  if (type == "pdf") {
    if (theme == "") {
      pdf_name <- paste0("vitae::", name, ":")
    } else {
      pdf_name <- paste0("vitae::", name, ":\n    theme: ", theme)
    }
    return(paste0(pdf_name, "\n    keep_tex: true"))
  }
  else {
    return(paste0("vitae::", name, ":\n    theme: ", theme))
  }
}

formats_df$yaml_output <- with(
  formats_df,
  mapply(process_name, name, theme, type, SIMPLIFY = TRUE, USE.NAMES = FALSE)
  )

# Rmd content to be added ####

rmd_template <- paste(
  readLines(
    here::here(markdown_dir, "_template.Rmd")), 
  collapse = "\n")

# write Rmd files ####

invisible(
  with(
    formats_df,
    mapply(
      function(name, theme, type, yaml_output) {
        rmd_content <- paste0(
          my_yaml,
          "\noutput:\n  ",
          yaml_output,
          '\n---\n\n',
          rmd_template)
        
        if (type == "html") {
          rmd_content <- gsub("# ", "## ", rmd_content)
        }

        if (name == "twentyseconds") {
          rmd_content <- gsub("name: \"Peter\"", "name: \"Peter YAO\"", rmd_content)
          rmd_content <- gsub("surname:", "unused_surname:", rmd_content)
        }
        
        if (name == "moderncv" | name == "latexcv") {
          rmd_content <- gsub("profilepic", "unused_profilepic", rmd_content)
        }

        if (name == "moderncv" | name == "latexcv") {
          rmd_content <- gsub("aboutme:", "unused_aboutme:", rmd_content)
        }
        
        if (!name == "latexcv") {
          rmd_content <- gsub("twitter:", "unused_twitter:", rmd_content)
        }        

        if (!name == "latexcv") {
          rmd_content <- gsub("github:", "unused_github:", rmd_content)
        }
        
        if ((name == "moderncv" & !theme == "casual") | name == "latexcv") {
          rmd_content <- gsub("bibliography.bib", "bibliography-notitles.bib", rmd_content)
        }
        
        rmd_content <- gsub("position:", "unused_position:", rmd_content)
        
        cat(rmd_content,
            file = here::here(markdown_dir, 
                              name, 
                              paste0(name, theme, ".Rmd")
                              )
            )
        },
      name, theme, type, yaml_output,
      SIMPLIFY = TRUE, USE.NAMES = FALSE)
  )
)
