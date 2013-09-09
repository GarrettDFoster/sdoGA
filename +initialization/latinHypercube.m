function candidates = latinHypercube(state,options)
  %get sizing information
%   if options.candidate_size_update < 0
%     rows = max(options.candidate_size_bounds);
%   else
%     rows = min(options.candidate_size_bounds);
%   end
  rows = options.evals_per_gen;
  cols = options.design_length;
  
  %get bounds
  lb = options.design_lower_bound;
  ub = options.design_upper_bound;
  l_inf = isinf(lb);
  u_inf = isinf(ub);
  
  %assume no bounds means normalized 0-1
  lb(l_inf) = 0;
  ub(u_inf) = 1;
  
  %build candidate population
  candidates = lhsdesign(rows,cols).*repmat(ub-lb,rows,1) + repmat(lb,rows,1);
  
  %round off integers
  for i=1:options.design_length
    if options.discrete_variables(i)
      candidates(:,i) = round(candidates(:,i));
    end
  end
end