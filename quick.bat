@echo on
CD /D Y:\MA Utilities\Residential\RES 1 -Residential Baseline Study\Analysis\NILM\SparseNILM

python test_Algorithm.py 12 AMPds_heatpump_furnace_dryer_denoise_3st_cv AMPdsR1_1min_A 1 A denoised all SparseViterbi
python test_Algorithm.py 13 AMPds_top6_noise_3st_cv AMPdsR1_1min_A 1 A noised all SparseViterbi

pause
