# YouTube View Count Predictor
- CSP554 - Big Data Technologies - Final Project
- Illinois Institute of Technology
- Fall 2019 Semester

## Group Members
- Niti Wattanasirichaigoon
- Jingeun Jung
- Hyungtaeg Oh

## Contents
1. getVidData.py - python code for retrieving video data from the YouTube API
2. video_data.csv - one week old video data gathered on Nov, 16 2019. Fields = (vid_id, channel_id, subscribers, published_date, category_id, duration(s), views)
3. Hive Command - Hive codes for data analysis
4. Pig Command - Pig codes for data analysis
5. Spark Command - Spark codes for data analysis
6. ModelFitting.R - R codes for data preparation, linear model fit with cross-validation
7. YoutubeViewMR.R - R script for running mapreduce in Hadoop environment. Reads video_data.csv in hdfs, trains linear models for each category to use for view prediction.
