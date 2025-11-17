function done = changeAssignation(state)
    done = false;
    if contains(state.LabelString,'entry:')
        done = true;
        if rand <0.8
            %change entry for during
            str = convertCharsToStrings(state.LabelString);
            newStr = strrep(str,'entry','during');
            state.LabelString = newStr;
            
        else
           %change entry for exit--exit is less used, this is why less prob.
           str = convertCharsToStrings(state.LabelString);
           newStr = strrep(str,'entry','exit');
           state.LabelString = newStr;
        end
        
    elseif contains(state.LabelString,'during:')
        done = true;
        if rand <0.8
            %change entry for entry
            str = convertCharsToStrings(state.LabelString);
            newStr = strrep(str,'during','entry');
            state.LabelString = newStr;
            
        else
           %change entry for exit--exit is less used, this is why less prob. 
           str = convertCharsToStrings(state.LabelString);
           newStr = strrep(str,'during','exit');
           state.LabelString = newStr;
            
        end
        
    elseif contains(state.LabelString,'exit:')
        done = true;
        if rand <=0.5
            %change exit for during
           str = convertCharsToStrings(state.LabelString);
           newStr = strrep(str,'exit','during');
           state.LabelString = newStr;
        else
           % change exit for entry
           str = convertCharsToStrings(state.LabelString);
           newStr = strrep(str,'exit','entry');
           state.LabelString = newStr;
        end
        
    end
    
end
