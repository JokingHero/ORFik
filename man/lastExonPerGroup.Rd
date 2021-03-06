% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/grl_helpers.R
\name{lastExonPerGroup}
\alias{lastExonPerGroup}
\title{Get last exon per GRangesList group}
\usage{
lastExonPerGroup(grl)
}
\arguments{
\item{grl}{a \code{\link{GRangesList}}}
}
\value{
a GRangesList of the last exon per group
}
\description{
grl must be sorted, call ORFik:::sortPerGroup if needed
}
\examples{
gr_plus <- GRanges(seqnames = c("chr1", "chr1"),
                   ranges = IRanges(c(7, 14), width = 3),
                   strand = c("+", "+"))
gr_minus <- GRanges(seqnames = c("chr2", "chr2"),
                    ranges = IRanges(c(4, 1), c(9, 3)),
                    strand = c("-", "-"))
grl <- GRangesList(tx1 = gr_plus, tx2 = gr_minus)
lastExonPerGroup(grl)
}
