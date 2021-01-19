@IsTest
public class CEC_CC_Expurgo_CasosTest {
    private static final String CEC_CC_ConsumidorGOV = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
    private static final String CEC_CC_ClaroContato = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ClaroContato').getRecordTypeId();

    @TestSetup
    static void makeData(){
        Account mainAccount = new Account(
            Name = 'Tony Stark',
            DocumentType__c = 'CPF',
            DocumentNumber__c = '714.607.567-20'
        );
        insert mainAccount;

        List<Account> lstAccounts = new List<Account>();
        Account billingAccount1 = new Account(
            ContractReferenceNumber__c = '1234512345',
            BusinessUnit__c = 'Net',
            vlocity_cmt__Status__c = 'Ativo',
            vlocity_cmt__CustomerValue__c = 'PURPLE',
            CityCode__c = '003',
            Name = '003/1234512345',
            Type = 'Cliente',
            ParentId = mainAccount.Id
        );
        lstAccounts.add(billingAccount1);

        insert lstAccounts;

        Contact contactDefault = new Contact(
            Gender__c = 'Masculino',
            DocumentType__c = 'CPF',
            Lastname = 'Stark',
            RecordTypeId = CEC_CC_ClaroContato
        );
        insert contactDefault;

        Case casoConsumidorGOV = new Case(
            RecordTypeId = CEC_CC_ConsumidorGOV,
            AccountId = mainAccount.Id,
            ContractBillingAccount__c = billingAccount1.Id,
            ContactId = contactDefault.Id,
            CriticalChannelOpenDate__c = DateTime.Now(),
            OpenDateRobot__c = DateTime.Now(),
            Status = 'New',
            SubStatus__c = 'Não Iniciado',
            ContactPreference__c = 'Whatsapp',
            Channel__c = 'Consumidor.gov',
            InputType__c = 'Site Consumidor.gov',
            Description = 'Testando Casos',
            Company__c = 'NET',
            Origin = 'Web'
        );

        insert casoConsumidorGOV;
    }

    @IsTest
    static void testBatch(){
        String metadataDeveloperName = 'Configura_o_Expurgo_de_Casos';

        Case casoCriado = [
            SELECT
                Id, OwnerId
            FROM
                Case
            LIMIT
                1
        ];

        User usuario = [
            SELECT
                ID
            FROM
                User
            LIMIT
                1
        ];

        casoCriado.OwnerId = usuario.Id;
        update casoCriado;

        CEC_CC_Expurgo_Caso__mdt configuracoesExpurgo = [
            SELECT
                Canal_do_Omnichannel__c, Condicao_de_Expurgo__c, Destinatarios_do_Relatorio__c
            FROM
                CEC_CC_Expurgo_Caso__mdt
            WHERE
                DeveloperName =: metadataDeveloperName
        ];

        String varChannelId = CEC_SkillsBasedRouting.getChannelId(configuracoesExpurgo.Canal_do_Omnichannel__c);

        String query = '';
        query += 'SELECT ';
            query += 'Id, WorkItemId ';
        query += 'FROM ';
            query += 'PendingServiceRouting ';
        query += 'WHERE ';
            query += 'ServiceChannelId = :varChannelId AND ';
            query += configuracoesExpurgo.Condicao_de_Expurgo__c;

        Test.startTest();
            CEC_CC_Expurgo_Casos batchCase = new CEC_CC_Expurgo_Casos(metadataDeveloperName);
            Database.executeBatch(batchCase, 200);
        Test.stopTest();

        List<PendingServiceRouting> precisamSerExpurgados = (List<PendingServiceRouting>)Database.query(query);

        System.assertEquals(0, precisamSerExpurgados.size());
    }

    @IsTest
    static void testSchedule(){
        String CRON_EXP = '0 0 1 * * ?';

        Test.startTest();
            String jobId = System.schedule('Schedule Expurgo de Casos', CRON_EXP,  new CEC_CC_Expurgo_Casos_Schedule()); 
        Test.stopTest();

        System.assert(!String.isBlank(jobId));
    }
}