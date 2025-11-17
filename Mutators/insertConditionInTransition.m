function done = insertConditionInTransition(transition,rt)
    %TODO: Add it at a random point in the transition?
    done = false;
    inputs = getInputs(rt); %up to now, limited only to inputs
    
    if ~isempty(inputs) && ~isInitialTransition(transition)
        relationalOps = {'<=','>=','<','==','~='}; 
        conditionalOps = {'&&','||'}; 
        %selectedTrans = randi(length(transitions));
        selectedRelOp = relationalOps{randi(5)};
        selectedCondOp = conditionalOps{randi(2)};
        selectedInput = inputs(randi(length(inputs))).Name;
        if rand < 0.8
            numToBeSelected = randi([0,1]); %priority given to 1 or 0            
        else
            numToBeSelected = randi([-20,20]); %TODO --> POLISH THIS
        end
        newStr = [selectedCondOp ' ' selectedInput ' ' selectedRelOp ' ' num2str(numToBeSelected)];
        chr = transition.LabelString;
        lastLocation = strfind(chr, ']');
        chr = [chr(1:lastLocation-1) newStr ']'];
        transition.LabelString = chr;
    end
       
end