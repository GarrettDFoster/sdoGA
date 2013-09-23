function candidates = uniform(state,options)
  %uniform across the range instead of biased towards current value
  
  %set static mutation rate
  mutation_rate = 0.05;
  
  %get sizing variables
  candidates = state.candidate_tbl;
  [rows,cols] = size(candidates);
  
  %format bounds of space
  lb = options.variable_lower_bound;
  ub = options.variable_upper_bound;
  
  %bound any infinite bounds using mean and stdev
  pop = state.variable_tbl(state.population_index,:);
  i = all(isfinite(pop),2);
  avg = mean(state.variable_tbl(i,:));
  stdev = std(state.variable_tbl(i,:));  
  i = isinf(lb);
  lb(i) = avg(i) - 2*stdev(i);  
  i = isinf(ub);
  ub(i) = avg(i) + 2*stdev(i);
  
  %replace bits
  mutated_bits = repmat(lb,rows,1) + rand(rows,cols).*repmat(ub-lb,rows,1);
  i = rand(rows,cols) < mutation_rate;
  candidates(i) = mutated_bits(i);
  
  %round off integers
  for j=1:cols
    if options.discrete_variables(j)
      candidates(:,j) = round(candidates(:,j));
    end
  end
  
end