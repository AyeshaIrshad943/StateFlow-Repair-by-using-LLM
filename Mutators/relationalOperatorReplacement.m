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
            if contains(conditionsSeparatedByAnd,'||')
                strSplitByOr = split(conditionsSeparatedByAnd(ii),'||');
                for jj=1:length(strSplitByOr)
                    splitedCond(numOfConditions) = strSplitByOr(jj);
                    numOfConditions = numOfConditions+1;
                end 
            else
               splitedCond(numOfConditions) =  conditionsSeparatedByAnd(ii);
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
