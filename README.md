# Sparse NILM

Copyright (c) 2015 by Stephen Makonin
Additions by S Daniel Zafar

The super-state hidden Markov model disaggregator that uses a sparse Viterbi algorithm for decoding. This project contains the source code that was used for the [IEEE Transactions on Smart Grid](http://makonin.com/doc/TSG_2015.pdf) journal paper.

If you usethe code in your research please cite this paper. Current citation details are:


- **Title:** Exploiting HMM Sparsity to Perform Online Real-Time Nonintrusive Load Monitoring (NILM)
- **Authors:** Stephen Makonin, Fred Popowich, Ivan V. Bajic, Bob Gill, Lyn Bartram
- **Journal:** IEEE Transactions on Smart Grid
- **Vol/No/Pages:** vol. PP, no. 99, pp. 1-11
- **Accepted:** October 2015
- **DOI:** 10.1109/TSG.2015.2494592


**NOTE:** This code is a rewritten and modified version of the code used Makonin's my PhD thesis.

## Updates by S Daniel Zafar (10/11/16):
Additional scripts for 

	1) Disaggregating new whole-house data and ouputing disaggregated results (disagg.NAV)
	
	2) Visualization (in R) of all disaggregated data as well as obs and est for each appliance (disagg_viz.R & app_viz.R)
	
	3) Batch files for Windows machines (assorted .bat files)

Added a function to class Accuracy which outputs the Verification metrics to a specified .txt file in "\reports\" folder ( accuracy.write() )
