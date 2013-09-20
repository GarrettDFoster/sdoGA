function candidates = latinHypercube(state,options)
  %get sizing information
%   if options.candidate_size_update < 0
%     rows = max(options.candidate_size_bounds);
%   else
%     rows = min(options.candidate_size_bounds);
%   end
  rows = options.number_of_candidates;
  cols = options.number_of_variables;
  
  %get bounds
  lb = options.variable_lower_bound;
  ub = options.variable_upper_bound;
  l_inf = isinf(lb);
  u_inf = isinf(ub);
  
  %assume no bounds means normalized 0-1
  lb(l_inf) = 0;
  ub(u_inf) = 1;
  
  %build candidate population
  candidates = lhsdesign(rows,cols).*repmat(ub-lb,rows,1) + repmat(lb,rows,1);
  
  %round off integers
  for i=1:cols
    if options.discrete_variables(i)
      candidates(:,i) = round(candidates(:,i));
    end
  end
end