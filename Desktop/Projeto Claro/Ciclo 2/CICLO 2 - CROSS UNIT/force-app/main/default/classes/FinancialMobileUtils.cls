/**
 * @description       : Utilidades para as classes relacionadas ao histórico de eventos
 * @author            : Roger Rosset
 * @group             : Financeiro_Eventos

 * @last modified on  : 31-10-2020

 * @last modified by  : Roger Rosset
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   20-10-2020   Roger Rosset   Initial Version
**/
public with sharing class FinancialMobileUtils {
    /**
    * @description Retorna mensagens de erro
    * @author Roger Rosset | 24-10-2020 
    * @param String jsonString 
    * @return String 
    **/
    public static String setErrorMessage(String jsonString){
        String errorMessage = '';
        JSONEvents errorResponse = (JSONEvents)JSON.deserialize(jsonString, JSONEvents.class);
        if(errorResponse != null){
            if(errorResponse.error != null){
                errorMessage = errorResponse.error.errorCode + ' - ' + errorResponse.error.detailedMessage;
            }else{
                errorMessage = 'Unknown error';
            }
        }else{
            errorMessage = 'Unknown error';
        }
        return errorMessage;
    }

    /**
    * @description Recebe uma string de valor $ e converte em formato R$
    * @author Roger Rosset | 24-10-2020 
    * @param String stringValue 
    * @return String 
    **/
    public static String formatBRL(String stringValue) {
        String formattedCurrency = ( Decimal.valueOf(stringValue==null||stringValue.trim()==''?'0':stringValue).setScale(2) + 0.001 ).format();
        return 'R$ '+formattedCurrency.substring(0,formattedCurrency.length()-1);
    }

    /**
    * @description Retorna o token de autenticação cadastrado no custom setting
    * @author Roger Rosset | 24-10-2020 
    * @param String customSetting 
    * @return String 
    **/
    public static String getAuth(String customSetting){
        ServiceParameter__c setting = ServiceParameter__c.getValues(customSetting);
        String token = setting.Token__c;
        return token;
    }

    /**
    * @description Recebe uma data formato padrao e um parametro true ou false para adicionar ou não hora nesta data
    * Datetime recebido no formato YYYY-MM-DDTHH:MM:SS... 
    * Retorna data ou datetime nos formatos: DD/MM/YYYY se appendTime=false |ou| DD/MM/YYYY / HH:MM:SS se appendTime = true
    * @author Roger Rosset | 24-10-2020 
    * @param String responseDate 
    * @param Boolean appendTime 
    * @return String 
    **/
    public static String formatResponseDate(String responseDate, Boolean appendTime){
		String formattedDateTime;
        responseDate = responseDate.replace('.', '&');
        
        String rawDate = responseDate.split('T')[0];
		String formattedDate = rawDate.split('-')[2]+'/'+rawDate.split('-')[1]+'/'+rawDate.split('-')[0];
        
        String rawTime = responseDate.split('T')[1];
        String formattedTime = rawTime.split('&')[0];
       
        if(appendTime == true){

        	formattedDateTime = formattedDate + ' - ' + formattedTime;

        }else{
            formattedDateTime = formattedDate;
        }
        system.debug(formattedDateTime);
        return formattedDateTime;
    }

    /**
    * @description Recebe uma STRING-DATA e devolve uma instancia real de data. - Data recebida no formato DD/MM/YYYY
    * @author Roger Rosset | 24-10-2020 
    * @param String stringDate 
    * @return Date 
    **/
    public static Date getRealDateInstance(String stringDate){
        Date realDate = date.newinstance(integer.valueOf(stringDate.split('/')[2]), integer.valueOf(stringDate.split('/')[1]), integer.valueOf(stringDate.split('/')[0]));
        return realDate;
    }

    /**
    * @description Recebe STRING-DATA e STRING-TIME e devolve uma instancia real de datetime - Data recebida em formato DD/MM/YYYY e Time em formato HH:MM:SS
    * @author Roger Rosset | 24-10-2020 
    * @param String stringDate 
    * @param String stringTime 
    * @return Datetime 
    **/
    public static Datetime getRealDateTimeInstance(String stringDate, String stringTime){
        Integer year = Integer.valueOf(stringDate.split('/')[2]);
        Integer month = Integer.valueOf(stringDate.split('/')[1]);
        Integer day = Integer.valueOf(stringDate.split('/')[0]);
        Integer hour = Integer.valueOf(stringTime.split(':')[0]);
        Integer minute = Integer.valueOf(stringTime.split(':')[1]);
        Integer second = Integer.valueOf(stringTime.split(':')[2]);
        Datetime realDatetime = Datetime.newInstance(year, month, day, hour, minute, second);
        return realDatetime;
    }

    /**
    * @description - Recebe um JSON String e o retorna formatado inline
    * @author Roger Rosset | 24-10-2020 
    * @param String rawJson 
    * @return String 
    **/

    public static String formatInlineJson(String rawJson){String inlineJson = rawJson.replace('\n', ''); return inlineJson;}

    /**
    * @description Retorna o msisdn principal atrelado a conta comercial do caso
    * @author Roger Rosset | 28-10-2020 
    * @param String caseId 
    * @return String 
    **/
    @AuraEnabled
    public static String getMsisdn(String caseId){String accId = [SELECT ID , ContractBillingAccount__c FROM Case WHERE Id =:caseId LIMIT 1].ContractBillingAccount__c;  String msisdn = [SELECT Id, MSISDN__c FROM Asset WHERE vlocity_cmt__BillingAccountId__c =:accId LIMIT 1].MSISDN__c; return msisdn;}

    /**
    * @description retorna o customerCrmId reutilizando métodos já criados pelo cross
    * @author Roger Rosset | 28-10-2020 
    * @param String msisdn 
    * @return String 
    **/
    @AuraEnabled
    public static String getCustomerCrmId(String msisdn){CEC_RestObjects.mobileSubscribers objSubscriberAux = new  CEC_RestObjects.mobileSubscribers(); objSubscriberAux = CEC_360_IntegrationsSubscriberHistory.getSubscriber(msisdn);return objSubscriberAux.crmSubscriberId;}

}