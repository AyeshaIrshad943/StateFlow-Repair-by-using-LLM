function done = replaceSecMsecInAfter(transition)
    %TODO: All changes when more than one after in a transition. Could be
    %problematic, although this case is quite rare.
    %TODO: Extend for use with "tick"? also, quite a rare change
    done = false;
    str = convertCharsToStrings(transition.LabelString);
    if isInitialTransition(transition)==false && contains(str,'after')
        secLocations = strfind(str, 'sec');
        whichToChange = randi([1 length(secLocations)]);
        if strcmp(transition.LabelString(secLocations(whichToChange)-1), 'm')
            if rand<0.8
                newStr = strrep(str,'msec','sec');
                transition.LabelString = newStr;
                done = true;
            else
                newStr = strrep(str,'msec','usec');
                transition.LabelString = newStr;
                done = true;
            end
        elseif strcmp(transition.LabelString(secLocations(whichToChange)-1), 'u')
            if rand<0.8
                newStr = strrep(str,'usec','msec');
                transition.LabelString = newStr;
                done = true;
            else
                newStr = strrep(str,'usec','sec');
                transition.LabelString = newStr;
                done = true;
            end
        else
            if rand < 0.8
                newStr = strrep(str,'sec','msec');
                transition.LabelString = newStr;
                done = true;
            else
                newStr = strrep(str,'sec','usec');
                transition.LabelString = newStr;
                done = true;
            end 
        end
    end

end

