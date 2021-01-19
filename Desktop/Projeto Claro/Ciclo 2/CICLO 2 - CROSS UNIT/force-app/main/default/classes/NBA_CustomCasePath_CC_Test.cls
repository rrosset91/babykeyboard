@isTest
public class NBA_CustomCasePath_CC_Test  {
    
    @IsTest 
    public static void consultarStages(){
        
        List<NBA_CustomCasePath_CC.Stage> lstStages = new List<NBA_CustomCasePath_CC.Stage>();
        
        NBA_CustomCasePath_CC.Stage stage1 = new NBA_CustomCasePath_CC.Stage();
        stage1.checked = true ;
        stage1.current = false ;
        stage1.label = 'Sondagem';
        lstStages.add(stage1);
        
        Test.startTest();
        
        Case a = new Case();
        a.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
        a.Time_of_Service__c = 'Ofertas';
        a.CallReason__c = 'Concorrência';
        a.Subreason__c = 'Produto Melhor';
        a.ProductTV__c = true;
        insert a;
        
        Case b = new Case();
        b.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Rentabilizacao').getRecordTypeId();
        b.Time_of_Service__c = 'Ofertas';
        b.CallReason__c = null;
        b.Subreason__c = null;
        b.ProductTV__c = true;
        insert b;
        
        List<NBA_CustomCasePath_CC.Stage> lstStagesRetornoA = NBA_CustomCasePath_CC.consultarStages(JSON.Serialize(a));
        List<NBA_CustomCasePath_CC.Stage> lstStagesRetornoB = NBA_CustomCasePath_CC.consultarStages(JSON.Serialize(a));

        b = NBA_CustomCasePath_CC.getCaseDetails(b.id);

        
        System.assertEquals(1, lstStagesRetornoA.size());
        System.assertEquals(1, lstStagesRetornoB.size());
        
        Test.stopTest();
    }
    
    @IsTest 
    public static void updateStageCase(){
        
        Case a = new Case();
        a.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
        a.Time_of_Service__c = 'Sondagem';
        a.CallReason__c = 'Concorrência';
        a.Subreason__c = 'Produto Melhor';
        a.CallResultIndt__c = 'Com Ação';
        a.ProductTV__c = true;
        insert a;
        
        Case b = new Case();
        b.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Rentabilizacao').getRecordTypeId();
        b.Time_of_Service__c = 'Sondagem';
        b.CallReason__c = 'Financeiro';
        b.Subreason__c = null;
        b.ProductTV__c = true;
        insert b;
        
        List<NBA_CustomCasePath_CC.Stage> lstStages = new List<NBA_CustomCasePath_CC.Stage>();
        
        NBA_CustomCasePath_CC.Stage stage1 = new NBA_CustomCasePath_CC.Stage();
        stage1.checked = true ;
        stage1.current = false ;
        stage1.label = 'Sondagem';
        lstStages.add(stage1);
        
        NBA_CustomCasePath_CC.Stage stage2 = new NBA_CustomCasePath_CC.Stage();
        stage2.checked = true ;
        stage2.current = false ;
        stage1.label = 'Ação';
        lstStages.add(stage2);
        
        NBA_CustomCasePath_CC.Stage stage3 = new NBA_CustomCasePath_CC.Stage();
        stage3.checked = true ;
        stage3.current = false ;
        stage3.label = 'Argumentação';
        lstStages.add(stage3);
        
        NBA_CustomCasePath_CC.Stage stage4 = new NBA_CustomCasePath_CC.Stage();
        stage4.checked = false ;
        stage4.current = true ;
        stage4.label = 'Oferta';
        lstStages.add(stage4);
        
        NBA_CustomCasePath_CC.Stage stage5 = new NBA_CustomCasePath_CC.Stage();
        stage5.checked = false ;
        stage5.current = false ;
        stage5.label = 'Encerramento do atendimento';
        lstStages.add(stage5);
        
        Test.startTest();
        List<NBA_CustomCasePath_CC.Stage> lstStage1 = NBA_CustomCasePath_CC.updateStageCase(a.Time_of_Service__c, a.Id, JSON.serialize(lstStages) );
        List<NBA_CustomCasePath_CC.Stage> lstStage2 = NBA_CustomCasePath_CC.updateStageByPoll(JSON.serialize(lstStages), JSON.serialize(a));
        List<NBA_CustomCasePath_CC.Stage> lstStage3 = NBA_CustomCasePath_CC.updateStageByPoll(JSON.serialize(lstStages), JSON.serialize(b));
        
        System.assertEquals(5, lstStage1.size());
        System.assertEquals(1, lstStage2.size());
        System.assertEquals(1, lstStage3.size());
        Test.stopTest();
    }
    
    @IsTest 
    public static void consultarCase(){
        Case a = new Case();
        a.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
        a.Time_of_Service__c = 'Ofertas';
        a.CallReason__c = 'Concorrência';
        a.Subreason__c = 'Produto melhor';
        a.ProductTV__c = true;
        insert a;
        
        Test.startTest();
        case teste = NBA_CustomCasePath_CC.consultarCase(a.Id);
        System.assertEquals(teste.CallReason__c, a.CallReason__c);
        System.assertEquals(teste.Subreason__c, a.Subreason__c);
        System.assertEquals(teste.Id, a.id);
        Test.stopTest();
    }
    
    @IsTest 
    public static void toRecuperaOrderId(){
        Case a = new Case();
        a.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claro_NBA_Retencao').getRecordTypeId();
        a.Time_of_Service__c = 'Ofertas';
        a.CallReason__c = 'Concorrência';
        a.Subreason__c = 'Produto melhor';
        a.ProductTV__c = true;
        insert a;
        
        Test.startTest();
        String teste = NBA_CustomCasePath_CC.toRecuperaContractId(a.Id);
        System.assertNotEquals(teste, '');
        Test.stopTest();
    }
    
    @IsTest 
    public static void isPerfilRentabilizacaoAtiva(){
        Test.startTest();
        Boolean result = NBA_CustomCasePath_CC.isPerfilRentabilizacaoAtiva();
        System.assertNotEquals(true, result);
        Test.stopTest();
    }
    @IsTest 
    public static void isPerfilRetencao(){
        Test.startTest();
        Boolean result = NBA_CustomCasePath_CC.isPerfilRetencao();
        System.assertNotEquals(true, result);
        Test.stopTest();
    }

	@IsTest 
    public static void consultarContrato(){
        Account conta = new Account();
		conta.Name = 'teste';
		conta.DocumentNumber__c = '123123123';
		insert conta;

		Contract contrato = new Contract();
		contrato.AccountId = conta.Id;
		contrato.CPF__c = '24312312';
		contrato.CityCode__c = 'SC';
		contrato.vlocity_cmt__ContractReferenceNumber__c = '09099878776765';
		insert contrato;
        
        Test.startTest();
        String id = NBA_CustomCasePath_CC.toRecuperaIdContrato(contrato.vlocity_cmt__ContractReferenceNumber__c, contrato.CityCode__c);
        System.assertEquals(id, contrato.Id);
        Test.stopTest();
    }
}