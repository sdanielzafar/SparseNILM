args = commandArgs(trailingOnly=TRUE)

cat("\n-----------------------------------------------------------------------------")
cat("\n-----------------------------------------------------------------------------")
cat("\nDisaggregated Appliance Comparison Plot (R) ---------------------------------")
cat("\n-----------------------------------------------------------------------------")
cat("\n------------------------------------------------------------S Daniel Zafar---\n")

if (length(args) != 2) {
  stop("You need to add: 1) out csv file name and 2) truth data as args after the program", call.=FALSE)
}

suppressMessages(require(dplyr))
suppressMessages(require(tidyr))
suppressMessages(require(ggplot2))
suppressMessages(require(lubridate))

# args <- c("eGauge_AC_CDE_FGE_hold511","eGauge_AC_CDE_FGE_511")
# setwd("Y:/MA Utilities/Residential/RES 1 -Residential Baseline Study/Analysis/NILM/SparseNILM")
# name of the csv from disagg_NAV
disagg_name = args[1]
truth_name = args[2]
frac = 1/400

cat(paste0("\nReading in disaggregated data: \n\t",disagg_name,".csv..."))
est <- read.csv(file.path("csvs",paste0(disagg_name,".csv"))) 

cat(paste0("\nReading in truth data: \n\t",truth_name,".csv...\n"))
obs <- read.csv(file.path("datasets",paste0(truth_name,".csv"))) 


labels = ls(est)[ls(est) != "X" & 
                   !grepl("Time",ls(est)) &
                   ls(est) != "MAIN"]

# Appliance Visualization on time series plot
cat("\nPreparing the timeseries appliance dissag plot")
cat("\n\tPreparing data...\n")
est_plot <- est %>%
  select_(.dots = labels) %>%
  mutate(TimeStamp = 1:nrow(est)) %>%
  gather_("Meter","Est",labels) %>%
  mutate(Est = as.numeric(Est))

obs_plot <- obs %>%
  mutate(TimeStamp = 1:nrow(obs)) %>%
  select_(.dots = labels) %>% 
  mutate(TimeStamp = 1:nrow(obs)) %>%
  gather_("Meter","Obs",labels)

if (length(labels) < 4) cols = 1
if (length(labels) > 3 & length(labels) < 6) cols = 2
if (length(labels) >= 6 & length(labels) < 10) cols = 3
if (length(labels) >= 10) cols = 4

cat("\n\tConstructing plot...\n")
cat("\t\tLabels being plotted are:",labels)
plot <- est_plot %>%
  filter(TimeStamp < (diff(range(TimeStamp))*frac+range(TimeStamp)[1])) %>%
  left_join(obs_plot, by = c("TimeStamp","Meter")) %>%
  gather("Type","Demand",Est:Obs) %>% 
  ggplot(aes(x=TimeStamp, y=Demand, color = Type)) +
  geom_line(aes(linetype=Type)) +
  facet_wrap( ~ Meter, ncol = cols)

plotHeight <- function(x){
  if (x == 6) return(3)
  if (x == 4) return(5)
  if (x < 4) return(5*(x/3))
  if (x > 4) return(7)
}
cat(paste0("\n\n\tSaving plot to: \n\t",file.path("Visualization",paste0(disagg_name,"_apps.png...\n"))))
png(file.path("Visualization",paste0(disagg_name,"_apps.png")),
    height = plotHeight(length(labels)), width = 6, units = "in", res = 300)
plot
dev.off()

cat("\nCompleted Successfully!\n")

# Appliance Loadshape Vizualization plot
cat("\nPreparing the loadshape")
cat("\n\tPreparing data...\n")

# this plot is only set up for the Blueline/eGauge data
join_obs <- obs %>% 
  mutate(TimeStamp = as.character(TimeStamp),
         TimeStamp = as.POSIXct(TimeStamp, format = "%Y-%m-%dT%H:%M:%SZ", tz="EST"),
         Hour = hour(TimeStamp)) %>% 
  select_(.dots=c("Hour", labels)) %>%  
  rename_(.dots = setNames(labels,paste("Obs_",labels, sep=""))) %>% 
  group_by(Hour) %>% 
  summarise_each(funs(mean))

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
    height = 4, width = 6, units = "in", res = 300)
plot
dev.off()


