/* Autor: Danilo Fucuhara - Deloitte 
Criação: 20/05/2019
Descrição: Classe de conexão com a API de Alertas. 
Nome do projeto/ID: CEC FASE - Time: SQUAD 360.
* [19/07] - Danilo Fucuhara - Ajuste para utilizar credenciais nomeadas.
*/

public class CEC_360_IntegrationAlerts {
    
    public static CEC_RestObjects.AlertsMain getAlerts(String phoneLineNumber, String cpfCnpj, String recordType) { 
        CEC_RestObjects.AlertsMain alerts = new CEC_RestObjects.AlertsMain();
        ServiceParameter__c servParam = ServiceParameter__c.getValues('Alerts');
        String signatureType = null;
        String mobileSubscriberId = null;
        
        if(recordType == 'CECMovelPreControle') signatureType = 'CLARO_CARTAO';
        
        if(recordType == 'CECMovel') signatureType = 'CLARO_CONTA';
        
        if(recordType == 'CECMovelControle') signatureType = 'CLARO_CONTROLE';
        
        try {
            if(!Test.isRunningTest()) {
                mobileSubscriberId = CEC_360_IntegrationsSubscriberHistory.getMobileId(phoneLineNumber);
            }
            HTTPRequest request = new HTTPRequest();
            
            request.setEndpoint('callout:OAGClaro' + CEC_ServiceName__c.getValues('Alerts').ServiceName__c + 
                                '?'+ 'cpfCnpj=' + cpfCnpj + '&mobileAssinanteId=' + mobileSubscriberId +
                                '&signatureType=' + signatureType + '&phoneLineNumber=' + phoneLineNumber);
            
            request.setMethod('GET');
            request.setTimeout(120000);
  
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody);
            responseBody.replace('-', '_');
            
            alerts = (CEC_RestObjects.AlertsMain)JSON.deserialize(responseBody, CEC_RestObjects.AlertsMain.class);
            
            if(response.getStatusCode() != 201) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
            
        }catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return alerts;
    }
    
    public static CEC_RestObjects.AlertsMain generateMock() { 
        CEC_RestObjects.AlertsMain alertMain = new CEC_RestObjects.AlertsMain();
        alertMain.data = new CEC_RestObjects.DataAlert();
        alertMain.data.alerts = new List<CEC_RestObjects.Alert>();
        CEC_RestObjects.Alert alert = new CEC_RestObjects.Alert();
        
        alertMain.apiVersion = '1';
        alertMain.transactionId = '1';
        alert.alert_id = '1';
        alert.classification_alertaid = 'Assinante';
        alert.notes = 'Carência Upgrade';
        alert.value = 'VERDADEIRO';
        alertMain.data.alerts.add(alert);
        
        return alertMain;
    }
    
}