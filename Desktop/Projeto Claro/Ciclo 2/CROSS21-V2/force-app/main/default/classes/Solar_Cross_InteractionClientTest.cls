/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Classe de teste da Solar_Cross_InteractionClientController
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-12-09      Jean Sganzerla          class created 
**************************************************************************************************************/
@isTest
public class Solar_Cross_InteractionClientTest {
    private static final Id ACC_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    private static final Id CONSUMER_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
    private static final Id CASE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
    private static final Id TOPIC_RECTYPE = SObjectType.vlocity_cmt__CustomerInteractionTopic__c.getRecordTypeInfosByDeveloperName().get('InteractionTentative').getRecordTypeId();

    @TestSetup
    static void makeData(){
        List<Account> lAccountLst = new List<Account>{new Account(RecordTypeId = ACC_RECTYPE, Name = 'Contract', ShippingCity = 'SAO PAULO', ContractReferenceNumber__c = '654321', BusinessUnit__c = 'Net', CityCode__c = '11'), new Account (RecordTypeId = CONSUMER_RECTYPE, Name = 'Consumer', CityCode__c = '11')};
        insert lAccountLst;       

        Case lCase = new Case(AccountId = lAccountLst[1].Id, Subject = 'Default', RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lAccountLst[0].Id, LegacyProtocol__c = '123');
        insert lCase;

        vlocity_cmt__CustomerInteraction__c lInteraction = new vlocity_cmt__CustomerInteraction__c(ProtocolNumber__c = lCase.LegacyProtocol__c);
        insert lInteraction;

        vlocity_cmt__CustomerInteractionTopic__c lTopic = new vlocity_cmt__CustomerInteractionTopic__c(vlocity_cmt__CustomerInteractionId__c = lInteraction.Id, vlocity_cmt__CaseId__c = lCase.Id, RecordTypeId = TOPIC_RECTYPE, SolarCross_Status__c = 'Sucesso', SolarCross_Channel__c = 'Email', SolarCross_Author__c = 'Empresa', Comments__c = 'Teste', Solar_Cross_Type__c = 'Tentativa de Contato com Cliente');
        insert lTopic;            
    }

    static testMethod void getAlerts(){
        Case lCase = [SELECT Id FROM Case LIMIT 1];
        test.startTest();
            Solar_Cross_InteractionClientController.getClientHistory(lCase.Id);
        test.stopTest();
    }

    static testMethod void UpdateInteraction(){
        vlocity_cmt__CustomerInteractionTopic__c lTopic = [SELECT Id FROM vlocity_cmt__CustomerInteractionTopic__c LIMIT 1];
        test.startTest();
        Solar_Cross_InteractionClientController.Interaction objInteraction = new Solar_Cross_InteractionClientController.Interaction();
        objInteraction.lId   = lTopic.id;
        objInteraction.lStatus = 'Sucesso';
        objInteraction.lChannel = 'Call Center';
        objInteraction.lAuthor = 'Empresa';
        objInteraction.lComments = 'Teste';
        objInteraction.lCommentsManual = 'Teste';
        objInteraction.lType = 'Telefone';
        objInteraction.lFooterIcon = 'Teste';
        objInteraction.lFooterVariant = 'Teste';
        objInteraction.lClaroLogin = '12345';
        objInteraction.lCreatedDate = DateTime.newInstance(2021,01,12); 
        Solar_Cross_InteractionClientController.updateInteraction(JSON.serialize(objInteraction));
        test.stopTest();
    }
    
}