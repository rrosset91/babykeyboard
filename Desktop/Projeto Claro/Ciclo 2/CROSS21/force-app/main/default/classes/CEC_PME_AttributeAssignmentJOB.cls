/*
* Autor: Marcos Aurélio - Deloitte
* Data: 28/02/2019
* Descrição: 	[CEC/ID: CEC FASE 1/ XXXXX]
				[Time: SQUAD PME - Sprint 8]
				[JOB criado para processar o objeto ProductIO__c carregado pelo Informática Cloud e replicar suas
				informações nos objetos de produtos dentro do salesforce e vlocity]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 26/03/2019    
* Autor: Marcos Aurélio
* Alterações: Adicionado o produto SIMCARD na Sprint 10 - US 356B.
* Inserindo e atualizando as informações da custom setting PME_SimCard_Info__c.
*/

public class CEC_PME_AttributeAssignmentJOB {

    /*
    * Autor: Marcos Aurélio - Deloitte
    * Descrição: 	[CEC/ID: CEC FASE 1/ XXXXX]
					[Time: SQUAD PME - Sprint 8]
					[Método que replica os dados contidos no objeto ProductIO para as demais classes relativo
					a lista de produtos do PME.
					Tabelas Replicadas: Product2(Salesforce), PriceBookEntry(Salesforce), vlocity_cmt__AttributeAssignment__c (vlocity) e vlocity_cmt__PriceListEntry__c(vlocity)]
    */
    public static void productAssignment(){
        List<Product2> lstPrd = new List<Product2>();
        List<PricebookEntry> lstPbe = new List<PricebookEntry>();
        List<vlocity_cmt__AttributeAssignment__c> lstAttAssigment = new List<vlocity_cmt__AttributeAssignment__c>();
        List<Pricebook2> standardPB = (Test.isRunningTest())
          ? new list<Pricebook2>{ new Pricebook2(Id = Test.getStandardPricebookId())}
          : [select id from Pricebook2 where isStandard=true];
        List<vlocity_cmt__PriceListEntry__c> lstPriceListEntry = new List<vlocity_cmt__PriceListEntry__c>();
        List<PME_SimCard_Info__c> lstSimCard = new List<PME_SimCard_Info__c>();
        Map<String, String> mapIdObjClass = new Map<String, String>();
        Map<String, String> mapSAPIdPrdId = new Map<String, String>();
        Map<String, String> mapAttCategory = new Map<String, String>();
        Map<String, String> mapAttribute = new Map<String, String>();
        Map<String, String> mapPicklist = new Map<String, String>();
        Map<String, List<vlocity_cmt__PicklistValue__c>> mapPickListValue = new Map<String, List<vlocity_cmt__PicklistValue__c>>();
        Set<String> pbeProductIds = new Set<String>();
        Set<String> setAttAssigmentKey = new Set<String>();
        vlocity_cmt__PriceList__c priceList = [SELECT Id FROM vlocity_cmt__PriceList__c WHERE vlocity_cmt__Code__c = 'Price_List_PME' LIMIT 1];
        vlocity_cmt__PricingElement__c priceElement = [SELECT Id FROM vlocity_cmt__PricingElement__c WHERE vlocity_cmt__Code__c = 'R$0 Generico' and vlocity_cmt__PriceListId__c =: priceList.Id];
        
        for(PricebookEntry pbe : [SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id =: standardPB[0].Id]){
            pbeProductIds.add(pbe.Product2Id);
        }
        
        for(vlocity_cmt__ObjectClass__c objClass : [SELECT Id, Name FROM vlocity_cmt__ObjectClass__c]){
            mapIdObjClass.put(objClass.Name, objClass.Id);
        }
        
        for(vlocity_cmt__AttributeCategory__c attCategory : [SELECT Id, vlocity_cmt__Code__c FROM vlocity_cmt__AttributeCategory__c]){
            mapAttCategory.put(attCategory.vlocity_cmt__Code__c ,attCategory.Id);
        }
        
        for(vlocity_cmt__Attribute__c att : [SELECT Id, vlocity_cmt__Code__c FROM vlocity_cmt__Attribute__c]){
            mapAttribute.put(att.vlocity_cmt__Code__c , att.Id);
        }
        
        for(vlocity_cmt__Picklist__c pick : [SELECT Id, vlocity_cmt__Code__c FROM vlocity_cmt__Picklist__c]){
            mapPicklist.put(pick.vlocity_cmt__Code__c, pick.Id);
        }
        
        for(vlocity_cmt__PicklistValue__c pickValue : [SELECT vlocity_cmt__PicklistId__c, JSON__c, Name, vlocity_cmt__Value__c, vlocity_cmt__Sequence__c FROM vlocity_cmt__PicklistValue__c Where vlocity_cmt__PicklistId__c =: mapPicklist.values()]){
            if(mapPickListValue.containsKey(pickValue.vlocity_cmt__PicklistId__c)){
                List<vlocity_cmt__PicklistValue__c> lstPickValue = mapPickListValue.get(pickValue.vlocity_cmt__PicklistId__c);
                lstPickValue.add(pickValue);
            } else {
                List<vlocity_cmt__PicklistValue__c> lstPickValue = new List<vlocity_cmt__PicklistValue__c>();
                lstPickValue.add(pickValue);
                mapPickListValue.put(pickValue.vlocity_cmt__PicklistId__c, lstPickValue);
            }
        }       
        
        for(vlocity_cmt__AttributeAssignment__c attAsigment : [SELECT vlocity_cmt__ObjectId__c, vlocity_cmt__AttributeId__c FROM vlocity_cmt__AttributeAssignment__c]){
            setAttAssigmentKey.add(attAsigment.vlocity_cmt__ObjectId__c+attAsigment.vlocity_cmt__AttributeId__c);
        }
        
        List<ProductIO__c> lstPrdIO = [SELECT Id, 
                                    		SAPID__c, 
                                    		Product_Description__c, 
                                    		Product_Family__c, 
                                  			Active__c, 
                                    		Product_Type__c, 
                                    		Product_Sub_Type__c, 
                                    		Specification_Type__c, 
                                    		Orderable__c,
                                       		Object_Type__c,
                                       		Attribute_Category__c,
                                       		Attribute_Assign_Value_1__c,
                                       		Attribute_Assign_Value_2__c,
                                       		Attribute_Assign_Value_3__c,
                                       		Attribute_Assign_Value_4__c,
                                       		Attribute_Assign_Value_5__c,
                                       		Attribute_Assign_Value_6__c,
                                       		Attribute_Code_1__c,
                                       		Attribute_Code_2__c,
                                       		Attribute_Code_3__c,
                                       		Attribute_Code_4__c,
                                       		Attribute_Code_5__c,
                                       		Attribute_Code_6__c,
                                       		PicklistCode1__c,
                                       		Picklist_Code_2__c,
                                       		Picklist_Code_3__c,
                                       		Picklist_Code_4__c,
                                       		Picklist_Code_5__c,
                                       		Picklist_Code_6__c,
                                       		SimCardPrice__c,
											SAP_ID_UF__c,
											UF__c
                                    FROM ProductIO__c
                                    WHERE Process_Completed__c = false
                                    LIMIT 5];
        Set<String> produtoDuplicado = new Set<String>();
        for(ProductIO__c prdIO : lstPrdIO){
            prdIO.Process_Completed__c = true;
            prdIO.Effective_End_Date__c = Date.today();
            
            /*Não adicionar duplicados*/
            if(produtoDuplicado.contains(prdIO.SAP_ID_UF__c)){continue;}
            
            produtoDuplicado.add(prdIO.SAP_ID_UF__c);
            
            if('SimCard'.equals(prdIO.Product_Type__c)){
                PME_SimCard_Info__c	customSettingSimCard = new PME_SimCard_Info__c();
                customSettingSimCard.Name = prdIO.SAP_ID_UF__c;
                customSettingSimCard.Description__c = prdIO.Product_Description__c;
                customSettingSimCard.Price__c = prdIO.SimCardPrice__c;
                customSettingSimCard.SAP_ID__c = prdIO.SAPID__c;
                customSettingSimCard.SAP_ID_UF__c = prdIO.SAP_ID_UF__c;
                customSettingSimCard.UF__c = prdIO.UF__c;
				lstSimCard.add(customSettingSimCard);
            } else {
                Product2 prd = new Product2();
                                            
                prd.ProductCode = prdIO.SAPID__c;
                prd.Name = prdIO.Product_Description__c;
                prd.Description = prdIO.Product_Description__c;
                prd.Family = prdIO.Product_Family__c;
                prd.IsActive = prdIO.Active__c;
                prd.vlocity_cmt__Type__c = prdIO.Product_Type__c;
                prd.vlocity_cmt__SubType__c = prdIO.Product_Sub_Type__c;
                prd.SAPID__c = prdIO.SAPID__c;
                prd.vlocity_cmt__SpecificationType__c = prdIO.Specification_Type__c;
                prd.vlocity_cmt__IsOrderable__c = prdIO.Orderable__c;
                prd.vlocity_cmt__ObjectTypeId__c = mapIdObjClass.get(prdIO.Object_Type__c);
                prd.Manufacturer__c = prdIO.Attribute_Assign_Value_3__c;
                prd.Model__c = prdIO.Attribute_Assign_Value_1__c;
                prd.Color__c = prdIO.Attribute_Assign_Value_2__c;
                prd.vlocity_cmt__Status__c = 'Active';
                                            
                lstPrd.add(prd);
            }
        }
        system.debug('1');
        upsert lstSimCard SAP_ID_UF__c;
        system.debug('2');
        system.debug('Produto json '+ lstPrd.size() + ' ' + JSON.serializePretty(lstPrd));
        upsert lstPrd SAPID__c;
        
        for(Product2 prd : lstPrd){
            mapSAPIdPrdId.put(prd.SAPID__c, prd.Id);
            
            if(pbeProductIds.contains(prd.Id)){continue;} //Não adicionar novamente produtos já contidos no priceebook
            
            PricebookEntry pbe = new PricebookEntry();
            pbe.IsActive = true;
			pbe.Pricebook2Id = standardPB[0].Id;
			pbe.UnitPrice = 0;
			pbe.Product2Id = prd.Id;
			pbe.UseStandardPrice = false;
            pbe.vlocity_cmt__RecurringPrice__c = 0;

                
            lstPbe.add(pbe);
            
            vlocity_cmt__PriceListEntry__c priceListEntry = new vlocity_cmt__PriceListEntry__c();
            priceListEntry.vlocity_cmt__IsActive__c = true;
            priceListEntry.vlocity_cmt__IsBasePrice__c = true;
            priceListEntry.vlocity_cmt__PriceListId__c = priceList.Id;
            priceListEntry.vlocity_cmt__ProductId__c = prd.Id;
            priceListEntry.vlocity_cmt__PricingElementId__c = priceElement.Id;
            priceListEntry.vlocity_cmt__EffectiveFromDate__c = Date.today();
            priceListEntry.Name = prd.Name;
            
            lstPriceListEntry.add(priceListEntry);
        }
        system.debug('3');
        insert lstPbe;
        system.debug('4');
        insert lstPriceListEntry;
        
        for(ProductIO__c prdIO : lstPrdIO){
            if(String.isNotBlank(prdIO.Attribute_Assign_Value_1__c)){
                if(!setAttAssigmentKey.contains(mapSAPIdPrdId.get(prdIO.SAPID__c) + mapAttribute.get(prdIO.Attribute_Code_1__c))){
                    String valuesData = CEC_PME_AttributeAssignmentJOB.obterPickListValues(mapPickListValue.get(mapPicklist.get(prdIO.PicklistCode1__c)));
                    lstAttAssigment.add(CEC_PME_AttributeAssignmentJOB.loadAttAssignment(mapSAPIdPrdId.get(prdIO.SAPID__c),prdIO.Attribute_Assign_Value_1__c,mapAttCategory.get(prdIO.Attribute_Category__c),mapAttribute.get(prdIO.Attribute_Code_1__c),mapPicklist.get(prdIO.PicklistCode1__c),valuesData));
                }
            }
            
            if(String.isNotBlank(prdIO.Attribute_Assign_Value_2__c)){
                if(!setAttAssigmentKey.contains(mapSAPIdPrdId.get(prdIO.SAPID__c) + mapAttribute.get(prdIO.Attribute_Code_2__c))){
                    String valuesData = CEC_PME_AttributeAssignmentJOB.obterPickListValues(mapPickListValue.get(mapPicklist.get(prdIO.Picklist_Code_2__c)));
                    lstAttAssigment.add(CEC_PME_AttributeAssignmentJOB.loadAttAssignment(mapSAPIdPrdId.get(prdIO.SAPID__c),prdIO.Attribute_Assign_Value_2__c,mapAttCategory.get(prdIO.Attribute_Category__c),mapAttribute.get(prdIO.Attribute_Code_2__c),mapPicklist.get(prdIO.Picklist_Code_2__c),valuesData));
                }
            }
            
            if(String.isNotBlank(prdIO.Attribute_Assign_Value_3__c)){
                if(!setAttAssigmentKey.contains(mapSAPIdPrdId.get(prdIO.SAPID__c) + mapAttribute.get(prdIO.Attribute_Code_3__c))){
                	String valuesData = CEC_PME_AttributeAssignmentJOB.obterPickListValues(mapPickListValue.get(mapPicklist.get(prdIO.Picklist_Code_3__c)));
                    lstAttAssigment.add(CEC_PME_AttributeAssignmentJOB.loadAttAssignment(mapSAPIdPrdId.get(prdIO.SAPID__c),prdIO.Attribute_Assign_Value_3__c,mapAttCategory.get(prdIO.Attribute_Category__c),mapAttribute.get(prdIO.Attribute_Code_3__c),mapPicklist.get(prdIO.Picklist_Code_3__c),valuesData));
                }
            }
            
            if(String.isNotBlank(prdIO.Attribute_Assign_Value_4__c)){
                if(!setAttAssigmentKey.contains(mapSAPIdPrdId.get(prdIO.SAPID__c) + mapAttribute.get(prdIO.Attribute_Code_4__c))){
                	String valuesData = CEC_PME_AttributeAssignmentJOB.obterPickListValues(mapPickListValue.get(mapPicklist.get(prdIO.Picklist_Code_4__c)));
                    lstAttAssigment.add(CEC_PME_AttributeAssignmentJOB.loadAttAssignment(mapSAPIdPrdId.get(prdIO.SAPID__c),prdIO.Attribute_Assign_Value_4__c,mapAttCategory.get(prdIO.Attribute_Category__c),mapAttribute.get(prdIO.Attribute_Code_4__c),mapPicklist.get(prdIO.Picklist_Code_4__c),valuesData));
                }
            }
            
            if(String.isNotBlank(prdIO.Attribute_Assign_Value_5__c)){
                if(!setAttAssigmentKey.contains(mapSAPIdPrdId.get(prdIO.SAPID__c) + mapAttribute.get(prdIO.Attribute_Code_5__c))){
			    	String valuesData = CEC_PME_AttributeAssignmentJOB.obterPickListValues(mapPickListValue.get(mapPicklist.get(prdIO.Picklist_Code_5__c)));
                    lstAttAssigment.add(CEC_PME_AttributeAssignmentJOB.loadAttAssignment(mapSAPIdPrdId.get(prdIO.SAPID__c),prdIO.Attribute_Assign_Value_5__c,mapAttCategory.get(prdIO.Attribute_Category__c),mapAttribute.get(prdIO.Attribute_Code_5__c),mapPicklist.get(prdIO.Picklist_Code_5__c),valuesData));
            	}
            }
            
            if(String.isNotBlank(prdIO.Attribute_Assign_Value_6__c)){
                if(!setAttAssigmentKey.contains(mapSAPIdPrdId.get(prdIO.SAPID__c) + mapAttribute.get(prdIO.Attribute_Code_6__c))){
                	String valuesData = CEC_PME_AttributeAssignmentJOB.obterPickListValues(mapPickListValue.get(mapPicklist.get(prdIO.Picklist_Code_6__c)));
                    lstAttAssigment.add(CEC_PME_AttributeAssignmentJOB.loadAttAssignment(mapSAPIdPrdId.get(prdIO.SAPID__c),prdIO.Attribute_Assign_Value_6__c,mapAttCategory.get(prdIO.Attribute_Category__c),mapAttribute.get(prdIO.Attribute_Code_6__c),mapPicklist.get(prdIO.Picklist_Code_6__c),valuesData));
                }
            }
		}
        system.debug('4');
        System.Debug('Total Geral: ' + lstAttAssigment.size());
        insert lstAttAssigment;
        system.debug('5');
        update lstPrdIO;
        inativarProdutos(priceList.Id);
	}
    
    /*
    * Autor: Marcos Aurélio - Deloitte
    * Descrição: 	[CEC/ID: CEC FASE 1/ XXXXX]
					[Time: SQUAD PME - Sprint YYYYY]
					[Método que isolado que prepara os dados para inserção no vlocity_cmt__AttributeAssignment__c
					evitando assim redundância de código.]
    */
    public static vlocity_cmt__AttributeAssignment__c loadAttAssignment(String sapId, String value, String category, String attCode, String pickCode, String valueData){
        vlocity_cmt__AttributeAssignment__c attAss = new vlocity_cmt__AttributeAssignment__c();
        attAss.vlocity_cmt__ObjectId__c = sapId;
        attAss.vlocity_cmt__ObjectType__c = 'Product2';
        attAss.vlocity_cmt__Value__c = value;
        attAss.vlocity_cmt__AttributeCategoryId__c = category;
        attAss.vlocity_cmt__AttributeId__c = attCode;
        attAss.vlocity_cmt__PicklistId__c = pickCode;
        attAss.vlocity_cmt__ValidValuesData__c = valueData;
        
    	return attAss;
    }
    
    /*
    * Autor: Marcos Aurélio - Deloitte
    * Descrição: 	[CEC/ID: CEC FASE 1/ XXXXX]
					[Time: SQUAD PME - Sprint YYYYY]
					[Método que isolado que prepara a lista de valores da picklist.]
    */
    public static String obterPickListValues(List<vlocity_cmt__PicklistValue__c> pickValues){
        String retorno = '';
    
        if(pickValues == Null){return '';}
        if(pickValues.size() == 0){return '';}
        
        for(vlocity_cmt__PicklistValue__c pickVal : pickValues){
        	retorno+= pickVal.JSON__c + ',';
        }

        return '[' + retorno.mid(0,retorno.length() -1) + ']';
    }
    
    /*
    * Autor: Marcos Aurélio - Deloitte
    * Descrição: 	[CEC/ID: CEC FASE 1/ XXXXX]
					[Time: SQUAD PME - Sprint 12]
					[Devido a productIO só conter os produtos que possuam preços (Considerados ativos)
						é necessário desativar os produtos que foram previamente carregados e não
						estão mais na lista atual.
						Para isso é necessário marcar o campo vlocity_cmt__IsOrderable__c como false
						para que não sejam mais apresentados na busca no carrinho.]
    */
    private static void inativarProdutos(String priceListId){
        List<Product2> prdUpdate = new List<Product2>();
        Set<String> idProduto = new Set<String>();
        Set<String> sapId = new Set<String>();
        for(vlocity_cmt__PriceListEntry__c vple : [SELECT vlocity_cmt__ProductId__c FROM vlocity_cmt__PriceListEntry__c WHERE vlocity_cmt__PriceListId__c =: priceListId]){
            idProduto.add(vple.vlocity_cmt__ProductId__c);
        }
        
        for(ProductIO__c prdIO : [SELECT SAPID__c FROM ProductIO__c]){
            sapId.add(prdIO.SAPID__c);
        }
        
        for(Product2 prd2 : [SELECT Id, SAPID__c, vlocity_cmt__IsOrderable__c FROM Product2 WHERE id =: idProduto and vlocity_cmt__Type__c = 'Aparelhos' and vlocity_cmt__IsOrderable__c = true]){
            if(!sapId.contains(prd2.SAPID__c)){
                Product2 prd = new Product2();
                prd.Id = prd2.Id;
                prd.vlocity_cmt__IsOrderable__c = false;
                prdUpdate.add(prd);
                System.Debug('ID PRODUTO: ' + prd2.Id + ' SAP ID: ' + prd2.SAPID__c);
            }
        }
        
        update prdUpdate;
    }
}