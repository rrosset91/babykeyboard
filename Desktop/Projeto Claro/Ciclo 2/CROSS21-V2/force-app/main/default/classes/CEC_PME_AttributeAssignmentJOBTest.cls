/*
* Autor: Marcos Aurélio - Deloitte
* Data: 28/02/2019
* Descrição: 	[CEC/ID: CEC FASE 1/ XXXXX]
				[Time: SQUAD PME - Sprint 8]
				[Classe de teste criada para testar os métodos implementados das classes CEC_PME_AttributeAssignmentJOB
				e CEC_PME_AttributeAssignmentSCH]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/
@isTest
public class CEC_PME_AttributeAssignmentJOBTest {
	/*
    * Autor: Marcos Aurélio - Deloitte
    * Descrição: 	[CEC/ID: CEC FASE 1/ XXXXX]
					[Time: SQUAD PME - Sprint 8]
					[Pré configuração dos testes, cria os registros necessários para a correta execução dos testes.]
    */
    @testSetup static void setup() {
        Product2 prd = new Product2();
		prd.name = 'Name Product';
		prd.isActive = true;
		insert prd;
        
        PricebookEntry pbe = new PricebookEntry();
		pbe.pricebook2Id = Test.getStandardPricebookId();
		pbe.Product2Id = prd.id;
		pbe.UnitPrice = 1.00;
		pbe.UseStandardPrice = false;
		pbe.isActive = true;
		insert pbe;
        
        vlocity_cmt__PriceList__c vpl = new vlocity_cmt__PriceList__c();
        vpl.Name = 'PME';
        vpl.vlocity_cmt__Code__c = 'Price_List_PME';
        vpl.vlocity_cmt__CurrencyCode__c = 'BRL';
        vpl.vlocity_cmt__LoyaltyCode__c = 'PTS';
        insert vpl;
        
        vlocity_cmt__PricingVariable__c vpv = new vlocity_cmt__PricingVariable__c();
        vpv.Name = 'Recurring Monthly Std Price';
        vpv.vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC';
        insert vpv;
        
        vlocity_cmt__PricingElement__c vpe = new vlocity_cmt__PricingElement__c();
        vpe.Name = 'R$0 Generico';
        vpe.vlocity_cmt__Code__c = 'R$0 Generico';
        vpe.vlocity_cmt__PricingVariableId__c = vpv.Id;
        vpe.vlocity_cmt__PriceListId__c = vpl.Id;
        insert vpe;
        
        vlocity_cmt__ObjectClass__c oc = new vlocity_cmt__ObjectClass__c();
        oc.Name = 'Aparelhos';
        oc.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert oc;
        
        vlocity_cmt__AttributeCategory__c ac = new vlocity_cmt__AttributeCategory__c();
        ac.Name = 'Aparelhos';
        ac.vlocity_cmt__Code__c = '	CT_ATT_Devices';
        ac.vlocity_cmt__DisplaySequence__c = 250.0;
        insert ac;
        
        vlocity_cmt__Attribute__c att = new vlocity_cmt__Attribute__c();
        att.Name = 'COR';
        att.vlocity_cmt__Code__c = 'ATT_Cor';
        att.vlocity_cmt__AttributeCategoryId__c = ac.Id;
        insert att;
        
        vlocity_cmt__Attribute__c att2 = new vlocity_cmt__Attribute__c();
        att2.Name = 'Fabricante';
        att2.vlocity_cmt__Code__c = 'ATT_Fabricante';
        att2.vlocity_cmt__AttributeCategoryId__c = ac.Id;
        insert att2;
        
        vlocity_cmt__Attribute__c att3 = new vlocity_cmt__Attribute__c();
        att3.Name = 'Modelo';
        att3.vlocity_cmt__Code__c = 'ATT_Modelo';
        att3.vlocity_cmt__AttributeCategoryId__c = ac.Id;
        insert att3;
        
        vlocity_cmt__Attribute__c att4 = new vlocity_cmt__Attribute__c();
        att4.Name = 'Tecnologia';
        att4.vlocity_cmt__Code__c = 'ATT_Tecnologia';
        att4.vlocity_cmt__AttributeCategoryId__c = ac.Id;
        insert att4;
        
        vlocity_cmt__Attribute__c att5 = new vlocity_cmt__Attribute__c();
        att5.Name = '';
        att5.vlocity_cmt__Code__c = 'Tipo SimCard';
        att5.vlocity_cmt__AttributeCategoryId__c = ac.Id;
        insert att5;
        
        vlocity_cmt__Picklist__c pl = new vlocity_cmt__Picklist__c();
        pl.Name = 'Tipo SimCard';
        pl.vlocity_cmt__Code__c = 'PKL_Tipo_SimCard';
        insert pl;
        
        vlocity_cmt__PicklistValue__c plv = new vlocity_cmt__PicklistValue__c();
        plv.vlocity_cmt__Code__c = 'APAR';
        plv.vlocity_cmt__TextValue__c = 'APAR';
        plv.Name = 'APAR';
        plv.vlocity_cmt__PicklistId__c = pl.Id;
        insert plv;
        
        vlocity_cmt__PicklistValue__c plv2 = new vlocity_cmt__PicklistValue__c();
        plv2.vlocity_cmt__Code__c = 'APAR';
        plv2.vlocity_cmt__TextValue__c = 'APAR';
        plv2.Name = 'APAR';
        plv2.vlocity_cmt__PicklistId__c = pl.Id;
        insert plv2;
        
        ProductIO__c prdIO = new ProductIO__c();
        prdIO.SAPID__c = '16622';
        prdIO.Product_Description__c = 'AP 4G SAMSUNG'; 
        prdIO.Product_Family__c = 'Movel';
        prdIO.Active__c = true;
        prdIO.Product_Type__c = 'Aparelho'; 
        prdIO.Product_Sub_Type__c = 'None';
        prdIO.Specification_Type__c = 'Product';
        prdIO.Orderable__c = true;
        //prdIO.Object_Type__c = 'Aparelhos';
        prdIO.Attribute_Assign_Value_1__c = 'G570M GAL J5 PRIME';
        prdIO.Attribute_Assign_Value_2__c = 'DOURADO';
        prdIO.Attribute_Assign_Value_3__c = 'SAMSUNG';
        prdIO.Attribute_Assign_Value_4__c = '3G';
        prdIO.Attribute_Assign_Value_5__c = 'APAR';
        prdIO.Attribute_Assign_Value_6__c = 'NanoSimcard	';
        prdIO.Attribute_Code_1__c = 'ATT_Modelo';
        prdIO.Attribute_Code_2__c = 'ATT_Cor';
        prdIO.Attribute_Code_3__c = 'ATT_Fabricante';
        prdIO.Attribute_Code_4__c = 'ATT_Tecnologia';
        prdIO.Attribute_Code_5__c = 'ATT_Equipamento';
        prdIO.Attribute_Code_6__c = 'ATT_Tipo_SimCard';
        insert prdIO;
        
        ProductIO__c prdIO2 = new ProductIO__c();
        prdIO2.SAPID__c = '23100';
        prdIO2.Product_Description__c = 'SCBOPP 1NP SP 128KB AAC005 TRIPLE'; 
        prdIO2.Product_Family__c = 'Movel';
        prdIO2.Active__c = true;
        prdIO2.Product_Type__c = 'SimCard'; 
        prdIO2.Product_Sub_Type__c = 'None';
        prdIO2.Specification_Type__c = 'Product';
        prdIO2.Orderable__c = true;
        prdIO2.Attribute_Assign_Value_1__c = '';
        prdIO2.Attribute_Assign_Value_2__c = '';
        prdIO2.Attribute_Assign_Value_3__c = '';
        prdIO2.Attribute_Assign_Value_4__c = '';
        prdIO2.Attribute_Assign_Value_5__c = 'SIMCARD';
        prdIO2.Attribute_Assign_Value_6__c = '';
        prdIO2.Attribute_Code_1__c = 'ATT_Modelo';
        prdIO2.Attribute_Code_2__c = 'ATT_Cor';
        prdIO2.Attribute_Code_3__c = 'ATT_Fabricante';
        prdIO2.Attribute_Code_4__c = 'ATT_Tecnologia';
        prdIO2.Attribute_Code_5__c = 'ATT_Equipamento';
        prdIO2.Attribute_Code_6__c = 'ATT_Tipo_SimCard';
        prdIO2.SimCardPrice__c = 10.0;
		prdIO2.UF__c = 'SP';
        insert prdIO2;
        
        ProductIO__c clonePRD = prdIO2.clone();
        insert clonePRD;
	}
    /*
    * Autor: Marcos Aurélio - Deloitte
    * Descrição: 	[CEC/ID: CEC FASE 1/ XXXXX]
					[Time: SQUAD PME - Sprint 8]
					[Testa o cenário onde os dados da productIO são replicados para os demais objetos.]
    */
    @isTest static void test1() {
        Test.startTest();
        CEC_PME_AttributeAssignmentJOB.productAssignment();
        CEC_PME_AttributeAssignmentJOB.productAssignment();
        Test.stopTest();
        
        Product2 prd = [SELECT Description FROM Product2 Where SAPID__c =: '16622'];
        System.Debug(prd);
        System.assertEquals('AP 4G SAMSUNG', prd.Description);
        
       	PME_SimCard_Info__c CS = PME_SimCard_Info__c.getValues('23100SP');
		System.assertEquals('23100SP', CS.SAP_ID_UF__c);

    }
    /*
    * Autor: Marcos Aurélio - Deloitte
    * Descrição: 	[CEC/ID: CEC FASE 1/ XXXXX]
					[Time: SQUAD PME - Sprint 8]
					[Método cobre os códigos da classe CEC_PME_AttributeAssignmentSCH.]
    */
    static testmethod void testSchedulable() {
		String CRON_EXP = '0 0 0 15 3 ? 2022';
        String jobId = System.schedule('JOB NAME', CRON_EXP, new CEC_PME_AttributeAssignmentSCH());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        System.assertEquals(CRON_EXP, ct.CronExpression);
    }
}