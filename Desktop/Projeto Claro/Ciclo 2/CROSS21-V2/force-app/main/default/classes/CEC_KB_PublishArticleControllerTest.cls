@isTest
public with sharing class CEC_KB_PublishArticleControllerTest {
    @testSetup static void charge(){
        String IdAEG = Schema.SObjectType.knowledge__kav.getRecordTypeInfosByDeveloperName().get('Artigo_Estruturado_Generico').getRecordTypeId();
        String IdNews = Schema.SObjectType.knowledge__kav.getRecordTypeInfosByDeveloperName().get('Noticias').getRecordTypeId();
        Knowledge__kav knw = new Knowledge__kav();
        knw.Title = 'testing wololo wololo2';
        knw.Understand__c = 'wololo'; 
        knw.Request_Center__c = 'Comercial';
        knw.Requester_Name__c = 'Banoffee';
        knw.Preferred_Publication_Date__c = Date.today();
        knw.Purpose__c = 'Criação';
        knw.Product_Type__c = 'Fone';
        knw.Impact__c = 'Baixo';
        knw.Profile__c = 'Residencial - Claro NET';
        knw.Demand_Model__c = 'Conteúdo';
        knw.ContentRecordType__c = 'Artigos';
        knw.ResponsibleRedactor__c = UserInfo.getUserId();
        knw.Approval_Status__c = 'Publicação';
        knw.RecordTypeId = IdAEG;
        knw.UrlName = 'testing-wololo-wololo2';
        insert knw;
        
        Knowledge__kav knw1 = new Knowledge__kav();
        knw1.Title = 'testing wololo wololo3';
        knw1.Understand__c = 'wololo';
        knw1.Request_Center__c = 'Comercial';
        knw1.Requester_Name__c = 'Banoffee';
        knw1.Preferred_Publication_Date__c = Date.today();
        knw1.Purpose__c = 'Criação';
        knw1.Product_Type__c = 'Fone';
        knw1.Impact__c = 'Baixo';
        knw1.Profile__c = 'Residencial - Claro NET';
        knw1.Demand_Model__c = 'Conteúdo';
        knw1.ContentRecordType__c = 'Artigos';
        knw1.ResponsibleRedactor__c = UserInfo.getUserId();
        knw1.Approval_Status__c = 'Publicação';
        knw1.RecordTypeId = IdAEG;
        knw1.UrlName = 'testing-wololo-wololo3';
        insert knw1;

    }
    @isTest static void testCheckUserPermission(){
        Knowledge__kav article = [SELECT Id FROM Knowledge__kav WHERE Title = 'testing wololo wololo2'];
        String articleFromCtrl = CEC_KB_PublishArticleController.checkUserPermission(article.Id);
        System.assert(articleFromCtrl != null);
    }
    @isTest static void testPublishArticle(){
        Knowledge__kav article = [SELECT Id FROM Knowledge__kav WHERE Title = 'testing wololo wololo2'];
        String dtSchedule = String.valueOf(Date.today().addDays(30));
        Test.startTest();
        String ctrlResponse = CEC_KB_PublishArticleController.publishArticle(article.Id, dtSchedule, 'now', true, dtSchedule);
        Test.stopTest();
        System.assert(ctrlResponse == 'Artigo publicado com sucesso');
    }
    
    @isTest static void testPublishArticleSchedule(){
        Knowledge__kav article = [SELECT Id FROM Knowledge__kav WHERE Title = 'testing wololo wololo2'];
        String dtSchedule = '2021-03-03';
        Test.startTest();
		String ctrlResponse = CEC_KB_PublishArticleController.publishArticle(article.Id, dtSchedule, 'later', false, dtSchedule);
        Test.stopTest();
    }    

    @isTest static void testCreateTask(){
        Knowledge__kav article = [SELECT Id FROM Knowledge__kav WHERE Title = 'testing wololo wololo2'];
        String dtSchedule = String.valueOf(Date.today().addDays(30));
        Test.startTest();
        CEC_KB_PublishArticleController.createTask(article.Id, dtSchedule);
        Test.stopTest();
    }
}