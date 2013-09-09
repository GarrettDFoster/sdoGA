function x_norm = normalize(x,bounds)
  if ~exist('bounds','var')
    upper_bound = max(x);
    lower_bound = min(x);
  else
    upper_bound = max(bounds);
    lower_bound = min(bounds);
  end
  range = upper_bound - lower_bound;
  range(range==0) = 1; %prevent divide by zero errors
  [rows,cols] = size(x);
  x_norm = (x - repmat(lower_bound,rows,1))./repmat(range,rows,1);
end