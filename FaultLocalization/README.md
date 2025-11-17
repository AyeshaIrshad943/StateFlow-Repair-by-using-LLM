# Fault localization for stateflow models

In this folder there are the necessary scripts to measure the suspiciousness of transitions and states in a stateflow model. To do this, we need to execute two scripts. 

The first script refers to InstrumentModel.m. This scripts takes a simulink model and instruments the stateflow in order to get all the data. Open the script and add the model name in the variable "modelToBeInstrumented".

Once done this, the second script measures the SBFL data. Currently, we only support Tarantula, although it can be easily extended to any other state-of-the-art SBFL metric. The following steps are necessary to measure SBFL data:

1.- Open the script and add the instrumented model name on "InstrumentedModel"

2.- You need to implement the test executor function. , which should have as an input the model and the test case number, and as an output, the transitions output, the states outputs and the Verdict of the test case. The implemented function should be added through a pointer to "executeTest".

3.- You need to specify the number of test cases in the variable NtestCases. 

4.- Run the scripts and the suspiciousness scores will be in arrays "suspiciousness_states" and "suspiciousness_transitions". 