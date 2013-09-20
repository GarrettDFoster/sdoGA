function i_front_vol = inducedFrontHypervolume(test_pts,frontier_pts,ref_pt)
  
  %init variables
  f_rows = size(frontier_pts,1);
  t_rows = size(test_pts,1);
  i_front_vol = nan(t_rows,1);
  
  %go through each test point
  for i=1:t_rows
    
    %find set of frontier points that dominate test point
    index = all(repmat(test_pts(i,:),f_rows,1) >= frontier_pts,2);
    
    %make induced frontier
    i_front = [frontier_pts(~index,:);test_pts(i,:)];
    
    %calculate induced front hypervolume
    i_front_vol(i,:) = metric.hypervolume(i_front,ref_pt);
    
  end
end