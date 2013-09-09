function [candidates] = scattered(state,options)
  candidates = state.candidates;
  [rows,cols] = size(candidates);
  for i=1:2:rows
    for j = 1:cols
      if(rand > 0.5)
        tmp = candidates(i,j);
        candidates(i,j) = candidates(i+1,j);
        candidates(i+1,j) = tmp;
      end
    end
  end
end
