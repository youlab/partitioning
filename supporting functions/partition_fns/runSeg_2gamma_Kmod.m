function [Y_end]=runSeg_2gamma_Kmod(params, Y0_, nonEmpty, carryingCap,tend,Ksigma)

% carryingCap

M = size(Y0_{1},2); % number of populations
options=odeset('NonNegative',1:M,'AbsTol',1e-9);
N_res = length(Y0_); % number of partitioning levelss

Y_end = cell(N_res,1); % Initialize cell array

for i = 1:N_res
    Y_end{i} = zeros(nonEmpty(i),M); % each row is one local environment
    % each column is one population
end

%% find final density for inidivual pop

%% run the simulation with various segregations

% older version
% yIndiv = (1-params{1}).*((1-params{1})>(1/cellTot));

yIndiv = (1-params{1}); 
yIndiv(yIndiv<=0)=0;

% there is a simple analytical solution when only one population is in a
% local environment
% segation levels

for i = 1:N_res
    for k = 1:nonEmpty(i)

        if sum(Y0_{i}(k,:)>=(1/carryingCap))<=1 % only one or less strains are seeded in the local environment
            Y_end{i}(k,:) = yIndiv'.*(Y0_{i}(k,:)>=(1/carryingCap));
        else
            % ====== key step of creating stochastic local carrying
            % capacity ================================================
            params{4} = normrnd(1,Ksigma);
            if params{4} <= 0
                params{4} = 0;
            end 
            % =========================================================
            [~,y] = ode45(@core_ode_Kmod,[0 tend],Y0_{i}(k,:),options, params{1}, params{2}, params{3}, params{4});
            
            Y_end{i}(k,:) = y(end,:);
        end
    end
%     i
end

fprintf('.')