@isTest

public with sharing class CEC_360_ShowCanceledProdControllerTest {

    @isTest public static void getAssetsTest  (){
       Account acc = new Account(Name = 'Acc');
        insert acc;
        
        Asset ass = new Asset(Name = 'Ass', AccountId = acc.Id, SpotId__c='123456',Status='Ativo');
        Asset ass2 = new Asset(Name = 'Ass', AccountId = acc.Id, SpotId__c='123456',Status='Ativo');
        insert ass;  
		List<Asset> subProducts = new List<Asset>();
        subProducts.add(ass);
        subProducts.add(ass2);
        CEC_360_ShowCanceledProductsController.getAssets(ass.Id);
        CEC_360_ShowCanceledProductsController.formatSubWrapper(subProducts);
    }
}