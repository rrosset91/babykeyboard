/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 12/09/2018 
* Descrição: [CEC - Fase Extensão 1 - Sprint 15] - US475 (Atribuição automática de casos de clientes recorrentes)
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 19/11/2020
* Autor: Squad Canais Criticos
* Alterações: Ajustes para cobertura de testes referentes a unificação de canais na regra de recorrência.
* ---------------------------------------------------------------
*/

@IsTest
public class CEC_CC_CustomBasedRoutingTest {

    private static final Profile profileRepresentantesGOV = [SELECT Id FROM Profile WHERE Name = 'Representantes Gov' LIMIT 1];

    @testSetup
    private static void setup()
    {   
        // Criação de três contas, três contatos (um para cada conta) e dois usuários com perfil Representantes GOV
        // para utilização nos métodos de teste
        List<Account> accountList = new List<Account>();

        for (Integer i = 0; i <= 2; i++) {
            Account varAcc = CEC_SobjectFactory.getAccount();
            varAcc.DocumentNumber__c = '9999999999' + i;
            accountList.add(varAcc);
        }

        insert accountList;

        List<Contact> contactList = new List<Contact>();

        for (Account acc : accountList) {
            Contact varContact = CEC_SobjectFactory.getContact(acc);
            contactList.add(varContact);
        }
        
        insert contactList;

        for (Contact ct : contactList) {
            System.debug(ct);
        }
    }

    @isTest public static void routeUsingCustomBasedTestClosed() 
    {
        /* Verifica a aplicação da regra de recorrência para o terceiro caso abertos da mesma conta, quando já há dois casos (um aberto
        e outro fechado para esta conta). Valida a regra de inatividade do usuário: existe caso fechado e aberto por isso a recorrência aplica-se,
        a recorrência não deve aplicar-se quando há apenas casos fechados.
        Os casos são amarrados através do AccountID do Contato (no @testSetup foi criado um contato para cada conta) */

        Contact testContact = [SELECT Id, AccountId FROM Contact WHERE Account.DocumentNumber__c = '99999999990' LIMIT 1];

        User testUser = new user(firstName = 'test7897', lastName = 'test7897', Alias = 'alias', Email = 'teste7897@claro.com.br',
        Username = 'teste7897@claro.com.br', Profileid = profileRepresentantesGOV.Id, LanguageLocaleKey = 'pt_BR',
        EmailEncodingKey = 'ISO-8859-1', LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true);
        testUser.CommunityNickname = testUser.lastName;
        testUser.FederationIdentifier = '123456';
        insert testUser;

        Case firstCase = CEC_SobjectFactory.getCase(testContact);
        Case secondCase = CEC_SobjectFactory.getCase(testContact);
        Case thirdCase = CEC_SobjectFactory.getCase(testContact);
        
        // Cria dois casos idênticos
        for(Integer i = 0; i <= 1; i++){
            Case caseToWork;
            if(i == 0){
                caseToWork = firstCase;
            }
            else{
                caseToWork = secondCase;
            }
            caseToWork.BusinessUnit__c = 'Claro';
            caseToWork.Channel__c = 'Audiência (TNF)';
            caseToWork.Grouping__c = 'Procon';
            caseToWork.InputType__c = 'Carta';
            caseToWork.CriticalChannelProtocol__c = '123456';
            caseToWork.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
            caseToWork.AccountId = testContact.AccountId;
            caseToWork.DateOfHearing__c = Datetime.now();            
        }
        
        //Insere os casos com usuário de perfil representantes gov, fechando um deles
        System.runAs(testUser)
        {   
            List<Case> cases = new List<Case>();
            cases.add(firstCase);
            cases.add(secondCase);
            insert cases;
        }

        //Insere os casos com usuário de perfil representantes gov, fechando um deles
        secondCase.Status = 'Closed';
        update secondCase;

        test.startTest();

        // Cria e insere o terceiro caso, dessa vez com usuário de perfil administrador
        thirdCase.BusinessUnit__c = 'Claro';
        thirdCase.Channel__c = 'Audiência (TNF)';
        thirdCase.Grouping__c = 'Procon';
        thirdCase.InputType__c = 'Carta';
        thirdCase.CriticalChannelProtocol__c = '123456';
        thirdCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
        thirdCase.AccountId = testContact.AccountId;
        thirdCase.DateOfHearing__c = Datetime.now();
        insert thirdCase;                    
        
        Case firstCaseDB = [SELECT OwnerId FROM Case WHERE Id =: firstCase.Id LIMIT 1];
        Case secondCaseDB = [SELECT OwnerId FROM Case WHERE Id =: secondCase.Id LIMIT 1];
        Case thirdCaseDB = [SELECT OwnerId FROM Case WHERE Id =: thirdCase.Id LIMIT 1];

        // Testa se a recorrência foi aplicada atribuindo o mesmo owner do primeiro e segundo caso para o terceiro caso criado.
        System.assertEquals(secondCaseDB.OwnerId, thirdCaseDB.OwnerId, 
                            'Regra de recorrencia falhou: OwnerId do caso recorrente incorreto:' + thirdCaseDB.OwnerId + 
                            ' - OwnerId esperado: ' + secondCaseDB.OwnerId + 
                            ' - OwnerId do primeiro caso aberto ' + firstCaseDB.OwnerId);
                                            
        test.stopTest();  
    }

    @isTest 
    public static void routeUnifiedChannelBulk()
    {   
        /* Verifica a aplicação da regra de recorrência na criação de vários casos de tipos diferente, validando também a lista de
        exclusão presente no custom metadata type.
        Os casos são amarrados através do AccountID do Contato (no @testSetup foi criado um contato para cada conta) */

        User testUser = new user(firstName = 'test7897', lastName = 'test7897', Alias = 'alias', Email = 'teste7897@claro.com.br',
        Username = 'teste7897@claro.com.br', Profileid = profileRepresentantesGOV.Id, LanguageLocaleKey = 'pt_BR',
        EmailEncodingKey = 'ISO-8859-1', LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true);
        testUser.CommunityNickname = testUser.lastName;
        testUser.FederationIdentifier = '123456';
        insert testUser;

        List <Contact> contactList = [SELECT Id, AccountId FROM Contact WHERE Account.DocumentNumber__c = '99999999990' OR
                                      Account.DocumentNumber__c = '99999999991' OR Account.DocumentNumber__c = '99999999992' LIMIT 3];

        Contact firstContact = contactList[0];
        Contact secondContact = contactList[1];
        Contact thirdContact = contactList[2];

        Case testCase = CEC_SobjectFactory.getCase(firstContact);
        Case testCase2 = CEC_SobjectFactory.getCase(secondContact);
        Case testCase3 = CEC_SobjectFactory.getCase(thirdContact);
        Case testCase4 = CEC_SobjectFactory.getCase(firstContact);
        Case testCase5 = CEC_SobjectFactory.getCase(secondContact);
        Case testCase6 = CEC_SobjectFactory.getCase(thirdContact);

        List<Case> firstCaseList = new List<Case>();
        List<Case> secondCaseList = new List<Case>();

        // Cria casos com o usuário do perfil representantes gov
        System.runAs(testUser){
            testCase.BusinessUnit__c = 'Claro';
            testCase.Channel__c = 'CIP';
            testCase.Grouping__c = 'Procon';
            testCase.InputType__c = 'Carta';
            testCase.CriticalChannelProtocol__c = '123456';
            testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
            testCase.AccountId = firstContact.AccountId;
            firstCaseList.add(testCase);
            
            testCase2.BusinessUnit__c = 'Claro';
            testCase2.Channel__c = 'Consumidor.gov';
            testCase2.Grouping__c = 'Consumidor.gov';
            testCase2.InputType__c = 'Site Consumidor.gov';
            testCase2.CriticalChannelProtocol__c = '123456';
            testCase2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
            testCase2.AccountId = secondContact.AccountId;
            firstCaseList.add(testCase2);

            insert firstCaseList;
        }

        test.startTest();

        // Cria casos com usuário de perfil administrador
        testCase4.BusinessUnit__c = 'Claro';
        testCase4.Channel__c = 'Consumidor.gov';
        testCase4.Grouping__c = 'Consumidor.gov';
        testCase4.InputType__c = 'Site Consumidor.gov';
        testCase4.CriticalChannelProtocol__c = '123456';
        testCase4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
        testCase4.AccountId = firstContact.AccountId;
        secondCaseList.add(testCase4);
        
        testCase5.BusinessUnit__c = 'Claro';
        testCase5.Channel__c = 'CIP';
        testCase5.Grouping__c = 'Procon';
        testCase5.InputType__c = 'Carta';
        testCase5.CriticalChannelProtocol__c = '123456';
        testCase5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
        testCase5.AccountId = secondContact.AccountId;
        secondCaseList.add(testCase5);

        insert secondCaseList;

        List<Case> firstCaseListDB = [SELECT OwnerId, AccountId, BusinessUnit__c FROM Case WHERE Id IN : firstCaseList];
        List<Case> secondCaseListDB = [SELECT OwnerId, AccountId FROM Case WHERE Id IN : secondCaseList];

        // Testa a recorrência para os casos da primeira e segunda conta e a não recorrência para os casos da terceira conta
        for(Case firstVarCase : firstCaseListDB){
            for(Case secondVarCase : secondCaseListDB){
                if (firstVarCase.AccountId == secondVarCase.AccountId && firstVarCase.BusinessUnit__c != 'NET') {
                    System.assertEquals(firstVarCase.OwnerId, secondVarCase.OwnerId,
                                        'Regra de recorrencia falhou: OwnerId do segundo caso criado difere do primeiro caso');
                }
                else if(firstVarCase.AccountId == secondVarCase.AccountId && firstVarCase.BusinessUnit__c == 'NET'){
                    System.assertNotEquals(firstVarCase.OwnerId, secondVarCase.OwnerId, 
                                           'Falha: Regra de recorrencia nao deve ser aplicada para o segundo caso criado quando a' +
                                           'unidade de negocio do primeiro caso estiver presente na lista de exclusao');
                }
            }
        }

        test.stopTest();
    }

    @isTest
    public static void routeUnifiedChannelSpecialQueue()
    {   
        /* Teste da fila especial, que aplica-se a Casos de Consumidor.gov e Procon CIP
        Quando há um caso fechado e outro caso aberto de uma mesma conta atribuído a um mesmo usuário,
        na criação do terceiro caso, este cairá em uma fila especial 'SpecialCaseRecurrence'
        Os casos são amarrados através do AccountID do Contato (no @testSetup foi criado um contato para cada conta)
        */

        Contact testContact = [SELECT Id, AccountId FROM Contact WHERE Account.DocumentNumber__c = '99999999990' LIMIT 1];

        User testUser = new user(firstName = 'test7897', lastName = 'test7897', Alias = 'alias', Email = 'teste7897@claro.com.br',
        Username = 'teste7897@claro.com.br', Profileid = profileRepresentantesGOV.Id, LanguageLocaleKey = 'pt_BR',
        EmailEncodingKey = 'ISO-8859-1', LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true);
        testUser.CommunityNickname = testUser.lastName;
        testUser.FederationIdentifier = '123456';
        insert testUser;

        Case firstCase = CEC_SobjectFactory.getCase(testContact);
        Case secondCase = CEC_SobjectFactory.getCase(testContact);
        Case thirdCase = CEC_SobjectFactory.getCase(testContact);

        // Cria três casos com o mesmo usuário para a mesma conta, atualizando o status do segundo para Fechado
        System.runAs(testUser){
            List<Case> cases = new List<Case>();
            firstCase.BusinessUnit__c = 'Claro';
            firstCase.Channel__c = 'CIP';
            firstCase.Grouping__c = 'Procon';
            firstCase.InputType__c = 'Carta';
            firstCase.CriticalChannelProtocol__c = '123456';
            firstCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
            firstCase.AccountId = testContact.AccountId;
            cases.add(firstCase);            
            
            secondCase.BusinessUnit__c = 'Claro';
            secondCase.Channel__c = 'CIP';
            secondCase.Grouping__c = 'Procon';
            secondCase.InputType__c = 'Carta';
            secondCase.CriticalChannelProtocol__c = '123456';
            secondCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
            secondCase.AccountId = testContact.AccountId;
            cases.add(secondCase);

            insert cases;
        }

        test.startTest();

        secondCase.Status = 'Closed';
        update secondCase;
        
        thirdCase.BusinessUnit__c = 'Claro';
        thirdCase.Channel__c = 'CIP';
        thirdCase.Grouping__c = 'Procon';
        thirdCase.InputType__c = 'Carta';
        thirdCase.CriticalChannelProtocol__c = '123456';
        thirdCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
        thirdCase.AccountId = testContact.AccountId;
        insert thirdCase;

        // Testa a atribuição do terceiro caso criado para a fila especial
        Case thirdCaseDB = [SELECT OwnerId FROM Case WHERE Id =: thirdCase.Id LIMIT 1];
        Group ReccurencyGroupId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'SpecialCaseRecurrence' LIMIT 1];
        System.assertEquals(ReccurencyGroupId.Id, thirdCaseDB.OwnerId,
                            'Erro ao atribuir caso para a fila especial. Id proprietário esperado ' + 
                            ReccurencyGroupId.Id + ', recebido: ' + thirdCaseDB.OwnerId);


        test.stopTest();
        
    }

    /*
    @isTest
    public static void testProfilesToRoute ()
    {   
        // Regra de recorrência deve-se aplicar apenas a casos existesntes cujo owner é do perfil Representantes GOV ou
        // Representantes_Canais_Criticos. Neste método é testado a não aplicação da regra para um caso inicial atribuído
        // a um usuário de perfil administrador.
        // Os casos são amarrados através do AccountID do Contato (no @testSetup foi criado um contato para cada conta)

        Contact testContact = [SELECT Id, AccountId FROM Contact WHERE Account.DocumentNumber__c = '99999999990' LIMIT 1];

        User testUser = new user(firstName = 'test7897', lastName = 'test7897', Alias = 'alias', Email = 'teste7897@claro.com.br',
        Username = 'teste7897@claro.com.br', Profileid = profileRepresentantesGOV.Id, LanguageLocaleKey = 'pt_BR',
        EmailEncodingKey = 'ISO-8859-1', LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true);
        testUser.CommunityNickname = testUser.lastName;
        testUser.FederationIdentifier = '123456';
        insert testUser;
        
        Case firstCase = CEC_SobjectFactory.getCase(testContact);

        Case secondCase = CEC_SobjectFactory.getCase(testContact);

        // Criação de dois casos idênticos
        for(Integer i = 0; i <= 1; i++){
            Case caseToWork;
            if(i == 0){
                caseToWork = firstCase;
            }
            else{
                caseToWork = secondCase;
            }
            caseToWork.BusinessUnit__c = 'Claro';
            caseToWork.Channel__c = 'CIP';
            caseToWork.Grouping__c = 'Procon';
            caseToWork.InputType__c = 'Carta';
            caseToWork.CriticalChannelProtocol__c = '123456';
            caseToWork.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
            caseToWork.AccountId = testContact.AccountId;
        }

        // Primeiro caso é inserido com usuário de perfil administrador
        insert firstCase;

        System.runAs(testUser){
            insert secondCase; // Segundo caso é inserido com perfil Representantes GOV
        }

        test.startTest();

        Case firstCaseDB = [SELECT OwnerId FROM Case WHERE Id =: firstCase.Id LIMIT 1];
        Case secondCaseDB = [SELECT OwnerId FROM Case WHERE Id =: secondCase.Id LIMIT 1];

        // Testa a não aplicação da regra de recorrência para o segundo caso criado
        System.assertNotEquals(secondCaseDB.OwnerId, firstCaseDB.OwnerId,
                               'Falha: Regra de recorrencia nao deve ser aplicada para o segundo caso criado sendo Owner do primeiro caso um usuario admin');
        test.stopTest();
    }

    @isTest public static void routeOuvidoriaTest()
    {   
        // Testa a regra de recorrência para o canal de ouvidoria.
        // Os casos são amarrados através do AccountID do Contato (no @testSetup foi criado um contato para cada conta)

        Contact testContact = [SELECT Id, AccountId FROM Contact WHERE Account.DocumentNumber__c = '99999999990' LIMIT 1];

        User testUser = new user(firstName = 'test7897', lastName = 'test7897', Alias = 'alias', Email = 'teste7897@claro.com.br',
        Username = 'teste7897@claro.com.br', Profileid = profileRepresentantesGOV.Id, LanguageLocaleKey = 'pt_BR',
        EmailEncodingKey = 'ISO-8859-1', LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true);
        testUser.CommunityNickname = testUser.lastName;
        testUser.FederationIdentifier = '123456';
        insert testUser;
        
        Case firstCase = CEC_SobjectFactory.getCase(testContact);

        Case secondCase = CEC_SobjectFactory.getCase(testContact);

        // Cria dois casos idênticos
        for(Integer i = 0; i <= 1; i++){
            Case caseToWork;
            if(i == 0){
                caseToWork = firstCase;
            }
            else{
                caseToWork = secondCase;
            }
            caseToWork.BusinessUnit__c = 'NET';
            caseToWork.Channel__c = 'Ouvidoria';
            caseToWork.Grouping__c = 'Ouvidoria';
            caseToWork.Category__c = 'Cancelamento';
            caseToWork.InputType__c = 'Portal';
            caseToWork.CriticalChannelProtocol__c = '123456';
            caseToWork.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
            caseToWork.AccountId = testContact.AccountId;
        }

        // Insere o primeiro caso com usuário de perfil representantes gov
        System.runAs(testUser)
        {
            insert firstCase;
        }

        insert secondCase; // Insere o segundo caso com usuário administrador

        test.startTest();

        Case firstCaseDB = [SELECT OwnerId FROM Case WHERE Id =: firstCase.Id LIMIT 1];
        Case secondCaseDB = [SELECT OwnerId FROM Case WHERE Id =: secondCase.Id LIMIT 1];

        // Verifica se a regra de recorrência foi aplicada
        System.assertEquals(secondCaseDB.OwnerId, firstCaseDB.OwnerId,
                            'Regra de recorrencia falhou: OwnerId do segundo caso criado difere do primeiro caso');
        
        test.stopTest();
    }

    @isTest public static void routeUsingCustomBasedTestOpen() 
    {   
        // Verifica a aplicação da regra de recorrência para dois casos abertos da mesma conta, sendo o primeiro caso
        //   criado com o usuário de perfil Representantes GOV e o segundo caso criado com usuário administrador.
        //   Os casos são amarrados através do AccountID do Contato (no @testSetup foi criado um contato para cada conta)

        Contact testContact = [SELECT Id, AccountId FROM Contact WHERE Account.DocumentNumber__c = '99999999990' LIMIT 1];

        User testUser = new user(firstName = 'test7897', lastName = 'test7897', Alias = 'alias', Email = 'teste7897@claro.com.br',
        Username = 'teste7897@claro.com.br', Profileid = profileRepresentantesGOV.Id, LanguageLocaleKey = 'pt_BR',
        EmailEncodingKey = 'ISO-8859-1', LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true);
        testUser.CommunityNickname = testUser.lastName;
        testUser.FederationIdentifier = '123456';
        insert testUser;
        
        Case firstCase = CEC_SobjectFactory.getCase(testContact);

        Case secondCase = CEC_SobjectFactory.getCase(testContact);

        // Cria dois casos identicos
        for(Integer i = 0; i <= 1; i++){
            Case caseToWork;
            if(i == 0){
                caseToWork = firstCase;
            }
            else{
                caseToWork = secondCase;
            }
            caseToWork.BusinessUnit__c = 'Claro';
            caseToWork.Channel__c = 'CIP';
            caseToWork.Grouping__c = 'Procon';
            caseToWork.InputType__c = 'Carta';
            caseToWork.CriticalChannelProtocol__c = '123456';
            caseToWork.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
            caseToWork.AccountId = testContact.AccountId;
        }

        System.runAs(testUser){
            insert firstCase; // Insere o primeiro caso com usuário do perfil representates gov
        }

        insert secondCase; // Insere o segundo caso com usuário de perfil administrador

        test.startTest();

        Case firstCaseDB = [SELECT OwnerId FROM Case WHERE Id =: firstCase.Id LIMIT 1];
        Case secondCaseDB = [SELECT OwnerId FROM Case WHERE Id =: secondCase.Id LIMIT 1];

        // Testa se a recorrência foi aplicada atribuindo o mesmo owner do primeiro caso para o segundo caso criado.
        System.assertEquals(firstCaseDB.OwnerId, secondCaseDB.OwnerId,
                            'Regra de recorrencia falhou: OwnerId do segundo caso criado difere do primeiro caso');
        
        test.stopTest();
    }
    */
}