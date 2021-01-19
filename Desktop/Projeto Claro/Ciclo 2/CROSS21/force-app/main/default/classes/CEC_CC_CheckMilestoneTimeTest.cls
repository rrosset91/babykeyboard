@IsTest
public class CEC_CC_CheckMilestoneTimeTest {

    @isTest 
    public static void caseMilestoneNullTest() {
        Profile varProfile = [SELECT Id FROM Profile WHERE Name = 'Supervisor Gov' LIMIT 1];

        Account varAcc = CEC_SobjectFactory.getAccount();
        varAcc.DocumentNumber__c = '46909498901';
        insert varAcc;
        
        Contact varContact = CEC_SobjectFactory.getContact(varAcc);
        insert varContact;        
        
        User varUser = CEC_SobjectFactory.getUser();
        varUser.profileId = varProfile.Id;
        insert varUser;    
        
        //Deixar um caso em aberto para que o usuario esteja ativo e apto a receber um caso 
        Case varCase = CEC_SobjectFactory.getCase(varContact);
        //varCase.ContactId = varContact.ID;
        varCase.AccountId = varAcc.ID;
        varCase.SituationCase__c = null;
        varCase.SupportArea__c = null;
        varCase.IsStopped  = false;
        varCase.Contract__c = null;
        
        varCase.BusinessUnit__c = null;
        varCase.InputType__c = 'Site Consumidor.gov';
        varCase.Company__c = 'Claro Celular';
        varCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();
        test.startTest(); 
        insert varCase; 
        
        List<String> cases = new List<String>();
        cases.add(varCase.Id);       
        
        CEC_CC_CheckMilestoneTime.checkMilestoneTimeCase(cases);
        
        test.stopTest(); 
        
        List<CaseMilestone> milestones = [SELECT TargetDate, CaseId FROM CaseMilestone WHERE CaseId = :varCase.Id ];
            
        System.debug('#Milestones: ' + milestones.size());
        Case varParentCase = [SELECT MilestoneTime__c FROM Case WHERE Id =: varCase.Id LIMIT 1];
        
        //System.assertEquals('Em tratamento', varParentCase.SubStatus__c, 'Erro ao vincular o SubStatus para "Em Tratamento"');               
        //System.assertNotEquals(null, varParentCase.MilestoneTime__c, 'Erro ao atualizar  milestone para o caso!');         
    }
}