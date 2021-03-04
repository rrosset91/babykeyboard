@isTest
public class KB_PublicarArtigoControllerTest {
    @testSetup static void charge(){
        WatsonIntegrationSettings__c setting = new WatsonIntegrationSettings__c();
        setting.CollectionID__c = 'ioqfbioffhbwihofbq';
        setting.EnviromentID__c = '129073h2109u3n1d1';
        setting.Method__c = 'GET';
        setting.Name = 'UpdateDocumentOnWatson';
        setting.Endpoint__c = 'https://api.us-south.discovery.watson.cloud.ibm.com/instances/640486bf-064c-4972-954f-d0fdb5df5f0a';
        setting.Username__c = 'wwuhruhwr';
        setting.Password__c = '192uhoi12n3ij12b';
        setting.Path__c = 'drive/driveapi';
        setting.QueryType__c = 'query';
        setting.Version__c = '202-10-10';
        setting.BackendEndpoint__c = 'https://claro-watson-orchestrator.us-south.cf.appdomain.cloud';
        insert setting;
        
        WatsonIntegrationSettings__c setting2 = new WatsonIntegrationSettings__c();
        setting2.CollectionID__c = 'ioqfbioffhbwihofbq';
        setting2.EnviromentID__c = '129073h2109u3n1d1';
        setting2.Method__c = 'GET';
        setting2.Name = 'SendArticleToWatson';
        setting2.Endpoint__c = 'https://api.us-south.discovery.watson.cloud.ibm.com/instances/640486bf-064c-4972-954f-d0fdb5df5f0a';
        setting2.Username__c = 'wwuhruhwr';
        setting2.Password__c = '192uhoi12n3ij12b';
        setting2.Path__c = 'drive/driveapi';
        setting2.QueryType__c = 'query';
        setting2.Version__c = '202-10-10';
        
        insert setting2;
        
        Knowledge__kav knw = new Knowledge__kav();
        knw.Title = 'testing wololo wololo2';
        knw.UrlName = 'testing-wololo-wololo2';
        knw.Summary = 'wololo';
        knw.Understand__c = 'wololo';
        knw.Valid_for__c = 'wololo';
        knw.Benefits__c = 'wololo';
        knw.Channels_and_Systems__c = 'wololo';
        knw.How_it_works__c = 'wololo';
        knw.Value__c = 'wololo';
        knw.Know_more__c = 'wololo';        
        insert knw;
        
        Knowledge__kav knw2 = new Knowledge__kav();
        knw2.Title = 'testing wololo wololo3';
        knw2.UrlName = 'testing-wololo-wololo3';
        knw2.Summary = 'wololo';
        knw2.Understand__c = 'wololo';
        knw2.Valid_for__c = 'wololo';
        knw2.Benefits__c = 'wololo';
        knw2.Channels_and_Systems__c = 'wololo';
        knw2.How_it_works__c = 'wololo';
        knw2.Value__c = 'wololo';
        knw2.Know_more__c = 'wololo';
		knw2.Watson_ID__c = '98h219ubnf8y0bf12hbf';        
        insert knw2;
    }
    @isTest static void testGetArticle(){
        Knowledge__kav article = [SELECT Id FROM Knowledge__kav WHERE Title = 'testing wololo wololo2'];
        Boolean articleFromCtrl = CEC_KB_PublishArticleController.checkUserPermission(article.Id);
        System.assert(articleFromCtrl != null);
    }
    
    @isTest static void testPublishArticle(){
        Knowledge__kav article = [SELECT Id FROM Knowledge__kav WHERE Title = 'testing wololo wololo2'];
        Test.setMock(HttpCalloutMock.class, new MockHttpWatsonResponse('{"document_id": "21ub12uybf1", "message": "Pending"}', 200));
        String dtSchedule = String.valueOf(Date.today().addDays(30));
        System.debug('dtSchedule: ' + dtSchedule);
        Test.startTest();
        Boolean ctrlResponse = CEC_KB_PublishArticleController.publishArticle(article.Id, dtSchedule, 'now', dtSchedule, true);
        Test.stopTest();
        System.assert(ctrlResponse);
    }
    
    @isTest static void testPublishArticle2(){
        Knowledge__kav article = [SELECT Id FROM Knowledge__kav WHERE Title = 'testing wololo wololo2'];
        Test.setMock(HttpCalloutMock.class, new MockHttpWatsonResponse('{"document_id": "21ub12uybf1", "message": "Pending"}', 200));
        String dtSchedule = String.valueOf(Date.today().addDays(30));
        System.debug('dtSchedule: ' + dtSchedule);
        Test.startTest();
        Boolean ctrlResponse = CEC_KB_PublishArticleController.publishArticle(article.Id, dtSchedule, 'later', dtSchedule, true);
        Test.stopTest();
        System.assert(ctrlResponse);
    }
    
    @isTest static void testPublishArticle3(){
        Knowledge__kav article = [SELECT Id FROM Knowledge__kav WHERE Title = 'testing wololo wololo2'];
        Test.setMock(HttpCalloutMock.class, new MockHttpWatsonResponse('{"message": "error"}', 400));
        String dtSchedule = String.valueOf(Date.today().addDays(30));
        System.debug('dtSchedule: ' + dtSchedule);
        Test.startTest();
        Boolean ctrlResponse = CEC_KB_PublishArticleController.publishArticle(article.Id, dtSchedule, 'later', dtSchedule, true);
        Test.stopTest();
        System.assert(!ctrlResponse);
    }
}