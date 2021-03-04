/* Autor: Letícia Freitas - Deloitte 
Criação: 22/03/2018 
Descrição: Classe de teste para CEC_360_InvoiceController.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360.

*  Controle de Versão
* ---------------------------------------------------------------
*  Data: 24-04-2019
*  Autor: Danilo Fucuhara.
*  Alterações: Classe refatorada para novas alterações.
*/

@isTest
public class CEC_360_InvoiceControllerTest { 
    
    static testMethod void getContractNumber() {
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Contract contract = new Contract(Name = 'Con', 
                                         AccountId = acc.Id);
        insert contract;
        
        Asset ast = new Asset(Name = 'Ast', 
                              AccountId = acc.Id, 
                              MSISDN__c = '123');
        insert ast;
        
        Test.startTest();
        CEC_360_InvoiceController.getContractNumber(contract.Id);
        Test.stopTest();
    }
    
    static testMethod void getContractNumberBillingAccount() {
        Account acc = new Account(Name = 'Acc', 
                                  ContractReferenceNumber__c = '123');
        insert acc;

        Test.startTest();
        CEC_360_InvoiceController.getContractNumberBillingAccount(acc.Id);
        Test.stopTest();
    }
    
    static testMethod void getObjectData1(){
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Contract con = new Contract(Name = 'Con', 
                                         AccountId = acc.Id, 
                                         vlocity_cmt__ContractReferenceNumber__c = '349338695', 
                                         CityCode__c = '003', 
                                         BusinessUnit__c = 'NET');
        insert con;
		
        Test.startTest();
        CEC_360_InvoiceController.getObjectData(con.id, '2017-01-01', '2017-06-01');
        Test.stopTest();
        
    }
    
    static testMethod void getObjectData2(){
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Contract con = new Contract(Name = 'Con', 
                                         AccountId = acc.Id, 
                                         vlocity_cmt__ContractReferenceNumber__c = '349338695', 
                                         CityCode__c = '003', 
                                         BusinessUnit__c = 'CLARO');
        insert con;
               
        Test.startTest();
        CEC_360_InvoiceController.getObjectData (con.id, '2017-01-01', '2017-06-01');
        test.stopTest();
    }
    
    static testMethod void getObjectDataBillingAcc(){
        Account acc = new Account(Name = 'Acc',
                                  BusinessUnit__c = 'CLARO',
                                  ContractReferenceNumber__c = '349338695',
                                  CityCode__c = '003');
        insert acc;

        Test.startTest();
        CEC_360_InvoiceController.getObjectDataBillingAcc(acc.id, '2017-01-01', '2017-06-01');
        Test.stopTest();
    }
    
    static testMethod void testGetUrlPdf1() {
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Contract con = new Contract(Name = 'Teste1', 
                                         AccountId = acc.Id, 
                                         BusinessUnit__c = 'CLARO');
        insert con;

        Test.startTest();
        CEC_360_InvoiceController.getUrlPdf('2020-01-01', con.Id);
        Test.stopTest();
    }
    
    static testMethod void testGetUrlPdf2() {
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Contract con = new Contract(Name = 'Teste1', 
                                         AccountId = acc.Id, 
                                         BusinessUnit__c = 'NET');
        insert con;

        Test.startTest();
        CEC_360_InvoiceController.getUrlPdf('2020-01-01', con.Id);
        Test.stopTest();
    }
    
    static testMethod void getUrlPdfBillingAccTest1() {
        Account acc = new Account(Name = 'Acc',
                                  BusinessUnit__c = 'CLARO',
                                  ContractReferenceNumber__c = '349338695',
                                  CityCode__c = '003');
        insert acc;

        Test.startTest();
        CEC_360_InvoiceController.getUrlPdfBillingAcc('2020-01-01', acc.Id);
        Test.stopTest();
    }
    
    static testMethod void getUrlPdfBillingAccTest2() {
        Account acc = new Account(Name = 'Acc',
                                  BusinessUnit__c = 'NET',
                                  ContractReferenceNumber__c = '349338695',
                                  CityCode__c = '003');
        insert acc;
        
        Test.startTest();
        CEC_360_InvoiceController.getUrlPdfBillingAcc('2020-01-01', acc.Id);
        Test.stopTest();
    }
}