public class CEC_CallOSGenericHandler {
    @AuraEnabled
    public static CEC_OmniScript__mdt getParametersByOmniscriptName (String omniscriptName) {
        CEC_OmniScript__mdt  mc = null;

        try {
         mc = [SELECT
               MasterLabel,
               strOmniScriptType__c,
               strOmniScriptSubType__c,
               strOmniScriptLang__c FROM CEC_OmniScript__mdt WHERE MasterLabel = :omniscriptName];
        } catch (Exception e) {
            system.debug('The following exception has occurred: ' + e.getMessage());
        }

        return mc;
    }
}