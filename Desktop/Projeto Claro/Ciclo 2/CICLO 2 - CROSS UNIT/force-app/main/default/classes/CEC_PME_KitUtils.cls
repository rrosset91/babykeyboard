global class CEC_PME_KitUtils implements vlocity_cmt.VlocityOpenInterface {
    
    private Map<String, Object> input;
    private Map<String, Object> output;
    private Map<String, Object> options;
    private List<OpportunityLineitem> oppToUpdate;
    private List<OrderItem> orToUpdate;
    private String kitCode;
    
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        try {
            System.debug('input: ' + JSON.serialize(input));
            System.debug('output: ' + JSON.serialize(output));
            System.debug('options: ' + JSON.serialize(options));
            this.input = input;
            this.output = output;
            this.options = options;
            
            switch on methodName {
                when 'showKitProducts' {
                    this.showKitProducts(input, output,options);
                }
                when 'getDependentPicklistValues' {
                    this.getDependentPicklistValues(input, output,options);
                }
                when 'getPickListValues' {
                    this.getPickListValues(input, output,options);
                }
                when 'addKit' {
                    this.addKit(input, output,options);
                }
                when 'deleteKit' {
                    this.deleteKit(input, output,options);
                }
                when 'getManufacturer' {
                    this.getManufacturer(input, output,options);
                }
                when 'getModel' {
                    this.getModel(input, output,options);
                }
                when 'getDevices' {
                    this.getDevices(input, output,options);
                }                
                when 'getColor' {
                    this.getColor(input, output,options);
                }
            }
        } catch (Exception ex) {
            throw ex;
        }
        return true;
    }
    
    private void showKitProducts(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        try {  
          
            String orderId=String.valueOf(options.get('orderId'));
            String orderTemplateId=String.valueOf(options.get('orderTemplateId'));
            if(!String.isBlank(orderId)) {
                System.debug('ORDERID:'+orderId);
                String orderItemParentId=String.valueOf(options.get('orderItemParentId'));
                List<Object> orderProducts= (List<Object>) options.get('orderTemplateProducts');
            
                System.debug('MAMB OrderProducts => ' + orderProducts);
                
                Map<String,Object> productsById = new Map<String,Object>();
                List<String> productsId = new List<String>();
                String kitTemplateId='none';
                String kitDescription='none';
                
                for(Object obj : orderProducts) {
                    Map<String,Object> itemTemp = (Map<String,Object>) obj;
                    
                    if(String.valueOf(itemTemp.get('Name')).containsIgnoreCase('kit')) {
                        kitTemplateId=String.valueOf(itemTemp.get('ReliesOnReference'));
                        kitDescription=String.valueOf(itemTemp.get('Description'));
                    }
                    
                    productsById.put(String.valueOf(itemTemp.get('AssetReference')),itemTemp);
                    
                }
              
                List<Object>franquias = new List<Object>();
                String objectName='OrderItem';
                String whereClause='ReliesOnReferenceId__c = \''+kitTemplateId+'\' AND vlocity_cmt__AssetReferenceId__c <> \''+kitTemplateId +'\' AND OrderId= \''+orderTemplateId+'\' AND vlocity_cmt__product2id__r.productcode LIKE \'%Franquia%\' ';
                
                List<OrderItem> franquiaItems=getCopyableOrderItems(objectName,whereClause);
                
                for(OrderItem franquia:franquiaItems) {
                    Map<String,Object> franquiaSpecs = new Map<String,Object>();
                    List<Object> franquiaServices = new List<Object>();
                    List<Object> passaportes = new List<Object>();
                    List<Object> aparelhos= new List<Object>();
                    List<Object> listBonus = new List<Object>();
                    
                    Map<String,Object>product = (Map<String,Object>)productsById.get(String.valueOf(franquia.vlocity_cmt__AssetReferenceId__c));
                    
                    franquiaSpecs.put('Name',String.valueOf(product.get('Name')));
                    franquiaSpecs.put('ProductId',String.valueOf(product.get('ProductId')));
                    franquiaSpecs.put('Quantity',String.valueOf(product.get('DefaultQuantity')));
                    franquiaSpecs.put('Price',String.valueOf(product.get('EffectiveRecurringTotal')));
                    franquiaSpecs.put('ProductCode',String.valueOf(product.get('ProductCode')));
                    
                    franquiaSpecs.put('AssetReference',String.valueOf(product.get('AssetReference')));
                    ObjectName='OrderItem';
                    whereClause='ReliesOnReferenceId__c = \''+String.valueOf(product.get('AssetReference'))+'\' AND OrderId= \''+orderTemplateId+'\'';
                    List<OrderItem> franquiaChildItems=getCopyableOrderItems(objectName,whereClause);
                    for(OrderItem serviceItem:franquiaChildItems) {
                        String assetRef=String.valueOf(serviceItem.vlocity_cmt__AssetReferenceId__c);
                        Map<String,Object> productService=(Map<String,Object>)productsById.get(assetRef);
                        String name = String.valueOf(productService.get('Name'));
                        if(name.containsIgnoreCase('Passaporte')) {
                            Map<String,Object> singlePassport = new Map<String,Object>();
                            singlePassport.put('Name',name);
                            singlePassport.put('AssetReference',String.valueOf(productService.get('AssetReference')));
                            singlePassport.put('Price',String.valueOf(productService.get('EffectiveRecurringTotal')));
                            singlePassport.put('Quantity',String.valueOf(productService.get('DefaultQuantity')));
                            singlePassport.put('ProductId',String.valueOf(productService.get('ProductId')));
                            passaportes.add(singlePassport);
                        } else if(name.contains('Bônus') || name.contains('Bonus')) {
                            Map<String,Object> bonus = new Map<String,Object>();
                            bonus.put('Name', name);
                            bonus.put('AssetReference', String.valueOf(productService.get('AssetReference')));
                            bonus.put('Price', String.valueOf(productService.get('EffectiveRecurringTotal')));
                            bonus.put('Quantity', String.valueOf(productService.get('DefaultQuantity')));
                            listBonus.add(bonus);
                        } else if(!name.contains('AP')) {
                            Map<String,Object> singleService = new Map<String,Object>();
                            singleService.put('Name',name);
                            singleService.put('AssetReference',String.valueOf(productService.get('AssetReference')));
                            singleService.put('Price',String.valueOf(productService.get('EffectiveRecurringTotal')));
                            singleService.put('Quantity',String.valueOf(productService.get('DefaultQuantity')));
                            franquiaServices.add(singleService);                                
                        } else {
                            Map<String,Object> singleAparelho = new Map<String,Object>();
                            singleAparelho.put('Name',name);
                            singleAparelho.put('AssetReference',String.valueOf(productService.get('AssetReference')));
                            singleAparelho.put('Price',String.valueOf(productService.get('EffectiveRecurringTotal')));
                            singleAparelho.put('Quantity',String.valueOf(productService.get('DefaultQuantity')));
                            aparelhos.add(singleAparelho);
                        }
                        
                        
                        franquiaSpecs.put('Aparelhos', aparelhos);
                        franquiaSpecs.put('Pasaportes', passaportes);
                        franquiaSpecs.put('Servicios', franquiaServices);
                        franquiaSpecs.put('Bônus', listBonus);
                        
                        
                    }
                    franquias.add(franquiaSpecs);
                  
                }   
                output.put('KitReferenceId',kitTemplateId);
                output.put('Franquias',franquias);
                output.put('KitDescription',kitDescription);
                return;
            } 

            /////////////////////////OPPORTUNITY/////////////////////////////////////////////////////
            String opptyId=String.valueOf(options.get('opptyId'));
            String oppTemplateId=String.valueOf(options.get('oppTemplateId'));
                        
            if(!String.isBlank(opptyId)) {
                System.debug('OPPTYID:'+opptyId);   
                String oppItemParentId=String.valueOf(options.get('oppItemParentId'));
                List<Object> oppProducts= (List<Object>) options.get('oppTemplateProducts');
                system.debug('***oppProducts ' + oppProducts );
                Map<String,Object> productsById = new Map<String,Object>();
                List<String> productsId = new List<String>();
                String kitTemplateId='none';
                String kitDescription='none';

                for(Object obj : oppProducts) {
                    Map<String,Object> itemTemp = (Map<String,Object>) obj;
                    
                    if(String.valueOf(itemTemp.get('Name')).containsIgnoreCase('kit')) {
                        kitTemplateId=String.valueOf(itemTemp.get('ReliesOnReference'));
                        kitDescription=String.valueOf(itemTemp.get('Description'));
                    }
                    
                    productsById.put(String.valueOf(itemTemp.get('AssetReference')),itemTemp);
                    
                }
                
                
                List<Object>franquias = new List<Object>();
                String objectName='OpportunityLineItem';
                String whereClause='ReliesOnReferenceId__c = \''+kitTemplateId+'\' AND vlocity_cmt__AssetReferenceId__c <> \''+kitTemplateId +'\' AND OpportunityId=\''+oppTemplateId+'\' AND vlocity_cmt__product2id__r.productcode LIKE \'%Franquia%\'';
                
                List<OpportunityLineItem> franquiaItems=getCopyableOpportunityLineItems(objectName,whereClause);
              
                for(OpportunityLineItem franquia : franquiaItems) {
                    Map<String,Object> franquiaSpecs = new Map<String,Object>();
                    List<Object> franquiaServices = new List<Object>();
                    List<Object> passaportes = new List<Object>();
                    List<Object> aparelhos= new List<Object>();
                    List<Object> listBonus = new List<Object>();
                    
                    system.debug('***productsById ' + productsById);
                    system.debug('***productsById get ' + productsById.get(String.valueOf(franquia.vlocity_cmt__AssetReferenceId__c)));
                    system.debug('***franquia.vlocity_cmt__AssetReferenceId__c ' + franquia.vlocity_cmt__AssetReferenceId__c);
                    
                    Map<String,Object> product = (Map<String,Object>) productsById.get(String.valueOf(franquia.vlocity_cmt__AssetReferenceId__c));
                    
                    franquiaSpecs.put('Name',String.valueOf(product.get('Name')));
                    franquiaSpecs.put('ProductId',String.valueOf(product.get('ProductId')));
                    franquiaSpecs.put('Quantity',String.valueOf(product.get('DefaultQuantity')));
                    franquiaSpecs.put('Price',String.valueOf(product.get('EffectiveRecurringTotal')));
                    
                    franquiaSpecs.put('AssetReference',String.valueOf(product.get('AssetReference')));
                    ObjectName='OpportunityLineItem';
                    whereClause='ReliesOnReferenceId__c = \''+String.valueOf(product.get('AssetReference'))+'\' AND OpportunityId=\''+oppTemplateId+'\'';
                    List<OpportunityLineItem> franquiaChildItems=getCopyableOpportunityLineItems(objectName,whereClause);
                    for(OpportunityLineItem serviceItem:franquiaChildItems) {
                        String assetRef=String.valueOf(serviceItem.vlocity_cmt__AssetReferenceId__c);
                        Map<String,Object> productService=(Map<String,Object>)productsById.get(assetRef);
                        String name = String.valueOf(productService.get('Name'));
                        if(name.containsIgnoreCase('Passaporte')) {
                            Map<String,Object> singlePassport = new Map<String,Object>();
                            singlePassport.put('Name',name);
                            singlePassport.put('AssetReference',String.valueOf(productService.get('AssetReference')));
                            singlePassport.put('Price',String.valueOf(productService.get('EffectiveRecurringTotal')));
                            singlePassport.put('Quantity',String.valueOf(productService.get('DefaultQuantity')));
                            singlePassport.put('ProductId',String.valueOf(productService.get('ProductId')));
                            passaportes.add(singlePassport);
                        } else if(name.contains('Bônus') || name.contains('Bonus')) {
                            Map<String,Object> bonus = new Map<String,Object>();
                            bonus.put('Name', name);
                            bonus.put('AssetReference', String.valueOf(productService.get('AssetReference')));
                            bonus.put('Price', String.valueOf(productService.get('EffectiveRecurringTotal')));
                            bonus.put('Quantity', String.valueOf(productService.get('DefaultQuantity')));
                            listBonus.add(bonus);
                        } else if(!name.contains('AP')) {
                            Map<String,Object> singleService = new Map<String,Object>();
                            singleService.put('Name',name);
                            singleService.put('AssetReference',String.valueOf(productService.get('AssetReference')));
                            singleService.put('Price',String.valueOf(productService.get('EffectiveRecurringTotal')));
                            singleService.put('Quantity',String.valueOf(productService.get('DefaultQuantity')));
                            franquiaServices.add(singleService);                                
                        } else {
                            Map<String,Object> singleAparelho = new Map<String,Object>();
                            singleAparelho.put('Name',name);
                            singleAparelho.put('AssetReference',String.valueOf(productService.get('AssetReference')));
                            singleAparelho.put('Price',String.valueOf(productService.get('EffectiveRecurringTotal')));
                            singleAparelho.put('Quantity',String.valueOf(productService.get('DefaultQuantity')));
                            aparelhos.add(singleAparelho);
                        }
                        
                        
                        franquiaSpecs.put('Aparelhos',aparelhos);
                        franquiaSpecs.put('Pasaportes',passaportes);
                        franquiaSpecs.put('Servicios',franquiaServices);
                        franquiaSpecs.put('Bônus', listBonus);
                        
                    }
                    franquias.add(franquiaSpecs);
                   
                }   
                output.put('KitReferenceId',kitTemplateId);
                output.put('Franquias',franquias);
                output.put('KitDescription',kitDescription);

                return;
            }           
            
        }
        catch(Exception e) {           
            System.debug('Exception Cause: ' + e.getCause());
            System.debug('Exception Line Number: ' + e.getLineNumber());
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception Stack Trace: ' + e.getStackTraceString());
            System.debug('Exception Type: ' + e.getTypeName());
            throw e;
        }
    }
    
    private List<OrderItem> getCopyableOrderItems(String objectName, String whereClause)
    {
        String query=getCreatableFieldsSOQL(objectName,whereClause);
        List<OrderItem> orderItems= (List<OrderItem>)Database.query(query);
        
        return orderItems;
    }
    
    private List<OpportunityLineItem> getCopyableOpportunityLineItems(String objectName, String whereClause)
    {
        String query=getCreatableFieldsSOQL(objectName,whereClause);
        List<OpportunityLineItem> OpportunityLineItems= (List<OpportunityLineItem>)Database.query(query);
        
        return OpportunityLineItems;
    }
    
    
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
        
        String selects = '';
        
        if (whereClause == null || whereClause == ''){ return null; }
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if(objectName.equals('OpportunityLineItem'))
                selects+='ProductCode';
            if(objectName.equals('OrderItem'))
                selects+='ProductCode__c';
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
            
        }
        
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
        
    }
    
    
    public void getDependentPicklistValues( Map<String, Object> input, Map<String, Object> output, Map<String, Object> options )
    {
        String sObjectName = String.valueOf(options.get('sObjectName'));
        String fieldname = String.valueOf(options.get('fieldname'));
        
        Map<Object,List<String>> dependentPickList=getDependentPicklistValues
            (   Schema.getGlobalDescribe().get( sObjectName ).getDescribe().fields.getMap().get( fieldName )
            );
        
        output.put('values',dependentPickList);
    }
    
    
    public Map<Object,List<String>> getDependentPicklistValues( Schema.sObjectField dependToken )
    {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
            (   control.getType() == Schema.DisplayType.Boolean
             ?   null
             :   control.getPicklistValues()
            );
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                
                Object controlValue =
                    (   controlEntries == null
                     ?   (Object) (index == 1)
                     :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                    );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                
                try{
                    if  (   controlValue == null
                         ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                        ) continue;
                }catch(Exception e)
                {
                    continue;
                }
                
                if ( !dependentPicklistValues.containsKey( controlValue ) )
                {
                    dependentPicklistValues.put( controlValue, new List<String>() );
                }
                dependentPicklistValues.get( controlValue ).add( entry.getLabel() );
            }
        }
        
        return dependentPicklistValues;
    }
    
    public void getPickListValues( Map<String, Object> input, Map<String, Object> output, Map<String, Object> options )
    {
        String sObjectName = String.valueOf(options.get('sObjectName'));
        String fieldname = String.valueOf(options.get('fieldname'));
        
        List<String> values = new List<String>();
        String[] types = new String[]{sObjectName};
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldname).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {values.add(entry.getValue());}
            }
        }
        output.put('TSolicitacao',values);
    }
    
    private Map<String,Object> getOrderTemplateItems(String orderTemplateId)
    {
        Map<String,Object> items=new Map<String,Object>(); 
        String whereClause = 'OrderId= \''+orderTemplateId+'\'';
        String objectName='OrderItem';
        String query=getCreatableFieldsSOQL(objectName,whereClause);
        List<OrderItem> itemsOriginal =(List<OrderItem>)Database.query(query);
        
        for(OrderItem item: itemsOriginal)
        {
            items.put(item.vlocity_cmt__AssetReferenceId__c,item);
        }
        
        
        return items;
        
    }
    
    private Map<String,Object> getOppTemplateItems(String oppTemplateId)
    {
        Map<String,Object> items=new Map<String,Object>(); 
        String whereClause = 'OpportunityId= \''+oppTemplateId+'\'';
        String objectName='OpportunityLineItem';
        String query=getCreatableFieldsSOQL(objectName,whereClause);
        List<OpportunityLineItem> itemsOriginal =(List<OpportunityLineItem>)Database.query(query);
        
        for(OpportunityLineItem item: itemsOriginal)
        {
            items.put(item.vlocity_cmt__AssetReferenceId__c,item);
        }
        
        
        return items;
        
    }
    
    public void deleteKit(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options )
    {
        
        String planGroup=String.valueOf(input.get('Group'));
        String opptyId=String.valueOf(input.get('OpptyId'));
        String orderId=String.valueOf(input.get('OrderId'));
        String kit=String.valueOf(input.get('Kit'));
        
        if(orderId==null)
            orderId=String.valueOf(input.get('ConvertedOrderId'));
        
        
        if(opptyId!=null)
        {
            OpportunityLineItem[] itemsToDelete = [SELECT Id, PlanGroup__c,OpportunityId FROM OpportunityLineItem WHERE Opportunityid =:opptyId AND PlanGroup__c = :planGroup AND vlocity_cmt__ItemName__c =:kit];
            try {
                delete itemsToDelete;
            } catch (DmlException e) {
                output.put('EXCEPTION',e);
            }
        }
        
        if(orderId!=null)
        {
            OrderItem[] itemsToDelete = [SELECT Id, PlanGroup__c,OrderId FROM OrderItem WHERE OrderId =:orderId AND PlanGroup__c = :planGroup AND vlocity_cmt__ItemName__c =:kit];
            try {
                delete itemsToDelete;
            } catch (DmlException e) {
                output.put('EXCEPTION',e);
            }
        }
        
    }
    
    public void addKit( Map<String, Object> input, Map<String, Object> output, Map<String, Object> options )
    {
        
        Map<String,Object> kitSelected = (Map<String,Object>)options.get('KitSelected');
        String planGroup=String.valueOf(options.get('NumberOfGroupsInTheCart'));
        String opptyId=String.valueOf(kitSelected.get('OpptyId'));
        String orderId=String.valueOf(kitSelected.get('OrderId'));
        String oppTemplateId= String.valueOf(kitSelected.get('oppTemplateId')); 
        String orderTemplateId= String.valueOf(kitSelected.get('orderTemplateId'));
        List<Object> franquias = (List<Object>)kitSelected.get('Franquias');
        kitCode=String.valueOf(kitSelected.get('Name'));
        
        if(orderId==null)
            orderId=String.valueOf(input.get('ConvertedOrderId'));
        
        Map<String,Object> orderTemplateItems = new Map<String,Object>();
        Map<String,Object> oppTemplateItems= new Map<String,Object>();
        
        oppToUpdate = new List<OpportunityLineItem>();
        orToUpdate = new List<OrderItem>();
        
        if(orderId!=null)
            orderTemplateItems=getOrderTemplateItems(orderTemplateId);
        if(opptyId!=null)
            oppTemplateItems=getOppTemplateItems(opptemplateId);
        
        String planoId=String.valueOf(kitSelected.get('PlanoId'));
        String kitordertemplateid=String.valueOf(kitSelected.get('KitReferenceId'));
        System.debug('oppTemplateItems:'+ oppTemplateItems.size());
        System.debug('oppteMPlateItems:'+oppTemplateItems);
        //String kitReference= cloneKit(opptyId,orderId,kitordertemplateid,planoId,planGroup,orderTemplateitems,oppTemplateItems);
        String kitReference=planoId;
        output.put('KITCLONEDID',kitReference);
        
        for(Object obj:franquias)
        {
            Map<String,Object> franquia = (Map<String,Object>)obj;
            Map<String,Object> franquiaInfo = new Map<String,Object>();
            
            String assetReferenceId = String.valueOf(franquia.get('AssetReference'));
            
            //FRANQUIA INFO
            String bonus= String.valueOf(franquia.get('Bonus'));
            String franquiaGroup=String.valueOf(franquia.get('SelectUF'));
            String parentGroup=String.valueOf(franquia.get('SelectRegional'));
            String subGroup=String.valueOf(franquia.get('SelectDDD'));
            String requestType=String.valueOf(franquia.get('SelectTSolicitacao'));
            String franquiaPCode=String.valueOf(franquia.get('ProductCode'));
            
            franquiaInfo.put('Bonus',bonus);
            franquiaInfo.put('Group',franquiaGroup);
            franquiaInfo.put('ParentGroup',parentGroup);
            franquiaInfo.put('SubGroup',subGroup);
            franquiaInfo.put('RequestType',requestType);
            franquiaInfo.put('PlanGroup',planGroup);
            franquiaInfo.put('ReliesOn',kitReference);
            franquiaInfo.put('ProductCode',franquiaPCode);
            
            String franquiaReferenceId = cloneFranquia(franquiaInfo,assetReferenceId,orderId,opptyId,orderTemplateitems,oppTemplateItems);
            List<Object> serviciosFranquias = (List<Object>)franquia.get('Servicios');
            for(Object obj1:serviciosFranquias)
            {
                Map<String,Object>servicio = (Map<String,Object>)obj1;
                String servicioAssetReference=String.valueOf(servicio.get('AssetReference'));
                cloneServicio(servicioAssetReference,franquiaReferenceId,planGroup,opptyId,orderId,orderTemplateitems,oppTemplateItems,franquiaGroup,requestType);
            }
            
            List<Object> aparelhosFranquias = (List<Object>)franquia.get('Aparelhos');
            for(Object obj1:aparelhosFranquias)
            {
                Map<String,Object>aparelho = (Map<String,Object>)obj1;
                Map<String,Object>aparelhoInfo = new Map<String,Object>();
                String aparelhoAssetReference=String.valueOf(aparelho.get('AssetReference'));
                String aparelhoPrice=String.valueOf(aparelho.get('Price'));
                String franquiaCode= franquiaPCode; 
                Integer quantity=1;
                String tradeIn='Não';
                String payment ='Vista';
                
                aparelhoInfo.put('group',franquiaCode);
                aparelhoInfo.put('quantity',quantity);
                aparelhoInfo.put('tradeIn',tradeIn);
                aparelhoInfo.put('payment',payment);
                aparelhoInfo.put('typeOfRequest',requestType);
                aparelhoInfo.put('planGroup',planGroup);
                aparelhoInfo.put('UF',franquiaGroup);
                aparelhoInfo.put('Price',aparelhoPrice);
                
                if(aparelho.get('AparelhoSelected')!= null && Boolean.valueOf(aparelho.get('AparelhoSelected')))
                    cloneAparelho(aparelhoAssetReference,franquiaReferenceId,aparelhoInfo,opptyId,orderId,orderTemplateitems,oppTemplateItems,planGroup,requestType);
            }
            
            List<Object> pasaportesFranquias = (List<Object>)franquia.get('Pasaportes');
            for(Object obj1:pasaportesFranquias)
            {
                Map<String,Object>pasaporte = (Map<String,Object>)obj1;
                String pasaporteAssetReference=String.valueOf(pasaporte.get('AssetReference'));
                if(pasaporte.get('chck')!=null && Boolean.valueOf(pasaporte.get('chck')))
                    cloneServicio(pasaporteAssetReference,franquiaReferenceId,planGroup,opptyId,orderId,orderTemplateitems,oppTemplateItems,franquiaGroup,requestType);
            }
            
        }
        output.put('Number of Queries used in this apex code so far',Limits.getQueries());
        if(opptyId!=null)
            upsert oppToUpdate;
        if(orderId!=null)
            upsert orToUpdate;
        
    }
    
    
    
    public void cloneAparelho(String assetReferenceId,String franquiaReferenceId,Map<String,Object> aparelhoInfo,String opptyId, String orderId, Map<String,Object> orderItems, Map<String,Object> oppItems,String planGroup, String requestType){
        String defaultString='ORDERID OR OPPTY ID ARE NULL';
        if(opptyId!=null)
        {
            OpportunityLineItem itemsOriginal =(OpportunityLineItem)oppItems.get(assetReferenceId);
            OpportunityLineItem clone = itemsOriginal.clone(false,true,false,false);
            clone.Discount_Values__c=String.valueOf(aparelhoInfo.get('discountType'))+' '+String.valueOf(aparelhoInfo.get('group'));
            clone.TradeIn__c=String.valueOf(aparelhoInfo.get('tradeIn'));
            clone.TypeOfRequest__c=String.valueOf(aparelhoInfo.get('typeOfRequest'));
            clone.Payment_Term__c=String.valueOf(aparelhoInfo.get('payment'));
            clone.PlanGroup__c=planGroup;
            clone.OpportunityId=opptyId;
            clone.Avoid_vlc_pricing__c=true;
            clone.vlocity_cmt__ItemName__c=kitCode;
            clone.id=null;
            clone.ReliesOnReferenceId__c=franquiaReferenceId;
            clone.vlocity_cmt__RecurringCalculatedPrice__c=clone.vlocity_cmt__RecurringCharge__c;
            clone.UnitPrice=0.0;
            clone.TotalPrice=null;
            upsert clone;
            clone.TotalPrice=0.0;
            clone.vlocity_cmt__AssetReferenceId__c=clone.id;
            update clone;
            for (String assetReference : oppItems.keySet()){
                OpportunityLineItem item =(OpportunityLineItem)oppItems.get(assetReference);
                if(item!=null && item.ReliesOnReferenceId__c.equals(assetReferenceId))
                {
                    String uf=String.valueOf(aparelhoInfo.get('UF'));
                    OpportunityLineItem simCardClone = item.clone(false,true,false,false);
                    PME_SimCard_Info__c simInfo= [SELECT SAP_ID__c,Description__c FROM PME_SimCard_Info__c WHERE UF__c =:uf Order By CreatedDate DESC LIMIT 1 ];
                    simCardClone.Description= simInfo.Description__c;
                    simCardClone.SAP_ID__c=simInfo.SAP_ID__c;
                    simCardClone.ReliesOnReferenceId__c=clone.vlocity_cmt__AssetReferenceId__c;
                    simCardClone.PlanGroup__c=planGroup;
                    simCardClone.OpportunityId=clone.OpportunityId;
                    simCardClone.vlocity_cmt__ItemName__c=kitCode;
                    simCardClone.UnitPrice=0.0;
                    simCardClone.TotalPrice=null;
                    simCardClone.TypeOfRequest__c=requestType;
                    if(requestType.equalsIgnoreCase('TT PF/PJ')){
                        simCardClone.Avoid_vlc_pricing__c=true;
                        simCardClone.vlocity_cmt__RecurringCharge__c=0.0;
                        simCardClone.vlocity_cmt__RecurringTotal__c=0.0;
                        simCardClone.vlocity_cmt__RecurringCalculatedPrice__c=0.0;
                    }
                    if(!oppToUpdate.contains(simCardClone))
                        oppToUpdate.add(simCardClone);
                }
                
            }
            
        }
        if(orderId!=null)
        {
            OrderItem itemOriginal =(OrderItem)orderItems.get(assetReferenceId);
            OrderItem clone = itemOriginal.clone(false,true,false,false);
            clone.Discount_Values__c=String.valueOf(aparelhoInfo.get('discountType'))+' '+String.valueOf(aparelhoInfo.get('group'));
            clone.TradeIn__c=String.valueOf(aparelhoInfo.get('tradeIn'));
            clone.TypeOfRequest__c=String.valueOf(aparelhoInfo.get('typeOfRequest'));
            clone.Payment_Term__c=String.valueOf(aparelhoInfo.get('payment'));
            clone.Avoid_vlc_pricing__c=true;
            clone.OrderId=orderId;
            clone.vlocity_cmt__ItemName__c=kitCode;
            clone.vlocity_cmt__RecurringCalculatedPrice__c=clone.vlocity_cmt__RecurringCharge__c;
            clone.id=null;
            clone.ReliesOnReferenceId__c=franquiaReferenceId;
            clone.PlanGroup__c=planGroup;
            upsert clone;
            clone.vlocity_cmt__AssetReferenceId__c=clone.id;
            
            update clone;
            for (String assetReference : orderItems.keySet()){
                OrderItem item =(OrderItem)orderItems.get(assetReference);
                if(item!=null && item.ReliesOnReferenceId__c.equals(assetReferenceId))
                {
                    String uf=String.valueOf(aparelhoInfo.get('UF'));
                    PME_SimCard_Info__c simInfo= [SELECT SAP_ID__c,Description__c FROM PME_SimCard_Info__c WHERE UF__c =:uf Order By CreatedDate DESC LIMIT 1 ];
                    OrderItem simCardClone = item.clone(false,true,false,false);
                    simCardClone.Description= simInfo.Description__c;
                    simCardClone.SAP_ID__c=simInfo.SAP_ID__c;
                    simCardClone.ReliesOnReferenceId__c=clone.vlocity_cmt__AssetReferenceId__c;
                    simCardClone.PlanGroup__c=planGroup;
                    simCardClone.vlocity_cmt__ItemName__c=kitCode;
                    simCardClone.OrderId=clone.OrderId;
                    simCardClone.PlanGroup__c=planGroup;
                    simCardClone.TypeOfRequest__c=requestType;
                    if(requestType.equalsIgnoreCase('TT PF/PJ')){
                        simCardClone.Avoid_vlc_pricing__c=true;
                        simCardClone.vlocity_cmt__RecurringCharge__c=0.0;
                        simCardClone.vlocity_cmt__RecurringTotal__c=0.0;
                        simCardClone.vlocity_cmt__RecurringCalculatedPrice__c=0.0;
                    }
                    if(!orToUpdate.contains(simCardClone))
                        orToUpdate.add(simCardClone);
                }
                
            }
            
        }
        
    }
    
    public void cloneServicio(String assetReferenceId,String franquiaReferenceId,String planGroup,String opptyId, String orderId, Map<String,Object> orderItems,Map<String,Object> oppItems,String uf,String requestType){
        if(opptyId!=null)
        {
            OpportunityLineItem itemsOriginal =(OpportunityLineItem)oppItems.get(assetReferenceId);
            if(itemsOriginal.ProductCode=='PME_SimCardAparelho_0001')
                return;
            OpportunityLineItem clone = itemsOriginal.clone(false,true,false,false);
            clone.PlanGroup__c=planGroup;
            clone.OpportunityId=opptyId;
            clone.id=null;
            clone.ReliesOnReferenceId__c=franquiaReferenceId;
            clone.vlocity_cmt__ItemName__c=kitCode;
            clone.UnitPrice=0.0;
            clone.TotalPrice=null;
            
            if(clone.ProductCode!=null && clone.ProductCode.containsIgnoreCase('PME_SimCardAvulso_0001'))
            {
                
                PME_SimCard_Info__c simInfo= [SELECT SAP_ID__c,Description__c FROM PME_SimCard_Info__c WHERE UF__c =:uf Order By CreatedDate DESC LIMIT 1 ];
                clone.Description= simInfo.Description__c;
                clone.SAP_ID__c=simInfo.SAP_ID__c;
                clone.TypeOfRequest__c=requestType;
                if(requestType.equalsIgnoreCase('TT PF/PJ')){
                    clone.Avoid_vlc_pricing__c=true;
                    clone.vlocity_cmt__RecurringCharge__c=0.0;
                    clone.vlocity_cmt__RecurringTotal__c=0.0;
                    clone.vlocity_cmt__RecurringCalculatedPrice__c=0.0;
                    
                }
            }
            
            oppToUpdate.add(clone);
            
        }
        if(orderId!=null)
        {
            OrderItem itemOriginal =(OrderItem)orderItems.get(assetReferenceId);
            if(itemOriginal.ProductCode__c=='PME_SimCardAparelho_0001')
                return;
            OrderItem clone = itemOriginal.clone(false,true,false,false);
            clone.PlanGroup__c=planGroup;
            clone.OrderId=orderId;
            clone.id=null;
            clone.ReliesOnReferenceId__c=franquiaReferenceId; 
            clone.vlocity_cmt__ItemName__c=kitCode;
            
            if(clone.ProductCode__c!=null && clone.ProductCode__c.equals('PME_SimCardAvulso_0001'))
            {
                PME_SimCard_Info__c simInfo= [SELECT SAP_ID__c,Description__c FROM PME_SimCard_Info__c WHERE UF__c =:uf Order By CreatedDate DESC LIMIT 1 ];
                clone.Description= simInfo.Description__c;
                clone.SAP_ID__c=simInfo.SAP_ID__c;
                clone.TypeOfRequest__c=requestType;
                if(requestType.equalsIgnoreCase('TT PF/PJ')){
                    clone.vlocity_cmt__RecurringCalculatedPrice__c=0.0;
                    clone.vlocity_cmt__RecurringCharge__c=0.0;
                    clone.vlocity_cmt__RecurringTotal__c=0.0;
                    clone.Avoid_vlc_pricing__c=true;
                }
                
            }
            orToUpdate.add(clone);
        }
        
    }
    
    // public String cloneKit(String opptyId, String orderId, String assetReferenceId,String planoId,String planGroup, Map<String,Object> orderItems,Map<String,Object> oppItems){
    //    String defaultString='ORDERID OR OPPTY ID ARE NULL';
    //     if(opptyId!=null)
    //     {
    //         OpportunityLineItem itemsOriginal =(OpportunityLineItem)oppItems.get(assetReferenceId);
    //         OpportunityLineItem clone = itemsOriginal.clone(false,true,false,false);
    //         clone.PlanGroup__c=planGroup;
    //         clone.OpportunityId=opptyId;
    //         clone.id=null;
    //         clone.ReliesOnReferenceId__c=planoId;
    //         clone.UnitPrice=0.0;
    //         clone.TotalPrice=null;
    //         upsert clone;
    //         clone.TotalPrice=0.0;
    //         clone.AssetReferenceId__c=clone.id;
    //         update clone;
    //         return clone.AssetReferenceId__c;
    
    
    //    }
    //    if(orderId!=null)
    //    {
    //         OrderItem itemOriginal =(OrderItem)orderItems.get(assetReferenceId);
    //         OrderItem clone = itemOriginal.clone(false,true,false,false);
    //         clone.PlanGroup__c=planGroup;
    //         clone.OrderId=orderId;
    //         clone.id=null;
    //         clone.ReliesOnReferenceId__c=planoId; 
    //         upsert clone;
    //         clone.vlocity_cmt__AssetReferenceId__c=clone.id;
    //         update clone;
    //         return clone.vlocity_cmt__AssetReferenceId__c;
    //    }
    //    return defaultString;
    
    // }
    
    public String cloneFranquia(Map<String,Object> franquiaInfo,String assetReferenceId,String orderId,String opptyId, Map<String,Object> orderItems,Map<String,Object> oppItems){
        String defaultString='ORDERID OR OPPTY ID ARE NULL';
        
        if(opptyId!=null)
        {
            OpportunityLineItem itemsOriginal =(OpportunityLineItem)oppItems.get(assetReferenceId);
            OpportunityLineItem clone = itemsOriginal.clone(false,true,false,false);
            clone.BonusValue__c=String.ValueOf(franquiaInfo.get('Bonus'));
            clone.Group__c=String.ValueOf(franquiaInfo.get('Group'));
            clone.ParentGroup__c=String.ValueOf(franquiaInfo.get('ParentGroup'));
            clone.Subgroup__c=String.ValueOf(franquiaInfo.get('SubGroup'));
            clone.TypeOfRequest__c=String.ValueOf(franquiaInfo.get('RequestType'));
            clone.PlanGroup__c=String.ValueOf(franquiaInfo.get('PlanGroup'));
            clone.ReliesOnReferenceId__c=String.ValueOf(franquiaInfo.get('ReliesOn'));
            clone.OpportunityId=opptyId;
            clone.vlocity_cmt__RecurringTotal__c=clone.vlocity_cmt__RecurringCharge__c;
            clone.UnitPrice=0.0;
            clone.TotalPrice=null;
            clone.vlocity_cmt__ItemName__c=kitCode;
            clone.id=null;
            clone.vlocity_cmt__AssetReferenceId__c=null;
            upsert clone;
            clone.vlocity_cmt__AssetReferenceId__c=clone.id;
            clone.TotalPrice=0.0;
            update clone;
            return clone.vlocity_cmt__AssetReferenceId__c;
        }
        if(orderId!=null)
        {
            OrderItem itemOriginal =(OrderItem)orderItems.get(assetReferenceId);
            OrderItem clone = itemOriginal.clone(false,true,false,false);
            clone.BonusValue__c=String.ValueOf(franquiaInfo.get('Bonus'));
            clone.Group__c=String.ValueOf(franquiaInfo.get('Group'));
            clone.ParentGroup__c=String.ValueOf(franquiaInfo.get('ParentGroup'));
            clone.Subgroup__c=String.ValueOf(franquiaInfo.get('SubGroup'));
            clone.TypeOfRequest__c=String.ValueOf(franquiaInfo.get('RequestType'));
            clone.PlanGroup__c=String.ValueOf(franquiaInfo.get('PlanGroup'));
            clone.ReliesOnReferenceId__c=String.ValueOf(franquiaInfo.get('ReliesOn'));
            clone.OrderId=orderId;
            clone.vlocity_cmt__ItemName__c=kitCode;
            clone.id=null;
            clone.vlocity_cmt__AssetReferenceId__c=null;
            upsert clone;
            clone.vlocity_cmt__AssetReferenceId__c=clone.id;
            update clone;
            return clone.vlocity_cmt__AssetReferenceId__c;
        }
        return defaultString;
        
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: SOLAR FASE 2 + SQUAD PME: Utilizado para identificar o tipo de pesquisa de marcas de aparelhos dos kit
    */     
	public void getManufacturer(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        if (String.isNotBlank(String.valueOf(options.get('orderTemplateId')))) {
        	getManufacturerOrder(input, output, options);    
        } else {
            getManufacturerOppt(input, output, options);    
        }
    }     
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: SOLAR FASE 2 + SQUAD PME: Utilizado na pesquisa de marcas dos aparelhos dos kit no template de pedido
    */     
	public void getManufacturerOrder(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        Id orderTemplateId = (Id)options.get('orderTemplateId');
		Map<String, Set<String>> mapMarcas = new Map<String, Set<String>>();
        
		for (OrderItem marca : [SELECT Id, ReliesOnReferenceId__c, Product2.Manufacturer__c, Product2.Model__c, Product2.Color__c FROM OrderItem WHERE Product2.vlocity_cmt__Type__c = 'Aparelhos' AND OrderId = :orderTemplateId]) {
            if (mapMarcas.containsKey(marca.ReliesOnReferenceId__c)) {
                mapMarcas.get(marca.ReliesOnReferenceId__c).add(marca.Product2.Manufacturer__c);    
            } else {
                mapMarcas.put(marca.ReliesOnReferenceId__c, new Set<String>{marca.Product2.Manufacturer__c});    
            }
        }
        
        output.put('values', mapMarcas);
    }  
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: SOLAR FASE 2 + SQUAD PME: Utilizado na pesquisa de marcas dos aparelhos dos kit no template de simulação
    */     
	public void getManufacturerOppt(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        Id opportunityTemplateId = (Id)options.get('opportunityTemplateId');
		Map<String, Set<String>> mapMarcas = new Map<String, Set<String>>();
        
		for (OpportunityLineItem marca : [SELECT Id, ReliesOnReferenceId__c, Product2.Manufacturer__c, Product2.Model__c, Product2.Color__c FROM OpportunityLineItem WHERE Product2.vlocity_cmt__Type__c = 'Aparelhos' AND OpportunityId = :opportunityTemplateId]) {
            if (mapMarcas.containsKey(marca.ReliesOnReferenceId__c)) {
                mapMarcas.get(marca.ReliesOnReferenceId__c).add(marca.Product2.Manufacturer__c);    
            } else {
                mapMarcas.put(marca.ReliesOnReferenceId__c, new Set<String>{marca.Product2.Manufacturer__c});    
            }
        }
        
        output.put('values', mapMarcas);
    }    
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: SOLAR FASE 2 + SQUAD PME: Utilizado para identificar o tipo de pesquisa de aparelhos dos kit
    */     
	public void getModel(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        if (String.isNotBlank(String.valueOf(options.get('orderTemplateId')))) {
        	getModelOrder(input, output, options);    
        } else {
            getModelOppt(input, output, options);    
        }
    }     
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: SOLAR FASE 2 + SQUAD PME: Utilizado na pesquisa de modelos de aparelhos dos kit no template de pedido
    */     
	public void getModelOrder(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        Id orderTemplateId = (Id)options.get('orderTemplateId');
		Map<String, Set<String>> mapModels = new Map<String, Set<String>>();
		String chave;
        
		for (OrderItem model : [SELECT Id, ReliesOnReferenceId__c, Product2.Manufacturer__c, Product2.Model__c, Product2.Color__c FROM OrderItem WHERE Product2.vlocity_cmt__Type__c = 'Aparelhos' AND OrderId = :orderTemplateId]) {
            chave = String.ValueOf(model.ReliesOnReferenceId__c) + String.ValueOf(model.Product2.Manufacturer__c);
            if (mapModels.containsKey(chave)) {
                mapModels.get(chave).add(model.Product2.Model__c);    
            } else {
                mapModels.put(chave, new Set<String>{model.Product2.Model__c});    
            }
        }
        
        output.put('values', mapModels);
    }  
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: SOLAR FASE 2 + SQUAD PME: Utilizado na pesquisa de modelos dos aparelhos dos kit no template de simulação
    */     
	public void getModelOppt(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        Id opportunityTemplateId = (Id)options.get('opportunityTemplateId');
		Map<String, Set<String>> mapModels = new Map<String, Set<String>>();
		String chave;
        
		for (OpportunityLineItem model : [SELECT Id, ReliesOnReferenceId__c, Product2.Manufacturer__c, Product2.Model__c, Product2.Color__c FROM OpportunityLineItem WHERE Product2.vlocity_cmt__Type__c = 'Aparelhos' AND OpportunityId = :opportunityTemplateId]) {
            chave = String.ValueOf(model.ReliesOnReferenceId__c) + String.ValueOf(model.Product2.Manufacturer__c);
            if (mapModels.containsKey(chave)) {
                mapModels.get(chave).add(model.Product2.Model__c);    
            } else {
                mapModels.put(chave, new Set<String>{model.Product2.Model__c});    
            }
        }
        
        output.put('values', mapModels);
    }    
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: SOLAR FASE 2 + SQUAD PME: Utilizado para identificar o tipo de pesquisa das cores dos aparelhos dos kit
    */     
    public void getColor(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        if (String.isNotBlank(String.valueOf(options.get('orderTemplateId')))) {
        	getColorOrder(input, output, options);    
        } else {
            getColorOppt(input, output, options);    
        }        
    } 

    /*
    * Autor: Otávio Fonseca
    * Descrição: SOLAR FASE 2 + SQUAD PME: Utilizado na pesquisa de cores dos aparelhos dos kit no template de pedido
    */     
	public void getColorOrder(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        Id orderTemplateId = (Id)options.get('orderTemplateId');
		Map<String, Set<String>> mapColors = new Map<String, Set<String>>();
		String chave;
        
		for (OrderItem color : [SELECT Id, ReliesOnReferenceId__c, Product2.Model__c, Product2.Color__c FROM OrderItem WHERE Product2.vlocity_cmt__Type__c = 'Aparelhos' AND OrderId = :orderTemplateId]) {
            chave = String.ValueOf(color.ReliesOnReferenceId__c) + String.ValueOf(color.Product2.Model__c);
            if (mapColors.containsKey(chave)) {
                mapColors.get(chave).add(color.Product2.Color__c);    
            } else {
                mapColors.put(chave, new Set<String>{color.Product2.Color__c});    
            }
        }
        
        output.put('values', mapColors);
    }  
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: SOLAR FASE 2 + SQUAD PME: Utilizado na pesquisa de cores do aparelhos dos kit no template de simulação
    */     
	public void getColorOppt(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        Id opportunityTemplateId = (Id)options.get('opportunityTemplateId');
		Map<String, Set<String>> mapColors = new Map<String, Set<String>>();
		String chave;
        
		for (OpportunityLineItem color : [SELECT Id, ReliesOnReferenceId__c, Product2.Model__c, Product2.Color__c FROM OpportunityLineItem WHERE Product2.vlocity_cmt__Type__c = 'Aparelhos' AND OpportunityId = :opportunityTemplateId]) {
            chave = String.ValueOf(color.ReliesOnReferenceId__c) + String.ValueOf(color.Product2.Model__c);

            if (mapColors.containsKey(chave)) {
                mapColors.get(chave).add(color.Product2.Color__c);    
            } else {
                mapColors.put(chave, new Set<String>{color.Product2.Color__c});    
            }
        }
        
        output.put('values', mapColors);
    } 
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: SOLAR FASE 2 + SQUAD PME: Utilizado para identificar o tipo de pesquisa de aparelhos dos kit
    */     
    public void getDevices(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        if (String.isNotBlank(String.valueOf(input.get('orderTemplateId'))) ) {
        	getDevicesOrder(input, output, options);    
        } else {
            getDevicesOppt(input, output, options);    
        }        
    } 

/*
    * Autor: Otávio Fonseca
    * Descrição: SOLAR FASE 2 + SQUAD PME: Utilizado na pesquisa de aparelhos dos kit no template de simulação
    */ 
    public void getDevicesOppt(Map<String, Object> input,Map<String, Object> outMap, Map<String, Object> options){
        String query;
               
        Id opportunityTemplateId = (Id)input.get('opportunityTemplateId');
        Id assetReferenceId = (Id)input.get('assetReference');
        String brand = (String)input.get('brand');
        String model = (String)input.get('model');
        String color = (String)input.get('color');        
        
        List<OpportunityLineItem> devices;

        Integer pageSize;
        Integer counter = 0;
        Integer currentPage = 1;

        List<Map<String, String>> page;
        Map<String, List<Map<String, String>>> pages = new Map<String,List<Map<String, String>>>();  
        Map<String, String> tempMap;       

        query = 'SELECT Id, Product2.Id, Product2.Name, Product2.Manufacturer__c, Product2.Model__c, Product2.Color__c, Product2.Photo__c, Product2.ProductCode, vlocity_cmt__RecurringCharge__c FROM OpportunityLineItem WHERE Product2.vlocity_cmt__Type__c = \'Aparelhos\' AND OpportunityId = :opportunityTemplateId AND ReliesOnReferenceId__c = :assetReferenceId ';            

        if (String.isNotBlank(brand)){
            query += 'AND Product2.Manufacturer__c = :brand ';
        }

        if (String.isNotBlank(model)){
            query += 'AND Product2.Model__c = :model ';
        } 
        
        if (String.isNotBlank(color)){
            query += 'AND Product2.Color__c = :color ';
        } 

        devices = Database.query(query);

        try {
            pageSize = integer.valueof(System.Label.CEC_PME_Pagination);
        } catch(Exception e){
            pageSize = 12;
        }
        //pageSize = 1;

        for (OpportunityLineItem device : devices) {                
            if (counter == 0){
                page = new List<Map<String, String>>();
            }
            
            tempMap = new Map<String, String>();
            tempMap.put('Id', device.Id);            
            tempMap.put('productId', device.Product2.Id);            
            tempMap.put('productName', device.Product2.Name); 
            tempMap.put('productCode', device.Product2.ProductCode);            
            tempMap.put('price', String.ValueOf(device.vlocity_cmt__RecurringCharge__c));            
            tempMap.put('manufacturer', device.Product2.Manufacturer__c);
            tempMap.put('model', device.Product2.Model__c);            
            tempMap.put('color', device.Product2.Color__c);
            tempMap.put('picture', device.Product2.Photo__c);            
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
        outMap.put('assetReference', input.get('assetReference'));
    }     
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: SOLAR FASE 2 + SQUAD PME: Utilizado na pesquisa de aparelhos dos kit no template de pedido
    */     
    public void getDevicesOrder(Map<String, Object> input,Map<String, Object> outMap, Map<String, Object> options){
        String query;
        
        Id orderTemplateId = (Id)input.get('orderTemplateId');  
        Id assetReferenceId = (Id)input.get('assetReference');
        String brand = (String)input.get('brand');
        String model = (String)input.get('model');
        String color = (String)input.get('color');        

        List<OrderItem> devices;

        Integer pageSize;
        Integer counter = 0;
        Integer currentPage = 1;

        List<Map<String, String>> page;
        Map<String, List<Map<String, String>>> pages = new Map<String,List<Map<String, String>>>();  
        Map<String, String> tempMap;       
         
        query = 'SELECT Id, Product2.Id, Product2.Name, Product2.Manufacturer__c, Product2.Model__c, Product2.Color__c, Product2.Photo__c, Product2.ProductCode, vlocity_cmt__RecurringCharge__c FROM OrderItem WHERE Product2.vlocity_cmt__Type__c = \'Aparelhos\' AND OrderId = :orderTemplateId AND ReliesOnReferenceId__c = :assetReferenceId ';            

        if (String.isNotBlank(brand)){
            query += 'AND Product2.Manufacturer__c = :brand ';
        }

        if (String.isNotBlank(model)){
            query += 'AND Product2.Model__c = :model ';
        } 
        
        if (String.isNotBlank(color)){
            query += 'AND Product2.Color__c = :color ';
        } 

        devices = Database.query(query);

        try {
            pageSize = integer.valueof(System.Label.CEC_PME_Pagination);
        } catch(Exception e){
            pageSize = 12;
        }
        //pageSize = 1;

        for (OrderItem device : devices) {                
            if (counter == 0){
                page = new List<Map<String, String>>();
            }
            
            tempMap = new Map<String, String>();
            //tempMap.put('AssetReference', assetReference);
            tempMap.put('Id', device.Id);            
            tempMap.put('productId', device.Product2.Id);            
            tempMap.put('productName', device.Product2.Name); 
            tempMap.put('productCode', device.Product2.ProductCode);            
            tempMap.put('price', String.ValueOf(device.vlocity_cmt__RecurringCharge__c));            
            tempMap.put('manufacturer', device.Product2.Manufacturer__c);
            tempMap.put('model', device.Product2.Model__c);
            tempMap.put('color', device.Product2.Color__c);
            tempMap.put('picture', device.Product2.Photo__c);  
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
        outMap.put('assetReference', input.get('assetReference'));
    }

           
}