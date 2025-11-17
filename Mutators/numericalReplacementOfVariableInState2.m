function done = numericalReplacementOfVariableInState2(state,outputs)
    done = false;
    totalNumOfOutputs = 0;
    
    for ii=1:size(outputs,1)
        if checkStateContainsVariable(state,outputs(ii))
            totalNumOfOutputs = totalNumOfOutputs+1;
            outs(totalNumOfOutputs)=ii;
        end
    end
    if totalNumOfOutputs>0
        var = outputs(outs(randi(totalNumOfOutputs)));
        if checkStateContainsVariable(state,var)
           str = split(convertCharsToStrings(state.LabelString),newline);
           for jj=1:size(str,1)
               if contains([str{jj} ' '],var.Name)|| contains([str{jj} '='],var.Name) % can be problematic
                   stringOfVar = str(jj);
                   numberStr =  split(stringOfVar,'=');
                   number =  str2num(numberStr(2));
                   numberSel = rand;
                   if numberSel < 0.25
                       newNum = 1; % I want 1/4 of the time the num to be 1
                   elseif numberSel < 0.5
                       newNum = 0; % I want 1/4 of the time the num to be 0
                   elseif numberSel < 0.75
                       newNum = -number;
                   else
                        newNum = randi([number-100 number+100 ]); % TODO -> polish this
                   end
                   str(jj) = strcat(numberStr(1), '=', num2str(newNum),';');
                   done = true;
                   break; % we supose only once is declared the variable
               end
           end
           if done
               lab = '';
               for jj=1:size(str,1)
                  lab =  lab + str(jj) + newline;
               end
               state.LabelString = lab;
           end
        end
    
    end
    

end