function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)

Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

m = size(X, 1);
         
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));


X = [ones(m, 1) X];
yk = y;
z2 = X * Theta1';
a2 = sigmoid(z2);
a2 = [ones(m,1) a2];
z3 = a2 * Theta2';
a3 = sigmoid(z3);
J = (1/m)*sum(sum(-yk .* log(a3) - (1-yk) .* log(1-a3)));
r = (lambda / (2 * m)) * (sum(sum(Theta1(:, 2:end) .^ 2)) + sum(sum(Theta2(:, 2:end) .^ 2)));
J = J + r;

for row = 1:m
    a1 = X(row,:)';
    z2 = Theta1 * a1;
    a2 = sigmoid(z2);
    a2 = [1; a2];
    z3 = Theta2 * a2;
    a3 = sigmoid(z3);
    z2 = [1; z2];
    %size((yk(row,:))')
    delta3 = a3 - (yk(row,:))';
    
    delta2 = (Theta2' * delta3) .* sigmoidGradient(z2);
    delta2 = delta2(2:end);
    Theta1_grad = Theta1_grad + delta2 * a1';
    Theta2_grad = Theta2_grad + delta3 * a2';

end
Theta1_grad = Theta1_grad ./ m;
Theta1_grad(:, 2:end) = Theta1_grad(:, 2:end) + (lambda/m) * Theta1(:, 2:end);
Theta2_grad = Theta2_grad ./ m;
Theta2_grad(:, 2:end) = Theta2_grad(:, 2:end) + (lambda/m) * Theta2(:, 2:end);


grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
