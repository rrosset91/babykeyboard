/* Autor: Letícia Freitas - Deloitte 
Criação: 13/06/2019.
Descrição: Classe de Integração para o servicos de Assinantes.
USS 18086.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360.
* [19/07] - Danilo Fucuhara - Ajuste para utilizar credenciais nomeadas.
*/


public class CEC_360_IntegrationsSubscriberHistory {
    
    public static string getMobileId (String msisdn){
        CEC_RestObjects.mobileSubscribersHistory mobileSubscribersHistoryMain = new CEC_RestObjects.mobileSubscribersHistory();
        String mobileSubscriberId;
        ServiceParameter__c servParam = ServiceParameter__c.getValues('Subscriber');
        try{
            HTTPRequest request = new HTTPRequest();
            
            request.setEndpoint('callout:OAGClaro' + CEC_ServiceName__c.getValues('Subscriber').ServiceName__c + 
                                '?'+ 'msisdn=' + msisdn + '&page=' + '1' + '&limit=' + '1');
            
            request.setMethod('GET');
            request.setTimeout(120000);
            
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody);
            
            mobileSubscribersHistoryMain = (CEC_RestObjects.mobileSubscribersHistory)JSON.deserialize(responseBody, CEC_RestObjects.mobileSubscribersHistory.class);
            
            mobileSubscriberId = mobileSubscribersHistoryMain.data.subscribers[0].mobileSubscriberId ;
            
            if(response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        } catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        
        return mobileSubscriberId;
    }
    
    public static CEC_RestObjects.mobileSubscribers getSubscriber(String msisdn){
        
        CEC_RestObjects.mobileSubscribersHistory mobileSubscribersHistoryMain = new CEC_RestObjects.mobileSubscribersHistory();
        
        try{
            HTTPRequest request = new HTTPRequest();
            system.debug('callout:OAGClaro' + CEC_ServiceName__c.getValues('Subscriber').ServiceName__c + 
                                '?'+ 'msisdn=' + msisdn + '&page=' + '1' + '&limit=' + '1');
            
            request.setEndpoint('callout:OAGClaro' + CEC_ServiceName__c.getValues('Subscriber').ServiceName__c + 
                                '?'+ 'msisdn=' + msisdn + '&page=' + '1' + '&limit=' + '1');
            request.setMethod('GET');
            request.setTimeout(120000);
            
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody);
            
            mobileSubscribersHistoryMain = (CEC_RestObjects.mobileSubscribersHistory)JSON.deserialize(responseBody, CEC_RestObjects.mobileSubscribersHistory.class);
            
            
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        } catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        
        
        return mobileSubscribersHistoryMain.data.subscribers[0];
        
        
    }
    
    public static CEC_RestObjects.mobileSubscribersHistory generateMock(){
        CEC_RestObjects.mobileSubscribersHistory mobileSubscribersHistoryMain = new CEC_RestObjects.mobileSubscribersHistory();
        CEC_RestObjects.dataSubscriber dataSubscriber = new CEC_RestObjects.dataSubscriber();
        List<CEC_RestObjects.mobileSubscribers> listMobileSubs = new List<CEC_RestObjects.mobileSubscribers>();
        CEC_RestObjects.mobileCustomer mobileCustomer = new  CEC_RestObjects.mobileCustomer();
        CEC_RestObjects.mobileDocuments mobileDocuments = new CEC_RestObjects.mobileDocuments();
        
        mobileDocuments.cpf ='42317802742';
        mobileCustomer.acrmCustomerId ='1234';
        mobileCustomer.businessName ='Businessname';
        mobileCustomer.companyName ='Companyname';
        mobileCustomer.type_Z ='TypeZ';
        mobileCustomer.crmCustomerId ='12345';
        mobileCustomer.crmCustomerSubType ='SubType';
        mobileCustomer.faId ='12345';
        mobileCustomer.mobileBan ='12345';
        mobileCustomer.mobileId ='11';
        mobileCustomer.mobileSubType ='SubType';
        mobileCustomer.name ='Name';
        mobileCustomer.documents = mobileDocuments;
        
        for(integer i =0;i<5;i++){
            CEC_RestObjects.mobileSubscribers mobileSubscriber = new CEC_RestObjects.mobileSubscribers();
            mobileSubscriber.cancellationDate ='10/05/2019';
            mobileSubscriber.comboType ='comboType';
            mobileSubscriber.crmSubscriberId ='12345';
            mobileSubscriber.customer = mobileCustomer;
            mobileSubscriber.name ='NameSubscriber'+i;
            listMobileSubs.add(mobileSubscriber);
        }
        dataSubscriber.subscribers = listMobileSubs;
        
        mobileSubscribersHistoryMain.apiVersion ='1';
        mobileSubscribersHistoryMain.transactionId ='1';
        mobileSubscribersHistoryMain.data = dataSubscriber;
        
        return mobileSubscribersHistoryMain;
    }
    
}