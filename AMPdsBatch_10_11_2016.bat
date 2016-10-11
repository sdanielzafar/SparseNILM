@echo on
CD /D Y:\MA Utilities\Residential\RES 1 -Residential Baseline Study\Analysis\NILM\SparseNILM

python train_SSHMM.py AMPds_heatpump_furnace_dryer_noise_3st AMPdsR1_1min_A 1 104 noised 3 1 HPE,FRE,CDE
python train_SSHMM.py AMPds_heatpump_furnace_dryer_noise_3st_cv AMPdsR1_1min_A 1 104 noised 3 10 HPE,FRE,CDE
python test_Algorithm.py 11 AMPds_heatpump_furnace_dryer_noise_3st_cv AMPdsR1_1min_A 1 A noised all SparseViterbi
python disagg_NAV.py AMPds_heatpump_furnace_dryer_noise_3st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_noise_3st
Rscript --vanilla app_viz.R AMPds_heatpump_furnace_dryer_noise_3st AMPdsR1_1min_A

python train_SSHMM.py AMPds_heatpump_furnace_dryer_denoise_3st AMPdsR1_1min_A 1 104 denoised 3 1 HPE,FRE,CDE
python train_SSHMM.py AMPds_heatpump_furnace_dryer_denoise_3st_cv AMPdsR1_1min_A 1 104 denoised 3 10 HPE,FRE,CDE
python test_Algorithm.py 12 AMPds_heatpump_furnace_dryer_denoise_3st_cv AMPdsR1_1min_A 1 A noised all SparseViterbi
python disagg_NAV.py AMPds_heatpump_furnace_dryer_denoise_3st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_denoise_3st
Rscript --vanilla app_viz.R AMPds_heatpump_furnace_dryer_denoise_3st AMPdsR1_1min_A

python train_SSHMM.py AMPds_top6_noise_3st AMPdsR1_1min_A 1 104 noised 3 1 HPE,FRE,CDE,UTE,GRE,TVE
python train_SSHMM.py AMPds_top6_noise_3st_cv AMPdsR1_1min_A 1 104 noised 3 10 HPE,FRE,CDE,UTE,GRE,TVE
python test_Algorithm.py 13 AMPds_top6_noise_3st_cv AMPdsR1_1min_A 1 A noised all SparseViterbi
python disagg_NAV.py AMPds_top6_noise_3st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_top6_noise_3st
Rscript --vanilla app_viz.R AMPds_top6_noise_3st AMPdsR1_1min_A

python train_SSHMM.py AMPds_top6_denoise_3st AMPdsR1_1min_A 1 104 denoised 3 1 HPE,FRE,CDE,UTE,GRE,TVE
python train_SSHMM.py AMPds_top6_denoise_3st_cv AMPdsR1_1min_A 1 104 denoised 3 10 HPE,FRE,CDE,UTE,GRE,TVE
python test_Algorithm.py 14 AMPds_top6_denoise_3st_cv AMPdsR1_1min_A 1 A noised all SparseViterbi
python disagg_NAV.py AMPds_top6_denoise_3st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_top6_denoise_3st
Rscript --vanilla app_viz.R AMPds_top6_denoise_3st AMPdsR1_1min_A

REM try four states:

python train_SSHMM.py AMPds_heatpump_furnace_dryer_noise_4st AMPdsR1_1min_A 1 104 noised 4 1 HPE,FRE,CDE
python train_SSHMM.py AMPds_heatpump_furnace_dryer_noise_4st_cv AMPdsR1_1min_A 1 104 noised 4 10 HPE,FRE,CDE
python test_Algorithm.py 21 AMPds_heatpump_furnace_dryer_noise_4st_cv AMPdsR1_1min_A 1 A noised all SparseViterbi
python disagg_NAV.py AMPds_heatpump_furnace_dryer_noise_4st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_noise_4st
Rscript --vanilla app_viz.R AMPds_heatpump_furnace_dryer_noise_4st AMPdsR1_1min_A

python train_SSHMM.py AMPds_heatpump_furnace_dryer_denoise_4st AMPdsR1_1min_A 1 104 denoised 4 1 HPE,FRE,CDE
python train_SSHMM.py AMPds_heatpump_furnace_dryer_denoise_4st_cv AMPdsR1_1min_A 1 104 denoised 4 10 HPE,FRE,CDE
python test_Algorithm.py 22 AMPds_heatpump_furnace_dryer_denoise_4st_cv AMPdsR1_1min_A 1 A noised all SparseViterbi
python disagg_NAV.py AMPds_heatpump_furnace_dryer_denoise_4st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_heatpump_furnace_dryer_denoise_4st
Rscript --vanilla app_viz.R AMPds_heatpump_furnace_dryer_denoise_4st AMPdsR1_1min_A

python train_SSHMM.py AMPds_top6_noise_4st AMPdsR1_1min_A 1 104 noised 4 1 HPE,FRE,CDE,UTE,GRE,TVE
python train_SSHMM.py AMPds_top6_noise_4st_cv AMPdsR1_1min_A 1 104 noised 4 10 HPE,FRE,CDE,UTE,GRE,TVE
python test_Algorithm.py 23 AMPds_top6_noise_4st_cv AMPdsR1_1min_A 1 A noised all SparseViterbi
python disagg_NAV.py AMPds_top6_noise_4st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_top6_noise_4st
Rscript --vanilla app_viz.R AMPds_top6_noise_4st AMPdsR1_1min_A

python train_SSHMM.py AMPds_top6_denoise_4st AMPdsR1_1min_A 1 104 denoised 4 1 HPE,FRE,CDE,UTE,GRE,TVE
python train_SSHMM.py AMPds_top6_denoise_4st_cv AMPdsR1_1min_A 1 104 denoised 4 10 HPE,FRE,CDE,UTE,GRE,TVE
python test_Algorithm.py 24 AMPds_top6_denoise_4st_cv AMPdsR1_1min_A 1 A noised all SparseViterbi
python disagg_NAV.py AMPds_top6_denoise_4st AMPdsR1_1min_A_ 1 A 
Rscript --vanilla disagg_viz.R AMPds_top6_denoise_4st
Rscript --vanilla app_viz.R AMPds_top6_denoise_4st AMPdsR1_1min_A
pause
