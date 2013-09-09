function contribution = volumeContribution(objectives,ref)
  %VOLUMECONTRIBUTION Summary of this function goes here
  %   Detailed explanation goes here
  
  [rows,cols] = size(objectives);
  contribution = ones(rows,1);
  for j=1:cols
    [y,i] = sort(objectives(:,j));
    x = [y(2:end);ref(j)];
    contribution = contribution.*(x(i)-y(i));
  end 
end

