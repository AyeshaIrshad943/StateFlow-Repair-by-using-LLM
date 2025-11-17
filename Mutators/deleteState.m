function done = deleteState(state, transitions, states)
    if length(states)<=1
        done = false;
    else
        for ii=1:length(transitions)
            if isInitialTransition(transitions(ii))
                if transitions(ii).Destination ==state
                    replacementOfTransitionDestination(transitions(ii),states);
                end
            elseif transitions(ii).Source==state || transitions(ii).Destination ==state

               delete(transitions(ii));
            end
        end
        delete(state);
        done = true;
    end    
end

