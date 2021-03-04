public without sharing class CEC_KB_PublishArticleController {
    @AuraEnabled
    public static String checkUserPermission(String recordId){
        //Checa se os usuarios possuem permissão de publicação e se o artigo ainda não foi publicado e foi aprovado para publicação
        List<PermissionSetAssignment> currentUserPS = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId()];
        Knowledge__kav article = [SELECT  PublishStatus, Approval_Status__c FROM Knowledge__kav WHERE id =: recordId];
        String emptyReturn = '';
        String permissionCustomLabel = System.Label.PermissionError_Publish_KB;
        String statusCustomLabel = System.Label.StatusError_Publish_KB;
        String userProfileName = [SELECT Name FROM profile WHERE id =: userinfo.getProfileId()].Name;

        try {
            if(article.PublishStatus == 'Draft' && article.Approval_Status__c == 'Publicação'){
                for(PermissionSetAssignment lstcurrentUserPerSet : currentUserPS){
                	if (lstcurrentUserPerSet.PermissionSet.Name != 'KB_Management' || lstcurrentUserPerSet.PermissionSet.Name != 'KB_Edit' || userProfileName != 'System Administrator'){
                        return emptyReturn;
                	} else {
                    	return permissionCustomLabel;
                    }
                }
            } else {
                return statusCustomLabel;
            }
        } catch (Exception e) {
            System.debug('ERROR ------> ' + e.getMessage() + ' Line -----> ' + e.getLineNumber());
            throw new AuraHandledException('Erro: ' + e.getMessage()); 
        }
        return emptyReturn;
    }
    
    @AuraEnabled
    public static String publishArticle(String recordId, String scheduledDate, String publishOption, Boolean isNewVersion, String scheduledRevisionDate){
        //publica artigo e cria tarefa
        String emptyReturn = '';
        String successPublication = 'Artigo publicado com sucesso';
        Knowledge__kav article = [SELECT KnowledgeArticleId, Wardship__c  FROM Knowledge__kav WHERE id =: recordId];
        if(article.Wardship__c == false) {
            createTask(recordId, scheduledRevisionDate);
        }
        try {
            if(publishOption == 'now') {
                KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, isNewVersion);
                return successPublication;
            }else{
                Date dtSchedule = Date.valueOf(scheduledDate);
                String scheduledPublication = 'Publicacao agendada para o dia ' + dtSchedule + '.';
                Datetime dttmSchedule = Date.newInstance(dtSchedule.year(), dtSchedule.month(), dtSchedule.day());
                KbManagement.PublishingService.scheduleForPublication(article.KnowledgeArticleId, dttmSchedule);
                return scheduledPublication; 
            }
        } catch(Exception e){
            System.debug('ERROR ------> ' + e.getMessage() + ' Line -----> ' + e.getLineNumber());
            throw new AuraHandledException('Erro: ' + e.getMessage());          
        }
    }
    
    @AuraEnabled
    public static void createTask(String recordId, String scheduledRevisionDate){
        // Cria uma tarefa de revisão para o artigo publicado
        Knowledge__kav article = [SELECT Id, CreatedById, RecordTypeId, ResponsibleEditor__c FROM Knowledge__kav WHERE Id =: recordId];
        Date dtSchedule = Date.valueOf(scheduledRevisionDate);
        Group idFila = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'DAC_Editores' Limit 1];
        String IdCA = Schema.SObjectType.knowledge__kav.getRecordTypeInfosByDeveloperName().get('Artigo_para_clientes').getRecordTypeId();
        String IdNews = Schema.SObjectType.knowledge__kav.getRecordTypeInfosByDeveloperName().get('Noticias').getRecordTypeId();
        String IdTaskRT = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Tarefa_KB').getRecordTypeId();
        try {
            if(article.RecordTypeId != IdCA || article.RecordTypeId != IdNews) {
                Task task = new Task();
                task.ActivityDate = dtSchedule;
                task.OwnerId = idFila.Id;
                task.Priority = 'Normal';
                task.RecordTypeId = IdTaskRT;
                task.Responsible__c = article.ResponsibleEditor__c;
                task.Status = 'Open';
                task.Subject = 'Revisão de artigo';
                task.Task_Article__c = article.Id;
                insert task;
            }
        } catch(Exception e){
            System.debug('ERROR ------> ' + e.getMessage() + ' Line -----> ' + e.getLineNumber());
            throw new AuraHandledException('Erro: ' + e.getMessage());          
        }
    }
}