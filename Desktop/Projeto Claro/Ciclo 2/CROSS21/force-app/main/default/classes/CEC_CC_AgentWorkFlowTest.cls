@IsTest
public class CEC_CC_AgentWorkFlowTest {
    
    @isTest public static void testCasoEmTratamentoOK() 
    {
        Set<String> setAllowdProfiles = new Set<String>{'Administrador do sistema','System Administrator'};
        User userADM = [SELECT Id FROM User WHERE Profile.Name IN: setAllowdProfiles AND IsActive = true LIMIT 1];
        
        system.runAs(userADM) {
            
            User varRepGov = CEC_SobjectFactory.getUser();
            varRepGov.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Representantes Gov' LIMIT 1].Id;
            insert varRepGov;
            system.assert(varRepGov.Id <> null, 'Erro ao criar usuário com Perfil de Representante Gov');
            
            Account varAcc = CEC_SobjectFactory.getAccount();
            varAcc.DocumentNumber__c = '46909498901';
            insert varAcc;
            system.assert(varAcc.Id <> null, 'Erro ao criar conta para atrelar ao caso');
            
            Contact varContact = CEC_SobjectFactory.getContact(varAcc);
            insert varContact;        
            system.assert(varContact.Id <> null, 'Erro ao criar contato para atrelar ao caso');
            
            Case varCase = CEC_SobjectFactory.getCase(varContact);
            varCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
            varCase.Company__c = 'Claro Celular';
            insert varCase;
            system.assert(varCase.Id <> null, 'Erro ao criar caso de Consumidor GOV');
            
            test.startTest();   
            
            List<CEC_CC_AgentWorkFlow.Agente> lstAgents = new List<CEC_CC_AgentWorkFlow.Agente>();
            CEC_CC_AgentWorkFlow.Agente agente = new CEC_CC_AgentWorkFlow.Agente();
            agente.UserId = varRepGov.Id;
            agente.WorkItemId = varCase.Id;
            lstAgents.add(agente);
            
            CEC_CC_AgentWorkFlow.setCaseUp(lstAgents);
            
            test.stopTest();
            
            system.assertEquals('In Progress', [SELECT Status, SubStatus__c FROM CASE].Status, 'Erro ao atualizar status do caso na distribuição do omni para repGOV');
            system.assertEquals('Em tratamento', [SELECT Status, SubStatus__c FROM CASE].SubStatus__c, 'Erro ao atualizar status do caso na distribuição do omni para repGOV');
            
        }
    }        
    
    @isTest public static void testCasoEmTratamentoNOK() 
    {
        Set<String> setAllowdProfiles = new Set<String>{'Administrador do sistema','System Administrator'};
            
        Account varAcc = CEC_SobjectFactory.getAccount();
        varAcc.DocumentNumber__c = '46909498901';
        insert varAcc;
        system.assert(varAcc.Id <> null, 'Erro ao criar conta para atrelar ao caso');
        
        Contact varContact = CEC_SobjectFactory.getContact(varAcc);
        insert varContact;   
        system.assert(varContact.Id <> null, 'Erro ao criar contato para atrelar ao caso');
        
        Case varCase = CEC_SobjectFactory.getCase(varContact);
        varCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
        varCase.Company__c = 'Claro Celular';
        insert varCase;
        system.assert(varCase.Id <> null, 'Erro ao criar caso de Consumidor GOV');
        
        test.startTest();   
                    
        	List<CEC_CC_AgentWorkFlow.Agente> lstAgents = new List<CEC_CC_AgentWorkFlow.Agente>();
            CEC_CC_AgentWorkFlow.Agente agente = new CEC_CC_AgentWorkFlow.Agente();
            agente.UserId = UserInfo.getUserId();
            agente.WorkItemId = varCase.Id;
            lstAgents.add(agente);
                
        	CEC_CC_AgentWorkFlow.setCaseUp(lstAgents);
                
        test.stopTest();
        
        system.assertEquals('New', [SELECT Status, SubStatus__c FROM CASE].Status, 'Erro ao atualizar status do caso na atribuição do omni para outros perfis');
        system.assertEquals('Não Iniciado', [SELECT Status, SubStatus__c FROM CASE].SubStatus__c, 'Erro ao atualizar status do caso na atribuição do omni para outros perfis');
    }        
}