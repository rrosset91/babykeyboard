/*-------------------------------------------------------------------------------------------------------
--- Company: Deloitte Brazil
--- Creation Date: 23/10/2019
--- Author: Squad Canais Críticos
--- Description: [CEC - Extensção Fase 1] - Serviço que retorna o histórico do caso 
-------------------------------------------------------------------------------------------------------*/

@RestResource(urlMapping='/api/caseDetailService/*')
global with sharing class CEC_CC_CaseDetailService 
{    
	@testVisible    
    private static final String CEC_CC_Ouvidoria = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
     @testVisible 
    private static final String CEC_CC_ConsumidorGov = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Anatel = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Anatel').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_AtendimentoPessoal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_AtendimentoPessoal').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_CanaisInternos = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_CanaisInternos').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Canais_Eletronicos = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Canais_Eletronicos').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_JEC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_JEC').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Pre_JEC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Pre_JEC').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_Procon = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
    @testVisible 
    private static final String CEC_CC_ReaberturaAnatel = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_ReaberturaAnatel').getRecordTypeId();
    
    
    @HttpGet
    global static Response doGet() 
    {
        // Properties
        Set<Id> IdRecordType = new Set<Id>(); 
        IdRecordType.add(CEC_CC_Ouvidoria); 
        IdRecordType.add(CEC_CC_ConsumidorGov);
        IdRecordType.add(CEC_CC_Anatel);
        IdRecordType.add(CEC_CC_CanaisInternos);
        IdRecordType.add(CEC_CC_Canais_Eletronicos);
        IdRecordType.add(CEC_CC_JEC);
        IdRecordType.add(CEC_CC_Pre_JEC);
        IdRecordType.add(CEC_CC_Procon);
        IdRecordType.add(CEC_CC_ReaberturaAnatel);
        IdRecordType.add(CEC_CC_AtendimentoPessoal);
        
        string caseNumber='';
        string cpf = '';
        datetime dateStart;
        datetime dateEnd;
        
        RestRequest request = RestContext.request;
        Response response = new Response();
        response.results = new List<CaseResult>(); 
        CaseResult resultError = new CaseResult();
        List<Case> lstCases = new List<Case>();
        Map<String,String> mapParameters= new Map<String,String>();
        String parameterMapRT = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('SolarCrossAnswerMapping').getRecordTypeId();
        String financialRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        // Request validation casenumber
        if(request.requestURI.contains('caseNumber'))
        {
            caseNumber = request.requestURI.substringAfter('/caseNumber/');
            lstCases = 
                [SELECT CaseNumber, Status, SubStatus__c, Description, OpenDateRobot__c,
                 CriticalChannelOpenDate__c, ClosedDate, Category__c,RecordType.Name, Channel__c,
                 Input_Subject__r.Reason__c,Modalidade__c,Input_Subject__r.SubReason__c,legacyProtocol__c, 
                 EntryReason__c,LeavingReason__c,Input_Subject__r.Classification__c, CreatedDate,RecordType.DeveloperName,RecordTypeId,
                 Resolution__c,ContractBillingAccount__r.BusinessUnit__c,ToLabel(Origin), Solar_Cross_SLAViolado__c
                 FROM Case
                 WHERE CaseNumber =: caseNumber];
        }
        else
        {
            // Request validation cpf + periodo 
            cpf = request.requestURI.substringAfter('/cpf/').substringBefore('/dateStart/');
            dateStart = DateTime.newInstanceGmt(date.valueOf(request.requestURI.substringAfter('/dateStart/').substringBefore('/dateEnd/')), Time.newInstance(0, 0, 0, 0));
            dateEnd = DateTime.newInstanceGmt(date.valueOf(request.requestURI.substringAfter('/dateEnd/')), Time.newInstance(23,59, 59, 59));
                
            // Request período superior a 180 dias 
            if(dateStart > System.today().addDays(-Integer.valueOf(Label.CEC_CC_QtdDiasConsultaPortal)))
            {   
                lstCases = 
                    [SELECT CaseNumber, Status, SubStatus__c, Description, OpenDateRobot__c,
                     CriticalChannelOpenDate__c, ClosedDate, Category__c,RecordType.Name, Channel__c,
                     Input_Subject__r.Reason__c,Modalidade__c,Input_Subject__r.SubReason__c,legacyProtocol__c,
                     EntryReason__c,LeavingReason__c,Input_Subject__r.Classification__c, CreatedDate,RecordType.DeveloperName, RecordTypeId,
                     Resolution__c,ContractBillingAccount__r.BusinessUnit__c, ToLabel(Origin)
                     FROM Case
                     WHERE AccountId IN (SELECT Id 
                                         FROM Account
                                         Where DocumentNumber__c =: cpf)
                     AND RecordTypeId IN: (IdRecordType)
                     AND (CriticalChannelOpenDate__c >: dateStart OR OpenDateRobot__c >: dateStart)
                     AND (CriticalChannelOpenDate__c <=: dateEnd OR OpenDateRobot__c <=: dateEnd)]; 
                
            }else
            {
                resultError.isSuccess = false;
                resultError.message = 'Período superior a '+Integer.valueOf(Label.CEC_CC_QtdDiasConsultaPortal)+' dia(s).';
                response.results.add(resultError);
                return response;
            }           
        }
        
        // Result validation
        if(lstCases.isEmpty()){
            resultError.isSuccess = false;
            
            if(String.isNotEmpty(caseNumber) || String.isNotBlank(caseNumber))
                resultError.message = 'Caso ' + caseNumber + ' não encontrado.';
            else
                resultError.message = 'Caso não encontrado para os parâmetros informado.';
            
            response.results.add(resultError);
        }
        else 
        {
            String lstJourney;
            Set<String> lstChannel = new Set<String>();
            Set<String> lstStatus  = new Set<string>();
            Set<String> lstBusinessUnit = new Set<String>();
            for(Case objCase : lstCases){
                if(lstJourney != null && !lstJourney.contains(objCase.RecordType.DeveloperName)){
                    lstJourney +=  ', ' + '\''+objCase.RecordType.DeveloperName+'\'';
                }else if(lstJourney == null){
                    lstJourney = '\''+objCase.RecordType.DeveloperName+'\''; 
                }
                lstChannel.add(objCase.Channel__c);
                lstStatus.add(objCase.Status);
                lstBusinessUnit.add(objCase.ContractBillingAccount__r.BusinessUnit__c);
            }
            String queryParam = 'Select id,SolarCrossStatus__c, Channel__c, Journey__c,FeedbackToCustomer__c, Solar_Cross_SLAViolado__c,Business_Unit__c FROM Parameters__c WHERE Journey__c INCLUDES ('+lstJourney+') AND Channel__c IN :lstChannel AND SolarCrossStatus__c IN :lstStatus AND Business_Unit__c IN :lstBusinessUnit  AND RecordTypeId = :parameterMapRT';
            List<Parameters__c> lstParameters  = Database.query(queryParam);
            map<String, String> mapStatusPickValByLabel = CEC_CC_Util.getPicklistValueByLabel('Case', 'Status');
            map<String, String> mapSubStatusPickValByLabel = CEC_CC_Util.getPicklistValueByLabel('Case', 'SubStatus__c');
            map<String, String> mapCategoryPickValByLabel = CEC_CC_Util.getPicklistValueByLabel('Case', 'Category__c');
            for(Parameters__c objParameter : lstParameters){
                List<String> lstJourneys = objParameter.Journey__c.split(';');
                for(String journey : lstJourneys){
                    String key = objParameter.Channel__c + objParameter.SolarCrossStatus__c + journey + objParameter.Business_Unit__c + objParameter.Solar_Cross_SLAViolado__c;
                    if(mapParameters.get(key)== null)
                        mapParameters.put(key,objParameter.FeedbackToCustomer__c);
                }
                
            }
            for(Case item : lstCases)
            {   
                CaseResult result = new CaseResult();
                result.caseDetail = new Cases();
                String key  = item.Channel__c + item.status + item.RecordType.DeveloperName + item.ContractBillingAccount__r.BusinessUnit__c+item.Solar_Cross_SLAViolado__c;
                if(item.RecordTypeId == financialRT){
                    result.isSuccess = true;
                    result.caseDetail.protocolNumber    = item.legacyProtocol__c;
                    result.caseDetail.openDate      = Datetime.newInstanceGmt(date.valueOf(item.CreatedDate), item.CreatedDate.time());
                    result.caseDetail.closeDate		= item.ClosedDate != null ? Datetime.newInstanceGmt(date.valueOf(item.ClosedDate), item.ClosedDate.time()) : item.ClosedDate;
                    result.caseDetail.description   = mapParameters.get(key) != null ? mapParameters.get(key) : item.Resolution__c;
                    result.caseDetail.category 		= mapCategoryPickValByLabel.get(item.Category__c);
                    result.caseDetail.status      	= mapStatusPickValByLabel.get(item.Status);
                    result.caseDetail.subStatus     = mapSubStatusPickValByLabel.get(item.SubStatus__c);
                    result.caseDetail.type          = item.RecordType.Name;
                    result.caseDetail.channel       = item.Channel__c;
                    result.caseDetail.reason        = item.Modalidade__c;
                    result.caseDetail.subReason     = item.EntryReason__c;
                    result.caseDetail.reasonClassification      = item.LeavingReason__c;
                    result.caseDetail.origin        = item.origin;
                    result.caseDetail.caseId        = item.id;

                }else{
                    result.isSuccess = true;
                    result.caseDetail.caseNumber  	= item.CaseNumber;
                    result.caseDetail.openDate    	= item.CriticalChannelOpenDate__c != null ? Datetime.newInstanceGmt(date.valueOf(item.CriticalChannelOpenDate__c), item.CriticalChannelOpenDate__c.time()) : Datetime.newInstanceGmt(date.valueOf(item.OpenDateRobot__c), item.OpenDateRobot__c.time());
                    result.caseDetail.closeDate		= item.ClosedDate != null ? Datetime.newInstanceGmt(date.valueOf(item.ClosedDate), item.ClosedDate.time()) : item.ClosedDate;
                    result.caseDetail.description 	= mapParameters.get(key) != null ? mapParameters.get(key) : item.Description; 
                    result.caseDetail.category 		= mapCategoryPickValByLabel.get(item.Category__c);
                    result.caseDetail.status      	= mapStatusPickValByLabel.get(item.Status);
                    result.caseDetail.subStatus     = mapSubStatusPickValByLabel.get(item.SubStatus__c);
                    result.caseDetail.type          = item.RecordType.Name;
                    result.caseDetail.channel       = item.Channel__c;
                    result.caseDetail.reason        = item.Input_Subject__r.Reason__c;
                    result.caseDetail.subReason     = item.Input_Subject__r.SubReason__c;
                    result.caseDetail.reasonClassification      = item.Input_Subject__r.Classification__c;
                    result.caseDetail.origin        = item.origin;
                    result.caseDetail.caseId        = item.id;
                }                 
                response.results.add(result);           
            }
        }
        
        return response;
    }            
    
    global class Response {
        @testVisible global List<CaseResult> results {get;set;}         
    }    
    
    global class CaseResult {
        @testVisible Boolean isSuccess {get;set;}
        @testVisible String message {get;set;}
        @testVisible Cases caseDetail {get;set;}
    }
    
    global class Cases {
        @testVisible String protocolNumber {get;set;}
        @testVisible String caseNumber {get;set;}
        @testVisible Datetime openDate {get;set;}
        @testVisible Datetime closeDate {get;set;}
        @testVisible String category {get;set;}
        @testVisible String description {get;set;}
        @testVisible String status {get;set;}
        @testVisible String subStatus {get;set;}
        @testVisible String type {get;set;}
        @testVisible String origin {get;set;}
        @testVisible String channel {get;set;}
        @testVisible String reason {get;set;}
        @testVisible String subReason {get;set;}
        @testVisible String reasonClassification {get;set;}
        @testVisible String caseId {get;set;}
    }  
}