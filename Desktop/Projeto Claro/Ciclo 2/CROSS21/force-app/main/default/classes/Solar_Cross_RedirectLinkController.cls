/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Solar_Cross_RedirectLink (Aura) Controller
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-19      Jean Sganzerla          class created 
**************************************************************************************************************/
public class Solar_Cross_RedirectLinkController {
    @AuraEnabled
    public static List<PicklistWrapper> picklistValues(){
        List<PicklistWrapper> pickListValuesList= new List<PicklistWrapper>();

        Schema.DescribeFieldResult fieldResult = Parameters__c.Icons__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            PicklistWrapper lValue = new PicklistWrapper(pickListVal.getLabel(),pickListVal.getValue());
            pickListValuesList.add(lValue);
        }    
        return pickListValuesList;    
    }

    @AuraEnabled
    public static void setRecordIcon(String aRecordId, String aIcon){
        List<Parameters__c> lParameterLst = [SELECT Id FROM Parameters__c WHERE Id = :aRecordId];
        lParameterLst[0].Icons__c = aIcon;
        update lParameterLst;
    }

    @AuraEnabled
    public static String getRecordIcon(String aRecordId){
        List<Parameters__c> lParameterLst = [SELECT Id, Icons__c FROM Parameters__c WHERE Id = :aRecordId];
        return lParameterLst[0].Icons__c;
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