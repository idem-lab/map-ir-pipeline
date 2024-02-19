
# Mapping IR Pipeline

<!-- badges: start -->
<!-- badges: end -->

The goal of this repository is to write out a pipeline for stacked generalisation method used in ["Mapping trends in insecticide resistance phenotypes in African malaria vectors"](https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.3000633#sec010).

We will first begin by generating a fake targets pipeline, so that we can identify the general workflow and refine it and make sure it has some kind of face validity, before going back into this in more depth

## Data

The data for this repository has been obtained from [Moyes et al's Data Dryad repository](https://datadryad.org/stash/dataset/doi:10.5061/dryad.dn4676s), 

## How to run this on your machine

Use the `capsule` package to manage the R dependencies

```r
install.packages(
   "capsule", 
   repos = c(mm = "https://milesmcbain.r-universe.dev", getOption("repos")))
```

Run targets:

```r
capsule::run(targets::tar_make())
```

This should, in theory, run the targets pipeline and you should then also have the packages installed that you require.
