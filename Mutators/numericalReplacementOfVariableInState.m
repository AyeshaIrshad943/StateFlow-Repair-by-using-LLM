function done = numericalReplacementOfVariableInState(state,var)
    done = false;
    if checkStateContainsVariable(state,var)
       str = split(convertCharsToStrings(state.LabelString),newline);
       for jj=1:size(str,1)
           if contains([str{jj} ' '],var.Name)|| contains([str{jj} '='],var.Name) % can be problematic
               stringOfVar = str(jj);
               numberStr =  split(stringOfVar,'=');
               number =  str2num(numberStr(2));
               numberSel = rand;
               if numberSel < 0.33
                   newNum = 1; % I want 1/3 of the time the num to be 1
               elseif numberSel < 0.66
                   newNum = 0; % I want 1/3 of the time the num to be 0
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