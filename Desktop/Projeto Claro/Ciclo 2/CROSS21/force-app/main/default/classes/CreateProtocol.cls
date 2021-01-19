/*
 * ---------------------------------------------------------------
 * Data: 23/07/2020
 * Autor: Squad Canais Criticos - Sysmap Solutions(RODOLFO RODRIGO)
 * Descrição: [SOLAR] - [Time: SQUAD LGPD - Sprint 4] -
 * Exposição da API de Criação de Protocolo NETSMS/PS8 / Caso / Customer Interaction / Customer Interaction Topic
 * ---------------------------------------------------------------
 */
@ RestResource(urlMapping = '/createProtocol')
global class CreateProtocol{
    @HttpPost
    global static void  createProtocolController(string cpf, string requestType, string nome, string email, string telefone, string persona, string canal) {
        List<String> validation = new List<String>();
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = case.channel__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }
        CEC_LGPDdsar__mdt[] requestTypeList = [ SELECT DeveloperName, rightName__c,caseStatus__c,
                                               PS8status__c,NETSMSstatus__c,reasonCode1__c,reasonCode2__c,
                                               reasonCode3__c,reasonCode4__c,reasonCode5__c 
                                               FROM CEC_LGPDdsar__mdt
                                               WHERE DeveloperName = :RequestType
                                               LIMIT 1 ];
        
        
        Object validationStr;
        validationStr = CPF.length() == 11 ? '': validation.add('CPF');
        validationStr =  String.isNotBlank(requestType) && !requestTypeList.isEmpty() ? '' : validation.add('REQUESTTYPE');
        validationStr = String.isNotBlank(NOME)  ? '' : validation.add('NOME');
        validationStr = String.isNotBlank(EMAIL) ? '' : validation.add('EMAIL');
        validationStr = String.isNotBlank(TELEFONE) ? '' : validation.add('TELEFONE');
        validationStr = String.isNotBlank(CANAL) && pickListValuesList.contains(CANAL) ? '' : validation.add('CANAL');
        
        
        String jsonResponse = '';
        string error500 = '{"error": {"httpCode": "500","errorCode": "API-DETAILS-500","message": "Internal Server Error","detailedMessage": "Internal Server Error ';
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        
        
        
        try { 
            
            
    
            Account[] client = [SELECT name,id,CustomerTypeList__c,documentType__c,recordTypeId,Email__c,Phone 
                                FROM Account WHERE DocumentNumber__c  =: CPF limit 1];
            String detailedMessage = 'Parametros  Seguintes estao incorretos ' + validation;
            
            
            if (!validation.isEmpty()){
                res.statusCode = 400;
                jsonResponse = '{"error": {"httpCode": "400","errorCode": "API-DETAILS-400","message": "Bad Request","'+ detailedMessage+'": "Bad Request"}}';
                res.responseBody = blob.valueOf(jsonResponse);
                return;
                
            }
            if(validation.isEmpty() && client.isEmpty()) {
                
                Account acct = new Account(documentNumber__c = CPF, 
                                           name = NOME, 
                                           documentType__c ='CPF',
                                           recordTypeId = RecordTypeId,
                                           Email__c  = email,
                                           Phone = telefone,
                                           ExternalID_DL__c = 'CPF'+ CPF,
                                           vlocity_cmt__BillingEmailAddress__c = email,
                                           CustomerTypeList__c = persona
                                          );
                
                
                
                CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse protocolClass = CEC_LGPD_ProtocolController.integrateLGPDProtocol(acct,requestType,canal); 
                
                
                res.statusCode = protocolClass.data != null && protocolClass.data.protocol != null ? 200 : 500 ;
                jsonResponse = protocolClass.data != null && protocolClass.data.protocol != null  ?  '{ "Protocol": "' + protocolClass.data.protocol + '" }' : error500 +  protocolClass.error +'"}}';
                res.responseBody = blob.valueOf(jsonResponse);
                return; 
                
            }
            if(validation.isEmpty() && !client.isEmpty()) {
                // client[0].CustomerTypeList__c = persona;
                CEC_LGPD_ProtocolController.LGPDProtocolControllerResponse protocolClass = CEC_LGPD_ProtocolController.integrateLGPDProtocol(client[0],requestType,canal);
                //update client;
                res.statusCode = protocolClass.data != null && protocolClass.data.protocol != null ? 200 : 500 ;
                jsonResponse = protocolClass.data != null && protocolClass.data.protocol != null  ?  '{ "Protocol": "' + protocolClass.data.protocol + '" }' : error500 +  protocolClass.error +'"}}';
                //jsonResponse =  '{ "Protocol": "' + 'protocolClass.data.protocol' + '" }';
                res.responseBody = blob.valueOf(jsonResponse);
                return; 
                
            }
            
        } catch(Exception e) {
            res.statusCode = 500;
            jsonResponse = error500 +  e + '"}}';
            res.responseBody = blob.valueOf(jsonResponse);
            return;
        }
        
        
        
    }
    
    
}