function LLMBasedGlobalLocalAlgorithm(seed,faultyModel, nonFaultyModel, executeTest, current_Path)
%% INPUT VARIABLES

% seed = The seed to initialize the rng
% faultyModel = Path to faulty model
% nonFaultyModel = Path to non faulty model

%%
    rng(seed);
        
    bdclose('all')
    
    load('fl_data_states.mat');
    load('fl_data_transitions.mat');
    
    stateLogger = StateRepairLogger();                      
    transitionLogger = StateRepairLogger();
    
    [bestVerdict,bestTimeVerdictActive,bestCriticalityVerdict,bestTimeFirstFailureExhibited] = executeTest(faultyModel);
    bdclose(nonFaultyModel);
    bdclose(faultyModel);

    baseFaultyModel = faultyModel;

    numOfIterations = 0;
    budget = 10000;
    
    numsOfSolsInArchive = 1;
    Archive{numsOfSolsInArchive}.modelName = faultyModel;
    Archive{numsOfSolsInArchive}.verdict = bestVerdict;
    Archive{numsOfSolsInArchive}.timeVerdict = bestTimeVerdictActive;
    Archive{numsOfSolsInArchive}.criticality = bestCriticalityVerdict;
    Archive{numsOfSolsInArchive}.firstFailureExhibited = bestTimeFirstFailureExhibited;
    
    numsOfPlausiblePatches = 0;
    plausiblePatchFound = false;
    
    timeBudget = 60*60; %1 hour
    tic;
    PlausiblePatches=[""];
    
    partialDir = fullfile(current_Path, "PartialArchive");
    if ~exist(partialDir, 'dir')
        mkdir(partialDir);
    end
    

    while toc<timeBudget 
        
        %Global search
        verdictEnhanced = false;
        while ~verdictEnhanced && toc<timeBudget
            numOfIterations=numOfIterations+1;
            selectedModelToMutate = randi([1 numsOfSolsInArchive]);
            faultyModel = Archive{selectedModelToMutate}.modelName;
        %    disp(['Selected model for mutation: ', faultyModel]);

            newModelName = strcat(baseFaultyModel, '_', num2str(numOfIterations));
            copyfile(strcat(baseFaultyModel, '.slx'), strcat(newModelName, '.slx')); 
            open_system(strcat(newModelName, '.slx'));
            done = false;

            %Uncoment for ELlement Selection limit/Avoids repeated element
            %selection

            % triedStates = [];
            % triedTransitions = [];
            % 
            % while done == false
            %     [done, statesOrTransitions, stateNum, transNum, triedStates, triedTransitions] = ...  %, triedStates, triedTransitions
            %     applyGlobalMutations(suspiciousness_transitions, suspiciousness_states, ...
            %                          timeBudget, stateLogger, transitionLogger, triedStates, triedTransitions);
            %                                                       % triedStates, triedTransitions
            %      if done
            %          break;
            %      end
            %     if length(triedStates) >= length(suspiciousness_states) && ...
            %        length(triedTransitions) >= length(suspiciousness_transitions)
            %         disp("All states and transitions attempted. Exiting loop.");
            %         break;
            %     end
            % end
            %without selection limit/
            
            while done == false
                [done, statesOrTransitions, stateNum, transNum] = ...  %, triedStates, triedTransitions
                applyGlobalMutations(suspiciousness_transitions, suspiciousness_states, ...
                                     timeBudget, stateLogger, transitionLogger);
                                                                  % triedStates, triedTransitions
                 if done
                     break;
                 end

            end
            
            try
                save_system(strcat(newModelName, '.slx'));
            catch
            end
            bdclose(strcat(newModelName, '.slx'));

            try
                [verdict,timeVerdictActive,criticalityVerdict,timeFirstFailureExhibited] = executeTest(newModelName);
                if sum(verdict)==0
                    plausiblePatchFound =true;
                    numsOfPlausiblePatches = numsOfPlausiblePatches+1;
                    PlausiblePatches(numsOfPlausiblePatches) = strcat(newModelName, '.slx');
                    disp(strcat('Plausible patch found! ' , newModelName));
                elseif (timeVerdictActive<Archive{selectedModelToMutate}.timeVerdict || criticalityVerdict<Archive{selectedModelToMutate}.criticality || timeFirstFailureExhibited>Archive{selectedModelToMutate}.firstFailureExhibited )...
                        && ~(timeVerdictActive>Archive{selectedModelToMutate}.timeVerdict || criticalityVerdict>Archive{selectedModelToMutate}.criticality || timeFirstFailureExhibited<Archive{selectedModelToMutate}.firstFailureExhibited )
                    faultyModel = newModelName;
                    if exist('stateNum','var') && ~isempty(stateNum)
                        elementName = sprintf("State_%d", stateNum);
                    elseif exist('transNum','var') && ~isempty(transNum)
                        elementName = sprintf("Transition_%d", transNum);
                    else
                        elementName = "UnknownElement";
                    end 
                    partialFile = fullfile(partialDir, elementName + ".txt");
                    fid = fopen(partialFile, 'a');
                    fprintf(fid, "%s\n", strcat(newModelName, '.slx'));
                    fclose(fid);
                    plausiblePatchFound = false;
                    numsOfSolsInArchive = numsOfSolsInArchive+1;
                    Archive{numsOfSolsInArchive}.modelName = faultyModel;
                    Archive{numsOfSolsInArchive}.timeVerdict = timeVerdictActive;
                    Archive{numsOfSolsInArchive}.criticality = criticalityVerdict;
                    Archive{numsOfSolsInArchive}.firstFailureExhibited = timeFirstFailureExhibited;
                    verdictEnhanced = true;
                end
            catch
               disp('non-compilable model'); 
            end
            bdclose(nonFaultyModel);
            bdclose(strcat(newModelName, '.slx'));
            bdclose('all')
        end
        
        %Local search
        numOfLocalTries = 0;
        totalLocalTries = 30;
        modelToPerformLocalMutations = numsOfSolsInArchive;
        
        while numOfLocalTries<totalLocalTries && toc<timeBudget
            numOfLocalTries = numOfLocalTries+1;
            numOfIterations=numOfIterations+1;
            selectedModelToMutate = modelToPerformLocalMutations;
            faultyModel = Archive{modelToPerformLocalMutations}.modelName;
           % disp(['Selected model for mutation by local mutatations: ', faultyModel]);

            newModelName = strcat(baseFaultyModel, '_', num2str(numOfIterations));
            copyfile(strcat(baseFaultyModel, '.slx'), strcat(newModelName, '.slx')); 
            open_system(strcat(newModelName, '.slx'));
            done = false;
            while done == false
                [done] = applyLocalMutations(statesOrTransitions, stateNum, transNum, ...
                                     stateLogger, transitionLogger);
            end

            try
                save_system(strcat(newModelName, '.slx'));
            catch
            end
            
            bdclose(strcat(newModelName, '.slx'));
    
            try
                [verdict,timeVerdictActive,criticalityVerdict,timeFirstFailureExhibited] = executeTest(newModelName);
                if sum(verdict)==0
                    plausiblePatchFound =true;
                    numsOfPlausiblePatches = numsOfPlausiblePatches+1;
                    PlausiblePatches(numsOfPlausiblePatches) = strcat(newModelName, '.slx');
                    disp(strcat('Plausible patch found ' , newModelName));
                elseif (timeVerdictActive<Archive{selectedModelToMutate}.timeVerdict || criticalityVerdict<Archive{selectedModelToMutate}.criticality || timeFirstFailureExhibited>Archive{selectedModelToMutate}.firstFailureExhibited )...
                        && ~(timeVerdictActive>Archive{selectedModelToMutate}.timeVerdict || criticalityVerdict>Archive{selectedModelToMutate}.criticality || timeFirstFailureExhibited<Archive{selectedModelToMutate}.firstFailureExhibited )
                    faultyModel = newModelName; 
                    if exist('stateNum','var') && ~isempty(stateNum)
                        elementName = sprintf("State_%d", stateNum);
                    elseif exist('transNum','var') && ~isempty(transNum)
                        elementName = sprintf("Transition_%d", transNum);
                    else
                        elementName = "UnknownElement";
                    end 
                    partialFile = fullfile(partialDir, elementName + ".txt");
                    fid = fopen(partialFile, 'a');
                    fprintf(fid, "%s\n", strcat(newModelName, '.slx'));
                    fclose(fid);
                    plausiblePatchFound = false;
                    numsOfSolsInArchive = numsOfSolsInArchive+1;
                    Archive{numsOfSolsInArchive}.modelName = faultyModel;
                    Archive{numsOfSolsInArchive}.timeVerdict = timeVerdictActive;
                    Archive{numsOfSolsInArchive}.criticality = criticalityVerdict;
                    Archive{numsOfSolsInArchive}.firstFailureExhibited = timeFirstFailureExhibited;
                    verdictEnhanced = true;
                    modelToPerformLocalMutations = numsOfSolsInArchive;
                    numOfLocalTries=0;
                end
            catch
               disp('non-compilable model'); 
            end
            bdclose(nonFaultyModel);
            bdclose(strcat(newModelName, '.slx'));
            bdclose('all')
            
        end
        Archive = clearArchive(Archive);
    end
    stateLogger.saveLogs('StatePatchResults');             
    transitionLogger.saveLogs('TransitionPatchResults');

    filename=strcat(current_Path,"/PlausiblePatches.txt");
    file_id=fopen(filename,'w');
    for i =1:length(PlausiblePatches)
       fprintf(file_id, '%s', PlausiblePatches(i)); 
       fprintf(file_id, '\n'); 
    end
    fclose(file_id);

end

function Archive = clearArchive(Archive)
    Archive = Archive;
end


