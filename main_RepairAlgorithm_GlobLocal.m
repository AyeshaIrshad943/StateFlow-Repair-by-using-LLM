clear;
clc;
rng(3);


restoredefaultpath;
addpath(genpath(pwd)); 

resultsDir = 'Results';  % folder to store outputs

modelDir = 'ModelsWithRealFaults\door_2';

if isfolder(resultsDir), addpath(resultsDir); end         %if both folders exist add to matlab path
if isfolder(modelDir), addpath(modelDir); end


stateLogger = StateRepairLogger();                      %logger objects for saving results
transitionLogger = StateRepairLogger();

% validatedDir = 'validated';
% if ~exist(validatedDir, 'dir')
%     mkdir(validatedDir);
% end

bdclose('all');


faultyModel = 'ModelsWithRealFaults\door_2\Door_Model_Incorrect';   
nonFaultyModel = 'ModelsWithRealFaults\door_2\Door_Model_Correct';
load('ModelsWithRealFaults/door_2/fl_data_states.mat');                
load('ModelsWithRealFaults/door_2/fl_data_transitions.mat');

executeTest = @executeTestDoor;

% faultyModel = 'ModelsWithRealFaults\elevator_2\Elevator_Incorrect_abiadura_Ur1';
% nonFaultyModel = 'ModelsWithRealFaults\elevator_2\Elevator_Correct';
% load('ModelsWithRealFaults/elevator_2/fl_data_states.mat');
% load('ModelsWithRealFaults/elevator_2/fl_data_transitions.mat');
% 
% executeTest = @executeTestElevator;


[bestVerdict, bestTimeVerdictActive, bestCriticalityVerdict, bestTimeFirstFailureExhibited] = executeTest(faultyModel);

bdclose(nonFaultyModel);
bdclose(faultyModel);

numOfIterations = 0;
budget = 10000;
numsOfSolsInArchive = 1;

PlausiblePatches=[""];
numsOfPlausiblePatches = 0;

Archive{numsOfSolsInArchive} = struct( ...
    'modelName', faultyModel, ...
    'verdict', bestVerdict, ...
    'timeVerdict', bestTimeVerdictActive, ...
    'criticality', bestCriticalityVerdict, ...
    'firstFailureExhibited', bestTimeFirstFailureExhibited ...
);

plausiblePatchFound = false;
timeBudget = 60 * 3;
%ValidatedPatches = {[]};
%validatedPatchCount = 0;

tic;

while toc < timeBudget
    verdictEnhanced = false;

    while ~verdictEnhanced && toc < timeBudget
        numOfIterations = numOfIterations + 1;
        selectedModelToMutate = randi([1 numsOfSolsInArchive]);
        faultyModel = Archive{selectedModelToMutate}.modelName;
        newModelName = [faultyModel '_' num2str(numOfIterations)];
        copyfile([faultyModel '.slx'], [newModelName '.slx']);
        open_system([newModelName '.slx']);

        done = false;
        
        
        triedStates = [];
        triedTransitions = [];
        
        while true
            %[done, statesOrTransitions, stateNum, transNum, ValidatedPatches, validatedPatchCount, ...
            [done, statesOrTransitions, stateNum, transNum, triedStates, triedTransitions] = ...
                applyGlobalMutations(suspiciousness_transitions, suspiciousness_states, ...
                                     timeBudget, stateLogger, transitionLogger, ...
                                     triedStates, triedTransitions);                             
        
             if done
                 break;
             end
        
            if length(triedStates) >= length(suspiciousness_states) && ...
               length(triedTransitions) >= length(suspiciousness_transitions)
                disp("All states and transitions attempted. Exiting loop.");
                break;
            end
        end


        try
            save_system([newModelName '.slx']);
        catch
        end

        bdclose(newModelName);

        try
            [verdict, timeVerdictActive, criticalityVerdict, timeFirstFailureExhibited] = executeTest(newModelName);
            if sum(verdict) == 0
                plausiblePatchFound = true;
                PlausiblePatches{end + 1} = newModelName;
                numsOfPlausiblePatches = numsOfPlausiblePatches+1;
                PlausiblePatches(numsOfPlausiblePatches) = strcat(faultyModel, '_', num2str(numOfIterations), '.slx');
                disp(['Plausible patch found: ' newModelName]);
            elseif (timeVerdictActive < Archive{selectedModelToMutate}.timeVerdict || ...
                    criticalityVerdict < Archive{selectedModelToMutate}.criticality || ...
                    timeFirstFailureExhibited > Archive{selectedModelToMutate}.firstFailureExhibited)
                Archive{end + 1} = struct( ...
                    'modelName', newModelName, ...
                    'timeVerdict', timeVerdictActive, ...
                    'criticality', criticalityVerdict, ...
                    'firstFailureExhibited', timeFirstFailureExhibited ...
                );
                verdictEnhanced = true;
            end

        catch
            disp('Non-compilable model.');
        end

        bdclose(nonFaultyModel);
        bdclose(newModelName);
    end

    numOfLocalTries = 0;
    totalLocalTries = 30;
    modelToPerformLocalMutations = numsOfSolsInArchive;

    while numOfLocalTries < totalLocalTries && toc < timeBudget
        numOfLocalTries = numOfLocalTries + 1;
        numOfIterations = numOfIterations + 1;

        selectedModelToMutate = modelToPerformLocalMutations;
        faultyModel = Archive{selectedModelToMutate}.modelName;
        newModelName = [faultyModel '_' num2str(numOfIterations)];
        copyfile([faultyModel '.slx'], [newModelName '.slx']);
        open_system([newModelName '.slx']);

        done = false;
        while ~done
        % [done, ValidatedPatches, validatedPatchCount] = ...
            [done] = applyLocalMutations(statesOrTransitions, stateNum, transNum, ...
                                     stateLogger, transitionLogger);
                                    
        end

        try
            save_system([newModelName '.slx']);
        catch
        end

        bdclose(newModelName);

        try
            [verdict, timeVerdictActive, criticalityVerdict, timeFirstFailureExhibited] = executeTest(newModelName);
            if sum(verdict) == 0
                plausiblePatchFound = true;
                PlausiblePatches{end + 1} = newModelName;
                 numsOfPlausiblePatches = numsOfPlausiblePatches+1;
                PlausiblePatches(numsOfPlausiblePatches) = strcat(faultyModel, '_', num2str(numOfIterations), '.slx');
                disp(['Plausible patch found (local): ' newModelName]);
                stateLogger.log(stateNum, statesOrTransitions, true, true, proposedPatch);
            elseif (timeVerdictActive < Archive{selectedModelToMutate}.timeVerdict || ...
                    criticalityVerdict < Archive{selectedModelToMutate}.criticality || ...
                    timeFirstFailureExhibited > Archive{selectedModelToMutate}.firstFailureExhibited)
                    Archive{end + 1} = struct( ...
                    'modelName', newModelName, ...
                    'timeVerdict', timeVerdictActive, ...
                    'criticality', criticalityVerdict, ...
                    'firstFailureExhibited', timeFirstFailureExhibited ...
                );
                verdictEnhanced = true;
                modelToPerformLocalMutations = numsOfSolsInArchive;
                numOfLocalTries = 0;
            end
        catch
            disp('Non-compilable model.');
        end

        bdclose(nonFaultyModel);
        bdclose(newModelName);
    end

    Archive = clearArchive(Archive);
end

%save('validated_patches.mat', 'ValidatedPatches');

stateLogger.saveLogs('StatePatchResults');             %saving results in csv
transitionLogger.saveLogs('TransitionPatchResults');

function Archive = clearArchive(Archive)
    %TODO -> Implement function
    Archive = Archive;

end