function [verdict,timeVerdictActive,criticalityVerdict,timeFirstFailureExhibited] = executeTestElevator(model)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    testCase=1;
    correct_model='Elevator_Correct.slx';
    correct_model_name=strrep(correct_model,'.slx','');

    modelname = strcat(model,".slx");
    open(modelname);
    open(correct_model);

    signalBuilderBlock= 'Signal Builder1';
    signalbuilder([model '/' signalBuilderBlock],'activegroup', testCase);
    signalbuilder([correct_model_name '/' signalBuilderBlock],'activegroup', testCase);
    

    incorrect_out=sim(modelname);
    correct_out=sim(correct_model);
    save_system(correct_model);
    close_system(correct_model);
    
    verdict = abs(incorrect_out.correct_out1.data-correct_out.out1.data) + abs(incorrect_out.correct_out2.data-correct_out.out2.data) + ...
         abs(incorrect_out.correct_out3.data-correct_out.out3.data);
    
    timeVerdictActive = sum(verdict>0);
    criticalityVerdict = max(verdict);
    timeFirstFailureExhibited = 0;
    for i=1:length(verdict)
       if verdict(i)>0
           timeFirstFailureExhibited=i;
           break;
       end
    end
    
end

