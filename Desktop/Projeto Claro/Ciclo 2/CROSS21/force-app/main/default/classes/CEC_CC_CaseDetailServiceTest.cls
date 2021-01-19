/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-16-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-15-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class CEC_CC_CaseDetailServiceTest {
    @testSetup
    static void testSetup()
    {
        
        Account varAccount = CEC_SobjectFactory.getAccount();
        varAccount.Documentnumber__c = '123456789';
        Database.insert(varAccount);
        
        Account ct = CEC_SobjectFactory.getAccount();
        ct.Name = '003/123456789';
        ct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        ct.ParentId = varAccount.Id;
        ct.BusinessUnit__c = 'Net';
        Database.insert(ct);
        
        Asset at = new Asset();
        at.Name = '2121212121';
        at.AccountId = varAccount.Id;
        at.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECMovel').getRecordTypeId();
        database.insert(at);
        
        List<Case> lstCase = new List<Case>();
        Case c = new Case();
        c.AccountId = varAccount.Id;
        c.Channel__c = 'Ouvidoria';
        c.Grouping__c = 'Ouvidoria';
        c.Status = 'New';
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
        c.CriticalChannelOpenDate__c = Date.today();

        Case c2 = new Case();
        c2.AccountId = varAccount.Id;
        c2.Channel__c = 'Ouvidoria';
        c2.Grouping__c = 'Ouvidoria';
        c2.ContractBillingAccount__c = ct.Id;  
        c2.Status = 'New';
        c2.Channel__c = 'URA';
        c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();

        lstCase.add(c);
        lstCase.add(c2);
        insert lstCase;

        Parameters__c objParam = new Parameters__c();
        objParam.Business_Unit__c = 'Net';
        objParam.Channel__c = 'URA';
        objParam.SolarCrossStatus__c = 'New';
        objParam.Journey__c = 'Financial';
        objParam.FeedbackToCustomer__c = 'Caso em atendimento';
        objParam.RecordTypeId = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('SolarCrossAnswerMapping').getRecordTypeId();
        insert objParam;
        
        /*
        Group varGroup = [SELECT Id FROM Group WHERE DeveloperName = 'SemIdentificacaoPortais' AND Type = 'Queue'];
        
        GroupMember varGroupMember = new GroupMember();
        varGroupMember.UserOrGroupId =  UserInfo.getUserId();
        varGroupMember.GroupId = varGroup.Id;
        insert varGroupMember;
        */
    }   
    
    @isTest
    static void testCaseDetailServiceAPICC() 
    {
        String rtFinancial = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
        List<Case> objCase = [SELECT Id, CaseNumber FROM Case WHERE RecordTypeId = :rtFinancial];
        RestRequest requestDetail = new RestRequest(); 
        RestContext.request = requestDetail;   
                
        requestDetail.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/api/caseDetailService/caseNumber/'+objCase[0].CaseNumber;
        requestDetail.httpMethod = 'GET';   
        
        test.startTest();
        
       	 CEC_CC_CaseDetailService.Response responseDetailCase = CEC_CC_CaseDetailService.doGet();
        	//system.assert(responseDetailCase.results.size() > 0, 'Nenhum retorno processado para a API CEC_CC_CaseDetailService');
        	CEC_CC_CaseDetailService.CaseResult caseDetailResult = responseDetailCase.results[0];
        	//system.assertEquals(false, caseDetailResult.isSuccess, 'Erro ao realizar consulta');    
        
        test.stopTest();
    }

    @isTest
    static void testCaseDetailServiceAPIFinancial() 
    {
        String rtFinancial = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        List<Case> objCase = [SELECT Id, CaseNumber FROM Case WHERE RecordTypeId = :rtFinancial];
        List<Parameters__c> lstParam = [SELECT Id,FeedbackToCustomer__c FROM Parameters__c WHERE Channel__c = 'URA'];
        RestRequest requestDetail = new RestRequest(); 
        RestContext.request = requestDetail;   
                
        requestDetail.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/api/caseDetailService/caseNumber/'+objCase[0].CaseNumber;
        requestDetail.httpMethod = 'GET';   
        
        test.startTest();
        
       	CEC_CC_CaseDetailService.Response responseDetailCase = CEC_CC_CaseDetailService.doGet();
        CEC_CC_CaseDetailService.CaseResult caseDetailResult = responseDetailCase.results[0];
        test.stopTest();
        system.assertEquals(true, caseDetailResult.isSuccess);
        System.assertEquals(lstParam[0].FeedbackToCustomer__c, caseDetailResult.caseDetail.description);

    }

    @isTest
    static void testCaseDetailServiceEmptyList() 
    {
        String rtFinancial = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        List<Case> objCase = [SELECT Id, CaseNumber FROM Case WHERE RecordTypeId = :rtFinancial];
        RestRequest requestDetail = new RestRequest(); 
        RestContext.request = requestDetail;   
                
        requestDetail.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/api/caseDetailService/caseNumber/0000';
        requestDetail.httpMethod = 'GET';   
        
        test.startTest();
        
       	 CEC_CC_CaseDetailService.Response responseDetailCase = CEC_CC_CaseDetailService.doGet();
        //	system.assert(responseDetailCase.results.size() > 0, 'Nenhum retorno processado para a API CEC_CC_CaseDetailService');
        	CEC_CC_CaseDetailService.CaseResult caseDetailResult = responseDetailCase.results[0];
        	//system.assertEquals(false, caseDetailResult.isSuccess, 'Erro ao realizar consulta');    
        
        test.stopTest();
    }
    
    
    private static CEC_CC_CaseService.Cases generateCaseAPI(String accountIdentifier)
    {
        CEC_CC_CaseService.Cases newCase = new CEC_CC_CaseService.Cases();
        
        newCase.recordType = 'CEC_CC_OUVIDORIA';
        newCase.reason = 'CANCELAMENTO';
        newCase.description = 'TESTE';
        newCase.criticalChannelProtocol = '2019/669691234567';
        newCase.contractNumber = '003/123456789';
        newCase.additionalInformation = 'infos';
        newCase.accountIdentifier = accountIdentifier;
        newCase.accountName = 'Baltazar Barata';
        newCase.accountEmail = 'baltazar@email.com';
        newCase.businessUnit = 'Net';
        newCase.grouping = 'Ouvidoria';
        newCase.channel = 'Ouvidoria';
        newCase.inputType = 'Formulário Minha Net'; 
        
        return newCase;
    }
    
    private static CEC_CC_CaseService.Cases generateCaseClaroAPI(String accountIdentifier)
    {
        CEC_CC_CaseService.Cases newCase = new CEC_CC_CaseService.Cases();
        
        newCase.recordType = 'CEC_CC_OUVIDORIA';
        newCase.reason = 'CANCELAMENTO';
        newCase.description = 'TESTE';
        newCase.criticalChannelProtocol = '2019/669691234567';
        newCase.contractNumber = '003/123456789';
        newCase.additionalInformation = 'infos';
        newCase.accountIdentifier = accountIdentifier;
        newCase.accountName = 'Baltazar Barata';
        newCase.accountEmail = 'baltazar@email.com';
        newCase.businessUnit = 'Claro';
        newCase.msisdn = '2121212121';
        newCase.grouping = 'Ouvidoria';
        newCase.channel = 'Ouvidoria';
        newCase.inputType = 'Formulário Minha Net'; 
        
        return newCase;
    }
}