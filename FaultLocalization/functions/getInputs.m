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