/**************************************************************************************************************
* IBM - Bluewolf
* @author           Jean Sganzerla (jean.sganzerla@ibm.com)
* Project:          Solar
* Description:      Classe que faz integração e monta o Wrapper para Invoice Events
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-12-14      Jean Sganzerla          class created 
**************************************************************************************************************/
public class Solar_Cross_InvoiceEvents {


    public static Map<String, List<Solar_Cross_InvoiceEvents.Event>> getEvents(String aOperatorCode, String aContractNumber, String aStartDate, String aEndDate){

        ServiceParameter__c lServParam = ServiceParameter__c.getValues('InvoiceEvents');
        HTTPRequest lRequest = new HTTPRequest();
        String strStartDate = aStartDate.removeEnd('-00:00');
        String strEndDate = aEndDate.removeEnd('-00:00');
        if(!Test.isRunningTest()){
            lRequest.setEndpoint('callout:OAGClaro'+ lServParam.EndPoint__c + 
            '?operatorCode=' + aOperatorCode + '&contractNumber=' + aContractNumber +'&startDate=' + strStartDate + '&endDate=' + strEndDate);
        }else{
            lRequest.setEndpoint('/InvoiceEvents');
        }
        

        lRequest.setMethod(lServParam.Method__c);
        lRequest.setTimeout(120000);
        String strUser  = lServParam.User__c;
        String strPassword = lServParam.Password__c;

        Blob headerValue = Blob.valueOf(strUser+ ':' + strPassword);
        String authorizationHeader = 'Basic ' +
        EncodingUtil.base64Encode(headerValue);
        System.debug('authorizationHeader: ' + authorizationHeader);
        lRequest.setHeader('Authorization',authorizationHeader);

        system.debug('INVOICE EVENTS ENDPOINT --------------->' + lRequest.getEndpoint());

        HTTP lHttp = new HTTP(); 
        HttpResponse lResponse = lHttp.send(lRequest);
		System.debug('events JSON: ' + lResponse.getBody());
        EventsWrapper events =  (EventsWrapper) JSON.deserialize(lResponse.getBody(), EventsWrapper.class);
        System.debug('events: ' + events);
        Map<String, List<Event>> mapEvent = new Map<String, List<Event>>();
        for(Event event:events.data.events){
            if(mapEvent.get(event.invoiceID) != null){
                mapEvent.get(event.invoiceID).add(event);
            }else{
                mapEvent.put(event.invoiceID, new List<Event>{event});
            }
        }
        System.debug('mapEvent: ' + mapEvent);
        return mapEvent;
    }

    public class EventsWrapper{
        public String apiVersion;
        public String transactionId;
        public Events data;
        
       // public EventsWrapper(){
           // data = new List<Event>();
       // }
    }

    public class Events {
        List<Event> events;
    }

    public class Event{
        @AuraEnabled
        public String invoiceID;
        @AuraEnabled
        public String invoiceStatusID;
        @AuraEnabled
        public String invoiceStatusDescription;
        @AuraEnabled
        public String criticalReasonID;
        @AuraEnabled
        public String criticalReasonDescription;
        @AuraEnabled
        public String eventDescription;
        @AuraEnabled
        public DateTime eventDate;

    }
}