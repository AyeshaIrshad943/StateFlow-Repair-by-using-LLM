function [done, statesOrTransitions, stateNum, transNum] = ...  
    applyGlobalMutations(suspiciousness_transitions, suspiciousness_states, timeBudget, ...
                         stateLogger, transitionLogger) %, triedStates, triedTransitions


    done = false;
    statesOrTransitions = 0;
    stateNum = 0;
    transNum = 0;
    useLLM = rand() < 0.7;

    if toc > timeBudget
        done = true;
        return;
    end

    rt = sfroot;
    states = rt.find('-isa', 'Stateflow.State');
    transitions = rt.find('-isa', 'Stateflow.Transition');


    statesOrTransitions = randi([1, 2]);

    if statesOrTransitions == 1 && ~isempty(states)
        stateNum = rouletteWheelSelection(suspiciousness_states);

        state = states(stateNum);
  %      triedStates = [triedStates, stateNum];

        if useLLM
            try
                done = LLMPatch_State(state, rt, stateNum, stateLogger);
                if done
                    return;
                end
            catch ME
                disp('LLM patch failed.');
                warning("State LLM error: %s", ME.message);
            end
        end

        try
            selectedOperator = randi([1, 2]);
            switch selectedOperator
                case 1
                  %  disp("delete State: \n")
                    done = deleteState(state, transitions, states);
                case 2
                 %   disp("change Assignation entry/during/exit: \n")
                    done = changeAssignation(state);
            end
        catch ME
            warning("Problem during state mutation: %s", ME.message);
        end

    elseif statesOrTransitions == 2 && ~isempty(transitions)
        transNum = rouletteWheelSelection(suspiciousness_transitions);
        % if ismember(transNum, triedTransitions)
        %     return;
        % end

        transition = transitions(transNum);
    %    triedTransitions = [triedTransitions, transNum];

        if useLLM
            try
                done = LLMPatch_Transition(transition, rt, transNum, transitionLogger);
                if done
                    return;
                end

            catch ME
                disp('LLM patch failed — falling back to mutation.');
                warning("Transition LLM error: %s", ME.message);
            end
        end

        try
            selectedOperator = randi([1, 4]);
            switch selectedOperator
                case 1
                    % disp("delete Transition: \n")
                    done = deleteTransition(transition);
                case 2
                    % disp("replacement Of Transition Source: \n")
                    done = replacementOfTransitionSource(transition, states);
                case 3
                    % disp("replacement Of Transition Destination: \n")
                    done = replacementOfTransitionDestination(transition, states);
                case 4
                    % disp("replace Initial transition: \n")
                    done = replaceInitialTransition(transitions, states);
            end
        catch ME
            warning("Problem during transition mutation: %s", ME.message);
        end

    else
        done = true;
    end
end



function selected_index = rouletteWheelSelection(probabilities)
    cumulative_probs = cumsum(probabilities)/sum(probabilities);  % Compute cumulative probabilities    
    selection = rand();  % Generate a random number between 0 and 1 
    % Perform Roulette Wheel Selection 
    selected_index = find(cumulative_probs >= selection, 1); 
 end





