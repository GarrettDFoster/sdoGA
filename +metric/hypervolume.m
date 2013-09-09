function volume = hypervolume(objectives,reference)
  %HYPERVOLUME is a single metric used to compare frontiers.
  %assumes minimization
  %
  %author: Garrett Foster <garrett.d.foster@gmail.com>
  %version: 2013.03.20
  
  %cut objectives that are larger than the reference point %TODO could I remove this if I used absolute values???
  cols = size(objectives,2);
  for j=1:cols
    objectives = objectives(objectives(:,j) < reference(:,j),:);
  end
  
  volume = rHypervolume(objectives,reference);
  
end

function volume = rHypervolume(objectives,reference)
  
  %remove any redundant objectives
  objectives = unique(objectives,'rows');
  
  %use only non-dominated points
  rank = metric.nonDominationRank(objectives);
  objectives = objectives(rank==1,:);
  [rows,cols] = size(objectives);
  
  if rows == 1 %base case
    volume = prod(reference - objectives); %TODO if i put absolute value here, I may be able to go around reference
  else
    
    if cols >= 4
      %sort objectives based on number of points remaining on front after eval -> smallest to largest
      points_left = nan(1,cols);
      for j=1:cols
        subset = objectives;
        subset(:,j) = [];
        rank = metric.nonDominationRank(subset);
        points_left(j) = nnz(rank == 1);
      end
      [null,sort_index] = sort(points_left);
      objectives = objectives(:,sort_index);
    end
    
    %sort worsening -> assuming minimization -> large to small -> descending
    objectives = sortrows(objectives,-1);
    
    %slice and get intermediate hypervolume
    slice_volumes = nan(rows,1);
    for i=1:rows
      subset = objectives(i:end,2:end);
      slice_volumes(i) = rHypervolume(subset,reference(:,2:end));
    end
    
    %combine and calculate total hypervolume
    slice_depths = [reference(1);objectives(1:end-1,1)]-objectives(:,1);
    volume = slice_volumes' * slice_depths;
    
  end
end
