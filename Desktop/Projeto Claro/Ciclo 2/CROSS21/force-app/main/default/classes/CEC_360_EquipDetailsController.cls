public class CEC_360_EquipDetailsController {
    @AuraEnabled
   public static CEC_RestObjects.Device getDevices(String recordId) {
        CEC_RestObjects.Device dev = new CEC_RestObjects.Device();
        String msisdn = [SELECT MSISDN__c FROM Asset WHERE Id =: recordId].MSISDN__c;
        if(msisdn != null) {
            dev = CEC_360_IntegrationDevices.getDevice(msisdn);
        }
        return dev;
    }
}