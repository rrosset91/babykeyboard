/* 
* @author: Diogo Braga - Deloitte 
* @date: 19/12/2019
* 
* @description: Classe abstrata de integração de orders 
* US 35133
* Nome do projeto/ID: CEC Ext - Time: SQUAD 360
*
* @version 1.0
*/
public abstract class CEC_360_IntegrationOrdersAbstract { 
	/*@author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe de exceção da para idnetificação validações da classe de integração*/
    public class IntegrationsOrdersException extends Exception {}
    
    /*@author: Diogo Braga - Deloitte 
	*@date: 04/12/2019
	*@description: valida preenchimento obrigatório dos atributos
	*@return void*/
    protected HTTPResponse send(Object requestParameters, String endPoint, String method) {
        HTTPRequest request = new HTTPRequest();
        request.setEndpoint(buildEndPoint(requestParameters, endPoint));
		request.setMethod(method);
        request.setTimeout(120000);  
        
        HTTPResponse response = new HTTP().send(request);
        System.debug('request EndPoint: ' + request.getEndpoint());
        System.debug('response: ' + response);
        system.debug('Response body: ' + response.getBody());
        validateResponse(response);
        
        return response;
    }
    
    /*@author: Diogo Braga - Deloitte 
	*@date: 04/12/2019
	*@description: valida preenchimento obrigatório dos atributos
	*@return void*/
    public static void validateRequiredAttribute(Object value, String nameAttribute) {
        if(value == null) {
            throw new IntegrationsOrdersException('Atributo obrigatório nulo [' + nameAttribute + ']');
        } else if(value instanceof String && String.isBlank((String) value)) {
            throw new IntegrationsOrdersException('Atributo obrigatório vazio [' + nameAttribute + ']');
        }
    }
    
    /*@author: Diogo Braga - Deloitte 
	*@date: 04/12/2019
	*@description: valida preenchimento obrigatório dos atributos
	*@return void*/
    public static String convertDateFormat(String strDateIn) {
        
        if(String.isBlank(strDateIn)) {
            return null;
        }
        system.debug('strDateIn ' + strDateIn);
        List<String> litDatSpl = strDateIn.split(' ');
        if(litDatSpl.size() == 6) {
            Map<String, String> mapMonths = new Map<String, String>{'Jan'=>'01','Feb'=>'02','Mar'=>'03','Apr'=>'04','May'=>'05',
            'Jun'=>'06','Jul'=>'07','Aug'=>'08','Sep'=>'09','Oct'=>'10','Nov'=>'11','Dec'=>'12'};
            return litDatSpl.get(2) + '/' + mapMonths.get(litDatSpl.get(1))  + '/' + litDatSpl.get(5);
        }
        return strDateIn; 
    }
    
    /*@author: Diogo Braga - Deloitte 
    *@date: 04/12/2019
	*@description: valida a resposta da integração
	*@return void*/
    protected void validateResponse(HTTPResponse response) {
        if(response.getStatusCode() != 200) {
            Error error = new Error();
            try {
                error = (Error) JSON.deserialize(response.getBody(), Error.class);
                if(String.isBlank(error.errorCode) || String.isBlank(error.message)) {
                    error.httpCode = String.valueOf(response.getStatusCode());
                    error.message = response.getStatus();
                }
            } catch (JSONException e) {
                error.httpCode = String.valueOf(response.getStatusCode());
                error.message = response.getStatus();
            }
            
            throw new IntegrationsOrdersException('Erro na integração(' + error.httpCode + '): ' + error.message);
        }
    }
    
    /*@author: Diogo Braga - Deloitte 
    *@date: 04/12/2019
	*@description: monta o endpoint
	*@return string com o endpoint da requisição*/
    protected String buildEndPoint(Object varObject, String endPoint) {
        String parameters = '?';
        
        List<String> listParameters = getListParametersByObj(varObject);
        
        for(Integer i = 0; i < listParameters.size(); i++) {
            if(listParameters.size()-1 == i) {
                parameters = parameters + listParameters.get(i);
            } else {
                parameters = parameters + listParameters.get(i) + '&';
            }
        }
        
        String fullEndPoint = 'callout:OAGClaro' + endPoint + parameters;
        
        return fullEndPoint;
    }
    
    /*@author: Diogo Braga - Deloitte 
    *@date: 04/12/2019
	*@description: transforma os paramentros de objeto para lista
	*@return uma lista com o label mais valor de parâmetro*/
    private List<String> getListParametersByObj(Object varObject) {
        List<String> listParameters = new List<String>();
        
        String jsonObject = JSON.serialize(varObject);
        Map<String, Object> mapObject = (Map<String, Object>) JSON.deserializeUntyped(jsonObject);
        
        for(String varParameterName : mapObject.keySet()) {
            String varParameterValue = (String) String.valueOf(mapObject.get(varParameterName));
            if(String.isNotBlank(varParameterValue)) {
                listParameters.add(varParameterName + '=' + varParameterValue);
            }
        }
        
        return listParameters;
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados*/
    public class Error {
        public String httpCode {get; set;}
        public String errorCode {get; set;}
        public String message {get; set;}
        public String detailedMessage {get; set;}
        public Link link {get; set;}
    }
    
    /* @author: Diogo Braga - Deloitte 
	* @date: 04/12/2019
	* @description: Classe modelo de transação de dados*/
    public class Link {
        public String rel {get; set;}
        public String href {get; set;}
    }
    
    public abstract class OrderRequestAbstract {
        
        public String operatorCode {
            get;
			set {
                CEC_360_IntegrationsWorkOrder.validateRequiredAttribute(value, 'operatorCode');
                operatorCode = value; 
            }
        }
        
        public Integer contractNumber {
            get;
			set {
                CEC_360_IntegrationsWorkOrder.validateRequiredAttribute(value, 'contractNumber');
                contractNumber = value; 
            }
        }
        
        public String cityId {get; set;}
        public String status {get; set;}
        public String requestID {get; set;}
    }
    
    public abstract class OrderResponseAbstract {
        @AuraEnabled
        public String cityId {get; set;}
        @AuraEnabled
        public String operatorCode {get; set;}
        @AuraEnabled
        public String contractNumber {get; set;}
        @AuraEnabled
        public String requestID {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String statusDescription {get; set;}
        @AuraEnabled
        public String closeUser {get; set;}
    }
}