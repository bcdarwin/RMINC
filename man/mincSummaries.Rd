\name{mincSummaries}
\alias{mincMean}
\alias{mincVar}
\alias{mincSum}
\alias{mincSd}
\title{Create descriptive statistics across a series of MINC volumes}

\description{This function is used to compute the mean, standard deviation,
  sum, or variance of every voxel in a set of MINC volumes. An optional
  grouping variable will split the computation by group rather than
  performing it across all volumes as is the default.}


\usage{
mincMean(filenames, grouping=NULL, mask=NULL)

mincSd(filenames, grouping=NULL, mask=NULL)

mincSum(filenames, grouping=NULL, mask=NULL)

mincVar(filenames, grouping=NULL, mask=NULL)
}

\arguments{
  \item{filenames}{Filenames of the MINC volumes across which to create
    the descriptive statistic.}
  \item{grouping}{Optional grouping - contains same number of elements
    as filenames; the results will then have the descriptive statistic
    computed separately for each group.}
  \item{mask}{A mask specifying which voxels are to be included in the summary.}
}

\value{
  \item{out}{The output will be a single vector containing as many
    elements as there are voxels in the input files. If a grouping
    factor was specified then the output will be a matrix consisiting of
    as many rows as there were voxels in the files, and as many columns
    as there were groups.}
}

\seealso{mincWriteVolume,mincLm,mincGetVolume}
\examples{
\dontrun{
# read the text file describing the dataset
gf <- read.csv("control-file.csv")
# compute the mean at every voxel of all files.
means <- mincMean(gf$filenames)
# write the results to file.
mincWriteVolume(means, "means.mnc")
# compute the mean separtely for each group
means <- mincMean(gf$filenames, gf$Group)
}}