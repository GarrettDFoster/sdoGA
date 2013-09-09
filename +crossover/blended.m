function candidates = blended(state,options)
  candidates = state.candidates;
  [rows,cols] = size(candidates);
  
  for i=1:2:rows
    for j = 1:cols
      if options.integer_variables(j)
        %scattered for integer values
        if(rand > 0.5)
          tmp = candidates(i,j);
          candidates(i,j) = candidates(i+1,j);
          candidates(i+1,j) = tmp;
        end
      else
        %BLX-alpha crossover for real values
        alpha = 0.2;
        
        lower = min(candidates(i:i+1,j));
        upper = max(candidates(i:i+1,j));
        range = upper-lower;
        
        lower = lower - range*alpha;
        upper = upper + range*alpha;
        range = upper-lower;
        
        candidates(i,j) = lower + range*rand;
        candidates(i+1,j) = lower + range*rand;
        
        if candidates(i,j) > options.design_upper_bound(j)
          candidates(i,j) = options.design_upper_bound(j);
        elseif candidates(i,j) < options.design_lower_bound(j)
          candidates(i,j) = options.design_lower_bound(j);
        end
        
        if candidates(i+1,j) > options.design_upper_bound(j)
          candidates(i+1,j) = options.design_upper_bound(j);
        elseif candidates(i+1,j) < options.design_lower_bound(j)
          candidates(i+1,j) = options.design_lower_bound(j);
        end
      end
    end
  end
end
