/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Classe de teste da CEC_ME_RedirecLinkClaroController
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-19      Jean Sganzerla          class created 
**************************************************************************************************************/
@isTest
public class CEC_ME_RedirecLinkClaroTest {
    private static final Id CASE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();

    @TestSetup
    static void makeData(){
        List<Case> lCaseLst = new List<Case>{new Case(Subject = 'Default', RecordTypeId = CASE_RECTYPE)};
        insert lCaseLst;     
    }

    static testMethod void getOrdemsfromData(){
        List<Case> lCaseLst = [SELECT Id FROM Case];
                
        Test.startTest();
        CEC_ME_RedirecLinkClaroController.picklistValues();
        CEC_ME_RedirecLinkClaroController.getParameterRecords('Todos',lCaseLst[0].Id);
        CEC_ME_RedirecLinkClaroController.getParameterRecords('Financial', null);
        Test.stopTest();
    }   
}