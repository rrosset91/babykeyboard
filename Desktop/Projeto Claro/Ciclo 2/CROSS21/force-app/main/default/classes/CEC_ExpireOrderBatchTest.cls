/*
* Autor: Henrique Almeida
* Data: 08-mar-2018
* Descrição: Classe de teste responsável por testar a CEC_ExpireOrderBatch
*/

@isTest
public class CEC_ExpireOrderBatchTest 
{
    @testSetup
    public static void testExpireOrder()
    {
        Id recTypeComercial = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Comercial').getRecordTypeId();
        
        CEC_OrderExpiration__c customSetting = new CEC_OrderExpiration__c();
        customSetting.Name = 'CalculoExpiração';
        customSetting.Dia__c = 0;
        customSetting.Status__c = 'Cancelada';
		insert customSetting;       
        
        Account varAccount = CEC_SobjectFactory.getAccount();
        insert varAccount;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 varPrice = new Pricebook2();
        varPrice.Name = 'Teste Pricebook';
        insert varPrice;
        
        Product2 varProduct = CEC_SobjectFactory.getProduct();
        insert varProduct;
        
        Order varOrder = CEC_SobjectFactory.getOrder(varAccount);
        varOrder.Pricebook2Id = varPrice.Id;
        varOrder.RecordTypeId = recTypeComercial;
        insert varOrder;
        
        PricebookEntry varEntryStd = CEC_SobjectFactory.getStdPricebookEntry(varProduct);
        varEntryStd.UnitPrice = 1;
        insert varEntryStd;
        
        PricebookEntry varEntry = CEC_SobjectFactory.getPricebookEntry(varProduct, varPrice);
        varEntry.UnitPrice = 1;
        insert varEntry;
        
        OrderItem varItem = CEC_SobjectFactory.getOrderItem(varOrder, varEntry);
        insert varItem;
    }
    @isTest
    private static void unitTest()
    {
        CEC_ExpireOrderBatch batch = new CEC_ExpireOrderBatch();
        Database.executeBatch(batch, 100);
    }
}