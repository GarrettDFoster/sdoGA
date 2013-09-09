function candidates = adaptive(state,options)
  %uniform on integers, biased on reals, adaptive (i.e. shrinking) mutation rate
  
  %set starting mutation rate
  mutation_rate = 0.05;
  
  %   %shrink as algorithm converges
  %   mutation_rate = mutation_rate*(1-state.converged_fraction);
  %
  %   %check for near stall
  %   if (state.stall_generations/options.max_stall_generations) > 0.5
  %     mutation_rate = mutation_rate*2;
  %   end
  
  %get sizing variables
  candidates = state.candidates;
  [rows,cols] = size(candidates);
  
  %replace real bits
  bias = [-0.9,-0.3,-0.1,0.1,0.3,0.9];
  mutated_bits = candidates + abs(candidates) .* bias(randi(length(bias),rows,cols));
  i = rand(rows,cols) < mutation_rate;
  real = ~options.discrete_variables;
  i(:,~real) = false;
  candidates(i) = mutated_bits(i);
  
  %format bounds of space
  lb = options.design_lower_bound;
  i = isinf(lb);
  lb(i) = min(state.design_values(:,i));
  lb(i) = lb(i) - abs(lb(i))*1.5;
  ub = options.design_upper_bound;
  i = isinf(ub);
  ub(i) = max(state.design_values(:,i));
  ub(i) = ub(i) + abs(ub(i))*1.5;
  
  %replace integer bits
  mutated_bits = repmat(lb,rows,1) + rand(rows,cols).*repmat(ub-lb,rows,1);
  i = rand(rows,cols) < mutation_rate;
  i(:,real) = false;
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