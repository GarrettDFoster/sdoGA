function volume = hypervolume(objectives,reference)
  %HYPERVOLUME is a single metric used to compare frontiers.
  %assumes minimization
  %
  %author: Garrett Foster <garrett.d.foster@gmail.com>
  %version: 2013.02.06
    
  %cut objectives that are larger than the reference point
  cols = size(objectives,2);
  for j=1:cols
    objectives = objectives(objectives(:,j) <= reference(:,j),:);
  end
  
  %remove any redundant designs
  objectives = unique(objectives,'rows');  
  
  %keep only non-dominated points
  rank = metric.nonDominationRank(objectives,1);
  objectives = objectives(rank==1,:);
  
%   %sort based on number of points remaining on front after eval -> smallest to largest
%   points_left = nan(1,cols);
%   for j=1:cols
%     subset = objectives;
%     subset(:,j) = [];
%     rank = metric.nonDominationRank(subset,1);
%     points_left(j) = sum(rank == 1);
%   end
%   [null,sort_index] = sort(points_left);
%   objectives = objectives(:,sort_index);
  
  %base case
  if cols == 1
    volume = reference - objectives;
  else
    %size remaining objectives
    rows = size(objectives,1);
    
    %sort descending
    objectives = sortrows(objectives,-1);
    
    %slice and get intermediate hypervolume
    volumes = NaN(rows,1);
    for i=1:rows
      subset = objectives(i:end,2:end);
      volumes(i) = metric.hypervolume(subset,reference(:,2:end));
    end
    
    %ignore trapezoidal rule for first piece
    volume = (reference(1) - objectives(1,1))*volumes(1);
    %combine and calculate total hypervolume
    for i = 2:size(volumes,1)
      %using a trapezoid rule to combine
      volume = volume + ...
        (objectives(i-1,1) - objectives(i,1))*...
        (volumes(i-1)+volumes(i))/2;
    end
    
  end
end
