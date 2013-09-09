function candidates = biased(state,options)
  %biased towards current value as opposed to uniform across the range
  
  %set static mutation rate
  mutation_rate = 0.05;
  
  %get sizing variables
  candidates = state.candidates;
  [rows,cols] = size(candidates);
  
  %replace bits
  bias = [-0.8,-0.4,-0.2,0.2,0.4,0.8];
  mutated_bits = candidates + abs(candidates) .* bias(randi(rows,cols));
  i = rand(rows,cols) < mutation_rate;
  candidates(i) = mutated_bits(i);
  
  %check that bounds are NOT violated
  for j=1:cols
    candidates(candidates(:,j) > options.design_upper_bound(j),j) = options.design_upper_bound(j);
    candidates(candidates(:,j) < options.design_lower_bound(j),j) = options.design_lower_bound(j);
  end
    
  %round off integers
  for j=1:cols
    if options.discrete_variables(j)
      candidates(:,j) = round(candidates(:,j));
    end
  end
  
end