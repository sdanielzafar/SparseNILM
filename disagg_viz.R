# This script visualizes the results of disagg_NAV

cat("\n-----------------------------------------------------------------------------")
cat("\n-----------------------------------------------------------------------------")
cat("\nDisaggregated Load Plot (R) -------------------------------------------------")
cat("\n-----------------------------------------------------------------------------")
cat("\n------------------------------------------------------------S Daniel Zafar---")

args = commandArgs(trailingOnly=TRUE)

if (length(args) != 1) {
  stop("You need to add the out csv file name after the program as an arg", call.=FALSE)
}

suppressMessages(require(dplyr))
suppressMessages(require(tidyr))
suppressMessages(require(ggplot2))

# name of the csv from disagg_NAV
file_name = args[1]
frac = 1/200 # only visualizing a portion of the data

# name of the whole-house comparison data
cat(paste0("\n\nReading in ",file_name,".csv...\n"))
data <- read.csv(file.path("csvs",paste0(file_name,".csv")))

labels = ls(data)[ls(data) != "TimeStamp" & 
                    ls(data) != "Time" & 
                    ls(data) != "X"]

cat("\nConstructing plot...\n")
cat("\tLabels being plotted are:",labels)

plot <- data %>%
  select_(.dots = labels) %>%
  mutate(TimeStamp = 1:nrow(data)) %>%
  gather_("Meter","Demand",c(labels)) %>% 
  filter(TimeStamp < (diff(range(TimeStamp))*frac+range(TimeStamp)[1])) %>%
  ggplot(aes(TimeStamp, Demand, color = Meter)) +
  geom_line()

cat(paste0("\n\nSaving plot to: \n",file.path("Visualization",paste0(file_name,".png...\n"))))
png(file.path("\nVisualization",paste0(file_name,".png")),
    height = 3, width = 8, units = "in", res = 300)
plot
dev.off()

cat("\nCompleted Successfully!\n")