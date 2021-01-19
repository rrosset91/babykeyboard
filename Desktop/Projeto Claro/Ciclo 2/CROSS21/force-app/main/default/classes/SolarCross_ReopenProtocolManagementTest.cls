/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:     Test class for SolarCross_ReopenProtocolManagement
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2021-01-05      Jean Sganzerla          class created 
**************************************************************************************************************/
@isTest
public class SolarCross_ReopenProtocolManagementTest {

    private static final Id CASE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();    
    private static final Id REOPEN_PROTOCOL_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('SolarCross_ReopenCasesManagement').getRecordTypeId();
    private static final Id ACC_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

    @TestSetup
    static void makeData(){
        Parameters__c lFourFields = new Parameters__c();
        lFourFields.Active__c = true;
        lFourFields.RecordTypeId = REOPEN_PROTOCOL_RECTYPE;
        lFourFields.Journey__c = 'Financial';
        lFourFields.EntryReason__c = 'Validação de Contestação de Valores';
        lFourFields.LeavingReason__c = 'Contestação Negada';
        lFourFields.Business_Unit__c = 'Claro';
        // lFourFields.Product__c = 
        lFourFields.SolarCross_QuantityTime__c = '1';
        lFourFields.SolarCross_QuantityDays__c = '5';

        Parameters__c lThreeFields = new Parameters__c();
        lThreeFields.Active__c = true;
        lThreeFields.RecordTypeId = REOPEN_PROTOCOL_RECTYPE;
        lThreeFields.Journey__c = 'Financial';
        lThreeFields.EntryReason__c = 'Validação de Contestação de Valores';
        lThreeFields.LeavingReason__c = 'Contestação Negada';
        lThreeFields.SolarCross_QuantityTime__c = '5';
        lThreeFields.SolarCross_QuantityDays__c = '5';

        Parameters__c lTwoFields = new Parameters__c();
        lTwoFields.Active__c = true;
        lTwoFields.RecordTypeId = REOPEN_PROTOCOL_RECTYPE;
        lTwoFields.Journey__c = 'Financial';
        lTwoFields.EntryReason__c = 'Validação de Contestação de Valores';
        lTwoFields.SolarCross_QuantityTime__c = '5';
        lTwoFields.SolarCross_QuantityDays__c = '5';

        Parameters__c lOneField = new Parameters__c();
        lOneField.Active__c = true;
        lOneField.RecordTypeId = REOPEN_PROTOCOL_RECTYPE;
        lOneField.Journey__c = 'Financial';
        lOneField.SolarCross_QuantityTime__c = '5';
        lOneField.SolarCross_QuantityDays__c = '5';

        Parameters__c llZeroFields = new Parameters__c();
        llZeroFields.Active__c = true;
        llZeroFields.RecordTypeId = REOPEN_PROTOCOL_RECTYPE;
        llZeroFields.SolarCross_QuantityTime__c = '5';
        llZeroFields.SolarCross_QuantityDays__c = '5';

        List<Parameters__c> lParametersLst = new List<Parameters__c>{lFourFields, lThreeFields, lTwoFields, lOneField, llZeroFields};
        insert lParametersLst;

        List<Account> lContractLst = new List<Account>{ new Account(RecordTypeId = ACC_RECTYPE, Phone = '11999999999', Name = 'Contract', ContractReferenceNumber__c = '654321', BusinessUnit__c = 'Net', CityCode__c = '11'),
                                                        new Account(RecordTypeId = ACC_RECTYPE, Phone = '11999999999', Name = 'Contract', ContractReferenceNumber__c = '654321', BusinessUnit__c = 'Claro', CityCode__c = '11')};
        insert lContractLst;
        
        List<Case> lCaseLst = new List<Case>{new Case(Status = 'Closed', AccountId = lContractLst[0].Id, Subject = 'Personal', RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id)};
        insert lCaseLst;  

        List<Case> lChildCaseLst = new List<Case>{new Case(AccountId = lContractLst[0].Id, Subject = 'Personal', RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id, ParentId = lCaseLst[0].Id)};
        insert lChildCaseLst;   
    }

    static testMethod void getContextRecordTest(){
        system.debug('teste');
        List<Case> lParentCaseLst = [SELECT Id, ClosedDate, CreatedDate, Status, ContractBillingAccount__c FROM Case WHERE ParentId = null];
        List<Account> lContractLst = [SELECT Id FROM Account WHERE RecordTypeId = :ACC_RECTYPE ORDER BY BusinessUnit__c ASC];

        Case lCaseWith4Fields = new Case();
        lCaseWith4Fields.Channel__c = 'Digital';
        lCaseWith4Fields.Origin = 'Portal';
        lCaseWith4Fields.RecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        lCaseWith4Fields.EntryReason__c = 'Validação de Contestação de Valores';
        lCaseWith4Fields.LeavingReason__c = 'Contestação Negada';
        // lCaseWith4Fields.BusinessUnit__c = 'Claro';
        //lCaseWith4Fields.Product__c = 'Banda Larga';
        lCaseWith4Fields.ContractBillingAccount__c = '0011g00000o1L8iAAE';
        lCaseWith4Fields.ParentId = '5001g000009J11PAAS';
        lCaseWith4Fields.Solar_Cross_IsReopen__c = true;
        lCaseWith4Fields.ParentId = lParentCaseLst[0].Id;
        lCaseWith4Fields.ContractBillingAccount__c = lContractLst[0].Id;

        Case lCaseWith3Fields = new Case();
        lCaseWith3Fields.Channel__c = 'Digital';
        lCaseWith3Fields.Origin = 'Portal';
        lCaseWith3Fields.RecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        lCaseWith3Fields.EntryReason__c = 'Validação de Contestação de Valores';
        lCaseWith3Fields.LeavingReason__c = 'Contestação Negada';
        // lCaseWith3Fields.BusinessUnit__c = 'Net';
        lCaseWith3Fields.ContractBillingAccount__c = '0011g00000o1L8iAAE';
        lCaseWith3Fields.ParentId = '5001g000009J11PAAS';
        lCaseWith3Fields.Solar_Cross_IsReopen__c = true;
        lCaseWith3Fields.ParentId = lParentCaseLst[0].Id;
        lCaseWith3Fields.ContractBillingAccount__c = lContractLst[1].Id;

        Case lCaseWith2Fields = new Case();
        lCaseWith2Fields.Channel__c = 'Digital';
        lCaseWith2Fields.Origin = 'Portal';
        lCaseWith2Fields.RecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        lCaseWith2Fields.EntryReason__c = 'Validação de Contestação de Valores';
        lCaseWith2Fields.LeavingReason__c = 'Contestação Parcialmente Aprovada';
        // lCaseWith2Fields.BusinessUnit__c = 'Net';
        lCaseWith2Fields.ContractBillingAccount__c = '0011g00000o1L8iAAE';
        lCaseWith2Fields.ParentId = '5001g000009J11PAAS';
        lCaseWith2Fields.Solar_Cross_IsReopen__c = true;
        lCaseWith2Fields.ParentId = lParentCaseLst[0].Id;
        lCaseWith2Fields.ContractBillingAccount__c = lContractLst[1].Id;

        Case lCaseWith1Fields = new Case();
        lCaseWith1Fields.Channel__c = 'Digital';
        lCaseWith1Fields.Origin = 'Portal';
        lCaseWith1Fields.RecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        lCaseWith1Fields.EntryReason__c = 'Solicitação de 2ª via';
        lCaseWith1Fields.LeavingReason__c = 'Contestação Parcialmente Aprovada';
        // lCaseWith1Fields.BusinessUnit__c = 'Net';
        lCaseWith1Fields.ContractBillingAccount__c = '0011g00000o1L8iAAE';
        lCaseWith1Fields.ParentId = '5001g000009J11PAAS';
        lCaseWith1Fields.Solar_Cross_IsReopen__c = true;
        lCaseWith1Fields.ParentId = lParentCaseLst[0].Id;
        lCaseWith1Fields.ContractBillingAccount__c = lContractLst[1].Id;

        Case lCaseWith0Fields = new Case();
        lCaseWith0Fields.Channel__c = 'Digital';
        lCaseWith0Fields.Origin = 'Portal';
        lCaseWith0Fields.RecordTypeId = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Backoffice').getRecordTypeId();
        lCaseWith0Fields.EntryReason__c = 'Solicitação de 2ª via';
        lCaseWith0Fields.LeavingReason__c = 'Contestação Parcialmente Aprovada';
        // lCaseWith0Fields.BusinessUnit__c = 'Net';
        lCaseWith0Fields.ContractBillingAccount__c = '0011g00000o1L8iAAE';
        lCaseWith0Fields.ParentId = '5001g000009J11PAAS';
        lCaseWith0Fields.Solar_Cross_IsReopen__c = true;
        lCaseWith0Fields.ParentId = lParentCaseLst[0].Id;
        lCaseWith0Fields.ContractBillingAccount__c = lContractLst[1].Id;

        List<Case> lCaseToInsertLst = new List<Case> {lCaseWith4Fields,lCaseWith3Fields,lCaseWith2Fields,lCaseWith1Fields,lCaseWith0Fields};
        
        Test.startTest();
            Database.insert(lCaseToInsertLst,false); 
            System.assertEquals(lCaseToInsertLst[0].Id, null);          
            System.assertEquals(lCaseToInsertLst[1].Id, null);          
            System.assertEquals(lCaseToInsertLst[2].Id, null);          
            System.assertEquals(lCaseToInsertLst[3].Id, null);          
            System.assertEquals(lCaseToInsertLst[4].Id, null);          
        Test.stopTest();
    }
}