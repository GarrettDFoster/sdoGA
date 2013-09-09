function candidates = onePoint(state,options)
  candidates = state.candidates;
  [rows,cols] = size(candidates);
  for i=1:2:rows
    bits = randi(cols,1);    
    tmp = candidates(i,1:bits);
    candidates(i,1:bits) = candidates(i+1,1:bits);
    candidates(i+1,1:bits) = tmp;    
  end
end