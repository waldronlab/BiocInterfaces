if (!requireNamespace("BiocFileCache"))
    stop("Please install 'BiocFileCache' to manage and generate data")

## Extract cancer codes from TCGA project
.parseDiseaseCodes <- function(from, to) {
    htcc <- xml2::read_html(from)
    diseaseCodes <- rvest::html_table(htcc, fill = TRUE)[[2L]]
    names(diseaseCodes) <- make.names(colnames(diseaseCodes))

    excludedCodes <- c("COADREAD", "GBMLGG", "KIPAN", "STES", "FPPP", "CNTL",
                       "LCML", "MISC")
    available <- !diseaseCodes[["Study.Abbreviation"]] %in% excludedCodes
    diseaseCodes[["Available"]] <- factor(available,  levels = c("TRUE", "FALSE"),
        labels = c("Yes", "No"))

    subtypeCodes <- c("ACC", "BLCA", "BRCA", "COAD", "GBM", "HNSC", "KICH",
        "KIRC", "KIRP", "LAML", "LGG", "LUAD", "LUSC", "OV", "PRAD", "SKCM",
        "STAD", "THCA", "UCEC")
    diseaseCodes[["SubtypeData"]] <- factor(
        diseaseCodes[["Study.Abbreviation"]] %in% subtypeCodes,
        levels = c("TRUE", "FALSE"), labels = c("Yes", "No"))

    diseaseCodes <- diseaseCodes[order(diseaseCodes[["Study.Abbreviation"]]), ]
    ## Rearrange column order
    diseaseCodes <- diseaseCodes[,
        c("Study.Abbreviation", "Available", "SubtypeData", "Study.Name")]
    rownames(diseaseCodes) <- NULL

    ## Coerce to standard data.frame (no tibble required)
    diseaseCodes <- as(diseaseCodes, "data.frame")

    ## For easy subsetting use:
    ## diseaseCodes[["Study.Abbreviation"]][diseaseCodes$Available == "Yes"]

    ## Save dataset for exported use
    save(diseaseCodes, file = to, compress = "bzip2")
    TRUE
}

.get_cache <- function() {
    cache <- rappdirs::user_cache_dir("TCGAutils")
    BiocFileCache::BiocFileCache(cache)
}

update_data_file <-
    function(fileURL, verbose = FALSE , resource, ext = ".rda", FUN) {
    bfc <- .get_cache()
    rid <- BiocFileCache::bfcquery(bfc, fileURL, "rname")$rid
    if (!length(rid)) {
        if (verbose)
            message( "Downloading ", resource, " file" )
        rid <- names(BiocFileCache::bfcadd(bfc, fileURL, download = FALSE,
            ext = ".rda"))
    }
    if (!isFALSE(BiocFileCache::bfcneedsupdate(bfc, rid))) {
        rpath <- BiocFileCache::bfcdownload(bfc, rid, ask = FALSE,
            FUN = FUN, ext = ".rda")
        ## copy to data dir after updating
        file.copy(rpath, file.path("data", paste0(resource, ext)),
            overwrite = TRUE)
    }
    if (verbose)
        message(resource, " update complete")

    bfcrpath(bfc, rids = rid)
}

url1 <- paste0("https://gdc.cancer.gov/resources-tcga-users/",
    "tcga-code-tables/tcga-study-abbreviations")
update_data_file(url1, verbose = FALSE,
    resource = "diseaseCodes", FUN = .parseDiseaseCodes)
