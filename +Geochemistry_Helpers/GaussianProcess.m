classdef GaussianProcess < handle & Geochemistry_Helpers.Collator
    properties
        kernel
        parameters
        observations
        observation_approximations
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
                self.observation_approximations = self.observations.approximateGaussian(2);
            
                
                self.observation_covariance_matrix = self.kernel_function(self.observations.collate("location"),self.observations.collate("location")',self.parameters)';
                self.cross_covariance_matrix = self.kernel_function(self.observations.collate("location")',self.queries.collate("location"),self.parameters)';
                self.query_covariance_matrix = self.kernel_function(self.queries.collate("location"),self.queries.collate("location")',self.parameters)';
            
                self.observation_covariance_matrix = self.observation_covariance_matrix+diag(repelem(1e-12,size(self.observation_covariance_matrix,1)));

                observation_uncertainty = (self.observation_approximations.standard_deviation().^2).*eye(size(self.observation_covariance_matrix));
                
                self.means = mean(self.observation_approximations.mean()) + self.cross_covariance_matrix/(self.observation_covariance_matrix+observation_uncertainty)*(self.observation_approximations.mean()-mean(self.observation_approximations.mean()));
                self.covariances = self.query_covariance_matrix-self.cross_covariance_matrix/(self.observation_covariance_matrix+observation_uncertainty)*self.cross_covariance_matrix';
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
        function reweight(self,method)
            samples_at_observations = interp1(self.queries.collate("location"),self.samples',self.observations.collate("location")');
            
            if strcmp(method,"rejection")
                supremum = self.getSupremum();
                new_samples = [];
                % What's the chance of getting those samples
                while size(new_samples,1)<size(self.samples,1)
                    for sample_index = 1:size(self.samples,1)
                        observation_probability = self.observations.getProbability(samples_at_observations(:,sample_index));
                        observation_approximation_probability = self.observation_approximations.getProbability(samples_at_observations(:,sample_index));
                        
                        accept = prod(observation_probability)./(prod(observation_approximation_probability)*supremum);
                        if rand(1)<accept
                            new_samples = [new_samples;self.samples(sample_index,:)];
                        end
                    end
                    disp(size(new_samples,1)+" out of "+size(self.samples,1));
                end
                
                
            elseif strcmp(method,"weight")
                observation_probability = NaN(size(samples_at_observations));
                observation_approximation_probability = NaN(size(samples_at_observations));
                for sample_index = 1:size(self.samples,1)
                    observation_probability(:,sample_index) = self.observations.getProbability(samples_at_observations(:,sample_index));
                    observation_approximation_probability(:,sample_index) = self.observation_approximations.getProbability(samples_at_observations(:,sample_index));
                end
                observations_probability_cumulative = prod(observation_probability,1);
                observation_approximations_probability_cumulative = prod(observation_approximation_probability,1);
                
                ratio = observations_probability_cumulative./observation_approximations_probability_cumulative;
                ratio_normalised = ratio./sum(ratio);
                [ratio_normalised_sorted,ratio_index] = sort(ratio_normalised);
                
                ratio_sampler = Geochemistry_Helpers.Sampler([ratio_index-0.5,ratio_index(end)+0.5],"manual",ratio_normalised_sorted,"latin_hypercube");
                ratio_sampler.getSamples(10000);
                rounded_samples = round(ratio_sampler.samples);
                new_samples = self.samples(rounded_samples,:);
            else
                error("Method unknown");
            end
            
            original_queries = self.queries.copy();
            self.samples = new_samples;
            self.assignSamples();
            
            %%
            index = 1;
            figure(1);
            clf
            hold on
            self.observations(index).plot('r');
            self.observation_approximations(index).plot('g');
            original_queries(round(original_queries(index).location*10 + 1)).plot('b');
            self.queries(round(self.observations(index).location*10 + 1)).plot('k');

            %%
            figure(2);
            clf
            hold on
            plot(self.queries.collate("location"),new_samples(1:100,:));
            
            plot(self.observations.collate("location"),self.observations.mean(),'ok','MarkerFaceColor','k');
        end
        
        function supremum = getSupremum(self)
            for distribution_index = 1:numel(self.observations)
                quantiles = self.observations(distribution_index).quantile([0.005,0.025,0.05,0.1,0.9,0.95,0.975,0.995]);
                observation_quantile_likelihoods = self.observations(distribution_index).getProbability(quantiles);
                observation_approximation_quantile_likelihoods = self.observation_approximations(distribution_index).getProbability(quantiles);
            
                ratio(:,distribution_index) = observation_quantile_likelihoods./observation_approximation_quantile_likelihoods;
            end
            suprema = max(ratio,[],1);
            supremum = prod(suprema);
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
