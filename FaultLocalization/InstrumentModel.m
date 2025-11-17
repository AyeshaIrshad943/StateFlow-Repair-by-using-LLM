
clear;
clc;
close all;
addpath functions;

modelToBeInstrumented = 'Door_Model_Incorrect';
copyfile([modelToBeInstrumented '.slx'],[modelToBeInstrumented '_instrumented.slx']);

instrumentedModel = [modelToBeInstrumented '_instrumented.slx'];
close
open(instrumentedModel);
rt = sfroot;
states = getStates(rt);%find(rt,'-isa','Stateflow.State'); % get all states from the stateflow model
transitions = getTransitions(rt);%find(rt,'-isa','Stateflow.Transition');
data = find(rt,'-isa','Stateflow.Data');
inputs = getInputs(rt);
outputs = getOutputs(rt);


for i=1:size(transitions,1)
    tran = transitions(i);
    if contains(tran.LabelString,'}')
        tran.LabelString = strrep(tran.LabelString,'}',['trans = ' num2str(i) ';}']);
    else
        tran.LabelString = [tran.LabelString '{trans = ' num2str(i) ';}'];
    end
end

for i=1:size(states,1)
   state = states(i);
   %try
        state.LabelString = [state.LabelString ' state = ' num2str(i) ';'];
   %catch
       
   %end
end

%Add two outputs to the stateflow
ch = find(rt,'-isa','Stateflow.Chart');
x = Stateflow.Data(ch);
x.Name = 'trans';
x.Scope = 'Output';

y = Stateflow.Data(ch);
y.Name = 'state';
y.Scope = 'Output';



%Add to workspace blocks
chartName = ch.Name;


blockName1 = 'Trans';
blockName2 = 'States';
modelName = [modelToBeInstrumented '_instrumented'];

add_block('simulink/Sinks/To Workspace', [modelName '/' blockName1]);
add_block('simulink/Sinks/To Workspace', [modelName '/' blockName2]);

add_line(modelName, [chartName, '/' num2str(size(outputs,1)+1)], 'Trans/1', 'autorouting', 'on');
add_line(modelName, [chartName, '/' num2str(size(outputs,1)+2)], 'States/1', 'autorouting', 'on');

set_param([modelName '/Trans'], 'VariableName', 'Trans');
set_param([modelName '/States'], 'VariableName', 'States');

 
save_system([modelToBeInstrumented '_instrumented.slx']);
close_system([modelToBeInstrumented '_instrumented.slx']);


