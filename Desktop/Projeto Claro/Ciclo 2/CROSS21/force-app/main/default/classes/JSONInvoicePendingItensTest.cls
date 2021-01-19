/**
* @author: Rafael de Campos
* @company: IBM - Bluewolf
* @description: Teste para a classe JSONInvoicePendingItens
*/
@isTest
public class JSONInvoicePendingItensTest {
    @isTest static void testInvoicePendingItensConvert(){
        String jsonString = '{'+
		'    \"apiVersion\": \"1\",'+
		'    \"transactionId\": \"32132131\",'+
		'    \"data\": {'+
		'        \"hasHistoricRenegotiation\": false,'+
		'        \"termRenegotiationId\": \"21312312\",'+
		'        \"cityId\": \"2065\",'+
		'        \"contractNumber\": \"432234\",'+
		'        \"functionalityRuleId\": \"20\",'+
		'        \"checkUseItemRenegotiation\": \"S\",'+
		'        \"enableFirstInstallmentSeparateDebts\": \"1\",'+
		'        \"migratedCityMessage\": \"Cidade migrada\",'+
		'        \"businessMessage\": \"Mensagem\",'+
		'        \"bills\": [{'+
		'            \"isMandatory\": true,'+
		'            \"isEnabled\": true,'+
		'            \"isOutOfTime\": false,'+
		'            \"dueDate\": \"02/01/2020\",'+
		'            \"status\": \"Em aberto\",'+
		'            \"paymentMethod\": \"Debito em Conta\",'+
		'            \"amount\": \"9,99\",'+
		'            \"charges\": [{'+
		'                \"partnerName\": \"NET\",'+
		'                \"partnerId\": \"16\",'+
		'                \"segmentationId\": \"CLARO, NET e EMBRATEL\",'+
		'                \"titleNumber\": \"NET\",'+
		'                \"generationDate\": \"02/01/2020\",'+
		'                \"amount\": \"22,43\"'+
		'            }],'+
		'            \"statements\": [{'+
		'                \"isMandatory\": true,'+
		'                \"isSelectable\": true,'+
		'                \"isRenegItem\": true,'+
		'                \"isDue\": true,'+
		'                \"dueDate\": \"02/01/2020\",'+
		'                \"paymentMethod\": \"Debito em Conta\",'+
		'                \"description\": \"NET\",'+
		'                \"amount\": \"9,24\",'+
		'                \"partnerName\": \"NET\",'+
		'                \"serviceType\": \"NET\"'+
		'            }]'+
		'        }]'+
		'    },'+
		''+
		'    \"error\": {'+
		'        \"httpCode\": \"400\",'+
		'        \"errorCode\": \"API-3566\",'+
		'        \"message\": \"Mensagem de erro resumida\",'+
		'        \"detailedMessage\": \"Mensagem de erro detalhada\",'+
		'        \"link\": {'+
		'            \"rel\": \"related\",'+
		'            \"href\": \"https://claro.com.br/P06CEC/corp\"'+
		'        }'+
		'    }'+
		'}';
		JSONInvoicePendingItens obj = (JSONInvoicePendingItens)JSON.deserialize(jsonString, JSONInvoicePendingItens.class);
		System.assert(obj != null);
    }	
}