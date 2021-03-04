@isTest
public class CEC_PME_ServiceEnvelopeTest {
    
    @testSetup
    static void setTestData() {

        Account testAccount = new Account();
        testAccount.Name = 'Test Smith';
        insert testAccount;

        Contact testContact = new Contact();
        testContact.FirstName = 'Test Contact';
        testContact.LastName = 'Contact';
        testContact.AccountId = testAccount.Id;
        insert testContact;

        Order testOrder = new Order();
        testOrder.Status = 'Aguardando Assinatura';
        testOrder.AccountId = testAccount.Id;
        testOrder.EffectiveDate = Date.today();
        insert testOrder;

        AccountContactRelation relation = [SELECT Id,
                                            ResponsibleForTheSignature__c
                                            FROM AccountContactRelation
                                            WHERE AccountId =: testAccount.Id ];

        relation.ResponsibleForTheSignature__c = true;
        update relation;
        
        testOrder.Related_Contacts__c = relation.Id + ';';
        update testOrder;     

        ServiceParameter__c docusignEndpoint = new ServiceParameter__c();
        docusignEndpoint.Name = 'DocuSignSendEnvelopePost';
        docusignEndpoint.Method__c = 'POST';
        docusignEndpoint.EndPoint__c = 'https://demo.docusign.net/';
        docusignEndpoint.Timeout__c = 120000;
        docusignEndpoint.User__c = 'docusign@gmail.com';
        docusignEndpoint.Password__c = 'password';
        docusignEndpoint.Token__c = '6e23dc57';
        insert docusignEndpoint;

        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
 
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink docLink = new ContentDocumentLink();
        docLink.LinkedEntityId = testOrder.Id;
        docLink.ContentDocumentId = documents[0].Id;
        docLink.ShareType = 'V';
        insert docLink;
        
        List<ServiceParameter__c> listServices = new List<ServiceParameter__c>();
        ServiceParameter__c templateService = new ServiceParameter__c();
        ServiceParameter__c createEnvelopeService = new ServiceParameter__c();
        ServiceParameter__c embeddedService = new ServiceParameter__c();
        ServiceParameter__c deleteRecipientsService = new ServiceParameter__c();
        ServiceParameter__c recipient = new ServiceParameter__c();
        ServiceParameter__c updRecipient = new ServiceParameter__c();
        
        templateService.Name = 'CEC_PME_DocuSignGetTemplate';
        templateService.EndPoint__c = 'somefunnyendpoint.com/templates/';
        templateService.Method__c = 'GET';
        templateService.Timeout__c = 120000;
        listServices.add(templateService);
        
        createEnvelopeService.Name = 'CEC_PME_DocuSignGetDocument';
        createEnvelopeService.EndPoint__c = 'somefunnyendpont.com/documents/';
        createEnvelopeService.Method__c = 'GET';
        createEnvelopeService.Timeout__c = 120000;
        listServices.add(createEnvelopeService);

        embeddedService.Name = 'CEC_PME_DocuSignEmbedded';
        embeddedService.EndPoint__c = 'somefunnyendpont.com/recipient';
        embeddedService.Method__c = 'POST';
        embeddedService.Timeout__c = 120000;
        listServices.add(embeddedService);

        deleteRecipientsService.Name = 'CEC_PME_DocuSignCreateEnvelope';
        deleteRecipientsService.EndPoint__c = 'somefunnyendpont.com/envelopes';
        deleteRecipientsService.Method__c = 'POST';
        deleteRecipientsService.Timeout__c = 120000;
        listServices.add(deleteRecipientsService);
        
        recipient.Name = 'CEC_PME_DocuSignListRecipient';
        recipient.EndPoint__c = 'https://demo.docusign.net/restapi/v2/accounts/{!accountId}/envelopes/{!envelopeId}/recipients';
        recipient.Method__c = 'POST';
        recipient.Timeout__c = 120000;
        listServices.add(recipient);  
        
        updRecipient.Name = 'CEC_PME_DocuSignUpdateRecipients';
        updRecipient.EndPoint__c = 'https://demo.docusign.net/restapi/v2/accounts/{!accountId}/envelopes/{!envelopeId}/recipients?resend_envelope=true';
        updRecipient.Method__c = 'POST';
        updRecipient.Timeout__c = 120000;
        listServices.add(updRecipient);         
        
        
        templateService.User__c = createEnvelopeService.User__c = embeddedService.User__c = deleteRecipientsService.User__c = 'test';
        templateService.Password__c = createEnvelopeService.Password__c = embeddedService.Password__c = deleteRecipientsService.Password__c = 'test';
        templateService.Token__c = createEnvelopeService.Token__c = embeddedService.Token__c = deleteRecipientsService.Token__c = 'test';
        
        insert listServices;
        
		Profile p = [SELECT Id FROM Profile WHERE Name='Loja Propria'];
        User u = new User(Alias = 'standt', Email='someuserdatdoesntexist@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='someuserdatdoesntexist@testorg.com');

            insert new Integration_Flow__c(SetupOwnerId = UserInfo.getProfileId(), isEmbedded__c=false, isSigningRequired__c=true, TemplateId__c='abcdef', AccountId__c='e4e0000HqQrez');
    }
    
    @isTest
    static void openTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CEC_PME_IntegrationDocuSignMock());
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        
        CEC_PME_ServiceEnvelope.SaveResult result = new CEC_PME_ServiceEnvelope().open(testOrder.Id, false, false, 'test', 'test');
        
        Test.stopTest();
    }

}