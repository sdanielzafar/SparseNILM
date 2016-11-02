# House vizualization

args = commandArgs(trailingOnly=TRUE)

cat("\n-----------------------------------------------------------------------------")
cat("\n-----------------------------------------------------------------------------")
cat("\nHouse Appliance Loadshape Plot (R) ------------------------------------------")
cat("\n-----------------------------------------------------------------------------")
cat("\n------------------------------------------------------------S Daniel Zafar---\n")

if (length(args) != 2) {
  stop("You need to add: \n1. Out csv file name for the house in question \n2. The list of appliances", call.=FALSE)
}

suppressMessages(require(dplyr))
suppressMessages(require(tidyr))
suppressMessages(require(ggplot2))
suppressMessages(require(lubridate))

house_name = args[1]
apps = strsplit(args[2], split = ',')[[1]]

cat(paste0("\nReading in house data: \n\t",house_name,".csv...\n"))
obs <- read.csv(file.path("datasets",paste0(house_name,".csv")))

labels = c("MAIN", apps)

plot = obs %>% 
  mutate(TimeStamp = as.character(TimeStamp),
         TimeStamp = as.POSIXct(TimeStamp, format = "%Y-%m-%dT%H:%M:%SZ", tz="EST")) %>% 
  mutate(Hour = hour(TimeStamp)) %>% 
  select_(.dots=c("Hour", labels)) %>%  
  group_by(Hour) %>% 
  summarise_each(funs(mean)) %>% 
  gather_("Type","Demand",labels) %>% 
  ggplot(aes(x=Hour, y=Demand, color=Type)) +
  geom_line() + 
  ggtitle("Hourly Loadshapes (Observed)")

cat(paste0("\n\n\tSaving House Loadshape plot to: \n\t",file.path("Visualization",paste0(house_name,"_loadshape.png...\n"))))
png(file.path("Visualization",paste0(house_name,"_loadshape_obs.png")),
    height = 4, width = 6, units = "in", res = 300)
plot
dev.off()

cat("\nCompleted Successfully!\n")