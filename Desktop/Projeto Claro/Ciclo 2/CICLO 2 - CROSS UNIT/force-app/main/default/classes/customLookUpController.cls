/* Autor: Danilo Fucuhara - Deloitte 
Criação: 06/05/2019
Descrição: Classe controller para o componente customLookup.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360 */

public class customLookUpController  {
    @AuraEnabled
    public static List<sObject> fetchLookUpValues(String searchKeyWord, String ObjectName, String field) {
        String searchKey = searchKeyWord + '%';
        
        List<sObject> returnList = new List<sObject>();
 
        String sQuery =  'SELECT Id, MasterLabel, CodigoOperadora__c FROM ' + ObjectName + ' WHERE ' + field + ' LIKE: searchKey limit 5';
        List<sObject> lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}