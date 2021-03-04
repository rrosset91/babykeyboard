@isTest
public without sharing class CEC_KB_NewsFooterTest {
        
    @isTest static void testRecentArticles(){
		User runUser = [SELECT Id FROM User WHERE Profile.Name = 'Governança KB' AND IsActive = true LIMIT 1];
        
        String articleId = 'Insert article ID';
        Knowledge__kav knw = new Knowledge__kav();
        knw.Title = 'UnitTest - Notícia para Massa de Dados';
        knw.UrlName = 'generic-URL';
        knw.Summary = 'Massa de dados para teste de componente de notícias.';
        knw.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Knowledge__kav' AND DeveloperName = 'Noticias'].Id;
        knw.Classification__c = 'Administrativa';
        knw.Impact__c = 'Baixo';
        knw.Request_Center__c = 'Ouvidoria';
        knw.Profile__c = 'Móvel – PF';
        knw.Requester_Name__c = 'Resquester';
        knw.Demand_Model__c = 'ApoioConteudo';
        knw.Preferred_Publication_Date__c = System.today().addDays(3);
        knw.ContentRecordType__c = 'Artigos';
        knw.Purpose__c = 'Correção';
        knw.Product_Type__c = 'Combos';
        knw.ResponsibleRedactor__c = userinfo.getUserId();
        
        System.runAs(runUser){
            insert knw;
            
            Knowledge__kav knwInst = [SELECT Id,Title,Summary,RecordType.Name, KnowledgeArticleId FROM Knowledge__kav WHERE id =: knw.Id];
            KbManagement.PublishingService.publishArticle(knwInst.KnowledgeArticleId, true);
            Test.startTest();
            CEC_KB_NewsFooterController.getRecentArticles(1);
            Test.stopTest();
        }
    }
}