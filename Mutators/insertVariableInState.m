function done = insertVariableInState(state,output)
    done = false;
    if(contains(state.LabelString,output.Name)==false)
        str = convertCharsToStrings(state.LabelString);
        selectVal = rand;
        if selectVal < 0.4
            str = str + newline + output.Name + '=' + num2str(0) + ';';
        elseif selectVal < 0.8
            str = str + newline + output.Name + '=' + num2str(1) + ';';
        else
            str = str + newline + output.Name + '=' + num2str(randi([0 50])) + ';'; % pulir esto
        end
        state.LabelString = str;
        done = true;
    end
end