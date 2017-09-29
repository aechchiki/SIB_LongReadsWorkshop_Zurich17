# a collection of functions for printing tables in all useful formats

# markdown (github wiki)
print.mdtable <- function(tabletoprint){
  num_of_cols <- ncol(tabletoprint)
  # sizes of all elements in data frame
  element_sizes <- apply(tabletoprint, 2, nchar)
  # add header as well
  element_sizes <- rbind(nchar(colnames(tabletoprint)), element_sizes)
  column_widths <- apply(element_sizes, 2, max)

# header
  for(i in 1:num_of_cols){
    colname_length <- element_sizes[1,i]
    filling <- paste0(rep(' ', column_widths[i] - colname_length), collapse = '')
    cat(paste0('| ', colnames(tabletoprint)[i], filling, ' '))
  }
  cat('|\n')

# |--|--| line
  for(i in 1:num_of_cols){
    filling <- paste0(rep('-', column_widths[i]), collapse = '')
    cat(paste0('| ', filling, ' '))
  }
  cat('|\n')

# content
  for(row in 1:nrow(tabletoprint)){
    for(i in 1:num_of_cols){
      content_length <- nchar(as.character(tabletoprint[row,i]))
      filling <- paste0(rep(' ', column_widths[i] - content_length), collapse = '')
      cat(paste0('| ', tabletoprint[row, i], filling, ' '))
    }
    cat('|\n')
  }
}
