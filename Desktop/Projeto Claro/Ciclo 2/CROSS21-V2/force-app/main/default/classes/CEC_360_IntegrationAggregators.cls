//<!-- CEC_360_IntegrationAggregators -->
//<!-- Autor: Danilo Fucuhara - Deloitte -->
//<!-- Criação: 06/06/2019 -->
//<!-- Descrição: Classe de de integração da API de Aggregators -->
//<!-- Nome do projeto/ID: CEC FASE - Time: SQUAD 360 -->
//* [06/08] - Danilo Fucuhara - Ajuste para nova versão de swagger.

public class CEC_360_IntegrationAggregators {
    
    public static CEC_RestObjects.SubscriberVasMain getAggregators(String msisdn, String startDate, String endDate, String status) { 
        CEC_RestObjects.SubscriberVasMain aggregators = new CEC_RestObjects.SubscriberVasMain();
        String service;
        if(!Test.isRunningTest()){
            CEC_360_serviceName__mdt  serviceName = [Select Id, ServiceName__c from CEC_360_serviceName__mdt  where DeveloperName = 'Aggregators'];
            service = serviceName.ServiceName__c;
        }else{
            service = '/agregator';
        }

        try { 
            HTTPRequest request = new HTTPRequest();
            
            String endpoint = 'callout:OAGClaro' + service + '?msisdn=' + msisdn;
            
            if(startDate != null) {
                endpoint = endpoint + '&effectiveDate=' + startDate + 'T00:00:00.000-00:00';
            }
            
            if(endDate != null) {
                endpoint = endpoint + '&effectiveEndDate=' + endDate + 'T00:00:00.000-00:00';
            }
            
            if(status != null) {
                endpoint = endpoint + '&status=' + status.toUpperCase();
            }
                
            request.setEndpoint(endpoint);
            System.debug('ENDPOINT: ' + request.getEndpoint());

            request.setMethod('GET');
            request.setTimeout(120000);
            
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody);
            
            aggregators = (CEC_RestObjects.SubscriberVasMain)JSON.deserialize(responseBody, CEC_RestObjects.SubscriberVasMain.class);
            aggregators = CEC_360_IntegrationAggregators.formatAggregators(aggregators);
            
            if(response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return aggregators;
    }
    
    public static CEC_RestObjects.SubscriberVasMain formatAggregators(CEC_RestObjects.SubscriberVasMain aggregators) {
        if(aggregators != null && aggregators.data != null && aggregators.data.subscribersVas != null) {
            for(CEC_RestObjects.SubscriberVasResponse s : aggregators.data.subscribersVas) {
                if(s.cancellationDate != null) {
                    Datetime dt1 = (DateTime)JSON.deserialize('"' + s.cancellationDate + '"', DateTime.class);
                    s.cancellationDate = String.valueOf(dt1.format('dd/MM/yyyy', 'America/Sao_Paulo'));
                }
                
                if(s.confirmationDate != null) {
                    Datetime dt2 = (DateTime)JSON.deserialize('"' + s.confirmationDate + '"', DateTime.class);
                    s.confirmationDate = String.valueOf(dt2.format('dd/MM/yyyy', 'America/Sao_Paulo'));
                }
                
                if(s.expirationDate != null) {
                    Datetime dt3 = (DateTime)JSON.deserialize('"' + s.expirationDate + '"', DateTime.class);
                    s.expirationDate = String.valueOf(dt3.format('dd/MM/yyyy', 'America/Sao_Paulo'));
                }
                
                if(s.amount != null) {
                    s.amount = formatValor(s.amount);
                }
            }
        }
        return aggregators;
    }
    
    public static String formatValor(String value) {
        value = 'R$ ' + value.replace('.', ',');
        if(value.substringAfter(',').length() < 2)
            value = value + '0';
        
        if(value.substringAfter(',').length() > 2)
            value = value.substringBefore(',') + ',' + value.substringAfter(',').substring(0, 2);
        return value;
    }
    
    /*public static CEC_RestObjects.SubscriberVasMain generateMock() {
		CEC_RestObjects.SubscriberVasMain aggMain = new CEC_RestObjects.SubscriberVasMain();
        aggMain.data = new CEC_RestObjects.DataSubscriberVas();
        aggMain.data.subscribersVas = new List<CEC_RestObjects.SubscriberVasResponse>();
        
        CEC_RestObjects.SubscriberVasResponse subs = new CEC_RestObjects.SubscriberVasResponse();
       
        DateTime confirmationDate = system.now();
        DateTime cancellationDate = system.now();
        DateTime expirationDate = system.now();      
       

        
        for(Integer i = 0; i < 35; i++)
        {          
            
            subs.serviceName = 'Nome do Serviço ' + i;
            subs.serviceAggregatorName = 'Nome do Serviço agregado';
            //subs.aggregatorName = 'Nome do Agregador';
            subs.msisdn = '17112341234';
            subs.status = 'Ativo';
            subs.serviceType = 'Minuto';
            subs.statusDate = '2009-01-12T12:10:30-03:00';
            subs.statusReasonDescription = 'Nome do serviço';
            subs.effectiveDate = '2009-01-12T12:10:30-03:00';
            subs.expirationDate = string.valueOf(expirationDate.format('dd/MM/yyyy'));
            subs.requestDescription = 'requestDescription ' + i;
            subs.amount = 'R$ 10,50';
            subs.confirmationDate = string.valueOf(confirmationDate.format('dd/MM/yyyy'));
            subs.confirmationCode = '2009-01-12T12:10:30-03:00';
            subs.cancellationDate = string.valueOf(cancellationDate.format('dd/MM/yyyy')); 
            subs.cancellationCode ='2009-01-12T12:10:30-03:00'; 
            subs.lastRateDate = '2009-01-12T12:10:30-03:00';
            subs.solicitationDate = '2009-01-12T12:10:30-03:00';

            aggMain.data.subscribersVas.add(subs);
        }
        
        return aggMain;
    }*/
}