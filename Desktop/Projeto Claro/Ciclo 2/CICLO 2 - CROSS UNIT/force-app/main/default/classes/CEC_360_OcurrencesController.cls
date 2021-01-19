/*
* Autor: [Letícia Freitas] + [Deloitte]
* Data: [01/10/2019]
* Descrição: [Nome do projeto/ID: CEC FASE 1 ] + [Time: SQUAD 360 - Sprint 12] +
* [Classe controller para a chamada via integração de objetos.]
*----------------------------------------------------------------------------------*
*/


public class CEC_360_OcurrencesController {
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
    public static List<CEC_RestObjects.ocurrencesObj> getOrdemsfromData (String startDate, String endDate, String contractNumber)
    {
        String contractRefNumber = contractNumber.subStringAfter('/');
        String operatorCode = contractNumber.substringBefore('/');
        String dataStart = startDate.substring(0,5) + startDate.substring(8,10) + startDate.substring(4,7);
        String dataEnd = endDate.substring(0,5) + endDate.substring(8,10) + endDate.substring(4,7);
        
        system.debug(dataStart);
        system.debug(dataEnd);
        
        List <CEC_RestObjects.ocurrencesObj> lstOcurrences = CEC_360_IntegrationOcurrences.getOcurrences(contractRefNumber,
                                                                                      operatorCode,dataStart, dataEnd);
                                                                                            
        
         if(lstOcurrences != null){
            for (CEC_RestObjects.ocurrencesObj objOcurrences : lstOcurrences){
                objOcurrences.creationDate = CEC_360_IntegrationOcurrences.formatData(objOcurrences.creationDate);
                objOcurrences.resolutionDate = CEC_360_IntegrationOcurrences.formatData(objOcurrences.resolutionDate);
                objOcurrences.returnDate = CEC_360_IntegrationOcurrences.formatData(objOcurrences.returnDate);
            }
        }
        
        return lstOcurrences;
        
    }
    
  
    
}