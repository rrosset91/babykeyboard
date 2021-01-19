/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-02-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   10-02-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class CEC_CC_ValidationRuleCaseTest {

    private class MyException extends Exception {
    }

    @IsTest
    static void CEC_CC_Req_Encerramento_PreJecTest(){
        String CEC_CC_Pre_JEC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Pre_JEC').getRecordTypeId();

        User u = createUserCanaisCriticos();

        System.runAs(u){
            Case newCase = createCasePrejecPreProcessual();
            Test.startTest();
            try{
                newCase.SubStatus__c = 'Encerrado';
                update newCase;
                throw new MyException('Uma exceção deveria ser levantada mas não foi');
            } catch (Exception ex) {
                 System.assert(ex.getMessage().contains('Os campos "Reclamação é Procedente", "Resolução", "Houve acordo" e "Motivo de Saída" precisam ser informados.'));
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void CEC_CC_ValidaStatusEncerradoPS8(){
        String CEC_CC_Procon = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();

        Profile p = [SELECT Id FROM Profile WHERE Name='Representantes Canais Criticos'];
        UserRole ro = [SELECT Id FROM UserRole WHERE Name='Representante Consumidor.gov'];
        User u = new User(Alias='TestUser', LastName='Test', Email='testUser@test.com', 
        ProfileId = p.Id, 
        UserRoleId = ro.Id,
        LanguageLocaleKey='pt_BR', 
        LocaleSidKey = 'pt_BR',
        TimeZoneSidKey = 'GMT',
        EmailEncodingKey='UTF-8',

        UserName='test@CEC_CC_Req_Encerramento_PreJecTest.com');

        System.runAs(u){
            Case newCase = createCaseProcon();
            Test.startTest();
            try{
                newCase.SubStatus__c = 'Encerrado';
                update newCase;
                throw new MyException('Uma exceção deveria ser levantada mas não foi');
            } catch (Exception ex) {
                System.assert(ex.getMessage().contains('Verificar se os campos da seção "Tipificação Motivo de Saída" foram preenchidos.'));
            }
            Test.stopTest();
        }
    }


    // @IsTest
    // static void CEC_CC_Req_CamposResolucao_Gov(){
    //     String CEC_CC_Procon = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();

    //     Profile p = [SELECT Id FROM Profile WHERE Name='Representantes Gov'];
    //     UserRole ro = [SELECT Id FROM UserRole WHERE Name='Representante Consumidor.gov'];
    //     User u = new User(Alias='TestUser', LastName='Test', Email='testUser@test.com', 
    //     ProfileId = p.Id, 
    //     UserRoleId = ro.Id,
    //     LanguageLocaleKey='pt_BR', 
    //     LocaleSidKey = 'pt_BR',
    //     TimeZoneSidKey = 'GMT',
    //     EmailEncodingKey='UTF-8',

    //     UserName='test@CEC_CC_Req_Encerramento_PreJecTest.com');
    //     Case newCase = new Case(
    //         AccountId = acc.Id,
    //         ContactId = acc.vlocity_cmt__PersonContactId__c,
    //         RecordTypeId = RT_CONSUMIDOR_GOV,
    //         CriticalChannelOpenDate__c = Date.Today(),
    //         Company__c = 'Claro Celular',
    //         OpenDateRobot__c = Date.today(),
    //         Status='New',
    //         SubStatus__c='Não Iniciado', 
    //         CriticalChannelProtocol__c = '2020202020',
    //         ChannelTerm__c = Date.Today().AddDays(10),
    //         ContactPreference__c = 'Telefone',
    //         Channel__c='Consumidor.gov',
    //         Origin='Web',
    //         InputType__c = 'Site Consumidor.gov',
    //         BusinessUnit__c='Claro',
    //         Product__c='Controle',
    //         Contract__c='69981407803',
    //         //Input_Subject__c = subject.Id,
    //         Subject = 'teste',
    //         Description = 'teste',
    //         CompanyRequest__c = 'teste',
    //         Manager__c = 'teste'
    //         );
    //     System.runAs(u){
    //        // Case newCase = createCaseConsumidorGov();
    //         Test.startTest();
    //         try{
    //             newCase.SubStatus__c = 'Respondido e Aguardando Avaliação';
    //             update newCase;
    //             throw new MyException('Uma exceção deveria ser levantada mas não foi');
    //         } catch (Exception ex) {
    //             System.assert(ex.getMessage().contains('informar se a "Reclamação é Procedente", a "Resolução" e se "Houve acordo"'));
    //         }
    //         Test.stopTest();
    //     }
    // }

        @IsTest
    static void CEC_CC_Req_CamposResolucao_Gov(){
        String RT_CONSUMIDOR_GOV = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();

        Profile p = [SELECT Id FROM Profile WHERE Name='Representantes Gov'];
        UserRole ro = [SELECT Id FROM UserRole WHERE Name='Representante Consumidor.gov'];
        User u = new User(Alias='TestUser', LastName='Test', Email='testUser@test.com', 
        ProfileId = p.Id, 
        UserRoleId = ro.Id,
        LanguageLocaleKey='pt_BR', 
        LocaleSidKey = 'pt_BR',
        TimeZoneSidKey = 'GMT',
        EmailEncodingKey='UTF-8',

        UserName='test@CEC_CC_Req_Encerramento_PreJecTest.com');
        Case newCase = new Case(
            RecordTypeId = RT_CONSUMIDOR_GOV,
            CriticalChannelOpenDate__c = Date.Today(),
            Company__c = 'Claro Celular',
            OpenDateRobot__c = Date.today(),
            Status='New',
            SubStatus__c='Não Iniciado', 
            CriticalChannelProtocol__c = '2020202020',
            ChannelTerm__c = Date.Today().AddDays(10),
            ContactPreference__c = 'Telefone',
            Channel__c='Consumidor.gov',
            Origin='Web',
            InputType__c = 'Site Consumidor.gov',
            BusinessUnit__c='Claro',
            Product__c='Controle',
            Contract__c='69981407803',
            //Input_Subject__c = subject.Id,
            Subject = 'teste',
            Description = 'teste',
            CompanyRequest__c = 'teste',
            Manager__c = 'teste'
            );

        // SubjectAdministration__c subjectClasse900 = new SubjectAdministration__c(
        //     Name = 'Teste Classe 900',
        //     Reason__c = 'CLASSE 900',
        //     BusinessUnit__c = 'Claro',
        //     Classification__c = 'Claro Pré Pago'
        // );
        // insert subjectClasse900;
        System.runAs(u){
            Test.startTest();
            newCase.SubStatus__c = 'Respondido e Aguardando Avaliação';
            //newCase.Output_Subject__c = subjectClasse900.Id;
            List<Case> newCases = new List<Case>{ newCase };
            CEC_CC_ValidationRuleCase.validationRules(newCases);
            Test.stopTest();
            System.debug(ApexPages.getMessages()[0].getSummary());
            System.assert( ApexPages.hasMessages());
            System.assert(ApexPages.getMessages()[0].getSummary().contains('informar se a "Reclamação é Procedente", a "Resolução" e se "Houve acordo"'));
        }
    }

    private static User createUserCanaisCriticos(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Gerente Canais Criticos'];
        UserRole ro = [SELECT Id FROM UserRole WHERE Name='Gerente Canais Críticos'];
        User u = new User(Alias='TestUser', LastName='Test', Email='testUser@test.com', 
        ProfileId = p.Id, 
        UserRoleId = ro.Id,
        LanguageLocaleKey='pt_BR', 
        LocaleSidKey = 'pt_BR',
        TimeZoneSidKey = 'GMT',
        EmailEncodingKey='UTF-8',

        UserName='test@CEC_CC_Req_Encerramento_PreJecTest.com');
        return u;
    }

    private static Case createCasePrejecPreProcessual(){
        String CEC_CC_Pre_JEC = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Pre_JEC').getRecordTypeId();
        Case newCase = new Case(
            RecordTypeId = CEC_CC_Pre_JEC,
            CriticalChannelOpenDate__c = Date.Today(),
            Status='New',
            SubStatus__c='Não Iniciado', 
            ChannelTerm__c = Date.Today().AddDays(10),
            ContactPreference__c = 'Telefone',
            Channel__c='Pré Processual',
            InputType__c = 'Carta',
            BusinessUnit__c='Claro',
            Product__c='Controle',
            Contract__c='69981407803'
            );
        insert newCase;
        return newCase;
    }
    


	private static Case createCaseProcon(){
        String CEC_CC_Procon = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
        Account acc = insertAccount();
        SubjectAdministration__c subject = new SubjectAdministration__c(
            Name = 'Teste',
            Reason__c = 'Reason',
            BusinessUnit__c = 'Claro',
            Classification__c = 'Pré'
        );
        insert subject;

        Case newCase = new Case(
            AccountId = acc.Id,
            ContactId = acc.vlocity_cmt__PersonContactId__c,
            RecordTypeId = CEC_CC_Procon,
            CriticalChannelOpenDate__c = Date.Today(),
            Status='New',
            SubStatus__c='Não Iniciado', 
            CriticalChannelProtocol__c = '2020202020',
            ChannelTerm__c = Date.Today().AddDays(10),
            ContactPreference__c = 'Telefone',
            Channel__c='Pré Procon',
            InputType__c = 'E-mail',
            BusinessUnit__c='Claro',
            Product__c='Controle',
            Contract__c='69981407803',
            Input_Subject__c = subject.Id,
            Description = 'teste',
            DateOfHearing__c = Date.today().addDays(-30)
            );
        insert newCase;
        return newCase;
    }
    
    private static Case createCaseConsumidorGov(){
        String RT_CONSUMIDOR_GOV = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
        Account acc = insertAccount();
        SubjectAdministration__c subject = new SubjectAdministration__c(
            Name = 'Teste',
            Reason__c = 'Reason',
            BusinessUnit__c = 'Claro',
            Classification__c = 'Pré'
        );
        insert subject;

        Case newCase = new Case(
            AccountId = acc.Id,
            ContactId = acc.vlocity_cmt__PersonContactId__c,
            RecordTypeId = RT_CONSUMIDOR_GOV,
            CriticalChannelOpenDate__c = Date.Today(),
            Company__c = 'Claro Celular',
            OpenDateRobot__c = Date.today(),
            Status='New',
            SubStatus__c='Não Iniciado', 
            CriticalChannelProtocol__c = '2020202020',
            ChannelTerm__c = Date.Today().AddDays(10),
            ContactPreference__c = 'Telefone',
            Channel__c='Consumidor.gov',
            Origin='Web',
            InputType__c = 'Site Consumidor.gov',
            BusinessUnit__c='Claro',
            Product__c='Controle',
            Contract__c='69981407803',
            //Input_Subject__c = subject.Id,
            Subject = 'teste',
            Description = 'teste',
            CompanyRequest__c = 'teste',
            Manager__c = 'teste'
            );
        insert newCase;
        return newCase;
	}

    private static Account insertAccount(){
        Contact ctt = new Contact ();
        ctt.FirstName  = 'Angela Maria';
        ctt.LastName = '.';
        ctt.DocumentNumber__c =  '44080794720';
        ctt.DocumentType__c = 'CPF';
        ctt.Email= 'ello.oliveira@sysmap.com.br';
        insert ctt;

        Account customer = new Account(
            name = 'Angela Maria',
            DocumentType__c = 'CPF',
            DocumentNumber__c = '44080794720',
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName()
                .get('Consumer')
                .getRecordTypeId(),
            vlocity_cmt__PersonContactId__c = ctt.Id
        );

        insert customer;
        return customer;
    } 
}