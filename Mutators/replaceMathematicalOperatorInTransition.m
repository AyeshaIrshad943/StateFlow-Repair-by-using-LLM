function done = replaceMathematicalOperatorInTransition(transition)
    done = false;
    containsPlus = false;
    containsMinus = false;
    containsMult = false;
    containsDiv = false;
    plusLocations = 0;
    minusLocations = 0;
    multLocations = 0;
    divLocations = 0;
    str = convertCharsToStrings(transition.LabelString);
    if (contains(str,'+') || contains(str,'-') ||...
       contains(str,'*') || contains(str,'/')) && isInitialTransition(transition)==false
        if contains(str,'+')
            containsPlus = true;
            plusLocations = strfind(str, '+');
        end
        if contains(str,'-')
            containsMinus = true;
            minusLocations = strfind(str, '-');
        end
        if contains(str,'*')
            containsMult = true;
            multLocations = strfind(str, '*');
        end
        if contains(str,'/')
            containsDiv = true;
            divLocations = strfind(str, '/');
        end
        locations = [];
        if containsPlus
            locations = [locations  plusLocations];
        end
        if containsMinus
            locations = [locations  minusLocations];
        end
        if containsMult
            locations = [locations  multLocations];
        end
        if containsDiv
            locations = [locations  divLocations];
        end
        whichToChange = randi([1 length(locations)]);
        if strcmp(transition.LabelString(locations(whichToChange)),'+')
            if rand <= 0.5
                transition.LabelString(locations(whichToChange)) = '-';
                done = true;
            else
               if rand <=0.5 && strcmp(transition.LabelString(locations(whichToChange)+1), '0')==false
                   transition.LabelString(locations(whichToChange)) = '/';
                   done = true;
               else
                   transition.LabelString(locations(whichToChange)) = '*';
                   done = true;
               end
            end
            
        elseif strcmp(transition.LabelString(locations(whichToChange)),'-')
            if rand <= 0.5
                transition.LabelString(locations(whichToChange)) = '+';
                done = true;
            else
               if rand <=0.5 &&  strcmp(transition.LabelString(locations(whichToChange)+1), '0')==false
                   transition.LabelString(locations(whichToChange)) = '/';
                   done = true;
               else
                   transition.LabelString(locations(whichToChange)) = '*';
                   done = true;
               end
            end
            
        elseif strcmp(transition.LabelString(locations(whichToChange)),'*')
            if rand <= 0.5 && strcmp(transition.LabelString(locations(whichToChange)+1), '0')==false
                transition.LabelString(locations(whichToChange)) = '/';
                done = true;
            else
               if rand <=0.5
                   transition.LabelString(locations(whichToChange)) = '+';
                   done = true;
               else
                   transition.LabelString(locations(whichToChange)) = '-';
                   done = true;
               end
            end
            
        elseif strcmp(transition.LabelString(locations(whichToChange)),'/')
            if rand <= 0.5
                transition.LabelString(locations(whichToChange)) = '*';
                done = true;
            else
               if rand <=0.5
                   transition.LabelString(locations(whichToChange)) = '-';
                   done = true;
               else
                   transition.LabelString(locations(whichToChange)) = '+';
                   done = true;
               end
            end
            
        end
    end
end