function [Trans States Verdict] = executeTestStateMachine(model,correct_model, testCase)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    
    modelname = strrep(model,'.slx','');
    correct_model_name=strrep(correct_model,'.slx','');
    
    if testCase ==1
        Verdict = 'Fail';
        signalBuilderBlock = 'Signal Builder';
        %set_param([modelname '/' signalBuilderBlock], 'GroupName', 'Group 1');
        signalbuilder([modelname '/' signalBuilderBlock],'activegroup', 1);
        signalbuilder([correct_model_name '/' signalBuilderBlock],'activegroup', 1);

    else
        if testCase == 2
           signalBuilderBlock = 'Signal Builder';
           %set_param([modelname '/' signalBuilderBlock], 'GroupName', 'Group 2');
           signalbuilder([modelname '/' signalBuilderBlock],'activegroup', 2);
           signalbuilder([correct_model_name '/' signalBuilderBlock],'activegroup', 2);
           Verdict = 'Pass';
           
        else
            signalBuilderBlock = 'Signal Builder';
            %set_param([modelname '/' signalBuilderBlock], 'GroupName', ['Group ' num2str(testCase-2)]); 
            signalbuilder([modelname '/' signalBuilderBlock],'activegroup', 3);
            signalbuilder([correct_model_name '/' signalBuilderBlock],'activegroup', 3);
            Verdict = 'Pass';
        end
        
    end
    incorrect_out=sim(model);
    Trans=incorrect_out.Trans;
    States=incorrect_out.States;
    original_out=sim(correct_model);
    verdict = abs(incorrect_out.correct_out1.data-original_out.out1.data) + abs(incorrect_out.correct_out2.data-original_out.out2.data);


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

