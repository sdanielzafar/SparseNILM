@echo on
CD /D Y:\MA Utilities\Residential\RES 1 -Residential Baseline Study\Analysis\NILM\SparseNILM

Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_noise_3st
Rscript --vanilla app_viz.R AMPds_heatpump_furnace_dryer_noise_3st AMPdsR1_1min_A

Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_denoise_3st
Rscript --vanilla app_viz.R AMPds_heatpump_furnace_dryer_denoise_3st AMPdsR1_1min_A

pause
