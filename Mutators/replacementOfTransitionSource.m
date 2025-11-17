function done = replacementOfTransitionSource(trans,states)
    done = false;
    if size(states,1)>1 && isInitialTransition(trans) == false
        stateSame = true;
        while stateSame
            newSourceState = randi([1 size(states,1)]);
            stateSame = trans.Source == states(newSourceState);
            if stateSame == false
                trans.Source = states(newSourceState);
                done = true;
            end
        end
    end
    
end

