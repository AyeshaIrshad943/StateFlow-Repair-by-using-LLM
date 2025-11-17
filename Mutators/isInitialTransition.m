function is = isInitialTransition(tran)
    is = isa(tran.Source,'Stateflow.State')==false;
end
