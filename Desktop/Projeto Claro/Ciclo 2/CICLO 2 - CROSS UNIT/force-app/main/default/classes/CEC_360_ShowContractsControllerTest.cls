/*
* Autor: [Letícia Freitas] + Squad V360 - Deloitte
* Data: [28/05/2019]
* Descrição: [Nome do projeto/ID: CEC FASE 1 ] 
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 18/03/2019  
* Autor: Squad Visão 360 [Cintia Sousa]
* Alterações: Refact do Componente para carregar as listas e sublistas no init, ao invés de chamar o callback a cada click
* ---------------------------------------------------------------
*/
@isTest
public class CEC_360_ShowContractsControllerTest {
    
    static Id recTypeBillingAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();    
    static Id recordTypeAssetMovel = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECMovelPreControle').getRecordTypeId();
    static Id recordTypeAssetTV = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('CECTV').getRecordTypeId();
    
    @isTest
    public static void getAssetsTest(){
        
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        List<Asset> lstAssets = new List<Asset>();
        
        lstAssets.add(new Asset(Name = 'Asset Principal TV', AccountId = acc.Id, RecordTypeId = recordTypeAssetTV, Status='Ativo', SpotId__c = 'TESTE', 
                                SpotType__c = 'Principal', vlocity_cmt__BillingAccountId__c=acc.Id));
        
        lstAssets.add(new Asset(Name = 'Asset TV 1 ', AccountId = acc.Id, RecordTypeId = recordTypeAssetTV, Status='Ativo', SpotId__c= 'TESTE', Msisdn__c='19888888888'));
        
        lstAssets.add(new Asset(Name = 'Asset TV 2 ', AccountId = acc.Id, RecordTypeId = recordTypeAssetTV, Status='Ativo', SpotId__c= 'TESTE', Msisdn__c='197777777'));
        
        insert lstAssets;
        
        Test.startTest();
            List<CEC_360_ShowContractsController.TreeProducts> lstProducts = CEC_360_ShowContractsController.getAssets(acc.Id,'CECTV');
            system.debug('lstProducts: ' + lstProducts);
        Test.stopTest();
    }
    
    
    @isTest
    public static void getAssetsMovTest(){
        
        Account acc = new Account(Name = 'Acc');
        insert acc;
        
        List<Asset> lstAssets = new List<Asset>();
        lstAssets.add(new Asset(Name = 'Asset Movel Principal', AccountId = acc.Id, RecordTypeId = recordTypeAssetMovel,
                                businessUnit__c = 'CLARO', Status='Ativo', Msisdn__c = '019999999999', SpotType__c = 'PLANO_PRECO',
                                vlocity_cmt__BillingAccountId__c=acc.Id));  
        
        lstAssets.add(new Asset(Name = 'Asset Movel 1', AccountId = acc.Id ,RecordTypeId = recordTypeAssetMovel, Status='Ativo', 
                                Msisdn__c = '019999999999', ServiceType__c = 'Assinante', vlocity_cmt__BillingAccountId__c=acc.Id));
        
        lstAssets.add(new Asset(Name = 'Asset Movel 2', AccountId = acc.Id ,RecordTypeId = recordTypeAssetMovel, Status='Ativo', 
                                Msisdn__c = '019999999999', ServiceType__c = 'Assinante', vlocity_cmt__BillingAccountId__c=acc.Id));
        
        insert lstAssets;
        
        Test.startTest();
        	List<CEC_360_ShowContractsController.TreeProducts> lstProducts = CEC_360_ShowContractsController.getAssetsMov(acc.Id);
        	system.debug('lstProducts: ' + lstProducts);
        Test.stopTest();                              
    }
    
}