# This script visualizes the results of disagg_NAV

library(dplyr)
library(tidyr)
library(ggplot2)

# name of the csv from disagg_NAV
file_name = "AMPds_heat_fridge_clothes_oven_denoise.csv"

# name of the whole-house comparison data
house_data = "AMPdsR1_1min_A_.csv"
house <- read.csv(file.path("../for_dissag",house_data))

data <- read.csv(file.path("../csvs",file_name))

plot <- data %>%
  bind_cols(house %>% slice(-1)) %>%
  select(TimeStamp, Whle_Hs = WHE, Frnce = FRE, Clth_Dryr = CDE, Frge = FGE, Ovn = WOE) %>%
  gather("Meter","Demand",Whle_Hs:Ovn)

a <- plot %>% 
  filter(TimeStamp < (diff(range(TimeStamp))/200+range(TimeStamp)[1])) %>%
  ggplot(aes(TimeStamp, Demand, color = Meter)) +
  geom_line()
a