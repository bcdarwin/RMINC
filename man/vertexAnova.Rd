% Generated by roxygen2 (4.0.1): do not edit by hand
\name{vertexAnova}
\alias{vertexAnova}
\title{Performs ANOVA on each vertex point specified}
\usage{
vertexAnova(formula, data, subset = NULL)
}
\arguments{
\item{formula}{a model formula}

\item{data}{a data.frame containing variables in formula}

\item{filenames}{list of vertex files}

\item{subset}{rows to be used, by default all are used}
}
\value{
Returns an array with the F-statistic for each model specified by formula with the following attributes: model – design matrix, filenames –
	vertex file names input, stat-type: type of statistic used, df – degrees of freedom of each statistic.
}
\description{
Performs ANOVA on each vertex point specified
}
\examples{
gf = read.csv("~/SubjectTable.csv")
civet.getAllFilenames(gf,"ID","ABC123","~/CIVET","TRUE","1.1.12")
gf = civet.readAllCivetFiles("~/Atlases/AAL/AAL.csv",gf)
result = vertexAnova(~Primary.Diagnosis,gf,gf$CIVETFILES$nativeRMStlink20mmleft)
}
\seealso{
mincAnova,anatAnova
}

