function done = numericalChangeInTransition(transition)
    %TODO: Some times it may end a number to be --. Prune this.
    %TODO: This implementation is much clearer than the numerical changes
    %done in the states. Think how to integrate this in the states?
    done = false;
    str = convertCharsToStrings(transition.LabelString); 
    numsOfStr = regexp(str,'\d*','Match');
    if ~isempty(numsOfStr)
        whereNumsAre = [];
        for ii=1:length(numsOfStr)
            plusLocations = strfind(str,numsOfStr{ii});
            for jj=1:length(plusLocations)
                %isNum = isNumber(str,plusLocations(jj));
                %aitor = 0;
                if isNumber(str,plusLocations(jj))
                   whereNumsAre = [whereNumsAre plusLocations(jj)];
                end
            end

        end
        whereNumsAre = unique(whereNumsAre);
        selectedNum = whereNumsAre(randi([1 length(whereNumsAre)]));
        chr = convertStringsToChars(str);
        chrNew = chr(1:selectedNum-1);
        ii=selectedNum;
        while isstrprop(chr(ii),'digit')
           ii=ii+1; 
        end

        %TODO: Polish this. Especially, maximum number is -15 + 15. How to
        %obtain another number?
        if rand <=0.5
            if rand <0.5
                selectedNum = 1;
            else
                selectedNum = 0;
            end
        else
            selectedNum = randi([-15 15]);
        end

        chrNew = [chrNew num2str(selectedNum)];
        chrNew = [chrNew chr(ii:length(chr))];
        %
        str2 = convertCharsToStrings(chrNew);
        if strcmp(str,str2)==false
            done = true;
            transition.LabelString = str2;
        end
    end
        
end

