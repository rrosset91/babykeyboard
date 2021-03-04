/*
* Autor: Squad Canais Criticos
* Data: 23/12/2020 
* Descrição: [CEC] - [Time: SQUAD Canais Criticos]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 23/12/2020
* Autor: Squad Canais Criticos
* Alterações: Alterações nos campos Status e Sub-Status do Caso (Melhorias Ouvidoria)
* ---------------------------------------------------------------
* Autor: Squad Canais Criticos
* Data: 23/12/2020 
* Descrição: Scripts GOV
* ---------------------------------------------------------------
*/
@isTest
public class Solar_CC_InteractionReasonTest {
    @testSetup
    private static void setup(){
        
        Account conta = new Account();
        conta.name = 'Test Claro';
        conta.DocumentNumber__c = '';
        System.debug(conta.CreatedBy.UserName);
        
        insert conta;
        
        Case caso = new Case();
        caso.SuppliedEmail = 'Teste@1235678.com';
        caso.AccountId = conta.Id;
        
		insert caso;        
        
        List<QuickText> listQuickText = new List<QuickText>{new QuickText(name = 'Quick Text',
                                                                          Category = 'Motivo de Interação',
                                                                          InteractionType__c = 'Interação com o Cliente',
                                                                          message='Teste Sem campos mesclados',
                                                                          EditableScript__c = 'Sim'),
            											 	new QuickText(name = 'Quick Text com campos dinamicos',
                                                                          Category = 'Motivo de Interação',
                                                                          InteractionType__c = 'Interação com o Cliente',
                                                                          message='Numero do Caso: {!Case.CaseNumber} site XXXXX', 
                                                                          EditableScript__c = 'Parcialmente'),
            											 	new QuickText(name = 'Quick Text com campos dinamicos digitados incorretamente',
                                                                          Category = 'Motivo de Interação',
                                                                          InteractionType__c = 'Interação com o Cliente',
                                                                          Message='Numero do Caso: {!Case.CaseNumb} site XXXXX', 
                                                                          EditableScript__c = 'Parcialmente'),
            											 	new QuickText(Name= 'Quick Texto não editável',
                                                                          InteractionType__c = 'Interação com o Cliente',
                                                                          Message = 'Script não editável {!Case.CaseNumber}',
                                                                          EditableScript__c = 'Não')};                                                                              
                                                                              
        insert listQuickText;
        
        QuickText quickText = new QuickText();
        quickText.Name = 'Quick Text Test';
        quickText.Category = 'Motivo de Interação'; 
        quickText.InteractionType__c = 'Interação com o Cliente';
        quickText.Message = 
        'CaseSuppliedEmail: ' + '{!Case.SuppliedEmail}' + ',' +
        'Usuario: '+ '{!UserInfo.UserName}' + + ',' +
        'Primeiro Nome: ' + '{!UserInfo.FirstName}'  + ',' +
        'Email: '+ '{!UserInfo.Email}' +
        'Contrato: ' + '{!Case.ContractBillingAccount__c}' + ',' +
        'CPF: ' + '{!Case.Account.DocumentNumber__c}' + ',' +
        'CPF Caso Pai: ' + '{!Case.Parent.Account.DocumentNumber__c}' + ',' +
        'Email da Web Caso Pai: ' + '{!Case.Parent.SuppliedEmail}' + ',' + 
        'Conta do Caso criada por: ' + '{!Case.Account.CreatedBy.UserName}'  + ',' +
        'Conta do Caso Pai criada por: ' + '{!Case.Parent.Account.CreatedBy.UserName}' + ',' +
        'Nome perfil do usuario que criou a conta do caso pai: ' + '{!Case.Parent.Account.CreatedBy.Profile.Name}' + ',' +
        'Nome perfil do usuario que criou a conta do caso: ' + '{!Case.Account.CreatedBy.Profile.Name}' + ',' +
        'Nome da licença do perfil do usuario que criou a conta do caso: '+ '{!Case.Account.CreatedBy.Profile.UserLicense.Name}' + ',' +
        'Data/Hora atual: ' + '{!Datetime.now}' + ',' +
        'Data de Criação do caso: ' + '{!DATETIMEFORMAT(Case.CreatedDate,\'dd/MM/yyyy\')}' + ',' +
        'Hora de Criação do caso: '+ '{!DATETIMEFORMAT(Case.CreatedDate,\'HH:mm\')}'  + ',' +
        'Formato Errado: {!DATETIMEFORMAT(Case.CreatedDate,\'ab:mm\')}';
        
        insert quickText;
        
        QuickText quickTextRecusa = new QuickText();
        quickTextRecusa.Name= 'Quick Texto recusa';
        quickTextRecusa.InteractionType__c = 'Recusa da Reclamação';
        quickTextRecusa.MainText__c = quickText.Id;
        quickTextRecusa.MandatoryAttachment__c = true;
        quickTextRecusa.Message = 'Script não editável {!Case.CaseNumber}';
        quickTextRecusa.EditableScript__c = 'Não';
        quickTextRecusa.MainTextMinInterval__c = 24;
        
        insert quickTextRecusa;
        
        vlocity_cmt__CustomerInteraction__C customerInteraction = new vlocity_cmt__CustomerInteraction__c();
        customerInteraction.InteractionReason__c = listQuickText.get(0).Id;
        
        insert customerInteraction;
        
        vlocity_cmt__CustomerInteractionTopic__c customerInteractionTopic = new vlocity_cmt__CustomerInteractionTopic__c();
        customerInteractionTopic.vlocity_cmt__CaseId__c = caso.Id;
        customerInteractionTopic.vlocity_cmt__CustomerInteractionId__c = customerInteraction.Id;

        insert customerInteractionTopic;
    }
    @isTest
    private static void searchQuickTextTest(){
        Case caso = [SELECT 
                           Id, CreatedDate, SuppliedEmail, Account.Name, Account.DocumentNumber__c, Account.CreatedBy.UserName,
                           Account.CreatedBy.Profile.Name, Account.CreatedBy.Profile.UserLicense.Name
                     FROM 
                     	Case WHERE SuppliedEmail = 'Teste@1235678.com'];
        QuickText quickText = [SELECT 
                              	 Id,InteractionType__c, EditableScript__c 
                               FROM  
                              	 QuickText 
                               WHERE 
                              	 Name = 'Quick Text Test'];
        
        Test.startTest();
            Solar_CC_InteractionReason.searchQuickText(quickText.InteractionType__c);
            Map<QuickText,String> quickTextAfterMap = Solar_CC_InteractionReason.getInteractionReasonParsed(caso.Id,quickText.Id);
        Test.stopTest();
        
        String emailAddress = UserInfo.getUserEmail();
        String userName = UserInfo.getUserName();
        String firstName = UserInfo.getFirstName();
        String dateString = caso.CreatedDate.format('dd/MM/yyyy');
        String hourString = caso.CreatedDate.format('HH:mm');
        String stringDateTime = String.valueOf(datetime.now());
        String message = 
            'CaseSuppliedEmail: ' + Caso.SuppliedEmail + ',' +
            'Usuario: '+ userName + + ',' +
            'Primeiro Nome: ' + firstName  + ',' +
            'Email: '+ emailAddress +
            'Contrato: ' + ',' +
            'CPF: ' + ',' +
            'CPF Caso Pai: ' + ',' +
            'Email da Web Caso Pai: ' + ',' + 
            'Conta do Caso criada por: ' + Caso.Account.CreatedBy.UserName  + ',' +
            'Conta do Caso Pai criada por: ' + ',' +
            'Nome perfil do usuario que criou a conta do caso pai: ' + ',' +
            'Nome perfil do usuario que criou a conta do caso: ' + Caso.Account.CreatedBy.Profile.Name + ',' +
            'Nome da licença do perfil do usuario que criou a conta do caso: '+ Caso.Account.CreatedBy.Profile.UserLicense.Name + ',' +
            'Data/Hora atual: ' + ',' +
            'Data de Criação do caso: ' + dateString + ',' +
            'Hora de Criação do caso: '+ hourString  + ',' +
            'Formato Errado: ';
        
        for(QuickText quickTextKey : quickTextAfterMap.keySet()){
            System.assertEquals(message, quickTextKey.Message);
            System.assertEquals(quickTextAfterMap.get(quickTextKey),null);
            System.assertEquals(quickTextKey.EditableScript__c, quickText.EditableScript__c);
        }
    }
    
    @isTest
    private static void searchQuickTextTestQueryFailedTest(){
        Case caso = [SELECT 
                     	Id 
                     FROM 
                     	Case];
        
        QuickText quickText = [SELECT 
                              	 Id, Message
                               FROM 
                              	 QuickText 
                               WHERE 
                              	 Name = 'Quick Text Test' 
                               LIMIT 1];
        
        quickText.Message = 'Cpf da conta: {!Case.Account.DocumentNumber}';
        update quickText;
        
        Test.startTest();       
            Map<QuickText,String> quickTextAfterMap = Solar_CC_InteractionReason.getInteractionReasonParsed(caso.Id,quickText.Id);
        Test.stopTest();
        
        for(QuickText quickTextKey : quickTextAfterMap.keySet()){
            System.assertEquals(quickTextKey.EditableScript__c, 'Sim');
            System.assertEquals(quickTextKey.Message, quickText.Message);
            System.assertEquals(quickTextAfterMap.get(quickTextKey),'Erro ao Consultar o banco, verifique os campos mesclados');
        }
    }
    
    @isTest
    private static void validateDescriptionInteractionReasonTest(){
        Case caso = [SELECT 
                     	CaseNumber 
                     FROM 
                     	Case];
        
        QuickText quickText = [SELECT 
                               	Id 
                               FROM 
                               	QuickText 
                               WHERE 
                               	EditableScript__c = 'Parcialmente' 
                               AND 
                               	Name = 'Quick Text com campos dinamicos' 
                               LIMIT 1];
        
        QuickText quickTextWithIncorrectField = [SELECT 
                                                 	Message 
                                                 FROM 
                                                 	QuickText 
                                                 WHERE
                                                 	EditableScript__c = 'Parcialmente'  
                                                 AND 
                                                 	Name = 'Quick Text com campos dinamicos digitados incorretamente' 
                                                 LIMIT 1];
        
        QuickText quickTextNotEditable = [SELECT 
                                          	Message
                                          FROM
                                          	QuickText
                                          WHERE
                                          	EditableScript__c = 'Não'  
                                          AND
                                          	Name = 'Quick Texto não editável'
                                          LIMIT 1];
        
        Test.startTest();
            String outputWithBaseTexChanged = Solar_CC_InteractionReason.validateDescriptionInteractionReason('Numero do Caso: '+Caso.CaseNumber+' sit', quickText.Id, caso.Id);
            System.assert(outputWithBaseTexChanged == 'Não é permitido alterar o texto base além dos valores dinâmicos');
            outputWithBaseTexChanged = Solar_CC_InteractionReason.validateDescriptionInteractionReason('Numero do Caso: '+Caso.CaseNumber+' sit', quickTextWithIncorrectField.Id, caso.Id);
            System.assert(outputWithBaseTexChanged == 'Não é permitido alterar o texto base além dos valores dinâmicos');
        	String outputWithScriptNotEditable = Solar_CC_InteractionReason.validateDescriptionInteractionReason('Script não editável teste '+Caso.CaseNumber, quickTextNotEditable.Id, caso.Id);
        	System.assert(outputWithScriptNotEditable == 'Script não editável '+Caso.CaseNumber);
        Test.stopTest();
    }
    
    @isTest
    private static void validateInteractionReasonTest(){
        Case caso = [SELECT 
                     	CaseNumber 
                     FROM 
                     	Case];
        
        QuickText quickText = [SELECT 
                               	Id 
                               FROM 
                               	QuickText 
                               WHERE 
                               	InteractionType__c = 'Recusa da Reclamação'
                               LIMIT 1];
        
        QuickText quickTextTest = [SELECT 
                                    Id 
                                   FROM 
                                    QuickText 
                                   WHERE 
                                    Name = 'Quick Text Test'
                                   LIMIT 1];
        
        Test.startTest();
            try{
                Solar_CC_InteractionReason.validateInteractionReason(quickText.Id, caso.Id, 0);            
            }catch(CEC_IntegrationException ex){
                boolean flagError = false;
                System.assert(ex.errorMessage == Label.CEC_CC_AnexoObr);    
            }	
        
            try{
                Solar_CC_InteractionReason.validateInteractionReason(quickText.Id, caso.Id, 1);            
            }catch(CEC_IntegrationException ex){
                System.assert(ex.errorMessage == 'Não é possível registrar uma interação com o motivo Quick Texto recusa' +
                    			                 ' antes de ter uma interação com o motivo Quick Text Test registrada.');    
            }
        
            try{
                vlocity_cmt__CustomerInteraction__C customerInteraction = [SELECT 
                                                                            Id 
                                                                           FROM 
                                                                            vlocity_cmt__CustomerInteraction__C 
                                                                           LIMIT 1];
                customerInteraction.InteractionReason__c = quickTextTest.Id;
                
                update customerInteraction;
                
                Solar_CC_InteractionReason.validateInteractionReason(quickText.Id, caso.Id, 1);            
            }catch(CEC_IntegrationException ex){        
            	System.assert(ex.errorMessage == 'Não é possível registrar uma interação com o motivo Quick Texto recusa' +
                                          ' antes de ter uma interação com o motivo Quick Text Test' +
                            			  ' com menos de 24 de criação.');
            }
        Test.stopTest();
    }

    @isTest 
    static void testUpdateCaseStatus(){

        Case varCase = new Case();
        varCase.RecordTypeId = CEC_CaseTriggerHandler.CEC_CC_Ouvidoria;
        varCase.Grouping__c = 'Ouvidoria';
        varCase.Channel__c = 'Ouvidoria';
        varCase.BusinessUnit__c = 'Claro';
        varCase.BusinessUnitGroup__c = 'Claro-Internet Móvel';
        varCase.Product__c = 'Banda Larga';
        varCase.ProductFamily__c = 'Claro Móvel';
        varCase.Contract__c = '11999999999';
        varCase.Status = 'New';
        varCase.SubStatus__c = 'Não Iniciado';
        insert varCase;

        Test.startTest();
        
            Solar_CC_InteractionReason.updateCaseStatus('Registro de Tratamento', varCase);

            Case varCaseAfterUpdate = [SELECT id, Status, SubStatus__c FROM Case WHERE Id =: varCase.Id LIMIT 1];

            System.assertEquals('In Progress', varCaseAfterUpdate.Status);
            System.assertEquals('Em tratamento', varCaseAfterUpdate.SubStatus__c);

        Test.stopTest();
        
    }
}