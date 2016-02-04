clc;
clear all;
format long

% Input files
input_file_returns = 'Returns.csv';
input_file_prices  = 'Daily_closing_prices.csv';

% Read expected returns
if(exist(input_file_returns,'file'))
  fprintf('\nReading returns datafile - %s\n', input_file_returns)
  fid1 = fopen(input_file_returns);
     % Read instrument tickers
     hheader  = textscan(fid1, '%s', 1, 'delimiter', '\n');
     headers = textscan(char(hheader{:}), '%q', 'delimiter', '\t');
     tickers = headers{1}(2:end);
     % Read time periods
     vheader = textscan(fid1, '%q %*[^\n]');
     periods = vheader{1}(1:end);
  fclose(fid1);
  data_returns = dlmread(input_file_returns, '\t', 1, 1);
else
  error('Returns datafile does not exist')
end

% Read daily prices
if(exist(input_file_prices,'file'))
  fprintf('\nReading daily prices datafile - %s\n', input_file_prices)
  fid2 = fopen(input_file_prices);
     % Read dates
     vheader = textscan(fid2, '%q %*[^\n]');
     dates = vheader{1}(2:end);
  fclose(fid2);
  data_prices = dlmread(input_file_prices, '\t', 1, 1);
else
  error('Daily prices datafile does not exist')
end

% Initial positions in the portfolio
init_positions = [5000 1000 2000 0 0 0 0 2000 3000 6500 0 0 0 0 0 0 1000 0 0 0]';
%init_positions = [0 1000 0 7000 0 0 0 2000 3000 6500 0 0 0 0 0 0 1000 0 0 0]';
% Initial value of the portfolio
init_value = data_prices(1,:) * init_positions;
fprintf('\nInitial portfolio value = $ %10.2f\n\n', init_value);

% Initial portfolio weights
w_init = (data_prices(1,:) .* init_positions')' / init_value;

% Number of periods, assets, trading days
N_periods = length(periods);
N = length(tickers);
N_days = length(dates);

% Convert dates into array [year month day]
format_date = 'mm/dd/yyyy';
dates_array = datevec(dates, format_date);
dates_array = dates_array(:,1:3);

% Number of strategies
strategy_functions = {'strat_buy_and_hold' 'strat_equally_weighted' 'strat_min_variance' 'strat_max_Sharpe'};
strategy_names     = {'Buy and Hold' 'Equally Weighted Portfolio' 'Minimum Variance Portfolio' 'Maximum Sharpe Ratio Portfolio'};
N_strat = 4; % comment this in your code
%N_strat = length(strategy_functions); % uncomment this in your code
fh_array = cellfun(@str2func, strategy_functions, 'UniformOutput', false);

%display(size(data_prices));
%daily_portfolio_values=zeros(5,size(data_prices,1));
%total_ind = 0;

for (period = 1:N_periods)
    
   % Compute current year and month, first and last day of the period
   if(dates_array(1,1)==5)
       cur_year  = 5 + floor(period/7);
   else
       cur_year  = 2005 + floor(period/7);
   end
   cur_month = 2*rem(period-1,6) + 1;
   day_ind_start = find(dates_array(:,1)==cur_year & dates_array(:,2)==cur_month, 1, 'first');
   day_ind_end = find(dates_array(:,1)==cur_year & dates_array(:,2)==(cur_month+1), 1, 'last');
   fprintf('\nPeriod %d: start date %s, end date %s\n', period, char(dates(day_ind_start)), char(dates(day_ind_end)));

   % Compute expected return and covariance matrix for period 1
   if(period==1)
       mu = data_returns(period,:)';
       Q  = dlmread(['covariance_' char(periods(period)) '.csv'], '\t', 'A1..T20');
   end

   % Prices for the current day
   cur_prices = data_prices(day_ind_start,:);

   % Execute portfolio selection strategies
   for(strategy = 1:N_strat)

      % Get current portfolio positions
      if(period==1)
         curr_positions = init_positions;
         curr_cash = 0;
         portf_value{strategy} = zeros(N_days,1);
      else
         curr_positions = x{strategy,period-1};
         curr_cash = cash{strategy,period-1};
      end

      % Compute strategy
      [x{strategy,period} cash{strategy,period}] = fh_array{strategy}(curr_positions, curr_cash, mu, Q, cur_prices);
      
      stocks_split_by_price = x{strategy,period} .* transpose(cur_prices);
      total_cost = sum(stocks_split_by_price);
      w_opt{strategy, period} = stocks_split_by_price/total_cost;
      
      % Verify that strategy is feasible (you have enough budget to re-balance portfolio)
      %     -our strategies will never return an infeasible answer
      % Check that cash account is >= 0
            if cash{strategy, period} < 0
                display(cash{strategy, period});
                display('Cash value error');
                return;
            end
      % Check that we can buy new portfolio subject to transaction costs
      %     -done in get_each_stock_TC and constraint of knapsack

      
      % Compute portfolio value
      portf_value{strategy}(day_ind_start:day_ind_end) = data_prices(day_ind_start:day_ind_end,:) * x{strategy,period} + cash{strategy,period};

      fprintf('   Strategy "%s", value begin = $ %10.2f, value end = $ %10.2f\n', char(strategy_names{strategy}), portf_value{strategy}(day_ind_start), portf_value{strategy}(day_ind_end));

   end
      
   % Compute expected returns and covariances for the next period
   cur_returns = data_prices(day_ind_start+1:day_ind_end,:) ./ data_prices(day_ind_start:day_ind_end-1,:) - 1;
   mu = mean(cur_returns)';
   Q = cov(cur_returns);
   
end

% Plot results
%%%%%%%%%%% Insert your code here %%%%%%%%%%%%
figure(1);
for(strategy = 1:N_strat)
    plot(portf_value{strategy});
    axis([0 504 0.7*10^6 3*10^6]);
    hold on;
end

n_assets = 20;
periods = 12;
strategies = 4;

y = zeros(strategies, n_assets, periods);
% display(y(:,:,12));
for i = 1:4
    for j =1:12
        for k =1:20
            y(i,k,j) = w_opt{i,j}(k);
        end
    end
end

for strat=3:4
    figure();
    for i=1:20
        toPlot = zeros(1,12);

        % display(y(strategy,i,:));
        for j=1:12
            %plot weights (monetary value percentage) -  NOT x values (# of stocks of each company)
            toPlot(j) = y(strat,i,j);
        end
        plot(toPlot);
        hold on;
    end
end