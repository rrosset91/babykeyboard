/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 29-12-2020
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   29-12-2020   Joao Neves   Initial Version
 **/
public without sharing virtual class ClaroAPIBaseResponse {
	//API
	public String apiVersion;
	public String transactionId;
	public Error error;
	//Custom atts
	public Boolean isSuccessfull;
	public String errorMessage;
	public Integer statusCode;
	//Type
	private Object specificTypeData;
	private String specificNameClass;

	public ClaroAPIBaseResponse() {
	}

	public ClaroAPIBaseResponse(String specificClassType, Map<String, String> initMap) {
		if (specificClassType == null)
			throw new ClaroAPIException('O parâmetro do tipo da classe é obrigatório.');

		this.specificNameClass = specificClassType;

		calculateAttributes(initMap);
	}

	private void calculateAttributes(Map<String, String> responseMap) {
		Type apexType = Type.forName(this.specificNameClass);
		Object untypedResponse = JSON.deserializeuntyped(responseMap.get('response'));
		Map<String, Object> deserializedUntyped = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(untypedResponse));

		this.statusCode = Integer.valueOf(responseMap.get('statusCode'));
		this.apiVersion = (String) deserializedUntyped.get('apiVersion');
		this.transactionId = (String) deserializedUntyped.get('transactionId');

		if (statusCode >= 400) {
			this.isSuccessfull = false;
			this.errorMessage = getErrorMessage();
			this.error = (Error) JSON.deserialize(JSON.serialize(((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(untypedResponse))).get('error')), Error.class);
		} else {
			this.isSuccessfull = true;
			this.errorMessage = null;
			this.specificTypeData = JSON.deserialize(JSON.serialize(((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(untypedResponse))).get('data')), apexType);
		}
	}

	public virtual Object getData() {
		return this.specificTypeData;
	}

	public string getErrorMessage() {
		String errorMessage = 'API Unknown error';

		if (this.error != null)
			errorMessage = this.error.errorCode + ' - ' + this.error.message + ' - ' + this.error.detailedMessage;

		return errorMessage;
	}

	public class Error {
		public String httpCode;
		public String errorCode;
		public String message;
		public String detailedMessage;
		public Link link;
	}

	public class Link {
		public String rel;
		public String href;
	}

	public class ClaroAPIException extends Exception {
	}
}