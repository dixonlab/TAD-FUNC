clear; close all; clc;
fid = fopen('celllist.txt','r');
line = 1;
while feof(fid) == 0    
    tline{line,1} = fgetl(fid);
    handle = tline{line};
    para = [handle,'/',handle,'.parameter.mat'];
    load(para);
    sv = [handle,'/',handle,'.SV.diamond.matrix.txt'];
    sv_data = load(sv);
    input_layer_size  = 2500;
    hidden_layer_size = 50;
    num_labels = 1;
    Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));
    Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));
    pred = predict1(Theta1, Theta2, sv_data);
    output = [handle,'/',handle,'.SV.pred.txt'];
    out = fopen(output,'w');
    nrow = size(pred,1);
    for i = 1: nrow
      fprintf(out,'%d\n',pred(i,1));
    end
    fclose(out);
end
fclose(fid);