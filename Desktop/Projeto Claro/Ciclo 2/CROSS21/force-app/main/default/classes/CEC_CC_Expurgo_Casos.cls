global class CEC_CC_Expurgo_Casos implements Database.Batchable<sObject>{
    private String metadataDeveloperName;
    private CEC_CC_Expurgo_Caso__mdt configuracoesExpurgo;
    private String varChannelId;

    public CEC_CC_Expurgo_Casos(String metadataDeveloperName){
        this.metadataDeveloperName = metadataDeveloperName;

        this.configuracoesExpurgo = [
            SELECT
                Canal_do_Omnichannel__c, Condicao_de_Expurgo__c, Destinatarios_do_Relatorio__c
            FROM
                CEC_CC_Expurgo_Caso__mdt
            WHERE
                DeveloperName = :this.metadataDeveloperName
        ];

        this.varChannelId = CEC_SkillsBasedRouting.getChannelId(this.configuracoesExpurgo.Canal_do_Omnichannel__c);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String varChannelId = this.varChannelId;
        String query = '';
        query += 'SELECT ';
            query += 'Id, WorkItemId ';
        query += 'FROM ';
            query += 'PendingServiceRouting ';
        query += 'WHERE ';
            query += 'ServiceChannelId = :varChannelId AND ';
            query += configuracoesExpurgo.Condicao_de_Expurgo__c;

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<PendingServiceRouting> scope){
        if(scope.size() > 0){
            Database.delete(scope);
            Database.emptyRecycleBin(scope);
        }
    }

    global void finish(Database.BatchableContext BC){
        System.debug('Entrou no Finish');
        AsyncApexJob job = [
            SELECT
                Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM
                AsyncApexJob
            WHERE
            Id = :BC.getJobId()
        ];
        
        String usersQuery = '';
        usersQuery += 'SELECT ';
            usersQuery += 'Email ';
        usersQuery += 'FROM ';
            usersQuery += 'User ';
        usersQuery += 'WHERE ';
            usersQuery += this.configuracoesExpurgo.Destinatarios_do_Relatorio__c;

        List<User> usersToSend = Database.query(usersQuery);
        
        if(usersToSend.size() > 0){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            for(User currentUser: usersToSend){
            toAddresses.add(currentUser.Email);
            }

            mail.setToAddresses(toAddresses);

            mail.setSubject('Expurgo de Casos do OmniChannel: ' + job.Status);
            mail.setPlainTextBody
            ('Total de trabalhos executados ' + job.TotalJobItems +
            ' com '+ job.NumberOfErrors + ' falhas.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}