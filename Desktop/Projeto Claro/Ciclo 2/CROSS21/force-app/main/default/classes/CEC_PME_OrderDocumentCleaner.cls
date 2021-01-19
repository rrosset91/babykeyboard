public class CEC_PME_OrderDocumentCleaner {
    public static void deleteContDocNComp(String recordId) {
        
        Set<String> setContentLink = new Set<String>();
        
        List<ContentDocumentLink> listContentDocumentLink = [SELECT Id,
                                                             ContentDocumentId 
                                                             FROM ContentDocumentLink 
                                                             WHERE LinkedEntityId = :recordId];
        
        system.debug('listContentDocumentLink ' + listContentDocumentLink);
        for(ContentDocumentLink contentDocumentLink : listContentDocumentLink) {
            setContentLink.add(contentDocumentLink.ContentDocumentId);
        }
        
        List<ContentVersion> listContentVersion = [SELECT Id, 
                                                   CEC_Tipo_de_Anexo__c, 
                                                   ContentDocumentId, 
                                                   PathOnClient, 
                                                   FileExtension ,
                                                   ContentDocument.Title,
                                                   CreatedDate
                                                   FROM ContentVersion
                                                   WHERE ContentDocumentId =: setContentLink 
                                                   AND IsLatest = true];
        
        Map<String, ContentVersion> mapLastVersionContent = new Map<String, ContentVersion>();
        for(ContentVersion contentVersion : listContentVersion) {
            String nameContent = contentVersion.ContentDocument.Title;
            nameContent = nameContent.toUpperCase();
            nameContent = nameContent.remove('_COMPLETED');
            nameContent = nameContent.remove('_SENT');
            nameContent = nameContent.remove('.PDF');
            System.debug('nameContent ' + nameContent);
            
            if(mapLastVersionContent.containsKey(nameContent)) {
                if(contentVersion.CreatedDate > mapLastVersionContent.get(nameContent).CreatedDate) {
                    mapLastVersionContent.put(nameContent, contentVersion);
                }
            } else {
                mapLastVersionContent.put(nameContent, contentVersion);
            }
        }
        
        List<Id> listContentDocumentDel = new List<Id>();
        for(ContentVersion contentVersion : listContentVersion) {
            boolean cotains = false;
            for(ContentVersion contentVersionMap : mapLastVersionContent.values()) {
                cotains = cotains || contentVersion.Id == contentVersionMap.Id;
            }
            
            if(!cotains) {
                listContentDocumentDel.add(contentVersion.ContentDocumentId);
            }
        }
        
        List<ContentDocument> listContentDocument = [SELECT Id
                                                     FROM ContentDocument 
                                                     WHERE Id IN :listContentDocumentDel];
        
        system.debug('listContentDocument ' + listContentDocument);
        delete listContentDocument;
    }
}