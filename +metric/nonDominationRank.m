function rank = nonDominationRank(objectives,varargin)
  %nonDominationRank ranks designs by first dividing the constraint space into
  %frontiers and then sub-dividing those into more frontiers in the objective
  %space. It assumes minimzation and lower rank is better.
  %
  %rank = nonDominationRank(objectives);
  %
  %rank = nonDominationRank(objectives,constraints);
  %
  %rank = nonDominationRank(objectives,max_rank);
  %
  %rank = nonDominationRank(objectives,constraints,max_rank);
  %
  
  %intialize sizing variables
  [rows,cols] = size(objectives);
  
  if nargin == 1
    constraints = [];
    max_rank = [];
  elseif nargin == 2
    if numel(varargin{1}) > 1
      constraints = varargin{1};
      max_rank = [];
    else
      constraints = [];
      max_rank = varargin{1};
    end
  elseif nargin == 3
    if numel(varargin{1}) > 1
      constraints = varargin{1};
      max_rank = varargin{2};
    else
      constraints = varargin{2};
      max_rank = varargin{1};
    end
  end  
  
  if isempty(constraints)
    constraint_rank = ones(rows,1);
  elseif size(constraints,2) == 1
    constraint_rank = oneDimRank(constraints,max_rank);
  else
    constraint_rank = multiDimRank(constraints,max_rank);
  end
  
  %go through constraint ranks and rank by domination
  rank = nan(rows,1);
  rank_counter = 0;
  ii=1;
  while any(constraint_rank == ii)
    index = (constraint_rank == ii);
    if cols == 1
      rank(index) = oneDimRank(objectives(index,:),max_rank) + rank_counter;
    else
      rank(index) = multiDimRank(objectives(index,:),max_rank) + rank_counter;
    end
    rank_counter = max(rank);
    ii = ii+1;
  end
  
end

function rank = oneDimRank(objectives,max_rank)
  rows = length(objectives);
  if nargin < 2 || isempty(max_rank)
    max_rank = rows;
  end
  [objectives,index] = sort(objectives);
  r = nan(rows,1);
  curr_rank = 0;
  i = 1;
  while any(isnan(r))
    curr_rank = curr_rank + 1;
    r(i) = curr_rank;
    for j=i+1:rows
      if objectives(i) == objectives(j)
        r(j) = curr_rank;
      else
        i = j;
        break;
      end
    end
  end
  rank(index) = r;
  rank = rank';
  rank(rank > max_rank) = Inf;
end

function rank = multiDimRank(objectives,max_rank)
  [rows,cols] = size(objectives);
  if nargin < 2  || isempty(max_rank)
    max_rank = rows;
  end
  ranked_indiv = false(rows,1);
  rank = inf(rows,1);
  domination_matrix = false(rows);
  for j = 1:cols
    domination_matrix = domination_matrix | bsxfun(@lt,objectives(:,j),objectives(:,j)');
  end
  for j = 1:cols
    domination_matrix = domination_matrix & bsxfun(@le,objectives(:,j),objectives(:,j)');
  end
  domination_matrix = ~domination_matrix;
  rank_counter = 1;
  while ~all(ranked_indiv) && rank_counter <= max_rank
    dominates = all(domination_matrix);
    rank(dominates) = rank_counter;
    rank_counter = rank_counter + 1;
    domination_matrix(dominates,:) = true;
    domination_matrix(dominates,dominates) = false;
    ranked_indiv(dominates) = true;
  end
end