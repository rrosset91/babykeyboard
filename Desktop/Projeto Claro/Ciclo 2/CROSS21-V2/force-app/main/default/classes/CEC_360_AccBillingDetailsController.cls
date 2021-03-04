public class CEC_360_AccBillingDetailsController {
    
    static Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    
    @AuraEnabled
    public static List<String> getBillingAccount (string parentId){
        List<Account> lstBillingAcc = [SELECT Id,Name,ContractNumber__c,
                                       vlocity_cmt__PremisesId__r.Complement__c,
                                       vlocity_cmt__PremisesId__r.Number__c, 
                                       vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c
                                       FROM Account 
                                       WHERE ParentId =: parentId
                                       and RecordTypeId=:recTypeBillingAccount];
        system.debug(lstBillingAcc);
        return formatAccount(lstBillingAcc);
    }
    
    @AuraEnabled
    public static List<String> fillContracts (string parentId){
        List<Account> lstBillingAcc = [SELECT Id,ContractNumber__c FROM Account 
                                       WHERE ParentId =: parentId
                                       and RecordTypeId=:recTypeBillingAccount];
        return formatAccount(lstBillingAcc);
    }
    
    public static List<String> formatAccount (List<Account> acc){
        List<String> accTList = new List<String> ();
        
        for(integer i = 0; i < acc.size();i++){
            String contract = acc[i].ContractNumber__c;
            accTList.add(contract);
        }
        return accTList;
    }
    
    @AuraEnabled
    public static Account getDetails (string contractNumber){
        List<Account> lstDetailsAcc = [SELECT Id, DueDay__c, CloseDay__c,
                                       ContractNumber__c,
                                       BusinessUnit__c,
                                       DiaLiberacaoFranquia__c,
                                       DiaRenovacaoCarencia__c,
                                       vlocity_cmt__AccountPaymentType__c,
                                       vlocity_cmt__BillDeliveryMethod__c,
                                       BillingAddress,
                                       vlocity_cmt__PremisesId__r.Complement__c,
                                       vlocity_cmt__PremisesId__r.Number__c, 
                                       vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                                       vlocity_cmt__PremisesId__r.Neighborhood__c,
                                       vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                                       vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
                                       vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c
                                       FROM Account
                                       WHERE ContractNumber__c=: contractNumber
                                       and RecordTypeId=:recTypeBillingAccount
                                      ];
        system.debug(lstDetailsAcc);
        return lstDetailsAcc[0];
    }
    
    @AuraEnabled
    public static List <CEC_RestObjects.Invoice> getObjectDataBillingAcc(String contractNumber, String startDate, String endDate) {
        List <CEC_RestObjects.Invoice> invoicesList;
        
        Account acc = [SELECT Id, BusinessUnit__c, ContractReferenceNumber__c, CityCode__c 
                       FROM Account 
                       WHERE contractNumber__c =: contractNumber];
        
        if(acc != null)
            System.debug('AA:: ' + acc.BusinessUnit__c + '- '+ acc.CityCode__c + '- ' + acc.ContractReferenceNumber__c+ ' - ' + startDate + '- ' +endDate +' fim');
            invoicesList = getFormatData(acc.BusinessUnit__c,acc.CityCode__c, acc.ContractReferenceNumber__c, startDate, endDate);
            //for test
            // invoicesList = returnTestInvoice();
        
        return invoicesList;
    }

    //Project [Claro - Solar] - [Sprint 0] - Task [TU20]
    @AuraEnabled
    public static SolarCaseResponseWrapper getContractData(String recordId){
        System.debug('getContractData ' +recordId);
        Case caso = [SELECT 
                        Id, 
                        ContractBillingAccount__c,
                        ContractBillingAccount__r.contractNumber__c, 

                        ContractBillingAccount__r.BusinessUnit__c,
     					RecordType.DeveloperName

                    FROM Case 
                    WHERE Id =: recordId];
        System.debug('getContractData caso ' +caso);

        SolarCaseResponseWrapper wrapper = new SolarCaseResponseWrapper();
        wrapper.contractNumber = caso.ContractBillingAccount__c;
        wrapper.contractNumber = caso.ContractBillingAccount__r.contractNumber__c;
        wrapper.businessUnit = caso.ContractBillingAccount__r.BusinessUnit__c;

        wrapper.recordTypeName = caso.RecordType.DeveloperName;

        System.debug('getContractData wrapper ' +wrapper);
        return wrapper;
    }

    public class SolarCaseResponseWrapper{
        @AuraEnabled public String contractId  {get; set;}
        @AuraEnabled public String contractNumber  {get; set;}
        @AuraEnabled public String businessUnit {get; set;}

        @AuraEnabled public String recordTypeName {get;set;}

        public SolarCaseResponseWrapper(){
            this.contractId   = '';
            this.contractNumber   = '';
            this.businessUnit  = '';


            this.recordTypeName = '';
        }
    }
    //Somente para 
    /*public static List <CEC_RestObjects.Invoice> returnTestInvoice(){


        List<CEC_RestObjects.Invoice> lstInvoice = new List<CEC_RestObjects.Invoice>();
        CEC_RestObjects.Invoice invoice = new CEC_RestObjects.Invoice();
            invoice.invoiceId = '2';
            invoice.statusInvoiceId = 'Total Contas Dedicadas';
            invoice.statusInvoiceDescription = 'Bônus para Ligações Locais';
            invoice.dueDate = '2017-02-20';
            invoice.invoiceAmount = 5.5;
            invoice.paymentForm = 'teste';
            invoice.dueDate_aux = '2017-02-20';
            invoice.amountPrincipal = 10;
            invoice.invoiceAmount_aux = '20';
        lstInvoice.add(invoice);
        invoice = new CEC_RestObjects.Invoice();
            invoice.invoiceId = '1';
            invoice.statusInvoiceId = 'Total Contas Dedicadas';
            invoice.statusInvoiceDescription = 'Bônus para Ligações Locais';
            invoice.dueDate = '2017-02-20';
            invoice.invoiceAmount = 5.5;
            invoice.paymentForm = 'teste';
            invoice.dueDate_aux = '2017-02-20';
            invoice.amountPrincipal = 10;
            invoice.invoiceAmount_aux = '20';
        lstInvoice.add(invoice);
        invoice = new CEC_RestObjects.Invoice();
            invoice.invoiceId = '3';
            invoice.statusInvoiceId = 'Total Contas Dedicadas';
            invoice.statusInvoiceDescription = 'Bônus para Ligações Locais';
            invoice.dueDate = '2017-02-20';
            invoice.invoiceAmount = 5.5;
            invoice.paymentForm = 'teste';
            invoice.dueDate_aux = '2017-02-20';
            invoice.amountPrincipal = 10;
            invoice.invoiceAmount_aux = '20';
        lstInvoice.add(invoice);
        return lstInvoice;

    }*/

    //End [TU20]
    
    public static List<CEC_RestObjects.Invoice> getFormatData(String businessUnit, String operatorId, String contractId, String startDate, String endDate) {
        String bu_aux;
        List <CEC_RestObjects.Invoice> invoices;
        
        if(businessUnit == 'NET') {
            bu_aux = 'RESIDENCIAL';
            if(!Test.isRunningTest()) {
                invoices = CEC_360_IntegrationInvoices.getInvoiceResidencial(bu_aux, contractId, operatorId, startDate, endDate);
            }
        }
        
        if(businessUnit == 'CLARO') {
            bu_aux = 'MOVEL';
            if(!Test.isRunningTest()) {
                invoices = CEC_360_IntegrationInvoices.getInvoiceMovel(bu_aux, contractId, startDate, endDate);
            }
        }
        
        return invoices;
    }
    
    @AuraEnabled
    public static String getBUnit(string contractNumber){
        Account acc = [SELECT Id, BusinessUnit__c, ContractReferenceNumber__c  
                       FROM Account 
                       WHERE ContractNumber__c =: contractNumber];
        return acc.BusinessUnit__c;
    }
    
    @AuraEnabled
    public static String getContractNumberBillingAccount(String contractId) {
        Account acc = [SELECT Id, ContractReferenceNumber__c 
                       FROM Account 
                       WHERE ContractNumber__c =: contractId];
        
        return acc.ContractReferenceNumber__c;
   }
    
    @AuraEnabled
    public static String getUrlPdfBillingAcc(String dueDate,String contractNumber) {
        String bu_aux;
        String url;
     
        if(!Test.isRunningTest()){
            url = CEC_360_IntegrationInvoices.getInvoicesURL('MOVEL',contractNumber,dueDate);   
        }else{
            url='teste';
        }
        
        return url;
    }
    
    @AuraEnabled
    public static String getUrlPdfBillingAccRes(String contractNumber, String invoiceId) {
        String url;
        string ContractReferenceNumber = contractNumber;
        if(!Test.isRunningTest()){
            url = CEC_360_IntegrationInvoices.getInvoicesURLRes('RESIDENCIAL',invoiceId,ContractReferenceNumber);
        }else{
            url = 'teste';
        }
        system.debug('URL'+url);
        return url;
    }
    
    
    
}