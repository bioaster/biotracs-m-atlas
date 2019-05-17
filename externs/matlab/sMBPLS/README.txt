Please run the following MATLAB command in the local directory:

>> sMBbpls_run('test_data.mat','sMBPLS_results');

Then you will get two files "sMBPLS_results.txt" and "sMBPLS_results.mat"

File "sMBPLS_results.txt" records all modules the algorithm identifies. Each line is a module. It has 8 columns.
Column 1: #sample
Column 2: #X1_feature,#X2_feature,#X3_feature
Column 3: #Y_feature
Column 4: List of samples in the module
Column 5: List of X1_features in the module
Column 6: List of X2_features in the module
Column 7: List of X3_features in the module
Column 8: List of Y_features in the module

File "sMBPLS_results.mat" is a MATLAB workspace file. It records all solution vectors obtained by the sMBPLS algorithm. The modules identified are derived from these vectors.