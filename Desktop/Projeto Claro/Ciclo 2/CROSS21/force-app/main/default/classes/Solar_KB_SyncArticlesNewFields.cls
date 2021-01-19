/**
 * @author: Bruno Felix
 * @company: IBM - Bluewolf
 * @description: Batch para popular campos (Modelo da demanda e Tipo de registro de conteúdo) obrigatórios
 */

public class Solar_KB_SyncArticlesNewFields implements Database.Batchable<sObject>, Database.Stateful{
    //variáveis de classe para contabilizar o processo
    public Integer success = 0;
    public Integer error = 0;
    public List<String> errorMessages = new List<String>();
    public List<String> successMessages = new List<String>();
    
    public Iterable<sObject> start(Database.BatchableContext bc){
        
        return [SELECT Id FROM Knowledge__ka WHERE ArchivedDate != null OR FirstPublishedDate != null]; //busca todos os artigos que já foram (ou estão) publicados ou arquivados
    }
    
    public void execute(Database.BatchableContext bc, List<Knowledge__ka> scope){
        Set<Id> containsDraft = new Set<Id>();
        Set<Id> articleSet = new Set<Id>();
        //Para cada Artigo, venham todas as suas versões e ordena pela versão ASCENDENTE. Versão 0 = Draft.
        for (Knowledge__kav kav : [SELECT Id, KnowledgeArticleId, VersionNumber
                                     FROM Knowledge__kav
                                    WHERE KnowledgeArticleId = :scope
                                 ORDER BY KnowledgeArticleId, VersionNumber ASC]){
            if (kav.VersionNumber == 0){
                containsDraft.add(kav.KnowledgeArticleId);
            } else { //Se não tem 0, é porque está arquivado ou publicado e deve ser processado.
				if (!containsDraft.contains(kav.KnowledgeArticleId)){
                	articleSet.add(kav.KnowledgeArticleId);
                }
            }
        }
        
        Set<Id> toArchiveKA = new Set<Id>();
        Set<Id> toPublishKA = new Set<Id>();
        
        Savepoint sp = Database.setSavepoint();

        //Para cada Artigo sem draft, venham todas as suas versões e ordena pela versão DESCENDENTE. Processará a última versão apenas (mais recente).
        Set<Id> lastArticleVersionSet = new Set<Id>();
        for (Knowledge__kav kav : [SELECT Id, PublishStatus, KnowledgeArticleId, Title
                                   	 FROM Knowledge__kav
                                    WHERE KnowledgeArticleId = :articleSet
                                      AND RecordType.DeveloperName IN ('Noticias', 'POP', 'Artigo_Estruturado_Generico', 'Artigo_Estruturado_1', 'Artigo_Estruturado_2', 'Artigo_Estruturado_3', 'PromotionOrOffer')
                                      AND Demand_Model__c = null
                                 ORDER BY KnowledgeArticleId, VersionNumber DESC]){
            if (!lastArticleVersionSet.contains(kav.KnowledgeArticleId)){//se já estiver no mapa, pela ordenação da consulta, é a última versão.
                lastArticleVersionSet.add(kav.KnowledgeArticleId);
                
                try{
                    if (kav.PublishStatus == 'Archived'){
                        toArchiveKA.add(KbManagement.PublishingService.editArchivedArticle(kav.KnowledgeArticleId));
                    } else if(kav.PublishStatus == 'Online'){
                        toPublishKA.add(KbManagement.PublishingService.editOnlineArticle(kav.KnowledgeArticleId, true));
                    }
                    
                    success++;
                    successMessages.add(kav.Title + ' (' + kav.Id + ')');
                } catch (HandledException ex){
                    error++;
                    errorMessages.add(kav.Title + ' (' + kav.Id + ') - Erro de processamento - ' + ex.getMessage());
                }
            }
        }
        
        Set<Id> allArticlesToUpdate = new Set<Id>();
        if (!toArchiveKA.isEmpty()){
            allArticlesToUpdate.addAll(toArchiveKA);
        }
        
        if (!toPublishKA.isEmpty()){
            allArticlesToUpdate.addAll(toPublishKA);
        }
        
        if (!allArticlesToUpdate.isEmpty()){
            List<Knowledge__kav> articleList = [SELECT Id, RecordType.DeveloperName, KnowledgeArticleId, Title, Demand_Model__c, ContentRecordType__c, Support_Type__c, PublishStatus
                                                  FROM Knowledge__kav
                                                 WHERE Id =: allArticlesToUpdate];
            
            Map<String, Knowledge__kav> articleVersionMap = new Map<String, Knowledge__kav>();
            for (Knowledge__kav knw : articleList){
                Boolean updated = false;
                //Atribuição do Modelo da demanda e o tipo de registro de conteúdo para os artigos
                if(knw.RecordType.DeveloperName == 'Noticias'){
                    knw.Demand_Model__c = 'Conteúdo';
                    knw.ContentRecordType__c = 'Notícias';
                    updated = true;
                } else if(knw.RecordType.DeveloperName == 'POP'){
                    knw.Demand_Model__c = 'POP';
                    knw.ContentRecordType__c = 'Artigos';
                    knw.Support_Type__c = 'POP';
                    updated = true;
                } else if(knw.RecordType.DeveloperName == 'Artigo_Estruturado_Generico'){
                    knw.Demand_Model__c = 'ApoioConteudo';
                    knw.ContentRecordType__c = 'Artigos';
                    updated = true;
                } else {
                    knw.Demand_Model__c = 'Conteúdo';
                    knw.ContentRecordType__c = 'Artigos';
                    updated = true;
                }
                
                if (updated){
                    articleVersionMap.put(knw.Id, knw);
                }
            }
            
            List<Database.SaveResult> resultList = Database.update(articleVersionMap.values(), false);//Aqui é concatenado o status dos artigos que foram alterados pelo batch
            for (Integer i = 0; i < resultList.size(); i++){
                if (resultList[i].isSuccess()){
                    KbManagement.PublishingService.publishArticle(articleVersionMap.get(resultList[i].Id).KnowledgeArticleId, true);
                    
                    if (toArchiveKA.contains(resultList[i].Id)){
                        KbManagement.PublishingService.archiveOnlineArticle(articleVersionMap.get(resultList[i].Id).KnowledgeArticleId, null);
                    }
                    
                    success++;
                    successMessages.add(articleVersionMap.get(resultList[i].Id).Title + ' (' + resultList[i].Id + ') - Sucesso!');
                } else {
                    error++;
                    errorMessages.add(articleVersionMap.get(articleVersionMap.values()[i].Id).Title + ' - Erro de processamento - ' + String.join(resultList[i].getErrors(), ' '));
                }
            }
        }
        if (error > 0) {Database.rollback(sp);}
     }
    public void finish(Database.BatchableContext bc){//Estes dois últimos métodos são inerentes à mensagem do email - Sucesso/erro
        String body = 'Artigos processados com sucesso: ' + success;
        if(!successMessages.isEmpty()){
            body += '\n Artigos com sucesso abaixo: ';
            for(String msg : successMessages){
                body += '\n' + msg;
            }
        }
        body += '\n Artigos não processados: ' + error;
        if(!errorMessages.isEmpty()){
            body += '\n Artigos com erro abaixo: ';
            for(String msg : errorMessages){
                body += '\n' + msg;
            }
        }
        sendEmail(body);
    }
    private static void sendEmail(String body){//Método que monta o email para envio
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'carolina.souza@claro.com.br', 'marcio.cabral.terceiros@claro.com.br', 'bruno.felix@ibm.com'}; 
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('carolina.souza@claro.com.br');
        mail.setSenderDisplayName('Processo de sincronização de artigos com novos campos: Modelo da demanda e Tipo de registro de conteúdo');
        mail.setSubject('Resultado da sincronização');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}