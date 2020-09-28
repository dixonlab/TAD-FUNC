# TAD-FUNC
#This is an example of running scripts provided to generate dataset and run neural network to identify TAD-fusion events.

cd example

perl ../Random_genome_wide_training_set.pl example_b38d5_40kb.super_matrix.filter.norm.DI.format.domain.txt ../hs38d5.fa.fai example 10000 
#Generate 10000 random coordinates for training set and crossvalidation set. example_b38d5_40kb.super_matrix.filter.norm.DI.format.domain.txt is a bed file that contains previous TAD annotation.

perl ../extract_diamonds.pl example_b38d5_40kb.super_matrix.filter.norm.txt example.training.diamond.txt 2000000 > example.training.diamond.matrix.txt 
#Generate diamond matrices for training set. example_b38d5_40kb.super_matrix.filter.norm.txt is the file recording Hi-C interaction supermatrix after filtration and normalization. It can be downloaded via link: https://salkinstitute.box.com/s/9w70b3qfkn1rdarxp530w1cznxi85ij1

perl ../extract_diamonds.pl example_b38d5_40kb.super_matrix.filter.norm.txt example.crossvalidation.diamond.txt 2000000 > example.crossvalidation.diamond.matrix.txt 
#Generate diamond matrices for crossvalidation set

perl ../extract_diamonds_SV.pl example_b38d5_40kb.super_matrix.filter.norm.txt example_b38d5.breaks.txt 2000000 > example.SV.diamond.matrix.txt 
#Generate diamond matrices for SV test set. example_b38d5.breaks.txt is the file that contains previous structure variant calling.

matlab -nodisplay -nosplash -nodesktop -r "run('../NN_output1_iteration.m');exit;" 
#Train the neural network, crossvalidate. Crossvalidation result saved in example.stat.txt, neural network parameters stored in example.parameter.mat

matlab -nodisplay -nosplash -nodesktop -r "run('../NN_output1_predictSV.m');exit;" 
#Use parameters to predict if there is a TAD-fusion event

paste example_b38d5.breaks.txt example.SV.pred.txt > example.SV.pred.finaloutput.txt 
#Paste structure variant file with last output. 0 means there is a TAD-fusion, 1 means there isn't. 
