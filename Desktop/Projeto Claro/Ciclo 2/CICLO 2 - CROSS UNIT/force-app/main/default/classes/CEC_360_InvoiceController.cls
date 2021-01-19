/* Autor: Letícia Freitas - Deloitte 
Criação: 18/01/2018 
Descrição: Nome do projeto/ID: CEC FASE - Time: SQUAD 360 -
Classe para Buscar Via API REST - dados da fatura relacionados ao contrato
*  Controle de Versão
* ---------------------------------------------------------------
*  Data: 25-03-2019  
*  Autor: Leticia Freitas
*  Alterações: Ajustar as chamadas da integração para credencial nominada. 
* ---------------------------------------------------------------
*  Data: 17-04-2019  
*  Autor: Leticia Freitas
*  Alterações: Status da fatura será calculado conforme o campo IndicatorPaymentMade e AmountPaymentMade.
* ---------------------------------------------------------------
*  Data: 23-04-2019
*  Autor: Letícia Freitas.
*  Alterações: Separado métodos de integração para a classe CEC_360_IntegrationInvoices e criação do método para a busca via 
*  billingAccount.
* ---------------------------------------------------------------
*  Data: 23-04-2019
*  Autor: Danilo Fucuhara.
*  Alterações: Criado o metodo getObjectDataBillingAcc para mapeamento dos campos levados para integracao de faturas. Refatorado getContractNumberBillingAccount
*/

public class CEC_360_InvoiceController {
    
    @AuraEnabled 
    public static String getContractNumber(String recordId) {
        Contract con = [SELECT ContractNumber__c 
                        FROM contract 
                        WHERE Id =: recordId];
        
        return con.ContractNumber__c;
    }
    
    @AuraEnabled
    public static String getContractNumberBillingAccount(String recordId) {
        Account acc = [SELECT ContractNumber__c 
                       FROM Account 
                       WHERE Id =: recordId];
        
        return acc.ContractNumber__c;
   }
    
    @AuraEnabled
    public static List <CEC_RestObjects.Invoice> getObjectData(String recordId, String startDate, String endDate) {
        List <CEC_RestObjects.Invoice> invoicesList;
        Contract contract = [SELECT BusinessUnit__c, vlocity_cmt__ContractReferenceNumber__c, CityCode__c 
                             FROM Contract 
                             WHERE id =: recordId];
        
        if(contract != null)
            invoicesList = getFormatData(contract.BusinessUnit__c, contract.CityCode__c, contract.vlocity_cmt__ContractReferenceNumber__c, startDate, endDate);
        
        return invoicesList;
    }
    
    @AuraEnabled
    public static List <CEC_RestObjects.Invoice> getObjectDataBillingAcc(String recordId, String startDate, String endDate) {
        List <CEC_RestObjects.Invoice> invoicesList;
        
        Account acc = [SELECT Id, BusinessUnit__c, ContractReferenceNumber__c, CityCode__c 
                       FROM Account 
                       WHERE Id =: recordId];
        
        if(acc != null)
            invoicesList = getFormatData(acc.BusinessUnit__c,acc.CityCode__c, acc.ContractReferenceNumber__c, startDate, endDate);
        
        return invoicesList;
    }
    
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
    public static String getUrlPdfBillingAcc(String dueDate, String recordId) {
        String bu_aux;
        String url;
        
        Account acc = [SELECT Id, BusinessUnit__c, ContractReferenceNumber__c  
                       FROM Account 
                       WHERE Id =: recordId];
        
        if(acc.BusinessUnit__c == 'NET')
            bu_aux = 'RESIDENCIAL';
        
        if(acc.BusinessUnit__c == 'CLARO')
            bu_aux ='MOVEL';
        
        if(!Test.isRunningTest())
            url = CEC_360_IntegrationInvoices.getInvoicesURL(bu_aux, acc.ContractReferenceNumber__c, dueDate);
        
        return url;
    }
    
    @AuraEnabled
    public static String getUrlPdf(String dueDate, String recordId) {
        String bu_aux;
        String url;
        
        Contract con = [SELECT BusinessUnit__c, ContractNumber__c 
                        FROM Contract 
                        WHERE Id =: recordId];
        
        if(con.BusinessUnit__c == 'NET')
            bu_aux = 'RESIDENCIAL';
        
        if(con.BusinessUnit__c == 'CLARO')
            bu_aux ='MOVEL';
        
        if(!Test.isRunningTest())
            url = CEC_360_IntegrationInvoices.getInvoicesURL(bu_aux, con.ContractNumber__c, dueDate);
        
        return url;
    }
}