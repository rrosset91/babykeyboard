/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:     Test class for Solar_Cross_ProtocolCodificationFlow
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-31      Jean Sganzerla          class created 
**************************************************************************************************************/
@isTest
public class Solar_Cross_ProtocolCodificationTest {
    private static final Id ATTENDENCE_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AttendanceTree').getRecordTypeId();
    private static final Id ACC_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    private static final Id CASE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();

    @TestSetup
    static void makeData(){
        List<Account> lContractLst = new List<Account>{new Account(RecordTypeId = ACC_RECTYPE, Name = 'Contract', ContractReferenceNumber__c = '654321', BusinessUnit__c = 'Net', CityCode__c = '11')};
        insert lContractLst;

        List<Parameters__c> lAttendenceRecords = new List<Parameters__c>{new Parameters__c( RecordTypeId = ATTENDENCE_RECTYPE, 
                                                                                            TypeService__c = 'Negativação', 
                                                                                           	Product__c = 'Claro NET TV', 
                                                                                            Solar_Cross_ServiceModality__c = 'TV', 
                                                                                            EntryReason__c = 'Validação de Contestação de Valores', 
                                                                                            LeavingReason__c = 'Contestação aprovada',
                                                                                            FirstCallResolution__c = false,
                                                                                            Active__c = true,
                                                                                            Journey__c = 'Financial',
                                                                                            Business_Unit__c = 'Net',
                                                                                            Channel__c = 'Anatel'),

                                                                                            new Parameters__c( RecordTypeId = ATTENDENCE_RECTYPE, 
                                                                                            TypeService__c = 'Negativação', 
                                                                                            Solar_Cross_ServiceModality__c = 'TV', 
                                                                                            EntryReason__c = 'Validação de Contestação de Valores', 
                                                                                            LeavingReason__c = 'Contestação aprovada',
                                                                                            FirstCallResolution__c = true,
                                                                                            Active__c = true,
                                                                                            Journey__c = 'Financial',
                                                                                            Business_Unit__c = 'Net',
                                                                                            Channel__c = 'Anatel')
                                                                                        };
        insert lAttendenceRecords;

        List<Case> lCaseLst = new List<Case>{new Case(  Subject = 'Default', 
                                                        RecordTypeId = CASE_RECTYPE, 
                                                        ContractBillingAccount__c = lContractLst[0].Id,
                                                        Category__c = 'Negativação',
                                                        Product__c = 'Claro NET TV',
                                                        Modalidade__c = 'TV',
                                                        BusinessUnit__c = 'Net',
                                                        EntryReason__c = 'Validação de Contestação de Valores',
                                                        LeavingReason__c = 'Contestação aprovada',
                                                        Channel__c = 'Anatel')};
        insert lCaseLst; 

        List<ServiceParameter__c> params = new List<ServiceParameter__c>();
        params.add(getServiceParameter('/communicationmanagement/send', 'POST', 'OAG_NET_SendEmail', 'MCIDAS', 'OAGClaro'));
        params.add(getServiceParameter('/contactrecords', 'POST', 'CEC_OAG_NET_Ocurrency', 'PROD_JD', 'OAGNet'));
        insert params;

    }

    private static ServiceParameter__c getServiceParameter(String endPoint, String method, String name, String userName, String namedCredential){
        ServiceParameter__c param = new ServiceParameter__c();
        param.Name = name;
        param.EndPoint__c = endPoint;
        param.IsActive__c = true;
        param.Method__c = method;
        param.User__c = userName;
        param.NamedCredential__c = namedCredential;
        return param;
    }     

    static testMethod void getPicklistOptionsTest(){
        List<Case> lCaseLst = [SELECT Id, ContractBillingAccount__r.BusinessUnit__c, Category__c, Product__c, Modalidade__c, EntryReason__c, Channel__c, LeavingReason__c FROM Case WHERE Subject = 'Default'];
        
        List<String> lMethodParameter = new List<String>();
        lMethodParameter.add('Financial');
        lMethodParameter.add(lCaseLst[0].ContractBillingAccount__r.BusinessUnit__c);
        lMethodParameter.add(lCaseLst[0].Channel__c);      

        Test.startTest();
            List<Solar_Cross_ProtocolCodificationFlow.PicklistWrapper> lAssert = Solar_Cross_ProtocolCodificationFlow.getPicklistOptions(lMethodParameter);
            System.assertEquals(lCaseLst[0].Category__c, lAssert[0].value);

            lMethodParameter.add(lCaseLst[0].Category__c);        
            lAssert = Solar_Cross_ProtocolCodificationFlow.getPicklistOptions(lMethodParameter);
            System.assertEquals(lCaseLst[0].Modalidade__c, lAssert[0].value);

            lMethodParameter.add(lCaseLst[0].Modalidade__c);
            lAssert = Solar_Cross_ProtocolCodificationFlow.getPicklistOptions(lMethodParameter);
            System.assertEquals(lCaseLst[0].EntryReason__c, lAssert[0].value);

            lMethodParameter.add(lCaseLst[0].EntryReason__c);
            lAssert = Solar_Cross_ProtocolCodificationFlow.getPicklistOptions(lMethodParameter);
            System.assertEquals(lCaseLst[0].LeavingReason__c, lAssert[0].value);
        Test.stopTest();
    }  
    
    static testMethod void getContextRecordTest(){
        List<Case> lCaseLst = [SELECT Id, Status, IsClosed, ContractBillingAccount__c, ContractBusinessUnit__c, RecordType.DeveloperName, Channel__c, Category__c, Product__c, Modalidade__c, EntryReason__c, Solar_Cross_forwardingReason__c FROM Case WHERE Subject = 'Default'];
        
        Test.startTest();
            Case lAssert = Solar_Cross_ProtocolCodificationFlow.getContextRecord(lCaseLst[0].Id);
            System.assertEquals(lCaseLst[0], lAssert);
        Test.stopTest();
    }

    static testMethod void updaContextRecordTest(){
        List<Account> lContractLst = [SELECT Id FROM Account];
        List<Case> lCaseLst = new List<Case>{new Case(  Subject = 'Default', 
                                                        RecordTypeId = CASE_RECTYPE, 
                                                        ContractBillingAccount__c = lContractLst[0].Id,
                                                        Category__c = 'Negativação',
                                                        // Product__c = 'Claro NET TV',
                                                        Modalidade__c = 'TV',
                                                        BusinessUnit__c = 'Net',
                                                        EntryReason__c = 'Validação de Contestação de Valores',
                                                        LeavingReason__c = 'Contestação aprovada',
                                                        Channel__c = 'Anatel')};
        insert lCaseLst; 

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"data": {"content": "Sua fatura já está disponível no aplicativo MinhaClaro Teste 3.","description": "TEXTO","subject": "Fatura Claro 3.","type": "EMAIL","receiver": [{ "email": "gustavo.rodrigues917@gmail.com","phoneNumber": "","type": ""}], "sender": {"email": "nao-responda@claro.com.br","id": "string","phoneNumber": "1129285598"}}}', 200));
            Solar_Cross_ProtocolCodificationFlow.updaContextRecord(lCaseLst[0].Id, 'Teste', lCaseLst[0].LeavingReason__c, lCaseLst[0].Category__c, lCaseLst[0].Modalidade__c, lCaseLst[0].EntryReason__c, 'Teste', 'Sim');            
        Test.stopTest();
    }
}