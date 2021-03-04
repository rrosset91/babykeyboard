/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      CEC_ME_RedirecLinkClaro (Aura) Controller
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-18      Jean Sganzerla          class created 
**************************************************************************************************************/
public class CEC_ME_RedirecLinkClaroController {

    private static final Id LINK_RECTYPE = SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('Solar_Cross_Links').getRecordTypeId();
    
    @AuraEnabled
    public static List<PicklistWrapper> picklistValues(){
        List<PicklistWrapper> pickListValuesList= new List<PicklistWrapper>{new PicklistWrapper('Todos','Todos')};

        Schema.DescribeFieldResult fieldResult = Parameters__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            PicklistWrapper lValue = new PicklistWrapper(pickListVal.getLabel(),pickListVal.getValue());
            pickListValuesList.add(lValue);
        }    
        return pickListValuesList;    
    }

    @AuraEnabled
    public static ParametersWrapper getParameterRecords(String aTypeFilter, String aRecordId){
        ParametersWrapper lReturn = new ParametersWrapper();
        String lTypeFilter;
        if(aTypeFilter == 'Todos'){
            List<CEC_ME_RedirecLinkClaroController.PicklistWrapper> lPicklistValues = CEC_ME_RedirecLinkClaroController.picklistValues();
            for(Integer i = 0; i < lPicklistValues.size(); i++){
                lTypeFilter = i == 0 ? '\'' + lPicklistValues[i].value +'\'' : lTypeFilter + '\'' + lPicklistValues[i].value + '\'' ;
                lTypeFilter = lPicklistValues.size() == i+1 ? lTypeFilter : lTypeFilter + ', ';
            }
        }
        else{
            lTypeFilter = '\'' + aTypeFilter + '\'';
        }
        system.debug('lTypeFilter ' + lTypeFilter);

        String lJourney;
        if(aRecordId != null && aRecordId.startsWithIgnoreCase('500')){
            Case lCase = [SELECT RecordType.DeveloperName, RecordType.Name FROM Case WHERE Id = :aRecordId]; 
            lJourney = lCase.RecordType.DeveloperName;
            lReturn.lJourney = lCase.RecordType.Name;  
            lJourney =  '\'' + lJourney + '\'';         
            system.debug('lJourney ' + lJourney);
        }
        
        String lQuery = 'SELECT Id, Name, Icons__c, Link__c, Type__c FROM Parameters__c WHERE RecordTypeId = :LINK_RECTYPE AND Active__c = true ';
        if(lJourney != null){
            lQuery += 'AND Journey__c INCLUDES (' + lJourney + ') ';
        }
        lQuery += 'AND Type__c INCLUDES (' + lTypeFilter + ') ';
        lQuery += 'ORDER BY Name ASC';
        
        lReturn.lParametersLst = Database.query(lQuery);
        system.debug('lReturn.lParametersLst ' + lReturn.lParametersLst);
        return lReturn;
    }

    public class ParametersWrapper{
        @AuraEnabled public String lJourney;
        @AuraEnabled public List<Parameters__c> lParametersLst;

        public ParametersWrapper(){
            lParametersLst = new List<Parameters__c>();
        }
    }    

    public class PicklistWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public PicklistWrapper(String aLabel, String aValue){
            label = aLabel;
            value = aValue;
        }
    }    
}