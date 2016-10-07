# This script visualizes the results of disagg_NAV

args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("You need to add the out csv file name after the program as an arg", call.=FALSE)
}

require(dplyr)
require(tidyr)
require(ggplot2)

cat(paste(getwd(),"\n"))

# name of the csv from disagg_NAV
#file_name = "AMPds_heatpump_furnace_dryer_noise_3st" # this was replaced by the trailing args
file_name = args[1]
frac = 1/200

# name of the whole-house comparison data
cat(paste0("Reading in ",file_name,".csv...\n"))
data <- read.csv(file.path("csvs",paste0(file_name,".csv")))

labels = ls(data)[ls(data) != "X"]

cat("Constructing plot...\n")
cat("\tLabels being plotted are:",labels)

plot <- data %>%
  select_(.dots = labels) %>%
  mutate(TimeStamp = 1:nrow(data)) %>%
  gather_("Meter","Demand",c(labels)) 
  
a <- plot %>% 
  filter(TimeStamp < (diff(range(TimeStamp))*frac+range(TimeStamp)[1])) %>%
  ggplot(aes(TimeStamp, Demand, color = Meter)) +
  geom_line()

cat(paste0("\nSaving plot to: ",file.path("Visualization",paste0(file_name,".png...\n"))))
png(file.path("Visualization",paste0(file_name,".png")),
    height = 3, width = 8, units = "in", res = 300)
a
dev.off()

cat("\nCompleted Successfully!\n")