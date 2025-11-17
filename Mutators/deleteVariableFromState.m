function done = deleteVariableFromState(state,rt)
    done = false;
    outputs = getOutputs(rt);
    %outputsInState = [];
    numsOfOutputsInState = 0;
    chr = state.LabelString;
    if length(outputs)>1 % at least there should be 2 variables
        for ii=1:length(outputs)
            if contains(state.LabelString,outputs(ii).Name)
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
            state.LabelString = chrNew;
            done = true;
        end
        
    end

end