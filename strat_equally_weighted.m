function  [x_optimal cash_optimal] = strat_equally_weighted(x_init, cash_init, mu, Q, cur_prices)
   current_portfolio_value = sum(x_init .* transpose(cur_prices)) + cash_init; 
   weights = (1/length(cur_prices))*ones(1,length(cur_prices));
   
   new_stock_numbers = get_each_stock_TC(current_portfolio_value, cur_prices , transpose(x_init), weights);
   %display(current_portfolio_value - sum(new_stock_numbers .* cur_prices));
   
   rounded_each_stock = arrayfun(@(x) floor(x), transpose(new_stock_numbers));
   
   %add in 0.005 transaction fee
   transaction_fees = sum((abs(rounded_each_stock - x_init).* transpose(cur_prices))*0.005);
   cash_remaining = current_portfolio_value - sum(rounded_each_stock .* transpose(cur_prices)) - transaction_fees;
   
   % rounding the remaining cash by fitting as many 1 stocks as
   % possible
   one_stock_plus_TCs = transpose(cur_prices) + (transpose(cur_prices).*0.005);
   % display(one_stock_plus_TCs);
   
   W = ceil(cash_remaining * 100);
   ks_weights = zeros(1,nnz(weights));
   ind = 1;
   for i=1:length(weights)
       if weights(i)~=0
           ks_weights(ind) = ceil(one_stock_plus_TCs(i)*100);
           ind = ind + 1;
       end
   end
   
   ks_values = ks_weights;
   [truth_array] = knapsack(W, ks_weights, ks_values);
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
   % value end is $ 1189798.54
   % value end is $ 1189931.79 with rounding LOL
   %display(x_optimal);
end