function done = deleteTransition(transition)
    if isInitialTransition(transition)
       done = false;
    else
       delete(transition);
       done = true;
    end
    
end