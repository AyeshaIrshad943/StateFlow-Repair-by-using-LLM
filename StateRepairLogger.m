classdef StateRepairLogger < handle
    properties
        Results
        Headers = {'Index', 'OriginalLabel', 'FaultDetected', 'ValidPatch', 'ProposedPatch'}
    end

    methods
        function obj = StateRepairLogger()
            obj.Results = cell2table(cell(0, 5), 'VariableNames', obj.Headers);
        end

        function obj = log(obj, index, originalLabel, faultDetected, validPatch, proposedPatch)
            if nargin < 6
                proposedPatch = "";
            end
            %newRow = {index, originalLabel, faultDetected, validPatch,
            %proposedPatch};  introduces a cell and merges multiple column
            %so need to add table row

             
            originalLabel = string(originalLabel); %nonverting to string (ensures no cellstr issues)
            proposedPatch = string(proposedPatch);
        
            originalLabel = regexprep(originalLabel, '[,\n\r]', ';');
            proposedPatch = regexprep(proposedPatch, '[,\n\r]', ';'); %replacing commas/newlines into semicolons/spaces to avoid confusion

            newRow = cell2table({index, originalLabel, faultDetected, validPatch, proposedPatch}, ...
            'VariableNames', obj.Headers);
            obj.Results = [obj.Results; newRow];
        end

        function saveLogs(obj, baseName)
            if nargin < 2 || isempty(baseName)
                baseName = 'PatchResults';
            end

            resultsDir = 'EvaluateResults';
            if ~exist(resultsDir, 'dir')
                mkdir(resultsDir);
            end


            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            csvFile = fullfile(resultsDir, [baseName '_' timestamp '.csv']);

            try
                writetable(obj.Results, csvFile);
                fprintf('CSV log saved: %s\n', csvFile);
            catch ME
                warning('Failed to write CSV file.\n%s', ME.message);
            end
            total = height(obj.Results);
            patched = sum(obj.Results.ValidPatch);
            skipped = total - patched;

            fprintf('\n=== Patch Summary: %s ===\n', baseName);
            fprintf('Total Processed:      %d\n', total);
            fprintf('Successfully Patched: %d\n', patched);
            fprintf('Skipped/Unpatched:    %d\n', skipped);
        end

        % function saveLogs(obj, baseName)
        %     if nargin < 2 || isempty(baseName)
        %         baseName = 'PatchResults';
        %     end
        % 
        %     resultsDir = 'EvalResults';
        %     if ~exist(resultsDir, 'dir')
        %         mkdir(resultsDir);
        %     end
        % 
        %     timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        % 
        %     allFile = fullfile(resultsDir, [baseName '_ALL_' timestamp '.xlsx']);  % Save ALL patches palusible, partial and failed
        %     writetable(obj.Results, allFile);
        % 
        %     plausibleMask = obj.Results.ValidPatch == true;  %plausible patch save                                 
        %     plausibleFile = fullfile(resultsDir, [baseName '_PLAUSIBLE_' timestamp '.xlsx']);
        %     writetable(obj.Results(plausibleMask, :), plausibleFile);
        % 
        %     partialMask = obj.Results.ValidPatch == false & obj.Results.FaultDetected == true; %partial patch
        %     partialFile = fullfile(resultsDir, [baseName '_PARTIAL_' timestamp '.xlsx']);
        %     writetable(obj.Results(partialMask, :), partialFile);
        % 
        %     total = height(obj.Results);
        %     patched = sum(plausibleMask);
        %     partials = sum(partialMask);
        %     skipped = total - patched - partials;
        % 
        %     fprintf('\n=== Patch Summary: %s ===\n', baseName);
        %     fprintf('Total Processed:      %d\n', total);
        %     fprintf('Plausible Patches:    %d\n', patched);
        %     fprintf('Partial Patches:      %d\n', partials);
        %     fprintf('Skipped/Failed:       %d\n', skipped);
        %     fprintf('Logs saved in: %s\n', resultsDir);
        % end

    end
end

