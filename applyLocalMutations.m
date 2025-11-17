function done = applyLocalMutations(statesOrTransitions, stateNum, transNum, stateLogger, transitionLogger)

    done = false;
    useLLM = rand() < 0.7; 
    try
        
        rt = sfroot;
        states = rt.find('-isa', 'Stateflow.State');
        transitions = rt.find('-isa', 'Stateflow.Transition');

        if statesOrTransitions == 1 && ~isempty(states)
            state = states(stateNum);
            
            if useLLM
                try
                    done = LLMPatch_State(state, rt, stateNum, stateLogger);
                if done
                    return;
                end
                catch ME
                    disp('LLM patch failed — falling back to traditional mutation.');
                    warning("State LLM error: %s", ME.message);
                end
            end

         
            try
                selectedOperator = randi([1, 2]);
                switch selectedOperator
                    case 1
                        done = deleteState(state, transitions, states);
                       % disp("Deleting state : \n")
                    case 2
                        done = changeAssignation(state);
                        % disp("changing entry/exit/during : \n")
                end
            catch ME
                warning("Problem during state mutation: %s", ME.message);
            end

 
        elseif statesOrTransitions == 2 && ~isempty(transitions)
            transition = transitions(transNum);
             
            if useLLM
                try
                    done = LLMPatch_Transition(transition, rt, transNum, transitionLogger);
                    if done
                        return;
                    end

                catch ME
                    disp('LLM patch failed — falling back to traditional mutation.');
                    warning("Transition LLM error: %s", ME.message);
                end
            end

            try
                selectedOperator = randi([1, 5]);
                switch selectedOperator
                    case 1
                       %  disp("Deleting Transition : \n")
                        done = deleteTransition(transition);
                    case 2
                       %  disp("replace Initial Transition: \n")
                        done = replaceInitialTransition(transitions, states);
                    case 3
                       %  disp("replacement Of Transition Destination: \n")
                        done = replacementOfTransitionDestination(transition, states);
                    case 4
                       %  disp("replacement Of Transition Source: \n")
                        done = replacementOfTransitionSource(transition, states);
                end
            catch ME
                warning("Problem during transition mutation: %s", ME.message);
            end

        else
            disp('Invalid input or empty state/transition set.');
        end

    catch ME
        warning("Error during applyLocalMutations: %s", ME.message);
    end
end


