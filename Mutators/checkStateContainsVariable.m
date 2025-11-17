function variableInState = checkStateContainsVariable(state,variable)
    strState = state.LabelString;
    strVariable = variable.Name;
    variableInState = contains(strState,strVariable);
end