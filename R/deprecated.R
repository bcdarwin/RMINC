# R code which I don't think is necessary anymore but which I'll
# include just in case I was wrong ...

# run a t-test, wilcoxon test, correlation, or linear model at every voxel
minc.model <- function(filenames, groupings, method="t-test",
                       mask=NULL) {

  if (method == "t-test"
      || method == "wilcoxon"
      || method == "correlation"
      || method == "lm"
      || method == "paired-t-test") {
    # do nothing
  }
  else {
    stop("Method must be one of t-test, paired-t-test, wilcoxon, correlation or lm")
  }

  if (method == "lm") {
    result <- list(method="lm")
    result$likeVolume <- filenames[1]
    result$model <- groupings
    result$filenames <- filenames
    result$data <- .Call("minc2_model",
                         as.character(filenames),
                         as.matrix(groupings),
                         NULL,
                         as.double(! is.null(mask)),
                         as.character(mask),
                         NULL, NULL,
                         as.character(method), PACKAGE="RMINC")

    # get the first voxel in order to get the dimension names
    v.firstVoxel <- mincGetVoxel(filenames, 0,0,0)
    rows <- sub('mmatrix', '',
                rownames(summary(lm(v.firstVoxel ~ groupings))$coefficients))
    colnames(result$data) <- c("F-statistic", rows)
    class(result) <- "mincMultiDim"
    
  }
  else {
    groupings <- as.double(groupings)
    result <- .Call("minc2_model",
                    as.character(filenames),
                    as.double(groupings),
                    NULL,
                    as.double(! is.null(mask)),
                    as.character(mask),
                    NULL, NULL,
                    as.character(method), PACKAGE="RMINC")
  }
  return(result)
}

# run a t-test at every voxel. Only two groups allowed.
minc.t.test <- function(filenames, groupings, mask=NULL) {
  voxel.t.test <- function(x) {
    .Call("t_test", as.double(x), as.double(tmp.groupings),
          as.double(length(x)), PACKAGE="RMINC")
  }
  assign("tmp.groupings", groupings, env=.GlobalEnv)
  assign("voxel.t.test", voxel.t.test, env=.GlobalEnv);
  t <- minc.apply(filenames, quote(voxel.t.test(x)), mask)
}

# run a non-parametric wilcoxon test at every voxel. Only two groups
# are allowed.
minc.wilcoxon.test <- function(filenames, groupings, mask=NULL) {
  voxel.wilcoxon.test <- function(x) {
    .Call("wilcoxon_rank_test", as.double(x),
          as.double(tmp.groupings),
          as.double(sum(tmp.groupings==0)),
          as.double(sum(tmp.groupings==1)), PACKAGE="RMINC")
  }

  groupings <- as.double(groupings)
  assign("tmp.groupings", groupings, env=.GlobalEnv)
  cat("TMP: ", as.double(tmp.groupings), "\n")
  assign("voxel.wilcoxon.test", voxel.wilcoxon.test, env=.GlobalEnv)
  w <- minc.apply(filenames, quote(voxel.wilcoxon.test(x)), mask)
  return(w)
}

minc.slice.loop <- function(filenames, n.slices, output.dims, func, ...) {
  sizes <- minc.dimensions.sizes(filenames[1])
  slice.dim.size <- sizes[1]

  total.size <- sizes[1] * sizes[2] * sizes[3]
  n.subjects <- length(filenames)

  sequence <- seq(0, slice.dim.size, n.slices)

  # make sure that all slices are included
  if (sequence[length(sequence)] != slice.dim.size) {
    sequence <- append(sequence, slice.dim.size)
  }
  cat("Sequence: "); cat(sequence); cat("\n");

  output <- vector(length=total.size)
  # do the loop
  prev.index <- 1
  buffer <- matrix(0, nrow=((sequence[2] - sequence[1]) *sizes[2] * sizes[3]), ncol=n.subjects)

  for (i in 1:(length(sequence)-1)) {
    start <- c(sequence[i], 0, 0)
    count <- c((sequence[i+1] - sequence[i]), sizes[2], sizes[3])

    #start <- c(0,0, sequence[i])
    #count <- c(sizes[1], sizes[2], sequence[i+1] - sequence[i])
    
    current.index <- sequence[i+1] * sizes[2] * sizes[3]
    #current.size <- current.index - prev.index
    current.size <- count[1] * count[2] * count[3]
    cat("Counter: "); cat(i); cat("\n")
    cat("sequence: "); cat(sequence[i]); cat("\n")
    cat("next sequence: "); cat(sequence[i+1]); cat("\n")
    cat("start: "); cat(start); cat("\n")
    cat("count: "); cat(count); cat("\n")
    for (j in 1:n.subjects) {
      #buffer[,j] <- minc.get.hyperslab2(filenames[j], start, count, buffer[,j])
    }
    current.index <- current.index
    cat("Prev: "); cat(prev.index); cat(" Curr: ");
    cat(current.index); cat("\n")
    for (k in prev.index:current.index) {
      output[k] <- wt(buffer[k,])
    }
    #output[prev.index:current.index] <- apply(buffer, 1, func, ...)
    #output[prev.index:current.index] <- buffer[,1]
    prev.index <- prev.index + current.size
    #sequence[i+1] <- sequence[i+1] + 1
  }
  return(output)
}

minc.get.hyperslab2 <- function(filename, start, count, buffer=NA) {
#  total.size <- (count[1] - start[1]) * (count[2] - start[2]) *
#                (count[3] - start[3])
  total.size <- (count[1] * count[2] * count[3])
  if (is.na(buffer)) {
    buffer <- double(total.size)
  }
  cat("Total size: "); cat(total.size); cat("\n")
  .Call("get_hyperslab2",
               as.character(filename),
               as.integer(start),
               as.integer(count), hs=buffer, DUP=FALSE, PACKAGE="RMINC")
  #return(output)
}


# given an array of filenames, get the data from the corresponding slices
minc.get.slices <- function(filenames, begin.slice=NA, end.slice=NA) {
  # blithely assume all volumes have the same dimensions
  #cat(filenames[1]
  sizes <- .C("get_volume_sizes",
              as.character(filenames[1]),
              sizes = integer(3), PACKAGE="RMINC")$sizes
  num.slices <- end.slice - begin.slice
  total.size <- sizes[2] * sizes[3] * num.slices
  num.files <- length(filenames)
  start <- c(begin.slice, 0, 0)
  count <- c((end.slice - begin.slice), sizes[2], sizes[3])
  output <- matrix(ncol=num.files, nrow=total.size)

  # get the hyperslabs
  for (i in 1:num.files) {
    output[, i] <- .C("get_hyperslab",
                       as.character(filenames[i]),
                       as.integer(start),
                       as.integer(count), hs=double(total.size), PACKAGE="RMINC")$hs
  }
  return(output)
}
wilcox.permutation <- function(filenames, groupings, mask, n.permute=10) {
  results <- data.frame(greater50=vector(length=n.permute),
                        less5=vector(length=n.permute),
                        equal55=vector(length=n.permute),
                        equal0=vector(length=n.permute),
                        percent5=vector(length=n.permute),
                        percent95=vector(length=n.permute))
  mask.volume <- minc.get.volume(mask)
  for (i in 1:n.permute) {
    new.order <- sample(groupings)
    cat("N: ", as.double(new.order), "\n")
    w <- minc.wilcoxon.test(filenames, new.order, mask)
    w2 <- w[mask.volume == 1]
    ws <- sort(w2)
    #minc.write.volume(paste("p", i, ".mnc", sep=""), mask, w)
    results$greater50[i] <- sum(w2 > 50)
    results$less5[i] <- sum(w2 < 5)
    results$equal55[i] <- sum(w2 == 55)
    results$equal0[i] <- sum(w2 == 0)
    results$percent5[i] <- ws[round(length(ws) * 0.05)]
    results$percent95[i] <- ws[round(length(ws) * 0.95)]
  }
  return(results)
}
