#' Check if all Columns are Present
#'
#' `check_cols` creates a *specification* of a recipe
#'  step that will check if all the columns of the training frame are
#'  present in the new data.
#'
#' @inheritParams check_missing
#' @export
#' @param id A character string that is unique to this step to identify it.
#' @details This check will break the `bake` function if any of the checked
#'  columns does contain `NA` values. If the check passes, nothing is changed
#'  to the data.
#' @examples
#'
#' library(modeldata)
#' data(biomass)
#'
#' biomass_rec <- recipe(HHV ~ ., data = biomass) %>%
#'    step_rm(sample, dataset) %>%
#'    check_cols(contains("gen")) %>%
#'    step_center(all_predictors())
#'
#' \dontrun{
#' bake(biomass_rec, biomass[, c("carbon", "HHV")])
#' }
check_cols <-
  function(recipe,
           ...,
           role = NA,
           trained = FALSE,
           skip = FALSE,
           id = rand_id("cols")) {
    add_check(
      recipe,
      check_cols_new(
        terms   = ellipse_check(...),
        role    = role,
        trained = trained,
        columns = NULL,
        skip = skip,
        id = id
      )
    )
  }

check_cols_new <-
  function(terms, role, trained, columns, skip, id) {
    check(subclass = "cols",
          prefix   = "check_",
          terms    = terms,
          role     = role,
          trained  = trained,
          columns  = columns,
          skip     = skip,
          id       = id)
  }

prep.check_cols <- function(x, training, info = NULL, ...) {
  col_names <- terms_select(x$terms, info = info)
  check_cols_new(
    terms = x$terms,
    role  = x$role,
    trained = TRUE,
    columns = col_names,
    skip = x$skip,
    id = x$id
  )
}

bake.check_cols <- function(object, new_data, ...) {
  original_cols <- object$columns
  new_cols      <- names(new_data)
  missing <- setdiff(original_cols, new_cols)
  if (length(missing) > 0) {
    mis_cols <- paste(paste0("`", missing, "`"), collapse = ", ")
    stop("The following cols are missing from `new_data`: ",
         mis_cols, ".", call. = FALSE)
  }
  new_data
}

print.check_cols <-
  function(x, width = max(20, options()$width - 30), ...) {
    cat("Check if the following columns are present: ", sep = "")
    printer(x$columns, x$terms, x$trained, width = width)
    invisible(x)
  }

#' @rdname check_cols
#' @param x A `check_cols` object.
#' @export
tidy.check_cols <- function(x, ...) {
  if (is_trained(x)) {
    res <- tibble(terms = x$columns)
  } else {
    res <- tibble(terms = sel2char(x$terms))
  }
  res$id <- x$id
  res
}

