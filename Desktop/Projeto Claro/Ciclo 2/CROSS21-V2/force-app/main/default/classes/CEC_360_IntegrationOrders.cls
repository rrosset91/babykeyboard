/*
* Autor: [Letícia Freitas] + [Deloitte]
* Data: [27/08/2019]
* Descrição: [Nome do projeto/ID: CEC FASE 1 ] + [Time: SQUAD 360 - Sprint 11] +
* [Classe apex para a chamada via integração de objetos.]
*--------------------------------------------------------------------------------*
*/


public class CEC_360_IntegrationOrders {
    
    @AuraEnabled
    public static List<CEC_RestObjects.Order> getOrders(String contractNumber, String operatorCode,
                                                        String startDate, String endDate)
    {
        Cec_RestObjects.ServiceOrder objOrders = new CEC_RestObjects.ServiceOrder();
        
        List<Cec_RestObjects.Order> lstOrders =  new List<CEC_RestObjects.Order>();
        String service;
        if(!Test.isRunningTest()){
            service = CEC_360_ServiceName.getServiceName('WorkOrders');
        }else{
            service = '/workorderschedules';
        }
                
        
        try { 
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGNetCorp'+ service +
                                '?isProtocolLimit=false'+'&contractNumber='+ contractNumber + 
                                '&cityId=' +operatorCode + 
                                '&startDate=' + startDate + '&endDate=' + endDate);
            
            request.setMethod('GET');
            request.setTimeout(120000);
            
            HTTP http = new HTTP(); 
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            system.debug('responseBody'+responseBody);
            system.debug(response.getStatus());
            if(response.getStatusCode() == 200){
                objOrders = (CEC_RestObjects.ServiceOrder)JSON.deserialize(responseBody, CEC_RestObjects.ServiceOrder.class);
                lstOrders = objOrders.data.orders;
               }
            
        }
        catch(CalloutException e) {
            System.debug('ERROR: ' + e);
            
        }
        
        return lstOrders;
    } 
    
    @AuraEnabled
    public static List<CEC_RestObjects.Order> getOrdersNumber(String protocolNumber, String operatorCode)
    {
        Cec_RestObjects.ServiceOrder objOrders = new CEC_RestObjects.ServiceOrder();
        
        List<Cec_RestObjects.Order> lstOrders =  new List<CEC_RestObjects.Order>();
         String service;
        if(!Test.isRunningTest()){
            service = CEC_360_ServiceName.getServiceName('WorkOrders');
        }else{
            service = '/workorderschedules';
        }
        
        try { 
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGNetCorp'+ service +
                                '?protocolNumber='+ protocolNumber + 
                                '&cityId=' +operatorCode + '&limit=1' );
            
            request.setMethod('GET');
            request.setTimeout(120000);
            
            HTTP http = new HTTP(); 
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            system.debug('responseBody'+responseBody.replace('/n',''));
            if(response.getStatusCode() == 200){
                objOrders = (CEC_RestObjects.ServiceOrder)JSON.deserialize(responseBody, CEC_RestObjects.ServiceOrder.class);
                lstOrders = objOrders.data.orders;
            }
            
        }
        catch(CalloutException e) {
            System.debug('ERROR: ' + e);
            
        }
        
        return lstOrders;
    } 
    
    
    
    
    
    public static CEC_RestObjects.serviceOrder generateMock(){
        
        CEC_RestObjects.serviceOrder order = new CEC_RestObjects.serviceOrder();
        order.apiVersion = '1';
        order.transactionId = '12345';
        CEC_RestObjects.ServiceOrderData dataOrder = new CEC_RestObjects.ServiceOrderData();
        
        List <CEC_RestObjects.Order> lstOrder = new List<CEC_RestObjects.Order> ();
        for(integer i = 0; i<5; i++){
            CEC_RestObjects.Order objOrder = new CEC_RestObjects.Order();
            objOrder.attendenceDate = '2016-01-01T15:00:59';
            objOrder.cityId = '06135' + i;
            objOrder.contractNumber = '123456';
            objOrder.description = 'Visita técnica.';
            objOrder.eventDate = '2016-01-01';
            objOrder.isExempt = 'true';
            objOrder.note = 'Teste';
            ObjOrder.typeDescription = 'Serviço';
            ObjOrder.orderId = '12345';
            objOrder.status = 'Concluído.';
            objOrder.terminationDate = '2016-01-01T16:00:00';
            objOrder.showDetails = false;
            objOrder.attendenceDate = formatData (objOrder.attendenceDate);
            objOrder.terminationDate = formatData (objOrder.terminationDate);
            objOrder.eventDate = formatData (objOrder.eventDate);
            lstOrder.add(objOrder);
        }
        
       dataOrder.orders = lstOrder;
       order.data = dataOrder;
        
       return Order;
        
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
    
    
}