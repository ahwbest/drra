
#' @title Fit a 4 parameter logistic (4PL) model to dose-response data.
#' 
#' @description Compute the confidence intervals of parameter estimates of a fitted
#'   model.
#'   
#' @name confint.dr4pl
#'   
#' @param object An object of the dr4pl class
#' @param parm Parameters of the 4PL model
#' @param level Confidence level
#' @param ... Other parameters to be passed
#' 
#' @return A matrix of the confidence intervals in which each row represents a
#'   parameter and each column represents the lower and upper bounds of the
#'   confidence intervals of the corresponding parameters.
#'   
#' @details This function computes the confidence intervals of the parameters of the
#'   4PL model based on the second order approximation to the Hessian matrix of the
#'   loss function of the model. Please refer to Subsection 5.2.2 of 
#'   Seber, G. A. F. and Wild, C. J. (1989). Nonlinear Regression. Wiley Series in
#'   Probability and Mathematical Statistics: Probability and Mathematical
#'   Statistics. John Wiley & Sons, Inc., New York.
#'   
#' @examples
#'   obj.dr4pl <- dr4pl(Response ~ Dose, data = sample_data_1)
#'   parm <- obj.dr4pl$parameters
#'
#'   confint(obj.dr4pl, parm = parm, level = 0.95)
#' 
#' @author Hyowon An, Justin T. Landis and Aubrey G. Bailey
#' @export
confint.dr4pl <- function(object, parm, level, ...) {
  
  x <- object$data$Dose
  y <- object$data$Response
  theta <- object$parameters
  hessian <- object$hessian
  
  n <- object$sample.size  # Number of observations in data
  f <- MeanResponse(x, theta)
  
  C.hat.inv <- solve(hessian/2)
  s <- sqrt(sum((y - f)^2)/(n - 4))
  
  q.t <- qt(1 - (1 - level)/2, df = n - 4)
  std.err <- s*sqrt(diag(C.hat.inv))  # Standard error
  ci <- cbind(theta - q.t*std.err, theta + q.t*std.err)
  
  return(ci)
}

#' @title Obtain coefficients of a 4PL model
#' 
#' @description This function obtains the coefficients of a 4PL model. The four
#' parameters, the upper asymptote, IC50, slope and lower asymptote, 
#' 
#' @name coef.dr4pl
#' @param object A 'dr4pl' object
#' @param ... arguments passed to coef
#' @return A vector of parameters
#' @export
coef.dr4pl <- function(object, ...) {
  
  object$parameters
}

#' @title plot
#' 
#' @description Default plotting function for a `dr4pl' object. Plot displays 
#'   decreasing dr4pl curve as well as measured points. Default points are 
#'   blue and size 5.
#'   
#' @name plot.dr4pl
#' 
#' @param x `dr4pl' object whose data and mean response function will be plotted.
#' @param text.title Character string for the title of a plot with a default set to 
#'   "Dose response plot".
#' @param text.x Character string for the x-axis of the plot with a default set to 
#'   "Dose".
#' @param text.y Character string for the y-axis of the plot with a default set to 
#'   "Response".
#' @param indices.outlier Pass a vector indicating all indices which are outliers in 
#'   the data.
#' @param ... All arguments that can normally be passed to ggplot.
#' @examples
#' ryegrass.dr4pl <- dr4pl::dr4pl(Response ~ Dose, data = sample_data_1)
#'
#' plot(ryegrass.dr4pl)
#' 
#' ##Able to further edit plots
#' library(ggplot2)
#' ryegrass.dr4pl <- dr4pl::dr4pl(Response ~ Dose, 
#'                                data = sample_data_1, 
#'                                text.title = "Sample Data Plot")
#'
#' a <- plot(ryegrass.dr4pl) 
#' a + geom_point(color = "green", size = 5)
#' 
#' ##Bring attention to outliers using parameter indices.outlier.
#' 
#' a <- dr4pl(Response ~ Dose, 
#'            data = drc_error_3, 
#'            method.init = "Mead", 
#'            method.robust = "absolute" )
#' plot(a, indices.outlier = c(90, 101))
#' 
#' ##Change the plot title default with parameter text.title
#' 
#' ryegrass.dr4pl <- dr4pl::dr4pl(Response ~ Dose, 
#'                                data = sample_data_1)
#' plot(ryegrass.dr4pl, text.title = "My New Dose Response plot")
#' 
#' ##Change the labels of the x and y axis to your need
#' 
#' library(drc)  #example requires decontaminants dataset from drc package.
#' d <- subset(decontaminants, group %in% "hpc")
#' e <- dr4pl(count~conc, data = d)
#' plot(e, 
#'      text.title = "hpc Decontaminants Plot", 
#'      text.x = "Concentration", 
#'      text.y = "Count")
#' 
#' @export
plot.dr4pl <- function(x,
                       text.title = "Dose-response plot",
                       text.x = "Dose",
                       text.y = "Response",
                       indices.outlier = NULL,
                       ...) {
  
  ### Check whether function arguments are appropriate
  if(!is.character(text.title)) {
    
    stop("Title text should be characters.")
  }
  if(!is.character(text.x)) {
    
    stop("The x-axis label text should be characters.")
  }
  if(!is.character(text.y)) {
    
    stop("The y-axis label text should be characters.")
  }
  
  ### Draw a plot
  n <- x$sample.size
  color.vec <- rep("blue", n)
  
  if(!is.null(indices.outlier)) {
    
    color.vec[indices.outlier] <- "red"
  }
  
  a <- ggplot2::ggplot(aes(x = x$data$Dose, y = x$data$Response), data = x$data)
  
  a <- a + ggplot2::stat_function(fun = MeanResponse,
                                  args = list(theta = x$parameters),
                                  size = 1.2)
  
  a <- a + ggplot2::geom_point(size = I(5), alpha = I(0.8), color = color.vec)
  
  a <- a + ggplot2::labs(title = text.title,
                         x = text.x,
                         y = text.y)
  
  # Set parameters for the grids
  a <- a + ggplot2::theme(strip.text.x = ggplot2::element_text(size = 16))
  a <- a + ggplot2::theme(panel.grid.minor = ggplot2::element_blank())
  a <- a + ggplot2::theme(panel.grid.major = ggplot2::element_blank())
  a <- a + ggplot2::scale_x_log10()
  a <- a + ggplot2::theme_bw()
  
  # Set parameters for the titles and text / margin(top, right, bottom, left)
  a <- a + ggplot2::theme(plot.title = ggplot2::element_text(size = 20, margin = ggplot2::margin(0, 0, 10, 0)))
  a <- a + ggplot2::theme(axis.title.x = ggplot2::element_text(size = 16, margin = ggplot2::margin(15, 0, 0, 0)))
  a <- a + ggplot2::theme(axis.title.y = ggplot2::element_text(size = 16, margin = ggplot2::margin(0, 15, 0, 0)))
  a <- a + ggplot2::theme(axis.text.x = ggplot2::element_text(size = 16))
  a <- a + ggplot2::theme(axis.text.y = ggplot2::element_text(size = 16))
  
  return(a)
}

#' Print the dr4pl object to screen.
#'
#' @param object a dr4pl object to be printed
#' @param ... all normally printable arguments
#' @examples
#' ryegrass.dr4pl <- dr4pl(Response ~ Dose,
#'                       data = sample_data_1)
#'
#' print(ryegrass.dr4pl)
print.dr4pl <- function(object, ...) {
  
  cat("Call:\n")
  print(object$call)
  
  cat("\nCoefficients:\n")
  print(object$parameters)
}

#' Print the dr4pl object summary to screen.
#' @param object a dr4pl object to be summarized
#' @param ... all normally printable arguments
print.summary.dr4pl <- function(object, ...) {
  
  cat("Call:\n")
  print(object$call)
  cat("\n")
  
  printCoefmat(object$coefficients, P.values = TRUE, has.Pvalue = TRUE)
}

#' @title summary
#'
#' @description Print the dr4pl object summary.
#' 
#' @name summary.dr4pl
#' 
#' @param object a dr4pl object to be summarized
#' @param ... all normal summary arguments
#' 
#' @export
summary.dr4pl <- function(object, ...) {
  
  TAB <- cbind(Estimate = object$parameters,
               StdErr = object$std.err,
               t.value = object$t.value,
               p.value = object$p.value)
  
  res <- list(call = object$call,
              coefficients = TAB)
  
  class(res) <- "summary.dr4pl"
  res
}

#' @description Perform the goodness-of-fit (gof) test for the 4PL model when there
#'   are at least two replicates for each dose level.
#' @title Perform the goodness-of-fit (gof) test for the 4PL model.
#' @name gof.dr4pl
#'   
#' @param object An object of the dr4pl class.
#' 
#' @return Object of class `gof.dr4pl' which consists of .
#'   
#' @details Perform the goodness-of-fit (gof) test for the 4PL model in which the
#'   mean response actually follws the 4 Parameter Logistic model. There should
#'   be at least two replicates at each dose level. The test statistic follows the
#'   Chi squared distributions with the (n - 4) degrees of freedom where n is the
#'   number of observations and 4 is the number of parameters in the 4PL model. For
#'   detailed explanation of the method, please refer to Subsection 2.1.5 of
#'   Seber, G. A. F. and Wild, C. J. (1989). Nonlinear Regression. Wiley Series in
#'   Probability and Mathematical Statistics: Probability and Mathematical
#'   Statistics. John Wiley & Sons, Inc., New York.
#'
#' @export
gof.dr4pl <- function(object) {
  
  x <- object$data$Dose  # Dose levels
  y <- object$data$Response  # Responses
  
  J.i <- table(x)  # Numbers of observations at all dose levels
  n <- length(unique(x))  # Number of dose levels
  N <- object$sample.size  # Total number of observations
  p <- 4  # Number of parameters of the 4PL model is 4
  # Numbers of observations per dose level
  n.obs.per.dose <- tapply(X = y, INDEX = x, FUN = length)
  
  # Check whether function arguments are appropriate
  if(n <= 4) {
    
    stop("The number of dose levels should be larger than four to perform the
         goodness-of-fit test for the 4PL model.")
  }
  if(any(n.obs.per.dose <= 1)) {
    
    stop("There should be more than one observation for each dose level to perform
         the goodness-of-fit test.")
  }
  
  levels.x.sorted <- sort(unique(x))
  
  x.sorted <- sort(x)
  indices.x.sorted <- sort(x, index.return = TRUE)$ix
  y.sorted <- y[indices.x.sorted]
  
  y.bar <- tapply(X = y.sorted, INDEX = x.sorted, FUN = mean)
  y.fitted <- MeanResponse(levels.x.sorted, object$parameters)
  
  
  y.bar.rep <- rep(y.bar, times = n.obs.per.dose)

  gof.numer <- J.i%*%(y.bar - y.fitted)^2/(n - p)
  gof.denom <- sum((y.sorted - y.bar.rep)^2)/(N - n)
  
  gof.stat <- gof.numer/gof.denom
  gof.pval <- pf(gof.stat, df1 = n - p, df2 = N - n, lower.tail = FALSE)
  gof.df <- c(n - p, N - n)
  
  obj.gof.dr4pl <- list(gof.stat, gof.pval, gof.df)
  names(obj.gof.dr4pl) <- c("Statistic", "pValue", "DegreesOfFreedom")
  
  class(obj.gof.dr4pl) <- "gof.dr4pl"
  
  return(obj.gof.dr4pl)
}