/*
* Autor: [Letícia Freitas] + [Deloitte]
* Data: [09/09/2019]
* Descrição: [Classe controller para a chamada via integração de protocolos móveis.]
*/

public class CEC_360_ProtocolsMobileController {
    Static Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    
    @AuraEnabled
    public static List<String> getAssets (string recordId){
        
        List<Asset> lstAsset = [Select ID,
                                Msisdn__c from
                                Asset where 
                                AccountId =: recordId
                               ];
        
        return formatAsset(lstAsset);
    }
      
    public static List<CEC_RestObjects.attendences> formatData(List<CEC_RestObjects.attendences> lst){
        
        List<Cec_RestObjects.attendences> lstAggrouped = new List<Cec_RestObjects.attendences> ();
        String numProtocol;
        
        for(integer i=0;i<lst.size();i++){
            string dateOpening = lst[i].solicitationDateOpening;
            string dateClosing = lst[i].solicitationDateClosing;
            CEC_RestObjects.attendences atd = new CEC_RestObjects.attendences();
            lst[i].solicitationDateOpening = dateOpening.substring(8,10) + '/' + dateOpening.subString(5,7)+ '/'+
                dateOpening.substring(0,4) +' as ' + dateOpening.substring(12,19);
            lst[i].solicitationDateClosing = dateClosing.substring(8,10) + '/' + dateClosing.subString(5,7)+ '/'+
                dateClosing.substring(0,4) +' as ' + dateClosing.substring(12,19);
        }
        
        return lst;
    }
    
   
    public static List<String> formatAsset (List<Asset> ast){
        List<String> astList = new List<String> ();
        
        for(integer i = 0; i < ast.size();i++){
            String msisdn = ast[i].Msisdn__c;
            astList.add(msisdn);
        }
        return astList;
    }
    
    @AuraEnabled
    public static List<CEC_RestObjects.attendences> getProtocolsNumber(string protocolNumber)
    {
         List<CEC_RestObjects.attendences> lstAttendences = new List<Cec_RestObjects.attendences> ();
        
       
         lstAttendences  = CEC_360_IntegrationMobileProtocols.getProtocolsNumber(protocolNumber);       
                   
        return formatData(lstAttendences);
    }
    
    
     @AuraEnabled
    public static List<CEC_RestObjects.attendences> getProtocolsData(string msisdn, 
                                                                 String startDate, String endDate)
    {
         List<CEC_RestObjects.attendences> lstAttendences = new List<Cec_RestObjects.attendences> ();
        if(!test.isRunningTest()){
             CEC_RestObjects.mobileSubscribers objSubs = CEC_360_IntegrationsSubscriberHistory.getSubscriber(msisdn);
        }
       
           lstAttendences  = CEC_360_IntegrationMobileProtocols.getProtocols(msisdn, startDate, endDate);       
        
            return formatData(lstAttendences);
    }
    
    @AuraEnabled
    public static List<CEC_RestObjects.attendences> generateMock (){
        
        List< CEC_RestObjects.attendences> lstAttendences = new List<CEC_RestObjects.attendences>();
        
        for(integer i =0; i < 5;i++){
            CEC_RestObjects.attendences objAttendences = new CEC_RestObjects.attendences();
            objAttendences.order = '1';
            objAttendences.protocolNumber = String.valueOf(i+100);
            objAttendences.interactionNumber = '322722520';
            objAttendences.action = 'C';
            objAttendences.solicitationType = 'REGISTRO SISTEMICO';
            objAttendences.solicitationDateClosing = '2019-05-10T15:43:44';
            objAttendences.solicitationDateOpening = '2019-05-10T15:43:44';
            objAttendences.solicitationStatus = 'Executada';
            objAttendences.channelRequestId = 'Internet';
            objAttendences.situation = 'ABERTO';
            objAttendences.reasonCode1 = '1';
            objAttendences.description = 'Teste.';
            objAttendences.slaIndicatorExceeded = 'false';
            lstAttendences.add(objAttendences);
        }
        
        return lstAttendences;
        
    }
    
    
    
}