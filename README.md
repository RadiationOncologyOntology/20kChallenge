This code accompanies the manuscript  
'Distributed learning on 20 000+ lung cancer patients - The Personal Health Train'  
by  
__T.M. Deist, F.J.W.M. Dankers__, P. Ojha, S.M. Marshall, T. Janssen, C. Faivre-Finn, C. Masciocchi, V. Valentini, J. Wang, J. Chen, Z. Zhang, E. Spezi, M. Button, J.J. Nuyttens, R. Vernhout, J. van Soest, A. Jochems, R. Monshouwer, J. Bussink, _G. Price, P. Lambin, A. Dekker_  
(__Bolded__ and _italicized_ authors contributed equally)

This repository contains code to  
- train a logistic regression model  
- validate a logistic regression model  
- compute summary statistics from data

in a distributed setting (master/site-architecture).

Please, see the wiki ([link](https://github.com/RadiationOncologyOntology/20kChallenge/wiki)) for 
- a description of the input data format 
- a short tutorial for transforming data (following the prescribed input data format) into RDF triples.

## Folder structure
`algorithms/` contains a folder with algorithm-specific code for each algorithm type  
`compiling/` contains code to compile/zip/sign MATLAB code for uploading it to the VLP  
`create_user_input_file/` contains code to create an input file for each algorithm  
`result_analysis/` contains code to read the VLP output  
`shared_code/` contains code shared by multiple algorithms  

## Requirements
This code is developed in MATLAB 2018a (Mathworks, Natick, MA). Older MATLAB versions are probably not compatible. 
The code is developed for use with the Varian Learning Portal 2.1 (Varian Medical Systems, Palo Alto, CA) but is possibly adaptable to a distributed learning infrastructure following a parallel (all sites execute their code simultaneously) and synchronous (the next iteration starts when all sites have sent results back to the master) master/site-architecture.

This repository uses code developed by others:

- The Alternating Direction Method of Multipliers (ADMM) algorithm is implemented based on MATLAB code by Boyd et al.  
http://web.stanford.edu/~boyd/papers/admm_distr_stats.html  
Boyd, Stephen, et al. "Distributed optimization and statistical learning via the alternating direction method of multipliers." Foundations and Trends® in Machine learning 3.1 (2011): 1-122.

- fminlbfgs() by Dirk-Jan Kroon  
https://nl.mathworks.com/matlabcentral/fileexchange/23245-fminlbfgs-fast-limited-memory-optimizer  
Please, see copyright notice in algorithms/master/updateZAndU.m and algorithms/site/updateX.m

- confint() by Anderson Winkler & Tom Nichols  
http://brainder.org

