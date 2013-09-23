function candidates = latinHypercube(state,options)
  %get sizing information
%   if options.candidate_size_update < 0
%     rows = max(options.candidate_size_bounds);
%   else
%     rows = min(options.candidate_size_bounds);
%   end
  rows = max(options.population_size,sum(state.population_index));
  cols = options.number_of_variables;
  
  %get bounds
  lb = options.variable_lower_bound;
  ub = options.variable_upper_bound;
  
  %assume no bounds means normalized 0-1
  lb(isinf(lb)) = 0;
  ub(isinf(ub)) = 1;
  
  %build candidate population
  candidates = lhsdesign(rows,cols).*repmat(ub-lb,rows,1) + repmat(lb,rows,1);
  
  %round off integers
  for i=1:cols
    if options.discrete_variables(i)
      candidates(:,i) = round(candidates(:,i));
    end
  end
end