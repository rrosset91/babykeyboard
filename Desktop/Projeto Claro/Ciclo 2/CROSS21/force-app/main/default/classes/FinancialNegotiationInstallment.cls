/**
 * @description       : US101348
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 18-01-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-01-2021   Diego Almeida   Initial Version
**/
public with sharing class FinancialNegotiationInstallment {

	/**
	* @description Retorna as possiveis variacoes de parcelamento
	* @author Diego Almeida | 13-01-2021
	* @param caseId Id do caso CRM
	* @param bills Lista de bills selecionadas
	* @param statements Lista de statements selecionadas
	* @return Map<String, Object>
	**/
    @AuraEnabled
	public static Map<String, Object> getInstallmentPlan(String caseId, List<String> bills, List<String> statements){
        Map<String, Object> response = new Map<String, Object>();

        Case casoAtual = [SELECT Id  FROM Case WHERE Id =:caseId LIMIT 1];

		response.put('alcada', hasSalesforceAuthority(casoAtual, ''));
        response.put('success', true);
        response.put('errorMessage', 'XPTO');
	    response.put('dadosParcelamento', new List<DadosParcelamento>());
			//response.put('nameAuthority', parameterHierarchy);
		return response;
    }

	/**
	* @description Com base no parcelamento selecionado retorna os dados das parcelas
	* @author Diego Almeida | 13-01-2021
	* @param request item da lista dadosParcelamento retornado em getInstallmentPlan
	* @return Map<String, Object>
	**/
    @AuraEnabled
	public static Map<String, Object> getInstallmentValues(String request){
		Map<String, Object> response = new Map<String, Object>();
        response.put('success', true);
        response.put('errorMessage', 'XPTO');
	    response.put('dadosParcelamento', new DadosParcelamento());
			//response.put('nameAuthority', parameterHierarchy);
		return response;
    }

    private static JSONInvoicesNegotiationOptions postNegotiationOptions(String contractNumber,String operatorCode, String discountValue, Map<String, List<string>> selectedNegotiation) {
		JSONInvoicesNegotiationOptions response = new JSONInvoicesNegotiationOptions();
        Map<String, Object> jsonData = new Map<String, Object>();
        Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(setJsonBody(jsonData), null, null, 'InvoicesNegotiationOptions ');
        calloutResponse.put('response', calloutResponse.get('response').replace('"number"', '"installmentNumber"'));
        JSONInvoicesNegotiationOptions resp = new JSONInvoicesNegotiationOptions('JSONInvoicesNegotiationOptions', calloutResponse);

        System.debug(JSON.serializePretty(resp));

        if (resp.isSuccessfull) {
            response = (JSONInvoicesNegotiationOptions) resp.getData();
        } else {
            throw new InstallmentException(resp.getErrorMessage());
        }
		//JSONInvoicesNegotiationOptions responseObject = (JSONInvoicesNegotiationOptions)JSON.deserialize(calloutResponse.get('response').replace('"number"', '"installmentNumber"'), JSONInvoicesNegotiationOptions.class);

		return response;
    }


    private static Map<String, Object> getPropensaoPROCON(String cpf, String contractNumber,String operatorCode, String origin) {
		Map<String, Object> response = new Map<String, Object>();

        Map<String, String> params = new Map<String, String>();
            params.put('origen', origin);
		// System.debug('getPropensaoPROCON params: ' + params);

        Map<String, String> headers = new Map<String, String>();
            String authToken = getAuth('CustomerProconPropensity');
			headers.put('X-Client-Auth', authToken);
		String queryString = 'cpf='+cpf+'&contractNumber='+contractNumber+'&operatorCode='+operatorCode;
			headers.put('X-QueryString', queryString);

		// System.debug('getPropensaoPROCON headers: ' + headers);

		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'CustomerProconPropensity');
		JSONCustomerProconPropensity responseObject = (JSONCustomerProconPropensity)JSON.deserialize(calloutResponse.get('response'), JSONCustomerProconPropensity.class);

		if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
			response.put('propensaoPROCON', true);
			if(origin == '2'){
				response.put('parameterPROCON', responseObject.data.codRangePropensity);
			}
		}else{
			response.put('propensaoPROCON', false);
			response.put('statusCode', calloutResponse.get('statusCode'));
		}
		return response;
    }

    private static Map<String, Object> getSegmentacaoDefault(String cpf, String contractNumber,String operatorCode, String origin) {
		Map<String, Object> response = new Map<String, Object>();

        Map<String, String> params = new Map<String, String>();
            params.put('origen', origin);
		// System.debug('getSegmentacaoDefault params: ' + params);

        Map<String, String> headers = new Map<String, String>();
            String authToken = getAuth('CustomerDefaultSegmetation');
			headers.put('X-Client-Auth', authToken);
		String queryString = 'cpf='+cpf+'&contractNumber='+contractNumber+'&operatorCode='+operatorCode;
			headers.put('X-QueryString', queryString);

		// System.debug('getSegmentacaoDefault headers: ' + headers);

		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'CustomerDefaultSegmetation');
		JSONCustomerDefaultSegmetation responseObject = (JSONCustomerDefaultSegmetation)JSON.deserialize(calloutResponse.get('response'), JSONCustomerDefaultSegmetation.class);

		if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
			response.put('propensaoDefault', true);
			if(origin == '2'){
				response.put('parameterDefault', responseObject.data.descCluster);
			}
		}else{
			response.put('propensaoDefault', false);
			response.put('statusCode', calloutResponse.get('statusCode'));
		}
		return response;
    }

    private static String getAuth(String customSetting){
        ServiceParameter__c setting = ServiceParameter__c.getValues(customSetting);
        String token = setting.Token__c;
        return token;
    }

    private static String setJsonBody(Map<String, Object> jsonData){
        PostBody objBody = new PostBody();
        PostData objData = new PostData();
        objData.operatorCode            =   (String) jsonData.get('operatorCode');
        objData.contractNumber          =   (Integer) jsonData.get('operatorCode');
        objData.userName                =   (String) jsonData.get('operatorCode');
        objData.discountValue           =   Double.valueOf(jsonData.get('operatorCode'));
        objData.firstInstallmentValue   =   Double.valueOf(jsonData.get('operatorCode'));
        objData.exemptInterestTicket    =   (Boolean) jsonData.get('operatorCode');
        objData.bills                   =   (List<String>) jsonData.get('bills');
        objData.statements              =   (List<String>) jsonData.get('statements');
        objBody.data                    =   objData;
        return objBody.toString();
    }

    private static Boolean hasSalesforceAuthority(Case casoAtual, String valorNegociacao){
        Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();



        List<Parameters__c> parametrosAlcada = new List<Parameters__c>();
        List<Parameters__c> parametrosAprovados = new List<Parameters__c>();



        parametrosAlcada = [
            SELECT
				id,
				name,
				active__c,
				Process__c,
				Channel__c,
				Profile__c,
				Amount__c,
				Segment__c
			FROM Parameters__c
			WHERE Active__c = TRUE
				AND RecordTypeId = :recordTypeIdParameter
				AND Process__c = 'Negociação'
        ];

        if(parametrosAlcada.size() == 0)return false;

        List<User> lstUser = new List<User>();
        List<PermissionSetAssignment> lstPermissionSet = new List<PermissionSetAssignment>();

        lstUser = [SELECT Id, Name, UserRoleId, UserRole.DeveloperName FROM User WHERE UserRoleId != NULL AND Id = :UserInfo.getUserId()];
		lstPermissionSet = [SELECT Id, PermissionSet.Name, Assignee.Name FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId()];

		Map<String, PermissionSetAssignment> permissionSets = new Map<String, PermissionSetAssignment>();
		for (PermissionSetAssignment assign : lstPermissionSet){
            permissionSets.put(assign.PermissionSet.Name, assign);
        }

        Id profileId = UserInfo.getProfileId();
		String usrProfileName = [SELECT Name FROM Profile WHERE Id = :profileId LIMIT 1].Name;
        Boolean isDigitalProfile = usrProfileName == 'SF_DAC_Digital';

        for (Parameters__c parametro : parametrosAlcada) {

            // if ((isDigitalProfile && parametro.Channel__c != 'Digital') || (!isDigitalProfile && parametro.Channel__c == 'Digital'))
            // continue;

            Boolean profileBool         = (usrProfileName == parametro.Profile__c);
            Boolean channelBool         = true;
            Boolean amountBool 			= parametro.Amount__c >= Decimal.valueOf(valorNegociacao);
            Boolean divisionBool        = true;

            if(profileBool && channelBool && amountBool && divisionBool){
                parametrosAprovados.add(parametro);
            }
        }



        //permissionSets.containsKey(param.Profile__c)
        return !parametrosAprovados.isEmpty();
    }


    //Wrapper do body envio
    public class PostBody{
        public PostData data;
    }
    public class PostData{
        public String operatorCode;
        public Integer contractNumber;
        public String userName;
        public Double discountValue;//Enviar Porcentagem
        public Double firstInstallmentValue;//Somente quando aporte a vista
        public Boolean exemptInterestTicket;//false
        public List<String> bills;
        public List<String> statements;
    }

    //Wrapper de comunicacao LWC
    public class DadosParcelamento{
        public String labelParcelamento;
        public Integer quantidadeParcelamento;  //number
        public Double valorDesconto;
        public Double porcentagemDesconto;
        public Date primeiroVencimento;
        public List<ParcelaItem> parcelas;
    }
    public class ParcelaItem{
        public String numeroParcela;
        public Double valorTotal;
        public String vencimento;
        public Double valorParcela;//firstValue
        public Double valorJuros;//firstInterest
        public Double valorMulta;//firstTicket
    }

	public class InstallmentException extends Exception {
	}
}