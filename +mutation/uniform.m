function candidates = uniform(state,options)
  %uniform across the range instead of biased towards current value
  
  %set static mutation rate
  mutation_rate = 0.05;
  
  %get sizing variables
  candidates = state.candidates;
  [rows,cols] = size(candidates);
  
  %format bounds of space
  lb = options.design_lower_bound;
  i = isinf(lb);
  lb(i) = min(state.design_values(:,i));
  lb(i) = lb(i) - abs(lb(i))*1.5;
  ub = options.design_upper_bound;
  i = isinf(ub);
  ub(i) = max(state.design_values(:,i));
  ub(i) = ub(i) + abs(ub(i))*1.5;
  
  %replace bits
  mutated_bits = repmat(lb,rows,1) + rand(rows,cols).*repmat(ub-lb,rows,1);
  i = rand(rows,cols) < mutation_rate;
  candidates(i) = mutated_bits(i);
  
  %round off integers
  for j=1:cols
    if options.integer_variables(j)
      candidates(:,j) = round(candidates(:,j));
    end
  end
  
end