#' Inspect missingness
#'
#' @param data Data object
#' @param min_value do you to see all, or say just those vars that have missigness above 0.2 - can specify, default = 0
#' @param filter_var specify variable for filtering
#' @param filter_value specify value for filtering in filter_var
#'
#' @return
#' @export
#'
#' @examples
#' inspect_missing(iCARE, min_value = .9)
inspect_missing <- function(data,
                            min_value = 0,
                            filter_var = NULL,
                            filter_value = NULL) {

  if(is.null(list(filter_var, filter_value))){
    data_temp <- data %>% filter({{filter_var}} %in% filter_value)
  }else{
    data_temp <- data
  }

  p_missing <- unlist(lapply(data_temp, function(x) sum(is.na(x))))/nrow(data_temp)

  message(paste0("Showing proportion of missing values in descending order above the level of: ", min_value, "."))
  round(sort(p_missing[p_missing > min_value], decreasing = TRUE), 2)
}
