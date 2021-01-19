/*Versão 1.0
* - Lucas Barbosa - 09/04/2019 
	Classe de teste para cobertura da classe CEC_SendToRobotController
*/
@isTest
public class CEC_SendToRobotControllerTest {
    private static Id orderId;
    private static String cpf;
    
    //LB - Modelo de dados para teste de preenchimento do método
    public class robotTest{
        public String sIdVenda {get; set;}
        public String sCPF {get; set;}
    }
    //LB - Cria massa de produtos, order, order item e pricebook
    static private testmethod void testProductSetup(){
        
        List<SObject> sObjList = new List<sObject>();
        Product2 prod1 = new Product2 (Name='Claro Pos Play 10GB', ProductCode = 'COM_POS_10GB_000001', vlocity_cmt__Type__c = 'Plano');
        sObjList.add(prod1);
        
        insert sObjList;
        sObjList.clear();
        
        Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(), Name = 'TestPricebook5', IsActive = true);
        Pricebook2 testPricebook = new Pricebook2(Name = 'TestPricebook7', IsActive = true);
        insert testPricebook;
        
        //Inserting into standard Pricebook
        PricebookEntry pbe11 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                                                  Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true);
        sObjList.add(pbe11);
        //insert sObjList;
        
        //Inserting into Custom Pricebook
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                                                 Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe1);
        
        insert sObjList;
        sObjList.clear();
        
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = testPricebook.Id, vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'TestPricebook5');
        insert pl1;
        
        
        Account a = new Account(Name='Account Test', BirthDate__c = Date.newInstance(1977,11,30), Gender__c = 'Feminino', 
                                MothersName__c = 'mãe', DocumentNumber__c = '08808327388', MaritalStatus__c = 'Casado', DocumentType__c = 'CPF',
                                Occupation__c = 'ASSISTENTE COMERCIAL', SalaryRange__c = 'De R$3.000,00 ate R$4.000,00');
        cpf = a.DocumentNumber__c;
        insert a;
        
        Order testOrder = new Order(Name='Test Order',EffectiveDate=System.today(), Forma_de_Pagamento__c='Boleto',
                                    status='Draft',AccountId = a.Id, vlocity_cmt__PriceListId__c = pl1.Id, NovoEndereco__c = true, 
                                    BillingNumber__c = '233', BillingStreet = 'RUA A', Complemento1__c = '12342123', TipoComplemento1__c = 'ACAD',
                                    Complemento2__c = '12342123', TipoComplemento2__c = 'ACAD', Complemento3__c = '12342123', TipoComplemento3__c = 'ACAD',
                                    Complemento4__c = '12342123', TipoComplemento4__c = 'ACAD', Pricebook2Id = testPricebook.Id, BillingPostalCode ='04836250');
        insert testOrder;
        orderId = testOrder.Id;
        
        List<priceBookEntry> priceBookEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod1.Id];
        Id priceBookEntryId = priceBookEntry[0].Id;
        
        OrderItem odtem = new OrderItem();
        odtem.OrderId = testOrder.Id;
        odtem.PricebookEntryId = pbe1.Id;
        odtem.Fidelidade__c = true;
        odtem.Quantity = 1;
        odtem.vlocity_cmt__LineNumber__c = '0001';
        odtem.UnitPrice = 100;
        odtem.vlocity_cmt__ProvisioningStatus__c = 'New';
        sObjList.add(odtem);
        
        insert sObjList;
    }
    //LB -Método de teste da classe CEC_SendToRobotController
    static testmethod void getObjects(){
        Test.startTest();
        testProductSetup();
        
        String jsonInput = CEC_SendToRobotController.getObjects(UserInfo.getUserId().left(10) + orderId);
        list<robotTest> mapObj = (list<robotTest>)JSON.deserialize(jsonInput, list<robotTest>.class);
		system.debug('mapObj: '+mapObj);
        system.assertEquals(mapObj[0].sIdVenda, orderId);
        system.assertEquals(mapObj[0].sCPF, cpf);

        Test.stopTest();
    }
     static testmethod void newHPTest(){
        Test.startTest();
        testProductSetup();
        Account varAcc = [SELECT Id, DocumentType__c FROM Account LIMIT 1];
        String jsonInput = CEC_SendToRobotController.getObjects(UserInfo.getUserId().left(10) + orderId);
        list<robotTest> mapObj = (list<robotTest>)JSON.deserialize(jsonInput, list<robotTest>.class);
		system.debug('mapObj: '+mapObj);
        system.assertEquals(mapObj[0].sIdVenda, orderId);
        system.assertEquals(mapObj[0].sCPF, cpf);

        Test.stopTest();
    }
}