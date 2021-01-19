/*
* Autor: Diogo Braga - Deloitte
* Data: 30/10/2019
* Trigger Handler de ContentDocumentLink
*  ---------------------------------------------------------------
*/ 
public class CEC_PME_ContentDocLinkTriggerHandler extends TriggerHandler {
    private final String ORDER_RT_PME  = 'PME_Order';
    private final String CONTENT_DOCUMENT = 'ContentDocument';
    private final Integer BATCH_SIZE = 100;
    
    private List<ContentDocumentLink> triggerNewPME; 
    private Map<Id, List<ContentDocumentLink>> mapContentDocumentIdListLink;
    private List<dsfs__DocuSign_Status__c> listDsStatus;
    
    /*
	* Autor: Diogo Braga
	* Descrição: CEC FASE 1 + SQUAD PME: Construtor
	*/ 
    public CEC_PME_ContentDocLinkTriggerHandler() {
        triggerNewPME = (List<ContentDocumentLink>) getTriggerNew();
    }
    
    /*
	* Autor: Diogo Braga
	* Descrição: CEC FASE 1 + SQUAD PME: método contextualizado de after insert 
	*/ 
    public override void afterInsert() {
        assemblyMapContentDocumentIdListLink();
        getListDsStatus();
        
        sharingWithOrder();
        
        versionDocusignDocuments();
    }
    
    /*
	* Autor: Diogo Braga
	* Descrição: CEC FASE 1 + SQUAD PME: método que busca de tem documentos de versão desatualizada e remove o registro mantendo informação de tipagem
	*/ 
    private void versionDocusignDocuments() {
        List<Id> listLinkedEntityId = new List<Id>();
        for(ContentDocumentLink iContentDocumentLink : triggerNewPME) {
            listLinkedEntityId.add(iContentDocumentLink.LinkedEntityId);
        }
        
        List<ContentDocumentLink> listContentDocumentLink = [SELECT Id, 
                                                             LinkedEntityId, 
                                                             ContentDocumentId 
                                                             FROM ContentDocumentLink
                                                             WHERE LinkedEntityId IN (SELECT Id 
                                                                                      FROM Order 
                                                                                      WHERE Id IN :listLinkedEntityId
                                                                                      AND RecordType.DeveloperName = :ORDER_RT_PME)];
        if(!listContentDocumentLink.isEmpty()) {
            
            Map<Id, Id> mapContentDocumentIdLinkedEntityId = new Map<Id, Id>();
            for(ContentDocumentLink iContentDocumentLink : listContentDocumentLink) {
                mapContentDocumentIdLinkedEntityId.put(iContentDocumentLink.ContentDocumentId, iContentDocumentLink.LinkedEntityId);
            }
            
            List<ContentVersion> listContentVersion = [SELECT Id,
                                                       ContentDocument.Title,
                                                       ContentDocument.Id,
                                                       CreatedDate,
                                                       CEC_Tipo_de_Anexo__c
                                                       FROM ContentVersion
                                                       WHERE ContentDocumentId IN :mapContentDocumentIdLinkedEntityId.keySet()
                                                       AND IsLatest = true];
            
            Map<String, ContentVersion> mapLastVersionContentVersion = new Map<String, ContentVersion>();
            List<ContentVersion> listContentVersionToDelete = new List<ContentVersion>();
            for(ContentVersion iContentVersion : listContentVersion) {
                String nameContent = iContentVersion.ContentDocument.Title;
                nameContent = nameContent.substringBeforeLast('.').substringBeforeLast('_');
                String key = nameContent + mapContentDocumentIdLinkedEntityId.get(iContentVersion.Id);
                
                if(mapLastVersionContentVersion.containsKey(key)) {
                    ContentVersion contentVersionOnMap = mapLastVersionContentVersion.get(key);
                    if(String.isBlank(contentVersionOnMap.CEC_Tipo_de_Anexo__c) && String.isNotBlank(iContentVersion.CEC_Tipo_de_Anexo__c)) {
                        contentVersionOnMap.CEC_Tipo_de_Anexo__c = iContentVersion.CEC_Tipo_de_Anexo__c;
                    } else if(String.isNotBlank(contentVersionOnMap.CEC_Tipo_de_Anexo__c) && String.isBlank(iContentVersion.CEC_Tipo_de_Anexo__c)) {
                        iContentVersion.CEC_Tipo_de_Anexo__c = contentVersionOnMap.CEC_Tipo_de_Anexo__c;
                    }
                    
                    if(contentVersionOnMap.CreatedDate < iContentVersion.CreatedDate) {
                        mapLastVersionContentVersion.put(key, iContentVersion);
                        listContentVersionToDelete.add(contentVersionOnMap);
                    } else {
                        listContentVersionToDelete.add(iContentVersion);
                    }
                } else {
                    mapLastVersionContentVersion.put(key, iContentVersion);
                }
            }
            
            if(mapLastVersionContentVersion.values() != null && !mapLastVersionContentVersion.values().isEmpty()) {
                update mapLastVersionContentVersion.values();
            }
            
            if(!listContentVersionToDelete.isEmpty()) {
                List<Id> listContentDocumentsIdToDelete = new List<Id>();
                for(ContentVersion iContentVersion: listContentVersionToDelete) {
                    listContentDocumentsIdToDelete.add(iContentVersion.ContentDocumentId);
                }
                
                Database.executeBatch( new CEC_PME_BatchDelete(listContentDocumentsIdToDelete, CONTENT_DOCUMENT), BATCH_SIZE);
            }
        }
    }
    
    /*
	* Autor: Diogo Braga
	* Descrição: CEC FASE 1 + SQUAD PME: método para pegar no banco os registros de status do envelope
	*/
    private void getListDsStatus() {
        if(mapContentDocumentIdListLink == null) {
            assemblyMapContentDocumentIdListLink();
        }
        
        listDsStatus = [SELECT Id,
                        Order__c
                        FROM dsfs__DocuSign_Status__c 
                        WHERE Id IN :mapContentDocumentIdListLink.keySet()];
    }
    
    /*
	* Autor: Diogo Braga
	* Descrição: CEC FASE 1 + SQUAD PME: método para montar o MapContentDocumentIdListLink
	*/
    private void assemblyMapContentDocumentIdListLink() {
        mapContentDocumentIdListLink = new Map<Id, List<ContentDocumentLink>>();
        
        for(ContentDocumentLink contentDocumentLink : triggerNewPME) {
            if(mapContentDocumentIdListLink.containsKey(contentDocumentLink.LinkedEntityId)) {
                mapContentDocumentIdListLink.get(contentDocumentLink.LinkedEntityId).add(contentDocumentLink);
            } else {
                mapContentDocumentIdListLink.put(contentDocumentLink.LinkedEntityId, new List<ContentDocumentLink>{contentDocumentLink});
            }
        }
    }
    
    /*
	* Autor: Diogo Braga
	* Descrição: CEC FASE 1 + SQUAD PME: método para compartilhar documento com o pedido
	*/
    public void sharingWithOrder() {
        
        List<ContentDocumentLink> listNewContentDocumentLink = new List<ContentDocumentLink>();
        
        for(dsfs__DocuSign_Status__c dsStatus : listDsStatus) {
            for(ContentDocumentLink baseContentDocumentLink : mapContentDocumentIdListLink.get(dsStatus.Id)) {
                ContentDocumentLink newcontentDocumentLinkBase = new ContentDocumentLink();
                newcontentDocumentLinkBase.LinkedEntityId = dsStatus.Order__c;
                newcontentDocumentLinkBase.ContentDocumentId = baseContentDocumentLink.ContentDocumentId;
                newcontentDocumentLinkBase.ShareType = baseContentDocumentLink.ShareType;
                newcontentDocumentLinkBase.Visibility = baseContentDocumentLink.Visibility;
                listNewContentDocumentLink.add(newcontentDocumentLinkBase);
            }
        }
        
        if(!listNewContentDocumentLink.isEmpty()) {
            insert listNewContentDocumentLink;
        }
    }
}