function frontier(state,options)  
  %figure out how many dimensions
  if options.number_of_objectives == 1
    output.convergence(state,options);
  else
    n = options.number_of_objectives;
    score = state.objective_tbl(state.rank_list == 1,:);
    for i=1:n
      for j=i+1:n
        subplot(n-1,n-1,(i-1)*(n-1)+(j-1))
        scatter(score(:,j),score(:,i));
        xlabel(sprintf('f%i',j));
        ylabel(sprintf('f%i',i));
      end
    end
    title(sprintf('Generation #%i',state.generation));
    drawnow;
  end  
end
