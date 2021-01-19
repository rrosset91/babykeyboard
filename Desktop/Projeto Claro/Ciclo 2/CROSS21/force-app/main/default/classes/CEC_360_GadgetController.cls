/* Autor: Danilo Fucuhara - Deloitte 
Criação: 22/03/2019
Descrição:Classe para interfacear a busca via integração de Dispositivos. 
Nome do projeto/ID: CEC FASE - Time: SQUAD 360. */

public class CEC_360_GadgetController {
    @AuraEnabled
    public static CEC_RestObjects.Device getDevice(String recordId) {
        CEC_RestObjects.subscriberLastDeviceResponse subscriberObj = new CEC_RestObjects.subscriberLastDeviceResponse();
        CEC_RestObjects.Device device = new CEC_RestObjects.Device();
        Asset record = [SELECT Id, MSISDN__c FROM Asset WHERE Id = :recordId];
        system.debug('msisdn'+record.MSISDN__c);
        if(record.MSISDN__c != null) {
           
            if(!test.isRunningTest()){
                device = CEC_360_IntegrationDevices.getDevice(record.msisdn__c);
                system.debug(device);
            }
        }
        return device;
    }
    
}