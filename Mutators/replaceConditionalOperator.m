function done = replaceConditionalOperator(transition)
    done = false;
    replaceAnd = false;
    replaceOr = false;
    str = transition.LabelString;
    if isInitialTransition(transition)==false
       if contains(str,'&&')&& contains(str,'||')
           if rand<=0.5
               replaceAnd = true;
           else
               replaceOr = true;
           end           
       elseif contains(str,'&&')
           replaceAnd = true;
           
       elseif contains(str,'||')
           replaceOr = true;           
       else
          %No conditional operator 
          
       end
       if replaceAnd
            andLocations = strfind(str, '&&');
            whichToChange = randi([1 length(andLocations)]);
            str(andLocations(whichToChange)) = '|'; % Replace first e with null (in other words, delete it).
            str(andLocations(whichToChange)+1) = '|';
            transition.LabelString = str;
            done = true;
       end
       if replaceOr
            orLocations = strfind(str, '||');
            whichToChange = randi([1 length(orLocations)]);
            str(orLocations(whichToChange)) = '&'; % Replace first e with null (in other words, delete it).
            str(orLocations(whichToChange)+1) = '&';
            transition.LabelString = str;
            done = true;
       end
    end
end
