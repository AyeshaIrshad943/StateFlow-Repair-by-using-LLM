function [Trans States Verdict] = executeTestPacemaker(model, testCase)
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
    
end

