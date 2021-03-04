/*
* Autor: Diogo Braga - Deloitte
* Data: 30/10/2019
* classe de teste da trigger e triggerhandler 
*  ---------------------------------------------------------------
*/
@isTest
private class CEC_ContentDocumentLinkTriggerTest {
    
    
    /*
	* Autor: Diogo Braga
	* Descrição: CEC FASE 1 + SQUAD PME: método de teste de compartilhamento
	*/ 
    @isTest
    private static void contentDocumentInsert(){
        
        Account newAccount = new Account(
            Name = 'Test Account'
        );
        
        insert newAccount;
        
        Order newOrder = new Order(
        	Name = 'Test Order',
            AccountId = newAccount.id,
            EffectiveDate = Date.today(),
            Status = 'Em Andamento',
            RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('PME_Order').getRecordTypeId()
        );
        
        insert newOrder;
        
        dsfs__DocuSign_Status__c newDocuSingStatus = new dsfs__DocuSign_Status__c();
        newDocuSingStatus.Order__c = newOrder.Id;
        insert newDocuSingStatus;
        
        ContentVersion newContentVersion = new ContentVersion(
            Title = 'Image',
            PathOnClient = 'Image.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        
        insert newContentVersion;   
        
        
        ContentVersion newContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :newContentVersion.Id];

        ContentDocumentLink newContentLink=new ContentDocumentLink();
        newContentLink.ShareType= 'V';
        newContentLink.LinkedEntityId = newDocuSingStatus.Id;
        newContentLink.ContentDocumentId = newContent.ContentDocumentId;
        newContentLink.Visibility = 'AllUsers'; 
        insert newContentLink;
        
        ContentVersion newVersContentVersion = new ContentVersion(
            Title = 'Image',
            PathOnClient = 'Image.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        
        insert newVersContentVersion;   
        
        
        ContentVersion newVersContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :newVersContentVersion.Id];

        ContentDocumentLink newVersContentLink = new ContentDocumentLink();
        newVersContentLink.ShareType= 'V';
        newVersContentLink.LinkedEntityId = newOrder.Id;
        newVersContentLink.ContentDocumentId = newVersContent.ContentDocumentId;
        newVersContentLink.Visibility = 'AllUsers'; 
        insert newVersContentLink;
    
    }
}