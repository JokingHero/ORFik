% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/coverage_plots.R
\name{windowCoveragePlot}
\alias{windowCoveragePlot}
\title{Get meta coverage plot of reads}
\usage{
windowCoveragePlot(
  coverage,
  output = NULL,
  scoring = "zscore",
  colors = c("skyblue4", "orange"),
  title = "Coverage metaplot",
  type = "transcripts",
  scaleEqual = FALSE,
  setMinToZero = FALSE
)
}
\arguments{
\item{coverage}{a data.table, e.g. output of scaledWindowCoverage}

\item{output}{character string (NULL), if set, saves the plot as pdf or png
to path given. If no format is given, is save as pdf.}

\item{scoring}{character vector, default "zscore", either of zscore,
transcriptNormalized, sum, mean, median, .. or  NULL. Set NULL if already scored.
see ?coverageScorings for info and more alternatives.}

\item{colors}{character vector colors to use in plot, will fix automaticly,
using binary splits with colors c('skyblue4', 'orange').}

\item{title}{a character (metaplot) (what is the title of plot?)}

\item{type}{a character (transcripts), what should legends say is
the whole region? Transcripts, genes, non coding rnas etc.}

\item{scaleEqual}{a logical (FALSE), should all fractions (rows), have same
max value, for easy comparison of max values if needed.}

\item{setMinToZero}{a logical (FALSE), should minimum y-value be 0 (TRUE).
With FALSE minimum value is minimum score at any position. This parameter
overrides scaleEqual.}
}
\value{
a ggplot object of the coverage plot, NULL if output is set,
then the plot will only be saved to location.
}
\description{
Spanning a region like a transcripts, plot how the reads distribute.
}
\details{
If coverage has a column called feature, this can be used to subdivide the
meta coverage into parts as (5' UTRs, cds, 3' UTRs) These are the columns
in the plot.
The fraction column divide sequence libraries. Like ribo-seq and rna-seq.
These are the rows of the plot.
If you return this function without assigning it and output is NULL,
it will automaticly plot the figure in your session. If output is assigned,
no plot will be shown in session. NULL is returned and object is saved to
output.

Colors:
Remember if you want to change anything like colors, just return the
ggplot object, and reassign like: obj + scale_color_brewer() etc.
}
\examples{
library(data.table)
coverage <- data.table(position = seq(20),
                       score = sample(seq(20), 20, replace = TRUE))
windowCoveragePlot(coverage)

#Multiple plots in one frame:
coverage2 <- copy(coverage)
coverage$fraction <- "Ribo-seq"
coverage2$fraction <- "RNA-seq"
dt <- rbindlist(list(coverage, coverage2))
windowCoveragePlot(dt, scoring = "log10sum")

# See vignette for a more practical example

}
\seealso{
Other coveragePlot: 
\code{\link{coverageHeatMap}()},
\code{\link{pSitePlot}()},
\code{\link{savePlot}()}
}
\concept{coveragePlot}
