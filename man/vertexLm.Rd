% Generated by roxygen2 (4.0.1): do not edit by hand
\name{vertexLm}
\alias{vertexLm}
\title{Calculates statistics and coefficients for linear model of specified vertex files}
\usage{
vertexLm(formula, data, subset = NULL)
}
\arguments{
\item{formula}{a model formula. The RHS of the formula may contain one term with filenames. If
so only the + operator may be used, and only two terms may appear on the RHS}

\item{data}{a data.frame containing variables in formula}

\item{subset}{rows to be used, by default all are used}
}
\value{
Returns an object containing the beta coefficients, F
and t statistcs that can be passed directly into vertexFDR.
}
\description{
Calculates statistics and coefficients for linear model of specified vertex files
}
\examples{
gf = read.csv("~/SubjectTable.csv")
civet.getAllFilenames(gf,"ID","ABC123","~/CIVET","TRUE","1.1.12")
gf = civet.readAllCivetFiles("~/Atlases/AAL/AAL.csv",gf)
gf$vertexFiles = as.factor(gf$CIVETFILES$nativeRMStlink20mmleft)
result = vertexLm(vertexFiles~Primary.Diagnosis,gf)
vertexFDR(result)
}
\seealso{
mincLm,anatLm,vertexFDR
}

