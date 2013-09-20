function contribution = hypervolumeContribution(frontier_pts,ref_pt)
  
  %init contribution vector
  rows = size(frontier_pts,1);
  contribution = nan(rows,1);
  
  %get hypervolume of base frontier
  base_vol =  metric.hypervolume(frontier_pts,ref_pt);
  
  if rows == 1
    contribution = base_vol
  else
    %go through each test point
    for i=1:rows
      
      %create frontier with current point removed
      tmp_front = frontier_pts;
      tmp_front(i,:) = [];
      
      %get subsets volume
      new_vol = metric.hypervolume(tmp_front,ref_pt);
      
      %get contribution of point
      contribution(i,:) = base_vol - new_vol;
    end
  end
end