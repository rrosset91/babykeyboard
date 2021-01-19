global with sharing class CustomPricingPlanStepImpl implements vlocity_cmt.VlocityOpenInterface {
	String inputType = ''; 
    
    global Boolean invokeMethod (String methodName,
                                 Map<String, Object> input,
                                 Map<String, Object> output,
                                 Map<String, Object> options)
    {
        if (methodName == 'GetMatrixPrice')
        {
            System.debug('Inside GetMatrixPrice');
            getMatrixPrice(input, output, options);
        }
        
        if (methodName == 'GetMatrixPricePlansPME')
        {	
            inputType = 'plans';
            getMatrixPricePME(input, output, options);
        }
        
        if (methodName == 'GetMatrixPriceDevicePME')
        {
            inputType = 'device';
            getMatrixPricePME(input, output, options);
        }

        return true;
    }

    private void getMatrixPrice(Map<String, Object> input,
                                Map<String, Object> output,
                                Map<String, Object> options)
    {
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        List<SObject> itemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');

        // Do nothing if there are no items
        if (itemList == null || itemList.isEmpty()) return;

        // If this is the first getMatrixPrice step, clear the external price flag
        Boolean clearExternalPriceFlag = (Boolean)vlocity_cmt.PricingPlanService.getFromPricingContext('ClearExternalPriceFlag');
        System.debug('ClearExternalPriceFlag: ' + clearExternalPriceFlag);
        if (clearExternalPriceFlag == null)
        {
            clearExternalPriceFlag = true;
            // Do not clear the external price flag for subsequent calls to getMatrixPrice
            vlocity_cmt.PricingPlanService.putInPricingContext('ClearExternalPriceFlag', false);
        }

        Map<String, object> priceHelperInput = new Map<String, object>();
        Map<String, object> priceHelperOutput = new Map<String, object>();
        Map<String, object> priceHelperOptions = new Map<String, object>();
        priceHelperInput.put('Parent', parent);
        priceHelperInput.put('ItemList', itemList);
        priceHelperInput.put('ClearExternalPriceFlag', clearExternalPriceFlag);
        priceHelperInput.putAll(input);

        // create the matrix input rows from the itemList
        PricingPlanHelper priceHelper = new PricingPlanHelper();
        priceHelper.invokeMethod('GetCalculationProcedurePrice', priceHelperInput, priceHelperOutput, priceHelperOptions);

        if (priceHelperOutput.get('error') != null)
        {
            output.put('error', priceHelperOutput.get('error'));
        }
    }
    
    /*
	* Autor: Marcos Aurélio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
	Método responsável por criar a lista de inputs utilizada pela calculation matrix
	Mapeamento dos planos
	*/
    private List<Object> getPlansInput(Map<String, Object> input, List<sObject> itemList, Map<String, String> mapPrdIdPrdCode,
                                      Map<String, String> mapAssetRefPrdCode){
        List<Object> matrixInput = new List<Object>();
        for(sObject item : itemList){
            map<String,Object> matrixRow = new map<String,Object>();
            
            matrixRow.put('Product Code', mapPrdIdPrdCode.get((String)item.get('Id')));
            matrixRow.put('Root Product Code', mapAssetRefPrdCode.get((String)item.get('ReliesOnReferenceId__c')));        
            matrixRow.put('ID',(String)item.Id);
            matrixInput.add(matrixRow);
		}
        return matrixInput;
    }
    /*
	* Autor: Marcos Aurélio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
	Método responsável por criar a lista de inputs utilizada pela calculation matrix
	Mapeamento dos aparelhos
	*/

    private List<Object> getDeviceInput(Map<String, Object> input, List<sObject> itemList, Map<String, String> mapPrdIdPrdCode){
        List<Object> matrixInput = new List<Object>();
        for(sObject item : itemList){
            map<String,Object> matrixRow = new map<String,Object>();
            
            matrixRow.put('Device_Code', mapPrdIdPrdCode.get((String)item.get('Id')));
            matrixRow.put('Payment_Method', input.get('Payment_Method'));
            matrixRow.put('Price_Type', input.get('Price_Type'));
            matrixRow.put('User_Type', input.get('User_Type'));
            matrixRow.put('Plan_Code', input.get('Plan_Code'));
            matrixRow.put('TradeIn', input.get('TradeIn'));
            matrixRow.put('ID',(String)item.get('Id'));
            matrixInput.add(matrixRow);
         }
        
        return matrixInput;
    }
    /*
	* Autor: Marcos Aurélio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
	Método responsável por obter os resultados da matriz de cálculo e alterar o valor no carrinho da oportunidade.
	*/    
    private void getMatrixPricePME(Map<String, Object> input,
                                Map<String, Object> output,
                                Map<String, Object> options){
        System.debug('INSIDE getMatrixPricePME');
        System.debug('Input: ' + input);
        System.debug('Output: ' + output);
        System.debug('Options: ' + options);
                                   
        Set<String> setLineItemId = new Set<String>();
        Map<String, String> mapPrdIdPrdCode = new Map<String,String>();
        Map<String, String> mapAssetRefPrdCode = new Map<String,String>();
        String RecordType = '';                            
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
		
        List<Object> matrixInput;
        Map<String, String> varCodeToFieldMap;
        
        List<SObject> sObjectItemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');                                    
        
        for(SObject obj : sObjectItemList){
            RecordType = getObjectNameByChildPrefix(obj.get('Id'));
            break;
        }
                                    
        if (RecordType == 'Opportunity') {
            List<OpportunityLineItem> itemList = (List<OpportunityLineItem>)sObjectItemList;
            System.Debug('parent: ' + parent);
            System.Debug('itemList: ' + itemList);
                                        
            for(OpportunityLineItem item : itemList){
                setLineItemId.add(item.Id);
            }
            
            //)vlocity_cmt.PricingPlanService.getFromPricingContext não retorna todos os campos necessários para execução
            //da lógica de matriz de preço. Criado o lstOppLi para obter os demais campos.
            String oppId = '';
            List<OpportunityLineItem> lstOppLi = [SELECT Id, OpportunityId, ProductCode, ReliesOnReferenceId__c, vlocity_cmt__AssetReferenceId__c	FROM OpportunityLineItem Where Id =: setLineItemId];
            for(OpportunityLineItem item : lstOppLi){
                oppId = item.OpportunityId;
                mapPrdIdPrdCode.put(item.Id, item.ProductCode);
                mapAssetRefPrdCode.put(item.vlocity_cmt__AssetReferenceId__c, item.ProductCode);
            }
            /*Devido a uma particularidade do catalogo do vlocity, é necessário verificar se a chamada
             * foi realizada a partir da oportunidade do PME. Caso não seja do PME, não realizar o cálculo
            */
            Opportunity opp = [Select Id, vlocity_cmt__PriceListId__c FROM Opportunity WHERE Id =: oppId];
            if(opp.vlocity_cmt__PriceListId__c <> getPriceListId('Price_List_PME')){return;}
            
            if('plans'.equals(inputType)){
                matrixInput = getPlansInput(input, lstOppLi, mapPrdIdPrdCode, mapAssetRefPrdCode);   
                varCodeToFieldMap = new Map<String, String>{
                        'PMEVASPricingMatrix__MRC'=>'vlocity_cmt__RecurringCharge__c',
                        'PMEVASPricingMatrix__NRC'=>'vlocity_cmt__OneTimeCharge__c',
                        'PMEVASPricingMatrix__OTL'=>'vlocity_cmt__OneTimeLoyaltyPrice__c'
                }; 
                    
            } else if('device'.equals(inputType)){
                matrixInput = getDeviceInput(input, lstOppLi, mapPrdIdPrdCode);   
                varCodeToFieldMap = new Map<String, String>{
                        'DevicePricing-PMEAll__MRC'=>'vlocity_cmt__RecurringCharge__c',
                        'DevicePricing-PMEAll__NRC'=>'vlocity_cmt__OneTimeCharge__c',
                        'DevicePricing-PMEAll__OTL'=>'vlocity_cmt__OneTimeLoyaltyPrice__c'
                };
            }
        } else if(RecordType == 'Order') {
            List<OrderItem> itemList = (List<OrderItem>)sObjectItemList;
            System.Debug('parent: ' + parent);
            System.Debug('itemList: ' + itemList);
                                        
            for(OrderItem item : itemList){
                setLineItemId.add(item.Id);
            }
            
            //)vlocity_cmt.PricingPlanService.getFromPricingContext não retorna todos os campos necessários para execução
            //da lógica de matriz de preço. Criado o lstOppLi para obter os demais campos.
            String orderId = '';
            List<OrderItem> lstOrderLi = [SELECT Id, OrderId, Product2.ProductCode, ReliesOnReferenceId__c, vlocity_cmt__AssetReferenceId__c FROM OrderItem Where Id =: setLineItemId];
            for(OrderItem item : lstOrderLi){
                orderId = item.OrderId;
                mapPrdIdPrdCode.put(item.Id, item.Product2.ProductCode);
                mapAssetRefPrdCode.put(item.vlocity_cmt__AssetReferenceId__c, item.Product2.ProductCode);
            }
            
            System.Debug('Map Order Id: ' + mapPrdIdPrdCode);
            /*Devido a uma particularidade do catalogo do vlocity, é necessário verificar se a chamada
             * foi realizada a partir da oportunidade do PME. Caso não seja do PME, não realizar o cálculo
            */
            Order ord = [Select Id, vlocity_cmt__PriceListId__c FROM Order WHERE Id =: orderId];
            if(ord.vlocity_cmt__PriceListId__c <> getPriceListId('Price_List_PME')){return;}
            if('plans'.equals(inputType)){
                matrixInput = getPlansInput(input, lstOrderLi, mapPrdIdPrdCode, mapAssetRefPrdCode);   
                varCodeToFieldMap = new Map<String, String>{
                        'PMEVASPricingMatrix__MRC'=>'vlocity_cmt__RecurringCharge__c',
                        'PMEVASPricingMatrix__NRC'=>'vlocity_cmt__OneTimeCharge__c',
                        'PMEVASPricingMatrix__OTL'=>'vlocity_cmt__OneTimeLoyaltyPrice__c'
                }; 
                    
            } else if('device'.equals(inputType)){
                matrixInput = getDeviceInput(input, lstOrderLi, mapPrdIdPrdCode);   
                varCodeToFieldMap = new Map<String, String>{
                        'DevicePricing-PMEAll__MRC'=>'vlocity_cmt__RecurringCharge__c',
                        'DevicePricing-PMEAll__NRC'=>'vlocity_cmt__OneTimeCharge__c',
                        'DevicePricing-PMEAll__OTL'=>'vlocity_cmt__OneTimeLoyaltyPrice__c'
                };
            }
        } else {
            return;
        }
        
        System.Debug(matrixInput);

        List<Object> matrixResults = invokeCalculationProcedure((String)input.get('Procedure Name'),matrixInput);
                                    
        System.Debug('matrixResults: ' + matrixResults);
                                    
        Map<String, object> extSvcInput = new Map<String, object>();
        Map<String, object> extSvcOutput = new Map<String, object>();
        Map<String, object> extSvcOptions = new Map<String, object>();
        
        extSvcInput.put('parent', parent);
        extSvcInput.put('itemList', sObjectItemList);
        extSvcInput.put('externalPriceData', matrixResults);
        extSvcInput.put('pricingVariableToFieldMap', varCodeToFieldMap);
        if(matrixResults != null)
            setExternalPrice(extSvcInput, extSvcOutput, extSvcOptions);                            
    }
    
    /*
	* Autor: Marcos Aurélio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
	Método copiado da classe PricingPlanHelper.
	Contém a lógica necessária para fazer a chamada na API do vlocity responsável por encontrar o valor correspondente da matriz.
	*/
    public List<Object> invokeCalculationProcedure (String procedureName, List<Object> rowData)
    {
        try {
            Type t = Type.forName('vlocity_cmt.PricingMatrixCalculationService');
            vlocity_cmt.VlocityOpenInterface matrixService = (vlocity_cmt.VlocityOpenInterface)t.newInstance();

            Map<String, Object> inputMap = new Map<String, Object>{
            'inputData' => rowData
            };

            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> optionsMap = new Map<String, Object>{
            'configurationName' => procedureName,
            'inputKey' => 'inputData',
            'mode' => null,
            'verbose' => true,
            'matchInputVariables' => true,
            'effectiveDate' => String.valueOf(System.Now()),
            'configurationVersionId' => null
            };

            System.debug('before inputMap: ' + inputMap);
            System.debug('before outputMap: ' + outputMap);
            System.debug('before optionsMap: ' + optionsMap);    

            matrixService.invokeMethod('calculate', inputMap, outputMap, optionsMap);
            
            System.debug('INSIDE invokeCalculationProcedure');
            System.debug('after inputMap: ' + inputMap);
            System.debug('after outputMap: ' + outputMap);
            System.debug('after optionsMap: ' + optionsMap);    
            List<Object> outList = (List<Object>)outputMap.get('output');
            List<Object> objectList;
            if (outList != null && !outList.isEmpty()) {
                vlocity_cmt.PricingCalculationService.CalculationProcedureResults calcProcResults =
                    (vlocity_cmt.PricingCalculationService.CalculationProcedureResults)outList[0];
                objectList = calcProcResults.calculationResults;
                
            }
            return objectList;
        } finally {
     
        }
    }
    
    private void setExternalPrice(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        Map<String, Object> itemFields = new Map<String, Object>();
        SObject parent = (SObject)input.get('parent');
        List<SObject> itemList = (List<SObject>)input.get('itemList');
        List<Object> extPriceData = (List<Object>)input.get('externalPriceData');
        Map<String, String> fieldMap = (Map<String, String>)input.get('pricingVariableToFieldMap');
        String message = (String)input.get('priceDetailMessage');

        for (Object obj : extPriceData)
        {
            if (obj instanceOf Map<String, Object>)
            {
                Map<String, Object> matrixResultRow = (Map<String, Object>)obj;
                Map<String, Object> itemFieldDetails = new Map<String, Object>();
                for (String fld : fieldMap.keySet())
                {
                    String itemField = fieldMap.get(fld);
                    Map<String, Object> fieldVals = new Map<String, Object>();
                    fieldVals.put('value', matrixResultRow.get(fld));
                    fieldVals.put('detail', message);
                    itemFieldDetails.put(itemField, fieldVals);
                }
                itemFields.put(String.valueOf(matrixResultRow.get('ID')), itemFieldDetails);
                
            }
        }
		System.debug('itemFields' + itemFields);
        if (!itemFields.isEmpty())
        {
            Type t = Type.forName('vlocity_cmt.SetCartItemExternalPriceService');
            if (t != null)
            {
                vlocity_cmt.VlocityOpenInterface externalPriceService =
                    (vlocity_cmt.VlocityOpenInterface)t.newInstance();
                Map<String, Object> externalPriceServiceInput = new Map<String, Object>();
                Map<String, Object> externalPriceServiceOutput = new Map<String, Object>();
                Map<String, Object> externalPriceServiceOptions = new Map<String, Object>();

                if (!itemFields.isEmpty())
                {
                    externalPriceServiceInput.put('parent', parent);
                    externalPriceServiceInput.put('itemList', itemList);
                    externalPriceServiceInput.put('itemFieldsInfo', itemFields);
                    // skip update to prevent this service from flushing to the database since the pricing plan service
                    // will update the itemList anyway, this saves one DML update
                    externalPriceServiceOptions.put('SkipUpdate', true);
                    externalPriceService.invokeMethod('setItemPrices', externalPriceServiceInput,
                        externalPriceServiceOutput, externalPriceServiceOptions);
                }
            }
        }
    }
    
    private String getPriceListId(String vlocityCode){
        String retorno = '';
        for(vlocity_cmt__PriceList__c priceList: [SELECT Id FROM vlocity_cmt__PriceList__c WHERE vlocity_cmt__Code__c =:vlocityCode]){
            retorno = priceList.Id;
        }
        return retorno;
    }
    
    private String getObjectNameByChildPrefix(Object id){
        String strId = (String)id;
        //802 Order Item
        if(strId.mid(0,3) == '802'){
            return 'Order';
        }
        
        //00k Opportunity Item
        if(strId.mid(0,3) == '00k'){
            return 'Opportunity';
        }
		
        return '';
    }
}