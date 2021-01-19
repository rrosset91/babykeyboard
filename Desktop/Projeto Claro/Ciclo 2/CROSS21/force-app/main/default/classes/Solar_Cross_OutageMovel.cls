/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-04-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-30-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class  Solar_Cross_OutageMovel{

    @AuraEnabled
    public static Map<String,Object> getOutagesMobile(String recordId){ 
        System.debug('Entrou aqui no mobile outage');
        Map<String, Object> data = new Map<String, Object>();
        Case objCase = [SELECT Id, ContractBillingAccount__r.ContractNumber__c,ContractBillingAccount__r.CityCode__c,ContractBillingAccount__r.ContractReferenceNumber__c FROM Case WHERE Id =: recordId LIMIT 1];
        String msisdn = objCase.ContractBillingAccount__r.ContractNumber__c;

       
        ServiceParameter__c metaParameter = ServiceParameter__c.getInstance('MobileOutages');
        String strUser  = metaParameter.User__c;
        String strPassword = metaParameter.Password__c;

        Blob headerValue = Blob.valueOf(strUser+ ':' + strPassword);
        String authorizationHeader = 'Basic ' +
        EncodingUtil.base64Encode(headerValue);
        System.debug('authorizationHeader: ' + authorizationHeader);

        Map<String,String> queryParams = new Map<String,String>{'msisdn' => msisdn};
        Map<String, String> headerParams = new Map<String,String>{'Authorization'=> authorizationHeader};

        Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', queryParams, headerParams, 'MobileOutages');

        if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
            MobileOutagesJSON mobileOutages = (MobileOutagesJSON) JSON.deserialize(calloutResponse.get('response'),MobileOutagesJSON.class);
            System.debug('mobileOutages: ' + mobileOutages);
            if(mobileOutages.data != null){
                Outage objOut = new Outage();
                objOut.isInOutage = mobileOutages.data.impact;
                objOut.prevision = mobileOutages.data.expectedRegularizationDt != null ? convertDate(mobileOutages.data.expectedRegularizationDt): null;
                data.put('success',true);
                data.put('outage',objOut);
            }else{
                data.put('success', true);
			    data.put('message', Label.Solar_Cross_IntegrationNoData);
            }
        }else {
			data.put('success', false);
			data.put('message', Label.Solar_Cross_IntegrationErrorMessage + '\n'+'Código do Erro: ' + calloutResponse.get('statusCode') + ' | ' +  metaParameter.EndPoint__c.subStringAfter(':'));
        }
        return data;
    }

    public static Datetime convertDate(String strDate){
        List<String> dateAndHour = strDate.split('T');
        List<String> yearMonthDay = dateAndHour[0].split('-');
        List<String> HourTimeZone = dateAndHour[1].split('-');
        List<String> HourMinSec = HourTimeZone[0].split(':');

        Datetime returnDateTime = Datetime.newInstanceGMT(Integer.valueof(yearMonthDay[0]),Integer.valueof(yearMonthDay[1]),Integer.valueof(yearMonthDay[2]),Integer.valueof(HourMinSec[0]),Integer.valueof(HourMinSec[1]),Integer.valueof(HourMinSec[2]));
        return returnDateTime;
    }

    public class Outage{
        @AuraEnabled
        public Boolean isInOutage;
        @AuraEnabled
        public Datetime prevision;
    }
}