/*
* Autor: Diogo Braga - Deloitte
* Data: 09/06/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe de testes da classe DocuSignRecipientStatusTrigger
*/
@isTest
public class CEC_DocuSignRecipientTriggerTest {
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na criação dos dados para execução dos testes
    */      
	@testSetup
    public static void testSetup() { 
		Account account = new Account();
        account.Name = 'test';
        insert account;
        
        Order order = new Order();
        order.accountId = account.Id;
        order.EffectiveDate = System.today();
        order.Status = 'Em andamento';
        order.Pricebook2Id = Test.getStandardPricebookId();
        insert order;
        
		Product2 prd = new Product2();
        prd.Name = 'Teste';
        prd.ProductCode = 'Teste';
        prd.vlocity_cmt__Type__c = '';
        prd.Manufacturer__c = 'teste fabricante';
        prd.Model__c = 'teste modelo';
        prd.Color__c = 'teste cor 2'; 
        insert prd;
        
		PricebookEntry pbe = new PricebookEntry();     
        pbe.pricebook2id=Test.getStandardPricebookId(); 
        pbe.product2id=prd.id;
        pbe.unitprice=0.0; 
        pbe.isActive=true;   
        insert pbe;
        
        OrderItem ordItem = new OrderItem();
        ordItem.OrderId = order.Id;
       	ordItem.Product2Id = prd.Id;
        ordItem.PricebookEntryId = pbe.Id;
        ordItem.Quantity = 1;
        ordItem.UnitPrice = 0.0;
        ordItem.vlocity_cmt__EffectiveRecurringTotal__c = 1;
        ordItem.DonatorName__c = 'Teste';
        ordItem.vlocity_cmt__RecurringTotal__c = 0.00;
        ordItem.AnotherDeviceColor__c = 'teste outra cor'; 
        insert ordItem;
        
        order.Status = 'Contrato Criado';
        update order;         
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Apenas 1 assinador, e com status Completed. Resultado: Status alterado 
    */     
    @isTest  
    public static void testCompleted() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        status.Order__c = order.Id;
        insert status;
        
        dsfs__DocuSign_Recipient_Status__c recipient = new dsfs__DocuSign_Recipient_Status__c();
        recipient.dsfs__DocuSign_Recipient_Id__c = 'test';
        recipient.dsfs__Parent_Status_Record__c = status.Id;
        recipient.dsfs__Recipient_Status__c = 'Completed';
        recipient.AssinaturaObrigatoria__c = true;
        insert recipient;
        //update recipient;
        
        order = [SELECT Status FROM Order LIMIT 1];
        System.assertNotEquals('Contrato Criado', order.Status);
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Apenas 1 assinador, e com status Sent. Resultado: Status não alterado
    */     
    @isTest     
	public static void testSent() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        status.Order__c = order.Id;
        insert status;
        
        dsfs__DocuSign_Recipient_Status__c recipient = new dsfs__DocuSign_Recipient_Status__c();
        recipient.dsfs__DocuSign_Recipient_Id__c = 'test';
        recipient.dsfs__Parent_Status_Record__c = status.Id;
        recipient.dsfs__Recipient_Status__c = 'Sent';
        recipient.AssinaturaObrigatoria__c = true;
        insert recipient;

        order = [SELECT Status FROM Order LIMIT 1];
        System.assertEquals('Contrato Criado', order.Status);        
    } 
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: 2 assinadores obrigatórios, e alterando o status de apenas 1 deles. Resultado: Status não alterado    
    */    
	@isTest
	public static void testUpdCompleted() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        status.Order__c = order.Id;
        insert status;
        
        dsfs__DocuSign_Recipient_Status__c recipient = new dsfs__DocuSign_Recipient_Status__c();
        recipient.dsfs__DocuSign_Recipient_Id__c = 'test1';
        recipient.dsfs__Parent_Status_Record__c = status.Id;
        recipient.dsfs__Recipient_Status__c = 'Sent';
        recipient.AssinaturaObrigatoria__c = true;
        insert recipient;
        
		recipient = new dsfs__DocuSign_Recipient_Status__c();
        recipient.dsfs__DocuSign_Recipient_Id__c = 'test2';
        recipient.dsfs__Parent_Status_Record__c = status.Id;
        recipient.dsfs__Recipient_Status__c = 'Sent';
        recipient.AssinaturaObrigatoria__c = true;
        insert recipient; 
        
        recipient.dsfs__Recipient_Status__c = 'Completed';
		update recipient;        

        order = [SELECT Status FROM Order LIMIT 1];
        system.debug('order.Status ' + order.Status);
        System.assertEquals('Contrato Criado', order.Status);        
    }

    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: 2 assinadores obrigatórios, e alterando o status dos 2. Resultado: Status alterado
    */     
	@isTest   
	public static void testUpdAllCompleted() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        status.Order__c = order.Id;
        insert status;
        
        dsfs__DocuSign_Recipient_Status__c recipient1 = new dsfs__DocuSign_Recipient_Status__c();
        recipient1.dsfs__DocuSign_Recipient_Id__c = 'test1';
        recipient1.dsfs__Parent_Status_Record__c = status.Id;
        recipient1.dsfs__Recipient_Status__c = 'Sent';
        recipient1.AssinaturaObrigatoria__c = true;
        insert recipient1;
        
		dsfs__DocuSign_Recipient_Status__c recipient2 = new dsfs__DocuSign_Recipient_Status__c();
        recipient2.dsfs__DocuSign_Recipient_Id__c = 'test2';
        recipient2.dsfs__Parent_Status_Record__c = status.Id;
        recipient2.dsfs__Recipient_Status__c = 'Sent';
        recipient2.AssinaturaObrigatoria__c = true;
        insert recipient2; 

        recipient1.dsfs__DocuSign_Recipient_Id__c = 'test1';         
        recipient1.dsfs__Recipient_Status__c = 'Completed';
		update recipient1;
        
        recipient2.dsfs__DocuSign_Recipient_Id__c = 'test2';        
        recipient2.dsfs__Recipient_Status__c = 'Completed';
		update recipient2;  
        
        order = [SELECT Status FROM Order LIMIT 1];
        System.assertNotEquals('Contrato Criado', order.Status);        
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: 2 assinadores, 1 obrigatórios, e alterando o status do outro. Resultado: Status não alterado    
    */     
	@isTest
	public static void testUpdNonReqCompleted() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        status.Order__c = order.Id;
        insert status;
        
        dsfs__DocuSign_Recipient_Status__c recipient1 = new dsfs__DocuSign_Recipient_Status__c();
        recipient1.dsfs__DocuSign_Recipient_Id__c = 'test1';
        recipient1.dsfs__Parent_Status_Record__c = status.Id;
        recipient1.dsfs__Recipient_Status__c = 'Sent';
        recipient1.AssinaturaObrigatoria__c = true;
        insert recipient1;
        
		dsfs__DocuSign_Recipient_Status__c recipient2 = new dsfs__DocuSign_Recipient_Status__c();
        recipient2.dsfs__DocuSign_Recipient_Id__c = 'test2';
        recipient2.dsfs__Parent_Status_Record__c = status.Id;
        recipient2.dsfs__Recipient_Status__c = 'Sent';
        recipient2.AssinaturaObrigatoria__c = false;
        insert recipient2; 
        
        recipient2.dsfs__DocuSign_Recipient_Id__c = 'test2';        
        recipient2.dsfs__Recipient_Status__c = 'Completed';
		update recipient2;  
        
        order = [SELECT Status FROM Order LIMIT 1];
        System.assertEquals('Contrato Criado', order.Status);        
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: 2 assinadores, 1 obrigatórios, e alterando o status do obrigatório. Resultado: Status alterado    
    */     
	@isTest
	public static void testUpdReqCompleted() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        status.Order__c = order.Id;
        insert status;
        
        dsfs__DocuSign_Recipient_Status__c recipient1 = new dsfs__DocuSign_Recipient_Status__c();
        recipient1.dsfs__DocuSign_Recipient_Id__c = 'test1';
        recipient1.dsfs__Parent_Status_Record__c = status.Id;
        recipient1.dsfs__Recipient_Status__c = 'Sent';
        recipient1.AssinaturaObrigatoria__c = true;
        insert recipient1;
        
		dsfs__DocuSign_Recipient_Status__c recipient2 = new dsfs__DocuSign_Recipient_Status__c();
        recipient2.dsfs__DocuSign_Recipient_Id__c = 'test2';
        recipient2.dsfs__Parent_Status_Record__c = status.Id;
        recipient2.dsfs__Recipient_Status__c = 'Sent';
        recipient2.AssinaturaObrigatoria__c = false;
        insert recipient2; 
        
        recipient1.dsfs__DocuSign_Recipient_Id__c = 'test2';        
        recipient1.dsfs__Recipient_Status__c = 'Completed';
		update recipient1;  
        
        order = [SELECT Status FROM Order LIMIT 1];
        System.assertNotEquals('Contrato Criado', order.Status);        
    }    
}