@echo on
CD /D Y:\MA Utilities\Residential\RES 1 -Residential Baseline Study\Analysis\NILM\SparseNILM
REM python train_SSHMM.py AMPds_heatpump_furnace_dryer_denoise_3st AMPdsR1_1min_A 1 104 denoised 3 1 HPE,FRE,CDE
REM python disagg_NAV.py AMPds_heatpump_furnace_dryer_denoise_3st AMPdsR1_1min_A_ 1 A 
python train_SSHMM.py AMPds_heatpump_furnace_dryer_noise_3st AMPdsR1_1min_A 1 104 noised 3 1 HPE,FRE,CDE
python disagg_NAV.py AMPds_heatpump_furnace_dryer_noise_3st AMPdsR1_1min_A_ 1 A 
python train_SSHMM.py AMPds_heatpump_furnace_dryer_others_denoise_3st AMPdsR1_1min_A 1 104 denoised 3 1 HPE,FRE,CDE,UTE,GRE,TVE
python disagg_NAV.py AMPds_heatpump_furnace_dryer_others_denoise_3st AMPdsR1_1min_A_ 1 A 
python train_SSHMM.py AMPds_heatpump_furnace_dryer_others_noise_3st AMPdsR1_1min_A 1 104 denoised 3 1 HPE,FRE,CDE,UTE,GRE,TVE
python disagg_NAV.py AMPds_heatpump_furnace_dryer_others_noise_3st AMPdsR1_1min_A_ 1 A 
