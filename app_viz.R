args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("You need to add: 1) out csv file name and 2) truth data as args after the program", call.=FALSE)
}

require(dplyr)
require(tidyr)
require(ggplot2)

# args <- c("AMPds_heatpump_furnace_dryer_noise_3st","AMPdsR1_1min_A")
# name of the csv from disagg_NAV
disagg_name = args[1]
truth_name = args[2]
frac = 1/400

cat(paste0("Reading in disaggregated data: \n",disagg_name,".csv...\n"))
est <- read.csv(file.path("csvs",paste0(file_name,".csv"))) 

cat(paste0("Reading in truth data: \n",truth_name,".csv...\n"))
obs <- read.csv(file.path("datasets",paste0(truth_name,".csv"))) %>% 
  mutate(TimeStamp = 1:nrow(obs))

labels = ls(est)[ls(est) != "X"]

cat("Preparing data...\n")
est_plot <- est %>%
  select_(.dots = labels) %>%
  mutate(TimeStamp = 1:nrow(est)) %>%
  gather_("Meter","Est",c(labels)) 

obs_plot <- obs %>%
  select_(.dots = labels) %>% 
  mutate(TimeStamp = 1:nrow(obs)) %>%
  gather_("Meter","Obs",c(labels))

if (length(labels) < 4) cols = 1
if (length(labels) > 3 & length(labels) < 6) cols = 2
if (length(labels) >= 6 & length(labels) < 10) cols = 3
if (length(labels) >= 10) cols = 4

cat("Constructing plot...\n")
cat("\tLabels being plotted are:",labels)
plot <- est_plot %>%
  filter(TimeStamp < (diff(range(TimeStamp))*frac+range(TimeStamp)[1])) %>%
  left_join(obs_plot, by = c("TimeStamp","Meter")) %>%
  gather("Type","Demand",Est:Obs) %>% 
  ggplot(aes(x=TimeStamp, y=Demand, color = Type)) +
  geom_line(aes(linetype=Type)) +
  facet_wrap( ~ Meter, ncol = cols)

plotheight <- function(x){
  if (x == 6) return(3)
  if (x < 4) return(x*5)
  if (x > 4) return(7)
}
cat(paste0("\nSaving plot to: ",file.path("Visualization",paste0(disagg_name,"_apps.png...\n"))))
png(file.path("Visualization",paste0(disagg_name,"_apps.png")),
    height = plotheight(length(labels)), width = 6, units = "in", res = 300)
plot
dev.off()

cat("\nCompleted Successfully!\n")