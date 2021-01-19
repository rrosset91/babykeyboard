/*
* Autor: Gabriel Russo - Aconcagua
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 10]
Classe de teste responsável por testar a funcionalidade implementada na classe CEC_PME_Devices e suas dependências.
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/

@isTest
private class CEC_PME_DevicesTest {
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
                                            ProductCode = '99999', vlocity_cmt__Type__c='Aparelhos', Family='Movel');
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

       /* PricebookEntry standardPrice6 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(), Product2Id = product3.Id,
            UnitPrice = 10, IsActive = true);
        insert standardPrice6;
        */

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
        // MAMB
        String rowInput5 = '{"TradeIn":"Yes","Plan_Code":"00001","User_Type":"All","Price_Type":"0PTS","Payment_Method":"BasePrice24x","Device_Code":"00001","Plan_Name":"Plano Claro Total Compartilhado"}';
        
        String rowOutput = '{"MRC":48.0,"NRC":0.0,"OTL":0.0}';
        String rowOutput5 = '{"MRC":55.0,"NRC":0.0,"OTL":0.0}';

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
         
         vlocity_cmt__CalculationMatrixRow__c matrixRow31 = new vlocity_cmt__CalculationMatrixRow__c(
                                                            vlocity_cmt__CalculationMatrixVersionId__c = calcMatrixVersion.id,
                                                            vlocity_cmt__InputData__c = rowInput5,
                                                            vlocity_cmt__OutputData__c = rowOutput5);
         


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
        matrixVersionRow.add(matrixRow31);
        matrixVersionRow.add(matrixRow4);

        insert matrixVersionRow; 
        
        Account cuenta = new Account(Name = 'Cuenta');
        insert cuenta;

        Order orden = new Order(AccountId = cuenta.Id, Status = 'Em andamento', EffectiveDate = Date.today(), Pricebook2ID = Test.getStandardPricebookId());
        insert orden;

        Opportunity opportunity = new Opportunity(Name = 'Opportunity',AccountId = cuenta.Id, StageName = 'Em andamento', CloseDate = Date.today(), Pricebook2ID = Test.getStandardPricebookId());
        insert opportunity;

        OpportunityLineItem oppLineItem = new OpportunityLineItem(Product2Id = product2.Id, OpportunityId = opportunity.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0001', TypeOfRequest__c = 'Novo');
        insert oppLineItem;

        OpportunityLineItem oppLineItem2 = new OpportunityLineItem(Product2Id = product3.Id, OpportunityId = opportunity.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0002', TypeOfRequest__c= 'Novo', ReliesOnReferenceId__c = oppLineItem.Id);
        insert oppLineItem2;
          
        OpportunityLineItem oppLineItem3 = new OpportunityLineItem(Product2Id = product4.Id, OpportunityId = opportunity.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0003', TypeOfRequest__c= 'Novo', ReliesOnReferenceId__c = oppLineItem.Id);
        insert oppLineItem3;

        OpportunityLineItem oppLineItem4 = new OpportunityLineItem(Product2Id = product5.Id, OpportunityId = opportunity.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0004', TypeOfRequest__c= 'Novo', ReliesOnReferenceId__c = oppLineItem.Id);
        insert oppLineItem4;

        OpportunityLineItem oppLineItem5 = new OpportunityLineItem(Product2Id = product4.Id, OpportunityId = opportunity.Id, Quantity = 100, TotalPrice = 1000, vlocity_cmt__LineNumber__c  = '0005', TypeOfRequest__c= 'Novo',  ReliesOnReferenceId__c = oppLineItem4.Id, vlocity_cmt__AssetReferenceId__c = oppLineItem4.Id);
        insert oppLineItem5;

        oppLineItem.vlocity_cmt__AssetReferenceId__c = oppLineItem.Id;
        Update oppLineItem;
          
        OrderItem orderItem = new OrderItem(Product2Id = product2.Id, OrderId = orden.Id, Quantity = 100, vlocity_cmt__LineNumber__c  = '0001', UnitPrice= 10, PricebookEntryId = standardPrice2.Id, TypeOfRequest__c= 'TT PF/PJ', SAP_ID__c = '23100', ParentGroup__c = 'BA/SE', Group__c = 'AC', Subgroup__c = '11', vlocity_cmt__OverageTotal__c = 0.00 );
        insert orderItem;

        OrderItem orderItem2 = new OrderItem(Product2Id = product3.Id, OrderId = orden.Id, Quantity = 100, vlocity_cmt__LineNumber__c  = '0002', UnitPrice = 10, PricebookEntryId = standardPrice.Id,  ReliesOnReferenceId__c = orderItem.id, TypeOfRequest__c= 'TT PF/PJ', SAP_ID__c = '23101', ParentGroup__c = 'BA/SE', Group__c = 'AC', Subgroup__c = '11', vlocity_cmt__OverageTotal__c = 0.00 );
        insert orderItem2;
        
        OrderItem orderItem3 = new OrderItem(Product2Id = product4.Id, OrderId = orden.Id, Quantity = 100, vlocity_cmt__LineNumber__c  = '0003', UnitPrice = 1, PricebookEntryId = standardPrice.Id,  ReliesOnReferenceId__c = orderItem.id, TypeOfRequest__c= 'TT PF/PJ', SAP_ID__c = '23102', ParentGroup__c = 'BA/SE', Group__c = 'AC', Subgroup__c = '11', vlocity_cmt__OverageTotal__c = 0.00 );
        insert orderItem3; 
          
        OrderItem orderItem4 = new OrderItem(Product2Id = product5.Id, OrderId = orden.Id, Quantity = 100, vlocity_cmt__LineNumber__c  = '0004', UnitPrice = 1, PricebookEntryId = standardPrice.Id,  ReliesOnReferenceId__c = orderItem.id, TypeOfRequest__c= 'TT PF/PJ', SAP_ID__c = '23103', ParentGroup__c = 'BA/SE', Group__c = 'AC', Subgroup__c = '11', vlocity_cmt__OverageTotal__c = 0.00 , vlocity_cmt__AssetReferenceId__c =  orderItem.id);
        insert orderItem4; 

        OrderItem orderItem5 = new OrderItem(Product2Id = product4.Id, OrderId = orden.Id, Quantity = 100, vlocity_cmt__LineNumber__c  = '0005', UnitPrice = 1, PricebookEntryId = standardPrice.Id,  ReliesOnReferenceId__c = orderItem4.id, TypeOfRequest__c= 'TT PF/PJ' , SAP_ID__c = '23104', ParentGroup__c = 'BA/SE', Group__c = 'AC', Subgroup__c = '11', vlocity_cmt__OverageTotal__c = 0.00 );
        insert orderItem5; 

        orderItem4.vlocity_cmt__AssetReferenceId__c = orderItem.Id;
        Update orderItem4;

        orderItem.ReliesOnReferenceId__c = orderItem.Id;
        update orderItem;

    }


     /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 10] Test of getManufacturedMethod
    */     
     @isTest static void testGetManufactured() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
            
        Set<Map<String,String>> testoptions = new Set<Map<String, String>>();
        Map<String, String> tempMap = new Map<String, String>();
        tempMap.put('name', 'manufacturer1'); 
        tempMap.put('value', 'manufacturer1');

        testoptions.add(tempMap);
        Test.startTest();
        Boolean retorno = caller.invokeMethod('getManufactured',inputMap,outMap,options);
        System.assertEquals(outMap.get('options'), testoptions);
        Test.stopTest();
        
     }

     /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 10] Test of getModel
    */     
     @isTest static void testGetModel() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();

        Map<String, Set<Map<String, String>>> dependency = new Map<String,Set<Map<String, String>>>();
        Set<Map<String, String>> option = new Set<Map<String, String>>();
        Map<String, String> tempMap = new Map<String, String>();
        tempMap.put('name','model1');
        tempMap.put('value','model1');
        option.add(tempMap);
        dependency.put('manufacturer1', option);
                
        Test.startTest();
        Boolean retorno = caller.invokeMethod('getModel',inputMap,outMap,options);
        System.assertEquals(outMap.get('dependency'), dependency);
        Test.stopTest();
        
     }

     /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 10] Test of getColor
    */     
     @isTest static void testGetColor() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        
        Map<String, Set<Map<String, String>>> dependency = new Map<String,Set<Map<String, String>>>();
        Set<Map<String, String>> option = new Set<Map<String, String>>();
        Map<String, String> tempMap = new Map<String, String>();
        tempMap.put('name','color1');
        tempMap.put('value','color1');
        option.add(tempMap);
        dependency.put('model1', option);

        Test.startTest();
        Boolean retorno = caller.invokeMethod('getColor',inputMap,outMap,options);
        System.assertEquals(outMap.get('dependency'), dependency);
        Test.stopTest();
        
     }

     /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 10] Test of getDevices
    */     
     @isTest static void testGetDevices_One() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        inputMap.put('Color', 'color1');
        inputMap.put('Model', 'model1');
        inputMap.put('Brand', 'manufacturer1');

        Test.startTest();
        Boolean retorno = caller.invokeMethod('getDevices',inputMap,outMap,options);
        Map<String,String> device = (Map<String,String>) (((List<Object>)((Map<String,Object>)outMap.get('devices')).get('page1')).get(0));
        System.assertEquals(device.get('productCode'), '00001');
        Test.stopTest();
        
     }

     /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 10] Test of getDevices
    */     
     @isTest static void testGetDevices_Two() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        inputMap.put('Model', 'model1');
        inputMap.put('Brand', 'manufacturer1');
        
        Test.startTest();
        Boolean retorno = caller.invokeMethod('getDevices',inputMap,outMap,options);
        Map<String,String> device = (Map<String,String>) (((List<Object>)((Map<String,Object>)outMap.get('devices')).get('page1')).get(0));
        System.assertEquals(device.get('productCode'), '00001');
        Test.stopTest();
        
     }

     /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 10] Test of getDevices
    */     
     @isTest static void testGetDevices_Three() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        inputMap.put('Brand', 'manufacturer1');
        
        Test.startTest();
        Boolean retorno = caller.invokeMethod('getDevices',inputMap,outMap,options);
        Map<String,String> device = (Map<String,String>) (((List<Object>)((Map<String,Object>)outMap.get('devices')).get('page1')).get(0));
        System.assertEquals(device.get('productCode'), '00001');
        Test.stopTest();
        
     }

     /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 10] Test of getDevices
    */     
     @isTest static void testGetDevices_Four() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        
        Test.startTest();
        Boolean retorno = caller.invokeMethod('getDevices',inputMap,outMap,options);
        Map<String,String> device = (Map<String,String>) (((List<Object>)((Map<String,Object>)outMap.get('devices')).get('page1')).get(0));
        System.assertEquals(device.get('productCode'), '00001');
        Test.stopTest();
        
     }

      /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 10] Test of getDevicePrices
    */     
     @isTest static void testGetDevicesPrices() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        inputMap.put('planName','Plano Claro Total Compartilhado');



        Test.startTest();
        Boolean retorno = caller.invokeMethod('getDevicePrices',inputMap,outMap,options);
        //Map<String,String> device = (Map<String,String>) (((List<Object>)((Map<String,Object>)outMap.get('devices')).get('page1')).get(0));
        System.assertEquals(((Set<String>)outMap.get('activedDevices')).contains('00001'), true); //verifies the device is in the activedDevices list
        //System.assertEquals(outMap.get('devicePrices'), 'null');
        //verifies the devicePrices
        
        // MAMB
        // ===> System.assertEquals(((Map<String,Object>)((Map<String,Object>)((Map<String,Object>)((Map<String,Object>)outMap.get('devicePrices')).get('24Vezes')).get('00001')).get('Faixa')).get('Franquia001') , '48.0'); 
        // MAMB
        System.assertEquals(((Map<String,Object>)((Map<String,Object>)((Map<String,Object>)((Map<String,Object>)((Map<String,Object>)outMap.get('devicePrices')).get('24Vezes')).get('00001')).get('Faixa')).get('WithoutTradeIn')).get('Franquia001') , '48.0'); 

        
        //System.assertEquals(((Map<String,Object>)((Map<String,Object>)((Map<String,Object>)((Map<String,Object>)outMap.get('devicePrices')).get('24Vezes')).get('00001')).get('Pontos')).get('100PTS') , '48.0'); 
        //System.assertEquals(((Map<String,Object>)((Map<String,Object>)outMap.get('devicePrices')).get('Vista')).get('00001') , '48.0'); 
        //checking franquia availability
        System.assertEquals(((List<String>)((Map<String,Object>)outMap.get('franquiaAvailability')).get('100PTS')).get(0), 'Franquia001');
        System.assertEquals(((List<String>)((Map<String,Object>)outMap.get('franquiaAvailability')).get('140PTS')).get(0), 'Franquia001');
        System.assertEquals(((List<String>)((Map<String,Object>)outMap.get('franquiaAvailability')).get('200PTS')).get(0), 'Franquia001');
        System.assertEquals(((List<String>)((Map<String,Object>)outMap.get('franquiaAvailability')).get('250PTS')).get(0), 'Franquia001');
        System.assertEquals(((List<String>)((Map<String,Object>)outMap.get('franquiaAvailability')).get('300PTS')).get(0), 'Franquia001');

        Test.stopTest();
        
     }

       /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11] Test of addDeviceToCart
    */    /* 
     @isTest static void testAddDeviceToCart_Ord() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        Map<String,Object> device  = new Map<String,Object>();

        inputMap.put('pagamento','24Vezes');
        inputMap.put('cartId','0062C000004lU2UQAU');

        device.put('productCode','17070');
        device.put('productId','01t2C000001WFuIQAW');
        device.put('discountType','Pontos');
        device.put('group','140PTS');
        device.put('franquia','00k2C000003yOg4QAE');
        device.put('qtty',1);

        inputMap.put('device',device);
        
        Test.startTest();
        Boolean retorno = caller.invokeMethod('addDeviceToCart',inputMap,outMap,options);
        Test.stopTest();


        
     }*/

    /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11] Test of addDeviceToCart
    */     
     @isTest static void testAddDeviceToCart_Opp1() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        Map<String,Object> deviceMap  = new Map<String,Object>();

        Opportunity cart = [SELECT id FROM Opportunity limit 1];
        Product2 device = [SELECT id,ProductCode  FROM Product2 WHERE vlocity_cmt__Type__c = 'Aparelhos' AND Family = 'Movel' limit 1];
        OpportunityLineItem franquia = [SELECT id  FROM OpportunityLineItem WHERE vlocity_cmt__LineNumber__c = '0001' LIMIT 1];

        inputMap.put('pagamento','24Vezes');
        inputMap.put('cartId',cart.Id);
        deviceMap.put('tradeIn','WithoutTradeIn');

        deviceMap.put('productCode',device.ProductCode);
        deviceMap.put('productId',device.Id);

        deviceMap.put('discountType','Pontos');
        deviceMap.put('group','100PTS');
        deviceMap.put('franquia',franquia.id);
        deviceMap.put('qtty',1);

        inputMap.put('device',deviceMap);
        
        Test.startTest();
        Boolean retorno = caller.invokeMethod('addDeviceToCart',inputMap,outMap,options);
        //System.assertEquals(outMap,null);
        Test.stopTest();

        OpportunityLineItem oppLineItem = [SELECT  Quantity, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__RecurringTotal__c FROM OpportunityLineItem where vlocity_cmt__LineNumber__c like '0003' limit 1];

        System.assertEquals(oppLineItem.Quantity, 100);   
        /*System.assertEquals(oppLineItem.vlocity_cmt__EffectiveQuantity__c, 1.00);
        System.assertEquals(oppLineItem.vlocity_cmt__RecurringCalculatedPrice__c,48.00);
        System.assertEquals(oppLineItem.vlocity_cmt__RecurringCharge__c,48.00);
        System.assertEquals(oppLineItem.vlocity_cmt__EffectiveRecurringTotal__c, 48.00);
        System.assertEquals(oppLineItem.vlocity_cmt__RecurringTotal__c,48.00);*/
        
     }

    /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11] Test of addDeviceToCart no simcard remaining
    */     
     @isTest static void testAddDeviceToCart_Opp2() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        Map<String,Object> deviceMap  = new Map<String,Object>();

        Opportunity cart = [SELECT id FROM Opportunity limit 1];
        Product2 device = [SELECT id,ProductCode  FROM Product2 WHERE vlocity_cmt__Type__c = 'Aparelhos' AND Family = 'Movel' limit 1];
        OpportunityLineItem franquia = [SELECT id  FROM OpportunityLineItem WHERE vlocity_cmt__LineNumber__c = '0001' LIMIT 1];

        inputMap.put('pagamento','24Vezes');
        inputMap.put('cartId',cart.Id);
        inputMap.put('planName','Plano Claro Total Compartilhado');

        deviceMap.put('productCode',device.ProductCode);
        deviceMap.put('productId',device.Id);

        deviceMap.put('discountType','Pontos');
        deviceMap.put('group','100PTS');
        deviceMap.put('franquia',franquia.id);
        deviceMap.put('qtty',100);

        inputMap.put('device',deviceMap);
        
        Test.startTest();
        Boolean retorno = caller.invokeMethod('addDeviceToCart',inputMap,outMap,options);
        //System.assertEquals(outMap,null);
        Test.stopTest();

        OpportunityLineItem oppLineItem = [SELECT  Quantity, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__RecurringTotal__c FROM OpportunityLineItem where vlocity_cmt__LineNumber__c like '0003' limit 1];

        /*System.assertEquals(oppLineItem.Quantity, 100.00);   
        System.assertEquals(oppLineItem.vlocity_cmt__EffectiveQuantity__c, 100.00);
        System.assertEquals(oppLineItem.vlocity_cmt__RecurringCalculatedPrice__c,48.00);
        System.assertEquals(oppLineItem.vlocity_cmt__RecurringCharge__c,48.00);
        System.assertEquals(oppLineItem.vlocity_cmt__EffectiveRecurringTotal__c, 48.00*100.00);
        System.assertEquals(oppLineItem.vlocity_cmt__RecurringTotal__c,48.00*100.00);*/
        
     }

     /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11] Test of addDeviceToCart no simcard remaining
    */     
     @isTest static void testAddDeviceToCart_Opp3() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        Map<String,Object> deviceMap  = new Map<String,Object>();

        Opportunity cart = [SELECT id FROM Opportunity limit 1];
        Product2 device = [SELECT id,ProductCode  FROM Product2 WHERE vlocity_cmt__Type__c = 'Aparelhos' AND Family = 'Movel' limit 1];
        OpportunityLineItem franquia = [SELECT id  FROM OpportunityLineItem WHERE vlocity_cmt__LineNumber__c = '0001' LIMIT 1];

        inputMap.put('pagamento','Vista');
        inputMap.put('cartId',cart.Id);
        inputMap.put('planName','Plano Claro Total Compartilhado');

        deviceMap.put('productCode',device.ProductCode);
        deviceMap.put('productId',device.Id);

        deviceMap.put('discountType','Pontos');
        deviceMap.put('group','100PTS');
        deviceMap.put('franquia',franquia.id);
        deviceMap.put('qtty',100);

        inputMap.put('device',deviceMap);
        
        Test.startTest();
        Boolean retorno = caller.invokeMethod('addDeviceToCart',inputMap,outMap,options);
        //System.assertEquals(outMap,null);
        Test.stopTest();

        OpportunityLineItem oppLineItem = [SELECT  Quantity, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__RecurringTotal__c FROM OpportunityLineItem where vlocity_cmt__LineNumber__c like '0003' limit 1];

        System.assertEquals(oppLineItem.Quantity, 100.00);   
        /*System.assertEquals(oppLineItem.vlocity_cmt__EffectiveQuantity__c, 100.00);
        System.assertEquals(oppLineItem.vlocity_cmt__RecurringCalculatedPrice__c,48.00);
        System.assertEquals(oppLineItem.vlocity_cmt__RecurringCharge__c,48.00);
        System.assertEquals(oppLineItem.vlocity_cmt__EffectiveRecurringTotal__c, 48.00*100.00);
        System.assertEquals(oppLineItem.vlocity_cmt__RecurringTotal__c,48.00*100.00);*/
        
     }

     /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11] Test of addDeviceToCart no simcard remaining
    */     
     @isTest static void testAddDeviceToCart_Ord1() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        Map<String,Object> deviceMap  = new Map<String,Object>();

        Order cart = [SELECT id FROM Order limit 1];
        Product2 device = [SELECT id, ProductCode  FROM Product2 WHERE vlocity_cmt__Type__c = 'Aparelhos' AND Family = 'Movel' limit 1];
        OrderItem franquia = [SELECT id  FROM OrderItem WHERE vlocity_cmt__LineNumber__c = '0001' LIMIT 1];

        inputMap.put('pagamento','24Vezes');
        inputMap.put('cartId',cart.Id);
        inputMap.put('planName','Plano Claro Total Compartilhado');

        deviceMap.put('productCode',device.ProductCode);
        deviceMap.put('productId',device.Id);

        deviceMap.put('discountType','Faixa');
        deviceMap.put('group','Franquia001');
        deviceMap.put('franquia',franquia.id);
        deviceMap.put('qtty',100);

        inputMap.put('device',deviceMap);
        
        Test.startTest();
        Boolean retorno = caller.invokeMethod('addDeviceToCart',inputMap,outMap,options);
        //System.assertEquals(outMap,null);
        Test.stopTest();

        OrderItem orderItem = [SELECT  Quantity, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__RecurringTotal__c FROM OrderItem where vlocity_cmt__LineNumber__c like '0003' limit 1];

        System.assertEquals(orderItem.Quantity, 100.00);   
        /*System.assertEquals(orderItem.vlocity_cmt__EffectiveQuantity__c, 100.00);
        System.assertEquals(orderItem.vlocity_cmt__RecurringCalculatedPrice__c,48.00);
        System.assertEquals(orderItem.vlocity_cmt__RecurringCharge__c,48.00);
        System.assertEquals(orderItem.vlocity_cmt__EffectiveRecurringTotal__c, 100.00*48.00);
        System.assertEquals(orderItem.vlocity_cmt__RecurringTotal__c,100.00*48.00);*/
        
     }

      /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11] Test of addDeviceToCart no simcard remaining
    */     
     @isTest static void testDeleteDeviceFromCart_Ord1() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        Map<String,Object> deviceMap  = new Map<String,Object>();

        Order cart = [SELECT id FROM Order limit 1];
        Product2 device = [SELECT id,ProductCode  FROM Product2 WHERE ProductCode = '00001' limit 1];
        OrderItem franquia = [SELECT id  FROM OrderItem WHERE vlocity_cmt__LineNumber__c = '0001' LIMIT 1];

        inputMap.put('pagamento','24Vezes');
        inputMap.put('cartId',cart.Id);

        deviceMap.put('productCode',device.ProductCode);
        deviceMap.put('productId',device.Id);

        deviceMap.put('discountType','Faixa');
        deviceMap.put('group','Fran');
        deviceMap.put('franquia',franquia.id);
        deviceMap.put('qtty',100);

        inputMap.put('device',deviceMap);
        caller.invokeMethod('addDeviceToCart',inputMap,outMap,options);
        
        
        OrderItem deviceItem = [SELECT  Id,Quantity, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__RecurringTotal__c FROM OrderItem where vlocity_cmt__LineNumber__c like '0004' limit 1];

        //OrderItem deviceItem = [SELECT Id from OrderItem where Product2Id = :device.id limit 1];
        inputMap = new Map<String,Object>();
        outMap  = new Map<String,Object>();
        inputMap.put('deviceId',deviceItem.id);

        Test.startTest();
        Boolean retorno = caller.invokeMethod('removeDeviceFromCart',inputMap,outMap,options);
        //System.assertEquals(outMap,null);
        Test.stopTest();

        List<OrderItem> deviceItems = [SELECT Id from OrderItem where Id = :deviceItem.id OR ReliesOnReferenceId__c =  :deviceItem.id];
        //System.assertEquals(deviceItems.size(),0);
        OrderItem simCard = [SELECT Id, Quantity from OrderItem where ReliesOnReferenceId__c =  :franquia.id limit 1];
        //System.assertEquals(simCard.Quantity,100.00);
        
     }

       /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11] Test of addDeviceToCart no simcard remaining
    */     
     @isTest static void testDeleteDeviceFromCart_Ord2() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        Map<String,Object> deviceMap  = new Map<String,Object>();

        Order cart = [SELECT id FROM Order limit 1];
        Product2 device = [SELECT id,ProductCode  FROM Product2 WHERE vlocity_cmt__Type__c = 'Aparelhos' AND Family = 'Movel' limit 1];
        OrderItem franquia = [SELECT id  FROM OrderItem WHERE vlocity_cmt__LineNumber__c = '0001' LIMIT 1];

        inputMap.put('pagamento','24Vezes');
        inputMap.put('cartId',cart.Id);

        deviceMap.put('productCode',device.ProductCode);
        deviceMap.put('productId',device.Id);

        deviceMap.put('discountType','Faixa');
        deviceMap.put('group','Franquia001');
        deviceMap.put('franquia',franquia.id);
        deviceMap.put('qtty',1);

        inputMap.put('device',deviceMap);
        caller.invokeMethod('addDeviceToCart',inputMap,outMap,options);
        
        OrderItem deviceItem = [SELECT  Id,Quantity, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__RecurringTotal__c FROM OrderItem where vlocity_cmt__LineNumber__c like '0004' limit 1];

        //OrderItem deviceItem = [SELECT Id from OrderItem where Product2Id = :device.id limit 1];
        inputMap = new Map<String,Object>();
        outMap  = new Map<String,Object>();
        inputMap.put('deviceId',deviceItem.id);

        Test.startTest();
        Boolean retorno = caller.invokeMethod('removeDeviceFromCart',inputMap,outMap,options);
        //System.assertEquals(outMap,null);
        Test.stopTest();

        List<OrderItem> deviceItems = [SELECT Id from OrderItem where Id = :deviceItem.id OR ReliesOnReferenceId__c =  :deviceItem.id];
        //System.assertEquals(deviceItems.size(),0);
        OrderItem simCard = [SELECT Id, Quantity from OrderItem where ReliesOnReferenceId__c =  :franquia.id limit 1];
        //System.assertEquals(simCard.Quantity,100.00);
        
     }

      /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11] Test of addDeviceToCart no simcard remaining
    */     
    @isTest static void testDeleteDeviceFromCart_Opp1() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        Map<String,Object> deviceMap  = new Map<String,Object>();

        Opportunity cart = [SELECT id FROM Opportunity limit 1];
        Product2 device = [SELECT id,ProductCode  FROM Product2 WHERE vlocity_cmt__Type__c = 'Aparelhos' AND Family = 'Movel' limit 1];
        OpportunityLineItem franquia = [SELECT id  FROM OpportunityLineItem WHERE vlocity_cmt__LineNumber__c = '0001' LIMIT 1];

        inputMap.put('pagamento','Vista');
        inputMap.put('cartId',cart.Id);

        deviceMap.put('productCode',device.ProductCode);
        deviceMap.put('productId',device.Id);

        deviceMap.put('discountType','Pontos');
        deviceMap.put('group','100PTS');
        deviceMap.put('franquia',franquia.id);
        deviceMap.put('qtty',1);



        inputMap.put('device',deviceMap);
        caller.invokeMethod('addDeviceToCart',inputMap,outMap,options);

        OpportunityLineItem deviceItem = [SELECT Id from OpportunityLineItem where vlocity_cmt__LineNumber__c like '0004' limit 1];
        inputMap = new Map<String,Object>();
        outMap  = new Map<String,Object>();
        inputMap.put('deviceId',deviceItem.id);

        Test.startTest();
        Boolean retorno = caller.invokeMethod('removeDeviceFromCart',inputMap,outMap,options);
        
        //System.assertEquals(outMap,null);
        Test.stopTest();

        List<OpportunityLineItem> deviceItems = [SELECT Id from OpportunityLineItem where Id = :deviceItem.id OR ReliesOnReferenceId__c =  :deviceItem.id];
        //System.assertEquals(deviceItems.size(),0);
        OpportunityLineItem simCard = [SELECT Id, ProductCode, Quantity from OpportunityLineItem where ReliesOnReferenceId__c =  :franquia.id AND productCode = 'PME_SimCardAvulso_0001' limit 1];
        //System.assertEquals(simCard.Quantity,100.00);
        
     }

       /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11] Test of addDeviceToCart no simcard remaining
    */     
    @isTest static void testDeleteDeviceFromCart_Opp2() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        Map<String,Object> deviceMap  = new Map<String,Object>();

        Opportunity cart = [SELECT id FROM Opportunity limit 1];
        Product2 device = [SELECT id,ProductCode  FROM Product2 WHERE vlocity_cmt__Type__c = 'Aparelhos' AND Family = 'Movel' limit 1];
        OpportunityLineItem franquia = [SELECT id  FROM OpportunityLineItem WHERE vlocity_cmt__LineNumber__c = '0001' LIMIT 1];

        inputMap.put('pagamento','Vista');
        inputMap.put('cartId',cart.Id);

        deviceMap.put('productCode',device.ProductCode);
        deviceMap.put('productId',device.Id);

        deviceMap.put('discountType','Pontos');
        deviceMap.put('group','100PTS');
        deviceMap.put('franquia',franquia.id);
        deviceMap.put('qtty',100);



        inputMap.put('device',deviceMap);
        caller.invokeMethod('addDeviceToCart',inputMap,outMap,options);
        
        OrderItem deviceItem = [SELECT  Id,Quantity, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__RecurringTotal__c FROM OrderItem where vlocity_cmt__LineNumber__c like '0004' limit 1];

        //OpportunityLineItem deviceItem = [SELECT Id from OpportunityLineItem where Product2Id = :device.id limit 1];
        inputMap = new Map<String,Object>();
        outMap  = new Map<String,Object>();
        inputMap.put('deviceId',deviceItem.id);

        Test.startTest();
        Boolean retorno = caller.invokeMethod('removeDeviceFromCart',inputMap,outMap,options);
        Test.stopTest();

        List<OpportunityLineItem> deviceItems = [SELECT Id from OpportunityLineItem where Id = :deviceItem.id OR ReliesOnReferenceId__c =  :deviceItem.id];
        //System.assertEquals(deviceItems.size(),0);
        //OpportunityLineItem simCard = [SELECT Id, ProductCode, Quantity from OpportunityLineItem where ReliesOnReferenceId__c =  :franquia.id AND productCode = 'PME_SimCardAvulso_0001' limit 1];
        //System.assertEquals(simCard.Quantity,100.00);
     }

       /*
    * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11] Test of invalid method call
    */     
    @isTest static void testInvalidMethod() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        Map<String,Object> deviceMap  = new Map<String,Object>();

        

        Test.startTest();
        Boolean retorno = caller.invokeMethod('invalidMethod',inputMap,outMap,options);
        
        System.assertEquals(retorno,false);
        Test.stopTest();
        
     }
     /*
     * Autor: Gabriel Russo
    * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11] Test of invalid method call
    */     
    @isTest static void testExceptionHandler() {
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap  = new Map<String,Object>();
        Map<String,Object> options  = new Map<String,Object>();
        Map<String,Object> deviceMap  = new Map<String,Object>();

        Test.startTest();
        Boolean retorno = caller.invokeMethod(null,inputMap,outMap,options);
        
        System.assertEquals(retorno,false);
        Test.stopTest();
        
     }

     //{franquiaAvailability={100PTS=(Franquia001), 140PTS=(Franquia001), 200PTS=(Franquia001), 250PTS=(Franquia001), 300PTS=(Franquia001)}, franquiaGroups={Franquia001=Franquia1}}
   @isTest static void testGetLineNumber(){
      CEC_PME_Devices caller = new CEC_PME_Devices(); 
      Integer intLineNumber = 12;
      String strPrefix = '';
       
      Test.startTest();
      strPrefix = caller.getLineNumber(intLineNumber); 
      System.assertEquals(strPrefix,'0012');
      Test.stopTest();
   }

    // Date: Dec 3, 2019
    // Modified by: Miguel A. Muñoz B. (LabsXD)
    @isTest static void testSetItemPrices(){
        CEC_PME_Devices caller = new CEC_PME_Devices(); 
        OpportunityLineItem oppLineItem = [SELECT  Quantity, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__RecurringTotal__c FROM OpportunityLineItem where vlocity_cmt__LineNumber__c like '0003' limit 1];
        caller.setItemPrices(oppLineItem, 5.00, 15, 2);

    }

   @isTest static void testCheckDeviceCount2(){
      CEC_PME_Devices caller = new CEC_PME_Devices();
      Map<String,Object> inputMap = new Map<String,Object>();
      Map<String,Object> outMap  = new Map<String,Object>();
      Map<String,Object> options  = new Map<String,Object>();
      Map<String,Object> deviceMap  = new Map<String,Object>();

      Product2 device = [SELECT id,ProductCode  FROM Product2 WHERE vlocity_cmt__Type__c = 'Aparelhos' AND Family = 'Movel' limit 1];
      OpportunityLineItem franquia = [SELECT id  FROM OpportunityLineItem WHERE vlocity_cmt__LineNumber__c = '0001' LIMIT 1];

      //inputMap.put('cartId',cart.Id);

      deviceMap.put('productCode',device.ProductCode);
      deviceMap.put('productId',device.Id);

      deviceMap.put('discountType','Pontos');
      deviceMap.put('group','100PTS');
      deviceMap.put('franquia',franquia.id);
      deviceMap.put('qtty',10);

      inputMap.put('pagamento','Vista');
      inputMap.put('device',deviceMap);
      inputMap.put('deviceCount',1);
      inputMap.put('linesQuantity',5);

      caller.checkDeviceCount(inputMap, outMap, options);

   }

   @isTest static void testgetDeliveryOptions(){
      CEC_PME_Devices caller = new CEC_PME_Devices(); 
      Map<String,Object> inputMap = new Map<String,Object>();
      Map<String,Object> outMap  = new Map<String,Object>();
      Map<String,Object> options  = new Map<String,Object>();

      Test.startTest();
         Boolean retorno = caller.invokeMethod('getDeliveryOptions',inputMap,outMap,options);
         //System.assertEquals(outMap,null);
      Test.stopTest();

   }

}