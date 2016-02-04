function  [x_optimal] = get_each_stock_TC(OPV, prices, num_old, weights)
    % get the exact number of each stock needed to satisfy the weight
    % condition, taking into account transaction fees
    
    % explained in report
    f = 0.005;
    index = 1;
    
    %find index as our unknown - must have non-zero weight
    for i=1:length(weights)
        if weights(i)~=0
            index = i;
            break
        end
    end
    
    
    % first term in sum
    c = sum(weights*prices(index)/weights(index));
    
    eioverdi = (num_old.*prices)./(weights*prices(index)/weights(index));
    %sorted = sort(eioverdi);
    %display(sorted);
    
    
    di = (weights*prices(index)/weights(index));
    ei = (num_old.*prices);
    %changecount = 0;
%     display(ei);
%     display(di);
    
    
    solutions = zeros(1, length(eioverdi));
    % real_solution = 0;
    % [1,2,3,4,5] 
    % eioverdi(1) = 1:
    % if eioverdi(j) < 1:
        %make negative
    
    
    for i=1:length(eioverdi)
        neg_array = ones(1, length(eioverdi));
        
        for j=1:length(eioverdi)
            if eioverdi(j) >= eioverdi(i)
                neg_array(j) = -1;
            end
        end
        
        
        d = f*sum(di .* neg_array);
        e = f*sum(ei .* neg_array);
        
        this_solution = (OPV + e)/(c + d);
%         display(d);
%         display(e);

        solutions(i) = this_solution;
%         if i==1 && this_solution < eioverdi(i)
%             %real_solution = this_solution;
%             changecount = changecount + 1;
%         elseif i>1 && this_solution < eioverdi(i) && this_solution >= sorted(find(sorted==eioverdi(i))-1)
%             %real_solution = this_solution;
%             changecount = changecount + 1;
%         else
%             %do nothing
%         end
    end
    
    i = length(eioverdi)+1;
    %last iteration - all positive
    neg_array = ones(1, length(eioverdi));
    d = f*sum(di .* neg_array);
    e = f*sum(ei .* neg_array);
    this_solution = (OPV + e)/(c + d);
    solutions(i) = this_solution;
%     if this_solution > eioverdi(length(eioverdi))
%         %real_solution = this_solution;
%         changecount = changecount + 1;
%     end
    
%    display(solutions);
%    display(real_solution);
%    display(changecount);
    % 8?

    %real_solution = solutions(8);

    % find the closest solution
    min_index = 1;
    current_min = 100000;
    
    for rs=1:length(solutions)
        new_stock_nums = zeros(1,length(prices));
        for i=1:length(prices)
            new_stock_nums(i) = ((weights(i)*prices(index))/(weights(index)*prices(i)))*solutions(rs);
        end
        TC = sum((abs(new_stock_nums - num_old).* prices)*0.005);
        shouldBeTC = OPV - sum(new_stock_nums .* prices);
        subtracted = TC - shouldBeTC;
        % display(subtracted);
        if (subtracted < current_min)
            current_min = subtracted;
            min_index = rs;
        end
    end
    
    x_optimal = zeros(1,length(prices));
    for i=1:length(prices)
        x_optimal(i) = ((weights(i)*prices(index))/(weights(index)*prices(i)))*solutions(min_index);
    end
%     display(eioverdi);
%     display(sorted);
    % display(x_optimal);
end


