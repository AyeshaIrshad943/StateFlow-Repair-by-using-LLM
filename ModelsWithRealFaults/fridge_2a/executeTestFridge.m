function [verdict,timeVerdictActive,criticalityVerdict,timeFirstFailureExhibited] = executeTestFridge(model)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    
    modelname = strcat(model,".slx");
    open(modelname);
    signalBuilderBlock = 'Signal Builder';
    %set_param([modelname '/' signalBuilderBlock], 'GroupName', 'Group 1');
    %signalbuilder([modelname '/' signalBuilderBlock],'activegroup', 1);

    sim(modelname);
    out1 = ans.out1.data;
    out2 = ans.out2.data;
    out3 = ans.out3.data;
    save_system(modelname);
    close_system(modelname);
    
    
    open('Fridge_Correct.slx');
    
    
    %signalbuilder(['Fridge_Correct' '/' signalBuilderBlock],'activegroup', 1);

    
    sim('Fridge_Correct.slx');
    correct_out1 = ans.correct_out1.data;
    correct_out2 = ans.correct_out2.data;
    correct_out3 = ans.correct_out3.data;
    save_system('Fridge_Correct.slx');
    close_system('Fridge_Correct.slx');
    verdict = abs(out1-correct_out1)+abs(out2-correct_out2)+abs(out3-correct_out3);%abs(out.correct_out1.data-out.out1.data) + abs(out.correct_out2.data-out.out2.data) + ...
         %abs(out.correct_out3.data-out.out3.data);
     

    timeVerdictActive = sum(verdict>0);
    criticalityVerdict = max(verdict);
    timeFirstFailureExhibited = 0;
    for i=1:length(verdict)
       if verdict(i)>0
           timeFirstFailureExhibited=i;
           break;
       end
    end
%     if criticalityVerdict==0
%         Verdict = 'Pass';
%     else
%         Verdict = 'Fail';
%     end
    
end

