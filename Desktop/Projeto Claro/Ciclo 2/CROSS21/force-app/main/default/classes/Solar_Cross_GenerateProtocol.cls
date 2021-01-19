/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-11-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-04-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class Solar_Cross_GenerateProtocol {
    
    @InvocableMethod(label='Sincronizar com sistemas legados solar' 
                        description='Envia casos fechados para os sistemas legados da Claro (PS8, NETSMS e etc...)'
                    )
       public static List<String> syncWithLegacySystems(List<flowInputVariables> inputVariables) {
           //Variables (internal)
           Map<String, Map<String, CEC_CC_PS8Classification__mdt>> classification;
           //List<Case> casesFromPB = getCasesForSync(caseIds);
           List<FlowInputVariables> caseIdsForNETSMS = new List<FlowInputVariables>();
           List<FlowInputVariables> caseIdsForPS8 = new List<FlowInputVariables>();
           Set<String> products = new Set<String>();
           Set<String> businessUnits = new Set<String>();
           List<String> lstReturn = new List<String>();
           //create a set of products and business units to check on metadata (CEC_CC_PS8Classification__mdt)
           for(flowInputVariables cs : inputVariables){
               products.add(cs.product);
               businessUnits.add(cs.businessUnit);
           }
           //search for metadata (CEC_CC_PS8Classification__mdt)
           classification = CEC_CC_ClassificationMdtDAO.getClassificationType(businessUnits, products);
           //check for cases and send to legacy systems (PS8, NETSMS and etc...)
           for(FlowInputVariables cs: inputVariables){
               if(classification.containsKey(cs.businessUnit) && classification.get(cs.businessUnit).containsKey(cs.product)){
                  if(classification.get(cs.businessUnit).get(cs.product).Legacy__c == 'NETSMS'){
                      caseIdsForNETSMS.add(cs);
                  }else if(classification.get(cs.businessUnit).get(cs.product).Legacy__c == 'PS8'){
                      caseIdsForPS8.add(cs);
                  }
               }
           }
           //use future methods to sync with legacy systems
           if(!caseIdsForNETSMS.isEmpty()){
                lstReturn.addAll(createOcurrencyNETSMS(caseIdsForNETSMS));
           }
           if(!caseIdsForPS8.isEmpty()){
                lstReturn.addAll(createProtocolPS8(caseIdsForPS8, products, businessUnits));
           }
           return lstReturn;
       }
       //verificar cenários de exceção
       public static List<String> createOcurrencyNETSMS(List<FlowInputVariables> flowInputVar){
           String serviceName = 'CEC_OAG_Claro_ProtocolNETSMS';
           String userName = ServiceParameter__c.getInstance(serviceName).User__c;
           String strReturn;
           List<String> lstReturn = new List<String>(); 
           //List<Case> casesToSync = getCasesForSync(caseIds);
           Solar_Cross_ClassificationNETSMS__mdt contestacaoMtd = [SELECT Application__c, SourceEvent__c,
                                                                      Identifier__c, IdentifierType__c, Description__c
                                                                      FROM Solar_Cross_ClassificationNETSMS__mdt 
                                                                      WHERE DeveloperName = 'ContestacaoFatura'];
           //System.debug('casesToSync: ' + casesToSync[0].Resolution__c + ' - ' + casesToSync[0].LegacyProtocol__c + ' - ' + casesToSync[0].InteractionNumber__c + ' - ' + casesToSync[0].ContractMSISDN__c);
           for(FlowInputVariables cs: flowInputVar){
               //main node
               CEC_OcurrencyNetRequest request = new CEC_OcurrencyNetRequest();
               request.application = contestacaoMtd.Application__c; //Solar
               //data node  
               CEC_OcurrencyNetRequest.Data data = new CEC_OcurrencyNetRequest.Data();
               data.reasonId = '1';
               data.sourceEvent = contestacaoMtd.SourceEvent__c; //SOLARCRM
               data.identifier = contestacaoMtd.Identifier__c; //1
               data.login = userName;
               data.note = contestacaoMtd.Description__c;
               data.identifierType = '794'; //794 ou 717
               data.description = contestacaoMtd.Description__c; //OV1 - OV5 - OUVIDORIA NIVEL I ou OV4 - ANALISE E RETORNO PARA CLIENTE
               data.protocol = '';
               System.debug('Contract Number:: ' + cs.contractNumber);
               data.contractNumber = (String.isNotEmpty(cs.contractNumber)) ? cs.contractNumber.substringAfter('/').trim() : '';
               System.debug('contractNumber: ' + data.contractNumber);
               data.operatorCode = (String.isNotEmpty(cs.contractNumber))? cs.contractNumber.substringBefore('/').trim() : '';
               System.debug('operatorCode: ' + data.operatorCode);
               data.interactionNumber = '';    
               request.data = data;
               System.debug('request.data: ' + request.data);
               //send request to NETSMS
               HttpResponse response = CEC_HttpReq.sendReq(serviceName, request);
               Integer status = response.getStatusCode();
               System.debug('response.getBody(): ' + response.getBody());
               if(status == 200){
                ProtocolsSolar returnNetSMS = (ProtocolsSolar) JSON.Deserialize(response.getBody(),ProtocolsSolar.class);
                    if(returnNetSMS.data != null){
                        strReturn = returnNetSMS.data.protocolNumber+'-'+returnNetSMS.data.interactionNumber;
                        System.debug('NETSMS Sync response: ' + response);
                    }else{
                        strReturn = 'Erro ao criar protocolo: Erro desconhecido'; 
                    }
               }else{
                    strReturn = 'Erro ao criar protocolo: código de erro: '+ String.valueOf(status);
                    
               }
               lstReturn.add(strReturn);
               
           }
           return lstReturn;
       }
       //verificar cenários de exceção
       public static List<String> createProtocolPS8(List<FlowInputVariables> flowInputVar, Set<String> products, Set<String> businessUnits){
           Map<String, Map<String, CEC_CC_PS8Classification__mdt>> classification = CEC_CC_ClassificationMdtDAO.getClassificationType(businessUnits, products);
           List<String> lstReturn = new List<String>();
           String strReturn;
           String strReturnIteraction;
          // List<Case> casesToSync = getCasesForSync(caseIds);
           for(FlowInputVariables cs: flowInputVar){
               /*if(!classification.containsKey(cs.BusinessUnit__c) && !classification.get(cs.BusinessUnit__c).containsKey(cs.Product__c)){
                   System.debug('Classificação (' + cs.BusinessUnit__c + 'x' + cs.Product__c + ') não encontrada para o caso: ' + cs.CaseNumber);
                   return;
               }
               if(String.isBlank(cs.ContractMSISDN__c) && cs.Product__c != 'Sem produto'){
                   System.debug('Número da Linha não informado para o caso: '  + cs.CaseNumber);
                   return;
               }*/
               Cross_ProtocolPS8Request request = new Cross_ProtocolPS8Request();
               Cross_ProtocolPS8Request.DataRequest data = new Cross_ProtocolPS8Request.DataRequest();
               data.companyId = classification.get(cs.businessUnit).get(cs.product).Company__c;
               data.channelRequestId = classification.get(cs.businessUnit).get(cs.product).ChannelRequestId__c;
               data.situation = classification.get(cs.businessUnit).get(cs.product).Situation__c;
               data.contactTypeId = classification.get(cs.businessUnit).get(cs.product).ContactTypeId__c;
               data.result = classification.get(cs.businessUnit).get(cs.product).Result__c;
               data.reasonCode1 = classification.get(cs.businessUnit).get(cs.product).ReasonCode1__c;
               data.reasonCode2 = classification.get(cs.businessUnit).get(cs.product).ReasonCode2__c;
               data.reasonCode3 = classification.get(cs.businessUnit).get(cs.product).ReasonCode3__c;
               data.reasonCode4 = classification.get(cs.businessUnit).get(cs.product).ReasonCode4__c;
               data.reasonCode5 = classification.get(cs.businessUnit).get(cs.product).ReasonCode5__c;
               data.summary = Label.Solar_Cross_PS8StandardDescription;
               data.description = Label.Solar_Cross_PS8StandardDescription ;       
               data.contactName = '';
               data.contactEmail = '';
               Cross_ProtocolPS8Request.Customer customer = new Cross_ProtocolPS8Request.Customer();
               customer.msisdn = cs.msisdn;
               System.debug('customer.msisdn: ' + customer.msisdn);
               data.customer = customer;
               request.data = data;
               HttpResponse response = CEC_HttpReq.sendReq('CEC_OAG_Claro_Protocol', request);
               Integer status = response.getStatusCode();
               System.debug('PS8 Sync response: ' + response);
               //lstReturn.add(String.valueOf(status));
               if(status == 200){
                    ProtocolsSolar returnPS8 = (ProtocolsSolar) JSON.Deserialize(response.getBody(),ProtocolsSolar.class);
                if(returnPS8.data != null){
                    strReturn = returnPS8.data.protocolNumber+'-';
                    System.debug('NETSMS Sync response: ' + response);
                }else{
                    strReturn = 'Erro ao criar protocolo: Erro desconhecido'; 
                }
                }else{
                    strReturn = 'Erro ao criar protocolo: código de erro: '+ String.valueOf(status);
                
                }
                lstReturn.add(strReturn);
           }
           return lstReturn;
       }
       
       public class FlowInputVariables{
           @InvocableVariable 
           public String businessUnit;
           @InvocableVariable
           public String product;
           @InvocableVariable
           public String msisdn;
           @InvocableVariable
           public String contractNumber;
           @InvocableVariable
           public String operatorCode;
       }
           //Usado pela classe Solar_GenerateProtocol NetSMS

           
    public class ProtocolsSolar {
        public  String apiVersion;
        public  String transactionId;
        public  dataProtocolsSolar data;
    }

    public class dataProtocolsSolar {
        public  String protocolNumber;
        public  String interactionNumber;
    }
  
}
   //Fim Solar_GenerateProtocol