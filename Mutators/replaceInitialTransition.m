function done = replaceInitialTransition(transitions,states)
    done = false;
    for ii=1:size(transitions,1)
       if isInitialTransition(transitions(ii))
           done = replacementOfTransitionDestination(transitions(ii),states);
       end
    end

end
