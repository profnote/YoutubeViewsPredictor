# YoutubeViewMR.R
#
# Niti Wattanasirichaigoon
#
# This script executes a MepReduce job
#  the mapper selects the important fields in the video dataset file in HDFS
#  the reducer aggregates the data into a dataframe trains a linear model and makes a prediction
#   *the test data point is hardcoded

library(rmr2)
# Set environment for working with hadoop (these locations will vary by machine)
Sys.setenv(HADOOP_CMD="/usr/bin/hadoop")
Sys.setenv(HADOOP_STREAMING="/usr/hdp/2.6.4.0-91/hadoop-mapreduce/hadoop-streaming.jar")

mapper <- function(null, line) {
  # key=cat_id, val=(subscribers, duration, views(after one week))
  return(keyval(line[[5]], paste(line[[3]], line[[6]], line[[7]], sep=",")))
}

reducer <- function(key, val.list) {
  list <- list()
  # separate fields
  for (line in val.list) {
    row <- unlist(strsplit(line, split=","))
    list[[length(list+1)]] <- row
  }
  # create dataframe
  frame <- do.call(rbind, list)
  mode(frame) = "numeric"
  df <- data.frame(frame)
  colnames(df) <- c("subscribers", "dur", "views")
  
  ##** This part failed to work during mapreduce for unknown reasons  **##
  # remove outliers by cook's distance
  #mod <- lm(views ~ subscribers + factor(cat_id) + dur, data = df)
  #cdist <- cooks.distance(mod)
  #influential <- as.numeric(names(cdist)[(cdist > 4*mean(cdist))])
  #vid_data <- df[-influential,]
  
  # train linear model
  lmfit <- lm(views ~ subscribers + dur, data = df) # data=vid_data if able to omit outliers
  
  # predict our test point
  # change the test values here: data.frame(<subscribers>, <duration>)
  test <- data.frame(50000, 500) 
  colnames(test) <- c("subscribers", "dur")
  results <- predict(lmfit, newdata = test)
  return(keyval(key, results))
}

# call MapReduce job
mapreduce(input="/user/maria_dev/video_data.csv",  #location of video dataset file in hdfs
  input.format=make.input.format("csv", sep = ","),
  output="/user/maria_dev/test_result", #location of output directory in hdfs
  output.format="csv",
  map=mapper,
  reduce=reducer
)
