% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/base.R
\name{DerivativeFLogIC50}
\alias{DerivativeFLogIC50}
\title{Compute the derivative values of the mean response function with respect to
  reparametrized parameters including the log 10 IC50 parameter.}
\usage{
DerivativeFLogIC50(retheta, x)
}
\arguments{
\item{retheta}{Parameters obtained from the original parameters by
\code{retheta[2] <- log10(theta[2])}}

\item{x}{Dose levels}
}
\value{
Derivative values of the mean response function.
}
\description{
Compute the derivative values of the mean response function with respect to
  reparametrized parameters including the log 10 IC50 parameter.
}
