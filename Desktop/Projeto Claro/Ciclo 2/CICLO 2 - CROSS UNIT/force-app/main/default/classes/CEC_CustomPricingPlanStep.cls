global with sharing class CEC_CustomPricingPlanStep implements vlocity_cmt.VlocityOpenInterface {
    String inputType = '';
    static Map<String, String> mapRowProduct = new Map<String,String>();
    static Map<String, Decimal> mapItemAdjustment = new Map<String,Decimal>();
    static Map<String, OrderItem> mapIdAndItem = new Map<String,OrderItem>();
    static String cartState = '';
    static Map<String, String> varCodeToFieldMap;
    global static boolean pricingPlan ;
    
    global Boolean invokeMethod (String methodName,
                                 Map<String, Object> input,
                                 Map<String, Object> output,
                                 Map<String, Object> options)
    {
        if (methodName == 'GetMatrixPriceComercial')
        {       
            getMatrixPriceComercial(input, output, options);
        }
        if (methodName == 'setOneTimeChargeToZero')
        {       
            setOneTimeChargeToZero(input, output, options);
        }       
        if (methodName.equalsIgnoreCase('getOptionalProducts'))
        {
            return getOptionalProducts(input, output, options);
        }
        if (methodName == 'getPromotion') // Preencher a lista de promoções - manda pra tela
        {
            getPromotion(input, output, options);
        }
        if (methodName == 'GetCartState')
        {
            getCartState(input, output, options);
        }
        if (methodName == 'SetMemberFeePricingPlan')
        {
            setMemberFeePricingPlan(input, output, options);
        }
        if (methodName == 'SetPaymentAdjust')
        {
            setPaymentAdjust(input, output, options);
        }
        if (methodName == 'SetPromotionAdjust')
        {
            setPromotionAdjust(input, output, options);
        }
        if (methodName == 'getProducts') // Preencher a prateleira - manda pra tela
        {
            getProducts(input, output, options);
        }
        if (methodName == 'getBonus')
        {
            getBonus(input, output, options);
        }
        if (methodName == 'SetFidelity')
        {
            setFidelityItems(input, output, options);
        }
		if (methodName == 'notSellProducts')
        {
            notSellProducts(input, output, options);
        }
        if (methodName == 'getDependentEmbeddedProducts') // Preencher produtos embutidos de dependentes - manda pra tela
        {
            getDependentEmbeddedProducts(input, output, options);
        }
        if (methodName == 'setDiscountPricing')
        {           
            setDiscountPricing(input, output, options);
        }
        return true;
    }
    
/*
* Autor: Henrique Almeida - Deloitte
* Data: 21-mar-2018
* Descrição: Método responsável por obter os resultados da matriz de cálculo e alterar o valor no carrinho da order.
*/    
    private void getMatrixPriceComercial(Map<String, Object> input,Map<String, Object> output,Map<String, Object> options)
    {
        List<vlocity_cmt__PricingVariable__c> priceVariables = [select Id, vlocity_cmt__Code__c, Name from vlocity_cmt__PricingVariable__c where vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC' OR  vlocity_cmt__Code__c =  'OT_STD_PRC' OR vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC_ADJ_ABS'];
        vlocity_cmt.PricingPlanService.putInPricingContext('priceVariables', priceVariables);
        
        String RecordType = '';                            
        Set<String> setLineItemId = new Set<String>();
        Map<String, Boolean> mapFamilyBoolean = new Map<String, Boolean>();

        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');        
        List<SObject> sObjectItemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');

        input.put('cartId', parent.get('Id'));
        input.put('OrderId', parent.get('Id'));
        
        for(SObject obj : sObjectItemList){
            RecordType = getObjectNameByChildPrefix(obj.get('Id'));
            break;
        }
        if (RecordType != 'OrderItem'){return;}
                
        List<OrderItem> itemList = (List<OrderItem>)sObjectItemList;
        for(OrderItem item : itemList)
        {
            setLineItemId.add(item.Id);
        }
        
        List<OrderItem> lstOrderLi = [SELECT Id, Product2.ProductCode, Fidelidade__c, Order.Unidade__c, Order.vlocity_cmt__PriceListId__r.Name, (Select Id from vlocity_cmt__OrderPricingAdjustments__r), Order.Cart_State__c, Order.TipoFatura__c, Acrescimo_Desconto__c, Product2.vlocity_cmt__SubType__c, Product2.vlocity_cmt__Type__c, Grupo__c, Meses_de_Fidelidade__c, DDD__c, Product2.Name, Product2.Family, Order.Forma_de_Pagamento__c, vlocity_cmt__RecurringCharge__c, ReliesOnReferenceId__c, vlocity_cmt__AssetReferenceId__c 
                                      FROM OrderItem 
                                      Where Id =: setLineItemId];
        
        if(lstOrderLi[0].Order.vlocity_cmt__PriceListId__r.Name != 'Comercial Residencial'){return;}
        
        String fluxo = lstOrderLi[0].Order.Unidade__c;
        String formaDePagamento = '';
        Map<String, String> mapIdAndSubType = new Map<String,String>();
        Map<String, String> mapIdAndFamily = new Map<String,String>();
        Map<String, String> mapIdAndFormaEnvio = new Map<String,String>();
        
        for(OrderItem item : lstOrderLi)
        {
            mapIdAndSubType.put((String)item.Id, item.Product2.vlocity_cmt__SubType__c == null ? 'None' : item.Product2.vlocity_cmt__SubType__c);
            mapIdAndFamily.put((String)item.Id, item.Product2.Family);
            mapIdAndFormaEnvio.put((String)item.Id, item.Order.TipoFatura__c);
            formaDePagamento = item.Order.Forma_de_Pagamento__c;
            cartState = (String)vlocity_cmt.PricingPlanService.getFromPricingContext('CartState');
        }
        List<Object> matrixInput = getProductsInput(lstOrderLi);
        List<Object> matrixResults = invokeCalculationProcedure(matrixInput, fluxo);
        
        Map<String, object> extSvcInput = new Map<String, object>();
        Map<String, object> extSvcOutput = new Map<String, object>();
        Map<String, object> extSvcOptions = new Map<String, object>();
        
        List<MetodoPagamento__c> lstMtdPagamentos = [SELECT Id, Name, Sub_Type__c, Forma_de_Pagamento__c, TipoFatura__c, Family__c, Preco__c FROM MetodoPagamento__c WHERE Forma_de_Pagamento__c = :formaDePagamento];
        for(OrderItem item : itemList)
        {
            for(MetodoPagamento__c mtdPag : lstMtdPagamentos)
            {
                String subtype = mapIdAndSubType.get(item.Id);
                String family = mapIdAndFamily.get(item.Id);
                String formaEnvio = mapIdAndFormaEnvio.get(item.Id);
                
                if(mtdPag.Sub_Type__c == subtype && mtdPag.Family__c == family && mtdPag.TipoFatura__c == formaEnvio) 
                {
                    item.Acrescimo_Desconto__c = mtdPag.Preco__c;
                    mapItemAdjustment.put(item.Id, item.Acrescimo_Desconto__c);
                }
            }
        }
        
        vlocity_cmt.PricingPlanService.putInPricingContext('adjustments', mapItemAdjustment);
        extSvcInput.put('parent', parent);
        extSvcInput.put('itemList', sObjectItemList);
        extSvcInput.put('itemListAux', lstOrderLi);
        extSvcInput.put('externalPriceData', matrixResults);
        extSvcInput.put('pricingVariableToFieldMap', varCodeToFieldMap);
        extSvcInput.put('formaDePagamento', formaDePagamento);
        extSvcOutput.put('productsInCart', mapFamilyBoolean);
        
        if(matrixResults != null)
        {
            setExternalPrice(extSvcInput, extSvcOutput, extSvcOptions); 
        }                          
    }

    /*
* Autor: Henrique Almeida - Deloitte
* Data: 21-mar-2018
* Descrição: Método responsável por criar a lista de inputs utilizada pela calculation matrix Mapeamento dos produtos do comercial
*/
    private List<Object> getProductsInput(List<OrderItem> itemList)
    {
        Set<String> lstPlanos = new Set<String>();
        for(OrderItem item : itemList)
        {
            lstPlanos.add(item.Product2.Family);
        }
        List<Object> matrixInput = new List<Object>();
        Map<Id, Decimal> mapItemsFidelity = (Map<Id, Decimal>)vlocity_cmt.PricingPlanService.getFromPricingContext('ItemsFidelity');
        for(OrderItem item : itemList)
        {
            if(item.Product2.vlocity_cmt__Type__c == 'Plano' || item.Product2.vlocity_cmt__Type__c == 'Ponto Opcional' || item.Product2.vlocity_cmt__Type__c == 'Dependente')
            {
                map<String,Object> matrixRow = new map<String,Object>();
                matrixRow.put('COD_PROID', item.Product2Id);
                matrixRow.put('GRUPO_CIDADE', item.Grupo__c == null ? '-' : item.Grupo__c);
                matrixRow.put('FIDELIDADE', String.valueOf(mapItemsFidelity.get(item.Id)));
                matrixRow.put('MODALIDADE', cartState);
                matrixRow.put('DDD', '-');
                matrixInput.add(matrixRow);
            }
        }
        return matrixInput;
    }
    
    public static boolean vlocityAdjustment (Map<String, Object> input, Map<String, Object> output, Map<String, Object> options, Object itemId, Decimal ajuste)
    {
        List<Object> adjustments = new List<Object>();
        Map<String, Object> adj = new Map<String, Object>();           
        Map<String, Object> inputNew = new Map<String, Object>();
        
        adj.put('AdjustmentValue', ajuste);
        adj.put('AdjustmentMethod', 'Absolute');
        adj.put('DetailType', 'OVERRIDE');
        adj.put('AdjustmentType', 'Override');    //Added by VL on 08/20
        adj.put('PricingVariableCode', 'OT_STD_PRC');
        adj.put('Field', 'vlocity_cmt__OneTimeCharge__c');
        adjustments.add(adj);
        inputNew.put('price', false);
        inputNew.put('validate', false);
        
        vlocity_cmt.CpqAppHandler cpqAppHandlerService = new vlocity_cmt.CpqAppHandler();
        
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        String cartId = (String)parent.get('Id');   
        
        String itemIdString = String.valueOf(itemId);
        inputNew.put('id', itemIdString);
        inputNew.put('cartId',cartId); 
        inputNew.put('adjustments', adjustments);
        
        cpqAppHandlerService.invokeMethod('applyAdjustment', inputNew, output, options);
                                                                    
        return true;
    }
    /*
* Autor: Henrique Almeida - Deloitte
* Data: 21-mar-2018
* Descrição: Método personalizado para calcular o preço de acordo com nova matriz.
*/
     public List<Object> invokeCalculationProcedure (List<Object> rowData, String fluxo)
    {
        Set<String> setProductId  = new Set<String>();
        Set<String> setGroup        = new Set<String>();
        Set<Integer> setFidelity    = new Set<Integer>();
        Set<String> setDDD          = new Set<String>();
        
        for(Integer i = 0; i < rowData.size(); i++)
        {
            map<String,Object> obj = (map<String,Object>) rowData[i];
            setProductId.add((String)obj.get('COD_PROID'));
            setGroup.add((String)obj.get('GRUPO_CIDADE'));
            setFidelity.add(Integer.valueOf(obj.get('FIDELIDADE')));
            setDDD.add((String)obj.get('DDD'));
        }
       
        List<Pricing_Matrix__c> lstRows = [SELECT Id, PricingValue__c, Multa_Desc__c, Duration__c, Group__c, Source_Product_Code__c, Source_Product__r.Family, Source_Product__r.ProductCode, Source_Product__r.vlocity_cmt__Type__c, Pricing_Var_Code__c, Pricing_Var_Binding_Field__c, Pricing_Variable_Code__c
                                           FROM Pricing_Matrix__c
                                           WHERE Source_Product__c IN :setProductId
                                           AND Group__c IN :setGroup
                                           AND Duration__c IN :setFidelity
                                           AND DDD__c IN :setDDD
                                           AND Modalidade__c = :cartState
                                           AND ((End_Date__c = null AND Start_Date__c <= TODAY) OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY))
                                           AND RecordType.developerName = 'Pricing'
                                           ORDER BY Duration__c DESC];
        
        
        List<Pricing_Matrix__c> residentialRows = new List<Pricing_Matrix__c>(); 
        List<Pricing_Matrix__c> movelRows = new List<Pricing_Matrix__c>();
        List<Object> matrixResults = new List<Object>();
        
        for(Pricing_Matrix__c row : lstRows)
        {
            mapRowProduct.put(row.id, row.Source_Product_Code__c);
            matrixResults.add(row);
            
            varCodeToFieldMap = new Map<String, String>{'PricingValue__c' => row.Pricing_Var_Binding_Field__c}; 
        }

        return matrixResults;
    }
    
    private void setExternalPrice(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        Map<String, Object> itemFields = new Map<String, Object>();
        SObject parent = (SObject)input.get('parent');
        List<SObject> itemList = (List<SObject>)input.get('itemList');
        List<OrderItem> itemListAux = (List<OrderItem>)input.get('itemListAux');
        List<Object> extPriceData = (List<Object>)input.get('externalPriceData');
        Map<String, Boolean> mapFamilyBoolean = (Map<String, Boolean>)output.get('productsInCart');
        Map<String, String> fieldMap = (Map<String, String>)input.get('pricingVariableToFieldMap');
        String message = (String)input.get('priceDetailMessage');
        for (Object obj : extPriceData) 
        {
            Pricing_Matrix__c matrixResultRow = (Pricing_Matrix__c)obj;
            Map<String, Object> itemFieldDetails = new Map<String, Object>();
            for (String fld : fieldMap.keySet())
            {
                String itemField = matrixResultRow.Pricing_Var_Binding_Field__c;
                Map<String, Object> fieldVals = new Map<String, Object>();
                Decimal total = (Decimal)matrixResultRow.get(fld);
                fieldVals.put('value', total);
                fieldVals.put('detail', message);
                fieldVals.put('multa', matrixResultRow.Multa_Desc__c);
                itemFieldDetails.put(itemField, fieldVals);
            }
            Map<Id, Decimal> mapItemsFidelity = (Map<Id, Decimal>)vlocity_cmt.PricingPlanService.getFromPricingContext('ItemsFidelity');
            for(OrderItem item : itemListAux)
            {
                if((item.Product2.vlocity_cmt__Type__c == 'Ponto Opcional' || item.Product2.vlocity_cmt__Type__c == 'Plano' || item.Product2.vlocity_cmt__Type__c == 'Dependente'  || item.Product2.vlocity_cmt__Type__c == 'Serviço Adicional') && item.Grupo__c == matrixResultRow.Group__c)
                {  
                    if(item.Product2Id == matrixResultRow.Source_Product__c && mapItemsFidelity.get(item.Id) == matrixResultRow.Duration__c)
                    {
                        if(!itemFields.containsKey(item.Id))
                        {
                            itemFields.put(item.Id, itemFieldDetails);
                        }
                    }
                }
            }
        }
        if (!itemFields.isEmpty())
        {
            List<OrderItem> sObjectItemList = (List<OrderItem>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
            for(OrderItem item : sObjectItemList)
            {
                for(String itemField : itemFields.keyset())
                {
                    if(item.Id == itemField)
                    {
                        Map<String, Object> details = (Map<String, Object>)itemFields.get(item.Id);
                        Map<String, Object> objecto = (Map<String, Object>)details.get('vlocity_cmt__RecurringCharge__c');
                        item.DescricaoMulta__c = (String)objecto.get('multa');
                    }
                }
            }

            Type t = Type.forName('vlocity_cmt.SetCartItemExternalPriceService');
            if (t != null)
            {
                vlocity_cmt.VlocityOpenInterface externalPriceService =
                    (vlocity_cmt.VlocityOpenInterface)t.newInstance();
                Map<String, Object> externalPriceServiceInput = new Map<String, Object>();
                Map<String, Object> externalPriceServiceOutput = new Map<String, Object>();
                Map<String, Object> externalPriceServiceOptions = new Map<String, Object>();
                externalPriceServiceOutput.put('productsInCart', mapFamilyBoolean);
                
                if (!itemFields.isEmpty())
                {
                    externalPriceServiceInput.put('parent', parent);
                    externalPriceServiceInput.put('itemList', itemList);
                    externalPriceServiceInput.put('itemFieldsInfo', itemFields);
                    externalPriceServiceOptions.put('SkipUpdate', true);
                    
                    
                    if(!Test.isRunningTest())
                    {
                        externalPriceService.invokeMethod('setItemPrices', externalPriceServiceInput, externalPriceServiceOutput, externalPriceServiceOptions);
                    }
                }
            }
        }
    }
    private String getObjectNameByChildPrefix(Object id)
    {
        Id objectId = (String)id;
        return objectId.getSObjectType().getDescribe().getName();
    }
    /*
* Autor: Henrique Almeida - Deloitte
* Data: 06-ago-2019
* Descrição: Método que retorna promoções aplicáveis ao carrinho.
*/
  public static Boolean getPromotion(Map<String, Object> input,Map<String, Object> output,Map<String, Object> options) {
        
      String cartId = (String)input.get('cartId');
      
        List<OrderItem> lstOrderLi = [SELECT Id, Order.Cart_State__c, DescricaoPromocao__c, vlocity_cmt__RecurringTotal__c, Promotion_Log__c, (Select Id, vlocity_cmt__Amount__c from vlocity_cmt__OrderPricingAdjustments__r WHERE vlocity_cmt__Amount__c != null), Product2.ProductCode, Quantity, Product2.vlocity_cmt__Type__c, Acrescimo_Desconto__c, Product2.vlocity_cmt__SubType__c, Grupo__c, Meses_de_Fidelidade__c, DDD__c, Product2.Name, Product2.Family, Order.Forma_de_Pagamento__c, Order.TipoFatura__c, vlocity_cmt__RecurringCharge__c, ReliesOnReferenceId__c, vlocity_cmt__AssetReferenceId__c
                                      FROM OrderItem
                                      Where OrderId = :cartId AND (Product2.vlocity_cmt__Type__c = 'Plano' OR 
                                                                   Product2.vlocity_cmt__Type__c = 'A la carte' OR 
                                                                   Product2.vlocity_cmt__ObjectTypeId__r.name != 'Produtos Opcionais' OR
                                                                   Product2.vlocity_cmt__Type__c = 'Ponto Opcional' OR Product2.vlocity_cmt__Type__c = 'Dependente' OR Product2.vlocity_cmt__Type__c = 'Serviço') ORDER BY Product2.Family ASC];
                    
        String cartState = lstOrderLi[0].Order.Cart_State__c;
        String tvClause;
        String internetClause;
        String movelClause;
        String foneClause;
        Set<Id> setTarget = new Set<Id>();
        Set<String> setGroups = new Set<String>();
        Set<String> setOptionalProducts = new Set<String>();
        setGroups.add('-');
        String formadePagamentoOrder = lstOrderLi[0].Order.Forma_de_Pagamento__c;
		String formadeEnvio = lstOrderLi[0].Order.TipoFatura__c;
        for (orderItem item : lstOrderLi) 
        {
            setTarget.add(item.Product2Id);
            setGroups.add(item.Grupo__c);
            if(item.Product2.vlocity_cmt__Type__c == 'Plano')
            {
                if(item.Product2.Family == 'TV')
                {
                    tvClause = item.Product2Id;
                }
                else if(item.Product2.Family == 'Internet Fixa')
                {
                    internetClause = item.Product2Id;
                }
                else if(item.Product2.Family == 'Fone')
                {
                    foneClause = item.Product2Id;
                }
                else if(item.Product2.Family == 'Movel')
                {
                    movelClause = item.Product2Id;
                }

            } else {
                setOptionalProducts.add(item.Product2.ProductCode);
            }
        }
      
        // US 95498 - Aplicar desconto no plano principal/adicional de forma automática
        List<Pricing_Matrix__c> listPromotions = new List<Pricing_Matrix__c>();
        if(!setOptionalProducts.isEmpty()){
            listPromotions = [SELECT Id, Cart_State__c, Produto_Opcional__r.ProductCode, Forma_de_Pagamento__c, TipoFatura__c , Modalidade__c, Codigo_Promocao__c, To_Quantity__c, PricingValue__c, From_Quantity__c, Target_Product__c, Single__c, Internet__c, Mobile__c, Phone__c, TV__c, Promotion__c, Double__c, Triple__c, Combo_Multi__c, Group__c, Description__c, Type__c, Pricing_Var_Binding_Field__c, Pricing_Variable_Code__c 
                                FROM Pricing_Matrix__c 
                                WHERE RecordType.DeveloperName = 'Promotion'
                                AND Group__c IN :setGroups
                                AND Target_Product__c IN :setTarget 
                                AND Target_Product__r.vlocity_cmt__ObjectTypeId__r.name != 'Produtos Opcionais'  
                                AND Produto_Opcional__r.ProductCode IN :setOptionalProducts
                                AND ((End_Date__c = null AND Start_Date__c <= TODAY) OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY))
                                AND Modalidade__c = :cartState];
        }

        if(listPromotions.isEmpty()){
            listPromotions = [SELECT Id, Cart_State__c, Produto_Opcional__r.ProductCode, Forma_de_Pagamento__c, TipoFatura__c , Modalidade__c, Codigo_Promocao__c, To_Quantity__c, PricingValue__c, From_Quantity__c, Target_Product__c, Single__c, Internet__c, Mobile__c, Phone__c, TV__c, Promotion__c, Double__c, Triple__c, Combo_Multi__c, Group__c, Description__c, Type__c, Pricing_Var_Binding_Field__c, Pricing_Variable_Code__c 
                                                  FROM Pricing_Matrix__c 
                                                  WHERE RecordType.DeveloperName = 'Promotion'
                                                  AND Group__c IN :setGroups
                                                  AND Target_Product__c IN :setTarget 
                                AND Target_Product__r.vlocity_cmt__ObjectTypeId__r.name != 'Produtos Opcionais'  
                                AND Produto_Opcional__c = null
                                                  AND ((End_Date__c = null AND Start_Date__c <= TODAY) OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY))
                                                  AND Modalidade__c =:cartState];
        }
        
        List<Pricing_Matrix__c> listPromotionsAlaCarte = [SELECT Id, Cart_State__c, Produto_Opcional__r.ProductCode, Forma_de_Pagamento__c, TipoFatura__c ,Modalidade__c, Codigo_Promocao__c, To_Quantity__c, PricingValue__c, From_Quantity__c, Target_Product__c, Single__c, Internet__c, Mobile__c, Phone__c, TV__c, Promotion__c, Double__c, Triple__c, Combo_Multi__c, Group__c, Description__c, Type__c, Pricing_Var_Binding_Field__c, Pricing_Variable_Code__c 
                                                  FROM Pricing_Matrix__c 
                                                  WHERE RecordType.DeveloperName = 'Promotion'
                                                  AND Group__c IN :setGroups
                                                  AND Target_Product__c IN :setTarget
                                                  AND Target_Product__r.vlocity_cmt__ObjectTypeId__r.name = 'Produtos Opcionais'                            
                                                  AND ((End_Date__c = null AND Start_Date__c <= TODAY) OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY))
                                                  AND TV__c =:tvClause];

        listPromotions.addAll(listPromotionsAlaCarte);
      
        List<ItemDetails> lstItensDetails = new List<ItemDetails>();
        for (orderItem item : lstOrderLi)
        {
            List<Pricing_Matrix__c> promotions = new List<Pricing_Matrix__c>();
            ItemDetails itemDet = new ItemDetails();
            for(Pricing_Matrix__c promotion : listPromotions)
            {
                Boolean isvalid = true;
                if(promotion.Target_Product__c == item.Product2Id)
                {
                    if(promotion.TV__c != null && tvClause != promotion.TV__c || 
                       ((item.Product2.vlocity_cmt__Type__c == 'Ponto Opcional' || item.Product2.vlocity_cmt__Type__c == 'A la carte' ) && tvClause != promotion.TV__c))
                    {
                        isvalid = false;
                    }
                    if(promotion.Internet__c != null && internetClause != promotion.Internet__c)
                    {
                        isvalid = false;
                    }
                    if(promotion.Phone__c != null && foneClause != promotion.Phone__c)
                    {
                        isvalid = false;
                    }
                    if(promotion.Mobile__c != null && movelClause != promotion.Mobile__c)
                    {
                        isvalid = false;
                    }
               
                    if(isvalid)
                    {
                        if(promotion.Forma_de_Pagamento__c.containsIgnoreCase(formadePagamentoOrder) && promotion.TipoFatura__c.containsIgnoreCase(formadeEnvio))
                        {
                            if((item.Product2.vlocity_cmt__Type__c == 'Plano' || item.Product2.vlocity_cmt__Type__c == 'Dependente') && item.Grupo__c == promotion.Group__c && item.Order.Cart_State__c == promotion.Modalidade__c)
                            {
                                promotions.add(promotion);
                            }
                            else
                            {
                                if( item.Product2.vlocity_cmt__Type__c == 'Ponto Opcional' && item.Order.Cart_State__c == promotion.Modalidade__c && item.Grupo__c == promotion.Group__c)
                                {
                                    if(item.Quantity > 0 && item.Quantity >= promotion.From_Quantity__c && item.Product2.vlocity_cmt__Type__c == 'Ponto Opcional')
                                    {
                                        promotion.PricingValue__c = (item.vlocity_cmt__RecurringCharge__c *-1) - (item.Quantity - promotion.To_Quantity__c) * (item.vlocity_cmt__RecurringCharge__c *-1) / item.Quantity;
                                        promotions.add(promotion);
                                    }
                                }
                                else if(item.Product2.vlocity_cmt__Type__c == 'A la carte' && item.Order.Cart_State__c == promotion.Modalidade__c && item.Grupo__c == promotion.Group__c)
                                {
                                    if(item.vlocity_cmt__OrderPricingAdjustments__r.isEmpty() == true && String.isBlank(item.DescricaoPromocao__c) || String.isNotBlank(item.DescricaoPromocao__c))
                                    {
                                        promotions.add(promotion);
                                    }
                                }
                                else if(item.Product2.vlocity_cmt__Type__c == 'Serviço' && item.Order.Cart_State__c == promotion.Modalidade__c && item.Grupo__c == promotion.Group__c && promotion.Produto_Opcional__c == item.Product2Id)
                                {
                                    if(item.vlocity_cmt__OrderPricingAdjustments__r.isEmpty() == true && String.isBlank(item.DescricaoPromocao__c) || String.isNotBlank(item.DescricaoPromocao__c))
                                    {
                                        promotions.add(promotion);
                                    }
                                }
                            }   
                        }
                    }
                }

                itemDet.OrderId = item.OrderId;
                itemDet.ReliesOnReferenceId = item.ReliesOnReferenceId__c;
                itemDet.AssetReferenceId = item.vlocity_cmt__AssetReferenceId__c;
                itemDet.Product2Name = item.Product2.Name;
                itemDet.Id = item.Id; 
                itemDet.Promotions = promotions;
            }
            lstItensDetails.add(itemDet);
        }
     
        output.put('getPromotions', lstItensDetails);
        return true;
    }
    
       private static Boolean getOptionalProducts (Map<String, Object> inputMap, Map<String, Object> outMap,Map<String, Object> options)
    {
        String tvGroups;
        String tvProductId = null;
        List<OrderItem> lstItens = [SELECT Order.TV_Grupo__c, Grupo__c, Order.Empacotado_Grupo__c, Product2.Family, Order.Fone_Grupo__c, Order.Internet_Grupo__c, Order.Movel_Grupo__c, Order.Cart_State__c, Product2.vlocity_cmt__Type__c 
                                    FROM OrderItem 
                                    WHERE OrderId = :(String)inputMap.get('OrderId') 
                                    AND Product2.vlocity_cmt__Type__c = 'Plano'];
        
        String modalidade = lstItens[0].order.Cart_State__c;
        set<Id> prodsAvailable  = getAvailability((String)inputMap.get('city'), 'Optional', false, modalidade, (String)inputMap.get('TemplateOrderId'));
        
        List<OrderItem> lstOptProducts = [SELECT id, vlocity_cmt__product2id__r.productcode, group__c, ReliesOnReferenceId__c, Grupo__c, Product2.TemplateOrderId__c, PricebookEntry.Product2.Name, orderid,Product2.Family,TemplateMinQty__c,vlocity_cmt__OneTimeCharge__c,Product2.Name,Product2.vlocity_cmt__Type__c,vlocity_cmt__RecurringCharge__c,Product2.vlocity_cmt__SubType__c,Product2.ProductCode,vlocity_cmt__product2id__r.vlocity_cmt__subtype__c,vlocity_cmt__product2id__r.vlocity_cmt__type__c,vlocity_cmt__effectiveonetimetotal__c,product2id,templatedefaultqty__c,templatemaxqty__c,vlocity_cmt__effectiverecurringtotal__c,vlocity_cmt__product2id__r.name 
                                          FROM OrderItem 
                                          WHERE (OrderId = :(String)inputMap.get('TemplateOrderId'))
                                          AND Product2Id IN :prodsAvailable
                                          AND Product2.vlocity_cmt__Type__c != 'Dependente'
                                          AND Product2.vlocity_cmt__Type__c != 'Plano'
                                          AND ((Product2.vlocity_cmt__EndDate__c != null AND Product2.vlocity_cmt__EffectiveDate__c <= TODAY AND Product2.vlocity_cmt__EndDate__c >= TODAY) OR Product2.vlocity_cmt__EffectiveDate__c <= TODAY)
        								  ];
        
        set<String> pontoOptSet = new set<String>();
        set<String> lstGroupsOpt = new set<String>();
        set<String> optProdIds = new set<String>();
        
        for(OrderItem optProd : lstOptProducts)
        {
            if(optProd.Product2.vlocity_cmt__Type__c == 'Ponto Opcional')
            {
                pontoOptSet.add(optProd.Product2Id);
            }
            else
            {
                optProdIds.add(optProd.Product2Id);
            }
        }
        List<Pricing_Matrix__c> lstRows = [SELECT Id, RecordType.developerName, TV__c, TV__r.Name, Target_Product__r.Name, Group__c, PricingValue__c, Target_Product__c, Source_Product__c, Source_Product_Code__c, Pricing_Var_Code__c, Pricing_Var_Binding_Field__c, Pricing_Variable_Code__c
                                           FROM Pricing_Matrix__c
                                           WHERE (Source_Product__c IN :pontoOptSet OR Target_Product__c IN :optProdIds)
                                           AND (DDD__c = '-' OR DDD__c = '' OR DDD__c = null)
                                           AND (RecordType.developerName = 'Pricing' OR RecordType.developerName = 'Package_Pricing')
                                           AND ((End_Date__c = null AND Start_Date__c <= TODAY) OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY))
                                           AND Modalidade__c = :modalidade];
        
        map<String, Object> mapProdIdAndPackage = new map<String, Object>();
        map<String, Object> mapProdCodeAndPO = new map<String, Object>();
        vlocity_cmt__ProductChildItem__c decoder = [SELECT ID, vlocity_cmt__MaxQuantity__c, vlocity_cmt__ParentProductId__r.Name, vlocity_cmt__MinQuantity__c from vlocity_cmt__ProductChildItem__c WHERE vlocity_cmt__ParentProductId__r.Name = 'DECODER']; 
        OrderItem itemTV = null;
        for(OrderItem item : lstItens)
        {
            if(item.Product2.Family == 'TV')
            {
                itemTV = item;
            }
        }
        if(itemTV != null)
        {
            for(Pricing_Matrix__c row : lstRows)
            {
                if(row.RecordType.developerName == 'Package_Pricing')
                {
                    if((String)inputMap.get('Group') == row.Group__c && row.TV__c == itemTV.Product2Id)
                    {
                        mapProdIdAndPackage.put(row.Target_Product__c, row.get('PricingValue__c'));
                    }
                }
                else if (itemTV.Grupo__c == row.Group__c)
                {
                    mapProdCodeAndPO.put(row.Source_Product__c, row.get('PricingValue__c')); 
                }
            }
        }
        map<String, Decimal> mapOptProdBase = new Map<String, Decimal>();
        for(vlocity_cmt__PriceListEntry__c entry :[Select id, vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c, vlocity_cmt__ProductId__c 
                                                   from vlocity_cmt__PriceListEntry__c 
                                                   WHERE vlocity_cmt__ProductId__c IN :optProdIds
                                                   AND ((vlocity_cmt__EffectiveUntilDate__c  = null AND vlocity_cmt__EffectiveFromDate__c <= TODAY) OR (vlocity_cmt__EffectiveFromDate__c <= TODAY AND vlocity_cmt__EffectiveUntilDate__c >= TODAY))])
        {
            mapOptProdBase.put(entry.vlocity_cmt__ProductId__c, entry.vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c);
        }
            
        Map<String, Object> optionalProducts = new Map<String, Object>();
        if(!lstRows.isEmpty())
        {
            for(Pricing_Matrix__c row : lstRows)
            {
              for(OrderItem prodOptional : lstOptProducts)
              {
               if((String)inputMap.get('Group') == itemTV.Order.Empacotado_Grupo__c && prodOptional.Product2.vlocity_cmt__Type__c == 'A la carte')
                {
                    if ((prodOptional.Product2.vlocity_cmt__Type__c != 'Plano' && row.Group__c == (String)inputMap.get('Group')) || prodOptional.Product2.vlocity_cmt__SubType__c == 'Avulso')
                    {
                        map<String, Object> objOptProd = new map<String, Object>{'Group'                    => (String)inputMap.get('Group'), 
                                                                                'OrderItemId'               => prodOptional.Id,
                                                                                'ProductId'                 => prodOptional.Product2Id,
                                                                                'DefaultQuantity'           => prodOptional.TemplateDefaultQty__c,
                                                                                'MaxQuantity'               => prodOptional.TemplateMaxQty__c,
                                                                                'MinQuantity'               => prodOptional.TemplateMinQty__c,
                                                                                'EffectiveOneTimeTotal'     => 0,
                                                                                'EffectiveRecurringTotal'   => mapProdIdAndPackage.get(prodOptional.Product2Id) != null ? (Decimal)mapProdIdAndPackage.get(prodOptional.Product2Id) : mapOptProdBase.get(prodOptional.Product2Id),
                                                                                'Name'                      => prodOptional.Product2.Name,
                                                                                'ProductCode'               => prodOptional.Product2.ProductCode,
                                                                                'SubType'                   => prodOptional.Product2.vlocity_cmt__Subtype__c,
                                                                                'Type'                      => prodOptional.Product2.vlocity_cmt__Type__c};
                          optionalProducts.put(prodOptional.Id, objOptProd);
                      }

                }
                  else if (prodOptional.Product2.vlocity_cmt__Type__c != 'Plano' && row.Group__c == itemTV.Order.TV_Grupo__c)
                  {
                       map<String, Object> objOptProd = new map<String, Object>{'Group'                    => (String)inputMap.get('Group'), 
                                                                               'OrderItemId'               => prodOptional.Id,
                                                                               'ProductId'                 => prodOptional.Product2Id,
                                                                               'DefaultQuantity'           => prodOptional.TemplateDefaultQty__c,
                                                                               'MaxQuantity'               => String.valueOf(decoder.vlocity_cmt__MaxQuantity__c),
                                                                               'MinQuantity'               => prodOptional.TemplateMinQty__c,
                                                                               'EffectiveOneTimeTotal'     => 0,
                                                                               'EffectiveRecurringTotal'   => mapProdCodeAndPO.get(prodOptional.Product2Id) != null ? (Decimal)mapProdCodeAndPO.get(prodOptional.Product2Id) : mapOptProdBase.get(prodOptional.Product2Id),
                                                                               'Name'                      => prodOptional.Product2.Name,
                                                                               'ProductCode'               => prodOptional.Product2.ProductCode,
                                                                               'SubType'                   => prodOptional.Product2.vlocity_cmt__Subtype__c,
                                                                               'Type'                      => prodOptional.Product2.vlocity_cmt__Type__c};
                       optionalProducts.put(prodOptional.Id, objOptProd);
                  }
                    else if (prodOptional.Product2.vlocity_cmt__Type__c != 'Plano' && prodOptional.Product2.vlocity_cmt__Type__c != 'Ponto Opcional' && prodOptional.Product2.vlocity_cmt__Type__c != 'A la carte')
                    {
                      map<String, Object> objOptProd = new map<String, Object>{'Group'                    => (String)inputMap.get('Group'), 
                                                                               'OrderItemId'               => prodOptional.Id,
                                                                               'ProductId'                 => prodOptional.Product2Id,
                                                                               'DefaultQuantity'           => prodOptional.TemplateDefaultQty__c,
                                                                               'MaxQuantity'               => prodOptional.TemplateMaxQty__c,
                                                                               'MinQuantity'               => prodOptional.TemplateMinQty__c,
                                                                               'EffectiveOneTimeTotal'     => 0,
                                                                               'EffectiveRecurringTotal'   => mapOptProdBase.get(prodOptional.Product2Id),
                                                                               'Name'                      => prodOptional.Product2.Name,
                                                                               'ProductCode'               => prodOptional.Product2.ProductCode,
                                                                               'SubType'                   => prodOptional.Product2.vlocity_cmt__Subtype__c,
                                                                               'Type'                      => prodOptional.Product2.vlocity_cmt__Type__c};
                      optionalProducts.put(prodOptional.Id, objOptProd); 
                  }
              }
          }
        }
        else
        {
            for(OrderItem prodOptional : lstOptProducts)
            {
                if(prodOptional.TemplateMinQty__c != '1' || prodOptional.TemplateDefaultQty__c != '1' || prodOptional.TemplateMaxQty__c != '1')
                {
                if (prodOptional.Product2.vlocity_cmt__Type__c != 'Plano' && prodOptional.Product2.vlocity_cmt__Type__c != 'Ponto Opcional' && prodOptional.Product2.vlocity_cmt__Type__c != 'A la carte')
                {
                    map<String, Object> objOptProd = new map<String, Object>{'Group'                    => (String)inputMap.get('Group'), 
                                                                             'OrderItemId'               => prodOptional.Id,
                                                                             'ProductId'                 => prodOptional.Product2Id,
                                                                             'DefaultQuantity'           => prodOptional.TemplateDefaultQty__c,
                                                                             'MaxQuantity'               => prodOptional.TemplateMaxQty__c,
                                                                             'MinQuantity'               => prodOptional.TemplateMinQty__c,
                                                                             'EffectiveOneTimeTotal'     => 0,
                                                                             'EffectiveRecurringTotal'   => mapOptProdBase.get(prodOptional.Product2Id),
                                                                             'Name'                      => prodOptional.Product2.Name,
                                                                             'ProductCode'               => prodOptional.Product2.ProductCode,
                                                                             'SubType'                   => prodOptional.Product2.vlocity_cmt__Subtype__c,
                                                                             'Type'                      => prodOptional.Product2.vlocity_cmt__Type__c};
                    optionalProducts.put(prodOptional.Id, objOptProd);
                }
            }
        }
        }
        outMap.put('TemplateProducts',optionalProducts.values());
        return true;
    }
    

    
    public static Integer levelLength = 4;
    public static String padLeft(Integer i) {
        String str = String.valueOf(i);
        while (str.length() < levelLength) {
            str = '0' + str;
        }
        return str;
    }
    
    global virtual void setup(Map<String, Object> input
                              ,Map<String, Object> output
                              ,Map<String, Object> options
                              ,SObject existingParent
                              ,SObject templateParent
                              ,List<SObject> templateLi
                             ) {}
    
    private void getCartState(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        List<SObject> sObjectItemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        String RecordType = '';  
        for(SObject obj : sObjectItemList)
        {
            RecordType = getObjectNameByChildPrefix(obj.get('Id'));
            break;
        }
        if (RecordType != 'OrderItem') {return;}
        List<OrderItem> itemList = (List<OrderItem>)sObjectItemList;
        List<String> orderItemId = new List<String>();
        
        for(OrderItem oItem: itemList)
        {
            orderItemId.add(oItem.Id);
        }
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        String orderId = (String)parent.Id;
        
        set<String> setOIProductFamily = new set<String>();
        List<String> productCodes = new List<String>();
        Map<String,OrderItem> oItemsToPriceMap = new Map<String,OrderItem>();
        
        for (OrderItem ordItem: [select Id, Product2.Family, Product2.ProductCode, UnitPrice from OrderItem where Id in :orderItemId AND Product2.vlocity_cmt__Type__c = 'Plano'])
        {
            String family = ordItem.Product2.Family == 'Movel' ? 'Celular' : ordItem.Product2.Family; 
            setOIProductFamily.add(family);
            productCodes.add(ordItem.Product2.ProductCode);
            oItemsToPriceMap.put(ordItem.Product2.ProductCode,ordItem);
        }
        Map<String, ProductFamilyState__c> mcs = ProductFamilyState__c.getAll();
        list<String> lstOrderItem = new list<String>(setOIProductFamily);
        lstOrderItem.sort();
        String familyName = String.join(lstOrderItem, ';').toUpperCase();
        String cartState;
        for(String key: mcs.keySet())
        {    
            ProductFamilyState__c csProdFamily = mcs.get(key);
            if(csProdFamily.Combination__c == familyName)
                cartState = csProdFamily.State__c;
        }
        
        
        Order ord = (Order)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        ord.Cart_State__c = cartState;
        
        vlocity_cmt.PricingPlanService.putInPricingContext('CartState', cartState);
        vlocity_cmt.PricingPlanService.putInPricingContext('ProductCodes', productCodes);
        //oItemsToPrice
        vlocity_cmt.PricingPlanService.putInPricingContext('oItemsToPrice', oItemsToPriceMap);
        //priceItems();
    } 
    
    //Added by Jaya
    public static Boolean setOneTimeChargeToZero(Map<String, Object> inputMap, Map<String, Object> outMap,
                                                  Map<String, Object> options)
    {
        String recTypeOrderId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Comercial').getRecordTypeId();
        
        List<OrderItem> oItems = new List<OrderItem>();
        
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        String orderId = (String)parent.Id;
        List<SObject> sObjectItemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        String RecordType = '';
        for(SObject obj : sObjectItemList)
        {
            RecordType = controller.getObjectNameByChildPrefix(obj.get('Id'));
            break;
        }
        if (RecordType != 'OrderItem') 
        {
            return true;
        }
        
        oItems = [SELECT Id, Order.Cart_State__c, Product2Id, Product2.ProductCode, vlocity_cmt__OneTimeCharge__c, Meses_de_Fidelidade__c, Quantity, Product2.vlocity_cmt__Type__c, Acrescimo_Desconto__c,
                    Product2.vlocity_cmt__SubType__c, Grupo__c, DDD__c, Product2.Name, Product2.Family, Order.Forma_de_Pagamento__c, 
                    vlocity_cmt__RecurringCharge__c, ReliesOnReferenceId__c, vlocity_cmt__AssetReferenceId__c, vlocity_cmt__PricingLogData__c,
                  	Order.RecordTypeId
                    FROM OrderItem
                    Where OrderId = :orderId AND Product2.vlocity_cmt__Type__c = 'Plano' ORDER BY Product2.Family ASC];
                    
        
        for(OrderItem oItem:oItems)
        {
            
            //oItem.vlocity_cmt__PricingLogData__c = '{"LogData":{"OT_LTY_TOTAL":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"[One Time Loyalty Total (0) + Rollup ROLLUP_OT_LTY_TOTAL (0.00)] x Quantity (1.00)"}],"REC_MNTH_STD_PRC_TOTAL":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"[Recurring Calculated Price (0.00) + Rollup Recurring Total (0.00)] x Quantity (1.00)"}],"REC_MNTH_STD_PRC_CALC":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"Recurring Charge (0.00) - Recurring Manual Discount (0.00%)"}],"OT_STD_PRC_TOTAL":[{"ChargeTiming":"One-Time","LogSequence":0,"DisplayText":"[One Time Calculated Price (0.00) + Rollup One Time Total (0.00)] x Quantity (1.00)"}],"OT_STD_PRC_CALC":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"One Time Charge (0.00) - One Time Manual Discount (0.00%)"}],"REC_MNTH_STD_PRC":[{"LogSequence":0,"IsEffective":true,"EndDate":null,"StartDate":null,"AdjustmentType":"None","LoyaltyCode":"PTS","CurrencyCode":"BRL","CurrencyType":"Currency","Amount":0.00,"AdjustmentValue":0.00,"AdjustmentMethod":null,"BaseValue":0.00,"BaseAdjustment":null,"PriceListId":"a2wg0000001FWayAAG","OfferId":null,"PromotionId":null,"PricingElementId":"a2zg0000002SdLhAAK","PricingVariableCode":"REC_MNTH_STD_PRC","DisplayText":"0.00","EndValue":0.00,"ChargeTiming":"Recurring","Frequency":"Monthly","SubType":"Standard","StartValue":0.00,"PricingElementGlobalKey":"3312cda5-9baf-cf12-48da-79aca50a4c91","LogType":"PRICE","PriceListEntryId":"a2v2a0000007ImIAAU"}]},"PricingVariableCodeFieldBinding":{"vlocity_cmt__RecurringManualDiscount__c":"REC_MNTH_STD_PRC_DISC_PCT_MAN","vlocity_cmt__RecurringCharge__c":"REC_MNTH_STD_PRC","vlocity_cmt__OneTimeTotal__c":"OT_STD_PRC_TOTAL","vlocity_cmt__OneTimeManualDiscount__c":"OT_STD_PRC_DISC_PCT_MAN","vlocity_cmt__OneTimeCalculatedPricingValue__c":"OT_STD_PRC_CALC","vlocity_cmt__OneTimeCharge__c":"OT_STD_PRC","vlocity_cmt__OneTimeLoyaltyTotal__c":"OT_LTY_TOTAL","vlocity_cmt__OneTimeLoyaltyPricingValue__c":"OT_LTY","Quantity":"LINE_QUANTITY","vlocity_cmt__EffectiveRecurringTotal__c":"EFF_REC_MNTH_STD_PRC_TOTAL","vlocity_cmt__EffectiveOneTimeTotal__c":"EFF_OT_STD_PRC_TOTAL","vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c":"EFF_OT_LTY_TOTAL","vlocity_cmt__EffectiveQuantity__c":"EFFECTIVE_QUANTITY","vlocity_cmt__RecurringTotal__c":"REC_MNTH_STD_PRC_TOTAL","vlocity_cmt__RecurringCalculatedPricingValue__c":"REC_MNTH_STD_PRC_CALC"},"PriceAdjustmentPromoKeys":[],"PricingVariableCodeValues":{"DISP_OT_LTY":0.00,"DISP_OT_STD_PRC":0.00,"ROLLUP_OT_STD_PRC_TOTAL":0.00,"ROLLUP_OT_LTY_TOTAL":0.00,"ROLLUP_REC_MNTH_STD_PRC_TOTAL":0.00,"REC_MNTH_STD_PRC_DISC_PCT_MAN":0.00,"REC_MNTH_STD_PRC":0.00,"OT_STD_PRC_TOTAL":0.00,"OT_STD_PRC_DISC_PCT_MAN":0.00,"OT_STD_PRC_CALC":0.00,"OT_STD_PRC":0.00,"OT_LTY_TOTAL":0,"OT_LTY":0,"LINE_QUANTITY":1.00,"EFF_REC_MNTH_STD_PRC_TOTAL":0.00,"EFF_OT_STD_PRC_TOTAL":0.00,"EFF_OT_LTY_TOTAL":0,"EFFECTIVE_QUANTITY":1.00,"REC_MNTH_STD_PRC_TOTAL":0.00,"REC_MNTH_STD_PRC_CALC":0.00},"PricingVariableCodeBaseValues":{"REC_MNTH_STD_PRC":0.00},"LogVersion":"1.5","LastPricingTime":"2019-09-06T07:21:24.488Z"}';
            if(oItem.vlocity_cmt__PricingLogData__c == null && oItem.Order.RecordTypeId == recTypeOrderId)
                oItem.vlocity_cmt__PricingLogData__c = '{}';     
        }
        
        update oItems;
        
        return true;
    }
       
    public static Boolean setMemberFeePricingPlan(Map<String, Object> inputMap, Map<String, Object> outMap,
                                                  Map<String, Object> options)
    {
        
        Set<String> setLineItemId = new Set<String>();
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        inputMap.put('parent', parent);
        List<SObject> sObjectItemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        
        String RecordType = '';  
        for(SObject obj : sObjectItemList)
        {
            RecordType = controller.getObjectNameByChildPrefix(obj.get('Id'));
            break;
        }
        if (RecordType != 'OrderItem') 
        {
            return true;
        }
        
        List<OrderItem> itemList = (List<OrderItem>)sObjectItemList;
        
        String cartId = (String)parent.get('Id'); 
        inputMap.put('cartId', cartId);
        
        for(OrderItem item : itemList)
        {
            setLineItemId.add(item.Id);
        }
        
        itemList = new List<OrderItem>();
        
        itemList = [SELECT Id, Order.Cart_State__c, Order.vlocity_cmt__PriceListId__r.Name, Product2Id, Product2.ProductCode, vlocity_cmt__OneTimeCharge__c, Meses_de_Fidelidade__c, Quantity, Product2.vlocity_cmt__Type__c, Acrescimo_Desconto__c,
                    Product2.vlocity_cmt__SubType__c, Grupo__c, DDD__c, Product2.Name, Product2.Family, Order.Forma_de_Pagamento__c, 
                    vlocity_cmt__RecurringCharge__c, ReliesOnReferenceId__c, vlocity_cmt__AssetReferenceId__c, vlocity_cmt__PricingLogData__c
                    FROM OrderItem
                    Where OrderId = :cartId AND Product2.vlocity_cmt__Type__c = 'Plano' ORDER BY Product2.Family ASC];
                    
        if(itemList[0].Order.vlocity_cmt__PriceListId__r.Name != 'Comercial Residencial')
        {
            return true;
        }
        Map<Id, Decimal> mapItemsFidelity = (Map<Id, Decimal>)vlocity_cmt.PricingPlanService.getFromPricingContext('ItemsFidelity');
        for(OrderItem item : itemList)
        {
            item.Fidelidade__c = mapItemsFidelity.get(item.Id) > 0 ? true : false;
        }

        vlocity_cmt.PricingPlanService.putInPricingContext('newItemList', itemList);
        
        if(itemList.isEmpty())
        {
            return true;
        }
        
        //Variables to control the "where clause" on SOQL
        String tvClause = '';
        String recTypePolCommercial = 'Politica_Commercial';
        Set<Id> setSource = new Set<Id>();
        List<String> lstFamilies = new List<String>();
        Set<String> setGroups = new Set<String>();
        Set<Decimal> setDuration = new Set<Decimal>();
        setGroups.add('-');
        
        for (OrderItem item : itemList)
        {
            setSource.add(item.Product2Id);
            setDuration.add(mapItemsFidelity.get(item.Id));
            if(item.Grupo__c != null)
            {
                setGroups.add(item.Grupo__c);
            }
            if(item.Product2.vlocity_cmt__Type__c == 'Plano')
            {
                if(item.Product2.Family == 'Internet Fixa')
                {
                    lstFamilies.add(item.Product2.Family);
                }
                if(item.Product2.Family == 'Fone')
                {
                    lstFamilies.add(item.Product2.Family);
                    
                }
                if(item.Product2.Family == 'Movel')
                {
                    lstFamilies.add(item.Product2.Family);
                    
                }
                if(item.Product2.Family == 'TV')
                {
                    tvClause = item.Product2Id;
                    lstFamilies.add(item.Product2.Family);
                    
                }
            }
        }
        String cartState = (String)vlocity_cmt.PricingPlanService.getFromPricingContext('CartState');
        
        //Momentum Magicum - query the correspondents promotions according with our cart combination.
        List<Pricing_Matrix__c> lstComercialPol = Database.query('SELECT Id, Active__c, Modalidade__c, Cart_State__c, Combo_Multi__c, Description__c, Double__c, Duration__c, End_Date__c, Family__c, Installation_Amount__c, Group__c, Internet__c, Mobile__c, Multa_Desc__c, No_of_Installments__c, Phone__c, PricingValue__c, Pricing_Var_Code__c, Pricing_Var_Code__r.vlocity_cmt__Code__c, Product_Code__c, Single__c, TV__c, Source_Product__c, Start_Date__c, Triple__c, Business_Unit__c '+ 
                                                                 'FROM Pricing_Matrix__c '+
                                                                 'WHERE RecordType.DeveloperName = :recTypePolCommercial '+
                                                                 'AND Group__c IN :setGroups '+
                                                                 'AND Duration__c IN :setDuration '+
                                                                 'AND Modalidade__c = :cartState '+
                                                                 'AND ((End_Date__c = null AND Start_Date__c <= TODAY) OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY)) '+
                                                                 'AND Source_Product__c IN :setSource');
        

        List<ItemDetails> lstItensDetails = new List<ItemDetails>();
        
        for (OrderItem item : itemList)
        {
            List<Pricing_Matrix__c> lstPoliticas = new List<Pricing_Matrix__c>();
            for(Pricing_Matrix__c polComercial : lstComercialPol)
            {
                if(item.Product2Id == polComercial.Source_Product__c && item.Grupo__c == polComercial.Group__c && mapItemsFidelity.get(item.Id) == polComercial.Duration__c)
                {
                    inputMap.put('membershipAdjust', true);
                    Decimal ajuste = (Decimal)polComercial.get('PricingValue__c');
                    If(item.vlocity_cmt__OneTimeCharge__c != ajuste || item.vlocity_cmt__OneTimeCharge__c != 0)
                    {
                        vlocityAdjustment(inputMap, outMap, options, item.Id, ajuste);
                    }
                }
                else if(item.Product2Id == polComercial.Source_Product__c && polComercial.Group__c == '-' && item.Meses_de_Fidelidade__c == polComercial.Duration__c)
                {
                    inputMap.put('membershipAdjust', true);
                    Decimal ajuste = (Decimal)polComercial.get('PricingValue__c');
                    If(item.vlocity_cmt__OneTimeCharge__c != ajuste || item.vlocity_cmt__OneTimeCharge__c != 0)
                    {
                        vlocityAdjustment(inputMap, outMap, options, item.Id, ajuste);
                    }
                }
            }
        }
        return true;
    }   
    
    
    public static Boolean setPaymentAdjust (Map<String, Object> inputMap, Map<String, Object> outMap,
                                            Map<String, Object> options)
    {
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        Map<String, Decimal> mapItemAdjust = (Map<String, Decimal>)vlocity_cmt.PricingPlanService.getFromPricingContext('adjustments');
        String cartId = (String)parent.get('Id'); 
        List<SObject> sObjectItemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        String RecordType = '';  
        for(SObject obj : sObjectItemList)
        {
            RecordType = controller.getObjectNameByChildPrefix(obj.get('Id'));
            break;
        }
        if (RecordType != 'OrderItem') 
        {
            return true;
        }

        List<OrderItem> itemList = (List<OrderItem>)vlocity_cmt.PricingPlanService.getFromPricingContext('newItemList');
        
        if(itemList[0].Order.vlocity_cmt__PriceListId__r.Name != 'Comercial Residencial')
        {
            return true;
        }
        String code = '';
        String variableId = '';
        for(vlocity_cmt__PricingVariable__c variable : (List<vlocity_cmt__PricingVariable__c>)vlocity_cmt.PricingPlanService.getFromPricingContext('priceVariables'))
        {
            if(variable.vlocity_cmt__Code__c == 'REC_MNTH_STD_PRC_ADJ_ABS')
            {
                code = variable.vlocity_cmt__Code__c;
                variableId = variable.Id;   
            }
        }
        
        List<Object> adjList = new  List<Object>();
        
        for(OrderItem item : itemList)
        {
            if(item.Product2.vlocity_cmt__Type__c == 'Plano')
            {
                
                If(mapItemAdjust.get(item.Id) != 0)
                {
                    map<String, Object> drBody = new map<String, Object>{'Action'               => 'Add', 
                                                                        'AdjValue'              => code == 'OT_STD_PRC' ? null : mapItemAdjust.get(item.Id),
                                                                        'AdjAmount'             => code == 'REC_MNTH_STD_PRC_ADJ_ABS' ? null : mapItemAdjust.get(item.Id),
                                                                        'OrderId'               => cartId,
                                                                        'OrderItemId'           => item.Id,
                                                                        'PricingVar'            => variableId,
                                                                        'Source'                => 'Agent',
                                                                        'Name'                  => ''
                    };
                   adjList.add(drBody);
                }
            }
        }
        
        if(!adjList.isEmpty())
        {
            bulkdAdjustment(adjList);
        }
        
        return true;
    }
    
    public static void bulkdAdjustment (List<Object> lstAdj)
    {
        String dataJson = Json.serialize(lstAdj);
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processObjectsJSON(dataJson, 'CEC_CreateOrderPricingAdj');
        Map<String, Object> resultMap = result.convertToMap();
    }
    
 public static Boolean setPromotionAdjust (Map<String, Object> inputMap, Map<String, Object> outMap,
                                              Map<String, Object> options)
    {
        List<sObject> sObjectItemList = (List<sObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        String RecordType = '';  
        for(sObject obj : sObjectItemList)
        {
            RecordType = controller.getObjectNameByChildPrefix(obj.get('Id'));
            break;
        }
        if (RecordType != 'OrderItem') 
        {
            return true;
        }
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        String cartId = (String)parent.get('Id'); 
        
        List<OrderItem> itemList = [SELECT Id, Order.Cart_State__c, Order.TV_Grupo__c, Order.Empacotado_Grupo__c, Order.vlocity_cmt__PriceListId__r.Name, DescricaoPromocao__c, Product2Id, vlocity_cmt__PricingLogData__c, Promotion_Log__c, Product2.ProductCode, Meses_de_Fidelidade__c, Quantity, Product2.vlocity_cmt__Type__c, Acrescimo_Desconto__c,
                                    Product2.vlocity_cmt__SubType__c, Grupo__c, DDD__c, Product2.Name, Product2.Family, Order.Forma_de_Pagamento__c, Order.TipoFatura__c,
                                    vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c, ReliesOnReferenceId__c, vlocity_cmt__AssetReferenceId__c, (Select Id from vlocity_cmt__OrderPricingAdjustments__r)
                                    FROM OrderItem
                                    Where OrderId = :cartId ORDER BY Product2.Family ASC];
        
        vlocity_cmt.PricingPlanService.putInPricingContext('newItemList', itemList);
        
        if(itemList[0].Order.vlocity_cmt__PriceListId__r.Name != 'Comercial Residencial')
        {
            return true;
        }
        
        Set<String> optProdIds = new Set<String>();
        String tvProductId = null;

        for(OrderItem item : itemList)
        {
            if(item.Product2.Family == 'TV' && item.Product2.vlocity_cmt__Type__c == 'Plano')
            {
                tvProductId = item.Product2Id;
            }
            optProdIds.add(item.Product2Id);
        }
        
        Map<Id, Decimal> mapItemsFidelity = (Map<Id, Decimal>)vlocity_cmt.PricingPlanService.getFromPricingContext('ItemsFidelity');
        for(OrderItem item : itemList)
        {
            item.Fidelidade__c = mapItemsFidelity.get(item.Id) > 0 ? true : false;
        }
        
        vlocity_cmt.PricingPlanService.putInPricingContext('newItemList', itemList);
        String cartState = itemList[0].order.Cart_State__c;

        
        // Promoção Auto Aplicavel - Added by Deloitte 19/09/2019
        map<String, Object> mapProdIdAndPackage = new map<String, Object>();
        if(tvProductId != null)
        {
            List<Pricing_Matrix__c> lstRows = [SELECT Id, Single__c, RecordType.developerName, Promotion__c, PricingValue__c, Double__c, Triple__c, Combo_Multi__c, Target_Product__c, Source_Product_Code__c, Pricing_Var_Code__c, Pricing_Var_Binding_Field__c, Pricing_Variable_Code__c
                                               FROM Pricing_Matrix__c
                                               WHERE Target_Product__c IN :optProdIds AND TV__c = :tvProductId
                                               AND (Group__c = '-' OR Group__c = :itemList[0].order.Empacotado_Grupo__c)
                                               AND (Duration__c = 0 OR Duration__c = null)
                                               AND (DDD__c = '' OR DDD__c = null)
                                               AND Modalidade__c = :cartState
                                               AND ((End_Date__c = null AND Start_Date__c <= TODAY) OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY))
                                               AND RecordType.developerName = 'Package_Pricing'];
            
            for(Pricing_Matrix__c row : lstRows)
            {
                if(row.RecordType.developerName == 'Package_Pricing')
                {
                    mapProdIdAndPackage.put(row.Target_Product__c, row.get('PricingValue__c'));
                }
            }
        }
        String code = '';
        String variableId = '';
        for(vlocity_cmt__PricingVariable__c variable : (List<vlocity_cmt__PricingVariable__c>)vlocity_cmt.PricingPlanService.getFromPricingContext('priceVariables'))
        {
            if(variable.vlocity_cmt__Code__c == 'REC_MNTH_STD_PRC_ADJ_ABS')
            {
                code = variable.vlocity_cmt__Code__c;
                variableId = variable.Id;   
            }
        }
                
         List<Object> adjList = new  List<Object>();
        for(sObject itemSobj : sObjectItemList)
        {
            OrderItem itemContext = (OrderItem)itemSobj;
            for(OrderItem item : itemList)
            {
                if(itemContext.Id == item.Id)
                {
                    itemContext.CodigoPromocao__c = '';
                    itemContext.DescricaoPromocao__c = '';
                    if(item.Promotion_Log__c != null && item.DescricaoPromocao__c != null)
                    {
                        Map<String, Object> promotion = (Map<String, Object>)JSON.deserializeUntyped(item.Promotion_Log__c);
                        Decimal price;
                        itemContext.CodigoPromocao__c = '';
                        itemContext.DescricaoPromocao__c = '';
                        itemContext.Promotion_Log__c = '';

                        if(String.valueOf(promotion.get('Forma_de_Pagamento__c')).containsIgnoreCase(item.Order.Forma_de_Pagamento__c) && String.valueOf(promotion.get('TipoFatura__c')).containsIgnoreCase(item.Order.TipoFatura__c)){
                            if((String)promotion.get('Group__c') == item.Grupo__c && 
                                (String)promotion.get('Target_Product__c') == item.Product2Id && 
                                (String)promotion.get('Modalidade__c') == (String)vlocity_cmt.PricingPlanService.getFromPricingContext('CartState'))
                                {
                                    price = (Decimal)promotion.get('PricingValue__c');
                                    itemContext.CodigoPromocao__c = (String)promotion.get('Codigo_Promocao__c');
                                    itemContext.DescricaoPromocao__c = (String)promotion.get('Promotion__c');
                                    itemContext.Promotion_Log__c = item.Promotion_Log__c;
                                    If(item.Product2.vlocity_cmt__Type__c != 'Ponto Opcional')
                                    {
                                        map<String, Object> drBody = new map<String, Object>{'Action'               => 'Add', 
                                            'AdjAmount'             => price,
                                            'AdjValue'              => null,
                                            'OrderId'               => cartId,
                                            'OrderItemId'           => item.Id,
                                            'PricingVar'            => variableId,
                                            'Source'                => 'Agent',
                                            'Name'                  => ''};
                                                adjList.add(drBody);
                                    }
                                    else if (item.Product2.vlocity_cmt__Type__c == 'Ponto Opcional')
                                    {
                                        map<String, Object> drBody = new map<String, Object>{'Action'               => 'Add', 
                                            'AdjAmount'             => null,
                                            'AdjValue'              => price,
                                            'OrderId'               => cartId,
                                            'OrderItemId'           => item.Id,
                                            'PricingVar'            => variableId,
                                            'Source'                => 'Agent',
                                            'Name'                  => ''};
                                                adjList.add(drBody);
                                    }
                                    
                                }
                        }
                    }
                    // Promoção Auto Aplicavel - Added by Deloitte 19/09/2019
                    else if(item.Product2.vlocity_cmt__Type__c == 'A la carte')
                    {
                        map<String, Object> drBody = new map<String, Object>{'Action'               => 'Add', 
                                                                            'AdjAmount'             => code == 'OT_STD_PRC' ? null : mapProdIdAndPackage.get(item.Product2Id),
                                                                            'AdjValue'              => code == 'REC_MNTH_STD_PRC_ADJ_ABS' ? null : mapProdIdAndPackage.get(item.Product2Id),
                                                                            'OrderId'               => cartId,
                                                                            'OrderItemId'           => item.Id,
                                                                            'PricingVar'            => variableId,
                                                                            'Source'                => 'Agent',
                                                                            'Name'                  => ''};
                                        adjList.add(drBody);
                    }
                }
            }
        }
        if(!adjList.isEmpty())
        {
            bulkdAdjustment(adjList);
        }
        return true;
    }
    
    public static Boolean getProducts(Map<String, Object> inputMap, Map<String, Object> outMap,
                                              Map<String, Object> options) 
    {
        City_Groups__mdt cityGroup;
        List<City_Groups__mdt> listCityGroup = [SELECT Id, developerName, MasterLabel, UF__c , UnidadeNegocio__c, DDD__c, Internet__c, Phone__c, Mobile__c, TV__c, Empacotado__c 
                                      FROM City_Groups__mdt 
                                      Where MasterLabel = :(String)inputMap.get('city')
                                      AND DeveloperName LIKE '%CGR_%'				 
                                      AND UnidadeNegocio__c = 'Residencial'];
        
        if (!listCityGroup.isEmpty())
        {
            cityGroup = listCityGroup[0];
        }
        else
        {
            cityGroup = new City_Groups__mdt();
            cityGroup.DeveloperName = 'CGR_GENERIC';
            cityGroup.Internet__c = 'GN1';
            cityGroup.Mobile__c = 'GN';
            cityGroup.Phone__c = 'GN';
            cityGroup.TV__c = 'GN';
            cityGroup.Empacotado__c = 'G1A';
        }
        
        Order varOrder = [SELECT Id, AnaliseCredito__c, Cart_State__c, Unidade__c, TV_Grupo__c, Movel_Grupo__c, Fone_Grupo__c, Internet_Grupo__c, TechViabilityHFC__c, TechViabilityFibra__c
                          FROM Order Where Id = :(String)inputMap.get('OrderId')];
        
        set<String> setGroup = new set<String>{cityGroup.Internet__c, cityGroup.Phone__c, cityGroup.Mobile__c, cityGroup.TV__c, '-'};
        set<String> setFamily = (Object)inputMap.get('isMovel') == true ? new set<String>{'Movel'} : new set<String>{'TV', 'Internet Fixa', 'Fone', 'Movel'};
        Map<String, Set<Id>> availability = new Map<String, Set<Id>>();

        set<Id> prodsAvailable = new set<Id>();
        
        if(String.isNotBlank(varOrder.AnaliseCredito__c) && varOrder.AnaliseCredito__c.contains('OFERTAR APENAS ACESSO VIRTUA SINGLE'))       	                
        {
           prodsAvailable = getAvailability((String)inputMap.get('city'), 'Plano', true, varOrder.Cart_State__c, null); 
            inputMap.put('restricao', true);
        }
        else
        {
           prodsAvailable = getAvailability((String)inputMap.get('city'), 'Plano', false, varOrder.Cart_State__c, null);
           inputMap.put('restricao', false);
        }
        CEC_ComNodeAvailability nodeValidate = new CEC_ComNodeAvailability();  //viabilidade por node
        Set<Id> idsNodes = nodeValidate.getProductsIdWithNodeAvailable(inputMap);
        prodsAvailable.addAll(idsNodes);
        List<Product2> allPlans = new List<Product2>();
        Map<String, Object> mapProdRestricao = new Map<String, Object>();
        if(String.isNotBlank(varOrder.AnaliseCredito__c) && varOrder.AnaliseCredito__c.contains('OFERTAR APENAS ACESSO VIRTUA SINGLE'))                
        {        	
            for(Product2 plano : [Select Id, Family, vlocity_cmt__AttributeDefaultValues__c FROM Product2 WHERE vlocity_cmt__Type__c = 'Plano' ORDER BY Name ASC])
            {
                if(String.isNotBlank(plano.vlocity_cmt__AttributeDefaultValues__c ))
                {
                    Attributes attributes = (Attributes)System.JSON.deserialize(plano.vlocity_cmt__AttributeDefaultValues__c, Attributes.class);
                    
                    if(attributes.ATTR_Indica_Rest == true)
                    {
                        mapProdRestricao.put(plano.Id, attributes.ATTR_Indica_Rest);
                        allPlans.add(plano);
                    }
                }
            }
        }
        else
        {
            if((Object)inputMap.get('isMovel') == true){
                List<Product2> availabilityList = [Select Id, name, family, ProductCode FROM Product2 WHERE vlocity_cmt__Type__c = 'Plano' AND Id =:prodsAvailable AND Family = 'Movel' AND TemplateOrderId__c != '' AND (NOT ProductCode LIKE '%_REST_%')];
                List<Product2> productList = [SELECT ProductCode FROM Product2 WHERE Family = 'Movel'];
                List<Product2> catalogList = getCatalogProducts(varOrder.TechViabilityHFC__c, varOrder.TechViabilityFibra__c, productList, true);
                for(Product2 prod : catalogList){
                    for(Product2 availabilityProd : availabilityList){
                        if(prod.ProductCode == availabilityProd.ProductCode){
                            allPlans.add(availabilityProd);
                        }
                    }
                }
            }else{
                List<Product2> availabilityList = [Select Id, name, family, ProductCode FROM Product2 WHERE vlocity_cmt__Type__c = 'Plano' AND Id=:prodsAvailable AND TemplateOrderId__c != '' AND (NOT ProductCode LIKE '%_REST_%')];
                List<Product2> productList = [SELECT ProductCode FROM Product2];
                List<Product2> catalogList = getCatalogProducts(varOrder.TechViabilityHFC__c, varOrder.TechViabilityFibra__c, productList, false);
                for(Product2 prod : catalogList){
                    for(Product2 availabilityProd : availabilityList){
                        if(prod.ProductCode == availabilityProd.ProductCode){
                            allPlans.add(availabilityProd);
                        }
                    }
                }
            }      
        }
        Set<Id> allProds = new Set<Id>();
        for(Product2 varProd : allPlans)
        {
            allProds.add(varProd.Id);
        }
        
        List<Pricing_Matrix__c> lstRows = [SELECT Source_Product__r.Family, Group__c, Duration__c, Source_Product__r.IsActive, Modalidade__c, Source_Product__r.vlocity_cmt__Type__c, PricingValue__c
                                             FROM Pricing_Matrix__c 
                                             WHERE  Active__c = true AND Group__c IN :setGroup  
                                                    AND RecordType.DeveloperName = 'Pricing' 
                                                    AND Source_Product__r.Family IN : setFamily
                                                    AND Source_Product__r.IsActive = true 
                                                    AND Source_Product__r.vlocity_cmt__Type__c = 'Plano'
                                                 	AND Source_Product__c IN :allProds
                                           			AND ((End_Date__c = null AND Start_Date__c <= TODAY) OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY))
                                                 	ORDER BY PricingValue__c ASC
                                                    LIMIT 50000];
 
        Map<Id, Pricing_Matrix__c> mapIdProdAndRow = new Map<Id, Pricing_Matrix__c>();
        for(Pricing_Matrix__c row : lstRows)
        {mapIdProdAndRow.put(row.Source_Product__c, row);}
        
        Map<Id, Product2> mapProducts = new Map<Id, Product2>([SELECT Id, Name, Family, vlocity_cmt__Type__c, vlocity_cmt__SubType__c, TemplateOrderId__c, ProductCode, Technical_Description__c, Sequencia__c, vlocity_cmt__AttributeDefaultValues__c
                                                     FROM Product2 WHERE Id IN :mapIdProdAndRow.keySet()]);
        Map<Id, Object> mapTechnical = new Map<Id, Object>();
        for(Product2 varProd : mapProducts.values())
        {
            if(varProd.vlocity_cmt__AttributeDefaultValues__c != null && varProd.Family == 'Internet Fixa'){
                Object attribute = parseAttribute(varProd.vlocity_cmt__AttributeDefaultValues__c, varOrder.TechViabilityFibra__c);
                mapTechnical.put(varProd.Id, attribute);
            }
            if(varProd.Technical_Description__c != null && varProd.Family == 'TV')
            {
                Object technical = parseTechnical(varProd.Technical_Description__c, varOrder.TechViabilityFibra__c);
                mapTechnical.put(varProd.Id, technical);
            }
        }
        
        List<PricebookEntry> lstPriceEntry = [SELECT id,product2id,name FROM PricebookEntry 
                                              WHERE Product2Id IN :mapIdProdAndRow.keySet() LIMIT 50000];
        
        Map<String, String> mapIdProdAndIdPriceNetry = new Map<String, String>();
        for(PricebookEntry entry : lstPriceEntry)
        {mapIdProdAndIdPriceNetry.put(entry.Product2Id, entry.Id);}

        
        List<vlocity_cmt__VlocityAttachment__c> lstAttachs = [SELECT id,vlocity_cmt__objectid__c, name,vlocity_cmt__urllong__c FROM vlocity_cmt__VlocityAttachment__c 
                                                               WHERE vlocity_cmt__ObjectId__c IN :mapIdProdAndRow.keySet() LIMIT 50000];
        
        List<Object> lstProductsFone = new List<Object>();
        List<Object> lstProductsTV = new List<Object>();
        List<Object> lstProductsInternet = new List<Object>();
        List<Object> lstProductsMovel = new List<Object>();
        Map<String, List<Object>> mapFamilyList = new Map<String, List<Object>>();
        Map<String, String> mapFamilyIcon = new Map<String, String>();
        Map<String, String> mapProdGroup = new Map<String, String>();
        
        for(Product2 product : mapProducts.values())
        {
            if(product.Family == 'TV')
            {
                mapProdGroup.put(product.Id, varOrder.TV_Grupo__c);
            }
            else if(product.Family == 'Internet Fixa')
            {
                mapProdGroup.put(product.Id, varOrder.Internet_Grupo__c);
            }
            else if(product.Family == 'Fone')
            {
                mapProdGroup.put(product.Id, varOrder.Fone_Grupo__c);
            }
            else if(product.Family == 'Movel')
            {
                mapProdGroup.put(product.Id, varOrder.Movel_Grupo__c);
            }
        }

        for(Product2 product : mapProducts.values())
        {
            Map<Id, List<Object>> mapIdProdAndAttachs = new Map<Id, List<Object>>();
            Map<Id, List<Object>> mapIdProdAndPrices = new Map<Id, List<Object>>();
            List<Object> lstAtt = new List<Object>();
            List<Object> lstPrices = new List<Object>();
            List<Object> lstAttObj = new List<Object>();

            for(vlocity_cmt__VlocityAttachment__c attach : lstAttachs)
            {
                Map<String, Object> mapAttach = new Map<String, Object>();
                if(product.Id == attach.vlocity_cmt__ObjectId__c)
                {
                    mapAttach.put('url', attach.vlocity_cmt__UrlLong__c);
                    mapAttach.put('title', attach.Name);
                    lstAttObj.add(mapAttach);
                }
            }
            mapIdProdAndAttachs.put(product.Id, lstAttObj);

            for(Pricing_Matrix__c row : lstRows)
            {
                if(product.Id == row.Source_Product__c && mapProdGroup.get(product.Id) == row.Group__c)
                {
                    if(row.PricingValue__c != null)
                    {
                        if((row.Duration__c == 12 && (product.Family == 'TV' || product.Family == 'Internet Fixa' || product.Family == 'Movel')) || row.Duration__c == 0 && (product.Name.contains('3GB') || product.Family == 'Fone'))
                        {
                            if(row.Modalidade__c == 'INDIVIDUAL')
                            {
                                Map<String, Object> mapPrices = new Map<String, Object>();
                                mapPrices.put('modalidade', row.Modalidade__c);
                                mapPrices.put('valor', row.PricingValue__c);
                                lstPrices.add(mapPrices);
                            }
                        }
                    }
                }
            }
            mapIdProdAndPrices.put(product.Id, lstPrices);
            
            List<Object> prices = mapIdProdAndPrices.get(product.Id);
            if(prices.isEmpty())
            {
                for(Pricing_Matrix__c row : lstRows)
                {
                    if(product.Id == row.Source_Product__c && mapProdGroup.get(product.Id) == row.Group__c)
                    {
                        if(row.PricingValue__c != null)
                        {
                            if(row.Duration__c == 0 && (product.Family == 'TV' || product.Family == 'Internet Fixa' || product.Family == 'Movel'))
                            {
                                if(row.Modalidade__c == 'INDIVIDUAL')
                                {
                                    Map<String, Object> mapPrices = new Map<String, Object>();
                                    mapPrices.put('modalidade', row.Modalidade__c);
                                    mapPrices.put('valor', row.PricingValue__c);
                                    lstPrices.add(mapPrices);
                                }
                            }
                        }
                    }
                }
                mapIdProdAndPrices.put(product.Id, lstPrices);
            }
            
            
            Map<String, Object> mapProduct = new Map<String, Object>();
            mapProduct.put('vlocity_cmt__Type__c', product.vlocity_cmt__Type__c);
            mapProduct.put('vlocity_cmt__SubType__c', product.vlocity_cmt__SubType__c);
            mapProduct.put('TemplateOrderId__c', product.TemplateOrderId__c);
            mapProduct.put('Sequencia__c', product.Sequencia__c);
            mapProduct.put('Name', product.Name);
            mapProduct.put('Id', product.Id);
            mapProduct.put('Family', product.Family);
            mapProduct.put('Unidade', varOrder.Unidade__c);
            mapProduct.put('Restrito', mapProdRestricao.containsKey(product.Id) ? mapProdRestricao.get(product.Id) : false);
            mapProduct.put('vlocity_cmt__RecurringPrice__c', '0');
            mapProduct.put('Attachments', mapIdProdAndAttachs.get(product.Id));
            mapProduct.put('PBEId', mapIdProdAndIdPriceNetry.get(product.Id));
            mapProduct.put('prices', mapIdProdAndPrices.get(product.Id));
            
            if(mapTechnical.get(product.Id) != null)
            {
                mapProduct.put('Technical_Description__c', mapTechnical.get(product.Id));
            }
            
            If(product.Family == 'TV')
            {
               lstProductsTV.add(mapProduct);
                mapFamilyList.put(product.Family, lstProductsTV);
                mapFamilyIcon.put(product.Family, '/resource/cec_identidade/images-upload/comercial/icon-tv.png');
            }
            If(product.Family == 'Movel')
            {
               lstProductsMovel.add(mapProduct);
                mapFamilyList.put(product.Family, lstProductsMovel);
                mapFamilyIcon.put(product.Family, '/resource/cec_identidade/images-upload/comercial/icon-mobile.png');
            }
            If(product.Family == 'Internet Fixa')
            {
                lstProductsInternet.add(mapProduct);
                mapFamilyList.put(product.Family, lstProductsInternet);
                mapFamilyIcon.put(product.Family, '/resource/cec_identidade/images-upload/comercial/icon-internet.png');
            }
            If(product.Family == 'Fone')
            {
                lstProductsFone.add(mapProduct);
                mapFamilyList.put(product.Family, lstProductsFone);
                mapFamilyIcon.put(product.Family, '/resource/cec_identidade/images-upload/comercial/icon-phone.png');
            }
        }
        List<Object> lstFamilies = new List<Object>();
        for (String family : setFamily)
        {
            Family objFamily = new Family();
            objFamily.familyName = family;
            objFamily.familyIcon = mapFamilyIcon.get(family);
            objFamily.products = mapFamilyList.get(family);
            if(objFamily.products != null)
            {
                lstFamilies.add(objFamily);
            }
        }
        map<String, Object> groupsByFamily = new map<String, Object>();
        groupsByFamily.put('TV_Grupo__c', cityGroup.TV__c);
        groupsByFamily.put('Internet_Grupo__c', cityGroup.Internet__c);
        groupsByFamily.put('Fone_Grupo__c', cityGroup.Phone__c);
        groupsByFamily.put('Movel_Grupo__c', cityGroup.Mobile__c);
        groupsByFamily.put('Empacotado_Grupo__c', cityGroup.Empacotado__c);
        
        outMap.put('productsByFamily',lstFamilies);
        outMap.put('GroupsByFamily', groupsByFamily);
        return true;
    }

    /*
* Autor: Thayná Morim Barreto - Deloitte
* Data: 16-set-2020
* Descrição: Método responsável por obter resultados do Catálogo vigente de acordo com a viabilidade técnica.
*/  
	public static List<Product2> getCatalogProducts(Boolean hfc, Boolean fibra, List<Product2> productCode, Boolean isMovel){
        List<String> catalogType = new List<String>{'Internet Fixa', 'TV', 'Fone', 'Movel'};
        List<Product2> productCatalogList = new List<Product2>();
        
        if(isMovel == false){
            for(String catalog : catalogType){
                Map<String, Object> input = new Map<String, Object>();
                Map<String, Object> output = new Map<String, Object>();
                Map<String, Object> options = new Map<String, Object>();
                input.put('apiName', 'getOffers');
                
                if(catalog == 'Internet Fixa'){
                    String hfcString = hfc == true ? 'True' : 'False';
                    String fibraString = fibra == true ? 'True' : 'False';
                    String jsonContextString = '{"TechViabilityFibra":"' + fibraString  + '","TechViabilityHFC":"' + hfcString + '"}';
                    input.put('requestURL', '/services/apexrest/vlocity_cmt/v3/catalogs/CATALOG_PF_PLANO_INTERNETFIXA/offers');
                    input.put('catalogCode', 'CATALOG_PF_PLANO_INTERNETFIXA');
                    input.put('context', jsonContextString);
                } else if (catalog == 'TV'){
                    input.put('requestURL', '/services/apexrest/vlocity_cmt/v3/catalogs/CATALOG_PF_PLANO_TV/offers');
                    input.put('catalogCode', 'CATALOG_PF_PLANO_TV');
                } else if (catalog == 'Fone'){
                    input.put('requestURL', '/services/apexrest/vlocity_cmt/v3/catalogs/CATALOG_PF_PLANO_FONE/offers');
                    input.put('catalogCode', 'CATALOG_PF_PLANO_FONE');
                } else {
                    input.put('requestURL', '/services/apexrest/vlocity_cmt/v3/catalogs/CATALOG_PF_PLANO_MOVEL/offers');
                    input.put('catalogCode', 'CATALOG_PF_PLANO_MOVEL');
                }
                vlocity_cmt.CpqAppHandler cpqAppHandlerService = new vlocity_cmt.CpqAppHandler();
                cpqAppHandlerService.invokeMethod('getOffersByCatalogCode', input, output, options);
                
                String offerString = JSON.serialize(output.get('offers'));
                for(Product2 prod : productCode){
                    if(String.isNotBlank(prod.ProductCode) && String.isNotBlank(offerString) && offerString.contains(prod.ProductCode)){
                        productCatalogList.add(prod);
                    }                    
                }
            }
        }else{
            Map<String, Object> input = new Map<String, Object>();
            Map<String, Object> output = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            input.put('apiName', 'getOffers');
            input.put('requestURL', '/services/apexrest/vlocity_cmt/v3/catalogs/CATALOG_PF_PLANO_MOVEL/offers');
            input.put('catalogCode', 'CATALOG_PF_PLANO_MOVEL');
            vlocity_cmt.CpqAppHandler cpqAppHandlerService = new vlocity_cmt.CpqAppHandler();
            cpqAppHandlerService.invokeMethod('getOffersByCatalogCode', input, output, options);
                
            String offerString = JSON.serialize(output.get('offers'));
            for(Product2 prod : productCode){
                    if(String.isNotBlank(prod.ProductCode) && String.isNotBlank(offerString) && offerString.contains(prod.ProductCode)){
                        productCatalogList.add(prod);
                    }                    
                }
        	}
        return productCatalogList;
    }

    public static TechnicalDescription parseTechnical(String json, Boolean fibra) 
    {
        map<String, String> lMapResWord = new map<String, String>{ '" :' => '":', '"Franquia Total":' => '"Franquia":', '"Franquia TotalGPON":' => '"FranquiaGPON":'};
                for (String iJsonAttr: lMapResWord.keyset())
            {
                json = json.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
            }
        
        TechnicalDescription techDesc = (TechnicalDescription)System.JSON.deserialize(json, TechnicalDescription.class);
        
        techDesc.Franquia = fibra ? techDesc.FranquiaGPON : techDesc.Franquia;
        techDesc.Upload = fibra ? techDesc.UploadGPON : techDesc.Upload;
        techDesc.FranquiaGPON = null;
        techDesc.UploadGPON = null;
        return techDesc;
    }
    public static TechnicalDescription parseAttribute(String json, Boolean fibra){
        attributeString attDefault = (attributeString)System.JSON.deserialize(json, attributeString.class);
        TechnicalDescription techAtt = new TechnicalDescription();
        techAtt.Franquia = fibra == true ? attDefault.ATT_PF_FRANQUIA_FIBRA : attDefault.ATT_PF_FRANQUIA_HFC;
        techAtt.Upload = fibra == true? attDefault.ATT_PF_UP_FIBRA : attDefault.ATT_PF_UP_HFC; 
        techAtt.Download = attDefault.ATT_PF_DOWNLOAD;
        techAtt.FranquiaGPON = null;
        techAtt.UploadGPON = null;
        return techAtt;        
    }

  public static Set<Id> getAvailability(String city, String typeProduct, boolean restricao, String modalidade, Id orderTemplateId)
    {
        Set<Id> setAvailableProdAdd = new Set<Id>();
        Set<Id> setProdId = new Set<Id>();
        
        List<vlocity_cmt__ProductAvailability__c> lstAllAvailability = new List<vlocity_cmt__ProductAvailability__c>();
        List<vlocity_cmt__ProductRelationship__c> lstNotSell = new List<vlocity_cmt__ProductRelationship__c>();
        List<OrderItem> lstProducts = new List<OrderItem>();
		             
        if(typeProduct != 'Optional' && !restricao){
        	lstProducts = [Select Id, Product2Id from OrderItem where Product2.vlocity_cmt__Type__c = 'Plano' AND Order.RecordType.DeveloperName='OrderTemplate' 
                           AND (NOT vlocity_cmt__Product2Id__r.ProductCode LIKE '%_REST_%')
                           AND ((Product2.vlocity_cmt__EndDate__c != null AND Product2.vlocity_cmt__EffectiveDate__c <= TODAY AND Product2.vlocity_cmt__EndDate__c >= TODAY) OR Product2.vlocity_cmt__EffectiveDate__c <= TODAY) ];            
        }else if( typeProduct != 'Plano' && !restricao) {
        	lstProducts = [Select Id, Product2Id from OrderItem where Product2.vlocity_cmt__Type__c != 'Plano' AND Order.RecordType.DeveloperName='OrderTemplate' 
                           AND (NOT vlocity_cmt__Product2Id__r.ProductCode LIKE '%_REST_%') AND OrderId =:orderTemplateId
                           AND ((Product2.vlocity_cmt__EndDate__c != null AND Product2.vlocity_cmt__EffectiveDate__c <= TODAY AND Product2.vlocity_cmt__EndDate__c >= TODAY) OR Product2.vlocity_cmt__EffectiveDate__c <= TODAY) ];                                    
        }else if(restricao){
        	lstProducts = [Select Id, Product2Id from OrderItem where Product2.vlocity_cmt__Type__c = 'Plano' 
                           AND vlocity_cmt__Product2Id__r.ProductCode LIKE '%_REST_%' AND  Order.RecordType.DeveloperName='OrderTemplate'
                           AND ((Product2.vlocity_cmt__EndDate__c != null AND Product2.vlocity_cmt__EffectiveDate__c <= TODAY AND Product2.vlocity_cmt__EndDate__c >= TODAY) OR Product2.vlocity_cmt__EffectiveDate__c <= TODAY) ];                                    
        }
        
        for(OrderItem prod : lstProducts){setProdId.add(prod.Product2Id);}        

        
        lstAllAvailability = [select Name, Type__c, Group_Set__c ,vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__c, vlocity_cmt__City__c 
                                  from vlocity_cmt__ProductAvailability__c 
                                  WHERE vlocity_cmt__Product2Id__c =: setProdId
                                  AND vlocity_cmt__Product2Id__r.isActive = true
                                  AND ((vlocity_cmt__EndDate__c != null AND vlocity_cmt__StartDate__c <= TODAY AND vlocity_cmt__EndDate__c >= TODAY) OR vlocity_cmt__StartDate__c <= TODAY)                                   
                                  ORDER BY vlocity_cmt__Product2Id__r.Name ASC];
        
        setAvailableProdAdd.addAll(setProdId);

        lstNotSell = [SELECT Id, Modalidade__c, vlocity_cmt__RelationshipType__c,  vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__c 
                      FROM vlocity_cmt__ProductRelationship__c 
                      WHERE vlocity_cmt__RelationshipType__c = 'Not Sell'
                      AND vlocity_cmt__Product2Id__r.isActive = true
                      AND Modalidade__c = :modalidade];
        

        for(Id prodId : setProdId)
        {
            for(vlocity_cmt__ProductAvailability__c avl : lstAllAvailability)
            {
                if(!String.isBlank(avl.vlocity_cmt__City__c) && String.isBlank(avl.Group_Set__c))
                {
                    if(prodId == avl.vlocity_cmt__Product2Id__c && avl.vlocity_cmt__City__c.equalsIgnoreCase(city) && avl.Type__c == 'Not Available'){
                        setAvailableProdAdd.remove(avl.vlocity_cmt__Product2Id__c);
                    }
                    
                    if(prodId == avl.vlocity_cmt__Product2Id__c && avl.vlocity_cmt__City__c.equalsIgnoreCase(city) && avl.Type__c == 'Available'){
                        setAvailableProdAdd.add(avl.vlocity_cmt__Product2Id__c);       
                        break; 
                    }
                    else if(prodId == avl.vlocity_cmt__Product2Id__c && !avl.vlocity_cmt__City__c.equalsIgnoreCase(city) && avl.Type__c == 'Available'){                    
                        setAvailableProdAdd.remove(avl.vlocity_cmt__Product2Id__c);
                    }  
                }
                else
                {
                    setAvailableProdAdd.remove(avl.vlocity_cmt__Product2Id__c);
                }
            }
        }
        
        for(vlocity_cmt__ProductRelationship__c avl : lstNotSell){
            setAvailableProdAdd.remove(avl.vlocity_cmt__Product2Id__c);
        }
       return setAvailableProdAdd;
    }
    
        public static Boolean getBonus(Map<String, Object> inputMap, Map<String, Object> outMap,
                                              Map<String, Object> options) 
    {
        List<sObject> itemList = (List<sObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        String RecordType = '';  
        for(sObject obj : itemList)
        {
            RecordType = controller.getObjectNameByChildPrefix(obj.get('Id'));
            break;
        }
        if (RecordType != 'OrderItem') 
        {
            return true;
        }
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        Order varOrder = [Select TV_Grupo__c, City__c,  Internet_Grupo__c , Fone_Grupo__c, Movel_Grupo__c, Empacotado_Grupo__c, vlocity_cmt__PriceListId__r.Name,
                          (
                           Select id, product2.Family, Portabilidade__c, product2Id 
                           from OrderItems
                           WHERE Product2.vlocity_cmt__Type__c = 'Plano'
                          ) 
                          from Order WHERE Id = :(String)parent.get('Id')];
        
        if(varOrder.vlocity_cmt__PriceListId__r.Name != 'Comercial Residencial')
        {
            return true;
        }
        
        set<Id> setProducts = new set<Id>();
        for(OrderItem item : varOrder.OrderItems)
        {
           setProducts.add(item.Product2Id);
        }
        update varOrder.OrderItems;
        

        List<Bonus__c> lstBonus = [SELECT Id, Name, RecordTypeId, Business_Unit__c, Codigo_Bonus__c, Bonus__c, Cidade__c, End_Date__c, 
                                   Fone__c, Franquia_Bonus__c, Internet__c, Movel__c, Modalidade__c, Produto__c, Start_Date__c, 
                                   Tipo_Bonus__c, TV__c 
                                   FROM Bonus__c 
                                   WHERE Produto__c IN :setProducts 
                                   AND Modalidade__c = :(String)vlocity_cmt.PricingPlanService.getFromPricingContext('CartState') 
                                   AND (Cidade__c = :varOrder.City__c OR Cidade__c = '-') 
                                   AND ((End_Date__c = null AND Start_Date__c <= TODAY) 
                                        OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY)) 
                                   Order By Tipo_Bonus__c ASC, Cidade__c];
        
        
        
        String tvClause;
        String internetClause;
        String movelClause;
        String foneClause;
        
        if(lstBonus.size() == 0)
        {
            for(sObject item : itemList)
            {
                OrderItem itemContext = (OrderItem)item;
                itemContext.Descricao_Bonus__c = '';
                itemContext.Descricao_Bonus_Outro__c = '';
                itemContext.CodigoBonus__c = '';
            }
            return true;
        }
        for(OrderItem item : varOrder.OrderItems)
        {
            if(item.Product2.Family == 'TV')
            {
                tvClause = item.Product2Id;
            }
            else if(item.Product2.Family == 'Internet Fixa')
            {
                internetClause = item.Product2Id;
            }
            else if(item.Product2.Family == 'Fone')
            {
                foneClause = item.Product2Id;
            }
            else if(item.Product2.Family == 'Movel')
            {
                movelClause = item.Product2Id;
            }
        }
        List<OrderItem> toUpdate = new List<OrderItem>();
        map<Id, OrderItem> mapToUpdate = new map<Id, OrderItem>();
        
        for(OrderItem item : varOrder.OrderItems)
        {
            for(sObject itemContext : itemList)
            {
                OrderItem itemContextCast = (OrderItem)itemContext; 
                if(item.id == itemContext.Id)
                {
                    itemContextCast.Descricao_Bonus__c = '';
                    itemContextCast.Descricao_Bonus_Outro__c = '';
                    itemContextCast.CodigoBonus__c = '';
                    for(Bonus__c bonus : lstBonus)
                    {
                        Boolean isvalid = true;
                        if(bonus.Produto__c == item.Product2Id)
                        {
                            if(bonus.TV__c != null && tvClause != bonus.TV__c)
                            {
                                isvalid = false;
                            }
                            if(bonus.Internet__c != null && internetClause != bonus.Internet__c)
                            {
                                isvalid = false;
                            }
                            if(bonus.Fone__c != null && foneClause != bonus.Fone__c)
                            {
                                isvalid = false;
                            }
                            if(bonus.Movel__c != null && movelClause != bonus.Movel__c)
                            {
                                isvalid = false;
                            }
                            

                            
                            if(bonus.Tipo_Bonus__c == 'Portabilidade' && item.Portabilidade__c)
                            {	
                                if(isvalid)
                                {
                                    itemContextCast.Descricao_Bonus__c = bonus.Bonus__c;
                                    itemContextCast.CodigoBonus__c = bonus.Codigo_Bonus__c;
                                }
                            } 
                            else if (bonus.Tipo_Bonus__c == 'Dobro' || bonus.Tipo_Bonus__c == 'Franquia')
                            {
                                if(isvalid)
                                {
                                    itemContextCast.Descricao_Bonus_Outro__c = bonus.Bonus__c;
                                }
                            }
                        }
                    }
                }
            } 
        }
            return true;
    }
    public static Boolean setFidelityItems(Map<String, Object> inputMap, Map<String, Object> outMap,
                                           Map<String, Object> options) 
    {
        List<Sobject> itemList = (List<Sobject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        String RecordType = '';  
        for(Sobject obj : itemList)
        {
            RecordType = controller.getObjectNameByChildPrefix(obj.get('Id'));
            break;
        }
        if (RecordType != 'OrderItem') 
        {
            return true;
        }
        
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        Order varOrder = [Select TV_Grupo__c, City__c,  Internet_Grupo__c , vlocity_cmt__PriceListId__r.Name, Fone_Grupo__c, Movel_Grupo__c, Empacotado_Grupo__c, 
                          (
                              Select id, product2.Family, Portabilidade__c, Grupo__c, product2Id 
                              from OrderItems
                              WHERE Product2.vlocity_cmt__Type__c = 'Plano' 
                              OR Product2.vlocity_cmt__Type__c = 'Ponto Opcional' 
                              OR Product2.vlocity_cmt__Type__c = 'Dependente'
                          ) 
                          from Order WHERE Id = :(String)parent.get('Id')];
        
        
        vlocity_cmt.PricingPlanService.putInPricingContext('priceListName', varOrder.vlocity_cmt__PriceListId__r.Name);
        if(varOrder.vlocity_cmt__PriceListId__r.Name != 'Comercial Residencial')
        {
            return true;
        }
        Set<String> setProductId = new Set<String>();
        Set<String> setGroup = new Set<String>();
        map<Id, List<Pricing_Matrix__c>> mapProdPrices = new map<Id, List<Pricing_Matrix__c>>();
        map<Id, Decimal> mapItemsFidelity = new map<Id, Decimal>();
        List<OrderItem> itemsToUpdate = new List<OrderItem>();
        for(OrderItem item : varOrder.OrderItems)
        {
            setProductId.add(item.Product2Id);
            setGroup.add(item.Grupo__c);
        }    
        for(OrderItem item : varOrder.OrderItems)
        {
            List<Pricing_Matrix__c> lstRows = new List<Pricing_Matrix__c>();
            for(Pricing_Matrix__c row : [SELECT Id, PricingValue__c, Source_Product__c, Group__c, Duration__c, Source_Product_Code__c, Source_Product__r.Family, Source_Product__r.ProductCode, Source_Product__r.vlocity_cmt__Type__c, Pricing_Var_Code__c, Pricing_Var_Binding_Field__c, Pricing_Variable_Code__c
                                         FROM Pricing_Matrix__c
                                         WHERE Source_Product__c IN :setProductId
                                         AND Group__c IN :setGroup
                                         AND DDD__c = '-'
                                         AND Modalidade__c = :(String)vlocity_cmt.PricingPlanService.getFromPricingContext('CartState')
                                         AND ((End_Date__c = null AND Start_Date__c <= TODAY) OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY))
                                         AND RecordType.developerName = 'Pricing'
                                         ORDER BY Duration__c DESC])
            {
                if(item.Product2Id == row.Source_Product__c && item.Grupo__c == row.Group__c)
                {
                    lstRows.add(row);
                }
            }
            if(!lstRows.isEmpty())
            {
                mapProdPrices.put(item.id, lstRows);
            }
        }
        for(sObject item : itemList)
        {
            OrderItem itemContext = (OrderItem)item;
            List<Pricing_Matrix__c> lstPrice = mapProdPrices.get(item.Id);
            if(lstPrice != null && lstPrice.size() == 1)
            {
                boolean fidelidade = lstPrice[0].Duration__c > 0 ? true : false;
                itemContext.Fidelidade__c = fidelidade;
                mapItemsFidelity.put(itemContext.Id, lstPrice[0].Duration__c);
            }
            else
            {
                mapItemsFidelity.put(itemContext.Id, itemContext.Fidelidade__c == true ? 12 : 0);
            }
            
        }
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', itemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('ItemsFidelity', mapItemsFidelity);
        return true;
    }
	 public static Boolean notSellProducts(Map<String, Object> inputMap, Map<String, Object> outMap,
                                          Map<String, Object> options) 
    {
        List<SObject> sObjectItemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        List<OrderItem> itemsToDelete = new List<OrderItem>();
        
        //List<OrderItem> itemList = (List<OrderItem>)sObjectItemList;
        Set<Id> setLineItemId = new Set<Id>();
        for(sObject item : sObjectItemList)
        {
            setLineItemId.add((String)item.get('Id'));
        }
        
        List<OrderItem> lstOrderLi = [SELECT Id, Product2.ProductCode, Fidelidade__c, Order.Unidade__c, Order.vlocity_cmt__PriceListId__r.Name, (Select Id from vlocity_cmt__OrderPricingAdjustments__r), Order.Cart_State__c, Order.TipoFatura__c, Acrescimo_Desconto__c, Product2.vlocity_cmt__SubType__c, Product2.vlocity_cmt__Type__c, Grupo__c, Meses_de_Fidelidade__c, DDD__c, Product2.Name, Product2.Family, Order.Forma_de_Pagamento__c, vlocity_cmt__RecurringCharge__c, ReliesOnReferenceId__c, vlocity_cmt__AssetReferenceId__c 
                                      FROM OrderItem 
                                      Where Id =: setLineItemId];
                
        List<vlocity_cmt__ProductRelationship__c>  lstNotSell = [SELECT Id, Modalidade__c, vlocity_cmt__RelationshipType__c,  vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__c 
                                                                 FROM vlocity_cmt__ProductRelationship__c 
                                                                 WHERE vlocity_cmt__RelationshipType__c = 'Not Sell'
                                                                 AND vlocity_cmt__Product2Id__r.isActive = true
                                                                 AND Modalidade__c = :(String)vlocity_cmt.PricingPlanService.getFromPricingContext('CartState')];
        
        if(!lstNotSell.isEmpty())
        {
            for(vlocity_cmt__ProductRelationship__c relationship : lstNotSell)
            {
                for(OrderItem item : lstOrderLi)
                {
                    if(item.Product2Id == relationship.vlocity_cmt__Product2Id__c)
                    {
                        itemsToDelete.add(item);
                    }
                }
            }
        }
        if(!itemsToDelete.isEmpty())
        {
            for(OrderItem item : itemsToDelete)
            {
                for (Integer i = 0; i < sObjectItemList.size(); i++)
                {
                    if(sObjectItemList[i].get('Id') == item.Id)
                    {
                        sObjectItemList.remove(i);
                    }
                }
            }
            delete itemsToDelete;
        }
         vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', sObjectItemList);
        return true;
    }
    
    public static Boolean getDependentEmbeddedProducts(Map<String, Object> inputMap, Map<String, Object> outMap,
                                                      Map<String, Object> options) 
    {
        String planoProdsTemplateId = (String)inputMap.get('templateOrderIds');
        String groupMobile = (String)inputMap.get('Group');
        String cartState = (String)inputMap.get('cartState');
        List<OrderItem> embeddedTemplateItems = [Select id, product2.Family, PricebookEntryId, AvailableQuantity,  product2Id, OrderId, Forma_de_Pagamento__c, 
                                                 TemplateDefaultQty__c, Avoid_vlc_pricing__c, TemplateMaxQty__c, TemplateMinQty__c, Fidelidade__c, Product2.vlocity_cmt__Type__c,
                                                 ProductCode__c, ReliesOnReferenceId__c, vlocity_cmt__AssetReferenceId__c, product2.Name
                                                 from OrderItem 
                                                 WHERE (OrderId = :planoProdsTemplateId
                                                         AND TemplateMinQty__c = '1'
                                                         AND TemplateDefaultQty__c = '1'
                                                         AND TemplateMaxQty__c = '1'
                                                         AND ReliesOnReferenceId__c != '')
                                                 OR (OrderId = :planoProdsTemplateId 
                                                     AND Product2.vlocity_cmt__Type__c = 'Dependente')];
        set<Id>setIdSource = new Set<Id>();
        for(OrderItem item : embeddedTemplateItems)
        {
            if(item.Product2.vlocity_cmt__Type__c == 'Dependente')
            {
                setIdSource.add(item.Product2Id);
            }
        }
        
            List<Pricing_Matrix__c> lstRows = [SELECT PricingValue__c, Source_Product__c
                                             FROM Pricing_Matrix__c 
                                             WHERE  Active__c = true AND Group__c = :groupMobile  
                                                    AND RecordType.DeveloperName = 'Pricing' 
                                                    AND Source_Product__r.IsActive = true
                                               		AND Source_Product__c = :setIdSource
                                                 	AND Modalidade__c = :cartState
                                           			AND ((End_Date__c = null AND Start_Date__c <= TODAY) OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY))
                                                 	ORDER BY PricingValue__c ASC
                                                    LIMIT 50000];
    
        map<Id, Decimal> prodPrice = new map<Id, Decimal>();
        for(Pricing_Matrix__c result :lstRows)
        {
            prodPrice.put(result.Source_Product__c, result.PricingValue__c);
        }
        
        
        List<Object> toReturn = new List<Object>();
        map<id, List<OrderItem>> itemsAndEmbeddeds = new map<id, List<OrderItem>>();
        for(OrderItem item : embeddedTemplateItems)
        {
            if(item.Product2.vlocity_cmt__Type__c == 'Dependente')
            {
                String assetPlanId = item.vlocity_cmt__AssetReferenceId__c;
                List<OrderItem> lstEmbed = new List<OrderItem>(); 
                for(OrderItem itemEmbedded : embeddedTemplateItems)
                {
                    if(itemEmbedded.ReliesOnReferenceId__c == assetPlanId
                       && itemEmbedded.Product2.vlocity_cmt__Type__c != 'Dependente')
                    {
                        itemEmbedded.vlocity_cmt__RecurringCharge__c = prodPrice.get(item.Product2Id);
                        
                        lstEmbed.add(itemEmbedded);
                        continue;
                    }
                }
                if(!lstEmbed.isEmpty())
                {
                    map<String, Object> embeddeds = new map<String, Object>();
                    embeddeds.put(item.Product2.Name, lstEmbed);
                    toReturn.add(embeddeds);
                    continue;
                }
            }
        }
        outMap.put('ItemsAndEmbeddeds', toReturn);
        return true;
    }
    public static Boolean setDiscountPricing(Map<String, Object> inputMap, Map<String, Object> outMap,
                                             Map<String, Object> options) 
    {
        List<Sobject> itemList = (List<Sobject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        String RecordType = '';  
        for(Sobject obj : itemList)
        {
            RecordType = controller.getObjectNameByChildPrefix(obj.get('Id'));
            break;
        }
        String priceListName = (String)vlocity_cmt.PricingPlanService.getFromPricingContext('priceListName');
        if (RecordType != 'OrderItem' || priceListName != 'Comercial Residencial') 
        {
            return true;
        }
        Set<Id> optionalIds = new Set<Id>();
        Set<String> setGroups = new Set<String>();
        Map<String, OrderItem> mapCodeOpcionaisId = new Map<String, OrderItem>();
        for(OrderItem item : (List<OrderItem>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList'))
        {
            if(item.PriceBookEntry.Product2.vlocity_cmt__Type__c != 'Plano' && item.PriceBookEntry.Product2.vlocity_cmt__Type__c != 'Dependente')
            { 
                optionalIds.add(item.PriceBookEntry.Product2Id);
            }
            else
            {
                setGroups.add(item.Grupo__c);
            }
        }
         List<Pricing_Matrix__c> lstRows = [SELECT PricingValue__c, Description__c, Target_Product__c, Produto_Opcional__r.ProductCode, Group__c
                                               FROM Pricing_Matrix__c
                                               WHERE Group__c IN :setGroups
                                               AND Produto_Opcional__c IN :optionalIds
                                               AND Active__c = true
                                               AND Modalidade__c = :(String)vlocity_cmt.PricingPlanService.getFromPricingContext('CartState')
                                               AND ((End_Date__c = null AND Start_Date__c <= TODAY) OR (Start_Date__c <= TODAY AND End_Date__c >= TODAY))
                                               AND RecordType.developerName = 'Discount_Pricing'];     
        SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        Id variableId;
        for(vlocity_cmt__PricingVariable__c variable : (List<vlocity_cmt__PricingVariable__c>)vlocity_cmt.PricingPlanService.getFromPricingContext('priceVariables'))
        {
            if(variable.vlocity_cmt__Code__c == 'REC_MNTH_STD_PRC_ADJ_ABS')
            {
                variableId = variable.Id;   
            }
        }
        List<Object> adjList = new  List<Object>();
        for(Pricing_Matrix__c result : lstRows)
        {
            for(OrderItem item : (List<OrderItem>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList'))
            {
                if(result.Target_Product__c == item.PriceBookEntry.Product2Id)
                {
                    if(item.PriceBookEntry.Product2.Family == 'Movel' && result.Group__c == (String)parent.get('Movel_Grupo__c'))
                    {
                           map<String, Object> drBody = new map<String, Object>{'Action'               => 'Add', 
                                                                        'AdjValue'              => null,
                                                                        'AdjAmount'             => result.PricingValue__c,
                                                                        'OrderId'               => (String)parent.get('Id'),
                                                                        'OrderItemId'           => item.Id,
                                                                        'PricingVar'            => variableId,
                                                                        'Source'                => 'Agent',
                                                                        'Name'                  => ''};
                        adjList.add(drBody);
                    }
                    if(item.PriceBookEntry.Product2.Family == 'Internet Fixa' && result.Group__c == (String)parent.get('Internet_Grupo__c'))
                    { 
                           map<String, Object> drBody = new map<String, Object>{'Action'               => 'Add', 
                                                                        'AdjValue'              => null,
                                                                        'AdjAmount'             => result.PricingValue__c,
                                                                        'OrderId'               => (String)parent.get('Id'),
                                                                        'OrderItemId'           => item.Id,
                                                                        'PricingVar'            => variableId,
                                                                        'Source'                => 'Agent',
                                                                        'Name'                  => ''};
                        adjList.add(drBody);                        
                    }
                }
            }
        }
        if(!adjList.isEmpty())
        {
            bulkdAdjustment(adjList);
        }
        
        return true;        
    }
    
    public class Family
    { 
        String familyName {get;set;}
        String familyIcon {get;set;}
        List<Object> products {get;set;} 
    }
    public class TechnicalDescription
    {
        public String Franquia {get;set;} 
        public String Upload {get;set;}
        public String FranquiaGPON {get;set;} 
        public String UploadGPON {get;set;}
        public String Download {get;set;} 
        public Channels Channels {get;set;} 
        public HDTV HDTV {get;set;} 
    }
    public class attributeString{
        public string ATT_PF_UP_HFC{get;set;}
        public string ATT_PF_UP_FIBRA{get;set;}
        public string ATT_PF_DOWNLOAD{get;set;}
        public string ATT_PF_FRANQUIA_HFC{get;set;}
        public string ATT_PF_FRANQUIA_FIBRA{get;set;}
    }
    public class Channels 
    {
        public String Digital {get;set;} 
        public String HD {get;set;} 
    }
    public class Attributes 
    {
        public String ATT_COM_Franquia {get;set;} 
        public Boolean ATTR_Indica_Rest {get;set;} 
    }
    
    public class HDTV 
    {
        public String Technology {get;set;} 
    }
        
    private class ItemDetails
    {
        String OrderId;
        String Product2Name;
        String ReliesOnReferenceId;
        String AssetReferenceId;
        String Id;
        List<Pricing_Matrix__c> Promotions;
        List<Pricing_Matrix__c> polComercials;
    }
}