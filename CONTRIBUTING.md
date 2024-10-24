# Contributing to modisfast

First off, thanks for taking the time to contribute!

All types of contributions are encouraged and valued. See the 
[Table of contents](#table-of-contents) for different ways to help and details about how 
this project handles them. Please make sure to read the relevant section before 
making your contribution. It will make it a lot easier for us maintainers and 
smooth out the experience for all involved.


## Table of contents

- [Code of conduct](#code-of-conduct)
- [Style guide](#style-guide)
- [Commit messages](#commit-messages)
- [Asking questions](#asking-questions)
- [Reporting bugs](#reporting-bugs)
- [Requesting features](#requesting-features)
- [Contributing code](#contributing-code)



## Code of conduct

This project is released with a
[Contributor Code of Conduct](https://github.com/ptaconet/modisfast/blob/master/CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report 
unacceptable behavior to <paul.taconet@gmail.com>.



## Style guide

We use as much as possible the [Tidyverse style guide](https://style.tidyverse.org/) for writing R 
code - except for line length. Functions are documented with the 
[roxygen2](https://roxygen2.r-lib.org/articles/roxygen2.html) syntax. 
`modifast` uses the `lower_snake_case`.



## Commit messages

If you want to contribute by commiting changes, please try to use the 
[Conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) 
specification.


## Asking questions

Before you ask a question, it is best to search for existing
[Issues](https://github.com/ptaconet/modisfast/issues) that might help you. 
In case you have found a suitable issue and still need clarification, you can 
write your question in this issue.

If you then still feel the need to ask a question and need clarification, we 
recommend the following:

- Open a new [Issue](https://github.com/ptaconet/modisfast/issues/new).
- Provide as much context as you can about what you're running into.
- Provide project and platform versions (paste the output of `sessionInfo()`).

We will then take care of the issue as soon as possible.


## Reporting bugs

### Before submitting a bug report

A good bug report shouldn't leave others needing to chase you up for more 
information. Therefore, we ask you to investigate carefully, collect information
and describe the issue in detail in your report. Please complete the following 
steps in advance to help us fix any potential bug as fast as possible.

- Make sure that you are using the latest version of `modisfast`.
- Determine if your bug is really a bug and not an error on your side.
- To see if other users have experienced (and potentially already solved) the 
same issue you are having, check if there is not already a bug report existing 
for your bug or error in the [bug tracker](https://github.com/ptaconet/modisfast/issues?q=label%3Abug).


### How do I submit a bug report?

We use [GitHub Issues](https://github.com/ptaconet/modisfast/issues) to track 
bugs and errors. If you run into an issue with the project:

- Open a new [Issue](https://github.com/ptaconet/modisfast/issues/new).
- Explain the behavior you would expect and the actual behavior.
- Please provide as much context as possible and describe the 
*reproduction steps* that someone else can follow to recreate the issue on 
their own. This usually includes your code with a reproducible example.

We will then take care of the issue as soon as possible.



## Requesting features

### Before requesting a feature

- Make sure that you are using the latest version of `modisfast`.
- Read the [documentation](https://github.com/ptaconet/modisfast)
carefully and find out if the functionality is already covered.
- Perform a [search](https://github.com/ptaconet/modisfast/issues) to see if 
this enhancement has already been suggested. If it has, add a comment to the 
existing issue instead of opening a new one.


### How do I submit a feature request?

Feature requests are tracked as 
[GitHub Issues](https://github.com/ptaconet/modisfast/issues).

- Open a new [Issue](https://github.com/ptaconet/modisfast/issues/new).
- Provide a clear and descriptive title for the issue to identify the suggestion.
- Provide a step-by-step description of the suggested enhancement in as 
many details as possible.
- Explain why this enhancement would be useful to most `modisfast` users.

We will then take care of the issue as soon as possible.

## Contributing code

### General workflow

We use the [GitHub flow](https://docs.github.com/en/get-started/quickstart/github-flow) 
to collaborate on this project:


1. [Fork](https://docs.github.com/en/get-started/quickstart/contributing-to-projects) 
this repository using the GitHub interface.
1. [Clone](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) 
your fork using `git clone fork-url` (replace `fork-url` by the URL of your fork). 
Alternatively, open RStudio IDE and create a 
[New Project from Version Control](https://argoshare.is.ed.ac.uk/healthyr_book/clone-an-existing-github-project-to-new-rstudio-project.html).
1. Create a new branch w/ `git checkout -b branch-name` (replace `branch-name` 
by the name of your new branch).
1. Make your contribution (see below for examples).
1. Stage (`git add`) and commit (`git commit`) your changes as often as necessary
1. Push your changes to GitHub w/ `git push origin branch-name`.
3. Submit a [Pull Request](https://docs.github.com/en/get-started/quickstart/contributing-to-projects#making-a-pull-request) on the [original repo](https://github.com/ptaconet/modisfast/compare).

We will then review the PR as soon as possible.

### Improve documentation

#### Editing the README

If you want to contribute by improving the README, please edit the `README.Rmd` 
(not the `README.md`). Do not forget to update the `README.md` by running: 

```r
rmarkdown::render("README.Rmd")
```

#### Editing vignettes

If you want to contribute by editing an existing vignette, just edit the 
corresponding `Rmd` file stored in the `vignettes/articles/` folder.

If you want to contribute by adding a new vignette, create a new `Rmd` in the 
`vignettes/articles/` folder and add the following header:

```yaml
---
title: "Vignette Title"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Vignette Title}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---
```

If you use a new external dependency, do not forget to add it in the `DESCRIPTION` 
file under the section `Suggests` (only if this package is not already listed 
under the tag `Imports`).

Check the integrity of the package with: 

```r
devtools::check()
```

#### Editing function documentation

If you want to contribute by improving the documentation of a function, open 
the corresponding file in the `R/` folder and edit lines starting with `#'` 
([roxygen2](https://roxygen2.r-lib.org/articles/roxygen2.html) syntax).

Update the documentation (`Rd` files in the `man/` folder) by running:

```r
devtools::document()
```

If you use a new external dependency in the example section, do not forget to 
add it in the `DESCRIPTION` file under the section `Imports` (only if this 
package is not already listed).

Check the integrity of the package with: 

```r
devtools::check()
```


### Fix bug

If you want to contribute by improving the code of a function, open and edit 
the corresponding file in the `R/` folder.

Check the integrity of the package with: 

```r
devtools::check()
```

Do not forget to adapt the 
[unit tests](https://r-pkgs.org/testing-basics.html#introducing-testthat) for 
the function by editing the corresponding file stored in the `tests/testthat/` 
folder. We use the package [`testthat`](https://testthat.r-lib.org/) to 
implement unit tests.

Check your tests by running:

```r
devtools::test()
```


### New feature

If you want to contribute by submitting a new feature, please follow this 
workflow:

1. Create a new `R` file in the folder `R/`.
2. Implement the code of the function.
3. Document your function w/ the [roxygen2](https://roxygen2.r-lib.org/articles/roxygen2.html) syntax.
4. If necessary, add additional dependencies in the `DESCRIPTION` file.
5. Update the package documentation w/ `devtools::document()`.
6. Create a new `R` file in the folder `tests/testthat/`.
7. Implement [unit tests](https://r-pkgs.org/testing-basics.html#introducing-testthat) for the new function.
8. Check the integrity of the package w/ `devtools::check()`.

