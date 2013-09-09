function candidates = biased(state,options)
  %biased towards current value as opposed to uniform across the range
  
  %set static mutation rate
  mutation_rate = 0.05;
  
  %get sizing variables
  candidates = state.candidates;
  [rows,cols] = size(candidates);
  
  %replace bits
  mutated_bits = candidates + abs(candidates) .* randn(rows,cols);
  i = rand(rows,cols) < mutation_rate;
  candidates(i) = mutated_bits(i);
  
  %round off integers
  for j=1:cols
    if options.integer_variables(j)
      candidates(:,j) = round(candidates(:,j));
    end
  end
  
end