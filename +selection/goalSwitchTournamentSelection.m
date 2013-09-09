function candidates = goalSwitchTournamentSelection(state,options)

%initialize sizing variables
[rows,cols] = size(state.candidates);

%TODO
%-how often should the switch last?
%-should it be triggered by stalling?

%define how often goal switching occurs
% switch_percent = 0.1;
switch_generations = 10;

%define current objective
col = mod(floor(state.generations/switch_generations),options.number_of_objectives+1);

%TODO
%-should a multiobjective mode be used?
%-this idea is that it helps fill in the gaps within the frontier

%allow for 1 of the modes to be multiobjective
if col > 0
  
  %TODO
  %-figure out if geometric middle is better than mathematical (i.e.
  %mid vs median vs mean)
  %-also do i even want the middle, would a different ratio make more sense?
  %--the idea being if i cut closer, I put more pressre on the goal, however
  %too close and i lose too much design information
  %-What if you cut at an angle (small like 5 percent), this could allow
  %more points and allow you to cut closer
  %-is there a case to be made for cutting on the left and right of the
  %space? Perhaps filling out the middle of the frontier or a gap?
  
  %   %find percent of the geometric space
  %   percent = 0.20;
  %   i = (state.rank == 1);
  %   upper = max(state.score(i,col));
  %   lower = min(state.score(i,col));
  %   cutoff = lower + (upper-lower)*percent;
  %   i = (state.score(:,col) <= cutoff);
  
  %percentile cutting
  percent = 0.33;
  i = (state.rank == 1);
  cutoff = prctile(state.score(i,col),percent);
  i = (state.score(:,col) <= cutoff);
  
  %cut the space
  state.score = state.score(i,:);
  state.population = state.population(i,:);
  state.rank = state.rank(i,:);
  state.crowding_distance = state.crowding_distance(i,:);
  
end

%figure out how big the bucket needs to be
rows = min(rows*2,length(state.rank));

%fill the bucket
[null,i] = sortrows([state.rank,-1*state.crowding_distance]);
i = i(1:rows);
state.score = state.score(i,:);
state.population = state.population(i,:);
state.rank = state.rank(i,:);
state.crowding_distance = state.crowding_distance(i,:);

%perform 4 person tournaments until candidates is filled
for i=1:size(state.candidates,1)
  j = randi([1,rows],[4,1]);
  [null k] = sortrows([state.rank(j),-1*state.crowding_distance(j)]);
  state.candidates(i,:) = state.population(j(k(1)),:);
end

%return
candidates = state.candidates;
end

