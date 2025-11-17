clear;
clc;
rng(0);%to debug
name = 'simpleStateflowModel';

budget = 100;
totalMutants = 0;
while totalMutants<budget
   totalMutants=totalMutants+1;
   disp(['Total mutations applied = ' num2str(totalMutants)]);
   copyfile([name '.slx'], [name '_' num2str(totalMutants) '.slx']); 
   open_system([name '_' num2str(totalMutants) '.slx']);
   applyMutations();
   executeTest([name '_' num2str(totalMutants) '.slx']);
   save_system([name '_' num2str(totalMutants) '.slx']);
   close_system([name '_' num2str(totalMutants) '.slx']);
end

function done = applyMutations()
    numOfMutationsDone = 0;
    rt = sfroot;
    while rand<0.5^numOfMutationsDone
        done = false;
        
    while done == false
        states = getStates(rt);
        transitions = getTransitions(rt);
        statesOrTransitions = randi([1,2]);
        if statesOrTransitions==1
              %choose a state
            chosenState = states(randi([1,length(states)]));
            %chosenTrans = transitions(randi([1,length(transitions)]));
             selectedOperator = randi([1,6]);
            if selectedOperator==1
                try 
                    done = deleteVariableFromState(chosenState,rt);
                catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator==2
                try 
                    done = insertMathematicalOperation(chosenState);
                catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator==3
                try 
                    done = deleteVariableFromState(chosenState,rt);
                catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator==4
                try 
                    done = deleteState(chosenState,transitions,states);
                catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator==5
                try 
                    outputs = getOutputs(rt);
                    
                    done = insertVariableInState(chosenState,outputs(randi(randi([1,length(outputs)]))));
                catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator==6
                try 
                    done = changeAssignation(chosenState);
                catch
                    disp('Problem when generating mutation'); % buggi tiene pinta
                end
            end
                
                
                
        else
            %choose a transition
            chosenTrans = transitions(randi([1,length(transitions)]));
            %transitions(chosenTrans);
            selectedOperator = randi([1,11]);
            if selectedOperator==1
                try 
                    done = deleteConditionFromTransition(chosenTrans);
                catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator==2
                try
                    done = insertConditionInTransition(chosenTrans,rt);
                catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator==3
                try
                    done = deleteTransition(chosenTrans);
                catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator==4
                try
                    done = numericalChangeInTransition(chosenTrans);
                catch
                    disp('Problem when generating mutation');%bug (reproduced after mutation 32)
                end
            elseif selectedOperator==5
                try
                    done = relationalOperatorReplacement(chosenTrans); % potential bug (reproduced after mutation 14); looks like it comes from another place
                catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator==6
                try
                    done = replaceSecMsecInAfter(chosenTrans);
                catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator==7
                try
                    done = replaceMathematicalOperatorInTransition(chosenTrans);
                catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator==8
               try
                    done = replaceConditionalOperator(chosenTrans);
               catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator==9
               try
                    done = replaceInitialTransition(transitions,states);
               catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator==10
               try
                    done = replacementOfTransitionDestination(chosenTrans,states);
               catch
                    disp('Problem when generating mutation');
                end
            elseif selectedOperator ==11
                try
                    done = replacementOfTransitionSource(chosenTrans,states);
                catch
                    disp('Problem when generating mutation');
                end
            end

        end
    end
              
        
        numOfMutationsDone = numOfMutationsDone+1;
    end
    

end

function verdict = executeTest(model)
    try
        sim(model);
        verdict = 0;
    catch
       disp('non-compilable model'); 
    end

end

