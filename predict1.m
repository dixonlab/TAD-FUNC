function p = predict(Theta1, Theta2, X)

m = size(X, 1);
num_labels = size(Theta2, 1);

p = zeros(size(X, 1), 1);

h1 = sigmoid([ones(m, 1) X] * Theta1');
h2 = sigmoid([ones(m, 1) h1] * Theta2');
p = round(h2);
%for i=1:size(p,1)
%   if  h2 > 0.05
%      p(i,1) = 1; 
%   end
%   if  h2 <= 0.05
%%      p(i,1) = 0; 
 %  end
%end



end
