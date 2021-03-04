global with sharing class PME_Utils implements vlocity_cmt.VlocityOpenInterface {

    public Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {




        
        Boolean result = true;
        try
        {
            if (methodName.equals('TransformArrayToDRInput')) {
                TransformArrayToDRInput(input, outMap, options);
            }
            else if (methodName.equals('AppendStringToNode')) {
                AppendStringToNode(input, outMap, options);
            }
            else if (methodName.equals('SubtractStringToNode')) {
                SubtractStringToNode(input, outMap, options);
            }
            /*else if (methodName.equals('addToCart')) {
                addToCart(input, outMap, options);
            }*/
            else if (methodName.equals('generateGUID')) {
                generateGUID(input, outMap, options);
            }
            else if (methodName.equals('generateGUIDs')) {
                generateGUIDs(input, outMap, options);
            }/*
            else if (methodName.equals('GetCartProducts')) {
                GetCartProducts(input, outMap, options);
            }*/
            else if (methodName.equals('getSObjectType')) {
                getSObjectType(input, outMap, options);
            }else if (methodName.equals('decomposeOrder')) {
                decomposeOrder(input, outMap, options);
            }else{
                result = false;    
            }
        } 
        catch(Exception e)
        {
            throw e;
        }
        return result;
        


    



}
    private void generateGUID(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {




        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────
        * @description 
        * 
        * ──────────────────────────────────────────────────────────────────────────────────────────────────
        * @author   Damian Avrij
        * @date     2018-12-18
        * @param    Nothing
        * @return   GUID: The GUID generated
        *          
        */
        try{
            System.debug('Entering  generateGUID(');
            System.debug('input: '+input);

            //Generate a GUID for the Item
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);  

            outMap.put('GUID', guid);

        }
        catch(Exception e)
        {
            System.debug('Exception type caught: ' + e.getTypeName());
            System.debug('Exception Msg: ' + e.getMessage());
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            throw e;
        }
    


}
    /*
    private void GetCartProducts(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
        
        * ─────────────────────────────────────────────────────────────────────────────────────────────────
        * @description 
        * 
        * ──────────────────────────────────────────────────────────────────────────────────────────────────
        * @author   Damian Avrij
        * @date     2019-02-14
        * @param    Nothing
        * @return   
        *          
        
        try{
            Map<String, Object> req;
            System.debug('Entering GetCartProducts');
            System.debug('input: '+input);

            vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();

            //Replace spaces with + in order to call the API
            req = (Map<String, Object>) options.get('params');
            String filters = (String) req.get('filters');
            filters.replace(' ','+');
            System.debug('filters'+filters);
            req.put('filters', filters);

            appHandler.invokeMethod('getCartsProducts', req, outMap, options);    

        }
        catch(Exception e)
        {
            System.debug('Exception type caught: ' + e.getTypeName());
            System.debug('Exception Msg: ' + e.getMessage());
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            throw e;
        }
    }*/
    private void generateGUIDs(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {




        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────
        * @description 
        * 
        * ──────────────────────────────────────────────────────────────────────────────────────────────────
        * @author   Damian Avrij
        * @date     2019-01-16
        * @param    qtty: The quantity of GUIDs to be generated
        * @return   GUIDs: A list of "qtty" GUIDs
        *          
        */

        try{
            System.debug('Entering  generateGUIDs');
            System.debug('input: '+input);
            List<Object> GUIDs =  new List<Object>();
            Blob b;
            String h;
            String guid;

            Integer qtty = (Integer) options.get('qtty');
            Map<String, String> auxMap;

            for (Integer i=0; i < qtty; i++){

                b = Crypto.GenerateAESKey(128);
                h = EncodingUtil.ConvertTohex(b);
                guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);

                auxMap = new Map<String, String>();
                auxMap.put('vlocity_cmt__AssetReferenceId__c', guid);
                GUIDs.add(auxMap);

            }
            outMap.put('GUIDs', GUIds);

        }
        catch(Exception e)
        {
            System.debug('Exception type caught: ' + e.getTypeName());
            System.debug('Exception Msg: ' + e.getMessage());
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            throw e;
        }
    


}
    /*
    private void addToCart(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
        
        * ─────────────────────────────────────────────────────────────────────────────────────────────────
        * @description 
        * 
        * ──────────────────────────────────────────────────────────────────────────────────────────────────
        * @author   Damian Avrij
        * @date     2018-12-14
        * @param    NodeName
        * @return  
        *          
        
        try{
            System.debug('Entering addToCart');
            System.debug('input: '+input);

            String auxString;
            Map<String, Object> req;
            Map<String, Object> fieldsToUpdate;
            Map<String, Object> fieldsToUpdate2;
            List<Object> items;
            Map<String, Object> itemMap;

            fieldsToUpdate = (Map<String, Object>) options.get('fieldsToUpdate');
            if(fieldsToUpdate == null){
                fieldsToUpdate = new Map<String, Object>();
            }

            Object ftoUpdate2 = options.get('fieldsToUpdate2');
            Boolean b = ftoUpdate2 instanceof String;
            if (!b){
                fieldsToUpdate2 = (Map<String, Object>) options.get('fieldsToUpdate2');
                fieldsToUpdate.putAll(fieldsToUpdate2);
            }

            req = (Map<String, Object>) input.get('params');
            String cartId = (String) req.get('cartId');

            items = (List<Object>) req.get('items');
            itemMap = (Map<String, Object>) items[0];

            itemMap.put('fieldsToUpdate',fieldsToUpdate);

            System.debug('customReq: '+req);


            vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
            //Add item to cart
            appHandler.invokeMethod('postCartsItems', req, outMap, options);

            //Refresh cart
            req = new Map<String, Object>();
            req.put('cartId', cartId);
            req.put('methodName', 'getCartsItems');
            req.put('fields', 'ReliesOnReferenceId__c,AssetReferenceId__c');
            
            appHandler.invokeMethod('getCartsItems', req, outMap, options);    

        }
        catch(Exception e)
        {
            System.debug('Exception type caught: ' + e.getTypeName());
            System.debug('Exception Msg: ' + e.getMessage());
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            throw e;
        }
    }
*/
    private void SubtractStringToNode(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {




        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────
        * @description Subtract appendStr String to the node and each tag of the node
        * 
        * ──────────────────────────────────────────────────────────────────────────────────────────────────
        * @author   Damian Avrij
        * @date     2018-11-02
        * @param    NodeName
        *           appendStr
        * @return  
        *          
        */
        try{
            System.debug('Entering AppendStringToTags');
            System.debug('input: '+input);

            Map<String, Object> myOutMap = new Map<String, Object>();
            Map<String, Object> myNodeMap;
            Set<String> myKeySet;
            String auxString;

            String nodeName = (String) options.get('NodeName');
            String appendStr = (String) options.get('appendStr');
            auxString = nodeName + appendStr;
            Object node = input.get(auxString);

            System.debug('node: '+node);

            if (node != null){
                
                if(node instanceof Map<String, Object>){
                    myNodeMap = (Map<String, Object>) node;
                    myKeySet = myNodeMap.keySet();

                    //Change key name to all the elements of the Map
                    for (String myKey : myKeySet){
                        auxString = myKey.removeEnd(appendStr);
                        
                        System.debug('auxString: '+auxString);
                        myOutMap.put(auxString, myNodeMap.get(myKey));
                    }
                    //Change the name of the parent node
                    auxString = nodeName;
                    outMap.put(auxString, myOutMap);
                }
            }


        }
        catch(Exception e)
        {
            System.debug('Exception type caught: ' + e.getTypeName());
            System.debug('Exception Msg: ' + e.getMessage());
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            throw e;
        }
    



}
    private void AppendStringToNode(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {



        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────
        * @description Append StrToAppend String to the node and each tag of the node
        * 
        * ──────────────────────────────────────────────────────────────────────────────────────────────────
        * @author   Damian Avrij
        * @date     2018-11-02
        * @param    NodeName
        *           StrToAppend
        * @return  
        *          
        */
        try{
            System.debug('Entering AppendStringToTags');
            System.debug('input: '+input);

            Map<String, Object> myOutMap = new Map<String, Object>();
            Map<String, Object> myNodeMap;
            Set<String> myKeySet;
            String auxString;      
            //List<Object> myArray;

            String nodeName = (String) options.get('NodeName');
            String strToAppend = (String) options.get('StrToAppend');
            Object node = input.get(nodeName);

            System.debug('node: '+node);

            if (node != null){
                
                if(node instanceof Map<String, Object>){
                    myNodeMap = (Map<String, Object>) node;
                    myKeySet = myNodeMap.keySet();

                    //Change key name to all the elements of the Map
                    for (String myKey : myKeySet){
                        auxString = myKey + strToAppend;
                        System.debug('auxString: '+auxString);
                        myOutMap.put(auxString, myNodeMap.get(myKey));
                    }
                    //Change the name of the parent node
                    auxString = nodeName + strToAppend;
                    outMap.put(auxString, myOutMap);
                }
            }


        }
        catch(Exception e)
        {
            System.debug('Exception type caught: ' + e.getTypeName());
            System.debug('Exception Msg: ' + e.getMessage());
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            throw e;
        }
    



}
    private void TransformArrayToDRInput(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {

       


        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────
        * @description Transform an OS Input To a DR Input
        * 
        * ──────────────────────────────────────────────────────────────────────────────────────────────────
        * @author   Damian Avrij
        * @date     2018-10-26
        * @param    ArrayName
        * @return  
        *          
        */
        try{
            System.debug('Entering TransformArrayToDRInput');

            String arrayName = (String) options.get('ArrayName');
            Object auxObj = options.get(arrayName);
            Map<String, String> myMap;
            List<Object> myArray;
            String myArrayElementString;

            if(auxObj instanceof List<Object>){
                myArray = (List<Object>) auxObj;
                System.debug('arrayName: ' + myArray);
                
                List<Object> myOutList = new List<Object>();

                for (Object myArrayElement: myArray){
                    myMap = new Map<String, String>();
                    myArrayElementString = (String) myArrayElement;
                    myMap.put(arrayName, myArrayElementString);

                    myOutList.add(myMap);

                }
                outMap.put('transformArray', myOutList);
            }
            else if(auxObj instanceof String){
                myMap = new Map<String, String>();
                myArrayElementString = (String) auxObj;
                myMap.put(arrayName, myArrayElementString);
                outMap.put('transformArray', myMap);
            }

        }
        catch(Exception e)
        {
            System.debug('Exception type caught: ' + e.getTypeName());
            System.debug('Exception Msg: ' + e.getMessage());
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            throw e;
        }
    

      

}

    private void getSObjectType(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){

       


         /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────
        * @description Returns SObject name of the SObject id
        * 
        * ──────────────────────────────────────────────────────────────────────────────────────────────────
        * @author   Gabriel Russo
        * @date     2019-4-18
        * @param    
        * @return  
        *          
        */
        String sObjectId = (String)input.get('sObjectId');
        String sObjectName = (String)((Id)sObjectId).getSObjectType().getDescribe().getName();
        outMap.put('sObjectName',sObjectName);
    

  

}

    private void decomposeOrder(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){

     


         /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────
        * @description Returns SObject name of the SObject id
        * 
        * ──────────────────────────────────────────────────────────────────────────────────────────────────
        * @author   Gabriel Russo
        * @date     2019-4-18
        * @param    
        * @return  
        *          
        */
        String orderId = (String)input.get('ContextCartId');

        //quering the devices and simcards
        //List<OrderItem> orderItems = [SELECT vlocity_cmt__AssetReferenceId__c,ReliesOnReferenceId__c, PricebookEntry.Name, PricebookEntry.ProductCode, Quantity,vlocity_cmt__RecurringCalculatedPrice__c,vlocity_cmt__OneTimeLoyaltyPrice__c,SAP_ID__c,Description, ParentGroup__c, Group__c, Subgroup__c,OrderId, UnitPrice, TypeOfRequest__c, ProductCode__c, PlanGroup__c  FROM OrderItem WHERE OrderId = :orderId and Product2Id in (SELECT Id FROM Product2 WHERE (Family='Movel' AND vlocity_cmt__Type__c='Aparelhos') OR productCode = 'PME_SimCardAparelho_0001' OR productCode = 'PME_SimCardAvulso_0001')];
        List<OrderItem> orderItems = [SELECT vlocity_cmt__AssetReferenceId__c,ReliesOnReferenceId__c, PricebookEntry.Name, PricebookEntry.ProductCode, Quantity,vlocity_cmt__RecurringCalculatedPrice__c,vlocity_cmt__OneTimeLoyaltyPrice__c,SAP_ID__c,Description, ParentGroup__c, Group__c, Subgroup__c,OrderId, UnitPrice, TypeOfRequest__c, ProductCode__c, PlanGroup__c, Payment_Term__c, Discount_Type__c, Discount_Values__c,vlocity_cmt__OverageTotal__c FROM OrderItem WHERE OrderId = :orderId and Product2Id in (SELECT Id FROM Product2 WHERE (Family='Movel' AND vlocity_cmt__Type__c='Aparelhos') OR productCode = 'PME_SimCardAparelho_0001' OR productCode = 'PME_SimCardAvulso_0001')];        
        List<OrderItem> devices = new List<OrderItem>();
        Map<Id, List<OrderItem>> devicesGrouped = new Map<Id, List<OrderItem>>();
        List<OrderItem> scAparelhos = new List<OrderItem>(); //(reliesOn,OrderItem)
        List<OrderItem> scAvulsos = new List<OrderItem>();
        List<OrderItem> scToInsert = new List<OrderItem>();
        List<OrderItem> devicesToInsert = new List<OrderItem>();
        List<OrderItem> itemsToDelete = new List<OrderItem>();

        //grouping the simcards avulso, simcards aparelho and devices
        for (OrderItem orderItem : orderItems){
            if(orderItem.PricebookEntry.ProductCode == 'PME_SimCardAvulso_0001'){ //is SimcardAvulso
                scAvulsos.add(orderItem);
            }else if(orderItem.PricebookEntry.ProductCode == 'PME_SimCardAparelho_0001'){//is SimcardAparelho
                scAparelhos.add(orderItem);
            }else{//is Device
                devices.add(orderItem);
            }
        }

        //adding the items to be deleted at the end of the process
        itemsToDelete.addAll(scAvulsos);
        itemsToDelete.addAll(devices);
        itemsToDelete.addAll(scAparelhos);

        //spliting the simcards avulso if any
        if(scAvulsos.size() != 0){
            //split simcardAvulsos
            for(OrderItem simcardAvulsoGroup : scAvulsos){
                List<OrderItem> simcardAvulso = splitItem(simcardAvulsoGroup,null);
                scToInsert.addall(simcardAvulso);
            }
        }

        //spliting the devices if any
        if(devices.size() != 0){
            //plit devices
            for(OrderItem devicesGroup : devices){

                List<OrderItem> devAux = splitItem(devicesGroup,null);
                devicesToInsert.addall(devAux);
                devicesGrouped.put(devicesGroup.vlocity_cmt__AssetReferenceId__c, devAux);
            }

            //Saving and updating devices
            insert devicesToInsert;
            for (OrderItem dev : devicesToInsert){
                dev.vlocity_cmt__AssetReferenceId__c = dev.Id;
            }
            update devicesToInsert;

            //spliting the simcards aparelho if any
            if(scAparelhos.size() != 0){
                for(OrderItem simcardAparelhosGroup : scAparelhos){
                    List<Id> reliesOnList = getIdsList(devicesGrouped.get(simcardAparelhosGroup.ReliesOnReferenceId__c));
                    List<OrderItem> simcardAparelho = splitItem(simcardAparelhosGroup,reliesOnList);
                    scToInsert.addall(simcardAparelho);
                    
                }
            }
            

        }

        //Saving and updating the new simcards (aparelhos and avulsos)
        if (scToInsert.size() != 0){
            insert scToInsert;
            for (OrderItem sc : scToInsert){
                sc.vlocity_cmt__AssetReferenceId__c = sc.Id;
            }
            update scToInsert;    
        }
        

        //deletion of old simcards and devices
        if (itemsToDelete.size() != 0){
            delete itemsToDelete;   
        }

        

    



} 
   
   //Method used to split item into items 
    //if the listOfReliesOn is not null, it will take ReliesOn from the list and add it to the cloned elements
    private List<OrderItem> splitItem(OrderItem orderItem, List<Id> listOfReliesOn){

   


        Decimal quantity = orderItem.Quantity; 
        List<OrderItem> response = new List<OrderItem>();
        for(Integer i = 0; i < quantity ; i++){
            Id reliesOnVar;
            if (listOfReliesOn != null){ //logic for simcard aparelhos
                reliesOnVar = listOfReliesOn.get(0); 
                listOfReliesOn.remove(0);
            }else //logic for simcard avulso and devices
                reliesOnVar = orderItem.ReliesOnReferenceId__c;
            response.add(cloneItem(orderItem,reliesOnVar));   
        }
        return response;
    

    

}

    private OrderItem cloneItem(OrderItem groupItem, Id reliesOnVar){

   


        OrderItem orderItem = groupItem.clone(false, false, false, false);
        orderItem.ReliesOnReferenceId__c = reliesOnVar;
        setItemPrices(orderItem, 1.0,groupItem.vlocity_cmt__RecurringCalculatedPrice__c != null? groupItem.vlocity_cmt__RecurringCalculatedPrice__c :  groupItem.UnitPrice,groupItem.vlocity_cmt__OneTimeLoyaltyPrice__c != null? groupItem.vlocity_cmt__OneTimeLoyaltyPrice__c : 0 );
        return orderItem;
    

  

}

    private void setItemPrices(OrderItem orderItem, Decimal qtty, Decimal price, Decimal consumedPoints){

      


                    
            orderItem.Quantity= qtty;  // Amount 
            orderItem.vlocity_cmt__EffectiveQuantity__c= qtty;

            //unit Price
            orderItem.vlocity_cmt__RecurringCalculatedPrice__c=price;
            orderItem.vlocity_cmt__RecurringCharge__c=price;

            //total
            //item.put('TotalPrice', qtty*price);
            orderItem.vlocity_cmt__EffectiveRecurringTotal__c= qtty*price;
            orderItem.vlocity_cmt__RecurringTotal__c=qtty*price;

            //loyalty
            orderItem.vlocity_cmt__OneTimeLoyaltyPrice__c=consumedPoints;
            orderItem.vlocity_cmt__OneTimeLoyaltyTotal__c=consumedPoints*qtty;
            orderItem.vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c=consumedPoints*qtty;

      

    

}

      private List<Id> getIdsList(List<OrderItem> orderItems){

      


            List<Id> result = new List<Id>();

            for (OrderItem orderItem : orderItems){
                result.add(orderItem.vlocity_cmt__AssetReferenceId__c);
            }
            return result;
      



}


 

}