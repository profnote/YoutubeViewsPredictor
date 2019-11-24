# ModelFitting.R
#
# Niti Wattanasirichaigoon
# Visualizes data, remove outliers
# Fits linear model: Views ~ subscriber count + category + duration
# Model evaluation, interpretation
# Get final model though 10 fold cross-validation

library(caret)
library(glmnet)

# import data
mydata <- read.csv("video_data.csv", header = F)
colnames(mydata) <- c("vid_id", "channel_id", "subscribers", "pub_date", "cat_id", "dur", "views")
categories <- c("Film & Animation", "Auto $ Vehicles", "Music", "Sports", "Travel & Events", "Gaming", "People & Blogs", "Comedy", "Entertainment", "News & Politics", "Howto & Style", "Education", "Science & Tech")

# data visualization
par(las=2, mar=c(8,6,4,2))
boxplot(views ~ cat_id, data = mydata, main = "Views by Category", srt=90, xaxt="n", xlab="")
axis(1, at=1:length(categories), labels = categories, srt=90)
dev.off()
plot(views ~ subscribers, data = mydata, main = "Views by Subscribers")

## Remove outliers by cook's distance
# view outliers and threshhold line
mod <- lm(views ~ subscribers + factor(cat_id) + dur, data = mydata)
cdist <- cooks.distance(mod)
plot(cdist, main="Influential Obs by Cook's Distance", ylab = "Cook's Distance")
abline(h = 4*mean(cdist), col='red')
# remove outliers from data
influential <- as.numeric(names(cdist)[(cdist > 4*mean(cdist))])
vid_data <- mydata[-influential,]

# train linear model
trainIndex <- createDataPartition(vid_data$views, p=0.8, list = F)
training <- vid_data[trainIndex,]
testing <- vid_data[-trainIndex,]
MLR <- lm(views ~ subscribers + factor(cat_id) + dur, data = training)
# predict values
train.pred <- predict(MLR, newdata = training)
test.pred <- predict(MLR, newdata = testing)
trainRMSE <- sqrt(mean((train.pred-training$views)^2))
testRMSE <- sqrt(mean((test.pred-testing$views)^2))

# 10 fold cross-validation
ctrl <- trainControl(method = "repeatedcv", number = 10,  repeats = 10)
cvfit <- train(views ~ subscribers + factor(cat_id) + dur, data = vid_data, method = 'lm', trControl = ctrl)
summary(cvfit)
summary(cvfit$results)
