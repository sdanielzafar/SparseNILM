# House vizualization

args = commandArgs(trailingOnly=TRUE)

cat("\n-----------------------------------------------------------------------------")
cat("\n-----------------------------------------------------------------------------")
cat("\nDisaggregated Appliance Comparison Plot (R) ---------------------------------")
cat("\n-----------------------------------------------------------------------------")
cat("\n------------------------------------------------------------S Daniel Zafar---\n")

if (length(args) != 1) {
  stop("You need to add: out csv file name for the house in question", call.=FALSE)
}

plot = est %>% 
  mutate(TimeStamp = as.character(TimeStamp),
         TimeStamp = as.POSIXct(TimeStamp, format = "%Y-%m-%dT%H:%M:%SZ", tz="EST")) %>% 
  mutate(Hour = hour(TimeStamp)) %>% 
  select_(.dots=c("Hour", labels)) %>%  
  group_by(Hour) %>% 
  summarise_each(funs(mean)) %>% 
  rename_(.dots = setNames(labels,paste("Est_",labels, sep=""))) %>% 
  left_join(join_obs, by = "Hour") %>% 
  gather_("Type","Demand",c(paste("Est_",labels, sep=""),paste("Obs_",labels, sep=""))) %>% 
  ggplot(aes(x=Hour, y=Demand, color=Type)) +
  geom_line() + 
  ggtitle("Hourly Loadshapes")

cat(paste0("\n\n\tSaving Loadshape plot to: \n\t",file.path("Visualization",paste0(disagg_name,"_loadshape.png...\n"))))
png(file.path("Visualization",paste0(disagg_name,"_loadshape.png")),
    height = plotHeight(4, width = 6, units = "in", res = 300))
plot
dev.off()