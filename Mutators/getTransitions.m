function transitions = getTransitions(rt)
    transitions = find(rt,'-isa','Stateflow.Transition');
end