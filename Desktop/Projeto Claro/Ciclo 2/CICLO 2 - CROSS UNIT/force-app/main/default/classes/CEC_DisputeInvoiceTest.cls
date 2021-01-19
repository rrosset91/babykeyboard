/**
* @author: Caio Cesar Leite de Oliveira
* @company: IBM - Bluewolf
* @description: Teste para a classe CEC_DisputeInvoice
*/
@isTest
public class CEC_DisputeInvoiceTest 
{
    @isTest static void disputeInvoice() 
    {
		String result;   
		
		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'ContestItem';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = '00';
		customSetting.Timeout__c = 120;
		customSetting.ReturnMock__c = true;
		insert customSetting;

		ServiceParameter__c cs = new ServiceParameter__c();
		cs.name = 'InvoiceAuthority';
		cs.EndPoint__c = '00';
		cs.Method__c = '00';
		cs.Timeout__c = 120;
		cs.ReturnMock__c = true;
		insert cs;

		Account acc = new Account();
        acc.Name = 'Testante';
       	acc.ContractReferenceNumber__c = '1027935';
        acc.ExternalID__c = 'CPF43705574884';
        acc.BusinessUnit__c = 'CLARO';
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        insert acc;

		String rtContractId = [Select Id FROM RecordType WHERE DeveloperName = 'Contract' LIMIT 1].Id;
		Contract ct = new Contract(AccountId = acc.Id, RecordTypeId = rtContractId);
		insert ct;

		String assetRt = [Select Id FROM RecordType WHERE DeveloperName = 'Oferta' LIMIT 1].Id;
		Asset ast = new Asset(Name = '01', RecordTypeId = assetRt, AccountId = acc.Id, vlocity_cmt__BillingAccountId__c = acc.Id, vlocity_cmt__ContractId__c = ct.Id, vlocity_cmt__RecurringUOM__c = 'Monthly');
		insert ast;

        Test.startTest();
        List<CEC_DisputeInvoice.InvoiceItem> lst = new List<CEC_DisputeInvoice.InvoiceItem>();
        CEC_DisputeInvoice.InvoiceItem invoiceItems = new CEC_DisputeInvoice.invoiceItem();
        invoiceItems.idInvoiceItem = '1579031159';
        invoiceItems.idGroupItem = '1';
        invoiceItems.reason = '1';
        invoiceItems.partnerId = '1';
        invoiceItems.originalValue = 308.42;
        invoiceItems.wishedValue  = 15.42;
        invoiceItems.disputePercentage = 5;
        invoiceItems.approvationHash = '2ff06bbb2fbdd0bbd38461bb75362112a69aaa98ae5f6ab6e9c9e53e0527e767613e20cfcd40f0c';
        invoiceItems.notes = 'Observação da contestação';
        invoiceItems.status = 'EM ABERTO';
        lst.add(invoiceItems);
        
        CEC_DisputeInvoice.DisputeInvoiceRequest entrada = new CEC_DisputeInvoice.DisputeInvoiceRequest();
        entrada.contractNumber = '1027935';
        entrada.operatorCode = '004';
        entrada.channel = 'L';
        entrada.idInvoice = '245961436';
        entrada.userName = 'MCIDA';
        entrada.source = 1;
        entrada.type = 'R';
        entrada.invoiceItems = lst;
        
        CEC_DisputeInvoice.disputeInvoice(entrada);
        Test.stopTest();
        system.assertEquals(result,result); 
    } 
    
    @isTest static void caso() 
    {
        String result;
        Test.startTest();
            List<CEC_DisputeInvoice.InvoiceItem> lst = new List<CEC_DisputeInvoice.InvoiceItem>();
            CEC_DisputeInvoice.InvoiceItem invoiceItems = new CEC_DisputeInvoice.invoiceItem();
            invoiceItems.idInvoiceItem = '1579031159';
            invoiceItems.idGroupItem = '1';
            invoiceItems.reason = '1';
            invoiceItems.originalValue = 308.42;
            invoiceItems.wishedValue  = 15.42;
            invoiceItems.disputePercentage = 5;
            invoiceItems.approvationHash = '';
            invoiceItems.notes = 'Observação da contestação';
            invoiceItems.status = 'EM ABERTO';
            lst.add(invoiceItems);
            
            CEC_DisputeInvoice.Caso caso = new CEC_DisputeInvoice.caso();
            caso.contractNumber = '1027935';
            caso.protocol = '003321323154';
            caso.caseId = '13452';
            caso.status = 'EM ABERTO';
            caso.invoiceItems = lst;
            
            CEC_DisputeInvoice.DisputeInvoiceResponse response = new CEC_DisputeInvoice.DisputeInvoiceResponse();
            response.code = '200';
            response.message = 'SUCCESS';
            response.caseData = caso;
        Test.stopTest();
        system.assertEquals(result,result); 
    }    
    
    @isTest static void disputeInvoiceNull() 
    {
        String result;   
        Test.startTest();
        CEC_DisputeInvoice.disputeInvoice(null);
        Test.stopTest();
        system.assertEquals(result,result); 
    }
    
    @isTest static void disputeInvoiceCampoNull() 
    {
        String result;   
        Test.startTest();
        
        CEC_DisputeInvoice.DisputeInvoiceRequest entrada = new CEC_DisputeInvoice.DisputeInvoiceRequest();
        entrada.contractNumber = null;
        entrada.operatorCode = '004';
        entrada.channel = 'L';
        entrada.idInvoice = '245961436';
        entrada.userName = 'MCIDA';
        entrada.source = 1;
        entrada.type = 'R';
        
        CEC_DisputeInvoice.disputeInvoice(entrada);
        Test.stopTest();
        system.assertEquals(result,result); 
    }
    
    @isTest static void disputeInvoiceItemsNull() 
    {
        String result;   
        Test.startTest();
        List<CEC_DisputeInvoice.InvoiceItem> lst = new List<CEC_DisputeInvoice.InvoiceItem>();
        CEC_DisputeInvoice.InvoiceItem invoiceItems = new CEC_DisputeInvoice.invoiceItem();
        invoiceItems.idInvoiceItem = '1579031159';
        invoiceItems.idGroupItem = '1';
        invoiceItems.reason = '1';
        invoiceItems.wishedValue  = 15.42;
        invoiceItems.disputePercentage = 5;
        invoiceItems.approvationHash = null;
        invoiceItems.notes = 'Observação da contestação';
        invoiceItems.status = 'EM ABERTO';
        invoiceItems.getField('approvationHash');
        lst.add(invoiceItems);
        
        CEC_DisputeInvoice.DisputeInvoiceRequest entrada = new CEC_DisputeInvoice.DisputeInvoiceRequest();
        entrada.contractNumber = '1027935';
        entrada.operatorCode = '004';
        entrada.channel = 'L';
        entrada.idInvoice = '245961436';
        entrada.userName = 'MCIDA';
        entrada.source = 1;
        entrada.type = 'R';
        entrada.invoiceItems = lst;
        CEC_DisputeInvoice.disputeInvoice(entrada);
        Test.stopTest();
        system.assertEquals(result,result); 
    }
    
    @isTest static void disputeInvoiceError() 
    {
        String result;   
        Test.startTest();
        CEC_DisputeInvoice.DisputeInvoiceRequest entrada = new CEC_DisputeInvoice.DisputeInvoiceRequest();
        entrada.contractNumber = '1027935';
        entrada.operatorCode = '004';
        entrada.channel = 'L';
        entrada.idInvoice = '245961436';
        entrada.userName = 'MCIDA';
        entrada.source = 1;
        entrada.type = 'ERRO';
        entrada.invoiceItems = null;
        CEC_DisputeInvoice.disputeInvoice(entrada);
        Test.stopTest();
        system.assertEquals(result,result); 
    }
    
    @isTest static void checkRequiredFieldsInvoice()
    {
        String result;   
        Test.startTest();
        List<CEC_DisputeInvoice.InvoiceItem> lst = new List<CEC_DisputeInvoice.InvoiceItem>();
        CEC_DisputeInvoice.InvoiceItem invoiceItems = new CEC_DisputeInvoice.invoiceItem();
        invoiceItems.idInvoiceItem = '1579031159';
        invoiceItems.idGroupItem = '1';
        invoiceItems.reason = '1';
        invoiceItems.wishedValue  = 15.42;
        invoiceItems.disputePercentage = 5;
        invoiceItems.approvationHash = '2ff06bbb2fbdd0bbd38461bb75362112a69aaa98ae5f6ab6e9c9e53e0527e767613e20cfcd40f0c';
        invoiceItems.notes = 'Observação da contestação';
        invoiceItems.status = 'EM ABERTO';
        lst.add(invoiceItems);
        
        CEC_DisputeInvoice.DisputeInvoiceRequest entrada = new CEC_DisputeInvoice.DisputeInvoiceRequest();
        entrada.contractNumber = '1027935';
        entrada.operatorCode = '004';
        entrada.channel = 'L';
        entrada.idInvoice = '245961436';
        entrada.userName = 'MCIDA';
        entrada.source = 1;
        entrada.type = 'R';
        entrada.invoiceItems = lst;
         //CEC_DisputeInvoice.checkRequiredFieldsInvoice(entrada);
        Test.stopTest();
        system.assertEquals(result,result);

    }
}