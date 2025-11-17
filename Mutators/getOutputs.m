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