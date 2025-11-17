function [verdict,timeVerdictActive,criticalityVerdict,timeFirstFailureExhibited] = executeTestDoor(model)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    testCase = 1;
    modelname = strcat(model,".slx");

    open(modelname);
    signalBuilderBlock = 'Signal Builder';
    %set_param([modelname '/' signalBuilderBlock], 'GroupName', 'Group 1');
    %signalbuilder([modelname '/' signalBuilderBlock],'activegroup', testCase);

    sim(modelname);
    out1 = out1.data;
%     out2 = ans.out2.data;
%     out3 = ans.out3.data;
    save_system(modelname);
    close_system(modelname);
    
    
    open('Door_Model_Correct.slx');
    
    signalbuilder(['Door_Model_Correct' '/' signalBuilderBlock],'activegroup', testCase);

    
    sim('Door_Model_Correct.slx');
    correct_out1 = correct_out1.data;
    
    save_system('Door_Model_Correct.slx');
    close_system('Door_Model_Correct.slx');
    verdict = abs(out1-correct_out1);%+abs(out2-correct_out2)+abs(out3-correct_out3);%abs(out.correct_out1.data-out.out1.data) + abs(out.correct_out2.data-out.out2.data) + ...
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

