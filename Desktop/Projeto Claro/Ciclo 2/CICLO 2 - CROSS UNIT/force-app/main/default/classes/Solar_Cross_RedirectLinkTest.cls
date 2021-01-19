/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Classe de teste da Solar_Cross_RedirectLinkController
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-19      Jean Sganzerla          class created 
**************************************************************************************************************/
@isTest
public class Solar_Cross_RedirectLinkTest {
    private static final Id LINKS_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('Solar_Cross_Links').getRecordTypeId();

    @TestSetup
    static void makeData(){
        List<Parameters__c> lLinkLst = new List<Parameters__c>{new Parameters__c(RecordTypeId = LINKS_RECTYPE, Name = 'Portal Anatel', Active__c = true, Type__c = 'Móvel;Residencial', Journey__c = 'General;Backoffice;Financial', Link__c = 'https://www.anatel.gov.br', Icons__c = 'resource_territory')};
        insert lLinkLst;
    }

    static testMethod void getOrdemsfromData(){
        List<Parameters__c> lLinkLst = [SELECT Id, Icons__c FROM Parameters__c];
                
        Test.startTest();
        Solar_Cross_RedirectLinkController.picklistValues();
        Solar_Cross_RedirectLinkController.getRecordIcon(lLinkLst[0].Id);
        Solar_Cross_RedirectLinkController.setRecordIcon(lLinkLst[0].Id, lLinkLst[0].Icons__c);
        Test.stopTest();
    }   
}