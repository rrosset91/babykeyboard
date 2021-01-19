global with sharing class TemplateActions implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        Boolean retval = false;
        
        if (methodName == 'CloneFromTemplate') {
            retval = CloneTemplate(input,output,options);
        }
        
        return retval;
    }
    
    public static Integer levelLength = 4;
    
    public static String padLeft(Integer i) {
        String str = String.valueOf(i);
        while(str.length() < levelLength) {
            str = '0' + str;
        }
        
        return str;
    }
    
    private String getQuery(String sObjectType){
        String expr = '';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(sObjectType).getDescribe().fields.getMap();
        
        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) {
            expr += ' ' + s + ',';
        }
        
        //Added by Danilo/Marcos
        if(sObjectType=='OrderItem' || sObjectType=='OpportunityLineItem') {
            expr += ' Product2.ProductCode,';
        }
        
        if (expr.subString(expr.Length()-1, expr.Length()) == ','){
            expr = expr.subString(0,expr.Length()-1);
        }
        
        String qry = 'SELECT ' + expr + ' FROM '+sObjectType;
        System.Debug(qry);
        return qry;
    }
    
    public Boolean CloneTemplate(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        Boolean retval = false;
        
        //query Template Order
        
        String TemplateId = (String) input.get('TemplateId');
        String TemplateName = (String) input.get('TemplateName');
        String TemplateObjectType = (String) input.get('TemplateObjectType');
        
        Product2 simcardAvulso = [SELECT Id, ProductCode 
                                  FROM Product2 
                                  WHERE ProductCode = 'PME_SimCardAvulso_0001'];
        
        //<DA> 21/2/19
        List <Object> oIncludeItemsList = new List <Object>();
        try {
            oIncludeItemsList = (List <Object>) input.get('includeIds');    
        } catch(Exception e) {
            oIncludeItemsList.add((Id)input.get('includeIds'));
        }
        
        List<String> lIncludeItemsList = new List<String> ();
        
        if(oIncludeItemsList != null) {
            for(Object o : oIncludeItemsList) {
                lIncludeItemsList.add(String.valueOf(o));
            }
        }
        
        //if(!String.isBlank(sIncludeItemsList))
        //   lIncludeItemsList = sIncludeItemsList.split(',');
        //</DA> 21/2/19
        
        if ((TemplateId == null) && (TemplateName != null)) {
            String tempSoql = 'SELECT Id FROM ' + TemplateObjectType + ' WHERE Name =:TemplateName LIMIT 1';
            SObject o = database.query(tempSoql);
            TemplateId = o.Id;
        }
        
        String RecordType = (String) ((Id) TemplateId).getSObjectType().getDescribe().getName();
        
        //<DA> -11/1/19: Get ParentGroup, Group, Subgroup parameters
        String sParentGroup = (String) input.get('ParentGroup');
        String sGroup = (String) input.get('Group');
        String sContract = (String) input.get('ContractId');
        String sSubgroup = (String) input.get('Subgroup');
        Object oQuantity = (Object) input.get('Quantity');
        String sTradeIn = (String) input.get('TradeIn');
        
        // <DanMas>: get NumberOfGroupInTheCart
        Integer sNumberOfGroupInTheCart = (Integer) input.get('NumberOfGroupInTheCart');
        
        // <DanMas>: get Type SubType 
        String sType = (String) input.get('Type');
        String sSubType = (String) input.get('SubType');
        String sReliesOnReferenceId = (String) input.get('ReliesOnReferenceId__c');
        // </DanMas>
        
        // <Russo>: Get the type of request 
        String sTypeOfRequest = (String) input.get('TypeOfRequest__c');
        // </Russo>
        
        //<DanMas> - 03/4/19: Get Sap ID, Description, Price parameters
        String sSimCardSapId = (String) input.get('SimCard__SAP_ID__c');
        String sSimCardDescription = (String) input.get('SimCard__Description__c');
        Decimal sSimCardPrice = (Decimal) input.get('SimCard__Price__c');
        
        Integer iQuantity;
        //Test if the parrameter is not present (so the oQuantity will be null string)
        if(oQuantity instanceof String) {
            iQuantity = 1;
        } else if(oQuantity instanceof Integer) {
            iQuantity = (Integer) oQuantity;
        }        
        //  <DanMas>: Commented String sType;
        //  <DanMas>: Commented String sSubtype;
        //</DA>
        
        String existingId = (String)input.get('ExistingId');
        
        String TemplateSoql = getQuery(RecordType);
        TemplateSoql += ' where Id =\'' + TemplateId + '\'';
        SObject parent = Database.query(TemplateSoql);
        
        //create new Account
        
        Integer maxLineNumber = 0;
        String recordTypeLI;
        if(RecordType == 'Opportunity') {
            recordTypeLI = 'OpportunityLineItem';
            //Not implemented yet.
            
        } else if(RecordType == 'Quote') {
            recordTypeLI = 'QuoteLineItem';
        } else if(RecordType == 'Order') {
            recordTypeLI = 'OrderItem';
            
        }
        
        if((existingId == null) || (existingId == '')) {
            String accountId = (String)input.get('AccountId');
            if(accountId == null) {
                String accountName = (String)input.get('AccountName');
                if(accountName == null) {
                    //throw exception
                    output.put('Exception','Please input an accountName, accountId or existingOrderId');
                    return retval;
                }
                Account act = new Account(Name=accountName);
                insert act;
                accountId = act.Id;
            }
            Sobject newParent = parent.clone();
            newParent.put('AccountId', accountId);
            newParent.put('ContractId', sContract);
            //system.debug('newParentHenrich: '+newParent);
            insert newParent;
            existingId = newParent.Id;
            
        } else {
            
            TemplateSoql = getQuery(recordType);
            TemplateSoql += ' where Id =\'' + existingId + '\'';
            SObject existingParent = Database.query(TemplateSoql);
            existingId = existingParent.id;
            //System.debug('getBaseQuery: '+recordTypeLI);
            String soqlEL = getQuery(recordTypeLI);
            soqlEL += ' where ' + recordType + 'Id = :existingId order by vlocity_cmt__LineNumber__c desc limit 1';
            
            try {
                
                List<SObject> LIs = Database.query(soqlEL);
                if ((Lis != null) && (LIs.size() == 1)) {
                    String temp = (String) LIs[0].get('vlocity_cmt__LineNumber__c');
                    maxLineNumber = Integer.valueOf(temp.split('\\.')[0]);
                }
            } catch (Exception e) {
                //expect no rows.
            }
        }
        
        output.put('NewId',existingId);
        
        //query Template Order's Line Item
        String soqlLI = getQuery(recordTypeLI);
        //<DA>
        // <DanMas>: Commented  soqlLI += ' Product2.vlocity_cmt__Type__c, Product2.vlocity_cmt__SubType__c';
        //</DA>
        //soqlLI += ' where ' + recordType + 'Id = :TemplateId order by vlocity_cmt__LineNumber__c asc' ;
        //<DA> 21/2/19 Add a filter to the query in orderto search only the assesrefId sended by param
        
        if (lIncludeItemsList.isEmpty() ){ // <DanMas>: Change ==null to isEmpty(), Mar 15 2019 DanMas
            soqlLI += ' where ' + recordType + 'Id = :TemplateId order by vlocity_cmt__LineNumber__c asc' ;
        }
        else{
            soqlLI += ' where ' + recordType + 'Id = :TemplateId and Product2.Id in:lIncludeItemsList order by vlocity_cmt__LineNumber__c asc' ;
        }
        System.debug('soqlLI MARCOS: ' + soqlLI);
        
        //</DA> 21/2/19
        List<Sobject> LIs = Database.query(soqlLI);
        //output.put('ois',LIs);
        //clone Order Item
        List<SObject> newItems = new List<SObject>();
        Map<Id,SObject> oldNewIds = new Map<Id,SObject>();
        SObject tempLI;
        for(SObject Li : LIs) {
            
            //skip simcard if the request type is TT PF/PJ
            /* Gabriel Russo
if( ((String)Li.get('Product2Id')) == simcardAvulso.ProductCode && sTypeOfRequest == 'TT PF/PJ')
continue;
*/ // <DanMas>: Commented for TT PF/PJ
            
            tempLI = Li.clone();
            tempLI.put(recordType + 'Id',existingId);
            String lineNumber = ((String) tempLi.get('vlocity_cmt__LineNumber__c'));
            List<String> numberItems = lineNumber.split('\\.');
            Integer rootLN = Integer.valueOf(numberItems[0]);
            rootLn += maxLineNumber;
            numberItems[0] = padLeft(rootLn);
            tempLI.put('vlocity_cmt__LineNumber__c', String.join(numberItems, '.'));
            
            if(RecordType == 'Opportunity') {
                tempLI.put('TotalPrice',null);    // this is added for SF Opty insert logic for Oppty, [KB] Feb 8 2019            
            }
            
            // <DanMas>:  Added to Insert the informazion BEFORE INSERT THE CLONING OF TEMPLATE
            System.debug('sTypeOfRequest: PAPAPA' + (String)Li.get('vlocity_cmt__Product2Id__c') + ' ProductCode: ' + simcardAvulso.Id);
            
            tempLI.put('TypeOfRequest__c', sTypeOfRequest); //DanMas added to save the TypeOfRequest also on the SimCard Level
            
            if( ((String) Li.get('vlocity_cmt__Product2Id__c')) == simcardAvulso.Id) {
                tempLI = putTtPfPj(tempLI, sSimCardSapId, sSimCardDescription, sTypeOfRequest, sSimCardPrice);
            } 
            
            Boolean isFranquiaIndividual = sType =='Franquia' && sSubtype == 'Individual';
            Boolean isPluginCompartilhado = sType=='Plug-In' && sSubtype=='Compartilhado';
            if(sNumberOfGroupInTheCart != null && (isFranquiaIndividual || isPluginCompartilhado)) { // Added logic on sSubType NET Embratel ,Feb 27 2019 DanMas
                tempLI.put('PlanGroup__c',String.valueOf(sNumberOfGroupInTheCart));
            }
            
            oldNewIds.put(Li.Id,tempLI);
            
            newItems.add(tempLI);
        }
        
        System.debug('LISTA INSERT: ' + newItems);
        
        insert newItems;
        
        for(SObject LI : LIs) {
            
            try {
                
                //skip simcard if the request type is TT PF/PJ
                //Gabriel Russo
                /* if( ((String)Li.get('Product2Id')) == simcardAvulso.ProductCode && sTypeOfRequest == 'TT PF/PJ')
continue;
*/ // <DanMas>: Commented for TT PF/PJ
                
                Id OldReliesOn = (Id)LI.get('ReliesOnReferenceId__c');    // changed for Oppty context, [KB] Feb 8 2019
                
                //<DA>
                // <DanMas>: Commented sType = (String)LI.get('Product2.vlocity_cmt__Type__c');
                // <DanMas>: Commented sSubtype = (String)LI.get('Product2.vlocity_cmt__SubType__c');
                //</DA>
                
                tempLi = oldNewIds.get(LI.Id);
                
                if(recordType != 'Order') {
                    tempLi.put('vlocity_cmt__AssetReferenceId__c',tempLi.Id);    // changed for Oppty context, [KB] Feb 8 2019 
                    tempLi.put('TotalPrice',0.00); 
                } else {
                    tempLi.put('vlocity_cmt__AssetReferenceId__c',tempLi.Id);    // changed for Oppty context, [KB] Feb 8 2019 
                }   
                
                if(OldReliesOn != null) {
                    // Get what the original line items relies on.
                    // This is a text, but it should be a line item
                    SObject newReliesOn = oldNewIds.get(OldReliesOn);
                    System.debug('OldReliesOn' + OldReliesOn);
                    System.debug('newReliesOn' + newReliesOn);
                    
                    //OrderItem newReliesOn = oldNewIds.get((Id)'8022C00000022zsQAA');
                    Id newReliesOnId = (Id) newReliesOn.Id;
                    
                    // Get the new order Item based upon then original
                    SObject newItem = oldNewIds.get(Li.Id); 
                    
                    //<DA> 11/1/19: Update ParentGroup, Group, Subgroup
                    newItem.put('ParentGroup__c', sParentGroup);
                    newItem.put('Group__c', sGroup);
                    newItem.put('Subgroup__c', sSubgroup);
                    //System.debug('sType ' + sType + ' sSubtype '+sSubtype);
                    
                    // <DanMas>: Control the Type Franquia to save the parameter of Planos AssetReferenceId
                    if(sType=='Franquia' || sType=='Plug-In'){// Added logic on sType Plug-In ,Mar 06 2019 DanMas
                        newItem.put('ReliesOnReferenceId__c',sReliesOnReferenceId ); 
                        output.put('FranquiaAssetReferenceId__c',tempLi.Id);  // <DanMas>: put the AssetReferenceId in bpTree
                    } else {
                        newItem.put('ReliesOnReferenceId__c',newReliesOn.Id); // changed for Oppty context, [KB] Feb 8 2019  
                    }
                    
                    Boolean isFranquia = sType=='Franquia';
                    Boolean isIndIndNetEmbOrComp = sSubtype=='Individual' || sSubtype=='Individual - NET/Embratel' || sSubtype=='Compartilhado';
                    Boolean isPluginCompartilhado = sType=='Plug-In' && sSubtype=='Compartilhado';
                    if((isFranquia && isIndIndNetEmbOrComp) || isPluginCompartilhado) { // Added logic on sSubType NET Embratel ,Feb 27 2019 DanMas
                        newItem.put('TradeIn__c', sTradeIn);
                        newItem.put('TypeOfRequest__c', sTypeOfRequest);
                        newItem.put('Quantity', iQuantity);
                        sType=''; // <DanMas>: blank the sType
                        sSubtype=''; // <DanMas>: blank the sSubtype
                    } else {
                        newItem.put('Quantity', iQuantity); // <DanMas>: Change the value from 1 to iQuantity,Mar 06 2019 DanMas
                    }
                    //</DA>
                    
                    //<DanMas> - 03/4/19: Get Sap ID, Description, Price parameters
                    System.debug('sTypeOfRequest: ' + sTypeOfRequest);
                    System.debug('sTypeOfRequest: PAPAPA' + (String) Li.get('vlocity_cmt__Product2Id__c') + ' ProductCode: ' + simcardAvulso.Id);
                    
                    if( ((String) Li.get('vlocity_cmt__Product2Id__c')) == simcardAvulso.Id){
                        newItem.put('SAP_ID__c', sSimCardSapId);
                        newItem.put('Description', sSimCardDescription);
                        
                        if(sTypeOfRequest == 'TT PF/PJ'){
                            System.debug('sTypeOfRequest: ' + sTypeOfRequest);
                            //newItem.put('TotalPrice',1);
                            //newItem.put('vlocity_cmt__RecurringTotal__c',1);
                            newItem.put('Avoid_vlc_pricing__c', true);
                            //newItem.put('vlocity_cmt__EffectiveRecurringTotal__c',);
                        } else {
                            newItem.put('vlocity_cmt__EffectiveRecurringTotal__c', sSimCardPrice);
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
        System.debug('newItems: ' + newItems);
        
        update newItems;
        return retval;
    }
    
    @TestVisible
    private SObject putTtPfPj(SObject tempLI, String sSimCardSapId, String sSimCardDescription, String sTypeOfRequest, Decimal sSimCardPrice) {
        tempLI.put('SAP_ID__c', sSimCardSapId);
        tempLI.put('Description', sSimCardDescription);
        
        if(sTypeOfRequest == 'TT PF/PJ') {
            System.debug('sTypeOfRequest INSERT:' + sTypeOfRequest);
            //tempLI.put('TotalPrice',1);
            tempLI.put('UnitPrice', 0.0);
            tempLI.put('vlocity_cmt__RecurringCharge__c', 0.0);
            tempLI.put('vlocity_cmt__RecurringCalculatedPrice__c', 0.0);
            tempLI.put('vlocity_cmt__RecurringTotal__c', 0.0);
            tempLI.put('vlocity_cmt__EffectiveRecurringTotal__c', 0.0);
            tempLI.put('vlocity_cmt__OverageTotal__c', sSimCardPrice);	
        } else {
            tempLI.put('vlocity_cmt__EffectiveRecurringTotal__c', sSimCardPrice);
            tempLI.put('vlocity_cmt__OverageTotal__c', sSimCardPrice);
        }
        
        return tempLI;
    }
}