function done = replacementOfTransitionDestination(trans,states)
    done = false;
    if size(states,1)>1
        stateSame = true;
        while stateSame
            newDestinationState = randi([1 size(states,1)]);
            stateSame = trans.Destination == states(newDestinationState);
            if stateSame == false
                trans.Destination = states(newDestinationState);
                done = true;
            end
        end
    end
    
end
