public class CEC_360_ShowOccurrencesController {
    
    
    @AuraEnabled
    public static String getContractNumberBillingAccount(String recordId) {
        Account acc = [SELECT ContractNumber__c 
                       FROM Account 
                       WHERE Id =: recordId];
        
        return acc.ContractNumber__c;
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