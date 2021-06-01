#' Plot pie chart
#'
#' @param data specify data file i.e. global_raw
#' @param variable specify variable you want in pie chart
#' @param filter_response filter response options e.g. c(1:4) to get rid of other values - cleaner plot
#' @param title specify title
#' @param filllab title = "An awesome pie chart"
#' @param labels use to relabel value e.g. c("Male", "Female")
#' @param number_font_size respecify the font size in case it doesnt fit
#' @param return do you want to get the data or plot
#'
#' @return
#' @export
#'
#' @examples
#' plot_pie_chart(data = iCARE,
#'                variable = sex,
#'                filter_response=c(1:2),
#'                title = "Sex distribution",
#'                labels = c("Male", "Female"),
#'                number_font_size = 6,
#'                return = "plot")
plot_pie_chart <- function(data,
                           variable,
                           filter_response = NULL,
                           title = NULL,
                           filllab = NULL,
                           labels = NULL,
                           number_font_size = 4,
                           return = c("plot", "data")) {

  return <- match.arg(return)

  data_temp <- data %>%
    dplyr::select({{variable}}) %>%
    tidyr::pivot_longer(cols = {{variable}},
                 names_to = "variable") %>%
    dplyr::group_by(variable, value) %>%
    dplyr::count() %>%
    tidyr::drop_na() %>%
    dplyr::group_by(variable)%>%
    dplyr::mutate(sum_group = sum(n),
           prop = n / sum_group * 100)

  if(is.null(filter_response)) {
    data_temp <- data_temp
  } else
  {data_temp <- data_temp %>%
    dplyr::filter(value %in% filter_response)
  }
  # set the theme for the plot
  blank_theme <- ggplot2::theme_minimal()+
    ggplot2::theme(axis.title.x = ggplot2::element_blank(),
          axis.title.y = ggplot2::element_blank(),
          panel.border = ggplot2::element_blank(),
          panel.grid = ggplot2::element_blank(),
          axis.ticks = ggplot2::element_blank(),
          axis.text.x = ggplot2::element_blank(),
          plot.title = ggplot2::element_text(size = 15, hjust = 0.5, vjust = 1))

  plot <- data_temp %>%
    ggplot(aes(x =  "", y = n, fill = factor(value)))+
    geom_bar(stat = "identity") +
    coord_polar("y", start = 0)+
    labs(fill = filllab, title = title) +
    blank_theme +
    geom_text(aes(label = paste(round(n / sum(n) * 100, 1), "%")),
              color = "black", size = number_font_size,
              position = position_stack(vjust = 0.5))

  if(return == "data"){

    return(data_temp)

  }
  if(return == "plot"){
    if(is.null(labels)){
      return(plot)
    }else{
      return(plot + scale_fill_discrete(labels = labels))
    }
  }
}


#' Plot time trend
#'
#' @param data Data object
#' @param variables  which variables do you want to see
#' @param time_variable choose between month or wave
#' @param filter_value  which value of response e.g. 1 - most of the time
#' @param title specify title
#' @param xlab specify xlab
#' @param ylab specify ylab
#' @param var_names to relabel the header on the plot
#' @param max_value adjust the y axis
#' @param color change the color, available range = 0-1
#' @param return do you want to get data or plot -- I like this to
#'
#' @return
#' @export
#'
#' @examples
#' plot_time_trend(data = iCARE,
#'                 variables = c(impacvd_sq003, impacvd_sq001, impacvd_sq002),
#'                 filter_value = 1,
#'                 time_variable = month, # test out for month if you wish
#'                 var_names = c("impacvd_sq003" = "Depression",
#'                               "impacvd_sq001" = "Anxiety",
#'                               "impacvd_sq002" = "Loneliness"),
#'                 max_value = 25,
#'                 title = "Trend over waves of survey",
#'                 return = "plot")

plot_time_trend <- function(data,
                            variables,
                            time_variable,
                            filter_value = 1,
                            title = NULL,
                            xlab = NULL,
                            ylab = NULL,
                            var_names = NULL,
                            max_value = 100,
                            color = 0.5,
                            return = c("data", "plot")){

  data$month<-as.Date(data$startdate)
  data$month<- factor(format(data$month,'%Y-%m'))

  data_temp <- data %>%
    pivot_longer(cols = {{variables}},
                 names_to = "variable") %>%
    group_by({{time_variable}}, variable, value) %>%
    count() %>%
    group_by({{time_variable}}, variable) %>%
    mutate(sum_month_status = sum(n),
           prop_most_time = n / sum_month_status * 100) %>%
    filter(value == filter_value)

  if(return == "data"){
    return(data_temp)
  }
  if(return == "plot"){
    return(
      data_temp %>%
        ggplot(aes(x = {{time_variable}})) +
        geom_col(aes(y = prop_most_time, fill = "")) +
        scale_fill_viridis_d(begin = color) +
        facet_wrap(~variable, labeller = as_labeller(var_names)) +
        labs(title = title, x = xlab, y = ylab) +
        ylim(0, max_value) +
        theme_bw() +
        theme(legend.position = "none",
              axis.text.x = element_text(angle = 45, hjust = 1))
    )
  }
}

