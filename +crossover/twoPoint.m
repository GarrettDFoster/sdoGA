function candidates = twoPoint(state,options)
  candidates = state.candidates;
  [rows,cols] = size(candidates);
  for i=1:2:rows
    left = randi([1,cols],1);
    right = randi([left,cols],1);    
    tmp = candidates(i,left:right);
    candidates(i,left:right) = candidates(i+1,left:right);
    candidates(i+1,left:right) = tmp;    
  end  
end

