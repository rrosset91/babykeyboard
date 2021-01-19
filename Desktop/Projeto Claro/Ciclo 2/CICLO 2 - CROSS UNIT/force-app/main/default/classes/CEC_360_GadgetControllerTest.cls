/* Autor: Danilo Fucuhara - Deloitte 
   Criação: 22/03/2019
   Descrição:Classe teste para CEC_360_GadgetController.
   Nome do projeto/ID: CEC FASE - Time: SQUAD 360. */

@isTest
public class CEC_360_GadgetControllerTest {
    
    static testMethod void testGetDevice() {
        Account acc = new Account();
        acc.name = 'Acc1';
        insert acc;
        
        Asset ast = new Asset();
        ast.Name = 'Asset Test';
        ast.AccountId = acc.Id;
        ast.MSISDN__c = '1234567890';
        insert ast;
        
        Test.startTest();
        CEC_360_GadgetController.getDevice(ast.Id);
        Test.stopTest();
    }

}