# Check imbalance of data
table(imbalanceddata$Vaccination_Status)
round(prop.table(table(imbalanceddata$Vaccination_Status)),4)*100
ggplot(data = imbalanceddata, aes(x = Vaccination_Status, fill = Vaccination_Status)) +
  geom_bar(stat="count") +
  xlab("Vaccination Status") + ylab("Number of Individuals") +
  theme(axis.text=element_text(size=18), axis.title=element_text(size=18)) +
  theme(plot.title = element_text(size=30, face="bold")) +
  ggtitle("Comparison of Vaccination Rates") +
  theme(plot.title = element_text(hjust = 0.5))

# Treat imbalanced data
#Undersample
under_trains <- ovun.sample(Vaccination_Status ~ ., data = training, method = "under", N = 9700, seed = 1)$data
table(under_trains$Vaccination_Status)
set.seed(322)
under_model <- randomForest(Vaccination_Status~., data = under_trains)
under_pred <- predict(under_model, test)
under_cm <- confusionMatrix(test$Vaccination_Status, under_pred)
under_cm

# Mixture- minority class is oversampled and majority class is undersampled
both_trains <- ovun.sample(Vaccination_Status ~ ., data = training, method = "both", p=0.5, N=11400, seed = 1)$data
table(both_trains$Vaccination_Status)
set.seed(2323)
both_model <- randomForest(Vaccination_Status~., data = both_trains)
both_pred <- predict(both_model, test)
both_cm <- confusionMatrix(test$Vaccination_Status, both_pred)
both_cm
# SYnthetically generate data using ROSE
synth_trains <- ROSE(Vaccination_Status ~ ., data = training, seed = 1)$data
table(synth_trains$Vaccination_Status)
synth_model <- randomForest(Vaccination_Status~., data = synth_trains)
synth_pred <- predict(synth_model, test)
synth_cm <- confusionMatrix(test$Vaccination_Status, synth_pred)
synth_cm

# Oversample
over_trains <- ovun.sample(Vaccination_Status ~ ., data = training, method = "over",N = 36200)$data
table(over_trains$Vaccination_Status)
set.seed(3232)
over_model <- randomForest(Vaccination_Status~., data = over_trains)
over_pred <- predict(over_model, test)
over_cm <- confusionMatrix(test$Vaccination_Status, over_pred)
over_cm

# Check performance of each sampling method based on accuracy of Random Forest
compare_samples <- rbind(over_cm$overall, synth_cm$overall, both_cm$overall, under_cm$overall)
compare_samples <- as.data.frame(compare_samples)
compare_samples$Method <- c('Oversampled', 'Synthetic Data', 'Under/Oversampled', 'Undersampled')

# use oversampling as training data
trains <- over_trains
