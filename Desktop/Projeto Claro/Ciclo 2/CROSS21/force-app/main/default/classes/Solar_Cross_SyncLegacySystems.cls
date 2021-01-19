/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-11-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-03-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/

public class Solar_Cross_SyncLegacySystems {
    @InvocableMethod(label='Sincronizar com sistemas legados' 
                     description='Envia casos fechados para os sistemas legados da Claro (PS8, NETSMS e etc...)' 
                     category='Case')
    public static void syncWithLegacySystems(List<Id> caseIds) {
        //Variables (internal)
        System.debug('Entrou no sync LegacySystem');
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> classification;
        List<Case> casesFromPB = getCasesForSync(caseIds);
        List<String> caseIdsForNETSMS = new List<String>();
        List<String> caseIdsForPS8 = new List<String>();
        Set<String> products = new Set<String>();
        Set<String> businessUnits = new Set<String>();
        Set<String> recordTypeNames = new Set<String>();
        //create a set of products and business units to check on metadata (CEC_CC_PS8Classification__mdt)
        for(Case cs : casesFromPB){
            products.add(cs.Product__c);
            businessUnits.add(cs.BusinessUnit__c);
            recordTypeNames.add(cs.RecordType.DeveloperName);
        }
        //search for metadata (CEC_CC_PS8Classification__mdt)
        classification = CEC_CC_ClassificationMdtDAO.getClassificationType(businessUnits, products);
        //check for cases and send to legacy systems (PS8, NETSMS and etc...)
        for(Case cs: casesFromPB){
            if(classification.containsKey(cs.BusinessUnit__c) && classification.get(cs.BusinessUnit__c).containsKey(cs.Product__c)){
               if(classification.get(cs.BusinessUnit__c).get(cs.Product__c).Legacy__c == 'NETSMS'){
                   caseIdsForNETSMS.add(cs.Id);
               }else if(classification.get(cs.BusinessUnit__c).get(cs.Product__c).Legacy__c == 'PS8'){
                   System.debug('Entrou aqui');
                   caseIdsForPS8.add(cs.Id);
               }
            }
        }
      //use future methods to sync with legacy systems

        if(!caseIdsForNETSMS.isEmpty() && !Test.isRunningTest()) createOcurrencyNETSMS(caseIdsForNETSMS);
        if(!caseIdsForPS8.isEmpty() && !Test.isRunningTest()) createProtocolPS8(caseIdsForPS8, products, businessUnits,recordTypeNames);

    }
    //verificar cenários de exceção
    @future(callout=true)
    public static void createOcurrencyNETSMS(List<String> caseIds){
        String serviceName = 'CEC_OAG_NET_Ocurrency';
        String userName = ServiceParameter__c.getInstance(serviceName).User__c; 
        List<Case> casesToSync = getCasesForSync(caseIds);
        Solar_Cross_ClassificationNETSMS__mdt contestacaoMtd = [SELECT Application__c, SourceEvent__c,
                                                                   Identifier__c, IdentifierType__c, Description__c
                                                                   FROM Solar_Cross_ClassificationNETSMS__mdt 
                                                                   WHERE DeveloperName = 'ContestacaoFatura'];
        System.debug('casesToSync: ' + casesToSync[0].Resolution__c + ' - ' + casesToSync[0].LegacyProtocol__c + ' - ' + casesToSync[0].InteractionNumber__c + ' - ' + casesToSync[0].ContractMSISDN__c);
        for(Case cs: casesToSync){
            //main node
            CEC_OcurrencyNetRequest request = new CEC_OcurrencyNetRequest();
            request.application = contestacaoMtd.Application__c; //Solar
            //data node
            CEC_OcurrencyNetRequest.Data data = new CEC_OcurrencyNetRequest.Data();
            data.sourceEvent = contestacaoMtd.SourceEvent__c; //SOLARCRM
            data.identifier = contestacaoMtd.Identifier__c; //1
            data.login = userName;


            if(cs.Description != null && cs.Resolution__c == null){
                data.note = cs.Description;
            }else if(cs.Resolution__c != null){
                data.note = cs.Resolution__c;
            }
           // data.note = String.isBlank(cs.Resolution__c)?  'Protocolo encerrado com sucesso no Solar.': cs.Resolution__c;

            data.identifierType = contestacaoMtd.IdentifierType__c; //794
            data.description = contestacaoMtd.Description__c; //OV1 - OV5 - OUVIDORIA NIVEL I
            data.contractNumber = (String.isNotEmpty(cs.ContractBillingAccount__r.ContractNumber__c)) ? cs.ContractBillingAccount__r.ContractNumber__c.substringAfter('/').trim() : '';
            System.debug('data.contractNumber: ' + data.contractNumber);
            data.operatorCode = (String.isNotEmpty(cs.ContractBillingAccount__r.ContractNumber__c))? cs.ContractBillingAccount__r.ContractNumber__c.substringBefore('/').trim() : '';  
            System.debug('data.operatorCode ' + data.operatorCode);
            data.protocol = cs.LegacyProtocol__c;
            System.debug('LegacyProtocol__c: ' + cs.LegacyProtocol__c);

            data.interactionNumber = cs.InteractionNumber__c;//cs.InteractionNumber__c;    
            request.data = data;
            System.debug('request:: ' + request);

            //send request to NETSMS
            String response = CEC_HttpReq.sendReq(serviceName, request).getBody();
            System.debug('NETSMS Sync response: ' + response);  
        }
    }
    //verificar cenários de exceção
    @future(callout=true)
    public static void createProtocolPS8(List<String> caseIds, Set<String> products, Set<String> businessUnits,Set<String> recordTypeNames){
        System.debug('Entrou no PS8');
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> classification = CEC_CC_ClassificationMdtDAO.getClassificationType(businessUnits, products,recordTypeNames);
        List<Case> casesToSync = getCasesForSync(caseIds);
        for(Case cs: casesToSync){
            /*
            Cross_ProtocolPS8Request request = new Cross_ProtocolPS8Request();
            Cross_ProtocolPS8Request.DataRequest data = new Cross_ProtocolPS8Request.DataRequest();
            data.companyId = classification.get(cs.BusinessUnit__c+cs.RecordType.DeveloperName).get(cs.Product__c).Company__c;
            data.channelRequestId = classification.get(cs.BusinessUnit__c+cs.RecordType.DeveloperName).get(cs.Product__c).ChannelRequestId__c;
            data.situation = classification.get(cs.BusinessUnit__c+cs.RecordType.DeveloperName).get(cs.Product__c).Situation__c;
            data.contactTypeId = classification.get(cs.BusinessUnit__c+cs.RecordType.DeveloperName).get(cs.Product__c).ContactTypeId__c;
            data.result = classification.get(cs.BusinessUnit__c+cs.RecordType.DeveloperName).get(cs.Product__c).Result__c;
            data.reasonCode1 = classification.get(cs.BusinessUnit__c+cs.RecordType.DeveloperName).get(cs.Product__c).ReasonCode1__c;
            data.reasonCode2 = classification.get(cs.BusinessUnit__c+cs.RecordType.DeveloperName).get(cs.Product__c).ReasonCode2__c;
            data.reasonCode3 = classification.get(cs.BusinessUnit__c+cs.RecordType.DeveloperName).get(cs.Product__c).ReasonCode3__c;
            data.reasonCode4 = classification.get(cs.BusinessUnit__c+cs.RecordType.DeveloperName).get(cs.Product__c).ReasonCode4__c;
            data.reasonCode5 = classification.get(cs.BusinessUnit__c+cs.RecordType.DeveloperName).get(cs.Product__c).ReasonCode5__c;
            data.summary = cs.Output_Subject__r.Name;
            data.description = getDescription(classification.get(cs.BusinessUnit__c+cs.RecordType.DeveloperName).get(cs.Product__c).Description__c, cs);        
            data.contactName = cs.Contact.Name;
            data.contactEmail = cs.ContactEmail;
            Cross_ProtocolPS8Request.Customer customer = new Cross_ProtocolPS8Request.Customer();
            customer.msisdn = getMSISDN(cs.ContractMSISDN__c);
            data.customer = customer;
            request.data = data;*/
            Cross_UpdateProtocolPS8JSON.Request request = new Cross_UpdateProtocolPS8JSON.Request();
            Cross_UpdateProtocolPS8JSON.Data data = new Cross_UpdateProtocolPS8JSON.Data();
            data.companyId = classification.get(cs.BusinessUnit__c + cs.RecordType.DeveloperName).get(cs.Product__c).Company__c; 
            data.directionCode = ''; //Não necessário
            data.callId = ''; //Não necessário
            data.orderId = ''; //Não necessário
            data.customer = getCustomer(cs);
            data.interaction = getInteraction(cs); //Não necessário
            data.productComponentId = ''; //Não necessário
            data.channelRequestId = classification.get(cs.BusinessUnit__c + cs.RecordType.DeveloperName).get(cs.Product__c).ChannelRequestId__c;
            data.situation = classification.get(cs.BusinessUnit__c + cs.RecordType.DeveloperName).get(cs.Product__c).Situation__c;
            data.reasonCode1 = classification.get(cs.BusinessUnit__c + cs.RecordType.DeveloperName).get(cs.Product__c).ReasonCode1__c;
            data.reasonCode2 = classification.get(cs.BusinessUnit__c + cs.RecordType.DeveloperName).get(cs.Product__c).ReasonCode2__c;
            data.reasonCode3 = classification.get(cs.BusinessUnit__c + cs.RecordType.DeveloperName).get(cs.Product__c).ReasonCode3__c;
            data.reasonCode4 = classification.get(cs.BusinessUnit__c + cs.RecordType.DeveloperName).get(cs.Product__c).ReasonCode4__c;
            data.reasonCode5 = classification.get(cs.BusinessUnit__c + cs.RecordType.DeveloperName).get(cs.Product__c).ReasonCode5__c;
            data.summary = cs.Output_Subject__r.Name;
            data.description = getDescription(classification.get(cs.BusinessUnit__c + cs.RecordType.DeveloperName).get(cs.Product__c).Description__c, cs);
            data.address = getAddress();
            data.contactTypeId = classification.get(cs.BusinessUnit__c + cs.RecordType.DeveloperName).get(cs.Product__c).ContactTypeId__c;
            data.contactTelephoneNumber = ''; //Não necessário
            data.contactEmail = cs.ContactEmail;
            data.contactName = cs.Contact.Name;
            data.contactReturnType = ''; //Não necessário
            data.result = classification.get(cs.BusinessUnit__c + cs.RecordType.DeveloperName).get(cs.Product__c).Result__c;
            data.attachments = getAttachments(); // Não necessário
            data.survey = getSurvey(); //Não necessário
            data.sfcase = getSfCase();//Não necessário
            data.relatedCases = getRelatedCases(); //Não necessário
            data.sms = getSMS(); //Não necessário
            request.data = data;
            String jsRequest = JSON.serialize(request).replace('sfcase', 'case').replace('sfCase', 'Case').replace('streetNumber', 'number');
            System.debug('PS8 Sync request: ' + jsRequest);
            Integer response = CEC_HttpReq.sendReq('CEC_OAG_Claro_Protocol', request).getstatuscode();//original
            //String response = '{"apiVersion": "string","transactionId": "string","data": {"protocolNumber": "0303929","interactionNumber": "020498283"}}';//mock
            System.debug('PS8 Sync response: ' + response);
        }
    }
    
    @TestVisible
    private static List<Case> getCasesForSync(List<Id> caseIds){
        return [SELECT Id, RecordTypeId, BusinessUnit__c, Resolution__c,RecordType.DeveloperName,
                ContractMSISDN__c, LegacyProtocol__c, InteractionNumber__c,  ContactEmail,

                CaseNumber, Output_Subject__r.Name, Description, Product__c, Contact.Name,RequestSupport__c,

                Channel__c, InputType__c, ContractBillingAccount__r.ContractNumber__c, ProtocolNumber__c,Solar_Cross_forwardingReason__c,isClosed
                FROM Case 
                WHERE Id IN: caseIds];
    }
    @TestVisible
    private static String getMSISDN(String varContract){
        if(String.isEmpty(varContract)){
            return '';
        }else{
            Decimal contractOnlyNumbersDecimal = Decimal.valueOf(varContract.trim());
            varContract = String.valueOf(contractOnlyNumbersDecimal);
            return varContract; 
        }
    }
    //ver com o pink mensagem específica para esse cenário
    @testVisible 
    private static String getDescription(String message, Case cs){
        if(String.isNotBlank(message)){
            message =+ '/n';
            //Mensagem padrão de envio ao PS8
            message =+ 'Caso fechado para o canal ' + cs.Channel__c + ' via ' + cs.InputType__c + '\n';     
            message =+ 'Descrição: ' + cs.Description  + '\n';
            message =+ 'Resolução: ' + cs.Resolution__c;
            return message;
        }else{
            return '';
        }
    }
    
    @testVisible 
    private static Cross_UpdateProtocolPS8JSON.Customer getCustomer(Case cs){
        Cross_UpdateProtocolPS8JSON.Customer customer = new Cross_UpdateProtocolPS8JSON.Customer();
        customer.crmId = ''; //Não necessário
        customer.accountId = ''; //Não necessário
        customer.partyId = ''; //Não necessário
        customer.contractNumber = ///Não necessário
        customer.msisdn = getMSISDN(cs.ContractBillingAccount__r.ContractNumber__c);
        system.debug('MSISDN'+ customer.msisdn);
        return customer;
    }
    
    @testVisible 
    private static Cross_UpdateProtocolPS8JSON.Interaction getInteraction(Case cs){
        Cross_UpdateProtocolPS8JSON.Interaction interaction = new Cross_UpdateProtocolPS8JSON.Interaction();
        interaction.interactionId = ''; //Não necessário
      	interaction.protocolNumber = cs.LegacyProtocol__c;
        interaction.interactionStartDateTime = ''; //Não necessário
        interaction.context = ''; //Não necessário 
        interaction.mainProtocol = ''; //Não necessário
        interaction.userAuthenticated = getUserAuthenticated();  
        interaction.sendType = ''; //Não necessário
        return interaction;
    }
    
    @testVisible 
    private static Cross_UpdateProtocolPS8JSON.UserAuthenticated getUserAuthenticated(){
        Cross_UpdateProtocolPS8JSON.UserAuthenticated userAuthenticated = new Cross_UpdateProtocolPS8JSON.UserAuthenticated();
        userAuthenticated.userId = ''; //Não necessário
        userAuthenticated.authenticationDatetime = ''; //Não necessário
        userAuthenticated.authenticationReason = '';  //Não necessário
        userAuthenticated.sourceAppId = '';  //Não necessário
        userAuthenticated.sourceOperationId = ''; //Não necessário
        return userAuthenticated;
    }
    
    @testVisible
    private static Cross_UpdateProtocolPS8JSON.Address getAddress(){
        Cross_UpdateProtocolPS8JSON.Address address = new Cross_UpdateProtocolPS8JSON.Address();
        address.prefix = ''; //Não necessário
        address.streetAddress = ''; //Não necessário
        address.streetNumber = ''; //Nome da variavel original: number
        address.complement = ''; //Não necessário
        address.district = ''; //Não necessário
        address.city = ''; //Não necessário
        address.state = ''; //Não necessário
        address.zipCode = ''; //Não necessário
        return address;
    }
    
    @testVisible
    private static List<Cross_UpdateProtocolPS8JSON.Attachment> getAttachments(){
        List<Cross_UpdateProtocolPS8JSON.Attachment> attachments = new List<Cross_UpdateProtocolPS8JSON.Attachment>();
        Cross_UpdateProtocolPS8JSON.Attachment attachment = new Cross_UpdateProtocolPS8JSON.Attachment();
        attachment.sequence = ''; //Não necessário
        attachment.name = ''; //Não necessário
        attachment.url = ''; //Não necessário
        attachments.add(attachment);
        return attachments;
    }
    
    @testVisible
    private static Cross_UpdateProtocolPS8JSON.Survey getSurvey(){
        Cross_UpdateProtocolPS8JSON.Survey survey = new Cross_UpdateProtocolPS8JSON.Survey();
        survey.id = ''; //Não necessário
        survey.effectiveDate = ''; //Não necessário
        survey.questions = getQuestions();
        return survey;
    }
    
    @testVisible
    private static List<Cross_UpdateProtocolPS8JSON.Question> getQuestions(){
        List<Cross_UpdateProtocolPS8JSON.Question> questions = new List<Cross_UpdateProtocolPS8JSON.Question>();
        Cross_UpdateProtocolPS8JSON.Question question = new Cross_UpdateProtocolPS8JSON.Question();
        question.id = ''; //Não necessário
        question.answers = getAnswers();
        questions.add(question);
        return questions;
    }
    
    @testVisible
    private static List<Cross_UpdateProtocolPS8JSON.Answer> getAnswers(){
        List<Cross_UpdateProtocolPS8JSON.Answer> answers = new List<Cross_UpdateProtocolPS8JSON.Answer>();
        Cross_UpdateProtocolPS8JSON.Answer answer = new Cross_UpdateProtocolPS8JSON.Answer();
        answer.id = ''; //Não necessário
        answer.text = ''; //Não necessário
        answer.comments = ''; //Não necessário
        answers.add(answer);
        return answers;
    }
    
    @testVisible
    private static Cross_UpdateProtocolPS8JSON.sfCase getSfCase(){
        Cross_UpdateProtocolPS8JSON.sfCase sfCase = new Cross_UpdateProtocolPS8JSON.sfCase();
        sfCase.caseTypeId = ''; //Não necessário
        sfCase.severity = ''; //Não necessário
        sfCase.slaDueDate = ''; //Não necessário
        sfCase.priorityExecution = ''; //Não necessário
        return sfCase;
    }
    
    @testVisible
    private static List<Cross_UpdateProtocolPS8JSON.RelatedCas> getRelatedCases(){
        List<Cross_UpdateProtocolPS8JSON.RelatedCas> relatedCases = new List<Cross_UpdateProtocolPS8JSON.RelatedCas>();
        Cross_UpdateProtocolPS8JSON.RelatedCas relatedCas = new Cross_UpdateProtocolPS8JSON.RelatedCas();
        relatedCas.id = ''; //Não necessário
        relatedCas.systemRelatedCaseId = ''; //Não necessário
        relatedCases.add(relatedCas);
        return relatedCases;
    }
    
    @testVisible
    private static Cross_UpdateProtocolPS8JSON.Sms getSMS(){
        Cross_UpdateProtocolPS8JSON.Sms sms = new Cross_UpdateProtocolPS8JSON.Sms();
        sms.content = ''; //Não necessário
        sms.priority = false; //Não necessário
        return sms;
    }
}