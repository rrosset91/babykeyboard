@isTest
public class TemplateActionsTest 
{
    static PriceBook2 pb;
    
    @testSetup static void setup() {
        Product2 product = new Product2();
        product.Name = 'name1';
        product.Color__c = 'color1';
        product.Model__c = 'model1';
        product.ProductCode = '00001';
        product.Manufacturer__c = 'manufacturer1';
        product.vlocity_cmt__IsOrderable__c = true;
        product.IsActive = true;
        product.vlocity_cmt__Type__c='Aparelhos';
        product.Family='Movel';
        insert product;

        Product2 product2 = new Product2(vlocity_cmt__Type__c  = 'Franquia', 
                                            Name = 'Franquia001',
                                            ProductCode = 'Franquia001');
        insert product2;

        Product2 product3 = new Product2(Name = 'Simcard Avulso',
                                            ProductCode = 'PME_SimCardAvulso_0001');
        insert product3;

        Product2 product4 = new Product2(Name = 'Simcard Aparelho',
                                            ProductCode = 'PME_SimCardAparelho_0001');
        insert product4;
          
        Product2 product5 = new Product2(Name = 'Device',
                                            ProductCode = '00005');
        insert product5;

        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product3.Id,
            UnitPrice = 10, IsActive = true);
        insert standardPrice;

        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product2.Id,
            UnitPrice = 10, IsActive = true);
        insert standardPrice2;

        PricebookEntry standardPrice3 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product4.Id,
            UnitPrice = 10, IsActive = true);
        insert standardPrice3;

        PricebookEntry standardPrice4 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product.Id,
            UnitPrice = 10, IsActive = true);
        insert standardPrice4;

        PricebookEntry standardPrice5 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product5.Id,
            UnitPrice = 10, IsActive = true);
        insert standardPrice5;
          
        //insert both matrix
        vlocity_cmt__CalculationMatrix__c calcMatrix = new vlocity_cmt__CalculationMatrix__c(Name= 'Device Pricing - PME All');
        vlocity_cmt__CalculationMatrix__c franquiaControl = new vlocity_cmt__CalculationMatrix__c(Name= 'PME Franquias Control');
        list<vlocity_cmt__CalculationMatrix__c> matrix = new list<vlocity_cmt__CalculationMatrix__c>();
        matrix.add(calcMatrix);
        matrix.add(franquiaControl);
        insert matrix; 

        //insert matrix version
        vlocity_cmt__CalculationMatrixVersion__c calcMatrixVersion = new vlocity_cmt__CalculationMatrixVersion__c(vlocity_cmt__CalculationMatrixId__c= calcMatrix.Id, vlocity_cmt__IsEnabled__c = true);
        vlocity_cmt__CalculationMatrixVersion__c franquiaControlVersion = new vlocity_cmt__CalculationMatrixVersion__c(vlocity_cmt__CalculationMatrixId__c= franquiaControl.Id, vlocity_cmt__IsEnabled__c = true);
        list<vlocity_cmt__CalculationMatrixVersion__c> matrixVersion = new list<vlocity_cmt__CalculationMatrixVersion__c>();
        matrixVersion.add(calcMatrixVersion);
        matrixVersion.add(franquiaControlVersion);
        insert matrixVersion;

        //price matrix rows

        String rowInput1 = '{"TradeIn":"No","Plan_Code":"Franquia001","User_Type":"All","Price_Type":"None","Payment_Method":"BasePrice24x","Device_Code":"00001","Plan_Name":"Plano Claro Total Compartilhado"}';
        String rowInput2 = '{"TradeIn":"No","Plan_Code":"00001","User_Type":"All","Price_Type":"100PTS","Payment_Method":"BasePrice","Device_Code":"00001","Plan_Name":"Plano Claro Total Compartilhado"}';
        String rowInput3 = '{"TradeIn":"No","Plan_Code":"00001","User_Type":"All","Price_Type":"100PTS","Payment_Method":"BasePrice24x","Device_Code":"00001","Plan_Name":"Plano Claro Total Compartilhado"}';
        String rowOutput = '{"MRC":48.0,"NRC":0.0,"OTL":0.0}';

        vlocity_cmt__CalculationMatrixRow__c matrixRow1 = new vlocity_cmt__CalculationMatrixRow__c(
                                                            vlocity_cmt__CalculationMatrixVersionId__c = calcMatrixVersion.id,
                                                            vlocity_cmt__InputData__c = rowInput1,
                                                            vlocity_cmt__OutputData__c = rowOutput);
        vlocity_cmt__CalculationMatrixRow__c matrixRow2 = new vlocity_cmt__CalculationMatrixRow__c(
                                                            vlocity_cmt__CalculationMatrixVersionId__c = calcMatrixVersion.id,
                                                            vlocity_cmt__InputData__c = rowInput2,
                                                            vlocity_cmt__OutputData__c = rowOutput);
        vlocity_cmt__CalculationMatrixRow__c matrixRow3 = new vlocity_cmt__CalculationMatrixRow__c(
                                                            vlocity_cmt__CalculationMatrixVersionId__c = calcMatrixVersion.id,
                                                            vlocity_cmt__InputData__c = rowInput3,
                                                            vlocity_cmt__OutputData__c = rowOutput);
        //franquia controll row
        String rowInput4 = '{"Franquia Code":"Franquia001"}';
        String rowOutput2 = '{"300PTS":"true","250PTS":"true","200PTS":"true","140PTS":"true","100PTS":"true"}';

        vlocity_cmt__CalculationMatrixRow__c matrixRow4 = new vlocity_cmt__CalculationMatrixRow__c(
                                                            vlocity_cmt__CalculationMatrixVersionId__c = franquiaControlVersion.id,
                                                            vlocity_cmt__InputData__c = rowInput4,
                                                            vlocity_cmt__OutputData__c = rowOutput2);
        

        list<vlocity_cmt__CalculationMatrixRow__c> matrixVersionRow = new list<vlocity_cmt__CalculationMatrixRow__c>();
        matrixVersionRow.add(matrixRow1);
        matrixVersionRow.add(matrixRow2);
        matrixVersionRow.add(matrixRow3);
        matrixVersionRow.add(matrixRow4);

        insert matrixVersionRow; 
        Account cuenta = new Account(Name = 'Cuenta');
        insert cuenta;

        Order orden = new Order(AccountId = cuenta.Id, Status = 'Em andamento', EffectiveDate = Date.today(), Pricebook2ID = Test.getStandardPricebookId());
        insert orden;

        Opportunity opportunity = new Opportunity(Name = 'Opportunity',AccountId = cuenta.Id, StageName = 'Em andamento', CloseDate = Date.today(), Pricebook2ID = Test.getStandardPricebookId());
        insert opportunity;

        OpportunityLineItem oppLineItem = new OpportunityLineItem(Product2Id = product2.Id, OpportunityId = opportunity.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0001', ReliesOnReferenceId__c = '00kL0000009Td0YIAS');
        insert oppLineItem;

        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(Product2Id = product3.Id, OpportunityId = opportunity.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0002', ReliesOnReferenceId__c = oppLineItem.id);
        insert oppLineItem2;
          
        OpportunityLineItem oppLineItem3 = new OpportunityLineItem(Product2Id = product4.Id, OpportunityId = opportunity.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0003', ReliesOnReferenceId__c = oppLineItem.id);
        insert oppLineItem3;

        OpportunityLineItem oppLineItem4 = new OpportunityLineItem(Product2Id = product5.Id, OpportunityId = opportunity.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0004', ReliesOnReferenceId__c = oppLineItem.id);
        insert oppLineItem4;
          
        OrderItem orderItem = new OrderItem(Product2Id = product2.Id, OrderId = orden.Id, Quantity = 100, vlocity_cmt__LineNumber__c  = '0001', UnitPrice= 10, PricebookEntryId = standardPrice2.Id);
        insert orderItem;

        OrderItem orderItem2 = new OrderItem(Product2Id = product3.Id, OrderId = orden.Id, Quantity = 100, vlocity_cmt__LineNumber__c  = '0002', UnitPrice = 10, PricebookEntryId = standardPrice.Id,  ReliesOnReferenceId__c = orderItem.id);
        insert orderItem2;
        
        OrderItem orderItem3 = new OrderItem(Product2Id = product4.Id, OrderId = orden.Id, Quantity = 100, vlocity_cmt__LineNumber__c  = '0003', UnitPrice = 1, PricebookEntryId = standardPrice.Id,  ReliesOnReferenceId__c = orderItem.id);
        insert orderItem3; 
          
        OrderItem orderItem4 = new OrderItem(Product2Id = product5.Id, OrderId = orden.Id, Quantity = 100, vlocity_cmt__LineNumber__c  = '0004', UnitPrice = 1, PricebookEntryId = standardPrice.Id,  ReliesOnReferenceId__c = orderItem.id);
        insert orderItem4;

    }
    
    private static Opportunity newOpportunityCreation()
    {
        List<Product2> productList = new List<Product2>();
         Product2 prd = new Product2();
         prd.name = 'Name prd - Individual';
         prd.isActive = true;
      
         insert prd;
      
         Product2 prd2 = new Product2();
         prd2.name = 'Name prd2 - Individual';
         prd2.isActive = true;
      
         insert prd2;
         
         productList.add(prd);
         productList.add(prd2);
      
        List<Account> testAccount = createAccount(1);
        insert testAccount;
        
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('OppTemplate').getRecordTypeId();
        system.debug('devRecordTypeId -- '+devRecordTypeId); 
        
        //pb = createPricebook(productList); 
        Id standardPricebookId = Test.getStandardPricebookId();    
 
        Opportunity opp = new Opportunity(AccountId = testAccount[0].id);
        opp.name  =  '80GB_PME_Franquia80GBIndividual_0001_TemplateOpp';
        opp.StageName = 'Qualificação';
        opp.closedate = SYSTEM.TODAY() + 10;
        opp.RecordTypeId = devRecordTypeId;
        opp.Pricebook2Id = standardPricebookId;
        insert opp;
        return opp;
    }
    
    public static List<Account> createAccount(Integer numOfAccounts)
    {
        List<Account> accountList = new List<Account>();

        for (Integer i = 0; i < numOfAccounts; i++)
        {
            Account acctTest = new Account(Name = 'Test Account ' + i,
            
            BillingCountry='USA',
            BillingCity='Forest Hills',
            BillingPostalCode='11375',
            BillingStreet='110-35 72nd Rd',
            BillingState='NY',
            Fax = '1',
            Industry = 'Agriculture'
                );
            accountList.add(acctTest);
        }

        return accountList;
    }
    
    /*public static Pricebook2 createPricebook(List<Product2> products) {
        

        Id standardPricebookId = Test.getStandardPricebookId();

        List<PricebookEntry> entries = new List<PricebookEntry>();

        for (Product2 product : products) {
            entries.add(new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = product.id, UnitPrice = 15.0, isActive = true));
           
        }

        insert entries;
        return pricebook;
    }*/
    
    public static Pricebook2 CreatePriceBook2()
    {
        Pricebook2 pb2 = new Pricebook2();
        pb2.Description = pb2.Name = 'Test Pricebook';
        pb2.IsActive = True;
        insert pb2;
        return pb2;
    }
    
    public static OpportunityLineItem createOppLine(String oppId)
    {
        PricebookEntry entry = new PricebookEntry();
        Id standardPricebookId = Test.getStandardPricebookId();
        
        Product2 prd = new Product2();
         prd.name = 'Name prd - Individual';
         prd.isActive = true;
      
         insert prd;
        
         Pricebook2 pb2 = new Pricebook2();
         
         pb2 = CreatePriceBook2();
    
        entry = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = prd.id, UnitPrice = 15.0, isActive = true);
        insert entry;
        
        OpportunityLineItem oppLi = new OpportunityLineItem();
          oppLi.OpportunityId = oppId;
          oppLi.PricebookEntryId = entry.Id;
          oppLi.Product2Id = prd.Id;
          oppLi.Quantity = 1;
          oppLi.TotalPrice = 1.00;
          oppLi.vlocity_cmt__JSONAttribute__c = '{"ATT_CT_Franquia":[{"attributeRunTimeInfo":{"selectedItem":{"displayText":"VOZ(Bônusde500MB)","id":5,"value":"VOZ"}}}]}';
          oppLi.vlocity_cmt__LineNumber__c = '0001';
          insert oppLi;
          
          return oppLi;
        
    }
    
    @isTest public static void testInvokeMethod()
    {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        
        List<Account> newAccounts = new List<Account>();
        
        Opportunity opp = new Opportunity();
        opp = newOpportunityCreation();
        
        newAccounts = createAccount(1);
        OpportunityLineItem oppline = new OpportunityLineItem();
        
        oppline = createOppLine(opp.Id);
        
        inputMap.put('TemplateId',opp.Id);
        inputMap.put('TemplateName','80GB_PME_Franquia80GBIndividual_0001_TemplateOpp');
        inputMap.put('TemplateObjectType','Opportunity');
        
        inputMap.put('ParentGroup',null);
        inputMap.put('Group',null);
        inputMap.put('Subgroup',null);
        inputMap.put('Quantity',1);
        inputMap.put('Type','Franquia');
        inputMap.put('SubType','Individual');
        inputMap.put('ReliesOnReferenceId__c',null);
        
        List<Object> oppLi = new List<Object>();
        oppLi.add(oppline.Product2Id);
        inputMap.put('includeIds', oppLi);
        
        Test.startTest();
        TemplateActions tempActions = new TemplateActions();
        tempActions.invokeMethod('CloneFromTemplate',inputMap,outMap,options);
        
        inputMap.put('AccountId',newAccounts[0].Id);
        inputMap.put('AccountName',newAccounts[0].Name);
        
        tempActions.invokeMethod('CloneFromTemplate',inputMap,outMap,options);
        
        inputMap.put('ExistingId',opp.Id);
        tempActions.invokeMethod('CloneFromTemplate',inputMap,outMap,options);
        
        inputMap.put('TypeOfRequest__c', 'TT PF/PJ');
        tempActions.invokeMethod('CloneFromTemplate',inputMap,outMap,options);
        Test.stopTest();
        
        TemplateActions.padLeft(4);
        
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity WHERE Name = '80GB_PME_Franquia80GBIndividual_0001_TemplateOpp'];
        
        System.assertEquals(2, lstOpp.size());
    }
    
    @isTest public static void testInvokeMethod2()
    {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        
        List<Account> newAccounts = new List<Account>();
        
        Opportunity opp = new Opportunity();
        opp = newOpportunityCreation();
        
        newAccounts = createAccount(1);
        OpportunityLineItem oppline = new OpportunityLineItem();
        
        oppline = createOppLine(opp.Id);
        
        inputMap.put('TemplateName','80GB_PME_Franquia80GBIndividual_0001_TemplateOpp');
        inputMap.put('TemplateObjectType','Opportunity');
        
        inputMap.put('ParentGroup',null);
        inputMap.put('Group',null);
        inputMap.put('Subgroup',null);
        inputMap.put('Quantity','null');
        inputMap.put('Type','Franquia');
        inputMap.put('SubType','Individual');
        inputMap.put('TypeOfRequest__c','Novo');
        inputMap.put('ReliesOnReferenceId__c',oppline.Id);
        
        List<Object> oppLi = new List<Object>();
        oppLi.add(oppline.Id);
        inputMap.put('includeIds', oppLi);
        
        Test.startTest();
        TemplateActions tempActions = new TemplateActions();
        tempActions.invokeMethod('CloneFromTemplate',inputMap,outMap,options);
        
        inputMap.put('AccountId',newAccounts[0].Id);
        inputMap.put('AccountName',newAccounts[0].Name);
        
        tempActions.invokeMethod('CloneFromTemplate',inputMap,outMap,options);
        
        inputMap.put('ExistingId',opp.Id);
        tempActions.invokeMethod('CloneFromTemplate',inputMap,outMap,options);
        Test.stopTest();
        
        TemplateActions.padLeft(4);
        
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity WHERE Name = '80GB_PME_Franquia80GBIndividual_0001_TemplateOpp'];
        
        System.assertEquals(2, lstOpp.size());
    }
}