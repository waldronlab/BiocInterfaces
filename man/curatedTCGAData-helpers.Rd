% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/curatedTCGAData-helpers.R
\name{curatedTCGAData-helpers}
\alias{curatedTCGAData-helpers}
\alias{getSubtypeMap}
\alias{getClinicalNames}
\title{Helper functions for managing MultiAssayExperiment from
curatedTCGAData}
\usage{
getSubtypeMap(multiassayexperiment)

getClinicalNames(diseaseCode)
}
\arguments{
\item{multiassayexperiment}{A \linkS4class{MultiAssayExperiment} object}

\item{diseaseCode}{A TCGA cancer code (e.g., "BRCA")}
}
\description{
Additional helper functions for cleaning and uncovering metadata
within a downloaded \code{MultiAssayExperiment} from \code{curatedTCGAData}
}