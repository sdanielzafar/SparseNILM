@echo on
CD /D Y:\MA Utilities\Residential\RES 1 -Residential Baseline Study\Analysis\NILM\SparseNILM

python train_SSHMM.py tester_cv AMPdsR1_1min_A 10 104 noised 3 10 HPE,FRE,CDE
python test_Algorithm.py 99 tester_cv AMPdsR1_1min_A 10 A noised all SparseViterbi
