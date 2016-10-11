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

args <- c("AMPds_heatpump_furnace_dryer_noise_3st","AMPdsR1_1min_A")
# name of the csv from disagg_NAV
disagg_name = args[1]
truth_name = args[2]
frac = 1/400

cat(paste0("\nReading in disaggregated data: \n\t",disagg_name,".csv..."))
est <- read.csv(file.path("csvs",paste0(disagg_name,".csv"))) 

cat(paste0("\nReading in truth data: \n\t",truth_name,".csv...\n"))
obs <- read.csv(file.path("datasets",paste0(truth_name,".csv"))) 

labels = ls(est)[ls(est) != "X" & !grepl("Time",ls(est))]

cat("\nPreparing data...\n")
est_plot <- est %>%
  select_(.dots = labels) %>%
  mutate(TimeStamp = 1:length(WHE)) %>%
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

cat("\nConstructing plot...\n")
cat("\tLabels being plotted are:",labels)
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
  if (x < 4) return(x*5)
  if (x > 4) return(7)
}
cat(paste0("\n\nSaving plot to: \n\t",file.path("Visualization",paste0(disagg_name,"_apps.png...\n"))))
png(file.path("Visualization",paste0(disagg_name,"_apps.png")),
    height = plotHeight(length(labels)), width = 6, units = "in", res = 300)
plot
dev.off()

cat("\nCompleted Successfully!\n")