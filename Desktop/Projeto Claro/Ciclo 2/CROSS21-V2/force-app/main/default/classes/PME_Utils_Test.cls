@isTest
public with sharing class PME_Utils_Test {
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
                                            Name = 'Franquia1',
                                            ProductCode = 'Franquia001');
        insert product2;

        Product2 product3 = new Product2(Name = 'Simcard Avulso',
                                            ProductCode = 'PME_SimCardAvulso_0001');
        insert product3;

        Product2 product4 = new Product2(Name = 'Simcard Avulso',
                                            ProductCode = 'PME_SimCardAparelho_0001');
        insert product4;

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

        OrderItem orderItem = new OrderItem(Product2Id = product2.Id, OrderId = orden.Id, Quantity = 4, vlocity_cmt__LineNumber__c  = '0001', UnitPrice= 10, PricebookEntryId = standardPrice2.Id, vlocity_cmt__RecurringCalculatedPrice__c = 10);
        insert orderItem;

        OrderItem orderItem2 = new OrderItem(Product2Id = product3.Id, OrderId = orden.Id, Quantity = 4, vlocity_cmt__LineNumber__c  = '0002', UnitPrice = 10, PricebookEntryId = standardPrice.Id,  ReliesOnReferenceId__c = orderItem.id, vlocity_cmt__RecurringCalculatedPrice__c = 10);
        insert orderItem2;


    }

    @isTest
    public static void TransformArrayToDRInput_Test_String(){
        String methodName = 'TransformArrayToDRInput';

        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        String myString = '1234567';

        options.put('CPF', myString);
        options.put('ArrayName', 'CPF');
        
        
        Test.startTest();
        PME_Utils vlClass = new PME_Utils();
        vlClass.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest(); 

    }
    
    @isTest
    public static void TransformArrayToDRInput_Test_Array(){
        String methodName = 'TransformArrayToDRInput';

        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        List<Object> myList = new List<Object>();
        myList.add('121');
        myList.add('131');

        options.put('CPF', myList);
        options.put('ArrayName', 'CPF');
        
        Test.startTest();
        PME_Utils vlClass = new PME_Utils();
        vlClass.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest(); 

    }

    @isTest
    public static void TransformArrayToDRInput_Test_Error(){
        String methodName = 'TransformArrayToDRInput';

        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        List<Object> myList = new List<Object>();

        options.put('CPF', myList);
        options.put('ArrayName', myList);
        
        Test.startTest();
        PME_Utils vlClass = new PME_Utils();
        try{
            vlClass.invokeMethod(methodName, inputMap, outMap, options);
        }
        catch (Exception e) {
        }
        Test.stopTest(); 

    }

    @isTest
    public static void AppendStringToNode_Test(){
        String methodName = 'AppendStringToNode';

        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Map<String, Object> auxMap = new Map<String, Object>();
        auxMap.put('Node', 'Value');


        options.put('NodeName', 'Contact');
        options.put('StrToAppend', '_1');
        inputMap.put('Contact', auxMap);
        
        Test.startTest();
        PME_Utils vlClass = new PME_Utils();
        vlClass.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest(); 

        Map<String, Object> auxMap2= (Map<String, Object>) outMap.get('Contact_1');
        String auxString = (String) auxMap2.get('Node_1');

        System.Assert(auxString == 'Value');

    }

    @isTest
    public static void SubtractStringToNode_Test(){
        String methodName = 'SubtractStringToNode';

        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Map<String, Object> auxMap = new Map<String, Object>();
        auxMap.put('Node_1', 'Value');


        options.put('NodeName', 'Contact');
        options.put('appendStr', '_1');
        inputMap.put('Contact_1', auxMap);
        
        Test.startTest();
        PME_Utils vlClass = new PME_Utils();
        vlClass.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest(); 

        Map<String, Object> auxMap2= (Map<String, Object>) outMap.get('Contact');
        String auxString = (String) auxMap2.get('Node');

        System.Assert(auxString == 'Value');

    }

    @isTest
    public static void generateGUID_Test(){
        String methodName = 'generateGUID';

        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        Test.startTest();
        PME_Utils vlClass = new PME_Utils();
        vlClass.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest(); 

        String auxString= (String) outMap.get('GUID');

        System.Assert(auxString.length() == 36);

    }
    
    @isTest
    public static void generateGUIDs_Test(){
        String methodName = 'generateGUIDs';

        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        options.put('qtty', 4);
        
        Test.startTest();
        PME_Utils vlClass = new PME_Utils();
        vlClass.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest(); 

        List<Object> auxArray= (List<Object>) outMap.get('GUIDs');

        System.Assert(auxArray.size() == 4);

    }

    @isTest
    public static void getSObjectType_Test(){
        String methodName = 'getSObjectType';
        PME_Utils vlClass = new PME_Utils();

        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Account cuenta = new Account(Name = 'Cuenta');
        insert cuenta;

        Order orden = new Order(AccountId = cuenta.Id, Status = 'Em andamento', EffectiveDate = Date.today(), Pricebook2ID = Test.getStandardPricebookId());
        insert orden;        

        inputMap.put('sObjectId',orden.Id);

        Test.startTest();
        vlClass.invokeMethod(methodName, inputMap, outMap, options);
        Test.stopTest();

        System.assertEquals(outMap.get('sObjectName'),'Order');

    }

    @isTest
    public static void decomposeOrder(){
        /*
            * Autor: Gabriel Russo
            * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11] Test of decompose order no simcard remaining
            */     
        CEC_PME_Devices deviceCaller = new CEC_PME_Devices(); 
        PME_Utils caller = new PME_Utils(); 
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
        deviceMap.put('qtty',2);

        inputMap.put('device',deviceMap);
        deviceCaller.invokeMethod('addDeviceToCart',inputMap,outMap,options);
        
        inputMap = new Map<String,Object>();
        outMap = new Map<String,Object>();
        options = new Map<String,Object>();

        inputMap.put('ContextCartId', cart.Id);
        Test.startTest();
        Boolean retorno = caller.invokeMethod('decomposeOrder',inputMap,outMap,options);
        //System.assertEquals(outMap,null);
        Test.stopTest();

        List<OrderItem> orderItem = [SELECT  Quantity, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__RecurringTotal__c FROM OrderItem];

        //System.assertEquals(orderItem, null);   
        
     
    }

}