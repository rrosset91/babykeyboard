/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Parameters__c Trigger
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-10-22      Jean Sganzerla          class created 
**************************************************************************************************************/
trigger Parameters_trg on Parameters__c (before insert, before update) {
    
    //Desabilita a trigger caso haja um registro com o nome do objeto marcado com Active__c false no custom setting Solar_Cross_TriggerConfiguration__c
    if (!Solar_Cross_ParametersHandler.isActive('Parameters__c')) return;

    if(Trigger.isBefore){
	    if(Trigger.isInsert){
            Solar_Cross_ParametersHandler.validateDuplicatedAttendenceTree(null,Trigger.new);
        }
        if(Trigger.isUpdate){
            Solar_Cross_ParametersHandler.validateDuplicatedAttendenceTree(Trigger.oldMap,Trigger.new);
        }
    }
}