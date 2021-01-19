/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :

 * @last modified on  : 11-12-2020

 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   16-11-2020   Diego Almeida   Initial Version

 * 1.0   07-12-2020   Diego Almeida   MobilePDF
 *

**/
public without sharing class FinancialPDF {
    @AuraEnabled
	public static ResponseWrapper getPDFBase64(String companyId, String externalId, String operatorCode, String accountId) {

        Map<String, String> params = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>();

        params.put('companyId', companyId);
        params.put('externalId', externalId.leftPad(15, '0')); //é o código do boleto da fatura que você deseja consultar. Ele deve ter 15 dígitos completados com zeros à esquerda, caso seja menor.
        params.put('customerAccountId', getcustomerAccountId(operatorCode, accountId));

        String authToken = getAuth('ResidencialInvoicesPDF');
        headers.put('Authorization', authToken);


        return callPDF(params, headers, 'ResidencialInvoicesPDF', companyId);
    }

    @AuraEnabled
    public static ResponseWrapper getPDFURL(String companyId, String dueDate, String billingAccountId) {
        Map<String, String> params = new Map<String, String>();
        Map<String, String> headers = new Map<String, String>();

        params.put('companyId', companyId);
        params.put('dueDate', dueDate);
        params.put('billingAccountId', billingAccountId.substring(0,billingAccountId.length()-3));

        // String authToken = getAuth('MobileInvoicesPDF');
        // headers.put('Authorization', authToken);


        return callPDF(params, headers, 'MobileInvoicesPDF', companyId);
    }

	private static ResponseWrapper callPDF(Map<String, String> params, Map<String, String> headers, String customSetting, String companyId) {
        ResponseWrapper responseReturn = new ResponseWrapper();

		System.debug('callPDF params: '+params);
        System.debug('callPDF headers: '+headers);

		Map<String, String> calloutResponse = new Map<String, String>();
        calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, customSetting);
        System.debug('callPDF response: '+calloutResponse.get('response'));

        PDFResponse responseObject = new PDFResponse();
        try {
            responseObject = (PDFResponse)JSON.deserialize(calloutResponse.get('response').replace('retrieve', 'retrievepdf'), PDFResponse.class);
        } catch (Exception ex) {
            responseReturn.hasData      =   false;
            responseReturn.hasError     =   true;
            responseReturn.errorMessage =   'Opss! Algo deu errado. Favor tente novamente mais tarde' ;
            responseReturn.responseMsg  =   ex.getMessage();
            return responseReturn;
        }


        responseReturn.hasData = Integer.valueOf(calloutResponse.get('statusCode')) < 400;
        responseReturn.hasError = Integer.valueOf(calloutResponse.get('statusCode')) >= 500;

        if(responseReturn.hasData){

            if(responseObject.data != null){
                responseReturn.responseMsg = companyId == 'RESIDENCIAL' ? responseObject.data.retrievepdf.content : responseObject.data.invoicePDF.invoiceURL;


                //Somente para testes fora do ambiente claro
                String typeUser = UserInfo.getUserName().substringAfterLast('.');
                if(companyId == 'MOVEL' && ( typeUser == 'cross' || typeUser == 'crossunit' || typeUser == 'test' || typeUser == 'test2')){
                    responseReturn.responseMsg ='https://americalatina.dint.fgv.br/sites/americalatina.dint.fgv.br/files/teste33.pdf';
                }

            }
            else{
                responseReturn.errorMessage =  'Não existe pdf para esta fatura';
                responseReturn.hasData = false;
            }

        }else{
            responseReturn.responseMsg = responseObject.error.detailedMessage != null ? responseObject.error.detailedMessage : responseObject.error.message;
            responseReturn.errorMessage =responseReturn.hasError ? 'Opss! Algo deu errado. Favor tente novamente mais tarde' : 'Não existe pdf para esta fatura';
        }

        System.debug('callPDF responseReturn: '+responseReturn);


        return responseReturn;
    }


    private static String getAuth(String customSetting){
        ServiceParameter__c setting = ServiceParameter__c.getValues(customSetting);
        String token = setting.Token__c;
        return token;
    }

    /**
    * @description é composto por 3 dígitos do código da operadora, uma barra ‘/’ e nove dígitos do número do contrato, esse último completado com zeros à esquerda, caso seja menor
    * @author Diego Almeida | 19-11-2020
    * @param operatorCode
    * @param accountId
    * @return String
    **/
    private static String getcustomerAccountId(String operatorCode, String accountId){
        String stringReturn;
        stringReturn = operatorCode+'/'+ accountId.leftPad(9,'0');
        return stringReturn;
    }

    public class PDFRetrieve{
        public String content;
        public String name;
        public String status;
        public String message;
    }

    public class Data{
        public PDFRetrieve retrievepdf;

        public InvoicePDF invoicePDF;
    }

    public class InvoicePDF{
        public String invoiceURL;
    }


    public class Error{
        public String httpCode;
        public String errorCode;
        public String message;
        public String detailedMessage;
    }

    public class PDFResponse{
        public String apiVersion;
        public String transactionId;
        public Data data;
        public Error error;
    }

    public class ResponseWrapper{
        @AuraEnabled public Boolean hasData;
        @AuraEnabled public Boolean hasError;
        @AuraEnabled public String responseMsg;
        @AuraEnabled public String errorMessage;
    }
}