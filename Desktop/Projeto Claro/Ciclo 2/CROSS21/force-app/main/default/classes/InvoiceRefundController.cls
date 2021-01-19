/**
 * @author:      Roger Rosset
 * @company:     IBM - Bluewolf
 * @description: Classe controller para fluxo de Reembolso
 */
public without sharing class InvoiceRefundController {
	@AuraEnabled
	public static Map<String, Object> postInvoiceRefund(
	  String areaCode,
	  String contractNumber,
	  String name,
	  String infoMaker,
	  String operatorCode,
	  String phone,
	  String recordId,
	  InvoiceRefundWrapper paymentForm
	) {
	  JSONInvoiceRefundRequest JSONbody = new JSONInvoiceRefundRequest();
	  JSONInvoiceRefundRequest.Data refundRequest = new JSONInvoiceRefundRequest.Data();
	  refundRequest.areaCode = areaCode;
	  refundRequest.contractNumber = contractNumber;
	  refundRequest.description = 'FI2 - RS2 - ANALISE DE REEMBOLSO';
	  refundRequest.identifierType = '1129';
	  refundRequest.login = InvoicesUtils.getCalloutUser('InvoiceRefund');
	  refundRequest.name = name;
	  refundRequest.note = infoMaker;
	  refundRequest.operatorCode = operatorCode;
	  refundRequest.sourceEvent = 'CLARO';
	  refundRequest.telephoneNumber = phone;
	  JSONbody.data = refundRequest;
	  JSONbody.application = 'OTHER';
  
	  String body = JSON.serialize(JSONBody);
	  system.debug('@@@@BodyGerado ' + body);
	  Map<String, Object> data = new Map<String, Object>();
	  Map<String, String> params = new Map<String, String>();
	  Map<String, String> header = new Map<String, String>();
	  header.put('Content-Type', 'application/json');
	  header.put('Content-Length', String.valueOf(body.length()));
	  Integer responseCode;
	  try {
		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest(
		  body,
		  params,
		  header,
		  'InvoiceRefund'
		);
		system.debug('@@@@CALLOUT :' + calloutResponse);
		if (Integer.valueOf(calloutResponse.get('statusCode')) < 400) {
		  data.put('success', true);
		  data.put('refund', calloutResponse.get('response'));
		  responseCode = Integer.valueOf(calloutResponse.get('statusCode'));
		  system.debug(
			'@@@@SUCCESS - RESP :' +
			JSON.serializePretty(calloutResponse.get('response'))
		  );
		} else {
		  data.put('success', false);
		  data.put('message', calloutResponse.get('response'));
		  responseCode = Integer.valueOf(calloutResponse.get('statusCode'));
		  system.debug(
			'@@@@ERROR - RESP :' +
			JSON.serializePretty(calloutResponse.get('response'))
		  );
		}
	  } catch (Exception e) {
		throw new AuraHandledException(e.getMessage());
	  }
	  system.debug('@@@@ReturnData :' + data);
	  createCase(
		responseCode,
		recordId,
		contractNumber,
		operatorCode,
		paymentForm
	  );
	  return data;
	}
  
	public class InvoiceRefundControllerException extends Exception {
	}
	/*
	 * @description: Método para trazer a lista do Tipo de pessoa para a tela reembolso
	 */
	@AuraEnabled
	public static List<String> getPickListTipoPessoa() {
	  List<String> pickListValues = new List<String>();
	  Schema.DescribeFieldResult fieldResult = vlocity_cmt__PaymentAdjustment__c.PersonType__c.getDescribe();
	  List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
	  for (Schema.PicklistEntry pickListVal : pickList) {
		pickListValues.add(pickListVal.getValue());
		system.debug('@@@' + pickListValues);
	  }
	  return pickListValues;
	}
  
	@AuraEnabled
	public static void saveDuplicateField(
	  String refundSerialized,
	  String caseId
	) {
	  try {
		update new Case(Id = caseId, RefundObject__c = refundSerialized);
	  } catch (DMLException e) {
		throw new AuraHandledException(e.getMessage());
	  }
	}
  
	/*
	 * @description: Método para trazer a lista do Tipo de conta para a tela reembolso
	 */
	@AuraEnabled
	public static List<String> getPickListConta() {
	  List<String> pickListValues = new List<String>();
	  Schema.DescribeFieldResult fieldResult = vlocity_cmt__PaymentAdjustment__c.RefundAccount__c.getDescribe();
	  List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
	  for (Schema.PicklistEntry pickListVal : pickList) {
		pickListValues.add(pickListVal.getValue());
	  }
	  system.debug('@@@ LISTA RETORNADA' + pickListValues);
	  return pickListValues;
	}
  
	/*
	 * @description: Método para trazer a lista de bancos para a tela reembolso
	 */
	@AuraEnabled
	public static List<String> getPickListBanco() {
	  List<String> pickListValues = new List<String>();
	  Schema.DescribeFieldResult fieldResult = vlocity_cmt__PaymentAdjustment__c.Bank__c.getDescribe();
	  List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
  
	  for (Schema.PicklistEntry pickListVal : pickList) {
		pickListValues.add(pickListVal.getValue());
		system.debug('@@@' + pickListValues);
	  }
	  return pickListValues;
	}
  
	/*
	 * @description: Método para trazer a lista de motivos para a tela reembolso
	 */
	@AuraEnabled
	public static List<String> getPickListMotivo() {
	  List<String> pickListValues = new List<String>();
	  Schema.DescribeFieldResult fieldResult = vlocity_cmt__PaymentAdjustment__c.RefundReason__c.getDescribe();
	  List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
  
	  for (Schema.PicklistEntry pickListVal : pickList) {
		pickListValues.add(pickListVal.getValue());
		system.debug('@@@' + pickListValues);
	  }
	  return pickListValues;
	}
  
	/*
	 * @description: Método para criar caso e payment adjustment quando a chamada da API falha
	 */
	private static void createCase(
	  Integer StatusCode,
	  String recordId,
	  String contractNumber,
	  String operatorCode,
	  InvoiceRefundWrapper paymentForm
	) {
	  String sourceObject = findObjectAPIName(recordId);
	  Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
		.get('Financial')
		.getRecordTypeId();
	  Id paymentRecordTypeId = Schema.SObjectType.vlocity_cmt__PaymentAdjustment__c.getRecordTypeInfosByDeveloperName()
		.get('Refund')
		.getRecordTypeId();
	  vlocity_cmt__PaymentAdjustment__c payment = new vlocity_cmt__PaymentAdjustment__c();
	  payment.RecordTypeId = paymentRecordTypeId;
	  String accId;
	  system.debug('@@@@WRAPPER RECEBIDO' + paymentForm);
	  Case cs = new Case();
	  if (sourceObject == 'Account') {
		accId = recordId;
		cs.ContractBillingAccount__c = accId;
		cs.ParentId = [
		  SELECT Id
		  FROM Case
		  WHERE ContractBillingAccount__c = :accId
		  ORDER BY CreatedDate DESC
		  LIMIT 1
		]
		.Id;
	  } else if (sourceObject == 'Case') {
		cs.ParentId = recordId;
		accId = [
		  SELECT ContractBillingAccount__c
		  FROM Case
		  WHERE Id = :recordId
		  LIMIT 1
		]
		.ContractBillingAccount__c;
		cs.ContractBillingAccount__c = accId;
	  }
	  cs.Contract__c = contractNumber;
	  cs.OperatorCode__c = operatorCode;
	  cs.RecordTypeId = recordTypeId;
	  cs.Category__c = 'Reembolso';
  
	  if (StatusCode >= 400) {
		cs.Status = 'Closed';
		payment.vlocity_cmt__Status__c = 'Fail';
	  } else {
		cs.Status = 'Closed';
		payment.vlocity_cmt__Status__c = 'Approved';
	  }
	  insert cs;
	  if (paymentForm.refundType == 'CC') {
		payment.Bank__c = paymentForm.banco;
		payment.Agency__c = paymentForm.agencia;
		payment.AccountNumber__c = paymentForm.conta.format();
		payment.Digit__c = paymentForm.digito;
		payment.RefundAccount__c = paymentForm.titular;
	  }
	  if (paymentForm.cpf != null) {
		payment.CPF__c = paymentForm.cpf;
	  }
	  if (paymentForm.cnpj != null) {
		payment.CNPJ__c = paymentForm.cnpj;
	  }
	  payment.vlocity_cmt__DisputeId__c = cs.Id;
	  payment.vlocity_cmt__AccountId__c = accId;
	  payment.HolderName__c = paymentForm.nomeTitular;
	  payment.RefundReason__c = paymentForm.motivoReemb;
	  payment.DoubleRefund__c = paymentForm.reembDobro;
	  payment.Description__c = paymentForm.descricao;
	  payment.PersonType__c = paymentForm.pessoa;
	  payment.Email__c = paymentForm.email;
	  payment.InvoiceExpirationDate__c = paymentForm.vencimentoFatura;
	  payment.Phone1__c = paymentForm.tel1;
	  payment.Phone2__c = paymentForm.tel2;
	  system.debug('@@@@PAYMENT ADJUSTMENT' + payment);
	  insert payment;
	}
  
	/*
	 * @description: Método para buscar o nome do objeto de onde o fluxo iniciou
	 */
	private static String findObjectAPIName(String recordId) {
	  if (recordId == null)
		return null;
	  String objectAPIName = '';
	  String keyPrefix = recordId.substring(0, 3);
	  for (Schema.SObjectType obj : Schema.getGlobalDescribe().Values()) {
		String prefix = obj.getDescribe().getKeyPrefix();
		if (prefix == keyPrefix) {
		  objectAPIName = obj.getDescribe().getName();
		  break;
		}
	  }
	  system.debug(objectAPIName);
	  return objectAPIName;
	}
  }