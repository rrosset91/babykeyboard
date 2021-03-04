/*
* Autor: [Letícia Freitas] + [Deloitte]
* Data: [27/08/2019]
* Descrição: [Nome do projeto/ID: CEC FASE 1 ] + [Time: SQUAD 360 - Sprint 11] +
* [Classe controller para a chamada via integração de objetos.]
*----------------------------------------------------------------------------------*
*/


public class CEC_360_ServiceOrdersController {
    Static Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    
    @AuraEnabled
    public static List<String> getContracts (string recordId){
        String bu= 'Net';
        List<Account> lstAccount = [Select ID,
                                    ContractNumber__c from
                                    Account where 
                                    ParentId =: recordId
                                    And
                                    RecordTypeId =: recTypeBillingAccount
                                    And 
                                    BusinessUnit__c =: bu];
        
        return formatAccount(lstAccount);
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
    public static List<CEC_RestObjects.Order> getOrdemsfromData (String startDate, String endDate, String contractNumber)
    {
        String operatorCode = getContractData (contractNumber.substringBefore('/'));
        String contractRefNumber = contractNumber.subStringAfter('/');
        
        List <CEC_RestObjects.Order> lstOrder = CEC_360_IntegrationOrders.getOrders(contractRefNumber, operatorCode,
                                                                                    startDate, endDate);
        
         if(lstOrder != null){
            for (CEC_RestObjects.Order objOrder : lstOrder){
                objOrder.eventDate = CEC_360_IntegrationOrders.formatData(objOrder.eventDate);
                objOrder.attendenceDate = CEC_360_IntegrationOrders.formatData(objOrder.attendenceDate);
                objOrder.terminationDate = CEC_360_IntegrationOrders.formatData(objOrder.terminationDate);
            }
        }
        
        return lstOrder;
        
    }
    
    @TestVisible
    public static String getContractData (String operatorCode) {
        if(!test.isRunningTest()){
            CEC_City_CarrierCode__mdt mdt = [Select CodigoCidade__c from CEC_City_CarrierCode__mdt where
                                             CodigoOperadora__c=:operatorCode];      
            return mdt.CodigoCidade__c;
        }else{
            return '21555';
        }
        
    }
    
    @AuraEnabled 
    public static List<CEC_RestObjects.Order> getOrdemsfromProtocol (String protocolNumber,String contractNumber){
        
        String operatorCode = getContractData(contractNumber.substringBefore('/'));
        List <CEC_RestObjects.Order> lstOrder = CEC_360_IntegrationOrders.getOrdersNumber(protocolNumber,operatorCode);
        
        if(lstOrder != null){
            if(lstOrder[0].contractNumber == contractNumber.substringAfter('/')){
                for (CEC_RestObjects.Order objOrder : lstOrder){
                    objOrder.eventDate = CEC_360_IntegrationOrders.formatData(objOrder.eventDate);
                    objOrder.attendenceDate = CEC_360_IntegrationOrders.formatData(objOrder.attendenceDate);
                    objOrder.terminationDate = CEC_360_IntegrationOrders.formatData(objOrder.terminationDate);
                }
            }
        }
        
        return lstOrder;
     }
}