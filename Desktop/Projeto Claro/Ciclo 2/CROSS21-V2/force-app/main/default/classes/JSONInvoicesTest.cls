/**
* @author: Rafael de Campos
* @company: IBM - Bluewolf
* @description: Teste para a classe JSONInvoice
*/
@isTest
public class JSONInvoicesTest {
    @isTest static void testInvoicesConvert(){
        String jsonString = '{'+
		'    \"apiVersion\": \"1\", '+
		'    \"transactionId\": \"32132131\", '+
		'    \"data\": {'+
		'        \"invoices\": [{'+
		'            \"invoiceId\": \"305470553\", '+
		'            \"statusInvoiceId\": \"3\", '+
		'            \"statusInvoiceDescription\": \"Cancelado\", '+
		'            \"dueDate\": \"2009-05-01T00:00:00.000Z\", '+
		'            \"invoiceAmount\": 575.97, '+
		'            \"paymentForm\": \"Boleto\", '+
		'            \"referenceMonth\": \"11\", '+
		'            \"referenceYear\": \"11\", '+
		'            \"startDate\": \"2009-10-13\", '+
		'            \"endDate\": \"2009-11-13\", '+
		'            \"amountToPay\": 545, '+
		'            \"amountPaid\": 601, '+
		'            \"invoiceDescription\": \"3\" '+
		'        }]'+
		'    },'+
		'    \"error\": {'+
		'        \"httpCode\": \"400\", '+
		'        \"errorCode\": \"API-3566\", '+
		'        \"message\": \"Mensagem de erro resumida\",'+
		'        \"detailedMessage\": \"Mensagem de erro detalhada\", '+
		'        \"link\": {'+
		'            \"rel\": \"related\", '+
		'            \"href\": \"https://oagcechomolog.claro.com.br/P06CEC/corp\"'+
		'        }'+
		'    }'+
		'}';
        
        JSONInvoices obj = (JSONInvoices)JSON.deserialize(jsonString, JSONInvoices.class);
		System.assert(obj != null);
    }
}