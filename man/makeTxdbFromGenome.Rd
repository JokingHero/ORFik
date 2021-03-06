% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/txdbHelpers.R
\name{makeTxdbFromGenome}
\alias{makeTxdbFromGenome}
\title{Make txdb from genome}
\usage{
makeTxdbFromGenome(gtf, genome = NULL, organism, optimize = FALSE)
}
\arguments{
\item{gtf}{path to gtf file}

\item{genome}{character, default NULL. Path to fasta genome
corresponding to the gtf. If NULL, can not set seqlevels.
If value is NULL or FALSE, it will be ignored.}

\item{organism}{Scientific name of organism, first letter
must be capital! Example: Homo sapiens. Will force first letter
to capital and convert any "_" (underscore) to " " (space)}

\item{optimize}{logical, default FALSE. Create a folder
within the folder of the gtf, that includes optimized objects
to speed up loading of annotation regions from up to 15 seconds
on human genome down to 0.1 second. ORFik will then load these optimized
objects instead. Currently optimizes filterTranscript() function and
loadRegion() function.}
}
\value{
NULL, Txdb saved to disc named paste0(gtf, ".db")
}
\description{
Make a Txdb with defined seqlevels and
seqlevelsstyle from the fasta genome.
This makes it more fail safe than standard Txdb creation.
Example is that you can not create a coverage window outside
the chromosome boundary, this is only possible if you have
set the seqlengths.
}
\examples{
gtf <- "/path/to/local/annotation.gtf"
genome <- "/path/to/local/genome.fasta"
#makeTxdbFromGenome(gtf, genome, organism = "Saccharomyces cerevisiae")
}
