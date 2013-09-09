function convergence(state,options)
  
  subplot(2,2,1);
  plot(cumsum(state.runtimes),state.hypervolumes);
  xlabel('Runtime (s)');
  ylabel('Hypervolume');
  
  subplot(2,2,2);
  plot(1:state.generation+1,state.hypervolumes);
  xlabel('Generations');
  ylabel('Hypervolume');
  
  subplot(2,2,4);
  plot(1:state.generation+1,cumsum(state.runtimes));
  xlabel('Generations');
  ylabel('Runtime');
  
  drawnow;
  
end

