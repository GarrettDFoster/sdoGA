function distance = crowdingDistance(objectives)
  % Normalize before computing distance
  objectives = utility.normalize(objectives);
  [rows,cols] = size(objectives);
  distance = zeros(rows,1);
  
  %compute 1-norm distances
  for j = 1:cols
    [sorted_obj,index] = sort(objectives(:,j));
    distance([index(1),index(end)]) = Inf;
    for i=2:rows-1
      distance(index(i)) = distance(index(i)) + ...
        sorted_obj(i+1) - sorted_obj(i-1);
    end
  end
  
  %turn Infs into real numbers
  distance(distance == Inf) = cols;
end