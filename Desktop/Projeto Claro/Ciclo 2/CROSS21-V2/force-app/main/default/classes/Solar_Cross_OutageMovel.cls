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

    public static Outage globalOutage = new Outage();
    public static Map<String, Object> data = new Map<String, Object>();

    @AuraEnabled
    public static Map<String,Object> getOutagesMobile(String recordId){ 
        System.debug('Entrou aqui no mobile outage');
        Case objCase = [SELECT Id,ContractBillingAccount__c, ContractBillingAccount__r.ContractNumber__c,ContractBillingAccount__r.CityCode__c,ContractBillingAccount__r.ContractReferenceNumber__c FROM Case WHERE Id =: recordId LIMIT 1];
        
      //  String msisdn = objCase.ContractBillingAccount__r.ContractNumber__c;

        Set<String> lMSISDNSet = new Set<String>();
                //coloca os MSISDN's relacionados ao contrato dentro de um SET, pois o LAKE pode inserir registros duplicados
        for(Asset lAsset :[SELECT Id, MSISDN__c FROM Asset WHERE vlocity_cmt__BillingAccountId__c = :objCase.ContractBillingAccount__c AND Status = 'Ativo' AND MSISDN__c != null]){
                lMSISDNSet.add(lAsset.MSISDN__c);
        } 
        for(String msisdn : lMSISDNSet){
            data = doCallout(msisdn);
        }
       
        if(data.get('outage') == null && data.get('success') !=null && Boolean.valueOf(data.get('success')) != false){
            System.debug('Entrou Aqui');
            data.put('success', true);
            data.put('message', Label.Solar_Cross_IntegrationNoData);
        }else if(data.get('outage') != null){
            data.put('success', true);
        }
        return data;
    }


    public static Map<String,Object> doCallout(String msisdn){

        ServiceParameter__c metaParameter = ServiceParameter__c.getInstance('MobileOutages');
        String strUser  = metaParameter.User__c;
        String strPassword = metaParameter.Password__c;


        Map<String,String> queryParams = new Map<String,String>{'msisdn' => msisdn};
        Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', queryParams, 'MobileOutages');

        if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
            MobileOutagesJSON mobileOutages = (MobileOutagesJSON) JSON.deserialize(calloutResponse.get('response'),MobileOutagesJSON.class);
            System.debug('mobileOutages: ' + mobileOutages);
            if(mobileOutages.data != null){
                Outage objOut = new Outage();
                objOut.isInOutage = mobileOutages.data.impact;
                objOut.prevision = mobileOutages.data.expectedRegularizationDt != null ? convertDate(mobileOutages.data.expectedRegularizationDt): null;
                data.put('success',true);
                if(globalOutage.prevision != null && globalOutage.prevision > objOut.prevision){
                    data.put('outage',objOut);
                    globalOutage = objOut;
                }else if(globalOutage.prevision != null && globalOutage.prevision < objOut.prevision){
                    data.put('outage',globalOutage);
                }else{
                    globalOutage = objOut;
                    data.put('outage',globalOutage);
                }
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