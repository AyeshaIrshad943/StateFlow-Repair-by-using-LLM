clear;
clc;
addpath("LLMPatch");
seeds=[1,2,3,4,5];
loadEnv(); % Load API key

if isempty(getenv('OPENAI_API_KEY'))
    error('OPENAI_API_KEY not found. Please check your .env file.');
else
    disp("API key loaded successfully.");
end

 % executeTests={@executeTestDoor,@executeTestDoor,@executeTestFridge,@executeTestFridge,@executeTestFridge,@executeTestFridge,@executeTestFridge};
 % faultyModels=["ModelsWithRealFaults/door_1/Door_model_Incorrect","ModelsWithRealFaults/door_2/Door_model_Incorrect",...
 %     "ModelsWithRealFaults/fridge_1/Fridge_Faulty","ModelsWithRealFaults/fridge_2/Fridge_Faulty","ModelsWithRealFaults/fridge_2a/Fridge_Faulty",...
 %     "ModelsWithRealFaults/fridge_2b/Fridge_Faulty","ModelsWithRealFaults/fridge_3/Fridge_Faulty"];
 % nonFaultyModels=["ModelsWithRealFaults/door_1/Door_model_Correct","ModelsWithRealFaults/door_2/Door_model_Correct",...
 %     "ModelsWithRealFaults/fridge_1/Fridge_Correct","ModelsWithRealFaults/fridge_2/Fridge_Correct","ModelsWithRealFaults/fridge_2a/Fridge_Correct",...
 %     "ModelsWithRealFaults/fridge_2b/Fridge_Correct","ModelsWithRealFaults/fridge_3/Fridge_Correct"];

% executeTests={ @executeTestPacemaker,@executeTestPacemaker2};
% faultyModels=["ModelsWithRealFaults/pacemaker_fault1/Model1_Scenario2_Faulty_2020a","ModelsWithRealFaults/pacemaker_fault2/Model2_Scenario1_Faulty_2020a"];
% nonFaultyModels=["ModelsWithRealFaults/pacemaker_fault1/Model1_Scenario2_NonFaulty_2020a","ModelsWithRealFaults/pacemaker_fault2/Model2_Scenario1_Correct_2020a"];


executeTests={@executeTestPacemaker,@executeTestPacemaker2, @executeTestElevator,@executeTestElevator,@executeTestElevator,@executeTestElevator,@executeTestElevator,...
    @executeTestElevator,@executeTestElevator,@executeTestElevator,@executeTestElevator,@executeTestElevator,@executeTestElevator,...
    @executeTestElevator,@executeTestStateMachine,@executeTestStateMachine,@executeTestStateMachine,@executeTestStateMachine,@executeTestStateMachine};


faultyModels=["ModelsWithRealFaults/pacemaker_fault1/Model1_Scenario2_Faulty_2020a","ModelsWithRealFaults/pacemaker_fault2/Model2_Scenario1_Faulty_2020a",...
    "ModelsWithRealFaults/elevator_2/Elevator_Incorrect_abiadura_Ur1","ModelsWithRealFaults/elevator_3/Eelvator_Incorrect_abiadura_Ur2",...
    "ModelsWithRealFaults/elevator_4/Elevator_Incorrect_abrir_puerta_Xanet","ModelsWithRealFaults/elevator_5/Elevator_Incorrect_abrir_puerta_Xanet1",...
    "ModelsWithRealFaults/elevator_6/Elevator_Incorrect_abrir_puerta_Xanet2","ModelsWithRealFaults/elevator_7/Elevator_Incorrect_after_Iraitz",...
    "ModelsWithRealFaults/elevator_8/Elevator_Incorrect_after_Jorge","ModelsWithRealFaults/elevator_9/elevator_Incorrect_after_Jorge1",...
    "ModelsWithRealFaults/elevator_10/Elevator_Incorrect_after_Jorge2","ModelsWithRealFaults/elevator_12/Elevator_Incorrect_pisos_Nicolas",...
    "ModelsWithRealFaults/elevator_13/Elevator_Incorrect_pisos_Nicolas1","ModelsWithRealFaults/elevator_14/Elevator_Incorrect_pisos_Nicolas2",...
    "ModelsWithRealFaults/state_machine1/StateMachine_Incorrect_apaolaza","ModelsWithRealFaults/state_machine2/StateMachine_Incorrect_herrero",...
    "ModelsWithRealFaults/state_machine3/StateMachine_Incorrect_lide","ModelsWithRealFaults/state_machine4/StateMachine_Incorrect_Nicolas",...
    "ModelsWithRealFaults/state_machine5/StateMachine_Incorrect_paola"];


nonFaultyModels=["ModelsWithRealFaults/pacemaker_fault1/Model1_Scenario2_NonFaulty_2020a","ModelsWithRealFaults/pacemaker_fault2/Model2_Scenario1_Correct_2020a",...
      "ModelsWithRealFaults/elevator_2/Elevator_Correct","ModelsWithRealFaults/elevator_3/Elevator_Correct",...
    "ModelsWithRealFaults/elevator_4/Elevator_Correct","ModelsWithRealFaults/elevator_5/Elevator_Correct",...
    "ModelsWithRealFaults/elevator_6/Elevator_Correct","ModelsWithRealFaults/elevator_7/Elevator_Correct",...
    "ModelsWithRealFaults/elevator_8/Elevator_Correct","ModelsWithRealFaults/elevator_9/Elevator_Correct",...
    "ModelsWithRealFaults/elevator_10/Elevator_Correct","ModelsWithRealFaults/elevator_12/Elevator_Correct",...
    "ModelsWithRealFaults/elevator_13/Elevator_Correct","ModelsWithRealFaults/elevator_14/Elevator_Correct",...
    "ModelsWithRealFaults/state_machine1/StateMachine_Correct","ModelsWithRealFaults/state_machine2/StateMachine_Correct",...
    "ModelsWithRealFaults/state_machine3/StateMachine_Correct","ModelsWithRealFaults/state_machine4/StateMachine_Correct",...
    "ModelsWithRealFaults/state_machine5/StateMachine_Correct"];



for i=1:length(faultyModels)
     for j=1:length(seeds)

         folders_faulty=split(faultyModels(i), "/");
         folders_Nonfaulty=split(nonFaultyModels(i), "/");

         % Add directory to path
         addpath(strcat(folders_faulty(1), "/",folders_faulty(2)));

         % Make new directory
         newFolder=strcat("Results/LLM/",folders_faulty(2),"/","LLM_seed_",num2str(j));
         mkdir(newFolder);

         % Copy Test cases
         newFaultyModel=strcat(newFolder,"/",folders_faulty(3));
         copyfile(strcat(faultyModels(i), ".slx"), strcat(newFaultyModel,".slx"));

         newNonFaultyModel=strcat(newFolder,"/",folders_Nonfaulty(3));
         copyfile(strcat(nonFaultyModels(i), ".slx"), strcat(newNonFaultyModel,".slx"))
         
         %Execute LLM Based global local algorithm
         LLMBasedGlobalLocalAlgorithm(seeds(j),newFaultyModel, newNonFaultyModel, executeTests{i},newFolder)
         
         %Remove path
         rmpath(strcat(folders_faulty(1), "/",folders_faulty(2)));
     end
end

