function  [x_optimal cash_optimal] = strat_min_variance(x_init, cash_init, mu, Q, cur_prices)
   addpath('/Users/alvinleung/Applications/IBM/ILOG/CPLEX_Studio1263/cplex/matlab/x86-64_osx');
   
   % cplex solver for min variance
   n = length(cur_prices);
   lb = zeros(n,1);
   ub = inf*ones(n,1);
   A = ones(1,n);
   b = 1;
   
   cplex1 = Cplex('min_Variance');
   cplex1.addCols(zeros(n,1), [], lb, ub);
   cplex1.addRows(b, A, b);
   cplex1.Model.Q = 2*Q;
   cplex1.Param.qpmethod.Cur = 6; % concurrent algorithm
   cplex1.Param.barrier.crossover.Cur = 1; % enable crossover
   cplex1.DisplayFunc = []; % disable output to screen
   cplex1.solve();
   
   w_minVar = cplex1.Solution.x;
   
   %display(w_minVar);
   
   current_portfolio_value = sum(x_init .* transpose(cur_prices)) + cash_init;
   
   % old code
%    cur_port_value_array = ones(20,1) * current_portfolio_value;
%    value_each_stock = cur_port_value_array.*w_minVar;
%    num_each_stock = value_each_stock./transpose(cur_prices);
%    rounded_each_stock = arrayfun(@(x) floor(x), num_each_stock);

   new_stock_numbers = get_each_stock_TC(current_portfolio_value,cur_prices , transpose(x_init), transpose(w_minVar));
   %display(current_portfolio_value - sum(new_stock_numbers .* cur_prices));
   rounded_each_stock = arrayfun(@(x) floor(x), transpose(new_stock_numbers));
   
   %account for 0.005 transaction fee
   transaction_fees = sum((abs(rounded_each_stock - x_init).* transpose(cur_prices))*0.005);
   cash_remaining = current_portfolio_value - sum(rounded_each_stock .* transpose(cur_prices)) - transaction_fees;
   
   one_stock_plus_TCs = transpose(cur_prices) + (transpose(cur_prices).*0.005);
   
   weights = w_minVar;
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
   
   %display(transaction_fees);
   %display(cash_optimal);
 
   %$ 1129375.07 is max value at the end without proper rounding
   %$ 1129376.76 is the max value WITH proper rounding LOL
   
   %greedy rounding algorithm (2-approximation) for knapsack problem:
   % sort in descending order, take elements until can't fit weight
   % constraint
%    
%    savedValue = 0;
%    sorted = sort(cur_prices, 'descend');
%    indices = zeros(1,n);
%    for i=1:length(sorted)
%        indices(i) = find(cur_prices==sorted(i));
%    end
%    
%    toUpdate = zeros(1,n);
%    index = 1;
%    for i = 1:length(sorted)
%        toAdd = sorted(index);
%        if (savedValue + toAdd > W)
%            break
%        end
%        savedValue = savedValue + toAdd;
%        toUpdate(indices(i)) = 1;
%    end
%    
%    updated_each_stock = rounded_each_stock + transpose(toUpdate);
  
   %rounded_portfolio_value = sum(rounded_each_stock.*transpose(cur_prices));
   %cash_optimal = current_portfolio_value - rounded_portfolio_value;


   %display(cash_optimal);
   %display(x_optimal);
end
