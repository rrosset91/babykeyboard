/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 29/10/2019
* Descrição: [CEC - Extensção Fase 1] - [Time: SQUAD Canais Criticos - Sprint 13] - [Serviço de criação de casos]
* 
* Controle de Versão
* --------------------------------------------------------------- 
*/
@isTest
public class CEC_CC_CaseServiceTest {
    
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
        Database.insert(ct);
        
        Asset at = new Asset();
        at.Name = '2121212121';
        at.AccountId = varAccount.Id;
        at.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECMovel').getRecordTypeId();
        database.insert(at);
        
        Case c = new Case();
        c.AccountId = varAccount.Id;
        c.Channel__c = 'Ouvidoria';
        c.Grouping__c = 'Ouvidoria';
        c.InputType__c = 'Portal';
        c.Status = 'New';
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
        insert c;
        
        /*
        Group varGroup = [SELECT Id FROM Group WHERE DeveloperName = 'SemIdentificacaoPortais' AND Type = 'Queue'];
        
        GroupMember varGroupMember = new GroupMember();
        varGroupMember.UserOrGroupId =  UserInfo.getUserId();
        varGroupMember.GroupId = varGroup.Id;
        insert varGroupMember;
        */
    }
    
 
    @isTest
    static void testCaseServiceAPIError() 
    {
        RestRequest requestCase = new RestRequest();
        requestCase.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/api/caseDetailService/';
        requestCase.httpMethod = 'POST';
        
        CEC_CC_CaseService.Cases newCase = generateCaseAPI('123456789'); /* AccountIdentifier */

        CEC_CC_CaseService.Request requestCaseClass = new CEC_CC_CaseService.Request();
        requestCaseClass.cases = new List<CEC_CC_CaseService.Cases>();
        requestCaseClass.cases.add(newCase);

        CEC_CC_CaseService.Cases newCase2 = generateCaseClaroAPI('123456789'); /* AccountIdentifier */
        requestCaseClass.cases.add(newCase2);

		requestCaseClass.cases.add(newCase);

        test.startTest();
            
            RestContext.request = requestCase;
            CEC_CC_CaseService.Response responseCase = CEC_CC_CaseService.doPost(requestCaseClass);
        
        
        	system.debug('responseCase: ' + responseCase);
        	system.debug(responseCase.results[0].isSuccess);
        test.stopTest();
    }
    
    /*
    @isTest
    static void testCaseDetailServiceAPIError() 
    {
        RestRequest requestDetail = new RestRequest();
        requestDetail.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/api/caseDetailService/';
        requestDetail.httpMethod = 'POST';      
          
        RestContext.request = requestDetail;           
        requestDetail.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/api/caseDetailService/00098917';
        requestDetail.httpMethod = 'GET';   
        
        test.startTest();
        
       	 CEC_CC_CaseDetailService.Response responseDetailCase = CEC_CC_CaseDetailService.doGet();
        	system.assert(responseDetailCase.results.size() > 0, 'Nenhum retorno processado para a API CEC_CC_CaseDetailService');
        	CEC_CC_CaseDetailService.CaseResult caseDetailResult = responseDetailCase.results[0];
        	system.assertEquals(false, caseDetailResult.isSuccess, 'Erro ao realizar consulta');    
        
        test.stopTest();
    }
    */
    
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