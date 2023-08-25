library(tidyverse)
library(readr)
library(tidyr)
# install.packages("ggpubr")
library(ggpubr)

folder = dirname(rstudioapi::getSourceEditorContext()$path)
data_directory = file.path(folder, '..', 'data')
setwd(data_directory)

# read the files
data <- read.csv("sample_immigration.csv")


# Reorder ideology_cluster from left -> right
data$ideology_cluster <- factor(
  data$ideology_cluster,
  
  levels = c(
    "Far Left",
    "Left Centrist",
    "Centrist",
    "Right Centrist",
    "Far Right"
  )
)

data$vote <- factor(data$vote,
                    levels = c("Aye",
                               "No"),
                    labels = c("Pro-immigration \n(H.R.6136)",
                               "Anti-immigration \n(H.R.6136)"))

data$sentiment <- factor(
  data$sentiment,
  levels = c("negative",
             "neutral",
             "positive"),
  labels = c("Negative",
             "Neutral",
             "Positive")
)

plot1 <- ggplot(data, aes(x = ideology_cluster, fill = sentiment)) +
  geom_bar(position = "dodge") +
  labs(title = "(A) Sentiment distribution by ideology cluster", x = "Ideology Cluster", y = "Count") +
  scale_fill_manual(values = c(
    "Negative" = "red",
    "Positive" = "green",
    "Neutral" = "blue"
  )) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_grid(cols = vars(vote)) +
  scale_fill_discrete(name = "Sentiment")

plot2 <-
  ggplot(data,
         aes(
           x = ideology,
           y = vader,
           color = ideology_cluster,
           shape = vote
         )) +
  geom_point(size = 3) +
  labs(title = "(B) VADER sentiment vs. ideology scores with hue and shape by vote",
       x = "Ideology Scores", y = "VADER Sentiment") +
  scale_color_discrete(name = "Ideology Cluster") +
  scale_shape_manual(name = "Vote", values = c("Anti-immigration \n(H.R.6136)" = 16, "Pro-immigration \n(H.R.6136)" = 17))

# Box plot of sentiment by ideology_cluster
plot3 <-
  ggplot(data, aes(x = ideology_cluster, y = vader, fill = vote)) +
  geom_boxplot() +
  labs(title = "(C) VADER sentiment scores per ideological group and vote", x = "Ideology Cluster", y = "VADER Sentiment") +
  scale_fill_discrete(name = "Vote")

# Plot a table matrix of the bert sentiment against manually annotated sentiment
sentiment_counts <- data %>%
  group_by(bert_sentiment, sentiment) %>%
  tally()

# Create the stacked bar plot
plot4 <-
  ggplot(sentiment_counts, aes(x = bert_sentiment, y = n, fill = sentiment)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "(D) BERT sentiment vs manually annotated sentiment)",
       x = "BERT Sentiment", y = "Count") +
  scale_fill_discrete(name = "Sentiment")

# change the font-size title in all the plots
change_title_font_size <- function(plot, size) {
  plot + theme(plot.title = element_text(size = size))
}

# Change title font size for each plot
plot1 <- change_title_font_size(plot1, size = 10)
plot2 <- change_title_font_size(plot2, size = 10)
plot3 <- change_title_font_size(plot3, size = 10)
plot4 <- change_title_font_size(plot4, size = 10)

arranged_plots <-
  ggarrange(plot1, plot2, plot3, plot4, ncol = 2, nrow = 2)

folder_out = file.path(folder, 'figures')
dir.create(folder_out, showWarnings = FALSE)

path_out = file.path(folder, 'figures', 'facet_plots.png')

# Display the arranged plots
ggsave(path_out,
       arranged_plots,
       width = 12,
       height = 8)

plot(arranged_plots)