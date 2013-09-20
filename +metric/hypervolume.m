function vol = hypervolume(obj_vals,ref)
  %HYPERVOLUME is a single metric used to compare frontiers.
  %assumes minimization
  %
  %author: Garrett Foster <garrett.d.foster@gmail.com>
  
  %assign ref if one isn't given
  if ~exist('ref','var') || isempty(ref)
    ref = max(obj_vals);
  end
  
  %modify objectives that are larger than the reference point
  cols = size(obj_vals,2);
  for j=1:cols
    vec = obj_vals(:,j);
    index = vec > ref(j);
    obj_vals(index,j) = ref(j);
  end
  
  vol = rHypervolume(obj_vals,ref);
  
end

function vol = rHypervolume(obj_vals,ref)
  
  %remove any redundant objective entries
  obj_vals = unique(obj_vals,'rows');
  
  %use only non-dominated points
  rank = metric.nonDominatedRank(obj_vals);
  obj_vals = obj_vals(rank==1,:);
  [rows,cols] = size(obj_vals);
  
  if rows == 1 %base case
    vol = prod(ref - obj_vals);
  else
    
    if cols >= 4
      %sort objectives based on number of points remaining on front after eval -> smallest to largest
      points_left = nan(1,cols);
      for j=1:cols
        subset = obj_vals;
        subset(:,j) = [];
        rank = metric.nonDominatedRank(subset);
        points_left(j) = nnz(rank == 1);
      end
      [null,sort_index] = sort(points_left);
      obj_vals = obj_vals(:,sort_index);
    end
    
    %sort worsening -> assuming minimization -> large to small -> descending
    obj_vals = sortrows(obj_vals,-1);
    
    %slice and get intermediate hypervolume
    slice_volumes = nan(rows,1);
    for i=1:rows
      subset = obj_vals(i:end,2:end);
      slice_volumes(i) = rHypervolume(subset,ref(:,2:end));
    end
    
    %combine and calculate total hypervolume
    slice_depths = [ref(1);obj_vals(1:end-1,1)]-obj_vals(:,1);
    vol = slice_volumes' * slice_depths;
    
  end
end
