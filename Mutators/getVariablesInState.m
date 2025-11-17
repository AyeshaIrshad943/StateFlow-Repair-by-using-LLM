function vars = getVariablesInState(variablesToLookAt,state)
    numOfVars = 0;
    for ii=1:size(variablesToLookAt,1)
        if checkStateContainsVariable(state,variablesToLookAt(ii))
            numOfVars = numOfVars+1;
            vars(numOfVars) =  variablesToLookAt(ii);         
        end
    end
end