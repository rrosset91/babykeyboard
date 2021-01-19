/*
* @author: Roger Rosset
* @company: IBM - Bluewolf
* @description: Classe utilizada para consulta da api de 2a via
*/
public class InvoicesSendDuplicate {  
/*
* @description: Método para consultar o endpoint Duplicate (2a Via)
*/
    @AuraEnabled
    public static Map<String,Object> getDuplicateInvoice(String billId, String operatorCode){
        Map<String, Object> data = new Map<String, Object>();
        Map<String, String> headers = setHeaders();
        Map<String, String> params = setParams(billId, operatorCode);
        try{
            Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers,'SendDuplicate');
            if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
                data.put('success', true);
                data.put('duplicates', processSendMethods(calloutResponse.get('response')));
            }else{
                data.put('success', false);
                data.put('message', setErrorMessage(calloutResponse.get('response')));
            }
        }catch(Exception e){
           throw new AuraHandledException(e.getMessage());
        }
        return data;
    }
/*
* @description: Método para disponibilizar para o componente os motivos de envio de segunda via    
*/    
public static List<Object> getSendReasons(List<Integer> availableIds){
        List<Object> sendReasons = new List<Object>();
        sendDuplicateReason__mdt[] sdReasons = [SELECT MasterLabel, ReasonID__c, SolarReason__c FROM sendDuplicateReason__mdt];
        
    	for (sendDuplicateReason__mdt sdReason : sdReasons) {
            if(availableIds.contains(sdReason.ReasonID__c.intValue())){
            	sendReasons.add(sdReason);
            }
		}
        return sendReasons;
    }
/*
* @description: Método para processar o Json e retornar Wrapper do Post Response
*/
    @TestVisible
    private static JSONPostDuplicateResponse processPostJsonResponse(String responseJson){
        String jsonString = responseJson;
        JSONPostDuplicateRequest response = (JSONPostDuplicateRequest)JSON.deserialize(jsonString, JSONPostDuplicateRequest.class);
   		JSONPostDuplicateResponse jsnRsp = new JSONPostDuplicateResponse();
        jsnRsp.message = response.data.message;
        jsnRsp.billNewId = response.data.billNewId;
        jsnRsp.dueDate = response.data.dueDate;
        return jsnRsp;
    }    
/*
* @description: Método para processar o Json e retornar Wrapper
*/
@TestVisible
private static InvoicesDuplicateWrapper processSendMethods(String responseJson){
    String jsonString = responseJson; 
    List<InvoicesDuplicateWrapper.sendMethods> sendMethodsList = new  List<InvoicesDuplicateWrapper.sendMethods>();
    JSONDuplicates response = (JSONDuplicates)JSON.deserialize(jsonString, JSONDuplicates.class);
    for (JSONDuplicates.SendMethods sdMethods : response.data.listSendMethod) {
        InvoicesDuplicateWrapper.sendMethods sendMethod = new InvoicesDuplicateWrapper.sendMethods();
        sendMethod.sendMethodId = sdMethods.sendMethodId;
        sendMethod.sendMethodDescription = sdMethods.sendMethodDescription;
        sendMethod.isExtended = sdMethods.isExtended;
        
        if(sendMethod.sendMethodDescription !='FAX'
           	&& 
           sendMethod.sendMethodDescription !='LOCAL'
          	&& 
           sendMethod.isExtended == 'NAO'){
        		sendMethodsList.add(sendMethod);
           }
    }
	List<Integer> availableIds = new List<Integer>();
    for (JSONDuplicates.Reasons rsn : response.data.listReason) {
        InvoicesDuplicateWrapper.reasons reason = new InvoicesDuplicateWrapper.reasons();
        reason.descriptionReason = rsn.descriptionReason;
        reason.reasonId = rsn.reasonId;
		reason.isExtended = rsn.isExtended;
		
		if(reason.isExtended == 'NAO')
        	availableIds.add(reason.reasonId);
    }
    List<Object>reasonsList = getSendReasons(availableIds);
    InvoicesDuplicateWrapper dupWrp = new InvoicesDuplicateWrapper();
    dupWrp.availableSendMethods = sendMethodsList;
    dupWrp.availableReasons = reasonsList;
    dupWrp.billAllowsSending = response.data.billAllowsSending;
    dupWrp.billExtend = response.data.billExtend;
    dupWrp.contractNumber = response.data.contractNumber;
    dupWrp.email = response.data.email;
    dupWrp.name = response.data.name;
    dupWrp.note = response.data.note;
    dupWrp.phoneNumber = response.data.phoneNumber;
    dupWrp.userHasAccess = response.data.userHasAccess;
    return dupWrp;  
}  

	/*
	* @description: Método enviar duplicate(2a Via)
	*/
    
    @AuraEnabled 
    public static Object postDuplicateInvoice(string operatorCode ,string contractNumber ,string userName ,string billId , string name ,string phoneNumber , string email ,string sendMethod ,string billExtend, string descriptionReason){
		userName = InvoicesUtils.getCalloutUser('PostDuplicate');
		Map<String, Object> data = new Map<String, Object>();
        Map<String, String> headers = setHeaders();
        Map<String, String> params = setParams(billId, operatorCode);
        
        //@note BUG 10298281: add mock for data
        if(sendMethod == 'SMS' && (String.isBlank(phoneNumber) || phoneNumber.length() < 11))
        {        
            data.put('success', false);
            data.put('postDuplicateResponse', 'Para envio de SMS é necessario preenchimento do numero de celular valido');
            return data;
        }
        if(sendMethod == 'EMAIL' && (String.isBlank(email) || email.indexOf('@') == -1))
        {        
            data.put('success', false);
            data.put('postDuplicateResponse', 'Para envio de EMAIL é necessario preenchimento do email valido');
            return data;
		}
        //Fim BUG 10298281
        
        sendDuplicateReason__mdt reasonCmt = new sendDuplicateReason__mdt();
        reasonCmt = [SELECT ReasonID__c FROM sendDuplicateReason__mdt WHERE SolarReason__c =: descriptionReason LIMIT 1];
        Integer reasonId = reasonCmt.ReasonID__c.intValue();
        String body = processPostJson(operatorCode,contractNumber,userName,billId,name,phoneNumber,email,sendMethod,billExtend,reasonId,descriptionReason);
        
        try{
            Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(body, params, headers,'PostDuplicate');
            if(Integer.valueOf(calloutResponse.get('statusCode')) < 400){
                data.put('success', true);
                data.put('postDuplicateResponse', processPostJsonResponse(calloutResponse.get('response')));
            }else{
                data.put('success', false);
                data.put('postDuplicateResponse', setErrorMessage(calloutResponse.get('response')));
            }
        }catch(Exception e){
           throw new AuraHandledException(e.getMessage());
        }
        return data;
    }
	/*
	* @description: Método para gerar o JSON da requisição para POST
	*/   
    public static String processPostJson(string operatorCode ,string contractNumber ,string userName ,string billId , string name ,string phoneNumber , string email ,string sendMethod ,string billExtend , integer reasonId ,string descriptionReason){
    	JSONDuplicatesRequest body = new JSONDuplicatesRequest();
    	JSONDuplicatesRequest.Data data = new JSONDuplicatesRequest.Data();

    	data.operatorCode = operatorCode;
    	data.contractNumber = contractNumber;
    	data.userName = userName;
    	data.billId = billId;
    	data.name = name;
        //@note BUG 10298281: add mock for data
    	//data.phoneNumber = phoneNumber;
    	//data.email = email;
        data.phoneNumber = String.isEmpty(phoneNumber) ? '11999999999' : phoneNumber;
    	data.email = String.isEmpty(email) ? 'email@naoencontrado.com' : email;
        //FIM BUG

    	data.sendMethod = sendMethod.indexOf('-') == -1 ? sendMethod : sendMethod.remove('-');

    	data.billExtend = 'NAO';
    	data.reasonId = reasonId;
    	data.descriptionReason = descriptionReason;
   		String jsonResponse = JSON.serialize(data);
        jsonResponse = jsonResponse.replace('{"userName":', '{"data": {"userName":');
        jsonResponse+='}';
    	return jsonResponse;
	}
    
/*
* @description: Método para setar os parâmetros da chamada
*/
    public static Map<String, String> setParams(String billId, String operatorCode){
        Map<String, String> params = new Map<String, String>();
        if(String.isEmpty(billId) 
           || String.isEmpty(operatorCode))
        {
            String emptyFields = (String.isEmpty(billId)) ? ', billId' : '';
            emptyFields += (String.isEmpty(operatorCode)) ? ', operatorCode' : '';
            throw new DuplicateControllerException('Todos os parâmetros para realizar a busca devem ser preenchidos - ' + emptyFields);
        }else{
            params.put('billId', billId);
            params.put('operatorCode', operatorCode);
        }
        return params;
    }
/*
* @description: Método para setar o header da chamada
*/
    @TestVisible
    private static Map<String, String> setHeaders(){
        Map<String, String> header = new Map<String, String>();
        ServiceParameter__c params = ServiceParameter__c.getValues('SendDuplicate');
		String user = params.User__c;
        String token = params.Token__c;
        header.put('X-QueryString', 'username='+user);
        header.put('Content-Type', 'application/json');
        header.put('x-client-auth', token);
        return header;
    }

/*
* @description: Método para tratar erros de requisição
*/   
    @TestVisible
    private static String setErrorMessage(String jsonString){
        String errorMessage = '';
        JSONDuplicates errorResponse = (JSONDuplicates)JSON.deserialize(jsonString, JSONDuplicates.class);
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

    public class DuplicateControllerException extends Exception {}
}