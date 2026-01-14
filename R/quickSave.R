#' Quick Save Plot to PDF
#'
#' Save a ggplot or base R plot to PDF with automatic path management.
#'
#' @param plot A ggplot object or plot to save
#' @param filename Filename to save (with or without extension)
#' @param savedir Directory to save the file
#' @param width Plot width in inches (default: 4)
#' @param height Plot height in inches (default: 4)
#' @param verbose Print saved path (default: TRUE)
#'
#' @return Invisible NULL
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' library(quickSave)
#'
#' p <- ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()
#' qsave(p, "scatter.pdf", "./results")
#' }
#'
#' @export
qsave <- function(plot, filename, savedir, width = 4, height = 4, verbose = TRUE) {
  
  # 确保文件名有正确的扩展名
  if (!grepl("\\.pdf$", filename, ignore.case = TRUE)) {
    filename <- paste0(tools::file_path_sans_ext(filename), ".pdf")
  }
  
  filepath <- file.path(savedir, filename)
  
  # 创建目录（如果不存在）
  if (!dir.exists(savedir)) {
    dir.create(savedir, recursive = TRUE, showWarnings = FALSE)
  }
  
  # 保存为 PDF
  ggplot2::ggsave(
    filepath,
    plot = plot,
    width = width,
    height = height,
    device = "pdf"
  )
  
  if (verbose) {
    cat("✓ Saved:", filepath, "\n")
  }
  
  invisible(NULL)
}


#' Quick Save Plot to Multiple Formats
#'
#' Save a plot to multiple formats (PDF, PNG, JPG, etc.) in one call.
#'
#' @param plot A ggplot object
#' @param filename Filename to save (without extension, or with extension)
#' @param savedir Directory to save the files
#' @param formats Vector of formats to save (default: c("pdf", "png"))
#'        Options: "pdf", "png", "jpg", "jpeg", "tiff"
#' @param width Plot width in inches (default: 4)
#' @param height Plot height in inches (default: 4)
#' @param dpi Resolution for raster formats (default: 300)
#' @param verbose Print saved paths (default: TRUE)
#'
#' @return Invisible NULL
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' library(quickSave)
#'
#' p <- ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()
#' qsave_multi(p, "scatter", "./results", formats = c("pdf", "png"))
#' }
#'
#' @export
qsave_multi <- function(plot, filename, savedir, formats = c("pdf", "png"),
                        width = 4, height = 4, dpi = 300, verbose = TRUE) {
  
  # 移除可能的扩展名
  base_name <- tools::file_path_sans_ext(filename)
  
  # 创建目录
  if (!dir.exists(savedir)) {
    dir.create(savedir, recursive = TRUE, showWarnings = FALSE)
  }
  
  # 保存为多种格式
  for (fmt in formats) {
    filepath <- file.path(savedir, paste0(base_name, ".", fmt))
    
    ggplot2::ggsave(
      filepath,
      plot = plot,
      width = width,
      height = height,
      dpi = dpi,
      device = fmt
    )
    
    if (verbose) {
      cat("✓ Saved:", filepath, "\n")
    }
  }
  
  invisible(NULL)
}


#' Batch Save Multiple Plots
#'
#' Save a list of plots to a directory with automatic numbering.
#'
#' @param plots List of ggplot objects (named or unnamed)
#' @param savedir Directory to save the files
#' @param prefix Prefix for filenames (default: "plot")
#' @param format Format to save (default: "pdf")
#' @param width Plot width (default: 4)
#' @param height Plot height (default: 4)
#' @param dpi Resolution for raster formats (default: 300)
#' @param verbose Print saved paths (default: TRUE)
#'
#' @return Invisible list of saved filepaths
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' library(quickSave)
#'
#' plots <- list(
#'   scatter = ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point(),
#'   boxplot = ggplot(mtcars, aes(x = factor(cyl), y = mpg)) + geom_boxplot()
#' )
#'
#' qbatch_save(plots, "./results", prefix = "fig")
#' }
#'
#' @export
qbatch_save <- function(plots, savedir, prefix = "plot", format = "pdf",
                        width = 4, height = 4, dpi = 300, verbose = TRUE) {
  
  # 创建目录
  if (!dir.exists(savedir)) {
    dir.create(savedir, recursive = TRUE, showWarnings = FALSE)
  }
  
  saved_files <- character(length(plots))
  
  for (i in seq_along(plots)) {
    # 生成文件名
    plot_name <- names(plots)[i]
    if (is.null(plot_name) || plot_name == "") {
      plot_name <- sprintf("%02d.plot", i)
    } else {
      plot_name <- sprintf("%02d.%s", i, plot_name)
    }
    
    filename <- paste0(plot_name, ".", format)
    filepath <- file.path(savedir, filename)
    
    # 保存图
    ggplot2::ggsave(
      filepath,
      plot = plots[[i]],
      width = width,
      height = height,
      dpi = dpi,
      device = format
    )
    
    saved_files[i] <- filepath
    
    if (verbose) {
      cat("✓ Saved:", filepath, "\n")
    }
  }
  
  invisible(saved_files)
}


#' Create a Plot Saver Object
#'
#' Create a PlotSaver object for convenient plot saving with automatic numbering.
#'
#' @param savedir Directory to save plots
#' @param prefix Prefix for filenames (default: "plot")
#' @param format Default format to save (default: "pdf")
#'
#' @return A PlotSaver R6 object with the following methods:
#'   - save(plot, filename = NULL, ...): Save a single plot
#'   - reset(): Reset the counter
#'   - get_dir(): Get the save directory
#'   - get_count(): Get the current counter
#'
#' @examples
#' \dontrun{
#' library(quickSave)
#'
#' saver <- plot_saver("./results")
#' saver$save(plot1, "dimplot.pdf")
#' saver$save(plot2)  # Auto-numbered as 02.plot.pdf
#' }
#'
#' @export
plot_saver <- function(savedir, prefix = "plot", format = "pdf") {
  
  PlotSaver$new(savedir = savedir, prefix = prefix, format = format)
}


#' @keywords internal
PlotSaver <- R6::R6Class(
  "PlotSaver",
  public = list(
    savedir = NULL,
    prefix = NULL,
    format = NULL,
    counter = 0,

    initialize = function(savedir, prefix = "plot", format = "pdf") {
      self$savedir <- savedir
      self$prefix <- prefix
      self$format <- format
      self$counter <- 0

      if (!dir.exists(savedir)) {
        dir.create(savedir, recursive = TRUE, showWarnings = FALSE)
      }
    },

    save = function(plot, filename = NULL, width = 4, height = 4, dpi = 300) {
      self$counter <- self$counter + 1

      if (is.null(filename)) {
        filename <- sprintf("%02d.%s.%s", self$counter, self$prefix, self$format)
      }

      filepath <- file.path(self$savedir, filename)

      ggplot2::ggsave(
        filepath,
        plot = plot,
        width = width,
        height = height,
        dpi = dpi,
        device = self$format
      )

      cat("✓ [", sprintf("%02d", self$counter), "]", filepath, "\n")
      invisible(filepath)
    },

    reset = function() {
      self$counter <- 0
      cat("✓ Counter reset\n")
      invisible(self)
    },

    get_dir = function() {
      return(self$savedir)
    },

    get_count = function() {
      return(self$counter)
    }
  )
)
