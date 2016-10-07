@echo on
CD /D Y:\MA Utilities\Residential\RES 1 -Residential Baseline Study\Analysis\NILM\SparseNILM
python train_SSHMM.py AMPds_heatpump_furnace_dryer_denoise_3st AMPdsR1_1min_A 1 104 denoised 3 1 HPE,FRE,CDE
python disagg_NAV.py AMPds_heatpump_furnace_dryer_denoise_3st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_denoise_3st

python train_SSHMM.py AMPds_heatpump_furnace_dryer_noise_3st AMPdsR1_1min_A 1 104 noised 3 1 HPE,FRE,CDE
python disagg_NAV.py AMPds_heatpump_furnace_dryer_noise_3st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_noise_3st

python train_SSHMM.py AMPds_heatpump_furnace_dryer_others_denoise_3st AMPdsR1_1min_A 1 104 denoised 3 1 HPE,FRE,CDE,UTE,GRE,TVE
python disagg_NAV.py AMPds_heatpump_furnace_dryer_others_denoise_3st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_others_denoise_3st

python train_SSHMM.py AMPds_heatpump_furnace_dryer_others_noise_3st AMPdsR1_1min_A 1 104 denoised 3 1 HPE,FRE,CDE,UTE,GRE,TVE
python disagg_NAV.py AMPds_heatpump_furnace_dryer_others_noise_3st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_others_noise_3st

python train_SSHMM.py AMPds_90%_denoise_3st AMPdsR1_1min_A 1 104 denoised 3 1 HPE,FRE,CDE,UTE,GRE,TVE,FGE,EQE,BME,OFE
python disagg_NAV.py AMPds_90%_denoise_3st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_90%_denoise_3st

python train_SSHMM.py AMPds_90%_noise_3st AMPdsR1_1min_A 1 104 noised 3 1 HPE,FRE,CDE,UTE,GRE,TVE,FGE,EQE,BME,OFE
python disagg_NAV.py AMPds_90%_noise_3st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_90%_noise_3st

python train_SSHMM.py AMPds_heatpump_furnace_dryer_denoise_4st AMPdsR1_1min_A 1 104 denoised 4 1 HPE,FRE,CDE
python disagg_NAV.py AMPds_heatpump_furnace_dryer_denoise_4st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_denoise_4st

python train_SSHMM.py AMPds_heatpump_furnace_dryer_noise_4st AMPdsR1_1min_A 1 104 noised 4 1 HPE,FRE,CDE
python disagg_NAV.py AMPds_heatpump_furnace_dryer_noise_4st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_noise_4st

python train_SSHMM.py AMPds_heatpump_furnace_dryer_others_denoise_4st AMPdsR1_1min_A 1 104 denoised 4 1 HPE,FRE,CDE,UTE,GRE,TVE
python disagg_NAV.py AMPds_heatpump_furnace_dryer_others_denoise_4st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_others_denoise_4st

python train_SSHMM.py AMPds_heatpump_furnace_dryer_others_noise_4st AMPdsR1_1min_A 1 104 denoised 4 1 HPE,FRE,CDE,UTE,GRE,TVE
python disagg_NAV.py AMPds_heatpump_furnace_dryer_others_noise_4st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_others_noise_4st

python train_SSHMM.py AMPds_90%_denoise_4st AMPdsR1_1min_A 1 104 denoised 4 1 HPE,FRE,CDE,UTE,GRE,TVE,FGE,EQE,BME,OFE
python disagg_NAV.py AMPds_90%_denoise_4st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_90%_denoise_4st

python train_SSHMM.py AMPds_90%_noise_4st AMPdsR1_1min_A 1 104 noised 4 1 HPE,FRE,CDE,UTE,GRE,TVE,FGE,EQE,BME,OFE
python disagg_NAV.py AMPds_90%_noise_4st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_90%_noise_4st

pause
