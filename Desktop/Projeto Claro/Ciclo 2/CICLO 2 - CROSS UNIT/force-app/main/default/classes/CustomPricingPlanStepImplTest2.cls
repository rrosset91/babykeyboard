/*
* Autor: [Marcos Aurelio] + [Deloitte]
* Data: [13/02/2019]
* Descrição: [CEC/ID: CEC FASE 1] + [Time: SQUAD PME - Sprint 6]
	[Classe de teste utilizada para cobertura de código da classe CustomPricingPlanStepImpl.
	Seu código foi copiado da classe CustomPricingPlanStepImplTest e adaptado para os cenários de franquias e devices.]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/
@isTest(SeeAllData=false)
public class CustomPricingPlanStepImplTest2 {
    private static String namespace = 'vlocity_cmt__';
    
    // Intitialized in Setup, used throughout
    public static vlocity_cmt__CalculationMatrixVersion__c version;
    public static vlocity_cmt__CalculationMatrix__c parent;
    public static List<vlocity_cmt__CalculationMatrixRow__c> lineItems;
    private static Id oppId;
    private static boolean flag;  //used to upload matrix row data for test1 or test2
    
    /*
    * Autor: [Marcos Aurelio] + [Deloitte]
    * Descrição: [CEC/ID: CEC FASE 1] + [Time: SQUAD PME - Sprint 6]
    * [Método implementa o cenário de preço de franquias. Faz a cobertura de código do fluxo GetMatrixPricePlansPME.]
	*/
    static private testmethod void pricingVASPME(){

        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = false;

        Test.startTest();
        testProductSetup();
        testMatrixSetup();
        
        sObject targetProduct = [SELECT Id, Name FROM Product2 WHERE ProductCode = 'PME_Franquia30GBIndividual_0001'];
        sObject oppSObject = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        List<SObject> oppItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c,vlocity_cmt__OneTimeLoyaltyPrice__c
                FROM OpportunityLineItem WHERE OpportunityId = :oppId];
		
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', oppSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', oppItemList);

        input.put('Procedure Name','PMEVASPricingProcedure');
        input.put('MatrixName','PMEVASPricingMatrix');
        input.put('Root Product Code','PME_Franquia30GBIndividual_0001');

        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPricePlansPME',input,output,options);
        
        for(SObject oppItem : oppItemList){
            if(oppItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                System.assert(oppItem.get('vlocity_cmt__RecurringCharge__c') == 5.00 );
                System.assert(oppItem.get('vlocity_cmt__OneTimeCharge__c') == 5.00 );
                System.assert(oppItem.get('vlocity_cmt__OneTimeLoyaltyPrice__c') == 5.00 );
            }
        }
        Test.stopTest();
    }
    /*
    * Autor: [Marcos Aurelio] + [Deloitte]
    * Descrição: [CEC/ID: CEC FASE 1] + [Time: SQUAD PME - Sprint 6]
    * [Método implementa o cenário de preço de devices. Faz a cobertura de código do fluxo GetMatrixPriceDevicePME.]
	*/
    static private testmethod void pricingDevicesPME(){

        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = false;

        Test.startTest();
        testProductSetup2();
        testMatrixSetup2();
        
        sObject targetProduct = [SELECT Id, Name FROM Product2 WHERE ProductCode = '16067'];
        sObject oppSObject = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        List<SObject> oppItemList = [SELECT Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c, vlocity_cmt__OneTimeLoyaltyPrice__c
                FROM OpportunityLineItem WHERE OpportunityId = :oppId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', oppSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', oppItemList);

        input.put('Procedure Name','PMEDevicePricingProcedure');
        input.put('MatrixName','Device Pricing - PME All');
        input.put('Device_Code', '16067');
        input.put('Payment_Method', 'BasePrice24x');
        input.put('Price_Type', '100 PTS');
        input.put('User_Type', 'ALL');
        input.put('Plan_Code', '16067');
        input.put('TradeIn', 'No');

        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
		testing.invokeMethod('GetMatrixPriceDevicePME',input,output,options);
        
        for(SObject oppItem : oppItemList){
            if(oppItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                System.assert(oppItem.get('vlocity_cmt__RecurringCharge__c') == 5.00 );
                System.assert(oppItem.get('vlocity_cmt__OneTimeCharge__c') == 5.00 );
                System.assert(oppItem.get('vlocity_cmt__OneTimeLoyaltyPrice__c') == 5.00 );
            }
        }
        
        Test.stopTest();
    }

    /*
    * Autor: [Marcos Aurelio] + [Deloitte]
    * Descrição: [CEC/ID: CEC FASE 1] + [Time: SQUAD PME - Sprint 6]
    * [Método configura a matriz de preços utilizado por franquias.]
	*/    
    static private void testMatrixSetup() {
        insert new vlocity_cmt__TriggerSetup__c(Name = 'AllTriggers', vlocity_cmt__IsTriggerOn__c = true);
        parent = new vlocity_cmt__CalculationMatrix__c(Name = 'PMEVASPricingMatrix');
        insert parent;

        version = new vlocity_cmt__CalculationMatrixVersion__c(Name = 'PMEVASPricingMatrix Version', vlocity_cmt__VersionNumber__c = 2,
                vlocity_cmt__IsEnabled__c = false, vlocity_cmt__CalculationMatrixId__c = parent.Id,
                vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-10), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(10),vlocity_cmt__Priority__c = 2);
        insert version;

        //Populating Headers
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"Product Code\",\"listValues\":null,\"label\":null,\"headerType\":\"Input\",\"displayOrder\":1,\"dataType\":\"Text\",\"columnKey\":\"82431e\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"Root Product Code\",\"listValues\":null,\"label\":null,\"headerType\":\"Input\",\"displayOrder\":2,\"dataType\":\"Text\",\"columnKey\":\"ca2703\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"MRC\",\"listValues\":null,"label":null,\"headerType\":\"Output\",\"displayOrder\":5,\"dataType\":\"Number\",\"columnKey\":\"e96928\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"NRC\",\"listValues\":null,\"label\":null,\"headerType\":\"Output\",\"displayOrder\":6,\"dataType\":\"Number\",\"columnKey\":\"fc05d4\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"OTL\",\"listValues\":null,\"label\":null,\"headerType\":\"Output\",\"displayOrder\":7,\"dataType\":\"Number\",\"columnKey\":\"79822d\"}'
        ));
        insert lineItems;

        //Populating Row Data
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();

        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Root Product Code\":\"PME_Franquia30GBIndividual_0001\",\"Product Code\":\"PME_Franquia30GBIndividual_0001\"}',
                vlocity_cmt__OutputData__c = '{\"NRC\":\"125\",\"MRC\":\"300\",\"OTL\":\"250\"}'
        ));
        
        insert lineItems;

        lineItems = [SELECT Name, vlocity_cmt__InputData__c, vlocity_cmt__OutputData__c FROM vlocity_cmt__CalculationMatrixRow__c WHERE Name != 'Header'];
        update new vlocity_cmt__CalculationMatrixVersion__c(Id = version.Id, vlocity_cmt__IsEnabled__c = true);

        //service
        vlocity_cmt__CalculationProcedure__c calcProcedure = new vlocity_cmt__CalculationProcedure__c(Name='PMEVASPricingProcedure');
        insert calcProcedure;

        //Making isEnabled = false due to ERROR="Please add steps before enabling this procedure configuration."
        vlocity_cmt__CalculationProcedureVersion__c procVersion = new vlocity_cmt__CalculationProcedureVersion__c(Name='PMEVASPricingMatrix Version', vlocity_cmt__VersionNumber__c=2, vlocity_cmt__IsEnabled__c=false,
                vlocity_cmt__CalculationProcedureId__c=calcProcedure.Id, vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-5), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(5), vlocity_cmt__Priority__c=2);
        insert procVersion;

        List<vlocity_cmt__CalculationProcedureStep__c> steps = new List<vlocity_cmt__CalculationProcedureStep__c> ();
        vlocity_cmt__CalculationProcedureStep__c step1 = new vlocity_cmt__CalculationProcedureStep__c (Name='nome do step', vlocity_cmt__Sequence__c=1,vlocity_cmt__Function__c='Matrix Lookup', vlocity_cmt__CalculationMatrixId__c=parent.Id, vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__Input__c='[{\"columnKey\":\"82431e\",\"dataType\":\"Text\",\"label\":null,\"listValues\":null,\"name\":\"Product Code\"},{\"columnKey\":\"ca2703\",\"dataType\":\"Text\",\"label\":null,\"listValues\":null,\"name\":\"Root Product Code\"}]',
                vlocity_cmt__OutputMappingJSON__c ='{\"OTL\":\"PMEVASPricingMatrix__OTL\",\"MRC\":\"PMEVASPricingMatrix__MRC\",\"NRC\":\"PMEVASPricingMatrix__NRC\"}',
                vlocity_cmt__OutputJSON__c='[{\"columnKey\":\"79822d\",\"dataType\":\"Number\",\"label\":null,\"listValues\":null,\"name\":\"OTL\"},{\"columnKey\":\"e96928\",\"dataType\":\"Number\",\"label\":null,\"listValues\":null,\"name\":\"MRC\"},{\"columnKey\":\"fc05d4\",\"dataType\":\"Number\",\"label\":null,\"listValues\":null,\"name\":\"NRC\"}]');
        
        steps.add(step1);
        
        insert steps;

        List<vlocity_cmt__CalculationProcedureVariable__c> calcProcVariableList = new List<vlocity_cmt__CalculationProcedureVariable__c>{
            new vlocity_cmt__CalculationProcedureVariable__c(name='OTL',vlocity_cmt__alias__c='PMEVASPricingMatrix__OTL',vlocity_cmt__datatype__c='Number',vlocity_cmt__defaultValue__c='0',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
            new vlocity_cmt__CalculationProcedureVariable__c(name='MRC',vlocity_cmt__alias__c='PMEVASPricingMatrix__MRC',vlocity_cmt__datatype__c='Number',vlocity_cmt__defaultValue__c='0',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
            new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='PMEVASPricingMatrix__NRC',vlocity_cmt__datatype__c='Number',vlocity_cmt__defaultValue__c='0',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id)
            };
        insert calcProcVariableList;

        //Creating and enabling CalculationProcedureVersion
        update new vlocity_cmt__CalculationProcedureVersion__c(Id = procVersion.Id, vlocity_cmt__IsEnabled__c = true);
   }
    /*
    * Autor: [Marcos Aurelio] + [Deloitte]
    * Descrição: [CEC/ID: CEC FASE 1] + [Time: SQUAD PME - Sprint 6]
    * [Método configura a matriz de preços utilizado por devices.]
	*/    
    static private void testMatrixSetup2() {
        insert new vlocity_cmt__TriggerSetup__c(Name = 'AllTriggers', vlocity_cmt__IsTriggerOn__c = true);

        parent = new vlocity_cmt__CalculationMatrix__c(Name = 'PMEDevicePricingMatrix');
        insert parent;

        version = new vlocity_cmt__CalculationMatrixVersion__c(Name = 'PMEDevicePricingMatrix Version', vlocity_cmt__VersionNumber__c = 2,
                vlocity_cmt__IsEnabled__c = false, vlocity_cmt__CalculationMatrixId__c = parent.Id,
                vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-10), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(10),vlocity_cmt__Priority__c = 2);
        insert version;

        //Populating Headers
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
                lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"MRC\",\"listValues\":null,\"lineItemId\":\"a0U2C000001qGJrUAM\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":7,\"dataType\":\"Number\",\"columnKey\":\"6028686489\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"TradeIn\",\"listValues\":null,\"lineItemId\":\"a0U2C000001qGJsUAM\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":6,\"dataType\":\"Text\",\"columnKey\":\"6028686488\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"Device_Code\",\"listValues\":null,\"lineItemId\":\"a0U2C000001qGJtUAM\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":1,\"dataType\":\"Text\",\"columnKey\":\"6028686487\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"Payment_Method\",\"listValues\":null,\"lineItemId\":\"a0U2C000001qGJuUAM\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":2,\"dataType\":\"Text\",\"columnKey\":\"6028686486\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"User_Type\",\"listValues\":null,\"lineItemId\":\"a0U2C000001qGJvUAM\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":4,\"dataType\":\"Text\",\"columnKey\":\"6028686485\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"Plan_Code\",\"listValues\":null,\"lineItemId\":\"a0U2C000001qGJwUAM\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":5,\"dataType\":\"Text\",\"columnKey\":\"6028686484\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"NRC\",\"listValues\":null,\"lineItemId\":\"a0U2C000001qGJxUAM\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":8,\"dataType\":\"Number\",\"columnKey\":\"6028686483\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"Price_Type\",\"listValues\":null,\"lineItemId\":\"a0U2C000001qGJyUAM\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":3,\"dataType\":\"Text\",\"columnKey\":\"6028686482\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"OTL\",\"listValues\":null,\"lineItemId\":\"a0U2C000001qGJzUAM\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":9,\"dataType\":\"Number\",\"columnKey\":\"6028686481\"}'
        ));
        insert lineItems;


        //Populating Row Data
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();

        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"TradeIn\":\"No\",\"Plan_Code\":\"16067\",\"User_Type\":\"All\",\"Price_Type\":\"100 PTS\",\"Payment_Method\":\"BasePrice24x\",\"Device_Code\":\"16067\"}',
                vlocity_cmt__OutputData__c = '{\"MRC\":\"48\",\"NRC\":\"0\",\"OTL\":\"0\"}'
        ));
        
        insert lineItems;

        lineItems = [SELECT Name, vlocity_cmt__InputData__c, vlocity_cmt__OutputData__c FROM vlocity_cmt__CalculationMatrixRow__c WHERE Name != 'Header'];
        update new vlocity_cmt__CalculationMatrixVersion__c(Id = version.Id, vlocity_cmt__IsEnabled__c = true);

        //service
        vlocity_cmt__CalculationProcedure__c calcProcedure = new vlocity_cmt__CalculationProcedure__c(Name='PMEDevicePricingProcedure');
        insert calcProcedure;

        //Making isEnabled = false due to ERROR="Please add steps before enabling this procedure configuration."
        vlocity_cmt__CalculationProcedureVersion__c procVersion = new vlocity_cmt__CalculationProcedureVersion__c(Name='PMEDevicePricingMatrix Version', vlocity_cmt__VersionNumber__c=2, vlocity_cmt__IsEnabled__c=false,
                vlocity_cmt__CalculationProcedureId__c=calcProcedure.Id, vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-5), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(5), vlocity_cmt__Priority__c=2);
        insert procVersion;

        List<vlocity_cmt__CalculationProcedureStep__c> steps = new List<vlocity_cmt__CalculationProcedureStep__c> ();
        vlocity_cmt__CalculationProcedureStep__c step1 = new vlocity_cmt__CalculationProcedureStep__c (Name='nome de step', vlocity_cmt__Sequence__c=1,vlocity_cmt__Function__c='Matrix Lookup', vlocity_cmt__CalculationMatrixId__c=parent.Id, vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__Input__c='[{\"name\":\"TradeIn\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"6011396868\"},{\"name\":\"Device_Code\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"6011396867\"},{\"name\":\"Payment_Method\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"6011396866\"},{\"name\":\"User_Type\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"6011396865\"},{\"name\":\"Plan_Code\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"6011396864\"},{\"name\":\"Price_Type\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"6011396862\"}]',
                vlocity_cmt__OutputMappingJSON__c ='{\"MRC\":\"DevicePricing-PMEAll__MRC\",\"NRC\":\"DevicePricing-PMEAll__NRC\",\"OTL\":\"DevicePricing-PMEAll__OTL\"}',
                vlocity_cmt__OutputJSON__c='[{\"name\":\"MRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Number\",\"columnKey\":\"6011396869\"},{\"name\":\"NRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Number\",\"columnKey\":\"6011396863\"},{\"name\":\"OTL\",\"listValues\":null,\"label\":null,\"dataType\":\"Number\",\"columnKey\":\"6011396861\"}]');
        
        steps.add(step1);
        
        insert steps;

        List<vlocity_cmt__CalculationProcedureVariable__c> calcProcVariableList = new List<vlocity_cmt__CalculationProcedureVariable__c>{
            new vlocity_cmt__CalculationProcedureVariable__c(name='OTL',vlocity_cmt__alias__c='DevicePricing-PMEAll__OTL',vlocity_cmt__datatype__c='Number',vlocity_cmt__defaultValue__c='0',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
            new vlocity_cmt__CalculationProcedureVariable__c(name='MRC',vlocity_cmt__alias__c='DevicePricing-PMEAll__MRC',vlocity_cmt__datatype__c='Number',vlocity_cmt__defaultValue__c='0',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
            new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='DevicePricing-PMEAll__NRC',vlocity_cmt__datatype__c='Number',vlocity_cmt__defaultValue__c='0',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id)
            };
        insert calcProcVariableList;

        //Creating and enabling CalculationProcedureVersion
        update new vlocity_cmt__CalculationProcedureVersion__c(Id = procVersion.Id, vlocity_cmt__IsEnabled__c = true);
   }
    
    /*
    * Autor: [Marcos Aurelio] + [Deloitte]
    * Descrição: [CEC/ID: CEC FASE 1] + [Time: SQUAD PME - Sprint 6]
    *[Método configura o cenário de franquia, cria-se todas as dependências de registros utilizado tanto pelo salesforce
		quanto o vlocity.]
	*/        
    	static private void testProductSetup(){

        vlocity_cmt__TriggerSetup__c itemTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
        insert itemTrigger;

        List<SObject> sObjList = new List<sObject>();
        Product2 prod1 = new Product2 (Name='30GB', ProductCode = 'PME_Franquia30GBIndividual_0001');
        sObjList.add(prod1);

        Product2 prod2 = new Product2 (Name='Mobilidade', ProductCode = 'PME_ModuloMobilidade_0001');
        sObjList.add(prod2);
        
        insert sObjList;
        sObjList.clear();

        // Create Product Child Item
        vlocity_cmt__ProductChildItem__c pci1 = new vlocity_cmt__ProductChildItem__c();
        pci1.vlocity_cmt__ParentProductId__c = prod1.Id;
        pci1.vlocity_cmt__ChildProductId__c = prod2.Id;
        pci1.Name = 'Test PCI1';
        pci1.vlocity_cmt__Quantity__c = 1.0;
        pci1.vlocity_cmt__MinQuantity__c = 1.0;
        pci1.vlocity_cmt__MaxQuantity__c = 25.0;
        pci1.vlocity_cmt__IsRootProductChildItem__c = false;
        pci1.vlocity_cmt__IsOverride__c = false;
        pci1.vlocity_cmt__ChildLineNumber__c = '0001';
        pci1.vlocity_cmt__IsVirtualItem__c = false;
        sObjList.add(pci1);

        insert sObjList;
        sObjList.clear();

        //Inserting into standard Pricebook
        Pricebook2 standardBook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        Pricebook2 testPricebook = new Pricebook2(Name = 'TestPricebook8', IsActive = true);
        insert testPricebook;
        
        PricebookEntry pbe11 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = false);
        sObjList.add(pbe11);

        PricebookEntry pbe12 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true);
        sObjList.add(pbe12);
        
        insert sObjList;
        sObjList.clear();

        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = testPricebook.Id, vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'Price_List_PME');
        insert pl1;

        //Inserting into Custom Pricebook
        PricebookEntry pbe21 = new PricebookEntry(Pricebook2Id = standardBook.Id,
        	Product2Id = prod2.Id, UnitPrice = 20, vlocity_cmt__RecurringPrice__c = 10, IsActive = false);
        sObjList.add(pbe21);
        
        PricebookEntry pbe22 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
        	Product2Id = prod2.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe22);

        insert sObjList;
        sObjList.clear();

        // Create Object Type
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];
        vlocity_cmt__ObjectClass__c chargeObjType = new vlocity_cmt__ObjectClass__c(Name = 'Charge', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);
        vlocity_cmt__ObjectClass__c discObjType = new vlocity_cmt__ObjectClass__c(Name = 'Discount', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);

        sObjList.clear();
        sObjList.add(chargeObjType);
        sObjList.add(discObjType);
        insert sObjList;
        sObjList.clear();

        vlocity_cmt__PricingVariable__c oneTimeLoyaltyVar = new vlocity_cmt__PricingVariable__c(Name = 'One Time Loyalty', vlocity_cmt__Code__c = 'OT_LTY',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='One-time',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(oneTimeLoyaltyVar);

        vlocity_cmt__PricingVariable__c oneTimeStdPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'One Time Std Price', vlocity_cmt__Code__c = 'OT_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='One-time',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(oneTimeStdPriceVar);
        
        vlocity_cmt__PricingVariable__c recMonthStdPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'Recurring Monthly Std Price', vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='Recurring',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(recMonthStdPriceVar);
        
        insert sObjList;
        sObjList.clear();

        insert sObjList;

        // Create Pricing Element
        vlocity_cmt__PricingElement__c pElem1 = new vlocity_cmt__PricingElement__c(Name = '10PTS_Mobilidade', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 10.0,
                vlocity_cmt__Code__c = '10PTS_Mobilidade', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = oneTimeLoyaltyVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        
        vlocity_cmt__PricingElement__c pElem2 = new vlocity_cmt__PricingElement__c(Name = ' R3292 IPHONE 7 PLUS 128', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 3292.0,
                vlocity_cmt__Code__c = '16395', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        
        vlocity_cmt__PricingElement__c pElem3 = new vlocity_cmt__PricingElement__c(Name = ' R$0 Generico', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 0.0,
                vlocity_cmt__Code__c = 'R$0 Generico', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = recMonthStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        
        
        sObjList.clear();
        sObjList.add(pElem1);
        sObjList.add(pElem2);
        sObjList.add(pElem3);
        
        insert sObjList;
        sObjList.clear();

        List<vlocity_cmt__PricingElement__c> pricingElement = [SELECT Id, Name FROM vlocity_cmt__PricingElement__c];
        vlocity_cmt__PriceListEntry__c ple1 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod1.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        
        sObjList.add(ple1);

        insert sObjList;
        sObjList.clear();

        //Creating PricingVariableBinding
        vlocity_cmt__PricingVariableBinding__c pvb1 = new vlocity_cmt__PricingVariableBinding__c(Name='One Time Std Price - OpportunityLineItem',vlocity_cmt__DestinationSObjectType__c='OpportunityLineItem',
                vlocity_cmt__DestinationFieldApiName__c = 'OneTimeCharge__c', vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id);
        sObjList.add(pvb1);
        vlocity_cmt__PricingVariableBinding__c pvb2 = new vlocity_cmt__PricingVariableBinding__c(Name='Recurring Monthly Std Price - OpportunityLineItem',vlocity_cmt__DestinationSObjectType__c='OpportunityLineItem',
                vlocity_cmt__DestinationFieldApiName__c = 'RecurringCharge__c', vlocity_cmt__PricingVariableId__c = recMonthStdPriceVar.Id);
        sObjList.add(pvb2);

        vlocity_cmt__PricingVariableBinding__c pvb3 = new vlocity_cmt__PricingVariableBinding__c(Name='Loyalty Std Price - OpportunityLineItem',vlocity_cmt__DestinationSObjectType__c='OpportunityLineItem',
                vlocity_cmt__DestinationFieldApiName__c = 'OneTimeLoyaltyPrice__c', vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id);
        sObjList.add(pvb3);
        
        insert sObjList;
        sObjList.clear();

        Account a = new Account(Name='Account Test');
        insert a;

        vlocity_cmt__InterfaceImplementation__c iit1 = new vlocity_cmt__InterfaceImplementation__c (Name='PricingInterface');
        insert iit1;
        vlocity_cmt__InterfaceImplementationDetail__c iid1 = new vlocity_cmt__InterfaceImplementationDetail__c (Name = 'PricingElementServiceImplementation',
                vlocity_cmt__InterfaceId__c=iit1.Id, vlocity_cmt__IsActive__c=true);
        insert iid1;

        vlocity_cmt__InterfaceImplementation__c intImpl = new vlocity_cmt__InterfaceImplementation__c (Name='TightestMatchInterface');
        insert intImpl;

        vlocity_cmt__InterfaceImplementationDetail__c iit004_001 = new vlocity_cmt__InterfaceImplementationDetail__c
                (Name = 'TightestMatchServiceImplementation', vlocity_cmt__InterfaceId__c=intImpl.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);
        insert iit004_001;

        vlocity_cmt__TriggerSetup__c myTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
        insert myTrigger;
        vlocity_cmt__InterfaceImplementation__c iit = new vlocity_cmt__InterfaceImplementation__c (Name='ContextRuleService');
        insert iit;
        List<vlocity_cmt__InterfaceImplementationDetail__c> iidList = new List<vlocity_cmt__InterfaceImplementationDetail__c> ();
        vlocity_cmt__InterfaceImplementationDetail__c iit_001 = new vlocity_cmt__InterfaceImplementationDetail__c  (Name = 'ContextRuleService', vlocity_cmt__InterfaceId__c=iit.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);

        iidList.add(iit_001);
        insert iidList;

        Opportunity opp = new Opportunity();
        opp.name = 'Name Opp';
        opp.accountid = a.id;
        opp.StageName = 'Qualificação';
        opp.CloseDate = Date.Today();
        opp.Pricebook2Id = testPricebook.id;
        opp.vlocity_cmt__PriceListId__c =pl1.id;
            
        insert opp;
        oppId = opp.Id;
        
        OpportunityLineItem oppLi = new OpportunityLineItem();
        oppLi.OpportunityId = opp.id;
        oppLi.PricebookEntryId = pbe12.id;
        oppLi.Product2Id = prod1.Id;
        oppLi.Quantity = 1;
        oppLi.TotalPrice = 1.00;
        oppLi.vlocity_cmt__AssetReferenceId__c = '123456';
        oppLi.ReliesOnReferenceId__c = '123456';
        oppLi.vlocity_cmt__RecurringCharge__c = 5;
        oppLi.vlocity_cmt__OneTimeCharge__c = 5;
        oppLi.vlocity_cmt__OneTimeLoyaltyPrice__c = 5;
        insert oppLi;

        insert sObjList;
        sObjList.clear();

        // Create Pricing Plan
        vlocity_cmt__PricingPlan__c plan = new vlocity_cmt__PricingPlan__c(Name = 'Default Pricing Plan', vlocity_cmt__Code__c = 'DEFAULT_PRICING_PLAN', vlocity_cmt__IsActive__c = true);
        insert plan;

        vlocity_cmt__PricingPlanStep__c planStep13 = new vlocity_cmt__PricingPlanStep__c(Name = 'Target Path Pricing Demo', vlocity_cmt__ImplementationName__c = 'CustomPricingPlanStepImpl', vlocity_cmt__IsActive__c = true, vlocity_cmt__MethodName__c = 'GetMatrixPricePME', vlocity_cmt__Sequence__c = 103.0, vlocity_cmt__PricingPlanId__c = plan.Id);
        sObjList.add(planStep13);
        insert sObjList;
        sObjList.clear();
    }
    /*
    * Autor: [Marcos Aurelio] + [Deloitte]
    * Descrição: [CEC/ID: CEC FASE 1] + [Time: SQUAD PME - Sprint 6]
    *[Método configura o cenário de devices, cria-se todas as dependências de registros utilizado tanto pelo salesforce
		quanto o vlocity.]
	*/            
    //Initializing Product Details
    static private void testProductSetup2(){
		
        vlocity_cmt__TriggerSetup__c itemTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
        insert itemTrigger;
		
        List<SObject> sObjList = new List<sObject>();
        Product2 prod1 = new Product2 (Name='Nome Produto 1', ProductCode = '16067');
        sObjList.add(prod1);
		
        Product2 prod2 = new Product2 (Name='Nome Produto 2', ProductCode = '16068');
        sObjList.add(prod2);
		        
        insert sObjList;
        sObjList.clear();

        // Create Product Child Item
        vlocity_cmt__ProductChildItem__c pci1 = new vlocity_cmt__ProductChildItem__c();
        pci1.vlocity_cmt__ParentProductId__c = prod1.Id;
        pci1.vlocity_cmt__ChildProductId__c = prod2.Id;
        pci1.Name = 'Test PCI2';
        pci1.vlocity_cmt__Quantity__c = 1.0;
        pci1.vlocity_cmt__MinQuantity__c = 1.0;
        pci1.vlocity_cmt__MaxQuantity__c = 25.0;
        pci1.vlocity_cmt__IsRootProductChildItem__c = false;
        pci1.vlocity_cmt__IsOverride__c = false;
        pci1.vlocity_cmt__ChildLineNumber__c = '0001';
        pci1.vlocity_cmt__IsVirtualItem__c = false;
        sObjList.add(pci1);

        insert sObjList;
        sObjList.clear();

        //Inserting into standard Pricebook
        Pricebook2 standardBook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        Pricebook2 testPricebook = new Pricebook2(Name = 'TestPricebook8', IsActive = true);
        insert testPricebook;
        
        PricebookEntry pbe11 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = false);
        sObjList.add(pbe11);

        PricebookEntry pbe12 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true);
        sObjList.add(pbe12);
        
        insert sObjList;
        sObjList.clear();

        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = testPricebook.Id, vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'Price_List_PME');
        insert pl1;

        //Inserting into Custom Pricebook
        PricebookEntry pbe21 = new PricebookEntry(Pricebook2Id = standardBook.Id,
        	Product2Id = prod2.Id, UnitPrice = 20, vlocity_cmt__RecurringPrice__c = 10, IsActive = false);
        sObjList.add(pbe21);
        
        PricebookEntry pbe22 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
        	Product2Id = prod2.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe22);

        insert sObjList;
        sObjList.clear();

        // Create Object Type
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];
        vlocity_cmt__ObjectClass__c chargeObjType = new vlocity_cmt__ObjectClass__c(Name = 'Charge', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);
        vlocity_cmt__ObjectClass__c discObjType = new vlocity_cmt__ObjectClass__c(Name = 'Discount', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);

        sObjList.clear();
        sObjList.add(chargeObjType);
        sObjList.add(discObjType);
        insert sObjList;
        sObjList.clear();

        vlocity_cmt__PricingVariable__c oneTimeLoyaltyVar = new vlocity_cmt__PricingVariable__c(Name = 'One Time Loyalty', vlocity_cmt__Code__c = 'OT_LTY',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='One-time',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(oneTimeLoyaltyVar);

        vlocity_cmt__PricingVariable__c oneTimeStdPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'One Time Std Price', vlocity_cmt__Code__c = 'OT_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='One-time',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(oneTimeStdPriceVar);
        
        vlocity_cmt__PricingVariable__c recMonthStdPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'Recurring Monthly Std Price', vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='Recurring',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(recMonthStdPriceVar);
        
        insert sObjList;
        sObjList.clear();

        // Create Pricing Element
        vlocity_cmt__PricingElement__c pElem1 = new vlocity_cmt__PricingElement__c(Name = '10PTS_Mobilidade', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 10.0,
                vlocity_cmt__Code__c = '10PTS_Mobilidade', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = oneTimeLoyaltyVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        
        vlocity_cmt__PricingElement__c pElem2 = new vlocity_cmt__PricingElement__c(Name = ' R3292 IPHONE 7 PLUS 128', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 3292.0,
                vlocity_cmt__Code__c = '16395', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        
        vlocity_cmt__PricingElement__c pElem3 = new vlocity_cmt__PricingElement__c(Name = ' R$0 Generico', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 0.0,
                vlocity_cmt__Code__c = 'R$0 Generico', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = recMonthStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        
        
        sObjList.clear();
        sObjList.add(pElem1);
        sObjList.add(pElem2);
        sObjList.add(pElem3);
        
        insert sObjList;
        sObjList.clear();

        List<vlocity_cmt__PricingElement__c> pricingElement = [SELECT Id, Name FROM vlocity_cmt__PricingElement__c];
        vlocity_cmt__PriceListEntry__c ple1 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod1.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        
        sObjList.add(ple1);


        insert sObjList;
        sObjList.clear();

        //Creating PricingVariableBinding
        vlocity_cmt__PricingVariableBinding__c pvb1 = new vlocity_cmt__PricingVariableBinding__c(Name='One Time Std Price - OpportunityLineItem',vlocity_cmt__DestinationSObjectType__c='OpportunityLineItem',
                vlocity_cmt__DestinationFieldApiName__c = 'OneTimeCharge__c', vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id);
        sObjList.add(pvb1);
        vlocity_cmt__PricingVariableBinding__c pvb2 = new vlocity_cmt__PricingVariableBinding__c(Name='Recurring Monthly Std Price - OpportunityLineItem',vlocity_cmt__DestinationSObjectType__c='OpportunityLineItem',
                vlocity_cmt__DestinationFieldApiName__c = 'RecurringCharge__c', vlocity_cmt__PricingVariableId__c = recMonthStdPriceVar.Id);
        sObjList.add(pvb2);

        vlocity_cmt__PricingVariableBinding__c pvb3 = new vlocity_cmt__PricingVariableBinding__c(Name='Loyalty Std Price - OpportunityLineItem',vlocity_cmt__DestinationSObjectType__c='OpportunityLineItem',
                vlocity_cmt__DestinationFieldApiName__c = 'OneTimeLoyaltyPrice__c', vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id);
        sObjList.add(pvb3);
        
        insert sObjList;
  
		sObjList.clear();

        Account a = new Account(Name='Account Test');
        insert a;

        vlocity_cmt__InterfaceImplementation__c iit1 = new vlocity_cmt__InterfaceImplementation__c (Name='PricingInterface');
        insert iit1;
        vlocity_cmt__InterfaceImplementationDetail__c iid1 = new vlocity_cmt__InterfaceImplementationDetail__c (Name = 'PricingElementServiceImplementation',
                vlocity_cmt__InterfaceId__c=iit1.Id, vlocity_cmt__IsActive__c=true);
        insert iid1;

        vlocity_cmt__InterfaceImplementation__c intImpl = new vlocity_cmt__InterfaceImplementation__c (Name='TightestMatchInterface');
        insert intImpl;

        vlocity_cmt__InterfaceImplementationDetail__c iit004_001 = new vlocity_cmt__InterfaceImplementationDetail__c
                (Name = 'TightestMatchServiceImplementation', vlocity_cmt__InterfaceId__c=intImpl.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);
        insert iit004_001;
		
        vlocity_cmt__TriggerSetup__c myTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
        insert myTrigger;
		
        vlocity_cmt__InterfaceImplementation__c iit = new vlocity_cmt__InterfaceImplementation__c (Name='ContextRuleService');
        insert iit;
        List<vlocity_cmt__InterfaceImplementationDetail__c> iidList = new List<vlocity_cmt__InterfaceImplementationDetail__c> ();
        vlocity_cmt__InterfaceImplementationDetail__c iit_001 = new vlocity_cmt__InterfaceImplementationDetail__c  (Name = 'ContextRuleService', vlocity_cmt__InterfaceId__c=iit.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);

        iidList.add(iit_001);
        insert iidList;

        Opportunity opp = new Opportunity();
        opp.name = 'Name Opp';
        opp.accountid = a.id;
        opp.StageName = 'Qualificação';
        opp.CloseDate = Date.Today();
        opp.Pricebook2Id = testPricebook.id;
        opp.vlocity_cmt__PriceListId__c =pl1.id;
        
        insert opp;
        oppId = opp.Id;

        OpportunityLineItem oppLi = new OpportunityLineItem();
        oppLi.OpportunityId = opp.id;
        oppLi.PricebookEntryId = pbe12.id;
        oppLi.Product2Id = prod1.Id;
        oppLi.Quantity = 1;
        oppLi.TotalPrice = 1.00;
        oppLi.vlocity_cmt__RecurringCharge__c = 5;
        oppLi.vlocity_cmt__OneTimeCharge__c = 5;
        oppLi.vlocity_cmt__OneTimeLoyaltyPrice__c = 5;
        insert oppLi;

        insert sObjList;
        sObjList.clear();

        // Create Pricing Plan
        vlocity_cmt__PricingPlan__c plan = new vlocity_cmt__PricingPlan__c(Name = 'Default Pricing Plan 2', vlocity_cmt__Code__c = 'DEFAULT_PRICING_PLAN 2', vlocity_cmt__IsActive__c = true);
        insert plan;

        vlocity_cmt__PricingPlanStep__c planStep13 = new vlocity_cmt__PricingPlanStep__c(Name = 'Target Path Pricing Demo', vlocity_cmt__ImplementationName__c = 'CustomPricingPlanStepImpl', vlocity_cmt__IsActive__c = true, vlocity_cmt__MethodName__c = 'GetMatrixPricePME', vlocity_cmt__Sequence__c = 103.0, vlocity_cmt__PricingPlanId__c = plan.Id);
        sObjList.add(planStep13);
        insert sObjList;
        sObjList.clear();
    }
}