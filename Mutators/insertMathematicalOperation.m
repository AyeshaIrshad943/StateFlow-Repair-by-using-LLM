function done = insertMathematicalOperation(state)
    %TODO: Right now limited to include simple operations at the end of
    %statement. Could be extended for 1) including right after a variable,
    % 2) including data inside the operator, etc.
    done = false;
    chr = state.LabelString;
    str = convertCharsToStrings(state.LabelString);
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
        state.LabelString = newChr;
        done = true;
    end 
end