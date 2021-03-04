/*
* Autor: Gabriel Russo - Aconcagua
* Data: 01/04/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 9]
Class responsable for the Device screen logic, picklists, pricing, etc.
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/

global with sharing class CEC_PME_Devices implements vlocity_cmt.VlocityOpenInterface{
  private static String SIMCARD_AVULSO = 'PME_SimCardAvulso_0001';
  private static String SIMCARD_APARELHO = 'PME_SimCardAparelho_0001';
  private static String APARELHOS_TYPE = 'Aparelhos';
  private static String MOVEL_FAMILY = 'Movel';
  private static Map<String, Decimal> loyalty = new Map<String, Decimal>{ '0PTS'=> 0.00, 
                                      '100PTS' => 10000.00, 
                                      '140PTS' => 14000.00, 
                                      '200PTS' => 20000.00, 
                                      '250PTS' => 25000.00, 
                                      '300PTS' => 30000.00};
  private static Set<String> toppmeProfiles = new Set<String>{'TOP PME'};

    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
    Boolean result = true;

       try{
        if(methodName.equals('getManufactured')){
          getManufactured(inputMap, outMap, options);
        } else if(methodName.equals('getModel')){
          getModel(inputMap, outMap, options);
        } else if(methodName.equals('getColor')){
          getColor(inputMap, outMap, options);
        } else if(methodName.equals('getDevices')){
          getDevices(inputMap, outMap, options);
        } else if(methodName.equals('getDevicePrices')){
          getDevicePrices(inputMap, outMap, options);
        }else if(methodName.equals('addDeviceToCart')){
          addDeviceToCart(inputMap, outMap, options);
        }else if(methodName.equals('removeDeviceFromCart')){
          removeDeviceFromCart(inputMap, outMap, options);
        }if(methodName.equals('getDeliveryOptions')){
          getDeliveryOptions(inputMap, outMap, options);
        }if(methodName.equals('checkDeviceCount')){
          checkDeviceCount(inputMap, outMap, options);
        }else {
          result = false;
          }
    } catch(Exception e){  
      System.debug('Exception type caught: ' + e.getTypeName());   
        System.debug('Message: ' + e.getMessage());   
        System.debug('Cause: ' + e.getCause());
        System.debug('Line number: ' + e.getLineNumber());   
        System.debug('Stack trace: ' + e.getStackTraceString());
        outMap.put('Error', e.getMessage());
           result = false;  

      }  
      return result;  

   }

   /*
  * Autor: Gabriel Russo
  * Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 10] + get all the manufacturers of the active devices that contains models, and color diferent than null.
  */  
  public void getManufactured(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){
    Set<Map<String,String>> testoptions = new Set<Map<String, String>>();
    Set<String> ret2 = new Set<String>();
    //for(Product2 prd : [SELECT Manufacturer__c FROM Product2 WHERE Family=:MOVEL_FAMILY AND vlocity_cmt__Type__c=:APARELHOS_TYPE AND Manufacturer__c !=null ])
    //<DA> 14/2/19 added IsActive
    for(Product2 prd : [SELECT Manufacturer__c FROM Product2 WHERE Family=:MOVEL_FAMILY AND vlocity_cmt__Type__c=:APARELHOS_TYPE AND Manufacturer__c !=null AND Model__c != null AND Color__c != null AND IsActive = true AND IsDeleted = false AND vlocity_cmt__IsOrderable__c = true order by Manufacturer__c,Model__c ])
    { 
      //if(!ret2.contains(prd.Manufacturer__c) && String.isNotBlank(prd.Manufacturer__c)){
        Map<String, String> tempMap = new Map<String, String>();
            ret2.add(prd.Manufacturer__c);

        tempMap.put('name', prd.Manufacturer__c); // Manufacturer json name
        //<DA> 14/2/19:: Changed TypeAhead4 by value
        tempMap.put('value', prd.Manufacturer__c); // Manufacturer json value

        testoptions.add(tempMap);
      //}
    }
    outMap.put('options',testoptions);
  }


/*
* Autor: Gabriel Russo
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 10] + Get the Models of the device depending on the manufacturer.
*/  
  public void getModel(Map<String, Object> input,Map<String, Object> outMap, Map<String, Object> options){

  // Map of List where the Key is the Potential Values in the Other Picklist
      Map<String, Set<Map<String, String>>> dependency = new Map<String,Set<Map<String, String>>>();

      for (Product2 rel : [SELECT Model__c,Manufacturer__c FROM Product2 WHERE Family=:MOVEL_FAMILY AND vlocity_cmt__Type__c=:APARELHOS_TYPE AND Manufacturer__c !=null AND Model__c != null AND Color__c != null AND IsActive = true AND IsDeleted = false AND vlocity_cmt__IsOrderable__c = true order by Model__c]){
          if (!dependency.containsKey(rel.Manufacturer__c)){
              dependency.put(rel.Manufacturer__c, new Set<Map<String, String>>());

          }
          Map<String, String> tempMap = new Map<String, String>();

          tempMap.put('name', rel.Model__c); // Language Independent
          tempMap.put('value', rel.Model__c);

          // Displayed in Picklist UI
          dependency.get(rel.Manufacturer__c).add(tempMap);
      }
      outMap.put('dependency', dependency);
  }

  /*
* Autor: Gabriel Russo
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 10] + get Color list depending on the Device Model.
*/  
  public void getColor(Map<String, Object> input,Map<String, Object> outMap, Map<String, Object> options){

  // Map of List where the Key is the Potential Values in the Other Picklist
      Map<String, Set<Map<String, String>>> dependency = new Map<String,Set<Map<String, String>>>();

      for (Product2 rel : [SELECT Color__c,Model__c FROM Product2 WHERE Family=:MOVEL_FAMILY AND vlocity_cmt__Type__c=:APARELHOS_TYPE AND Manufacturer__c !=null AND Model__c != null AND Color__c != null AND IsActive = true AND IsDeleted = false AND vlocity_cmt__IsOrderable__c = true order by Model__c]){
          if (!dependency.containsKey(rel.Model__c)){
              dependency.put(rel.Model__c, new Set<Map<String, String>>());

          }
          Map<String, String> tempMap = new Map<String, String>();

          tempMap.put('name', rel.Color__c); // Language Independent
          tempMap.put('value', rel.Color__c);

          // Displayed in Picklist UI
          dependency.get(rel.Model__c).add(tempMap);
      }
      outMap.put('dependency', dependency);
  }

  /*
* Autor: Gabriel Russo
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 10] + get Color list depending on the Device Model.
*/  
  public void getDevices(Map<String, Object> input,Map<String, Object> outMap, Map<String, Object> options){

    String color = (String)input.get('Color');
    String brand = (String)input.get('Brand');
    String model = (String)input.get('Model');
    //String standardPricebook = (String)input.get('pricebook');
    String standardPricebook = 'Standard Price Book';
    List<Product2> devices;
    //Map<ID, Contact> m = new Map<ID, Contact>([SELECT Id, LastName FROM Contact]);
    if (brand == null || brand == ''){
      devices = [SELECT Color__c, Name,Id, Photo__c, ProductCode FROM Product2 WHERE Family=:MOVEL_FAMILY AND vlocity_cmt__Type__c=:APARELHOS_TYPE AND Manufacturer__c != null AND Model__c != null AND Color__c != null  AND IsActive = true AND IsDeleted = false AND vlocity_cmt__IsOrderable__c = true];
    }else{
     if (model == null || model == ''){
      devices = [SELECT Color__c,Name,Id, Photo__c, ProductCode FROM Product2 WHERE Family=:MOVEL_FAMILY AND vlocity_cmt__Type__c=:APARELHOS_TYPE AND Manufacturer__c = :brand AND Model__c != null AND Color__c != null  AND IsActive = true AND IsDeleted = false AND vlocity_cmt__IsOrderable__c = true];
     } else{
      if (color == null || color == ''){
        devices = [SELECT Color__c,Name,Id, Photo__c, ProductCode FROM Product2 WHERE Family=:MOVEL_FAMILY AND vlocity_cmt__Type__c=:APARELHOS_TYPE AND Manufacturer__c = :brand AND Model__c = :model AND Color__c != null  AND IsActive = true AND IsDeleted = false AND vlocity_cmt__IsOrderable__c = true];
      } else{
        devices = [SELECT Color__c,Name,Id, Photo__c, ProductCode FROM Product2 WHERE Family=:MOVEL_FAMILY AND vlocity_cmt__Type__c=:APARELHOS_TYPE AND Manufacturer__c = :brand AND Model__c = :model AND Color__c = :color AND IsActive = true AND IsDeleted = false AND vlocity_cmt__IsOrderable__c = true];    
      }
     }
    }
    /*
  List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id  FROM PricebookEntry where Product2Id in (SELECT Id FROM Product2 WHERE Family=:MOVEL_FAMILY AND vlocity_cmt__Type__c=:APARELHOS_TYPE AND Manufacturer__c != null AND Model__c != null AND Color__c != null  AND IsActive = true) AND Pricebook2Id in (select Id from Pricebook2 where Name = :standardPricebook)];
  Map<Id,String> pricebookEntriesMap = new Map<Id,String>();
  for(PricebookEntry pbEntry : pricebookEntries){
    pricebookEntriesMap.put(pbEntry.Product2Id, pbEntry.Id);
  }*/

    Integer pageSize;
    try{
      pageSize = integer.valueof(System.Label.CEC_PME_Pagination);
    }catch(Exception e){
      pageSize = 12;
    }
    Integer counter = 0;
    Integer currentPage = 1;
    List<Map<String, String>> page;
    Map<String, List<Map<String, String>>> pages = new Map<String,List<Map<String, String>>>();
      for (Product2 rel : devices){
             
        if (counter == 0){
          page = new List<Map<String, String>>();
        }
          
          
          Map<String, String> tempMap = new Map<String, String>();
          tempMap.put('productName', rel.Name); // Language Independent
          //tempMap.put('productId', pricebookEntriesMap.get(rel.Id));
          tempMap.put('productId', rel.Id);
          tempMap.put('picture', rel.Photo__c);
          tempMap.put('color', rel.Color__c);
          tempMap.put('productCode', rel.ProductCode);
          page.add(tempMap);
          pages.put('page'+currentPage,page);
          if (counter == pageSize-1){
            counter = 0;
            currentPage++;
          }else{
            counter++;  
          }
          
      }
      outMap.put('devices', pages);
  }

  /*
* Autor: Gabriel Russo
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 12] + Get Delivery options.
*/  
  public void getDeliveryOptions(Map<String, Object> input,Map<String, Object> outMap, Map<String, Object> options){

  // Map of List where the Key is the Potential Values in the Other Picklist
      Map<String, Set<Map<String, String>>> dependency = new Map<String,Set<Map<String, String>>>();
      Map<String, String> option = new Map<String, String>();
      dependency.put('Free', new Set<Map<String, String>>());
      dependency.put('Restricted', new Set<Map<String, String>>());
      option.put('name', 'Logistica'); 
      option.put('value', 'Logistica');
      dependency.get('Free').add(option);
      dependency.get('Restricted').add(option);

      option = new Map<String, String>();
      option.put('name', 'Local'); 
      option.put('value', 'Local');
      dependency.get('Free').add(option);

      outMap.put('dependency', dependency);
  }


  private void getDevicePrices(Map<String, Object> input,Map<String, Object> outMap, Map<String, Object> options){
    Map<String, String> franquias = new Map<String, String>();
    //getting the franquias Map to translate the code for the final tree
    for (Product2 franquia : [SELECT Name,ProductCode FROM Product2 where vlocity_cmt__Type__c  like 'Franquia']){
      franquias.put(franquia.ProductCode,franquia.Name);
    }

    Set<String> activeDevices = getActiveDevices();

    outMap.put('activedDevices', activeDevices);
    outMap.put('franquiaGroups', franquias);

    //getting devices
    String planName = String.isNotBlank(String.valueOf(input.get('convertedPlanName'))) ? String.valueOf(input.get('convertedPlanName')) : String.valueOf(input.get('planName'));
    Map<String, Object> devicePricesAux = getDevicePrices(activeDevices,planName);
    outMap.put('devicePrices', devicePricesAux);

    //getting franquias control
    Map<String, List<String>> franquiaControl = getFranquiasControl();
  outMap.put('franquiaAvailability',franquiaControl);

  }

  private Set<String> getActiveDevices(){
    Set<String> activeDevices = new Set<String>(); 
    for (Product2 device : [SELECT ProductCode FROM Product2 WHERE Family=:MOVEL_FAMILY AND vlocity_cmt__Type__c=:APARELHOS_TYPE AND Manufacturer__c != null AND Model__c != null AND Color__c != null  AND IsActive = true AND IsDeleted = false AND vlocity_cmt__IsOrderable__c = true]){
    activeDevices.add(device.ProductCode);
    } 
    return activeDevices;
  }

 public void addDevicePrice(Map<String, String> rowInput, Map<String, String> rowOutput,Map<String, Object> outMap, String asProfileName){
      String paymentMethod = rowInput.get('Payment_Method');
      String deviceCode = rowInput.get('Device_Code');
      String planCode = rowInput.get('Plan_Code');
      String planName = rowInput.get('Plan_Name') =='Plano Claro Total Compartilhado'? 'Compartilhado':'Individual' ;
      String priceType = rowInput.get('Price_Type');
      String tradeIn = rowInput.get('TradeIn');

      if (paymentMethod == 'BasePrice'){//Vista
        Map<String, Object> level1 = (Map<String, Object>)outMap.get('Vista');
        level1.put(deviceCode, rowOutput.get('MRC'));
      }else{//24 times
        Map<String, Object> level1 = (Map<String, Object>)outMap.get('24Vezes');
        verifyNode(level1,deviceCode);
        
        if (deviceCode == planCode){ //Pontos
          Map<String, Object> level2 = (Map<String, Object>)level1.get(deviceCode);
          verifyNode(level2, 'Pontos');
          Map<String, Object> level3 = (Map<String, Object>)level2.get('Pontos');
          //Danilo Trade-In
          if(tradeIn == 'Yes'){
            verifyNode(level3, 'WithTradeIn');
            Map<String, Object> level4 = (Map<String, Object>)level3.get('WithTradeIn');
            level4.put(priceType,rowOutput.get('MRC'));
          }
          else {
            verifyNode(level3, 'WithoutTradeIn');
            if(priceType=='0PTS')
            level2.put('Kit',rowOutput.get('MRC'));
            Map<String, Object> level4 = (Map<String, Object>)level3.get('WithoutTradeIn');
            level4.put(priceType,rowOutput.get('MRC'));
          }
        }else{ //Faixa
			  // MAMB: Modificación para incorporar la validación del perfil TOPPME + Trade-In
            if(asProfileName == 'TOPPME'){
                Map<String, Object> level2 = (Map<String, Object>)level1.get(deviceCode);
                verifyNode(level2, 'Faixa');
                Map<String, Object> level3 = (Map<String, Object>)level2.get('Faixa');
                    if(tradeIn == 'Yes'){
                        verifyNode(level3, 'WithTradeIn');
                      Map<String, Object> level4 = (Map<String, Object>)level3.get('WithTradeIn');
                        level4.put(planCode,rowOutput.get('MRC'));
                    }
                    else{
                        verifyNode(level3, 'WithoutTradeIn');
                        Map<String, Object> level4 = (Map<String, Object>)level3.get('WithoutTradeIn');
                        level4.put(planCode,rowOutput.get('MRC'));
                    }
            }else{
                
                Map<String, Object> level2 = (Map<String, Object>)level1.get(deviceCode);
                verifyNode(level2, 'Faixa');
                Map<String, Object> level3 = (Map<String, Object>)level2.get('Faixa');
                verifyNode(level3, 'WithoutTradeIn');
                Map<String, Object> level4 = (Map<String, Object>)level3.get('WithoutTradeIn');
                level4.put(planCode,rowOutput.get('MRC'));
                        
                //level3.put(planCode,rowOutput.get('MRC'));
                level4.put(planCode,rowOutput.get('MRC'));

            }
        }
    }
  
  }

  private Map<String, Object> getDevicePrices( Set<String> activeDevices, String planName){
    Map<String, Object> devicePricesAux = new Map<String, Object>();
    devicePricesAux.put('Vista',new Map<String, Object>());
    devicePricesAux.put('24Vezes',new Map<String, Object>());
    Profile p = [Select Name from Profile where Id =: userinfo.getProfileid() LIMIT 1];
    String profileName = 'All';
    if (toppmeProfiles.contains(p.name))
      profileName = 'TOPPME';

    vlocity_cmt__CalculationMatrixVersion__c activeMatrix = [SELECT Id FROM vlocity_cmt__CalculationMatrixVersion__c where vlocity_cmt__CalculationMatrixId__c in (SELECT Id FROM vlocity_cmt__CalculationMatrix__c where Name like 'Device Pricing - PME All') and vlocity_cmt__IsEnabled__c =true order by vlocity_cmt__Priority__c  Desc limit 1];
    //system.debug('Active Matrix: '+ activeMatrix.Id);
    Map<String, String> rowInput;
    Map<String, String> rowOutput;
    for (vlocity_cmt__CalculationMatrixRow__c matrixRow :[SELECT vlocity_cmt__InputData__c,vlocity_cmt__OutputData__c FROM vlocity_cmt__CalculationMatrixRow__c WHERE vlocity_cmt__CalculationMatrixVersionId__c = :activeMatrix.Id and IsDeleted = false and vlocity_cmt__OutputData__c  != null]){
      //system.debug(matrixRow.vlocity_cmt__InputData__c);
      rowInput = (Map<String, String>)  JSON.deserialize(matrixRow.vlocity_cmt__InputData__c, Map<String, String>.class);
      rowOutput = (Map<String, String>) JSON.deserialize(matrixRow.vlocity_cmt__OutputData__c, Map<String, String>.class);

      System.debug('Plan Name:'+planName);
      if(rowInput.get('Plan_Name')==planName && rowInput.get('User_Type') == profileName && activeDevices.contains(rowInput.get('Device_Code'))){
          addDevicePrice(rowInput,rowOutput,devicePricesAux,profileName);
        }
              
    }
    return devicePricesAux;

  }


  private Map<String, List<String>> getFranquiasControl(){
    Map<String, List<String>> franquiaControl = new Map<String, List<String>>();
    vlocity_cmt__CalculationMatrixVersion__c activeControlMatrix = [SELECT Id   FROM vlocity_cmt__CalculationMatrixVersion__c WHERE vlocity_cmt__CalculationMatrixId__c in (SELECT Id FROM vlocity_cmt__CalculationMatrix__c WHERE Name like 'PME Franquias Control') AND  vlocity_cmt__IsEnabled__c=true order by vlocity_cmt__Priority__c Desc limit 1];
    
    Map<String, String> rowInput;
    Map<String, String> rowOutput;

    for (vlocity_cmt__CalculationMatrixRow__c matrixRow :[SELECT vlocity_cmt__InputData__c,vlocity_cmt__OutputData__c FROM vlocity_cmt__CalculationMatrixRow__c where vlocity_cmt__CalculationMatrixVersionId__c = :activeControlMatrix.Id and IsDeleted = false and vlocity_cmt__OutputData__c  != null]){
      rowInput = (Map<String, String>)  JSON.deserialize(matrixRow.vlocity_cmt__InputData__c, Map<String, String>.class);
      rowOutput = (Map<String, String>) JSON.deserialize(matrixRow.vlocity_cmt__OutputData__c, Map<String, String>.class);

      for (String key : rowOutput.keySet()) {
      if (!franquiaControl.containsKey(key))
        franquiaControl.put(key,new List<String>());
      if (Boolean.valueOf(rowOutput.get(key)))
          franquiaControl.get(key).add(rowInput.get('Franquia Code'));
      }
  }

  return franquiaControl;
  }

  private void verifyNode(Map<String, Object> node, String nodeName){
      if(!(node).containsKey(nodeName)){
      node.put(nodeName, new Map<String, Object>());
    }
  }

/*
{
  "pagamento": "24Vezes",
  "device": {
    "productCode": "16385",
    "productId": "01u2C0000053dIXQAY",
    "discountType": "Pontos",
    "group": "300PTS",
    "franquia": "00k2C000003yM4UQAU",
    "qtty": "1"
  },
  "cartId": "0062C000004lMBOQA2"
}
*/

  private void addDeviceToCart(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){
    try{
      Map<String, Object> device = (Map<String, Object>) input.get('device');
      String pagamento = (String) input.get('pagamento');
      String cartId = (String) input.get('cartId');
      String isKit=(String) device.get('isKit');
      String productCode =(String) device.get('productCode');
      String productId = (String) device.get('productId');
      String discountType = (String) device.get('discountType');
      String discountGroup = (String) device.get('group');
      String franquia = (String) device.get('franquia');
      Integer qtty = (Integer) device.get('qtty');
      String tradeIn = (String) device.get('tradeIn');

      String cartType = ((Id)cartId).getSObjectType().getDescribe().getName();

      SObject item;
      SObject simItem;
      SObject simCardAvulso;
      Integer lineNumber;
      PricebookEntry pricebookEntry;
      PricebookEntry devicePricebookEntry;
      String parentUf;

      if(cartType == 'Opportunity'){

        item = new OpportunityLineItem();
        System.debug('cartId'+ cartId);
        item.put('ReliesOnReferenceId__c', franquia);
        OpportunityLineItem oppItem = [SELECT vlocity_cmt__LineNumber__c FROM OpportunityLineItem where OpportunityId = :cartId and vlocity_cmt__LineNumber__c  != '' order By vlocity_cmt__LineNumber__c desc limit 1];
        lineNumber = Integer.valueOf(oppItem.vlocity_cmt__LineNumber__c);
        OpportunityLineItem parent = [SELECT TypeOfRequest__c FROM OpportunityLineItem WHERE Id = :franquia limit 1];
        
        //if(parent.TypeOfRequest__c != 'TT PF/PJ'){
          simItem = new OpportunityLineItem();
          pricebookEntry = [SELECT Id,Product2Id FROM PricebookEntry where Product2Id in (SELECT Id FROM Product2 where ProductCode like :SIMCARD_APARELHO) and Pricebook2Id in (SELECT Pricebook2Id FROM Opportunity where Id = :cartId) limit 1];
          simCardAvulso = [SELECT Id,Quantity,SAP_ID__c,Description, ParentGroup__c, Group__c, Subgroup__c,TypeOfRequest__c,vlocity_cmt__OverageTotal__c FROM OpportunityLineItem where Product2Id in (SELECT Id FROM Product2 where ProductCode like :SIMCARD_AVULSO) and OpportunityId = :cartId and ReliesOnReferenceId__c = :franquia limit 1];
       // }
      }else{
        if(cartType == 'Order'){
          OrderItem assetRefId = [SELECT vlocity_cmt__AssetReferenceId__c FROM OrderItem WHERE Id =: franquia LIMIT 1];

          item = new OrderItem();
          
          item.put('ReliesOnReferenceId__c', assetRefId.vlocity_cmt__AssetReferenceId__c); 
          OrderItem ordItem = [SELECT vlocity_cmt__LineNumber__c FROM OrderItem where OrderId = :cartId and vlocity_cmt__LineNumber__c  != '' order By vlocity_cmt__LineNumber__c desc limit 1];
          lineNumber = Integer.valueOf(ordItem.vlocity_cmt__LineNumber__c);
          devicePricebookEntry = [SELECT Id,Product2Id FROM PricebookEntry where Product2Id =:productId  and Pricebook2Id in (SELECT Pricebook2Id FROM Order where Id = :cartId) limit 1];

          OrderItem parent = [SELECT TypeOfRequest__c FROM OrderItem WHERE Id = :franquia limit 1];
          
          //if(parent.TypeOfRequest__c != 'TT PF/PJ'){
           simItem = new OrderItem();
           pricebookEntry = [SELECT Id,Product2Id FROM PricebookEntry where Product2Id in (SELECT Id FROM Product2 where ProductCode like :SIMCARD_APARELHO) and Pricebook2Id in (SELECT Pricebook2Id FROM Order where Id = :cartId) limit 1];
            simCardAvulso = [SELECT Id,Quantity,SAP_ID__c,Description, ParentGroup__c, Group__c, Subgroup__c,TypeOfRequest__c,vlocity_cmt__OverageTotal__c FROM OrderItem where Product2Id in (SELECT Id FROM Product2 where ProductCode like :SIMCARD_AVULSO) and OrderId = :cartId and ReliesOnReferenceId__c = :assetRefId.vlocity_cmt__AssetReferenceId__c limit 1];
          //}
        }
      }
      //PME_SimCard_Info__c simcardInfo = [SELECT CreatedById,CreatedDate,Description__c,Id,Name,Price__c,SAP_ID_UF__c,SAP_ID__c,UF__c FROM PME_SimCard_Info__c where UF__c = :parentUf limit 1];
      //Saving simcard and device
      List<SObject> items = new List<SObject>();
      //init device attributes
      if (item != null){
        item.put(cartType+'Id',cartId); //Adding cartId relationship
        item.put('Product2Id', productId); 
        item.put('vlocity_cmt__Product2Id__c',productId);
        item.put('vlocity_cmt__ProductHierarchyPath__c',productId);
        item.put('Avoid_vlc_pricing__c',true);

        //
        String planName = String.isNotBlank(String.valueOf(input.get('convertedPlanName'))) ? String.valueOf(input.get('convertedPlanName')) : String.valueOf(input.get('planName'));
        Set<String> activeDevices = getActiveDevices();
        Map<String, Object> devicePricesAux = getDevicePrices(activeDevices,planName);
        //values to be defined
        initPrices(item);
        
        System.debug(pagamento);
        Map<String, Object> devicePricesAux2 = (Map<String, Object>)devicePricesAux.get(pagamento);
        System.debug(devicePricesAux2);
        Integer finalPrice;
        Integer basePrice;
        //details about pricing
        item.put('Payment_Term__c', pagamento);
        Decimal consumedPoints = 0.0;
        

        if(pagamento!='Vista'){
          //System.debug(productCode);
          Map<String, Object> devicePricesAux3 = (Map<String, Object>)devicePricesAux2.get(productCode);
          //System.debug(discountType);
          Map<String, Object> devicePricesAux4 = (Map<String, Object>)devicePricesAux3.get(discountType);
          
          item.put('Discount_Type__c',discountType);

          if(discountType == 'Pontos'){
                //with or without Trade in
                Map<String, Object> devicePricesAux5 = (Map<String, Object>)devicePricesAux4.get(tradeIn);
                basePrice = Integer.valueOf(devicePricesAux5.get('0PTS'));         
                finalPrice = Integer.valueOf(devicePricesAux5.get(discountGroup));         
                System.debug(discountGroup);
                System.debug(devicePricesAux2);
                System.debug(devicePricesAux3);
                System.debug(devicePricesAux4);
                System.debug(devicePricesAux5);
                consumedPoints = loyalty.get(discountGroup);
                item.put('Discount_Values__c',discountGroup);
                System.debug('FINAL PRICE PONTOS: '+finalPrice); //Dan Mas 16052019
				System.debug('BASE PRICE: '+basePrice); //Dan Mas 28082019
          }else{
                System.debug('DISCOUNT TYPE:'+discountType+' DISCOUNT GROUP:'+discountGroup+' TRADEIN:'+tradeIn);
                System.debug(devicePricesAux3);
                Map<String, Object> devicePricesAux4_basePrice = (Map<String, Object>)devicePricesAux3.get('Pontos');
                Map<String, Object> devicePricesAux5 = (Map<String, Object>)devicePricesAux4_basePrice.get(tradeIn);
                basePrice = Integer.valueOf(devicePricesAux5.get('0PTS')); 
                Map<String,Object> devicePricesAux6 = (Map<String, Object>)devicePricesAux4.get(tradeIn);
                finalPrice = Integer.valueOf(devicePricesAux6.get(discountGroup));
                if(isKit != '')
                  finalPrice = Integer.valueOf(devicePricesAux3.get('Kit'));
                item.put('Discount_Values__c','Faixa '+discountGroup);
                System.debug('BASE PRICE FAIXA: '+basePrice);
                System.debug('FINAL PRICE FAIXA: '+finalPrice); //Dan Mas 16052019
				System.debug('BASE PRICE: '+basePrice); //Dan Mas 28082019
          }
        }else{
            System.debug(discountType); 
            Map<String, Object> devicePricesAux2_basePrice = (Map<String, Object>)devicePricesAux.get('24Vezes');
            Map<String, Object> devicePricesAux3 = (Map<String, Object>)devicePricesAux2_basePrice.get(productCode);
            Map<String, Object> devicePricesAux4 = (Map<String, Object>)devicePricesAux3.get('Pontos');
            Map<String, Object> devicePricesAux5 = (Map<String, Object>)devicePricesAux4.get(tradeIn);
            System.debug('devicePricesAux2 ' + devicePricesAux2);
            System.debug('devicePricesAux3 ' + devicePricesAux3);
            if(devicePricesAux5 != null && devicePricesAux5.get('0PTS') != null) {
                basePrice = Integer.valueOf(devicePricesAux5.get('0PTS'));
            } 
            if(devicePricesAux2 != null && devicePricesAux2.get(productCode) != null) {
                finalPrice = Integer.valueOf(devicePricesAux2.get(productCode));
            } 
            System.debug('FINAL PRICE: '+finalPrice); //Dan Mas 16052019
            System.debug('BASE PRICE: '+basePrice); //Dan Mas 28082019
        }
        if(cartType == 'Opportunity'){
        	item.put('TotalPrice',finalPrice*qtty);
        	item.put('vlocity_cmt__OverageTotal__c',basePrice);
        }
        else if (cartType == 'Order'){
            item.put('UnitPrice',finalPrice);
            item.put('vlocity_cmt__OverageTotal__c',basePrice);
            item.put('PricebookEntryId',devicePricebookEntry.id);
        }
        
        System.debug('PARAMETERS BEFORE: '+ qtty +' '+ finalPrice+' '+consumedPoints); //Dan Mas 16052019
        setItemPrices(item,qtty,finalPrice,consumedPoints);
        System.debug('PARAMETERS AFTER: '+ qtty +' '+ finalPrice+' '+consumedPoints); //Dan Mas 16052019

        item.put('vlocity_cmt__CurrencyPaymentMode__c','Currency');
        item.put('vlocity_cmt__LineNumber__c',getLineNumber(lineNumber+1));
        item.put('TypeOfRequest__c',simCardAvulso.get('TypeOfRequest__c'));

        items.add(item);
      }
      
      //init simcard attributes
      if (simItem != null && simCardAvulso != null){
        Integer simPrice = 1;

        simItem.put(cartType+'Id',cartId); //Adding cartId relationship
        simItem.put('Product2Id', pricebookEntry.Product2Id); //Product2 reference
        simItem.put('vlocity_cmt__Product2Id__c',pricebookEntry.Product2Id);
        simItem.put('vlocity_cmt__ProductHierarchyPath__c',pricebookEntry.Product2Id);

        simItem.put('SAP_ID__c',simCardAvulso.get('SAP_ID__c'));
        simItem.put('Description',simCardAvulso.get('Description'));
        simItem.put('ParentGroup__c',simCardAvulso.get('ParentGroup__c'));
        simItem.put('Group__c',simCardAvulso.get('Group__c'));
        simItem.put('Subgroup__c',simCardAvulso.get('Subgroup__c'));
        simItem.put('TypeOfRequest__c',simCardAvulso.get('TypeOfRequest__c'));

        //prices
        initPrices(simItem);
    
        if(simCardAvulso.get('TypeOfRequest__c') == 'TT PF/PJ')
          simPrice = 0;      
        else
          simPrice = 1;         
        
        setItemPrices(simItem,qtty,simPrice,0.0);
 
        if(cartType == 'Opportunity'){
			simItem.put('TotalPrice',simPrice*qtty);
			simItem.put('vlocity_cmt__OverageTotal__c',simCardAvulso.get('vlocity_cmt__OverageTotal__c'));
        }
        else if (cartType == 'Order'){
          	simItem.put('UnitPrice',simPrice);
			simItem.put('vlocity_cmt__OverageTotal__c',simCardAvulso.get('vlocity_cmt__OverageTotal__c'));
          	simItem.put('PricebookEntryId',PricebookEntry.id);
        }

        simItem.put('vlocity_cmt__CurrencyPaymentMode__c','Currency');
        simItem.put('vlocity_cmt__LineNumber__c',getLineNumber(lineNumber+2));
        items.add(simItem); 
      }

      System.debug('ITEMS ADDING: '+ items);
      insert items;
      System.debug('ITEMS ADDED : '+ items);

      
      //update of referenceId and reliesOn for the device
    item.put('vlocity_cmt__RootItemId__c',item.get('Id'));
    if(cartType == 'Opportunity'){
        item.put('vlocity_cmt__AssetReferenceId__c',item.get('Id'));
      }else{
        if(cartType == 'Order'){
          item.put('vlocity_cmt__AssetReferenceId__c',item.get('Id'));

        }
      }    

      //update of referenceId and reliesOn for the simcard
      if (simItem != null && simCardAvulso != null){
      item.put('vlocity_cmt__RootItemId__c',item.get('Id'));
      simItem.put('vlocity_cmt__RootItemId__c',simItem.get('Id'));
      simItem.put('Avoid_vlc_pricing__c',true);
            
      if(cartType == 'Opportunity'){
          simItem.put('ReliesOnReferenceId__c', item.get('Id')); //Adding reliesOn device
          item.put('vlocity_cmt__AssetReferenceId__c',item.get('Id'));
          simItem.put('vlocity_cmt__AssetReferenceId__c',simItem.get('Id'));
        }else{
          if(cartType == 'Order'){
            simItem.put('ReliesOnReferenceId__c', item.get('Id')); //Adding reliesOn device
            item.put('vlocity_cmt__AssetReferenceId__c',item.get('Id'));
            simItem.put('vlocity_cmt__AssetReferenceId__c',simItem.get('Id'));

          }
        }    

        //logic for update or delete simCard Avulso depending on the remaining amount
        simCardAvulso.put('Quantity',Integer.valueOf(((Decimal)simCardAvulso.get('Quantity')))-qtty);
        if(Integer.valueOf(((Decimal)simCardAvulso.get('Quantity'))) > 0){
            System.debug('Quantity mayor que 0');
            System.debug(simCardAvulso);
          items.add(simCardAvulso);
        }else{
          delete simCardAvulso;
        }
      }

    update items;

      outMap.put('result',true);

  }catch(Exception e){
    outMap.put('Message', e.getMessage());
  }
    

  }

  private void initPrices(SObject item){
        
    item.put('vlocity_cmt__ProvisioningStatus__c', 'New');
    item.put('vlocity_cmt__SequenceNumber__c', 1.0);
      item.put('vlocity_cmt__Action__c', 'Add');
      item.put('vlocity_cmt__EffectiveRecurringTotal__c', 0.0);
      item.put('vlocity_cmt__EffectiveQuantity__c',0.0);
      item.put('vlocity_cmt__EffectiveOneTimeTotal__c',0.0);
      item.put('vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c',0.0);
      item.put('vlocity_cmt__OneTimeCalculatedPrice__c',0.0);
      item.put('vlocity_cmt__OneTimeCharge__c',0.0);
      
      item.put('vlocity_cmt__OneTimeManualDiscount__c',0.0);
      item.put('vlocity_cmt__OneTimeTotal__c',0.0);
      item.put('vlocity_cmt__RecurringCalculatedPrice__c',0.0);
      item.put('vlocity_cmt__RecurringCharge__c',0.0);
      item.put('vlocity_cmt__RecurringManualDiscount__c',0.0);
      item.put('vlocity_cmt__RecurringTotal__c',0.0);
  }

  @TestVisible private void setItemPrices(SObject item, Decimal qtty, Integer price, Decimal consumedPoints){
    System.debug('PARAMETERS INSIDE SETITEMPRICES: '+ qtty +' '+ price +' '+consumedPoints); //Dan Mas 16052019
        
    item.put('Quantity', qtty);  // Amount  
      item.put('vlocity_cmt__EffectiveQuantity__c', qtty);

      //unit Price
      item.put('vlocity_cmt__RecurringCalculatedPrice__c',price);
      item.put('vlocity_cmt__RecurringCharge__c',price);

      //total
      //item.put('TotalPrice', qtty*price);
      item.put('vlocity_cmt__EffectiveRecurringTotal__c', qtty*price);
      System.debug('FINAL PRICE1: vlocity_cmt__EffectiveRecurringTotal__c: '+qtty*price); //Dan Mas 16052019
      item.put('vlocity_cmt__RecurringTotal__c',qtty*price);
      System.debug('FINAL PRICE1: vlocity_cmt__RecurringTotal__c: '+qtty*price); //Dan Mas 16052019


      //loyalty
      item.put('vlocity_cmt__OneTimeLoyaltyPrice__c',(-1)*consumedPoints);
      item.put('vlocity_cmt__OneTimeLoyaltyTotal__c',(-1)*consumedPoints*qtty);
      item.put('vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c',(-1)*consumedPoints*qtty);

  }

  @TestVisible private String getLineNumber(Integer lineNumber){
    return String.valueOf(lineNumber).leftPad(4,'0');
  }

/*
  public void tryDelete(String deviceId){
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> options = new Map<String, Object>();

    input.put('deviceId',deviceId);
    removeDeviceFromCart(input,outMap,options);
  }*/

  @TestVisible private void removeDeviceFromCart(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){
    String deviceId = (String) input.get('deviceId');
      system.debug('INSIDE THE REMOVE');

    String itemType = ((Id)deviceId).getSObjectType().getDescribe().getName();
    SObject device;
    SObject simcardAparelho;
    SObject simcardAvulso;
    List<SObject> itemsToDelete = new List<SObject>();

    Integer simPrice = 1;

    Product2 simcardAparelhoProduct= [SELECT Id FROM Product2 WHERE ProductCode like :SIMCARD_APARELHO LIMIT 1];
    Product2 simcardAvulsoProduct= [SELECT Id FROM Product2 WHERE ProductCode like :SIMCARD_AVULSO LIMIT 1];
    Id franquiaId;
    Id assetRefIdDevice;
    PricebookEntry pricebookEntry;
    String typeOfRequest;  
    Decimal  qtty;
    String opptyId;
    String orderId;

    if (itemType == 'OpportunityLineItem'){
      device = [SELECT vlocity_cmt__LineNumber__c, OpportunityId,ReliesOnReferenceId__c, TypeOfRequest__c, vlocity_cmt__AssetReferenceId__c FROM OpportunityLineItem WHERE Id = :deviceId LIMIT 1];
      franquiaId = (Id)device.get('ReliesOnReferenceId__c');
      opptyId=String.valueOf(device.get('OpportunityId'));  
        
      OpportunityLineItem parent = [SELECT TypeOfRequest__c FROM OpportunityLineItem where vlocity_cmt__AssetReferenceId__c = :franquiaId AND OpportunityId = :opptyId limit 1];
      typeOfRequest = parent.TypeOfRequest__c;
      
      //if(typeOfRequest != 'TT PF/PJ'){
       simcardAparelho = [SELECT Description,SAP_ID__c,Quantity, ParentGroup__c, Group__c, Subgroup__c, TypeOfRequest__c, vlocity_cmt__AssetReferenceId__c, vlocity_cmt__OverageTotal__c FROM OpportunityLineItem WHERE product2Id = :simcardAparelhoProduct.Id AND ReliesOnReferenceId__c =:deviceId AND OpportunityId = :opptyId LIMIT 1];
       simcardAvulso = new OpportunityLineItem();
       simCardAvulso.put('ReliesOnReferenceId__c',franquiaId);
       simCardAvulso.put('OpportunityId',device.get('OpportunityId'));
       simCardAvulso.put('vlocity_cmt__RootItemid__c',franquiaId);
      //}
    }else if (itemType == 'OrderItem'){
      device = [SELECT vlocity_cmt__LineNumber__c,OrderId,ReliesOnReferenceId__c, TypeOfRequest__c, vlocity_cmt__AssetReferenceId__c from OrderItem where Id = :deviceId limit 1];
      orderId= String.valueOf(device.get('OrderId')); 
      franquiaId = (Id)device.get('ReliesOnReferenceId__c');
      assetRefIdDevice = (Id)device.get('vlocity_cmt__AssetReferenceId__c');
      OrderItem parent = [SELECT TypeOfRequest__c FROM OrderItem where vlocity_cmt__AssetReferenceId__c = :franquiaId AND OrderId =: orderId limit 1];
      typeOfRequest = parent.TypeOfRequest__c;

      //if(typeOfRequest != 'TT PF/PJ'){
        simcardAparelho = [SELECT Description,SAP_ID__c,Quantity, ParentGroup__c, Group__c, Subgroup__c, TypeOfRequest__c, vlocity_cmt__AssetReferenceId__c,vlocity_cmt__OverageTotal__c FROM OrderItem WHERE product2Id = :simcardAparelhoProduct.Id AND ReliesOnReferenceId__c =:assetRefIdDevice AND OrderId =: orderId LIMIT 1];
        String cartId = (String)device.get('OrderId');
        pricebookEntry = [SELECT Id,Product2Id FROM PricebookEntry where Product2Id = :simcardAvulsoProduct.id and Pricebook2Id in (SELECT Pricebook2Id FROM Order where Id = :cartId) limit 1];
        simcardAvulso = new OrderItem();
        simCardAvulso.put('ReliesOnReferenceId__c',franquiaId);
        simCardAvulso.put('OrderId',device.get('OrderId'));
        simCardAvulso.put('vlocity_cmt__RootItemid__c',franquiaId);
      //}
    }

    system.debug('BEFORE THE qtty');
    qtty = (Decimal) simcardAparelho.get('Quantity');
    system.debug('AFTER THE qtty');

    itemsToDelete.add(device);
  
    //if(typeOfRequest != 'TT PF/PJ'){  
    itemsToDelete.add(simcardAparelho);

    try{
      //trying to increase SimcardAvulso
      system.debug('BEFORE THE TRY');
      if (itemType == 'OpportunityLineItem'){
          simcardAvulso = [SELECT Quantity FROM OpportunityLineItem WHERE product2Id = :simcardAvulsoProduct.Id AND ReliesOnReferenceId__c =:franquiaId LIMIT 1];
      }else if (itemType == 'OrderItem'){
        simcardAvulso = [SELECT Quantity FROM OrderItem WHERE product2Id = :simcardAvulsoProduct.Id AND ReliesOnReferenceId__c =:franquiaId LIMIT 1];
      }
      system.debug('INSIDE THE TRY');

      simcardAvulso.put('Quantity', ((Decimal)simcardAvulso.get('Quantity'))+((Decimal)simcardAparelho.get('Quantity')));
      update simCardAvulso;
    }catch(Exception e){
      //Creating simCart Avulso
      system.debug('INSIDE THE CATCH');

      simcardAvulso.put('Product2Id',simcardAvulsoProduct.Id);
      simCardAvulso.put('vlocity_cmt__LineNumber__c',device.get('vlocity_cmt__LineNumber__c'));
      simcardAvulso.put('Description',simcardAparelho.get('Description'));
      simcardAvulso.put('SAP_ID__c',simcardAparelho.get('SAP_ID__c'));
      simcardAvulso.put('ParentGroup__c',simcardAparelho.get('ParentGroup__c'));
      simcardAvulso.put('Group__c',simcardAparelho.get('Group__c'));
      simcardAvulso.put('Subgroup__c',simcardAparelho.get('Subgroup__c'));
      simcardAvulso.put('Quantity',simcardAparelho.get('Quantity'));
      simcardAvulso.put('TypeOfRequest__c',simcardAparelho.get('TypeOfRequest__c'));
      simcardAvulso.put('vlocity_cmt__ProductHierarchyPath__c',simcardAvulsoProduct.Id);

      if(simCardAvulso.get('TypeOfRequest__c') == 'TT PF/PJ')
          simPrice = 0;      
        else
          simPrice = 10;         
        
        setItemPrices(simcardAvulso,qtty,simPrice,0.0);

      if (itemType == 'OpportunityLineItem'){
      	simcardAvulso.put('TotalPrice',simPrice*qtty);
		simcardAvulso.put('vlocity_cmt__OverageTotal__c',simcardAparelho.get('vlocity_cmt__OverageTotal__c'));
        simcardAvulso.put('vlocity_cmt__AssetReferenceId__c',simcardAparelho.get('vlocity_cmt__AssetReferenceId__c'));
      }else if (itemType == 'OrderItem'){
        simcardAvulso.put('UnitPrice',simPrice);
		simcardAvulso.put('vlocity_cmt__OverageTotal__c',simcardAparelho.get('vlocity_cmt__OverageTotal__c'));
        simcardAvulso.put('PricebookEntryId',pricebookEntry.id);
        simcardAvulso.put('vlocity_cmt__AssetReferenceId__c',simcardAparelho.get('vlocity_cmt__AssetReferenceId__c'));
      }
      system.debug('BEFORE INSERT SIMCARD AVULSO');
      system.debug(simCardAvulso);
      insert simCardAvulso;
      system.debug('AFTER INSERT SIMCARD AVULSO');

      if(simCardAvulso.get('TypeOfRequest__c') == 'TT PF/PJ'){
        simcardAvulso.put('Avoid_vlc_pricing__c',true);
        update simcardAvulso;
      }
    }
    //}
    system.debug('BEFORE DELETE ITEMS');
    delete itemsToDelete;
    system.debug('ITEMS DELETED');
  }

  public void checkDeviceCount(Map<String, Object> input,Map<String, Object> outMap, Map<String, Object> options){
      Integer maxTotal = (Integer) input.get('linesQuantity');
      Map<String, Object> device = (Map<String, Object>) input.get('device');
      Integer qtty = (Integer) device.get('qtty');
      Integer counter;
      Boolean blockAdd=false;

      if(input.get('deviceCount') != null)
        counter = (Integer) input.get('deviceCount');
      else
        counter=0;
        
        counter+=qtty;

        if(counter>maxTotal)
          blockAdd=true;

          outMap.put('blockAdd',blockAdd);
          outMap.put('deviceCount',counter);

      System.debug('counter:'+ counter);
      System.debug('blockAdd:'+ blockAdd);


      
  }

//16376
//{Device_Code=17070, Payment_Method=BasePrice24x, Plan_Code=17070, Plan_Name=Plano Claro Total Compartilhado, Price_Type=200PTS, TradeIn=No, User_Type=All}
/*
"devicePrices":{
    "Vista":{
      "16400": 350,
      "16401": 350,
      }  
    },
    "24Vezes":{
      "16400":{
        "Faixa": {
          "franquia1": 500,
          "franquia2": 600
        },
        "Pontos":{
          "100 PTS": 300,
          "140 PTS": 400
        }
      }
    }
  }*/
}