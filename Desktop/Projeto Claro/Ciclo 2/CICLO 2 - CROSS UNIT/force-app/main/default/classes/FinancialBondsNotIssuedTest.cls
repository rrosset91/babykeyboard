@isTest
public with sharing class FinancialBondsNotIssuedTest {
    // @note  83484 - Dados "Itens Títulos Não Emitidos"
    @TestSetup
    static void makeData(){
        ServiceParameter__c customSetting = new ServiceParameter__c();
        customSetting.name = 'GetBillDebts';
        customSetting.EndPoint__c = '00';
        customSetting.Method__c = 'GET';
        customSetting.Timeout__c = 120;
        customSetting.ReturnMock__c = true;
        insert customSetting;
    }
    @IsTest
    static void testMethodGetBillDebts(){
        
        Test.startTest();
            FinancialBondsNotIssued.ResponseWrapper result = FinancialBondsNotIssued.getBillDebts('xpto', '123241', '', '');
            System.assertEquals(200, result.responseCode);
        Test.stopTest();
        
    }
}