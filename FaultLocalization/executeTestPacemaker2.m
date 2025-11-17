function [Trans States Verdict] = executeTestPacemaker2(model, testCase)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    
    modelname = strrep(model,'.slx','');
    if testCase ==1
        Verdict = 'Fail';
        signalBuilderBlock = 'Signal Builder';
        %set_param([modelname '/' signalBuilderBlock], 'GroupName', 'Group 1');
        signalbuilder([modelname '/' signalBuilderBlock],'activegroup', 1);


    else
        if testCase == 2
           signalBuilderBlock = 'Signal Builder';
           %set_param([modelname '/' signalBuilderBlock], 'GroupName', 'Group 2');
           signalbuilder([modelname '/' signalBuilderBlock],'activegroup', 2);

           
        else
            SBGroup =2;
            signalBuilderBlock = 'Inputs';
            %set_param([modelname '/' signalBuilderBlock], 'GroupName', ['Group ' num2str(testCase-2)]); 
            signalbuilder([modelname '/' signalBuilderBlock],'activegroup', testCase-2);
        end
        Verdict = 'Pass';
    end
    sim(model);
    sim('Model2_Scenario1_Correct_2020a.slx');
    verdict = abs(correct_out1.data-out1.data) + abs(correct_out2.data-out2.data) + ...
         abs(correct_out3.data-out3.data) + abs(correct_out4.data-out4.data) + ...
         abs(correct_out5.data-out5.data) + abs(correct_out6.data-out6.data) + ...
         abs(correct_out7.data-out7.data) + abs(correct_out8.data-out8.data) +...
         abs(correct_out9.data-out9.data) + abs(correct_out10.data-out10.data) +...
         abs(correct_out11.data-out11.data) + abs(correct_out12.data-out12.data) +...
         abs(correct_out13.data-out13.data) + abs(correct_out14.data-out14.data) +...
         abs(correct_out15.data-out15.data);% + abs(correct_out16.data-out16.data);


    timeVerdictActive = sum(verdict>0);
    criticalityVerdict = max(verdict);
    timeFirstFailureExhibited = 0;
    for i=1:length(verdict)
       if verdict(i)>0
           timeFirstFailureExhibited=i;
           break;
       end
    end
    if criticalityVerdict==0
        Verdict = 'Pass';
    else
        Verdict = 'Fail';
    end
    
end

