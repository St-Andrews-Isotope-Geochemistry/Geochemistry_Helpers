classdef Timer<handle&Geochemistry_Helpers.Collator
    properties
        started_at
        finished_at
        number_of_iterations = 1;
        current_iteration = 0;
        average_time_taken = NaN;
        remaining_time = NaN;
    end
    properties (Dependent=true)
        percentage_complete
    end
    properties (Hidden=true)
        first_start = NaN;
        last_stop = NaN;
    end
    methods
        function self = Timer(iterations)
            if nargin>0
                self.number_of_iterations = iterations;
            end            
        end
        
        function self = start(self)
            self.started_at = tic;
            if isnan(self.first_start)
                self.first_start = self.started_at;
            end
        end
        function self = finish(self)
            self.finished_at = toc(self.started_at);
        end
        function percentage_complete = getPercentage(self,current_iteration)
            percentage_complete = (current_iteration/self.number_of_iterations).*100;
        end
        function self = predictFinish(self,current_iteration)
            time_taken = toc(self.started_at); % For timing
            self.last_stop = toc(self.first_start);
            
            self.current_iteration = current_iteration;
            
            if isnan(self.average_time_taken)
                self.average_time_taken = time_taken;
            else
                self.average_time_taken = (self.average_time_taken+time_taken).*0.5;
            end
            self.remaining_time = duration(0,0,(self.number_of_iterations-current_iteration).*self.average_time_taken);
        end
        
        function show(self)
            if floor(minutes(self.remaining_time))==0
                output_time_string = join([round(seconds(self.remaining_time),1),"seconds"]);
            elseif floor(hours(self.remaining_time))==0
                output_time_string = join([round(minutes(self.remaining_time),1),"minutes"]);
            else
                output_time_string = join([round(hours(self.remaining_time),0),"hours"]);
            end
            
            disp(join([self.getPercentage(self.current_iteration),"% done - approximately ",output_time_string," remaining"],"")); % Show percentage of data complete
        end
        function showFinal(self)
            total_time = duration(0,0,self.last_stop);
            if floor(minutes(total_time))==0
                output_time_string = join([round(seconds(total_time),1),"seconds"]);
            elseif floor(hours(total_time))==0
                output_time_string = join([round(minutes(total_time),1),"minutes"]);
            else
                output_time_string = join([round(hours(total_time),0),"hours"]);
            end
            
            disp(join(["100% done - took ",output_time_string],"")); % Show percentage of data complete
        end
    end
end