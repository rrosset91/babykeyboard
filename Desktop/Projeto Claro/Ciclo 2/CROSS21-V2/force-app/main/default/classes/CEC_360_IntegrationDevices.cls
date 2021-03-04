/* Autor: Letícia Freitas - Deloitte 
* Criação: 15/02/2018 
* Descrição: Nome do projeto/ID: CEC FASE - Time: SQUAD 360 
* USS 199 -  Classe para buscar as informações de ativo via integração REST baseado no campo msisdn__c - Ativo*/

public class CEC_360_IntegrationDevices {
    
    public static CEC_RestObjects.Device getDevice(String phoneLineNumber) { 
        CEC_RestObjects.subscriberLastDeviceResponse subscriberDevice = new CEC_RestObjects.subscriberLastDeviceResponse();
        CEC_RestObjects.Device objDevice = new CEC_RestObjects.Device();
         String service;
            if(!Test.isRunningTest()){
                service = CEC_360_ServiceName.getServiceName('Devices');
            }else{
                service = '/subscriberlastdevice';
            }
        
        try { 
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro'+ service + '?phoneLineNumber=' + phoneLineNumber);
            request.setMethod('GET');
            request.setTimeout(120000);
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            system.debug('Body'+responseBody);
            subscriberDevice = (CEC_RestObjects.subscriberLastDeviceResponse)JSON.deserialize(responseBody, CEC_RestObjects.subscriberLastDeviceResponse.class);
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            }
            
            if(subscriberDevice != null){
                objDevice = subscriberDevice.data.device; 
                objDevice = CEC_360_IntegrationDevices.formatData(objDevice);
                objDevice = CEC_360_IntegrationDevices.formatEmptyFields(objdevice);
            }
            
        } catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        
        return objDevice;
        
    }
    
    public static CEC_RestObjects.Device formatData (CEC_RestObjects.Device device){
        if(String.isBlank(device.deviceStatusDate) == false ){
            String dateAux = device.deviceStatusDate.subString(8,10)+ '/' + device.deviceStatusDate.subString(5,7) + '/'+
                device.deviceStatusDate.substring(0,4);
            device.deviceStatusDate = dateAux;
        }
        return device;
    }
    
    
    
    public static Cec_RestObjects.Device formatEmptyFields(CEC_RestObjects.Device device)
    {
        if(!String.isBlank(device.frequencies[0].modelFrequencyGenerationTechnology))
        {
            device.frequencymodelGenerationTechnology = device.frequencies[0].modelFrequencyGenerationTechnology;
            system.debug('Frequency'+device.frequencymodelGenerationTechnology);
        }
        if(String.isBlank(device.iccid)){
            device.iccid = 'Não possui.';
        }
        
        if(String.isBlank(device.imei)){
            device.imei = 'Não possui.';
        }
        if(String.isBlank(device.modelName)){
            device.modelName = 'Não possui.';
        }
        if(String.isBlank(device.modelTechnology)){
            device.modelTechnology = 'Não possui.';
        }
        
        if(String.isBlank(device.manufacturerName)){
            device.manufacturerName = 'Não possui.';
        }
        
        if(String.isBlank(device.deviceStatus)){
            device.deviceStatus = 'Não possui.';
        }
        
        
        
        if(String.isBlank(device.deviceStatusReason)){
            device.deviceStatusReason = 'Não possui.';
        }
        
        if(String.isBlank(device.serviceOperator)){
            device.serviceOperator = 'Não possui.';
        }
        
        
        if(String.isBlank(device.frequencymodelGenerationTechnology)){
            device.frequencymodelGenerationTechnology = 'Não possui.';
        }
        
        return device;
    }
    
    public static CEC_RestObjects.subscriberLastDeviceResponse generateMock() {
        CEC_RestObjects.subscriberLastDeviceResponse subscriberObj = new CEC_RestObjects.subscriberLastDeviceResponse();
        CEC_RestObjects.dataDevice dataDeviceObj = new Cec_RestObjects.dataDevice();
        CEC_RestObjects.Device device = new CEC_RestObjects.Device();
        CEC_RestObjects.Frequencies frequency = new Cec_RestObjects.Frequencies();
        frequency.modelFrequencyGenerationTechnology = '850 MHZ';
        frequency.modelGenerationTechnology = '3G';
        
        device.phoneLineNumber = '11 981277410';
        device.iccid = '8992101200003204510';
        device.imei = '352279018335277';
        device.modelName = 'Nokia N95';
        device.modelTechnology = '';
        device.frequencies = new List <Cec_RestObjects.Frequencies> ();
        device.frequencies.add(frequency);
        device.manufacturerName = 'NOKIA';
        device.deviceStatus = 'LIBERADO';
        device.deviceStatusDate = '2010-01-01';
        device.deviceStatusReason = '';
        device.serviceOperator = 'Claro';
        device.deviceSoldByClaro = 'true';
        device.directSale = 'true';
        device.frequencymodelGenerationTechnology = 'DESCONHECIDO';
        device = CEC_360_IntegrationDevices.formatData(device);
        device = CEC_360_IntegrationDevices.formatEmptyFields(device);
        dataDeviceObj.device = device;
        subscriberObj.data = dataDeviceObj;
        return subscriberObj;
        
    }
    
    public static CEC_RestObjects.Device generateMockBlank() {
        CEC_RestObjects.Device device = new CEC_RestObjects.Device();
        CEC_RestObjects.Frequencies frequency = new Cec_RestObjects.Frequencies();
        frequency.modelFrequencyGenerationTechnology = '850 MHZ';
        frequency.modelGenerationTechnology = '3G';
        
        device.phoneLineNumber = '11 981277410';
        device.iccid = '';
        device.imei = '';
        device.modelName = '';
        device.modelTechnology = '';
        device.frequencies = new List <Cec_RestObjects.Frequencies> ();
        device.frequencies.add(frequency);
        device.manufacturerName = '';
        device.deviceStatus = '';
        device.deviceStatusDate = '2010-01-01';
        device.deviceStatusReason = '';
        device.serviceOperator = '';
        device.deviceSoldByClaro = 'true';
        device.directSale = 'true';
        device.frequencymodelGenerationTechnology = '';
        
        
        device = CEC_360_IntegrationDevices.formatEmptyFields(device);
        return device;
        
    }
    
    
}