# This script visualizes the results of disagg_NAV

require(dplyr)
require(tidyr)
require(ggplot2)

cat(paste(getwd(),"\n"))

# name of the csv from disagg_NAV
file_name = "AMPds_heatpump_furnace_dryer_noise_3st"
house_data = "AMPdsR1_1min_A_.csv"
frac = 1/200

# name of the whole-house comparison data
house <- read.csv(file.path("for_dissag",house_data))

cat(paste0("Reading in ",file_name,".csv...\n"))
data <- read.csv(file.path("csvs",paste0(file_name,".csv")))

labels = ls(data)[ls(data) != "X"]
glimpse(data %>%
  select_(.dots = labels))

cat("Constructing plot...\n")
plot <- house %>% 
  slice(-1) %>%
  bind_cols(data) %>%
  select_("TimeStamp","WHE", .dots = labels) %>%
  gather_("Meter","Demand",c("WHE",labels))

a <- plot %>% 
  filter(TimeStamp < (diff(range(TimeStamp))*frac+range(TimeStamp)[1])) %>%
  ggplot(aes(TimeStamp, Demand, color = Meter)) +
  geom_line()

cat(paste0("Saving plot to: ",file.path("Visualization",paste0(file_name,".png...\n"))))
png(file.path("Visualization",paste0(file_name,".png")),
    height = 3, width = 8, units = "in", res = 300)
a
dev.off()

cat("Completed Successfully!\n")