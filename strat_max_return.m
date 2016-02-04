function  [x_optimal cash_optimal] = strat_max_return(x_init, cash_init, mu, Q, cur_prices)
   addpath('/Users/alvinleung/Applications/IBM/ILOG/CPLEX_Studio1263/cplex/matlab/x86-64_osx');
    
    n = length(cur_prices);
    % Optimization problem data
    lb = zeros(n,1);
    ub = inf*ones(n,1);
    A = ones(1,n);
    b = 1;
    % Compute maximum return portfolio
    cplex2 = Cplex('max_Return');
    cplex2.Model.sense = 'maximize';
    cplex2.addCols(mu, [], lb, ub);
    cplex2.addRows(b, A, b);
    cplex2.Param.lpmethod.Cur = 6; % concurrent algorithm
    cplex2.Param.barrier.crossover.Cur = 1; % enable crossover
    cplex2.DisplayFunc = []; % disable output to screen
    cplex2.solve();
    % Display maximum return portfolio
    w_maxRet = cplex2.Solution.x;
   
   current_portfolio_value = sum(x_init .* transpose(cur_prices)) + cash_init;
   cur_port_value_array = ones(20,1) * current_portfolio_value;
   value_each_stock = cur_port_value_array.*w_maxRet;
   num_each_stock = value_each_stock./transpose(cur_prices);
   rounded_each_stock = arrayfun(@(x) floor(x), num_each_stock);
   
   rounded_portfolio_value = sum(rounded_each_stock.*transpose(cur_prices));
   cash_optimal = current_portfolio_value - rounded_portfolio_value;
   x_optimal = rounded_each_stock;

   %display(cash_optimal);
   %display(x_optimal);
end
