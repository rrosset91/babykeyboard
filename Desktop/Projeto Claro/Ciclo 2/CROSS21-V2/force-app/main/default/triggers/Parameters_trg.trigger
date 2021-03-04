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
trigger Parameters_trg on Parameters__c (before insert, before update, before delete) {

    //Desabilita a trigger caso haja um registro com o nome do objeto marcado com Active__c false no custom setting Solar_Cross_TriggerConfiguration__c
    if (!Solar_Cross_ParametersHandler.isActive('Parameters__c')) return;

    if(Trigger.isBefore){
	    if(Trigger.isInsert){
            System.debug('Parameters_trg ==> isBefore.isInsert');

            Solar_Cross_ParametersHandler.validateDuplicatedAttendenceTree(null,Trigger.new);
            if(Solar_Cross_ParametersHandler.firstRun){
                Solar_Cross_ParametersHandler.validateInsertOfferMatriz(null,Trigger.new);
                Solar_Cross_ParametersHandler.firstRun=false;
            }
        }
        if(Trigger.isUpdate){
            System.debug('Parameters_trg ==> isBefore.isUpdate');

            Solar_Cross_ParametersHandler.validateDuplicatedAttendenceTree(Trigger.oldMap,Trigger.new);
            if(Solar_Cross_ParametersHandler.firstRun){
                Solar_Cross_ParametersHandler.validateEditOfferMatriz(Trigger.oldMap,Trigger.new);
                Solar_Cross_ParametersHandler.firstRun=false;
            }
        }
        if(Trigger.isDelete){
            System.debug('Parameters_trg ==> isBefore.isDelete');
            if(Solar_Cross_ParametersHandler.firstRun){
                Solar_Cross_ParametersHandler.validateDeleteOfferMatriz(Trigger.old);
                Solar_Cross_ParametersHandler.firstRun=false;
            }
        }
    }
}