classdef GaussianProcess < handle
    properties
        kernel
        parameters
        observations
        queries = Geochemistry_Helpers.Distribution();
        covariance_matrix
        observation_covariance_matrix
        cross_covariance_matrix
        query_covariance_matrix
        samples
        conditioned = false
        observation_weights
        query_weights
    end
    properties (Hidden=true)
        kernel_function
        kernel_functions = containers.Map("rbf",@(t1,t2,parameters) (parameters(1)^2)*exp(-((abs(t1-t2)/parameters(2)).^2)/2));
    
        means
        covariances
    end
    methods
        function self = GaussianProcess(kernel,query_locations)
            self.kernel = kernel;
            for query_index = 1:numel(query_locations)
                self.queries(query_index) = Geochemistry_Helpers.Distribution();
                self.queries(query_index).location = query_locations(query_index);
            end
            
            self.kernel_function = self.kernel_functions(kernel);
        end
        function runKernel(self,parameters)
            self.parameters = parameters;
            self.covariance_matrix = self.kernel_function(self.queries.collate("location"),self.queries.collate("location")',self.parameters);
            if ~isempty(self.observations) && ~isempty(self.observations.collate("location"))
                self.conditioned = true;
                
                self.observation_covariance_matrix = self.kernel_function(self.observations.collate("location"),self.observations.collate("location")',self.parameters)';
                self.cross_covariance_matrix = self.kernel_function(self.observations.collate("location")',self.queries.collate("location"),self.parameters)';
                self.query_covariance_matrix = self.kernel_function(self.queries.collate("location"),self.queries.collate("location")',self.parameters)';
            
                self.observation_covariance_matrix = self.observation_covariance_matrix+diag(repelem(1e-12,size(self.observation_covariance_matrix,1)));
                sigma_eye_1 = (self.observations.standard_deviation()*5).*eye(size(self.observation_covariance_matrix));
                
                self.means = mean(self.observations.mean()) + self.cross_covariance_matrix/(self.observation_covariance_matrix+sigma_eye_1)*(self.observations.mean()-mean(self.observations.mean()));
                self.covariances = self.query_covariance_matrix-self.cross_covariance_matrix/(self.observation_covariance_matrix+sigma_eye_1)*self.cross_covariance_matrix';
            end
        end
        function self = getSamples(self,number_of_samples)
            if ~self.conditioned
                self.samples = mvnrnd(zeros(size(self.covariance_matrix,1),1),self.covariance_matrix,number_of_samples);
            else
                self.samples = mvnrnd(self.means,self.covariances,number_of_samples);                
            end
            self.assignSamples();
        end
        function reweight(self,limit)
            if nargin==1
                limit = 1e6;
            end
            samples_at_observations = interp1(self.queries.collate("location"),self.samples',self.observations.collate("location")');
            samples_at_observations_histograms = NaN(size(samples_at_observations,1),numel(self.observations(1).bin_edges)-1);
            for observation_index = 1:size(samples_at_observations,1)
                [samples_at_observations_histograms(observation_index,:),~,samples_at_observations_histograms_indices(observation_index,:)] = histcounts(samples_at_observations(observation_index,:),self.observations(1).bin_edges,'Normalization','Probability');
            end
            actual_observations_histograms = self.observations.collate("probabilities");
            
            weights = actual_observations_histograms./samples_at_observations_histograms;
            weights(weights>limit)=NaN;
            weights(isnan(weights)) = 0;
            
            self.observation_weights = weights;
            self.query_weights =  interp1(self.observations.collate("location"),self.observation_weights,self.queries.collate("location"),'linear','extrap');
            
            self.assignSamples();
            
%             clf
%             subplot(2,1,1);
%             hold on            
%             plot(self.observations(1),'r');
%             plot(self.observations(1).bin_midpoints,samples_at_observations_histograms(1,:),'g');
%             plot(self.queries(6).bin_midpoints,self.queries(6).probabilities,'b');
%             
%             subplot(2,1,2);
%             hold on
%             plot(self.observations(8),'r');
%             plot(self.observations(8).bin_midpoints,samples_at_observations_histograms(8,:),'g');            
%             plot(self.queries(8).bin_midpoints,self.queries(366).probabilities,'b');
        end
        
        function assignSamples(self)
            locations = self.queries.collate("location");
            for query_index = 1:numel(self.queries)
                self.queries(query_index) = Geochemistry_Helpers.Distribution.fromSamples(self.observations(1).bin_edges,self.samples(:,query_index));
                if ~isempty(self.query_weights)
                    self.queries(query_index).probabilities = self.queries(query_index).probabilities.*self.query_weights(query_index,:);
                    self.queries(query_index).normalise();
                end
                self.queries(query_index).location = locations(query_index);
            end
        end
    end
end
