\name{qsave}
\alias{qsave}
\title{Quick Save Plot to PDF}
\usage{
qsave(plot, filename, savedir, width = 4, height = 4, verbose = TRUE)
}
\arguments{
\item{plot}{A ggplot object or plot to save}

\item{filename}{Filename to save (with or without extension)}

\item{savedir}{Directory to save the file}

\item{width}{Plot width in inches (default: 4)}

\item{height}{Plot height in inches (default: 4)}

\item{verbose}{Print saved path (default: TRUE)}
}
\value{
Invisible NULL
}
\description{
Save a ggplot or base R plot to PDF with automatic path management.
}
\examples{
\dontrun{
library(ggplot2)
library(quickSave)

p <- ggplot(mtcars, aes(x = wt, y = mpg)) + geom_point()
qsave(p, "scatter.pdf", "./results")
}
}
