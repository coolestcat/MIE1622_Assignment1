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
   
   % old code
%    cur_port_value_array = ones(20,1) * current_portfolio_value;
%    value_each_stock = cur_port_value_array.*w_minVar;
%    num_each_stock = value_each_stock./transpose(cur_prices);
%    rounded_each_stock = arrayfun(@(x) floor(x), num_each_stock);

   new_stock_numbers = get_each_stock_TC(current_portfolio_value,cur_prices , transpose(x_init), transpose(w_maxRet));
   %display(current_portfolio_value - sum(new_stock_numbers .* cur_prices));
   rounded_each_stock = arrayfun(@(x) floor(x), transpose(new_stock_numbers));
   
   %account for 0.005 transaction fee
   transaction_fees = sum((abs(rounded_each_stock - x_init).* transpose(cur_prices))*0.005);
   cash_remaining = current_portfolio_value - sum(rounded_each_stock .* transpose(cur_prices)) - transaction_fees;
   
   one_stock_plus_TCs = transpose(cur_prices) + (transpose(cur_prices).*0.005);
   
   weights = w_maxRet;
   W = ceil(cash_remaining * 100);
   ks_weights = zeros(1,nnz(weights));
   ind = 1;
   for i=1:length(weights)
       if weights(i)~=0
           ks_weights(ind) = round(one_stock_plus_TCs(i)*100);
           ind = ind + 1;
       end
   end
   
   ks_values = ks_weights;
   [truth_array] = knapsack(W, ks_weights, ks_values);
   %display(truth_array);
   stocks_to_add = zeros(1,length(weights));
   
   ind = 1;
   for i=1:length(weights)
       if weights(i)~=0
           if (truth_array(ind) == 1)
               stocks_to_add(i) = 1;
           end
           ind = ind + 1;
       end
   end
   
%    added = one_stock_plus_TCs(5) + one_stock_plus_TCs(10) + one_stock_plus_TCs(11) + one_stock_plus_TCs(20);
%    display(added);
%   display(stocks_to_add);
   updated_each_stock = rounded_each_stock + transpose(stocks_to_add);
   for i=1:length(weights)
       if stocks_to_add(i) == 1
           cash_remaining = cash_remaining - one_stock_plus_TCs(i);
       end
   end
   
   cash_optimal = cash_remaining;
   x_optimal = updated_each_stock;
   %display(cash_optimal);
   %display(x_optimal);
end
