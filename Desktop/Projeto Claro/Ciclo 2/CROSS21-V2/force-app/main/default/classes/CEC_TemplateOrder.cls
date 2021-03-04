global with sharing virtual class CEC_TemplateOrder implements vlocity_cmt.VlocityOpenInterface {

    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        Boolean retval = false;

        if (methodName == 'CloneFromTemplate') {
            retval = cloneTemplate(input,output,options);
            
        }

        return retval;
    }

    public static Integer levelLength = 4;
    public static String padLeft(Integer i) {
        String str = String.valueOf(i);
        while (str.length() < levelLength) {
            str = '0' + str;
        }
        
        return str;
    }

    public Boolean cloneTemplate(Map<String, Object> input,Map<String, Object> output,Map<String, Object> options) {
        Boolean retval = false;
        String objectType = '';
        
        //Template OQO: query it *****************
        String templateId = (String)input.get('TemplateId');
        String planName = (String)input.get('planName');
        String referenceId = (String)input.get('ReliesOnReferenceId');

        if (TemplateId != null && TemplateId != ''){
            ObjectType = (String)((Id)TemplateId).getSObjectType().getDescribe().getName();
            
        }  else {
            
            String TemplateName = (String)input.get('TemplateName');
            String TemplateObjectType = (String)input.get('TemplateObjectType');

            if(TemplateObjectType == null){
                output.put('Exception','TemplateName also requires TemplateObjectType');
                return retval;
            }
            String tempSoql = 'Select Id from ' + TemplateObjectType + ' where name =:TemplateName limit 1';

            SObject o = database.query(tempSoql);
            TemplateId = o.Id;
            ObjectType = TemplateObjectType;
        }
        
        
        List <Object> oIncludeItemsList = new List <Object>();
        try{
            oIncludeItemsList = (List <Object>) input.get('includeIds');    
        }catch(Exception e){
            oIncludeItemsList.add((Id)input.get('includeIds'));
        }
        
        List <Object> oIncludeProductItemsList = new List <Object>();
        try{
            oIncludeProductItemsList = (List <Object>) input.get('includeProductIds');    
        }catch(Exception e){
            oIncludeProductItemsList.add((Id)input.get('includeProductIds'));
        }
        
        List <Object> oIncludeItemsListQtd = new List <Object>();
        try{
            oIncludeItemsListQtd = (List <Object>)input.get('productWithQtd');    
        }catch(Exception e){
        
        }

        System.debug('oIncludeItemsList: '+ oIncludeItemsList); 
        
        System.debug('oIncludeProductItemsList: '+ oIncludeProductItemsList); 
        
        System.debug('oIncludeItemsListQtd: '+ oIncludeItemsListQtd); 
        
        List<String> lIncludeItemsList= new List<String> ();
        
        if(oIncludeItemsList != null)
        {
            for(Object o: oIncludeItemsList)
            {
                lIncludeItemsList.add(String.valueOf(o));
            }
        }
        
        
        List<String> lIncludeProductsItemsList= new List<String> ();
        
        if(oIncludeProductItemsList != null)
        {
            for(Object o: oIncludeProductItemsList)
            {
                lIncludeProductsItemsList.add(String.valueOf(o));
            }
        }

        
        String TemplateSoql = vlocity_cmt.DBHelper.getBaseQuery(ObjectType);
        TemplateSoql += ' where Id =\'' + TemplateId + '\'';

        SObject parent = Database.query(TemplateSoql);   // setting parent

        Integer maxLineNumber = 0;
        String objectTypeLI;
        if (ObjectType == 'Opportunity') {
            objectTypeLI = 'OpportunityLineItem';
        } else if (ObjectType == 'Quote') {
            objectTypeLI = 'QuoteLineItem';
        } else if (ObjectType == 'Order') {
            objectTypeLI = 'OrderItem';
        }
 
        // Clone Header: start setting up clone. 1st is there a header for new OQO passed in?*****************
         String existingId = (String)input.get('ExistingId');
        
        // get header info (existingId)
        String ExistingSoql = vlocity_cmt.DBHelper.getBaseQuery(ObjectType);
        ExistingSoql += ' where Id =\'' + existingId + '\'';
        SObject existingParent = Database.query(ExistingSoql);

        //String soqlEL = vlocity_cmt.DBHelper.getBaseQuery(objectTypeLI);
        String soqlEL = 'Select Id, vlocity_cmt__LineNumber__c FROM '+ objectTypeLI; // instrução recebida da Vlocity em 09/07/2020 pelo CASE 00315149
        soqlEL += ' where ' + ObjectType + 'Id = :existingId order by vlocity_cmt__LineNumber__c desc limit 1';
        try {

            List<SObject> tempLIs = Database.query(soqlEL);

            if ((tempLIs != null) && (tempLIs.size() == 1)) {
                String temp = (String)tempLIs[0].get('vlocity_cmt__LineNumber__c');
                maxLineNumber = Integer.valueOf(temp.split('\\.')[0]);
            }
        } catch (Exception e) {
            //expect no rows.
        }

        System.debug('NewId' + existingId);

        //query Template (OQO) Line Items *********************
        // String soqlLI = vlocity_cmt.DBHelper.getBaseQuery(objectTypeLI);
               
        //String soqlLI = 'select Id, IsDeleted, OrderId, PricebookEntryId, OriginalOrderItemId, QuoteLineItemId, AvailableQuantity, Quantity, UnitPrice, ListPrice, TotalPrice, ServiceDate, EndDate, Description, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, OrderItemNumber, vlocity_cmt__Action__c, vlocity_cmt__ActivationName__c, vlocity_cmt__Additional_Discount__c, vlocity_cmt__AssetId__c, vlocity_cmt__AssetReferenceId__c, vlocity_cmt__BillingAccountId__c, vlocity_cmt__ConnectDate__c, vlocity_cmt__CpqCardinalityMessage__c, vlocity_cmt__CpqMessageData__c, vlocity_cmt__CurrencyPaymentMode__c, vlocity_cmt__DisconnectDate__c, vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c, vlocity_cmt__EffectiveOneTimeTotal__c, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__ExpectedCompletionDate__c, vlocity_cmt__Filter__c, vlocity_cmt__FulfilmentStatus__c, vlocity_cmt__InCartQuantityMap__c, vlocity_cmt__IsChangesAccepted__c, vlocity_cmt__IsChangesAllowed__c, vlocity_cmt__IsEditable__c, vlocity_cmt__IsProductTrackAgreement__c, vlocity_cmt__ItemName__c, vlocity_cmt__JSONAttribute__c, vlocity_cmt__JSONNode__c, vlocity_cmt__LineItemNumString__c, vlocity_cmt__LineItemNumber__c, vlocity_cmt__LineNumber__c, vlocity_cmt__MRC__c, vlocity_cmt__Modification__c, vlocity_cmt__MonthlyTotal__c, vlocity_cmt__OneTimeCalculatedPrice__c, vlocity_cmt__OneTimeCharge__c, vlocity_cmt__OneTimeDiscountPrice__c, vlocity_cmt__OneTimeLoyaltyPrice__c, vlocity_cmt__OneTimeLoyaltyTotal__c, vlocity_cmt__OneTimeManualDiscount__c, vlocity_cmt__OneTimeTotal__c, vlocity_cmt__OverageCalculatedPrice__c, vlocity_cmt__OverageCharge__c, vlocity_cmt__OverageDiscountPrice__c, vlocity_cmt__OverageManualDiscount__c, vlocity_cmt__OverageTotal__c, vlocity_cmt__OverageUOM__c, vlocity_cmt__ParentItemId__c, vlocity_cmt__ParentLineItemNumber__c, vlocity_cmt__ParentOrderProduct__c, vlocity_cmt__PremisesId__c, vlocity_cmt__PricingLogData__c, vlocity_cmt__Product2Id__c, vlocity_cmt__ProductAttribXN__c, vlocity_cmt__ProductHierarchyPath__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__Query__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__RecurringDiscountPrice__c, vlocity_cmt__RecurringManualDiscount__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__RecurringUOM__c, vlocity_cmt__RelationshipType__c, vlocity_cmt__RequestDate__c, vlocity_cmt__RequestedChange__c, vlocity_cmt__RequestedCompletionDate__c, vlocity_cmt__RootItemId__c, vlocity_cmt__SequenceNumber__c, vlocity_cmt__SerialNumber__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__SubAction__c, vlocity_cmt__ThorJeopardyStatus__c, ReliesOnReferenceId__c, Acrescimo_Desconto__c, DDD__c, Fidelidade__c, Forma_de_Pagamento__c, Group__c, JanelaPortabilidade__c, MSISDN__c, Meses_de_Fidelidade__c, NumeroProvisorio__c, Operator__c, PlanType__c, Portabilidade__c, TemplateDefaultQty__c, TemplateMaxQty__c, TemplateMinQty__c, ParentGroup__c, ReliesOn__c, SAP_ID__c, Subgroup__c, vlocity_cmt__AttributeMetadataChanges__c, vlocity_cmt__AttributeSelectedValues__c, vlocity_cmt__RequestedStartDate__c, vlocity_cmt__SubscriptionId__c, AnotherDeviceColor__c, Avoid_vlc_pricing__c, DeviceSecondOptionColor__c, Discount_Type__c, Discount_Values__c, DonatorDocumentNumber__c, DonatorEmail__c, DonatorName__c, DonatorPhone__c, ICCID__c, IMEI__c, DescricaoMulta__c, PlanGroup__c, PortabilityNumber__c, ProductCode__c, RegionalState__c, Regional__c, State__c, Template_Default_Qty__c, Template_Max_Qty__c, Template_Min_Qty__c, TradeIn__c, TypeOfDelivery__c, TypeOfRequest__c, Payment_Term__c, DescricaoPromocao__c, Grupo__c, NumeroParcelas__c, Promotion_Log__c, ValorTaxa__c, BonusValue__c, Template_Multi_Max_Qty__c from OrderItem';
         
        String soqlLI = '';
        
        if (ObjectType == 'Opportunity') {
            soqlLI = 'select Id, OpportunityId, SortOrder, PricebookEntryId, Product2Id, ProductCode, Name, Quantity, Discount, Subtotal, TotalPrice, UnitPrice, ListPrice, ServiceDate, HasRevenueSchedule, HasQuantitySchedule, Description, HasSchedule, CanUseQuantitySchedule, CanUseRevenueSchedule, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsDeleted, vlocity_cmt__Action__c, vlocity_cmt__AttributeSelectedValues__c, vlocity_cmt__BillingAccountId__c, vlocity_cmt__ConnectDate__c, vlocity_cmt__CpqCardinalityMessage__c, vlocity_cmt__CpqMessageData__c, vlocity_cmt__CurrencyPaymentMode__c, vlocity_cmt__DisconnectDate__c, vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c, vlocity_cmt__EffectiveOneTimeTotal__c, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__Filter__c, vlocity_cmt__InCartQuantityMap__c, vlocity_cmt__IsProductTrackAgreement__c, vlocity_cmt__ItemName__c, vlocity_cmt__JSONAttribute__c, vlocity_cmt__JSONNode__c, vlocity_cmt__LineNumber__c, vlocity_cmt__Modification__c, vlocity_cmt__OneTimeCalculatedPrice__c, vlocity_cmt__OneTimeCharge__c, vlocity_cmt__OneTimeDiscountPrice__c, vlocity_cmt__OneTimeLoyaltyPrice__c, vlocity_cmt__OneTimeLoyaltyTotal__c, vlocity_cmt__OneTimeManualDiscount__c, vlocity_cmt__OneTimeTotal__c, vlocity_cmt__OverageCalculatedPrice__c, vlocity_cmt__OverageCharge__c, vlocity_cmt__OverageDiscountPrice__c, vlocity_cmt__OverageManualDiscount__c, vlocity_cmt__OverageTotal__c, vlocity_cmt__OverageUOM__c, vlocity_cmt__ParentItemId__c, vlocity_cmt__PremisesId__c, LogData__c, vlocvlocity_cmt__Pricingity_cmt__Product2Id__c, vlocity_cmt__ProductAttribXN__c, vlocity_cmt__ProductHierarchyPath__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__Query__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__RecurringDiscountPrice__c, vlocity_cmt__RecurringManualDiscount__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__RecurringUOM__c, vlocity_cmt__RelationshipType__c, vlocity_cmt__RootItemId__c, vlocity_cmt__SequenceNumber__c, vlocity_cmt__SerialNumber__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__ServiceDate__c, vlocity_cmt__SubAction__c, ReliesOnReferenceId__c, vlocity_cmt__AssetReferenceId__c, Avoid_vlc_pricing__c, DDD__c, Discount_Type__c, Discount_Values__c, Group__c, ParentGroup__c, BonusValue__c, Price_Type__c, RegionalState__c, Regional__c, SAP_ID__c, State__c, Subgroup__c, Template_Default_Qty__c, Template_Max_Qty__c, Template_Min_Qty__c, Payment_Term__c, vlocity_cmt__AttributeMetadataChanges__c, vlocity_cmt__SubscriptionId__c, PlanGroup__c, TradeIn__c, TypeOfRequest__c from OpportunityLineItem';
        } else if (ObjectType == 'Quote') {
            soqlLI = 'Select Id, IsDeleted, LineNumber, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, QuoteId, PricebookEntryId, OpportunityLineItemId, Quantity, UnitPrice, Discount, HasRevenueSchedule, HasQuantitySchedule, Description, ServiceDate, Product2Id, SortOrder, HasSchedule, ListPrice, Subtotal, TotalPrice, vlocity_cmt__Action__c, vlocity_cmt__AssetReferenceId__c, vlocity_cmt__AttributeSelectedValues__c, vlocity_cmt__BillingAccountId__c, vlocity_cmt__ConnectDate__c, vlocity_cmt__CpqCardinalityMessage__c, vlocity_cmt__CpqMessageData__c, vlocity_cmt__CurrencyPaymentMode__c, vlocity_cmt__DisconnectDate__c, vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c, vlocity_cmt__EffectiveOneTimeTotal__c, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__Filter__c, vlocity_cmt__InCartQuantityMap__c, vlocity_cmt__IsProductTrackAgreement__c, vlocity_cmt__ItemName__c, vlocity_cmt__JSONAttribute__c, vlocity_cmt__JSONNode__c, vlocity_cmt__LineNumber__c, vlocity_cmt__Modification__c, vlocity_cmt__OneTimeCalculatedPrice__c, vlocity_cmt__OneTimeCharge__c, vlocity_cmt__OneTimeDiscountPrice__c, vlocity_cmt__OneTimeLoyaltyPrice__c, vlocity_cmt__OneTimeLoyaltyTotal__c, vlocity_cmt__OneTimeManualDiscount__c, vlocity_cmt__OneTimeTotal__c, vlocity_cmt__OverageCalculatedPrice__c, vlocity_cmt__OverageCharge__c, vlocity_cmt__OverageDiscountPrice__c, vlocity_cmt__OverageManualDiscount__c, vlocity_cmt__OverageTotal__c, vlocity_cmt__OverageUOM__c, vlocity_cmt__ParentItemId__c, vlocity_cmt__PremisesId__c, vlocity_cmt__PricingLogData__c, vlocity_cmt__Product2Id__c, vlocity_cmt__ProductAttribXN__c, vlocity_cmt__ProductHierarchyPath__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__Query__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__RecurringDiscountPrice__c, vlocity_cmt__RecurringManualDiscount__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__RecurringUOM__c, vlocity_cmt__Recurring_UOM__c, vlocity_cmt__RelationshipType__c, vlocity_cmt__RootItemId__c, vlocity_cmt__SequenceNumber__c, vlocity_cmt__SerialNumber__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__ServiceDate__c, vlocity_cmt__SubAction__c, vlocity_cmt__AttributeMetadataChanges__c, vlocity_cmt__SubscriptionId__c, DDD__c, Discount_Type__c, Discount_Values__c, Group__c, ParentGroup__c, BonusValue__c, PlanGroup__c, Price_Type__c, Region__c, RegionalState__c, ReliesOnReferenceId__c, SAP__c, State__c, Subgroup__c, Template_Default_Qty__c, Template_Max_Qty__c, Template_Min_Qty__c, TradeIn__c, TypeOfRequest__c, Avoid_vlc_pricing__c, Payment_Term__c from QuoteLineItem';
        } else if (ObjectType == 'Order') {
            soqlLI = 'select Id, IsDeleted, OrderId, vlocity_cmt__AssetReferenceId__c, PricebookEntryId, OriginalOrderItemId, QuoteLineItemId, AvailableQuantity, Quantity, UnitPrice, ListPrice, TotalPrice, ServiceDate, EndDate, Description, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, OrderItemNumber, vlocity_cmt__Action__c, vlocity_cmt__ActivationName__c, vlocity_cmt__Additional_Discount__c, vlocity_cmt__AssetId__c, vlocity_cmt__BillingAccountId__c, vlocity_cmt__ConnectDate__c, vlocity_cmt__CpqCardinalityMessage__c, vlocity_cmt__CpqMessageData__c, vlocity_cmt__CurrencyPaymentMode__c, vlocity_cmt__DisconnectDate__c, vlocity_cmt__EffectiveOneTimeLoyaltyTotal__c, vlocity_cmt__EffectiveOneTimeTotal__c, vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__EffectiveRecurringTotal__c, vlocity_cmt__ExpectedCompletionDate__c, vlocity_cmt__Filter__c, vlocity_cmt__FulfilmentStatus__c, vlocity_cmt__InCartQuantityMap__c, vlocity_cmt__IsChangesAccepted__c, vlocity_cmt__IsChangesAllowed__c, vlocity_cmt__IsEditable__c, vlocity_cmt__IsProductTrackAgreement__c, vlocity_cmt__ItemName__c, vlocity_cmt__JSONAttribute__c, vlocity_cmt__JSONNode__c, vlocity_cmt__LineItemNumString__c, vlocity_cmt__LineItemNumber__c, vlocity_cmt__LineNumber__c, vlocity_cmt__MRC__c, vlocity_cmt__Modification__c, vlocity_cmt__MonthlyTotal__c, vlocity_cmt__OneTimeCalculatedPrice__c, vlocity_cmt__OneTimeCharge__c, vlocity_cmt__OneTimeDiscountPrice__c, vlocity_cmt__OneTimeLoyaltyPrice__c, vlocity_cmt__OneTimeLoyaltyTotal__c, vlocity_cmt__OneTimeManualDiscount__c, vlocity_cmt__OneTimeTotal__c, vlocity_cmt__OverageCalculatedPrice__c, vlocity_cmt__OverageCharge__c, vlocity_cmt__OverageDiscountPrice__c, vlocity_cmt__OverageManualDiscount__c, vlocity_cmt__OverageTotal__c, vlocity_cmt__OverageUOM__c, vlocity_cmt__ParentItemId__c, vlocity_cmt__ParentLineItemNumber__c, vlocity_cmt__ParentOrderProduct__c, vlocity_cmt__PremisesId__c, vlocity_cmt__PricingLogData__c, vlocity_cmt__Product2Id__c, vlocity_cmt__ProductAttribXN__c, vlocity_cmt__ProductHierarchyPath__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__Query__c, vlocity_cmt__RecurringCalculatedPrice__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__RecurringDiscountPrice__c, vlocity_cmt__RecurringManualDiscount__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__RecurringUOM__c, vlocity_cmt__RelationshipType__c, vlocity_cmt__RequestDate__c, vlocity_cmt__RequestedChange__c, vlocity_cmt__RequestedCompletionDate__c, vlocity_cmt__RootItemId__c, vlocity_cmt__SequenceNumber__c, vlocity_cmt__SerialNumber__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__SubAction__c, vlocity_cmt__ThorJeopardyStatus__c, ReliesOnReferenceId__c, Acrescimo_Desconto__c, DDD__c, Fidelidade__c, Forma_de_Pagamento__c, Group__c, JanelaPortabilidade__c, MSISDN__c, Meses_de_Fidelidade__c, NumeroProvisorio__c, Operator__c, PlanType__c, Portabilidade__c, TemplateDefaultQty__c, TemplateMaxQty__c, TemplateMinQty__c, ParentGroup__c, ReliesOn__c, SAP_ID__c, Subgroup__c, vlocity_cmt__AttributeMetadataChanges__c, vlocity_cmt__AttributeSelectedValues__c, vlocity_cmt__RequestedStartDate__c, vlocity_cmt__SubscriptionId__c, AnotherDeviceColor__c, Avoid_vlc_pricing__c, DeviceSecondOptionColor__c, Discount_Type__c, Discount_Values__c, DonatorDocumentNumber__c, DonatorEmail__c, DonatorName__c, DonatorPhone__c, ICCID__c, IMEI__c, DescricaoMulta__c, PlanGroup__c, PortabilityNumber__c, ProductCode__c, RegionalState__c, Regional__c, State__c, Template_Default_Qty__c, Template_Max_Qty__c, Template_Min_Qty__c, TradeIn__c, TypeOfDelivery__c, TypeOfRequest__c, Payment_Term__c, DescricaoPromocao__c, Grupo__c, NumeroParcelas__c, Promotion_Log__c, ValorTaxa__c, BonusValue__c, Template_Multi_Max_Qty__c, vlocity_cmt__Product2Id__r.vlocity_cmt__Type__c, Order.vlocity_cmt__PriceListId__r.Name from OrderItem';
        }
        
        system.debug('dfm: ' + soqlLI);
        soqlLI = soqlLI.replace('LastViewedDate', '').replace('LastModifiedDate', '').replace('LastReferencedDate', '').replace(', ,', ',').replace(',,', ',').replace(', FROM', ' FROM');

        if(ObjectType == 'Order'){
        // for OrderItem only, ObjectDescribe does NOT return Product2Id so need to insert it manually
            Integer i = soqlLI.indexOf('from');
            String pt1 = soqlLI.mid(0, i);
            String pt2 = soqlLI.substring(i);
            String combo = pt1;
            combo += ',Product2Id ';
            combo += pt2;
            soqlLI = combo;
            String one = '1';
        }
        if (lIncludeItemsList.isEmpty() ){
            soqlLI += ' where ' + ObjectType + 'Id = :TemplateId AND TemplateDefaultQty__c = :one order by vlocity_cmt__LineNumber__c asc' ;
        }
        else{
            soqlLI += ' where ' + ObjectType + 'Id = :TemplateId and Id in:lIncludeItemsList order by vlocity_cmt__LineNumber__c asc' ;
        }
        system.debug(':::templateId: ' + templateId);
        system.debug(':::templLIs: ' + soqlLI);
        List<Sobject> templLIs = Database.query(soqlLI);
      
        String testAssetRef = '';
        if (ObjectType == 'Opportunity'){
            testAssetRef = (String)templLIs[0].get('vlocity_cmt__AssetReferenceId__c');
        } else {
            testAssetRef = (String)templLIs[0].get('vlocity_cmt__AssetReferenceId__c');
        }
        Boolean isId = Test.isRunningTest() ? true : !testAssetRef.containsAny('-');

        //clone XLI  setup
        List<SObject> newItems = new List<SObject>();
        Map<Id,SObject> oldNewIds = new Map<Id,SObject>();  // lookup by Id
        Map<Id,SObject> oldNewIds2 = new Map<Id,SObject>(); // only used prior to V103 where AssetRefId populated with XLI.Id
        Map<String, SObject> oldNewStrings = new Map<String, SObject>(); //lookup by string (AssetRefId)
        SObject tempLI;
                
        // BC added for flexibility.
        setup(input,output,options,existingParent,parent,templLIs);
        vlocity_cmt.CoreGlobalInterfaces.GenerateGlobalKeyInterface gg = new vlocity_cmt.DefaultGenerateGlobalKeyImplementation();
        String guid = '';
        
        // First loop: iterate through template LIs and clone them to tempLI **************
        for(SObject Li:templLIs){

            try {
    
                tempLI = Li.clone();
       
                // populate OQO headerId
                tempLI.put(ObjectType + 'Id',existingId);

                // populate LineNumber__c
                String lineNumber = ((String)tempLI.get('vlocity_cmt__LineNumber__c'));
                List<String> numberItems = lineNumber.split('\\.');
        
                // for OptyLI it the line numbers come over as 'null.0001'
                String testRoot = String.valueOf(numberItems[0]);
                Integer rootLN;
                system.debug(':::testRoot: ' + testRoot);
                if (testRoot == 'null'){
                    rootLN = Integer.valueOf(numberItems[1]);
        
                } else {
                    rootLN = Integer.valueOf(numberItems[0]);

                }

                rootLn += maxLineNumber;
                numberItems[0] = padLeft(rootLn);
                tempLI.put('vlocity_cmt__LineNumber__c',String.join(numberItems,'.'));

                if(objectTypeLI=='OpportunityLineItem')
                {
                    tempLI.put('TotalPrice',null);     // special logic for OptyLI due to SFDC requirements for UnitPrice and TotalPrice
                    guid = gg.generateKey(null, null);
                    tempLI.put('vlocity_cmt__AssetReferenceId__c', guid);
                } else {
                    tempLI.put('ReliesOnReferenceId__c', referenceId);
                } 
                  
                oldNewIds.put(Li.Id, tempLI);
                
                System.debug('oldNewIds:: ' + oldNewIds);
               
                
                //populate Map oldNewStrings                
                if(objectTypeLI=='OpportunityLineItem'){
                    oldNewStrings.put((String)Li.get('vlocity_cmt__AssetReferenceId__c'), tempLI);
                } else {
                    oldNewStrings.put((String)Li.get('vlocity_cmt__AssetReferenceId__c'), tempLI);
                }
                system.debug('oldNewStrings'+  oldNewStrings);
                

                if(oIncludeItemsListQtd != null){
                    for(Object a: oIncludeItemsListQtd)
                    {
                        Map<String,Object> element = (Map<String,Object>) a;
                        String productIdQtd = (String)element.get('productId');
                        Integer qtd = (Integer)element.get('inputQtd');
                        String installments = (String)element.get('installmentSelected');
                        String productIdTemp = (String)tempLI.get('vlocity_cmt__Product2Id__c');
                        if(productIdQtd.equals(productIdTemp)){
                            tempLI.put('Quantity', decimal.valueOf(qtd));
                            if(installments != null){
                                tempLI.put('NumeroParcelas__c', installments);
                            }
                        }
                    }
                }
                    
                
                
    
                newItems.add(tempLI);
               
                
            } catch (Exception e) {
                System.debug('Exception type caught: ' + e.getTypeName());
                System.debug('Exception Msg: ' + e.getMessage());
                System.debug('Exception Cause: ' + e.getCause());
                System.debug('Exception Stack Trace: ' + e.getStackTraceString());
                throw e;
            }

        }
      
        // this if logic shouldnt be necessary v103 and after.  AssetRefId should be a GUID already.  Need to populate oldNewIds2 tho     
        if (isId) {  
            insert newItems;

            for(SObject Li:templLIs){
                SObject newItem = oldNewIds.get(Li.Id);
                //populate vlocity_cmt__AssetReferenceId__c with GUID prior to 103
                guid = gg.generateKey(null, null);
                if(objectTypeLI !='OpportunityLineItem')
                {
                    newItem.put('vlocity_cmt__AssetReferenceId__c',guid);  //for order or quote 
                }
                oldNewIds2.put(Li.Id, newItem);
            }
        }

        String lineNum = '';
        Id rootLI;
        Id rootProdId;

        Map<String,Object> plan = new Map<String,Object>();
        plan.put('PlanName', planName);
        plan.put('items', lIncludeProductsItemsList);
        plan.put('guid', NewGuid());
        output.put('AddedItems', plan);
        
        system.debug('isId:::::: '+isId);
         
        if (isId){
            update newItems;
        } else {
            insert newItems;
        }
        
         
        
        for(SObject LI:templLIs) {
		
            try {

                String OldReliesOn = (String)LI.get('ReliesOnReferenceId__c');
                                              
                if (OldReliesOn != null) {
                    // Get what the original line items relies on.
                    // This is a text, but it should be a line item
                    SObject newReliesOn = oldNewStrings.get(OldReliesOn);

                    System.debug('OldReliesOn: ' + OldReliesOn);
                    
                    System.debug('newReliesOn: ' + newReliesOn);

                    // Get the new order Item based upon then original
                    String assetRID = (String)Li.get('vlocity_cmt__AssetReferenceId__c');
                    SObject newItem = oldNewStrings.get(assetRID);
                    if(referenceId != null){
                        newItem.put('ReliesOnReferenceId__c', referenceId); 
                    }
                    else 
                    {
                        if(newReliesOn != null)
                        {
                            newItem.put('ReliesOnReferenceId__c', (String)newReliesOn.get('vlocity_cmt__AssetReferenceId__c'));  
                        }
                    }
                }
                    
            } catch (Exception e) {
                // expect the field not to exist.
                System.debug('Exception type caught: ' + e.getTypeName());
                System.debug('Exception Msg: ' + e.getMessage());
                System.debug('Exception Cause: ' + e.getCause());
                System.debug('Exception Stack Trace: ' + e.getStackTraceString());
                throw e;
            }
        }
		
        newItems = addParentItemId(newItems, (String)input.get('parentProductItem'),output );
        
        List<SObject> deleteItemList = new List<SObject>();
        for (SObject verifyItem : newItems){
			OrderItem prodItem = (OrderItem)verifyItem;
            if(ObjectType == 'Order' && verifyItem.get('vlocity_cmt__AssetReferenceId__c') != null && verifyItem.get('ReliesOnReferenceId__c') == null && (prodItem.vlocity_cmt__Product2Id__r.vlocity_cmt__Type__c == 'Serviço' || prodItem.vlocity_cmt__Product2Id__r.vlocity_cmt__Type__c == 'None') && prodItem.Order.vlocity_cmt__PriceListId__r.Name == 'Comercial Residencial'){
                deleteItemList.add(verifyItem);
            }
        }
        update newItems;
        if(!deleteItemList.isEmpty()){
        	delete deleteItemList;            
        }
        return retval;
    }

    public List<SObject> addParentItemId(List<SObject> newItems, String parentId, Map<String, Object> output ){
        for(SObject item: newItems){
            item.put('vlocity_cmt__ParentItemId__c',parentId);
            output.put('orderItem', item.Id);
        }
        return newItems;
    }


    global virtual void setup(Map<String, Object> input
                                ,Map<String, Object> output
                                ,Map<String, Object> options
                                ,SObject existingParent
                                ,SObject templateParent
                                ,List<SObject> templateLi
                                ) {

    }
    
    global static String NewGuid() {
        String returnValue;
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        returnValue = h.SubString(0,4);
        returnValue += '-';
        returnValue += h.SubString(4,8);
        returnValue += '-';
        returnValue += h.SubString(8,12);
        returnValue += '-';
        returnValue += h.SubString(12,16);
        return returnValue;
    }

}