function [binary_array] = knapsack(W, weights, values)
    % dynamic programming knapsack solution O(n,W) - for our case, 
    % weights always = values
    n = length(weights);
    M = zeros(n+1, W+1);
    
    % create table
    for i=1:n
        for w=1:W
            if (weights(i) > w)
                M(i+1,w+1) = M(i,w+1);
            else
                M(i+1,w+1) = max([M(i,w+1), values(i) + M(i,w-weights(i)+1)]);
            end
        end
    end
    
    %display(M);
    opt = M(n+1, W+1);
    
    % backtrack
    binary_array = zeros(1,n);
    curIndex = [n+1, W+1];
    
    while n > 0
        %display(curIndex);
        if opt == M(curIndex(1)-1, curIndex(2))
            curIndex = [curIndex(1)-1, curIndex(2)];
        else 
            binary_array(n) = 1;
            this_w = weights(n);
            curIndex = [curIndex(1)-1, curIndex(2)-this_w];
            opt = M(curIndex(1), curIndex(2));
        end
        n = n-1;
    end

    %1479 + 2116 + 3838 + 4200
%     n = length(weights);
%     best = M(n+1, W+1);
%     display(weights);
%     display(binary_array);
%     display(W);
%     display(best);

end