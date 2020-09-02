clear; close all; clc;
addpath(genpath('/pbld/raidix/home/zxu/projects/tadfusion/script_upload'));
fid = fopen('celllist.txt','r');
line = 1;
while feof(fid) == 0    
    tline{line,1} = fgetl(fid);
    input_layer_size  = 2500;
    hidden_layer_size = 50;
    num_labels = 1;
    handle = tline{line};
    train_data = [handle,'/',handle,'.training.diamond.matrix.txt'];
    val_data = [handle,'/',handle,'.crossvalidation.diamond.matrix.txt'];
    data = load(train_data);
    y = data(:,1);
    X = data(:,2:end);
    data_val = load(val_data);
    y_val = data_val(:,1);
    X_val = data_val(:,2:end);

    initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer_size);
    initial_Theta2 = randInitializeWeights(hidden_layer_size, num_labels);
    initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];

    options = optimset('MaxIter', 5);
    lambda = 0.02;
    i = 0;
    costFunction = @(p) nnCostFunction1(p, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, X, y, lambda);

    [nn_params, cost] = fmincg(costFunction, initial_nn_params, options);
    T = nn_params;
    Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));
    Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));
    pred = predict1(Theta1, Theta2, X);
    tacc = mean(double(pred == y)) * 100;
    %fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y)) * 100);
    pred = predict1(Theta1, Theta2, X_val);
    vacc = mean(double(pred == y_val)) * 100;
    V = vacc;
    %fprintf('\nCross Validation Set Accuracy: %f\n', mean(double(pred == y_val)) * 100);
    for i = 1:39
        %fprintf('Performing network training iteration %d to %d\n',i*10,(i+1)*10);
        [nn_params, cost] = fmincg(costFunction, nn_params, options);
        T = [T nn_params];
        % Obtain Theta1 and Theta2 back from nn_params
        Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

        Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));
        pred = predict1(Theta1, Theta2, X);
        tacc = mean(double(pred == y)) * 100;
        %fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y)) * 100);
        pred = predict1(Theta1, Theta2, X_val);
        vacc = mean(double(pred == y_val)) * 100;
        V = [V vacc];
        %fprintf('\nCross Validation Set Accuracy: %f\n', mean(double(pred == y_val)) * 100);
        if tacc-vacc > 3
           break; 
        end
    end
    [m,l] = max(V);
    nn_params = T(:,l);
    Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

    Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));
    pred = predict1(Theta1, Theta2, X);
    tacc = mean(double(pred == y)) * 100;
    %fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y)) * 100);
    pred = predict1(Theta1, Theta2, X_val);
    vacc = mean(double(pred == y_val)) * 100;
    pos = find(pred==0);
    neg = find(pred==1);
    fdr = mean(double(y_val(pos,:))) * 100;
    fnr = 100-mean(double(y_val(neg,:))) * 100;
    stat_file = [handle,'/',handle,'.stat.txt'];
    para_file = [handle,'/',handle,'.parameter.mat'];
    stat = fopen(stat_file,'wt');
    fprintf(stat,'Training Set Accuracy: %f\n',tacc);
    fprintf(stat,'Cross Validation Set Accuracy: %f\n',vacc);
    fprintf(stat,'FDR: %f\n',fdr);
    fprintf(stat,'FNR: %f\n',fnr);
    save (para_file,'nn_params');
    fclose(stat);
    line = line+1;
end
fclose(fid);