%% Miscellanous

clear;
clc;
%start

%open('simpleStateflowModel.slx')
rt = sfroot;
states = getStates(rt);%find(rt,'-isa','Stateflow.State'); % get all states from the stateflow model
transitions = getTransitions(rt);%find(rt,'-isa','Stateflow.Transition');
data = find(rt,'-isa','Stateflow.Data');
inputs = getInputs(rt);
outputs = getOutputs(rt);
%done = deleteState(states(4),transitions, states);
done = deleteConditionFromTransition(transitions(2));
done = insertConditionInTransition(transitions(1),rt)
done = deleteVariableFromState(states(2),rt);
done = insertMathematicalOperation(states(1),rt);
done = deleteState(states(4),transitions, states);
done = numericalChangeInTransition(transitions(2));
done = relationalOperatorReplacement(transitions(2));

done = replaceConditionalOperator(transitions(2));

done = insertVariableInState(states(1),outputs(1));
hasIt = checkStateContainsVariable(states(1),outputs(1));
variablesInState = getVariablesInState(getOutputs(rt),states(1));

done = changeAssignation(states(1));

done = numericalReplacementOfVariableInState(states(1),outputs(1));
%done = replacementOfTransitionSource(transitions(2),states);

a = isInitialTransition(transitions(3));
replaceInitialTransition(transitions,states);
b = replacementOfTransitionSource(transitions(1),states);


function done = deleteConditionFromTransition(transition)
    done = false;
    chr = transition.LabelString;
    if contains(chr,'&&') || contains(chr,'||') % more than one condition required
       andLocations = strfind(chr, '&&');
       orLocations = strfind(chr, '||');
       locations = sort([andLocations orLocations]);
       conditionToBeRemoved = randi(length(locations)+1);
       if conditionToBeRemoved==1
           %remove first
           chrNew = [chr(1) chr(locations(1)+2:length(chr))];
           transition.LabelString = chrNew;
           done = true;
       elseif conditionToBeRemoved == length(locations)+1
           %remove last
           chrNew = [chr(1:locations(conditionToBeRemoved-1)-1) ']'];
           finLocation = strfind(chr,']');
           if length(chr)>finLocation
               chrNew = [chrNew chr(finLocation:length(chr))];
           end
           transition.LabelString = chrNew;
           done = true;
       else
           loc = randi([conditionToBeRemoved-1,conditionToBeRemoved]);
           if loc<conditionToBeRemoved
               chrNew = chr(1:locations(loc)-1);
               chrNew = [chrNew chr(locations(loc+1):length(chr))];
               transition.LabelString = chrNew;
               done = true;
           else
               chrNew = chr(1:locations(loc-1)+1);
               chrNew = [chrNew chr(locations(loc)+2:length(chr))];
               transition.LabelString = chrNew;
               done = true;
           end
           %remove one in the middle, need to select which contional
           %operator to remove
       end
    end

end

function done = insertConditionInTransition(transition,rt)
    %TODO: Add it at a random point in the transition?
    done = false;
    inputs = getInputs(rt); %up to now, limited only to inputs
    
    if ~isempty(inputs) || ~isInitialTransition(transition)
        relationalOps = {'<=','>=','<','==','~='}; 
        conditionalOps = {'&&','||'}; 
        %selectedTrans = randi(length(transitions));
        selectedRelOp = relationalOps{randi(5)};
        selectedCondOp = conditionalOps{randi(2)};
        selectedInput = inputs(randi(length(inputs))).Name;
        if rand < 0.8
            numToBeSelected = randi([0,1]); %priority given to 1 or 0            
        else
            numToBeSelected = randi([-20,20]); %TODO --> POLISH THIS
        end
        newStr = [selectedCondOp ' ' selectedInput ' ' selectedRelOp ' ' num2str(numToBeSelected)];
        chr = transition.LabelString;
        lastLocation = strfind(chr, ']');
        chr = [chr(1:lastLocation-1) newStr ']'];
        transition.LabelString = chr;
    end
       
end


function done = deleteVariableFromState(state,rt)
    done = false;
    outputs = getOutputs(rt);
    %outputsInState = [];
    numsOfOutputsInState = 0;
    chr = state.Label;
    if length(outputs)>1 % at least there should be 2 variables
        for ii=1:length(outputs)
            if contains(state.Label,outputs(ii).Name)
                numsOfOutputsInState = numsOfOutputsInState+1;
                outputsInState(numsOfOutputsInState).Name = outputs(ii).Name;
                %aitor = 0;
            end
            
        end
        if numsOfOutputsInState > 2 % at least there should be 2 variables
            outputToRemove = outputsInState(randi([1 numsOfOutputsInState])).Name;
            idx = strfind(chr,outputToRemove);
            chrNew = chr(1:idx-1);
            while strcmp(chr(idx),';')==false && idx<length(chr)
               idx=idx+1; 
            end
            chrNew = [chrNew chr(idx+1:length(chr))];
            state.Label = chrNew;
            done = true;
        end
        
    end

end

function done = insertMathematicalOperation(state,rt)
    %TODO: Right now limited to include simple operations at the end of
    %statement. Could be extended for 1) including right after a variable,
    % 2) including data inside the operator, etc.
    done = false;
    chr = state.Label;
    str = convertCharsToStrings(state.Label);
    if contains(str,'=') && contains(str,';')
        locations = strfind(str,';');
        choosedLocation = locations(randi([1 length(locations)]));
        %select operator
        operator = ['+','-','*','/'];
        op = randi(4);
        selectedOperator = operator(op);
        
        
        newChr = chr(1:choosedLocation-1);
        newChr = [newChr selectedOperator num2str(randi(20)) ';'];
        newChr = [newChr chr(choosedLocation+1:length(chr))];
        state.Label = newChr;
        done = true;
    end
    
    
end

function done = deleteTransition(transition)
    if isInitialTransition(transitions(ii))
       done = false;
    else
       delete(transition);
       done = true;
    end
    
end

function done = deleteState(state, transitions, states)
    if length(states)<=1
        done = false;
    else
        for ii=1:length(transitions)
            if isInitialTransition(transitions(ii))
                if transitions(ii).Destination ==state
                    replacementOfTransitionDestination(transitions(ii),states);
                end
            elseif transitions(ii).Source==state || transitions(ii).Destination ==state

               delete(transitions(ii));
            end
        end
        delete(state);
        done = true;
    end    
end

function done = numericalChangeInTransition(transition)
    %TODO: Some times it may end a number to be --. Prune this.
    %TODO: This implementation is much clearer than the numerical changes
    %done in the states. Think how to integrate this in the states?
    done = false;
    str = convertCharsToStrings(transition.LabelString); 
    numsOfStr = regexp(str,'\d*','Match');
    whereNumsAre = [];
    for ii=1:length(numsOfStr)
        plusLocations = strfind(str,numsOfStr{ii});
        for jj=1:length(plusLocations)
            %isNum = isNumber(str,plusLocations(jj));
            %aitor = 0;
            if isNumber(str,plusLocations(jj))
               whereNumsAre = [whereNumsAre plusLocations(jj)];
            end
        end
       
    end
    whereNumsAre = unique(whereNumsAre);
    selectedNum = whereNumsAre(randi([1 length(whereNumsAre)]));
    chr = convertStringsToChars(str);
    chrNew = chr(1:selectedNum-1);
    ii=selectedNum;
    while isstrprop(chr(ii),'digit')
       ii=ii+1; 
    end
    
    %TODO: Polish this. Especially, maximum number is -15 + 15. How to
    %obtain another number?
    if rand <=0.5
        if rand <0.5
            selectedNum = 1;
        else
            selectedNum = 0;
        end
    else
        selectedNum = randi([-15 15]);
    end
    
    chrNew = [chrNew num2str(selectedNum)];
    chrNew = [chrNew chr(ii:length(chr))];
    %
    str2 = convertCharsToStrings(chrNew);
    if strcmp(str,str2)==false
        done = true;
        transition.LabelString = str2;
    end
        
end

function isNum = isNumber(str,charNum)
    isNum = false;
    if charNum==1
        isNum = true;
    elseif charNum<1
        isNum = false;
    else
        chr = convertStringsToChars(str);
        if isletter(chr(charNum-1))||strcmp(chr(charNum-1),'_')
            isNum=false;
        else
            isNum=true;
        end
    end
end

function done = relationalOperatorReplacement(transition)
    done = false;
    str = convertCharsToStrings(transition.LabelString);
    if contains(str,'==') || contains(str,'<') || contains(str,'>') || contains(str,'~=')
        numOfConditions = 1;
%         if contains(str,'&&') || contains(str,'||')
%             numOfConditions = length(strfind(str, '&&')) + length(strfind(str, '||'))+1;
%         end
        
        conditionsSeparatedByAnd =  split(str,'&&');
        %numsOfConditionsProcessed = 0;
        for ii=1:length(conditionsSeparatedByAnd)
            strSplitByOr = split(conditionsSeparatedByAnd(ii),'||');
            for jj=1:length(strSplitByOr)
               splitedCond(numOfConditions) = strSplitByOr(jj);
               numOfConditions = numOfConditions+1;
            end   
        end
        %select conditoin to mutate
        whichCond = randi([1, numOfConditions]);
        while contains(splitedCond(whichCond),'==')==false...
              && contains(splitedCond(whichCond),'~=')==false...
              && contains(splitedCond(whichCond),'<')==false ...
              && contains(splitedCond(whichCond),'>')==false 
            whichCond = randi([1, numOfConditions]);
        end
        
        if contains(splitedCond(whichCond),'==')
            selectedOperator = randi(4);
            operators = {'<=','>=','<','>','~='}; 
            newStr = strrep(splitedCond(whichCond),'==',operators{selectedOperator});
            transition.LabelString = strrep(transition.LabelString,splitedCond(whichCond),newStr);
            done = true;
        elseif contains(splitedCond(whichCond),'<=')
            selectedOperator = randi(4);
            operators = {'==','>=','<','>','~='}; 
            newStr = strrep(splitedCond(whichCond),'<=',operators{selectedOperator});
            transition.LabelString = strrep(transition.LabelString,splitedCond(whichCond),newStr);
            done = true;
        elseif contains(splitedCond(whichCond),'>=')
            selectedOperator = randi(4);
            operators = {'<=','==','<','>','~='}; 
            newStr = strrep(splitedCond(whichCond),'>=',operators{selectedOperator});
            transition.LabelString = strrep(transition.LabelString,splitedCond(whichCond),newStr);
            done = true;
        elseif contains(splitedCond(whichCond),'<')
            selectedOperator = randi(4);
            operators = {'<=','>=','<=','>','~='}; 
            newStr = strrep(splitedCond(whichCond),'<',operators{selectedOperator});
            transition.LabelString = strrep(transition.LabelString,splitedCond(whichCond),newStr);
            done = true;
        elseif contains(splitedCond(whichCond),'>')
            selectedOperator = randi(4);
            operators = {'<=','>=','<','==','~='}; 
            newStr = strrep(splitedCond(whichCond),'>',operators{selectedOperator});
            transition.LabelString = strrep(transition.LabelString,splitedCond(whichCond),newStr);
            done = true;
        elseif contains(splitedCond(whichCond),'~=')
            selectedOperator = randi(4);
            operators = {'<=','>=','<','==','>'}; 
            newStr = strrep(splitedCond(whichCond),'~=',operators{selectedOperator});
            transition.LabelString = strrep(transition.LabelString,splitedCond(whichCond),newStr);
            done = true;
        end
        
       
    end
   


end

function done = replaceSecMsecInAfter(transition)
    %TODO: All changes when more than one after in a transition. Could be
    %problematic, although this case is quite rare.
    %TODO: Extend for use with "tick"? also, quite a rare change
    done = false;
    str = convertCharsToStrings(transition.LabelString);
    if isInitialTransition(transition)==false && contains(str,'after')
        secLocations = strfind(str, 'sec');
        whichToChange = randi([1 length(secLocations)]);
        if strcmp(transition.LabelString(secLocations(whichToChange)-1), 'm')
            if rand<0.8
                newStr = strrep(str,'msec','sec');
                transition.LabelString = newStr;
                done = true;
            else
                newStr = strrep(str,'msec','usec');
                transition.LabelString = newStr;
                done = true;
            end
        elseif strcmp(transition.LabelString(secLocations(whichToChange)-1), 'u')
            if rand<0.8
                newStr = strrep(str,'usec','msec');
                transition.LabelString = newStr;
                done = true;
            else
                newStr = strrep(str,'usec','sec');
                transition.LabelString = newStr;
                done = true;
            end
        else
            if rand < 0.8
                newStr = strrep(str,'sec','msec');
                transition.LabelString = newStr;
                done = true;
            else
                newStr = strrep(str,'sec','usec');
                transition.LabelString = newStr;
                done = true;
            end 
        end
    end

end


function done = replaceMathematicalOperatorInTransition(transition)
    done = false;
    containsPlus = false;
    containsMinus = false;
    containsMult = false;
    containsDiv = false;
    plusLocations = 0;
    minusLocations = 0;
    multLocations = 0;
    divLocations = 0;
    str = convertCharsToStrings(transition.LabelString);
    if (contains(str,'+') || contains(str,'-') ||...
       contains(str,'*') || contains(str,'/')) && isInitialTransition(transition)==false
        if contains(str,'+')
            containsPlus = true;
            plusLocations = strfind(str, '+');
        end
        if contains(str,'-')
            containsMinus = true;
            minusLocations = strfind(str, '-');
        end
        if contains(str,'*')
            containsMult = true;
            multLocations = strfind(str, '*');
        end
        if contains(str,'/')
            containsDiv = true;
            divLocations = strfind(str, '/');
        end
        locations = [];
        if containsPlus
            locations = [locations  plusLocations];
        end
        if containsMinus
            locations = [locations  minusLocations];
        end
        if containsMult
            locations = [locations  multLocations];
        end
        if containsDiv
            locations = [locations  divLocations];
        end
        whichToChange = randi([1 length(locations)]);
        if strcmp(transition.LabelString(locations(whichToChange)),'+')
            if rand <= 0.5
                transition.LabelString(locations(whichToChange)) = '-';
                done = true;
            else
               if rand <=0.5 && strcmp(transition.LabelString(locations(whichToChange)+1), '0')==false
                   transition.LabelString(locations(whichToChange)) = '/';
                   done = true;
               else
                   transition.LabelString(locations(whichToChange)) = '*';
                   done = true;
               end
            end
            
        elseif strcmp(transition.LabelString(locations(whichToChange)),'-')
            if rand <= 0.5
                transition.LabelString(locations(whichToChange)) = '+';
                done = true;
            else
               if rand <=0.5 &&  strcmp(transition.LabelString(locations(whichToChange)+1), '0')==false
                   transition.LabelString(locations(whichToChange)) = '/';
                   done = true;
               else
                   transition.LabelString(locations(whichToChange)) = '*';
                   done = true;
               end
            end
            
        elseif strcmp(transition.LabelString(locations(whichToChange)),'*')
            if rand <= 0.5 && strcmp(transition.LabelString(locations(whichToChange)+1), '0')==false
                transition.LabelString(locations(whichToChange)) = '/';
                done = true;
            else
               if rand <=0.5
                   transition.LabelString(locations(whichToChange)) = '+';
                   done = true;
               else
                   transition.LabelString(locations(whichToChange)) = '-';
                   done = true;
               end
            end
            
        elseif strcmp(transition.LabelString(locations(whichToChange)),'/')
            if rand <= 0.5
                transition.LabelString(locations(whichToChange)) = '*';
                done = true;
            else
               if rand <=0.5
                   transition.LabelString(locations(whichToChange)) = '-';
                   done = true;
               else
                   transition.LabelString(locations(whichToChange)) = '+';
                   done = true;
               end
            end
            
        end
    end
end


function done = replaceMathematicalOperatorInState(state)
    done = false;
    containsPlus = false;
    containsMinus = false;
    containsMult = false;
    containsDiv = false;
    plusLocations = 0;
    minusLocations = 0;
    multLocations = 0;
    divLocations = 0;
    str = convertCharsToStrings(state.Label);
    if contains(str,'+') || contains(str,'-') ||...
       contains(str,'*') || contains(str,'/')
        if contains(str,'+')
            containsPlus = true;
            plusLocations = strfind(str, '+');
        end
        if contains(str,'-')
            containsMinus = true;
            minusLocations = strfind(str, '-');
        end
        if contains(str,'*')
            containsMult = true;
            multLocations = strfind(str, '*');
        end
        if contains(str,'/')
            containsDiv = true;
            divLocations = strfind(str, '/');
        end
        locations = [];
        if containsPlus
            locations = [locations  plusLocations];
        end
        if containsMinus
            locations = [locations  minusLocations];
        end
        if containsMult
            locations = [locations  multLocations];
        end
        if containsDiv
            locations = [locations  divLocations];
        end
        whichToChange = randi([1 length(locations)]);
        if strcmp(state.Label(locations(whichToChange)),'+')
            if rand <= 0.5
                state.Label(locations(whichToChange)) = '-';
                done = true;
            else
               if rand <=0.5 && strcmp(state.Label(locations(whichToChange)+1), '0')==false
                   state.Label(locations(whichToChange)) = '/';
                   done = true;
               else
                   state.Label(locations(whichToChange)) = '*';
                   done = true;
               end
            end
            
        elseif strcmp(state.Label(locations(whichToChange)),'-')
            if rand <= 0.5
                state.Label(locations(whichToChange)) = '+';
                done = true;
            else
               if rand <=0.5 &&  strcmp(state.Label(locations(whichToChange)+1), '0')==false
                   state.Label(locations(whichToChange)) = '/';
                   done = true;
               else
                   state.Label(locations(whichToChange)) = '*';
                   done = true;
               end
            end
            
        elseif strcmp(state.Label(locations(whichToChange)),'*')
            if rand <= 0.5 && strcmp(state.Label(locations(whichToChange)+1), '0')==false
                state.Label(locations(whichToChange)) = '/';
                done = true;
            else
               if rand <=0.5
                   state.Label(locations(whichToChange)) = '+';
                   done = true;
               else
                   state.Label(locations(whichToChange)) = '-';
                   done = true;
               end
            end
            
        elseif strcmp(state.Label(locations(whichToChange)),'/')
            if rand <= 0.5
                state.Label(locations(whichToChange)) = '*';
                done = true;
            else
               if rand <=0.5
                   state.Label(locations(whichToChange)) = '-';
                   done = true;
               else
                   state.Label(locations(whichToChange)) = '+';
                   done = true;
               end
            end
            
        end
        
%         numOfTotalOp = containsPlus+containsMinus+ContainsMult+containsDiv;
%         prob = 1/numOfTotalOp;
%         selectOp = randi([1,numOfTotalOp]);
%         i=1;
%         if containsPlus==1
%             if selectOp == i
%                %replace plus 
%             end
%             i = i+1;           
%         end
%         if containsMinus ==1
%             if selectOp ==i
%                 %replace minus
%             end
%         end
%         if containsMult ==1
%             if selectOp ==i
%                 %replaceMult
%             end
%         end
        
    end
    
end


function done = replaceConditionalOperator(transition)
    done = false;
    replaceAnd = false;
    replaceOr = false;
    str = transition.LabelString;
    if isInitialTransition(transition)==false
       if contains(str,'&&')&& contains(str,'||')
           if rand<=0.5
               replaceAnd = true;
           else
               replaceOr = true;
           end           
       elseif contains(str,'&&')
           replaceAnd = true;
           
       elseif contains(str,'||')
           replaceOr = true;           
       else
          %No conditional operator 
          
       end
       if replaceAnd
            andLocations = strfind(str, '&&');
            whichToChange = randi([1 length(andLocations)]);
            str(andLocations(whichToChange)) = '|'; % Replace first e with null (in other words, delete it).
            str(andLocations(whichToChange)+1) = '|';
            transition.LabelString = str;
            done = true;
       end
       if replaceOr
            orLocations = strfind(str, '||');
            whichToChange = randi([1 length(orLocations)]);
            str(orLocations(whichToChange)) = '&'; % Replace first e with null (in other words, delete it).
            str(orLocations(whichToChange)+1) = '&';
            transition.LabelString = str;
            done = true;
       end
    end
end


function done = insertVariableInState(state,output)
    done = false;
    if(contains(state.Label,output.Name)==false)
        str = convertCharsToStrings(state.Label);
        selectVal = rand;
        if selectVal < 0.4
            str = str + newline + output.Name + '=' + num2str(0) + ';';
        elseif selectVal < 0.8
            str = str + newline + output.Name + '=' + num2str(1) + ';';
        else
            str = str + newline + output.Name + '=' + num2str(randi([0 50])) + ';'; % pulir esto
        end
        state.Label = str;
        done = true;
    end
end

function done = changeAssignation(state)
    done = false;
    if contains(state.Label,'entry:')
        done = true;
        if rand <0.8
            %change entry for during
            str = convertCharsToStrings(state.Label);
            newStr = strrep(str,'entry','during');
            state.Label = newStr;
            
        else
           %change entry for exit--exit is less used, this is why less prob.
           str = convertCharsToStrings(state.Label);
           newStr = strrep(str,'entry','exit');
           state.Label = newStr;
        end
        
    elseif contains(state.Label,'during:')
        done = true;
        if rand <0.8
            %change entry for entry
            str = convertCharsToStrings(state.Label);
            newStr = strrep(str,'during','entry');
            state.Label = newStr;
            
        else
           %change entry for exit--exit is less used, this is why less prob. 
           str = convertCharsToStrings(state.Label);
           newStr = strrep(str,'during','exit');
           state.Label = newStr;
            
        end
        
    elseif contains(state.Label,'exit:')
        done = true;
        if rand <=0.5
            %change exit for during
           str = convertCharsToStrings(state.Label);
           newStr = strrep(str,'exit','during');
           state.Label = newStr;
        else
           % change exit for entry
           str = convertCharsToStrings(state.Label);
           newStr = strrep(str,'exit','entry');
           state.Label = newStr;
        end
        
    end
    
end

function done = replaceInitialTransition(transitions,states)
    done = false;
    for ii=1:size(transitions,1)
       if isInitialTransition(transitions(ii))
           done = replacementOfTransitionDestination(transitions(ii),states);
       end
    end

end

function is = isInitialTransition(tran)
    is = isa(tran.Source,'Stateflow.State')==false;
end

function done = replacementOfTransitionDestination(trans,states)
    done = false;
    if size(states,1)>1
        stateSame = true;
        while stateSame
            newDestinationState = randi([1 size(states,1)]);
            stateSame = trans.Destination == states(newDestinationState);
            if stateSame == false
                trans.Destination = states(newDestinationState);
                done = true;
            end
        end
    end
    
end

function done = replacementOfTransitionSource(trans,states)
    done = false;
    if size(states,1)>1 && isInitialTransition(trans) == false
        stateSame = true;
        while stateSame
            newSourceState = randi([1 size(states,1)]);
            stateSame = trans.Source == states(newSourceState);
            if stateSame == false
                trans.Source = states(newSourceState);
                done = true;
            end
        end
    end
    
end

function done = numericalReplacementOfVariableInState(state,var)
    done = false;
    if checkStateContainsVariable(state,var)
       str = split(convertCharsToStrings(state.Label),newline);
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
           state.Label = lab;
       end
    end

end


function vars = getVariablesInState(variablesToLookAt,state)
    numOfVars = 0;
    for ii=1:size(variablesToLookAt,1)
        if checkStateContainsVariable(state,variablesToLookAt(ii))
            numOfVars = numOfVars+1;
            vars(numOfVars) =  variablesToLookAt(ii);         
        end
    end
end

function state = getStates(rt)
    state= find(rt,'-isa','Stateflow.State');
end

function transitions = getTransitions(rt)
    transitions = find(rt,'-isa','Stateflow.Transition');
end

function inputs = getInputs(rt)
    data = find(rt,'-isa','Stateflow.Data');
    numOfInputs = 0;
    
    for ii=1:size(data,1)
        if strcmp(data(ii).Scope,'Input')
            numOfInputs = numOfInputs+1;
            inputs(numOfInputs,1) = data(ii);            
        end
    end
end

function outputs = getOutputs(rt)
    data = find(rt,'-isa','Stateflow.Data');
    numOfOutputs = 0;
    
    for ii=1:size(data,1)
        if strcmp(data(ii).Scope,'Output')
            numOfOutputs = numOfOutputs+1;
            outputs(numOfOutputs,1) = data(ii);            
        end
    end
end

function variableInState = checkStateContainsVariable(state,variable)
    strState = state.Label;
    strVariable = variable.Name;
    variableInState = contains(strState,strVariable);
end