/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 12/09/2018 
* Descrição: [CEC - Fase Extensão 1 - Sprint 15] - US475 (Atribuição automática de casos de clientes recorrentes)
* 
* Controle de Versão
* ---------------------------------------------------------------
*/
@IsTest
    public class CEC_CC_CustomBasedRoutingTest {
    
    @testSetup
    private static void setup()
    {
        ServiceParameter__c varServiceParameter = CEC_SobjectFactory.getServiceParameter('CEC_OAG_NET_Ocurrency', 
                                                                                         'https://apiuat.net.com.br:7443/sdp/interactions', 
                                                                              			 'POST','x1234','APP_TESTE');
        insert varServiceParameter;
    }
    
    @isTest public static void routeUsingCustomBasedTestOpen() 
    {
        Profile varProfile = [SELECT Id FROM Profile WHERE Name = 'Supervisor Gov' LIMIT 1];
        
        Account varAcc = CEC_SobjectFactory.getAccount();
        varAcc.DocumentNumber__c = '46909498901';
        insert varAcc;
        
        Contact varContact = CEC_SobjectFactory.getContact(varAcc);
        insert varContact;        
        
        User varUser = CEC_SobjectFactory.getUser();
        varUser.profileId = varProfile.Id;
        insert varUser;       
        
        Case varCase1 = CEC_SobjectFactory.getCase(varContact);
        
        //Criar caso como outro usuario, para que o proprietario seja clonado no caso da recorrência
        System.runAs(varUser)
        {
            varCase1.BusinessUnit__c = 'Claro';
            varCase1.Channel__c = 'CIP';
            varCase1.Grouping__c = 'Procon';
            varCase1.InputType__c = 'Carta';
            varCase1.CriticalChannelProtocol__c = '123456';
            varCase1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
            insert varCase1;
        }
        
        Case varParentCase = [SELECT Owner.Name FROM Case WHERE Id =: varCase1.Id LIMIT 1];
                
        Case varCase2 = CEC_SobjectFactory.getCase(varContact);
        varCase2.BusinessUnit__c = 'Claro';
        varCase2.Channel__c = 'CIP';
        varCase2.Grouping__c = 'Procon';
        varCase2.InputType__c = 'Carta';
        varCase2.CriticalChannelProtocol__c = '123456';
        varCase2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
        
        test.startTest();        
        	insert varCase2;            
            Case varCaseRecorrente = [SELECT Owner.Name FROM Case WHERE Id =: varCase2.Id LIMIT 1];            
            System.assertEquals(varParentCase.Owner.Name, varCaseRecorrente.Owner.Name, 
                                'Erro ao criar caso recorrente, proprietário incorreto: ' + varCaseRecorrente.Owner.Name);         
        test.stopTest();
    }
    
    @isTest public static void routeUsingCustomBasedTestClosed() 
    {
        Profile varProfile = [SELECT Id FROM Profile WHERE Name = 'Supervisor Gov' LIMIT 1];
        
        Account varAcc = CEC_SobjectFactory.getAccount();
        varAcc.DocumentNumber__c = '46909498901';
        insert varAcc;
        
        Contact varContact = CEC_SobjectFactory.getContact(varAcc);
        insert varContact;        
        
        User varUser = CEC_SobjectFactory.getUser();
        varUser.profileId = varProfile.Id;
        insert varUser;       
        
        Case varCase1 = CEC_SobjectFactory.getCase(varContact);
        
        //Criar caso como outro usuario, para que o proprietario seja clonado no caso da recorrência
        System.runAs(varUser)
        {
            List<Case> userCases = new List<Case>();

            //Deixar um caso em aberto para que o usuario esteja ativo e apto a receber um caso 
        	Case varCase0 = CEC_SobjectFactory.getCase(varContact);
            varCase0.BusinessUnit__c = 'NET';
            varCase0.Channel__c = 'CIP';
            varCase0.Grouping__c = 'Procon';
            varCase0.InputType__c = 'Carta';
            varCase0.CriticalChannelProtocol__c = '123456';
            varCase0.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
            userCases.add(varCase0);
            
            varCase1.BusinessUnit__c = 'NET';
            varCase1.Channel__c = 'CIP';
            varCase1.Grouping__c = 'Procon';
            varCase1.InputType__c = 'Carta';
            varCase1.CriticalChannelProtocol__c = '123456';
            varCase1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
            userCases.add(varCase1);

            insert userCases;
        }
                    
        test.startTest();    

            Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
        
            //Deixar um caso fechado para que seja prioridade no filtro da recorrencia - Cenário 2
            varCase1.Status = 'Closed';
            update varCase1;
            
            Case varParentCase = [SELECT Owner.Name, IsClosed, ClosedDate FROM Case WHERE Id =: varCase1.Id LIMIT 1];
            
            Case varCase2 = CEC_SobjectFactory.getCase(varContact);
            varCase2.BusinessUnit__c = 'NET';
            varCase2.Channel__c = 'CIP';
            varCase2.Grouping__c = 'Procon';
            varCase2.InputType__c = 'Carta';
            varCase2.CriticalChannelProtocol__c = '123456';
            varCase2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Procon').getRecordTypeId();
        
            insert varCase2;            

            Case varCaseRecorrente = [SELECT Owner.Name FROM Case WHERE Id =: varCase2.Id LIMIT 1];            
            System.assertEquals(varParentCase.Owner.Name, varCaseRecorrente.Owner.Name, 
                                'Erro ao criar caso recorrente, proprietário incorreto: ' + varCaseRecorrente.Owner.Name);    
                                           
        test.stopTest();  
    }
    
}