public class CEC_360_Integrationdsar {
/* 	Autor: Rennê Silva - Sysmap
   	Criação: 18/06/2020
   	Descrição: Classe de conexão com as APIs do módulo dsar da OneTrust.
   	Nome do projeto/ID: LGPD - Direito do Titular
	Time: SQUAD CEC */
  
    
    public static CEC_360_LGPDIntegrationObjects.GetDsarByStatus getDsarByTypeAndStatusNotClosed(String cpf, String requestType) { 
        CEC_360_LGPDIntegrationObjects.GetDsarByStatus responseDsar = new CEC_360_LGPDIntegrationObjects.GetDsarByStatus();
        
        String clientAuth = '';
        String statuses = '';
        // GET params to authenticate in APIGEE and static parameters from OneTrust
        CEC_LGPD_Parameters__mdt params = [Select statuses__c,clientAuth__c from CEC_LGPD_Parameters__mdt where DeveloperName = 'ConfigDsar'];
        System.debug('params: ' + params);
        if(params != null){
        
            clientAuth = params.clientAuth__c;
            System.debug('clientAuth: ' + clientAuth);
            
            statuses = params.statuses__c;
            System.debug('statuses: ' + statuses);
        
        }else{
            System.debug('Parâmetros de configuração para chamada do GET anterior ao POST não foram cadastrados corretamente');
            return responseDsar;
        }
        
        String service;
        if(!Test.isRunningTest()){
            service = CEC_360_ServiceName.getServiceName('DSAR_PathToGetByTypeAndStatus');
        }else{
            service = '/dataprivacy/v1/customers/orders/status';
        }
        
        try {
            HTTPRequest request = new HTTPRequest();
            
            System.debug('callout:APIGEE_Claro' + service + '?' 
                       + 'language=en-us' + '&status=' + statuses + '&requestType=' + requestType);
            
            request.setEndpoint('callout:APIGEE_Claro' + service + '?' 
                              + 'language=en-us' + '&status=' + statuses + '&requestType=' + requestType);
            
            request.setMethod('GET');
            //request.setHeader('Accept-Encoding', 'keep-alive');
            //request.setHeader('Connection', 'gzip, deflate, br');
            request.setHeader('Accept','*/*');
       		request.setHeader('X-Client-Auth', clientAuth);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-QueryString','cpf='+cpf);
            
            request.setTimeout(120000);
 
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody);
            responseBody.replace('-', '_');
            
            responseDsar = (CEC_360_LGPDIntegrationObjects.GetDsarByStatus)JSON.deserialize(responseBody, CEC_360_LGPDIntegrationObjects.GetDsarByStatus.class);
            
            System.debug('response.getStatusCode(): ' + response.getStatusCode());
            
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        
        return responseDsar;
    }
    
    public static CEC_360_LGPDIntegrationObjects.PostDsar postDsar(String jsonBody){
        CEC_360_LGPDIntegrationObjects.PostDsar postResponse = new CEC_360_LGPDIntegrationObjects.PostDsar();
        
        String clientAuth = '';
        String templateId = '';
        // GET params to authenticate in APIGEE and static parameters from OneTrust
        CEC_LGPD_Parameters__mdt params = [Select templateId__c,clientAuth__c from CEC_LGPD_Parameters__mdt where DeveloperName = 'ConfigDsar'];
        System.debug('params: ' + params);
        if(params != null){
            
            clientAuth = params.clientAuth__c;
            System.debug('clientAuth: ' + clientAuth);
            
            templateId = params.templateId__c;
            System.debug('templateId: ' + templateId);
        
        }else{
            System.debug('Parâmetros de configuração para chamada do POST não foram cadastrados corretamente');
            return postResponse;
        }
            
        String serviceFirstPartPath;
        if(!Test.isRunningTest()){
            serviceFirstPartPath = CEC_360_ServiceName.getServiceName('DSAR_FirstPartPathToPost');
        }else{
            serviceFirstPartPath = '/dataprivacy/v1/customers/templates/';
        }
        
        String serviceLastPartPath;
        if(!Test.isRunningTest()){
            serviceLastPartPath = CEC_360_ServiceName.getServiceName('DSAR_LastPartPathToPost');
        }else{
            serviceLastPartPath = '/forms';
        }
        
        String service = serviceFirstPartPath + templateId + serviceLastPartPath;
        
        try {

            HTTPRequest request = new HTTPRequest();
            
            System.debug('callout:APIGEE_Claro' + service);
            request.setEndpoint('callout:APIGEE_Claro' + service); 
          
            request.setMethod('POST');
            request.setHeader('Accept','*/*');
       		request.setHeader('X-Client-Auth', clientAuth);
            request.setHeader('Content-Type', 'application/json');
            
            request.setBody(jsonBody);
            request.setTimeout(120000);
  
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody);
            responseBody.replace('-', '_');
            
            postResponse = (CEC_360_LGPDIntegrationObjects.PostDsar)JSON.deserialize(responseBody, CEC_360_LGPDIntegrationObjects.PostDsar.class);
            
            if(response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return postResponse;
    }
    
    /*public static CEC_RestObjects.GetDsarByStatus generateMock() { 
        CEC_RestObjects.GetDsarByStatus response = new CEC_RestObjects.GetDsarByStatus();
        // complete JSON
        response = (CEC_RestObjects.GetDsarByStatus)JSON.deserialize('{"apiversion":"1; 2020-06-11","transactionId":"e6e4e0f4-089d-4194-845e-78f45426f7c7","customerOrders":[{"id":"SL244HWD6D","orderDate":"2019-08-09T12:49:47.983Z","completionDate":"2019-08-09T12:49:47.983Z","orderType":"Atualização de dados","status":"Aberto"}]}', CEC_RestObjects.GetDsarByStatus.class);
        
        // without customer orders
        //response = (CEC_RestObjects.GetDsarByStatus)JSON.deserialize('{"apiVersion": "1;2020-06-29","transactionId": "b654df01-5a7c-49d1-9bb6-40303e826b6f","customerOrders": []}', CEC_RestObjects.GetDsarByStatus.class);
        
        return response;
    }
    
    public static CEC_RestObjects.PostDsar generateMockPost() { 
        CEC_RestObjects.PostDsar postDsar = new CEC_RestObjects.PostDsar();
        postDsar = (CEC_RestObjects.PostDsar)JSON.deserialize('{"apiVersion":"1;2020-06-11","transactionId":"e6e4e0f4-089d-4194-845e-78f45426f7c7","data":{"approver":"Test User","countryCode":"DZ","countryName":"Italy","dateCompleted":"2019-05-31T12:43:24.173Z","dateCreated":"2019-08-09T12:49:47.983Z","dateUpdated":"2019-09-25T06:50:15.470Z","deadline":"2019-09-08T12:49:47.920Z","email":"testuser@onetrust.com","protocolNumber":"Test","isExtended":false,"language":"en-us","cpf":"User","organization":"Test organization","requestQueueId":"e2d0f59e-3df0-4b1f-965d-d57547ed44ad","requestQueueRefId":"SL244HWD6D","requestTypes":["Data Portability, Update Data"],"resolution":"Not a privacy-related request","status":"NEW","subjectTypes":["Student"],"webform":"Webform 1","workflow":"Default Workflow"}}', CEC_RestObjects.PostDsar.class);
        return postDsar;
    }*/
    
}