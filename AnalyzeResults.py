import pandas as pd
import os, sys
from os import chdir
from os.path import dirname,realpath
chdir(dirname(realpath(__file__)))
sys.path.append('..')
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter

filter_models= lambda f: f.endswith('.slx')
############################## INITIAL PARAMETERS ################################

#folder= "..\\" # Results folder
#model="elevator_2" # Model

folder = r"C:\Users\airshad\Documents\1. Project work\Stateflowrepair_Using_LLM\\Results\\"
model  = "fridge_1"
seeds=[1,2,3,4,5] # Seeds
seeds=[1] # Seeds
execTime=3600 # Execution time in seconds

##################################################################################

# ------------------- BASELINE (commented out) -------------------
# patches_baseline=list()
# for seed in seeds:
#     path_baseline=folder+"Baseline\\"+model+"\\Baseline_seed_"+str(seed)
#     models_baseline=list(filter(filter_models,os.listdir(path_baseline)))
#     totalNumberOfModels_baseline=len(models_baseline)-2
#     deltaModels_baseline=execTime/totalNumberOfModels_baseline
#
#     toRead_baseline=open(path_baseline+"\\PlausiblePatches.txt","r")
#     plausiblePatches_baseline=toRead_baseline.read().split("\n")
#
#     foundIndexes_baseline=list()
#     for i in range(0, len(plausiblePatches_baseline)-1):
#         splitted=plausiblePatches_baseline[i].split("_")
#         to_index_baseline=splitted[-1].split("\t")[0].split("'")[0].split(".")[0]
#         if to_index_baseline != 'NaN':
#             foundIndexes_baseline.append(to_index_baseline)
#
#     numOfPlausiblePatches_baseline=list()
#     j=0
#     for i in range(0,execTime):
#         if j<len(foundIndexes_baseline) and i==round(float(foundIndexes_baseline[j])*deltaModels_baseline):
#             j=j+1
#         numOfPlausiblePatches_baseline.append(j)
#     patches_baseline.append(numOfPlausiblePatches_baseline)
#
# mean_values_baseline=np.mean(patches_baseline, axis=0)
# std_values_baseline=np.std(patches_baseline, axis=0)
# upperBound_baseline=mean_values_baseline+std_values_baseline
# lowerBound_baseline=mean_values_baseline-std_values_baseline
# lowerBound_baseline=[0 if x<0 else x for x in lowerBound_baseline]
#
# plt.plot(mean_values_baseline, label="Baseline")
# plt.fill_between(range(0,execTime), lowerBound_baseline,upperBound_baseline, alpha=0.3)


# ------------------- APPROACH (commented out) -------------------
# patches_ea=list()
# for seed in seeds:
#     path_ea=folder+"Approach\\"+model+"\\Approach_seed_"+str(seed)
#     models_ea=list(filter(filter_models,os.listdir(path_ea)))
#     totalNumberOfModels_ea=len(models_ea)
#     deltaModels_ea=execTime/totalNumberOfModels_ea
#
#     toRead_ea=open(path_ea+"\\PlausiblePatches.txt","r")
#     plausiblePatches_ea=toRead_ea.read().split("\n")
#
#     foundIndexes_ea=list()
#     for i in range(0, len(plausiblePatches_ea)-1):
#         splitted=plausiblePatches_ea[i].split("_")
#         to_index_ea=splitted[-1].split("\t")[0].split("'")[0].split(".")[0]
#         if to_index_ea not in ['NaN','NOT VALIDATED!','NOT CHECKED','']:
#             foundIndexes_ea.append(to_index_ea)
#
#     numOfPlausiblePatches_ea=list()
#     j=0
#     for i in range(0,execTime):
#         if j<len(foundIndexes_ea) and i==round(float(foundIndexes_ea[j])*deltaModels_ea):
#             j=j+1
#         numOfPlausiblePatches_ea.append(j)
#     patches_ea.append(numOfPlausiblePatches_ea)
#
# mean_values_ea=np.mean(patches_ea, axis=0)
# std_values_ea=np.std(patches_ea, axis=0)
# upperBound_ea=mean_values_ea+std_values_ea
# lowerBound_ea=mean_values_ea-std_values_ea
# lowerBound_ea=[0 if x<0 else x for x in lowerBound_ea]
#
# plt.plot(mean_values_ea, label="FlowRepair")
# plt.fill_between(range(0,execTime), lowerBound_ea,upperBound_ea, alpha=0.3)


# ------------------- LLM (active) -------------------
patches_llm=list()
for seed in seeds:
    path_llm=folder+"LLM\\"+model+"\\LLM_seed_"+str(seed)
    #path_llm = folder + "Approach\\" + model + "\\Approach_seed_" + str(seed)
    models_llm=list(filter(filter_models,os.listdir(path_llm)))
    totalNumberOfModels_llm=len(models_llm)
    deltaModels_llm=execTime/totalNumberOfModels_llm

    toRead_llm=open(path_llm+"\\PlausiblePatches.txt","r")
    plausiblePatches_llm=toRead_llm.read().split("\n")

    foundIndexes_llm=list()
    for i in range(0, len(plausiblePatches_llm)-1):
        splitted=plausiblePatches_llm[i].split("_")
        to_index_llm=splitted[-1].split("\t")[0].split("'")[0].split(".")[0]
        if to_index_llm not in ['NaN','NOT VALIDATED!','NOT CHECKED','']:
            foundIndexes_llm.append(to_index_llm)

    numOfPlausiblePatches_llm=list()
    j=0
    for i in range(0,execTime):
        if j<len(foundIndexes_llm) and i==round(float(foundIndexes_llm[j])*deltaModels_llm):
            j=j+1
        numOfPlausiblePatches_llm.append(j)
    patches_llm.append(numOfPlausiblePatches_llm)

mean_values_llm=np.mean(patches_llm, axis=0)
std_values_llm=np.std(patches_llm, axis=0)
upperBound_llm=mean_values_llm+std_values_llm
lowerBound_llm=mean_values_llm-std_values_llm
lowerBound_llm=[0 if x<0 else x for x in lowerBound_llm]

plt.plot(mean_values_llm, label="LLM Repair")
plt.fill_between(range(0,execTime), lowerBound_llm,upperBound_llm, alpha=0.3)

plt.xlabel("Execution time (s)",weight='bold')
plt.ylabel("# of plausible patches",weight='bold')
plt.title(model,weight='bold')
plt.gca().yaxis.set_major_formatter(FormatStrFormatter('%.2f'))
plt.ylim((-0.1,1))
plt.legend(loc='upper left')

approach_name = "LLM"   #for saving

fig_folder = os.path.join("Figures", approach_name)
os.makedirs(fig_folder, exist_ok=True)
plt.savefig(os.path.join(fig_folder, model + ".pdf"), format="pdf", bbox_inches="tight")
plt.show()

#plt.savefig("Figures/"+model+".pdf", format="pdf", bbox_inches="tight")
#plt.show()
