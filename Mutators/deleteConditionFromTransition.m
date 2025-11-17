function done = deleteConditionFromTransition(transition)
    done = false;
    chr = transition.LabelString;
    if contains(chr,'&&') || contains(chr,'||') % more than one condition required
       andLocations = strfind(chr, '&&');
       orLocations = strfind(chr, '||');
       locations = sort([andLocations orLocations]);
       conditionToBeRemoved = randi(length(locations)+1);
       if conditionToBeRemoved==1
           %remove first
           chrNew = [chr(1) chr(locations(1)+2:length(chr))];
           transition.LabelString = chrNew;
           done = true;
       elseif conditionToBeRemoved == length(locations)+1
           %remove last
           chrNew = [chr(1:locations(conditionToBeRemoved-1)-1) ']'];
           finLocation = strfind(chr,']');
           if length(chr)>finLocation
               chrNew = [chrNew chr(finLocation:length(chr))];
           end
           transition.LabelString = chrNew;
           done = true;
       else
           loc = randi([conditionToBeRemoved-1,conditionToBeRemoved]);
           if loc<conditionToBeRemoved
               chrNew = chr(1:locations(loc)-1);
               chrNew = [chrNew chr(locations(loc+1):length(chr))];
               transition.LabelString = chrNew;
               done = true;
           else
               chrNew = chr(1:locations(loc-1)+1);
               chrNew = [chrNew chr(locations(loc)+2:length(chr))];
               transition.LabelString = chrNew;
               done = true;
           end
           %remove one in the middle, need to select which contional
           %operator to remove
       end
    end

end