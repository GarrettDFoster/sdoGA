function convergence(state,options)
  
  subplot(2,2,1);
  plot(cumsum(state.runtime_per_gen),state.hypervolume_per_gen);
  xlabel('Runtime (s)');
  ylabel('Hypervolume');
  
  subplot(2,2,2);
  plot(1:state.generation,state.hypervolume_per_gen);
  xlabel('Generations');
  ylabel('Hypervolume');
  
  subplot(2,2,4);
  plot(1:state.generation,cumsum(state.runtime_per_gen));
  xlabel('Generations');
  ylabel('Runtime');
  
  drawnow;
  
end

