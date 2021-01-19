/*
* Autor:Letícia Freitas.
* Data: 26/06/2019
* [Claro Visão 360] [Time: SQUAD 360]
* Descrição: [USS 202 - Sprint 8] - Classe de integração para o serviço usageMobile.
* ------------------------------------- Alterações -----------------------------------
* Data: 19-07-2019.
* Letícia Freitas.
* [Descrição]: Alterado para credencial nomeada. 
* 
*/

public class CEC_360_IntegrationsMobileUsage {
    
    public static CEC_RestObjects.mobileUsage getMobileUsage (string phoneLineNumber){
        CEC_RestObjects.mobileUsage objMobileUsage = new CEC_RestObjects.mobileUsage();
         
        try { 
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro'+ CEC_ServiceName__c.getValues('UsageMobiles').ServiceName__c 
                                +'?phoneLineNumber='+phoneLineNumber);
            request.setMethod('GET');
            request.setTimeout(120000);
            System.debug('REQUEST: ' + request);
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('RESPONSE: ' + responseBody);
            
            
            objMobileUsage = (CEC_RestObjects.mobileUsage)JSON.deserialize(responseBody, CEC_RestObjects.mobileUsage.class);
            
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
            } else {
                System.debug(response.getBody());
            }
        } catch(CalloutException e) {
            System.debug('ERROR: ' + e);
        }
        return objMobileUsage;
    } 
    
    public static CEC_RestObjects.mobileUsage generateMock (){
        List<CEC_RestObjects.usageDetail> lstUsageDetail = new List <CEC_RestObjects.usageDetail>();
        CEC_RestObjects.mobileUsageData objMobileUsageDate = new CEC_RestObjects.mobileUsageData();
        CEC_RestObjects.mobileUsage objMobileUsage = new CEC_RestObjects.mobileUsage ();
        objMobileUsage.apiVersion = '1';
        objMobileUsage.transactionId = '1000';
        
        for (integer i =0; i < 5;i++){
            CEC_RestObjects.usageDetail objUsageDetail = new CEC_RestObjects.usageDetail();
            objUsageDetail.consumedAmount = '10737418240';
            objUsageDetail.franchiseAmount = '16106127360';
            objUsageDetail.unitMeasure = 'Bytes';
            objUsageDetail.descriptionUsage = 'Franquia '+i;
            objUsageDetail.usageDateEnd = '2009-01-12T12:10:30-03:00';
            objUsageDetail.usageDateStart = '2009-01-12T12:10:30-03:00';
            lstUsageDetail.add(objUsageDetail);
        }
        
        
        objMobileUsageDate.usages = lstUsageDetail;
        objMobileUsage.data =  objMobileUsageDate;
        
        return  objMobileUsage;
    }
    
}