@isTest
public class CEC_CaseTriggerControllerTest {
    private static final String CEC_CC_Ouvidoria = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
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

        Account billingAccount2 = new Account(
            ContractReferenceNumber__c = '1234512346',
            BusinessUnit__c = 'Net',
            vlocity_cmt__Status__c = 'Ativo',
            vlocity_cmt__CustomerValue__c = 'PURPLE',
            CityCode__c = '003',
            Name = '003/1234512346',
            Type = 'Cliente',
            ParentId = mainAccount.Id
        );
        lstAccounts.add(billingAccount2);

        insert lstAccounts;

        Contact contactDefault = new Contact(
            Gender__c = 'Masculino',
            DocumentType__c = 'CPF',
            Lastname = 'Stark',
            RecordTypeId = CEC_CC_ClaroContato
        );
        insert contactDefault;

        List<Skill> habilidades = [
            SELECT
                Id, DeveloperName
            FROM
                Skill
            LIMIT
                1
        ];

        ServiceResource recursoServico = new ServiceResource(
            Name = userInfo.getName(),
            IsActive = true,
            ResourceType = '',
            RelatedRecordId = UserInfo.getUserId()
        );

        insert recursoServico;

        ServiceResourceSkill habilidadeRecursoServico = new ServiceResourceSkill(
            EffectiveStartDate = Datetime.Now(),
            ServiceResourceId = recursoServico.Id,
            SkillId = habilidades[0].Id
        );

        insert habilidadeRecursoServico;

        List<Case> cases = new List<Case>();
        Case casoOuvidoria1 = new Case(
            RecordTypeId = CEC_CC_Ouvidoria,
            AccountId = mainAccount.Id,
            ContractBillingAccount__c = billingAccount1.Id,
            ContactId = contactDefault.Id,
            CriticalChannelOpenDate__c = DateTime.Now(),
            Status = 'New',
            SubStatus__c = 'Não Iniciado',
            ContactPreference__c = 'Whatsapp',
            Channel__c = 'Ouvidoria',
            InputType__c = 'Telefone',
            BusinessUnit__c = 'Claro DTH',
            Description = 'Testando Casos',
            OwnerId = UserInfo.getUserId(),
            SupportArea__c = 'CEC_CC_Ouvidoria'
        );
        cases.add(casoOuvidoria1);

        insert cases;
        
        List<CEC_CC_Entitlement__c> cec_entitlements = new List<CEC_CC_Entitlement__c>();
        CEC_CC_Entitlement__c cec_entitlement1 = new CEC_CC_Entitlement__c(
            Name = 'Ouvidoria',
            SupportArea__c = 'CEC_CC_Ouvidoria',
            TypeName__c = 'CEC_CC_CanaisCriticos'
        );        
        cec_entitlements.add(cec_entitlement1);

        CEC_CC_Entitlement__c cec_entitlement2 = new CEC_CC_Entitlement__c(
            Name = 'OuvidoSuporteOuvidoriaria',
            SupportArea__c = 'Ouvidoria',
            TypeName__c = 'CEC_CC_SuporteOuvidoria'
        );        
        cec_entitlements.add(cec_entitlement2);

        insert cec_entitlements;
        
        List<Entitlement> entitlements = new List<Entitlement>();
        
        Entitlement vEntitlement1 = new Entitlement(
        	Name = 'CEC_CC_CanaisCriticos',
            AccountId = billingAccount1.Id
        );        
        entitlements.add(vEntitlement1);

        Entitlement vEntitlement2 = new Entitlement(
        	Name = 'CEC_CC_SuporteOuvidoria',
            AccountId = billingAccount1.Id
        );        
        entitlements.add(vEntitlement2);

        insert entitlements;        
    }

    @IsTest
    static void insertSingleCase(){
        List<Account> accounts = [
            SELECT
                Id
            FROM
                Account
            WHERE
                Name = '003/1234512345' OR Name = 'Tony Stark'
            ORDER BY
                Name ASC
            LIMIT
                2
        ];

        Contact contactDefault = [
            SELECT
                Id
            FROM
                Contact
            WHERE
                LastName = 'Stark'
            LIMIT
                1
        ];

        Test.startTest();
            Case casoOuvidoria = new Case(
                RecordTypeId = CEC_CC_Ouvidoria,
                AccountId = accounts[1].Id,
                ContractBillingAccount__c = accounts[0].Id,
                ContactId = contactDefault.Id,
                CriticalChannelOpenDate__c = DateTime.Now(),
                Status = 'New',
                SubStatus__c = 'Não Iniciado',
                ContactPreference__c = 'Whatsapp',
                Channel__c = 'Ouvidoria',
                InputType__c = 'Telefone',
                BusinessUnit__c = 'Claro DTH',
                Description = 'Testando Casos 2'
            );

            try{
                insert casoOuvidoria;
            }catch(Exception e){
                System.assert(e.getMessage().contains('Não é possível criar um novo caso de ouvidoria, pois o cliente possui um em aberto. Adicione uma ação interna ao caso aberto.'));
            }
        Test.stopTest();
    }

    @IsTest
    static void insertMultipleCases(){
        List<Account> accounts = [
            SELECT
                Id
            FROM
                Account
            WHERE
                Name = '003/1234512345' OR
                Name = '003/1234512346' OR
                Name = 'Tony Stark'
            ORDER BY
                Name ASC
        ];

        Contact contactDefault = [
            SELECT
                Id
            FROM
                Contact
            WHERE
                LastName = 'Stark'
            LIMIT
                1
        ];

        Test.startTest();
            List<Case> casesLst = new List<Case>();

            Case casoOuvidoriaError = new Case(
                RecordTypeId = CEC_CC_Ouvidoria,
                AccountId = accounts[2].Id,
                ContractBillingAccount__c = accounts[0].Id,
                ContactId = contactDefault.Id,
                CriticalChannelOpenDate__c = DateTime.Now(),
                Status = 'New',
                SubStatus__c = 'Não Iniciado',
                ContactPreference__c = 'Whatsapp',
                Channel__c = 'Ouvidoria',
                InputType__c = 'Telefone',
                BusinessUnit__c = 'Claro DTH',
                Description = 'Testando Casos 2'
            );
            casesLst.add(casoOuvidoriaError);

            Case casoOuvidoriaSuccess = new Case(
                RecordTypeId = CEC_CC_Ouvidoria,
                AccountId = accounts[2].Id,
                ContractBillingAccount__c = accounts[1].Id,
                ContactId = contactDefault.Id,
                CriticalChannelOpenDate__c = DateTime.Now(),
                Status = 'New',
                SubStatus__c = 'Não Iniciado',
                ContactPreference__c = 'Whatsapp',
                Channel__c = 'Ouvidoria',
                InputType__c = 'Telefone',
                BusinessUnit__c = 'Claro DTH',
                Description = 'Testando Casos 2'
            );
            casesLst.add(casoOuvidoriaSuccess);
            
            try{
                insert casesLst;
            }catch(DmlException e){
                System.assert(e.getNumDml() >= 1);
            }
        Test.stopTest();
    }

    @IsTest
    static void redirectToLastAgent(){
        List<Account> accounts = [
            SELECT
                Id
            FROM
                Account
            WHERE
                Name = '003/1234512345' OR
                Name = 'Tony Stark'
            ORDER BY
                Name ASC
            LIMIT
                2
        ];

        Contact contactDefault = [
            SELECT
                Id
            FROM
                Contact
            WHERE
                LastName = 'Stark'
            LIMIT
                1
        ];

        Case caseTmp = [
            SELECT
                Id, Status, OwnerId, ContractBillingAccount__c
            FROM
                Case
            WHERE
                AccountId = :accounts[0].Id
            LIMIT 1
        ];

        caseTmp.Status = 'Closed';
        update caseTmp;

        Test.startTest();
            Case casoOuvidoriaSuccess = new Case(
                RecordTypeId = CEC_CC_Ouvidoria,
                AccountId = accounts[1].Id,
                ContractBillingAccount__c = caseTmp.ContractBillingAccount__c,
                ContactId = contactDefault.Id,
                CriticalChannelOpenDate__c = DateTime.Now(),
                Status = 'New',
                SubStatus__c = 'Não Iniciado',
                ContactPreference__c = 'Whatsapp',
                Channel__c = 'Ouvidoria',
                InputType__c = 'Telefone',
                BusinessUnit__c = 'Claro DTH',
                Description = 'Testando Casos 2'
            );

            insert casoOuvidoriaSuccess;

            casoOuvidoriaSuccess = [
                SELECT
                    OwnerId
                FROM
                    Case
                WHERE
                    Id = :casoOuvidoriaSuccess.Id
            ];

            System.assertEquals(caseTmp.OwnerId, casoOuvidoriaSuccess.OwnerId);
        Test.stopTest();
    }
}