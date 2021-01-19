@isTest
public class CEC_AuthorityInvoiceTest {
    @isTest static void disputeInvoiceOk() 
    {	
		Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();

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

		Account acc = new Account(Name = 'Testante', ContractReferenceNumber__c = '1027935', RecordTypeId = recordTypeIdAccount);
		insert acc;

		insert new Parameters__c(Amount__c = 10, Active__c = true, RecordTypeId = recordTypeIdParameter);

        Test.startTest();
        List<CEC_DisputeInvoice.InvoiceItem> lst = new List<CEC_DisputeInvoice.InvoiceItem>();
        CEC_DisputeInvoice.InvoiceItem invoiceItems = new CEC_DisputeInvoice.invoiceItem();
        invoiceItems.idInvoiceItem = '1579031159';
        invoiceItems.idGroupItem = '1';
        invoiceItems.reason = '1';
        invoiceItems.originalValue = 308.42;
        invoiceItems.wishedValue  = 302.42;
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
        CEC_AuthorityInvoice.authorityInvoice(entrada);
        Test.stopTest();
	}
	
	@isTest static void disputeInvoiceWithout() 
    {	
		Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();

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

		Account acc = new Account(Name = 'Testante', ContractReferenceNumber__c = '1027935', RecordTypeId = recordTypeIdAccount);
		insert acc;

		insert new Parameters__c(Amount__c = 10, Active__c = true, RecordTypeId = recordTypeIdParameter);

        Test.startTest();
        List<CEC_DisputeInvoice.InvoiceItem> lst = new List<CEC_DisputeInvoice.InvoiceItem>();
        CEC_DisputeInvoice.InvoiceItem invoiceItems = new CEC_DisputeInvoice.invoiceItem();
        invoiceItems.idInvoiceItem = '1579031159';
        invoiceItems.idGroupItem = '1';
        invoiceItems.reason = '1';
        invoiceItems.originalValue = 308.42;
        invoiceItems.wishedValue  = 200.42;
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
        CEC_AuthorityInvoice.authorityInvoice(entrada);
        Test.stopTest();
	}
	
	@isTest static void disputeInvoiceMissingProperties() 
    {	
		Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();

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

		Account acc = new Account(Name = 'Testante', ContractReferenceNumber__c = '1027935', RecordTypeId = recordTypeIdAccount);
		insert acc;

		insert new Parameters__c(Amount__c = 10, Active__c = true, RecordTypeId = recordTypeIdParameter);

        Test.startTest();
        List<CEC_DisputeInvoice.InvoiceItem> lst = new List<CEC_DisputeInvoice.InvoiceItem>();
        CEC_DisputeInvoice.InvoiceItem invoiceItems = new CEC_DisputeInvoice.invoiceItem();
        invoiceItems.idGroupItem = '1';
        invoiceItems.reason = '1';
        invoiceItems.originalValue = 308.42;
        invoiceItems.wishedValue  = 200.42;
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
        CEC_AuthorityInvoice.authorityInvoice(entrada);
        CEC_AuthorityInvoice.authorityInvoice(null);
        Test.stopTest();
    }
}