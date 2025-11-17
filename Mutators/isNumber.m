function isNum = isNumber(str,charNum)
    isNum = false;
    if charNum==1
        isNum = true;
    elseif charNum<1
        isNum = false;
    else
        chr = convertStringsToChars(str);
        if isletter(chr(charNum-1))||strcmp(chr(charNum-1),'_')
            isNum=false;
        else
            isNum=true;
        end
    end
end

