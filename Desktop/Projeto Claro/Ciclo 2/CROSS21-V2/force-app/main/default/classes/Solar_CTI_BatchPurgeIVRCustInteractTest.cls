/*
    * Autor: Wanderson Viena - Deloitte
    * Descrição: [Nome do projeto/ID: Solar FASE 2] + [Time: SQUAD CTI - Semana 3] + [92254 - CTI - 
    * CRM CROSS - PROTOCOLO URA RESIDENCIAL + 92255 CTI - CRM CROSS - PROTOCOLO URA MÓVEL + 
    * 92248 CTI - CRM CROSS - SCRIPT POINT NAVEGAÇÃO URA RESIDENCIAL]
    * Classe de teste utilizada para expurgo ds registros de Customer Interaction com Recordtype DadosURA que foram criados no dia
    * anterior e não possuem um Customer Interaction Topic como filho.
*/
@isTest
public class Solar_CTI_BatchPurgeIVRCustInteractTest {
     @testSetup static void doTheSetup()
    {
        Id idRecordId = Schema.SObjectType.vlocity_cmt__CustomerInteraction__c.getRecordTypeInfosByDeveloperName().get('DadosURA').getRecordTypeId();
        
        vlocity_cmt__CustomerInteraction__c varCustomerInteractionWtopic = new vlocity_cmt__CustomerInteraction__c();
        varCustomerInteractionWtopic.RecordTypeId = idRecordId;
        varCustomerInteractionWtopic.Name = 'IVR - 54123';
        varCustomerInteractionWtopic.ProtocolNumber__c = '54123';
        
        insert varCustomerInteractionWtopic;
        
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(varCustomerInteractionWtopic.Id, yesterday);
        
        system.debug('CustomerInteractionWtopic ' +varCustomerInteractionWtopic.CreatedDate);
        /*
        vlocity_cmt__CustomerInteractionTopic__c varCustomerInteractiontopic = new vlocity_cmt__CustomerInteractionTopic__c();
        varCustomerInteractiontopic.Name = 'CIT - IVR - 54123';
        varCustomerInteractiontopic.vlocity_cmt__CustomerInteractionId__c = varCustomerInteractionWtopic.id;
        
        insert varCustomerInteractiontopic;
        
        Test.setCreatedDate(varCustomerInteractiontopic.Id, yesterday);
        system.debug('CustomerInteractiontopic ' +varCustomerInteractiontopic.CreatedDate);
        */
    //    vlocity_cmt__CustomerInteraction__c cstAux = new vlocity_cmt__CustomerInteraction__c();
        /*list<vlocity_cmt__CustomerInteraction__c> CustomerInteractionNtopic = new list<vlocity_cmt__CustomerInteraction__c>();
        for (integer i= 10; i<10;i++){   
            CustomerInteractionNtopic.add(new vlocity_cmt__CustomerInteraction__c(
                name='IVR '+i,RecordTypeId = idRecordId));            
        }*/
        
        vlocity_cmt__CustomerInteraction__c varCustomerInteractionNtopic = new vlocity_cmt__CustomerInteraction__c();
        varCustomerInteractionNtopic.RecordTypeId = idRecordId;
        varCustomerInteractionNtopic.Name = 'IVR - 65242';
        varCustomerInteractionNtopic.ProtocolNumber__c = '65242';
        insert varCustomerInteractionNtopic;
		Test.setCreatedDate(varCustomerInteractionNtopic.Id, yesterday);
        
        system.debug('varCustomerInteractionNtopic ' +varCustomerInteractionNtopic.CreatedDate);
       	system.debug('********');
    }
    
     @isTest static void testeDelete(){
                
		test.startTest();
            Database.executeBatch(new Solar_CTI_BatchPurgeIVRCustInteraction(null,null));
        test.stopTest();
        Id idRecordId = Schema.SObjectType.vlocity_cmt__CustomerInteraction__c.getRecordTypeInfosByDeveloperName().get('DadosURA').getRecordTypeId();
        list<vlocity_cmt__CustomerInteraction__c> lstValidation = [SELECT id from vlocity_cmt__CustomerInteraction__c where RecordTypeId =:idRecordId and CreatedDate = YESTERDAY];
        System.assertEquals(lstValidation.size(), 0);
        
    }
    
    @isTest static void testSchedule()
    {
        Datetime lSch5 = system.now().addMinutes(5);
        String cron = '0 ' + String.valueOf(lSch5.minute()) + ' ' + String.valueOf(lSch5.hour()) + ' * * ?';
        
        test.startTest();
        String lJobId = system.schedule('Deletar Customer Interaction teste', cron, new Solar_CTI_BatchPurgeIVRCustInteraction(null, null));
        test.stopTest();
        
        system.abortJob(lJobId);
        system.assert(lJobId != null);
    }
    @isTest static void testScheduleJob(){
        String cron = '0 ' + '0 ' + '10 ' + '? ' + '* ' + '2-6';
        test.startTest();
        String lJobId = system.schedule('Deletar Customer Interaction', cron, new Solar_CTI_BatchPurgeIVRCustInteraction(null, null));
        try
        {
            Solar_CTI_BatchPurgeIVRCustInteraction.startJob();
        }
        catch(Exception ex)
        {
            //System.debug('#Erro agendamento ' + ex + ' Cause ' + ex.getCause());
            //Classe já está agendada no ambiente atual
            System.assert(ex.getMessage().contains('Deletar Customer Interaction'));
        }
        test.stopTest();
        
        //Foi "Criado" um novo agendamento
        system.abortJob(lJobId);
        system.assert(lJobId != null);       
    }
    
    @isTest static void testScheduleExecute()
    {      	
        
        list<vlocity_cmt__CustomerInteraction__c> lstCustomerInteraction = new list<vlocity_cmt__CustomerInteraction__c>();
        Id idRecordId = Schema.SObjectType.vlocity_cmt__CustomerInteraction__c.getRecordTypeInfosByDeveloperName().get('DadosURA').getRecordTypeId();
        
        vlocity_cmt__CustomerInteraction__c varCustomerInteractionWtopic = new vlocity_cmt__CustomerInteraction__c();
        varCustomerInteractionWtopic.RecordTypeId = idRecordId;
        varCustomerInteractionWtopic.Name = 'IVR - 54123';
        varCustomerInteractionWtopic.ProtocolNumber__c = '54123';
        
        insert varCustomerInteractionWtopic;
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(varCustomerInteractionWtopic.Id, yesterday);
        vlocity_cmt__CustomerInteraction__c varCustomerInteractionNtopic = new vlocity_cmt__CustomerInteraction__c();
        varCustomerInteractionNtopic.RecordTypeId = idRecordId;
        varCustomerInteractionNtopic.Name = 'IVR - 65242';
        varCustomerInteractionNtopic.ProtocolNumber__c = '65242';
        insert varCustomerInteractionNtopic;
		Test.setCreatedDate(varCustomerInteractionNtopic.Id, yesterday);
        
        lstCustomerInteraction.add(varCustomerInteractionWtopic);
        lstCustomerInteraction.add(varCustomerInteractionNtopic);
        
        Solar_CTI_BatchPurgeIVRCustInteraction batch = new Solar_CTI_BatchPurgeIVRCustInteraction('2020-07-01', '2020-07-30');
        
        test.startTest();
        String lJobId = database.executeBatch(batch);
        batch.execute(null, lstCustomerInteraction);
        test.stopTest();
        
        system.abortJob(lJobId);
        system.assert(lJobId != null);
    }
}