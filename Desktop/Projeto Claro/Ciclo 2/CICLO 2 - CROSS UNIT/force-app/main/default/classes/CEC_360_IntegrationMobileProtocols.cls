/*
* Autor: [Letícia Freitas] + [Deloitte]
* Data: [28/05/2019]
* Descrição: [Nome do projeto/ID: CEC FASE 1 ] + [Time: SQUAD 360 - Sprint 6] +
[Classe controller para a chamada via integração de objetos.]
*/

public class CEC_360_IntegrationMobileProtocols {
    
    @AuraEnabled
    public static List<CEC_RestObjects.attendences> getProtocols(String msisdn, String startDate, String endDate)
    {
        Cec_RestObjects.Protocols objProtocols = new CEC_restObjects.Protocols ();
        List<Cec_RestObjects.attendences> lstAttendences =  new List<CEC_RestObjects.attendences>();
        CEC_RestObjects.mobileSubscribers objSubscriberAux = new  CEC_RestObjects.mobileSubscribers ();
        
        String service;
        if(!test.isRunningTest()){
            objSubscriberAux = CEC_360_IntegrationsSubscriberHistory.getSubscriber(msisdn);
            service = CEC_360_ServiceName.getServiceName('Interactions');
        }else{
            service = '/interactions';
        }
        
        try { 
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro'+ service +
                                '?customerCrmID='+objSubscriberAux.crmSubscriberId + 
                                '&page=1&limit=30&companyId=Movel'+
                                '&startDate=' + startDate + '&endDate=' + endDate);
            request.setMethod('GET');
            request.setTimeout(120000);
            
            HTTP http = new HTTP(); 
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            system.debug('responseBody'+responseBody.replace('/n',''));         
            
            objProtocols = (CEC_RestObjects.Protocols)JSON.deserialize(responseBody, CEC_RestObjects.Protocols.class);
            system.debug('ObjProtocols'+objProtocols);
            if(objProtocols.data != null)
                lstAttendences = objProtocols.data.attendances;
            system.debug('lstAtt'+lstAttendences);
            
        }
        catch(CalloutException e) {
            System.debug('ERROR: ' + e);
            
        }

        return lstAttendences;
    }    
    
    @AuraEnabled
    public static List<CEC_RestObjects.attendences> getProtocolsNumber(String protocolNumber)
    {
        Cec_RestObjects.Protocols objProtocols = new CEC_restObjects.Protocols ();
        List<Cec_RestObjects.attendences> lstAttendences =  new List<CEC_RestObjects.attendences>();
        String service;
        if(!test.isRunningTest()){
            service = CEC_360_ServiceName.getServiceName('Interactions');
        }else{
            service = '/interactions';
        }        
        
        try { 
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro'+ service +
                                '?protocolNumber='+protocolNumber+
                                '&companyId=Movel');
            request.setMethod('GET');
            request.setTimeout(120000);
            
            HTTP http = new HTTP(); 
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            system.debug('responseBody'+responseBody.replace('/n',''));
            
            objProtocols = (CEC_RestObjects.Protocols)JSON.deserialize(responseBody, CEC_RestObjects.Protocols.class);
            system.debug('ObjProtocols'+objProtocols);
            if(objProtocols.data != null)
            	lstAttendences = objProtocols.data.attendances;
            system.debug('lstAtt'+lstAttendences);
            
        }
        catch(CalloutException e) {
            System.debug('ERROR: ' + e);
            
        }
        
        return lstAttendences;
    }
    
    public static String formatData(String data){
        
        String dataAux;
        if(data != null){
            if(data.contains('T')){
                dataAux = data.substring(8,10) + '/' + data.substring(5,7) + '/' +
                    data.substring(0,4) + ' as ' + data.substring(11,16) ;
            }else{
                dataAux = data.substring(8,10) + '/' + data.substring(5,7) + '/' +
                    data.substring(0,4);
            }
        }
        else{
            dataAux='--';
        }
        return dataAux; 
    }    
    
    public static CEC_RestObjects.Protocols generateMock(){
        
        List<CEC_RestObjects.attendences> att = CEC_360_ProtocolsResidentialController.generateMock();
        CEC_RestObjects.dataProtocols dataProtocols = new CEC_RestObjects.dataProtocols();
        dataProtocols.attendances = att;
        CEC_RestObjects.Protocols protocols = new CEC_RestObjects.Protocols();
        protocols.apiVersion = '1';
        protocols.transactionId = '123456';
        protocols.data = dataProtocols;
        
        return protocols; 
    }   
    
}