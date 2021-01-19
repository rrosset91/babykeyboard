/*
* Autor: Henrique Almeida
* Data: 29-mar-2018
* Descrição: Classe responsável por testar a CEC_CustomPrincingPlan
*/
@isTest
public class CEC_CustomPricingPlanStepTest {

    @testSetup
    public static void testSetup() {
        Account varAccount = CEC_SobjectFactory.getAccount();
        insert varAccount;
        
        insert new List<MetodoPagamento__c> {
            new MetodoPagamento__c(Name = 'Boleto', Preco__c = 10, Sub_Type__c = 'Pós-Plano', Forma_de_Pagamento__c = 'Boleto'),
            new MetodoPagamento__c(Name = 'Débito automático', Preco__c = 10, Sub_Type__c = 'Pós-Plano', Forma_de_Pagamento__c = 'Débito automático')
        };
        Id pricebookId = Test.getStandardPricebookId();
        
        vlocity_cmt__PriceList__c vlocityPriceList = new vlocity_cmt__PriceList__c();
        vlocityPriceList.Name = 'Comercial Residencial';
        vlocityPriceList.vlocity_cmt__Code__c = 'Comercial_residencial';
        insert vlocityPriceList; 
        
        Pricebook2 varPrice = new Pricebook2();
        varPrice.Name = 'Teste Pricebook';
        insert varPrice;
            
        Order varOrder = CEC_SobjectFactory.getOrder(varAccount);
        varOrder.vlocity_cmt__PriceListId__c = vlocityPriceList.Id;
        varOrder.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('OrderTemplate').getRecordTypeId();
        varOrder.Pricebook2Id = varPrice.Id;
        varOrder.AnaliseCredito__c = 'APROVADO';
        varOrder.Unidade__c = 'Residencial';
        varOrder.Internet_Grupo__c = 'GN';
        varOrder.Fone_Grupo__c = 'G1';
        varOrder.Cart_State__c = 'INDIVIDUAL';
        varOrder.Forma_de_Pagamento__c = 'Boleto';
        varOrder.TV_Grupo__c = 'GN';
        varOrder.Movel_Grupo__c = 'GN';
        varOrder.City__c = 'SAO PAULO';
        varOrder.Forma_de_Pagamento__c = 'Débito Automático';
        varOrder.TipoFatura__c = 'Email';
        varOrder.TechViabilityFibra__c = true;
        varOrder.TechViabilityHFC__c = true;
        insert varOrder;

        List<Product2> lstProduct2ToInsert = new List<Product2>();
        Product2 varProduct = CEC_SobjectFactory.getProduct();
        varProduct.vlocity_cmt__SubType__c = 'Pós-Plano';
        varProduct.vlocity_cmt__Type__c = 'Plano';
        varProduct.Family = 'Internet Fixa';
        varProduct.TemplateOrderId__c = varOrder.Id;
        varProduct.Technical_Description__c = '{\r\n  \"HDTV\": {\r\n      \"Technology\": \"4K\"\r\n    },\r\n \"Channels\": {\r\n      \"HD\": \"96\",\r\n      \"Digital\": \"174\"\r\n    }\r\n}';
        varProduct.vlocity_cmt__EffectiveDate__c = date.newInstance(2019, 5, 13);
        varProduct.vlocity_cmt__AttributeDefaultValues__c = '{"ATTR_Indica_Rest":true,"ATT_COM_Franquia":null}';
        lstProduct2ToInsert.add(varProduct);        
              
        Product2 varProduct2 = CEC_SobjectFactory.getProduct();
        varProduct2.vlocity_cmt__SubType__c = 'None';
        varProduct2.ProductCode = '3213213';
        varProduct2.vlocity_cmt__Type__c = 'Plano';
        varProduct2.Family = 'TV';
        varProduct2.TemplateOrderId__c = varOrder.Id;
        varProduct2.Technical_Description__c = '{\r\n  \"HDTV\": {\r\n      \"Technology\": \"4K\"\r\n    },\r\n \"Channels\": {\r\n      \"HD\": \"96\",\r\n      \"Digital\": \"174\"\r\n    }\r\n}';
        varProduct2.vlocity_cmt__EffectiveDate__c = date.newInstance(2019, 5, 13);
        lstProduct2ToInsert.add(varProduct2);

        Product2 varProduct3 = CEC_SobjectFactory.getProduct();
        varProduct3.ProductCode = '998765555';
        varProduct3.vlocity_cmt__SubType__c = 'None';
        varProduct3.vlocity_cmt__Type__c = 'Ponto Opcional';
        varProduct3.Family = 'TV';
        varProduct3.TemplateOrderId__c = varOrder.Id;
        varProduct3.Technical_Description__c = '{\r\n  \"HDTV\": {\r\n      \"Technology\": \"4K\"\r\n    },\r\n \"Channels\": {\r\n      \"HD\": \"96\",\r\n      \"Digital\": \"174\"\r\n    }\r\n}';
        varProduct3.vlocity_cmt__EffectiveDate__c = date.newInstance(2019, 5, 13);
        lstProduct2ToInsert.add(varProduct3);

        Product2 varProduct4 = CEC_SobjectFactory.getProduct();
        varProduct4.ProductCode = '99882271';
        varProduct4.vlocity_cmt__SubType__c = 'None';
        varProduct4.vlocity_cmt__Type__c = 'Dependente';
        varProduct4.Family = 'Movel';
        varProduct4.TemplateOrderId__c = varOrder.Id;
        varProduct4.Technical_Description__c = '{\r\n  \"HDTV\": {\r\n      \"Technology\": \"4K\"\r\n    },\r\n \"Channels\": {\r\n      \"HD\": \"96\",\r\n      \"Digital\": \"174\"\r\n    }\r\n}';
        varProduct4.vlocity_cmt__EffectiveDate__c = date.newInstance(2019, 5, 15);
        lstProduct2ToInsert.add(varProduct4);

        Product2 varProduct5 = CEC_SobjectFactory.getProduct();
        varProduct5.ProductCode = '9989990923';
        varProduct5.vlocity_cmt__SubType__c = 'None';
        varProduct5.vlocity_cmt__Type__c = 'Serviço';
        varProduct5.Family = 'TV';
        varProduct5.TemplateOrderId__c = varOrder.Id;
        varProduct5.Technical_Description__c = '{\r\n  \"HDTV\": {\r\n      \"Technology\": \"4K\"\r\n    },\r\n \"Channels\": {\r\n      \"HD\": \"96\",\r\n      \"Digital\": \"174\"\r\n    }\r\n}';
        varProduct5.vlocity_cmt__EffectiveDate__c = date.newInstance(2019, 5, 13);
        lstProduct2ToInsert.add(varProduct5);

        Product2 varProduct6 = CEC_SobjectFactory.getProduct();
        varProduct6.ProductCode = '99892313131';
        varProduct6.vlocity_cmt__SubType__c = 'Avulso';
        varProduct6.vlocity_cmt__Type__c = 'A la carte';
        varProduct6.Family = 'TV';
        varProduct6.TemplateOrderId__c = varOrder.Id;
        varProduct6.Technical_Description__c = '{\r\n  \"HDTV\": {\r\n      \"Technology\": \"4K\"\r\n    },\r\n \"Channels\": {\r\n      \"HD\": \"96\",\r\n      \"Digital\": \"174\"\r\n    }\r\n}';
        varProduct6.vlocity_cmt__EffectiveDate__c = date.newInstance(2019, 5, 13);
        lstProduct2ToInsert.add(varProduct6);
        
        Product2 varProduct7 = CEC_SobjectFactory.getProduct();
        varProduct7.ProductCode = '6666454';
        varProduct7.IsActive = true;
        varProduct7.vlocity_cmt__SubType__c = 'Controle';
        varProduct7.vlocity_cmt__Type__c = 'Dependente';
        varProduct7.Family = 'Internet Fixa';
        varProduct7.TemplateOrderId__c = varOrder.Id;
        varProduct7.Technical_Description__c = '{\r\n  \"HDTV\": {\r\n      \"Technology\": \"4K\"\r\n    },\r\n \"Channels\": {\r\n      \"HD\": \"96\",\r\n      \"Digital\": \"174\"\r\n    }\r\n}';
        varProduct7.vlocity_cmt__EffectiveDate__c = date.newInstance(2019, 5, 13);
        varProduct7.vlocity_cmt__AttributeDefaultValues__c = '{"ATTR_Indica_Rest":true,"ATT_COM_Franquia":null}';
        lstProduct2ToInsert.add(varProduct7); 
        
        Product2 decoder = CEC_SobjectFactory.getProduct();
        decoder.Name = 'DECODER';
        decoder.ProductCode = '666666';
        decoder.vlocity_cmt__SubType__c = 'None';
        decoder.vlocity_cmt__Type__c = 'None';
        decoder.vlocity_cmt__EffectiveDate__c = date.newInstance(2019, 5, 13);
        lstProduct2ToInsert.add(decoder);
        insert lstProduct2ToInsert;
        
        vlocity_cmt__ProductChildItem__c childProduct = new vlocity_cmt__ProductChildItem__c();
        childProduct.Name = 'Root PCI';
        childProduct.vlocity_cmt__ChildLineNumber__c = '1';
        childProduct.vlocity_cmt__ParentProductId__c = decoder.Id;
        insert childProduct;
        
        List<PricebookEntry> lstPricebookEntryToInsert = new List<PricebookEntry>();
        PricebookEntry varEntryStd = CEC_SobjectFactory.getStdPricebookEntry(varProduct);
        varEntryStd.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntryStd);
        
        PricebookEntry varEntryStd2 = CEC_SobjectFactory.getStdPricebookEntry(varProduct2);
        varEntryStd2.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntryStd2);
        
        PricebookEntry varEntryStd3 = CEC_SobjectFactory.getStdPricebookEntry(varProduct3);
        varEntryStd3.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntryStd3);

        PricebookEntry varEntryStd4 = CEC_SobjectFactory.getStdPricebookEntry(varProduct4);
        varEntryStd4.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntryStd4);

        PricebookEntry varEntryStd5= CEC_SobjectFactory.getStdPricebookEntry(varProduct5);
        varEntryStd5.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntryStd5);

        PricebookEntry varEntryStd6 = CEC_SobjectFactory.getStdPricebookEntry(varProduct6);
        varEntryStd6.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntryStd6);
        
        PricebookEntry varEntryStd7 = CEC_SobjectFactory.getStdPricebookEntry(varProduct7);
        varEntryStd7.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntryStd7);
        
        PricebookEntry varEntry = CEC_SobjectFactory.getPricebookEntry(varProduct, varPrice);
        varEntry.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntry);
        
        PricebookEntry varEntry2 = CEC_SobjectFactory.getPricebookEntry(varProduct2, varPrice);
        varEntry2.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntry2);
        
        PricebookEntry varEntry3 = CEC_SobjectFactory.getPricebookEntry(varProduct3, varPrice);
        varEntry3.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntry3);

        PricebookEntry varEntry4 = CEC_SobjectFactory.getPricebookEntry(varProduct4, varPrice);
        varEntry4.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntry4);

        PricebookEntry varEntry5 = CEC_SobjectFactory.getPricebookEntry(varProduct5, varPrice);
        varEntry5.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntry5);

        PricebookEntry varEntry6 = CEC_SobjectFactory.getPricebookEntry(varProduct6, varPrice);
        varEntry6.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntry6);
        
        PricebookEntry varEntry7 = CEC_SobjectFactory.getPricebookEntry(varProduct7, varPrice);
        varEntry7.UnitPrice = 1;
        lstPricebookEntryToInsert.add(varEntry7);
        
        insert lstPricebookEntryToInsert;

        List<OrderItem> itemsLst = new List<OrderItem>();
        
        OrderItem varItem = CEC_SobjectFactory.getOrderItem(varOrder, varEntry);
        varItem.vlocity_cmt__Product2Id__c = varItem.Product2Id;
        varItem.vlocity_cmt__AssetReferenceId__c = varItem.Product2Id;
        varItem.Promotion_Log__c = '{"isPromotion":true,"RecordTypeId":"012g0000000A4MjAAK","Pricing_Variable_Code__c":"REC_MNTH_STD_PRC","Pricing_Var_Binding_Field__c":"vlocity_cmt__RecurringCharge__c","Type__c":"Override","Description__c":"Após R$ 249,99","Group__c":"GN","Promotion__c":"R$ 199,99 por 12 meses","Target_Product__c":"'+varItem.Product2Id+'","PricingValue__c":199.99,"Modalidade__c":"INDIVIDUAL","TipoFatura__c":"Email","Forma_de_Pagamento__c":"Débito Automático","Id":"a5Mg00000001ZopEAE","attributes":{"url":"/services/data/v48.0/sobjects/Pricing_Matrix__c/a5Mg00000001ZopEAE","type":"Pricing_Matrix__c"}}';
        varItem.DescricaoPromocao__c = 'Testing Promo';
        varItem.vlocity_cmt__LineNumber__c = '0001';
        varItem.Group__c = 'GN';
        insert varItem;
         
        varItem.ReliesOnReferenceId__c = varItem.Id;
        update varItem;
        
        OrderItem varItem2 = CEC_SobjectFactory.getOrderItem(varOrder, varEntry2);
        varItem2.vlocity_cmt__Product2Id__c = varItem2.Product2Id;
        varItem2.vlocity_cmt__AssetReferenceId__c = varItem2.Product2Id;
        varItem2.Promotion_Log__c = '{"isPromotion":true,"RecordTypeId":"012g0000000A4MjAAK","Pricing_Variable_Code__c":"REC_MNTH_STD_PRC","Pricing_Var_Binding_Field__c":"vlocity_cmt__RecurringCharge__c","Type__c":"Override","Description__c":"Após R$ 249,99","Group__c":"GN","Promotion__c":"R$ 199,99 por 12 meses","Target_Product__c":"'+varItem2.Product2Id+'","PricingValue__c":199.99,"Modalidade__c":"INDIVIDUAL","TipoFatura__c":"Email","Forma_de_Pagamento__c":"Débito Automático","Id":"a5Mg00000001ZopEAE","attributes":{"url":"/services/data/v48.0/sobjects/Pricing_Matrix__c/a5Mg00000001ZopEAE","type":"Pricing_Matrix__c"}}';
        varItem2.DescricaoPromocao__c = 'Testing Promo';
        varItem2.vlocity_cmt__LineNumber__c = '0001';
        varItem2.Group__c = 'GN';
        insert varItem2;
         
        varItem2.ReliesOnReferenceId__c = varItem2.Id;
        update varItem2;
        
        OrderItem varItem3 = CEC_SobjectFactory.getOrderItem(varOrder, varEntry3);
        varItem3.vlocity_cmt__Product2Id__c = varItem3.Product2Id;
        varItem3.vlocity_cmt__AssetReferenceId__c = varItem3.Product2Id;
        varItem3.Promotion_Log__c = '{"isPromotion":true,"RecordTypeId":"012g0000000A4MjAAK","Pricing_Variable_Code__c":"REC_MNTH_STD_PRC","Pricing_Var_Binding_Field__c":"vlocity_cmt__RecurringCharge__c","Type__c":"Override","Description__c":"Após R$ 249,99","Group__c":"GN","Promotion__c":"R$ 199,99 por 12 meses","Target_Product__c":"'+varItem3.Product2Id+'","PricingValue__c":199.99,"Modalidade__c":"INDIVIDUAL","TipoFatura__c":"Email","Forma_de_Pagamento__c":"Débito Automático","Id":"a5Mg00000001ZopEAE","attributes":{"url":"/services/data/v48.0/sobjects/Pricing_Matrix__c/a5Mg00000001ZopEAE","type":"Pricing_Matrix__c"}}';
        varItem3.DescricaoPromocao__c = 'Testing Promo';
        varItem3.vlocity_cmt__LineNumber__c = '0001';
        varItem3.Group__c = 'GN';
        itemsLst.add(varItem3);

        OrderItem varItem4 = CEC_SobjectFactory.getOrderItem(varOrder, varEntry4);
        varItem4.vlocity_cmt__Product2Id__c = varItem4.Product2Id;
        varItem4.vlocity_cmt__AssetReferenceId__c = varItem4.Product2Id;
        varItem4.Promotion_Log__c = '{"isPromotion":true,"RecordTypeId":"012g0000000A4MjAAK","Pricing_Variable_Code__c":"REC_MNTH_STD_PRC","Pricing_Var_Binding_Field__c":"vlocity_cmt__RecurringCharge__c","Type__c":"Override","Description__c":"Após R$ 249,99","Group__c":"GN","Promotion__c":"R$ 199,99 por 12 meses","Target_Product__c":"'+varItem3.Product2Id+'","PricingValue__c":199.99,"Modalidade__c":"INDIVIDUAL","TipoFatura__c":"Email","Forma_de_Pagamento__c":"Débito Automático","Id":"a5Mg00000001ZopEAE","attributes":{"url":"/services/data/v48.0/sobjects/Pricing_Matrix__c/a5Mg00000001ZopEAE","type":"Pricing_Matrix__c"}}';
        varItem4.DescricaoPromocao__c = 'Testing Promo';
        varItem4.vlocity_cmt__LineNumber__c = '0001';
        varItem4.Group__c = 'GN';
        varItem4.TemplateMinQty__c = '1';
        varItem4.TemplateDefaultQty__c = '1';
        varItem4.TemplateMaxQty__c = '1';
        insert varItem4;

        varitem4.ReliesOnReferenceId__c = varitem4.Id;
        update varitem4;
        
        OrderItem varItem5 = CEC_SobjectFactory.getOrderItem(varOrder, varEntry5);
        varItem5.vlocity_cmt__Product2Id__c = varItem5.Product2Id;
        varItem5.vlocity_cmt__AssetReferenceId__c = varItem5.Product2Id;
        varItem5.Promotion_Log__c = '{"isPromotion":true,"RecordTypeId":"012g0000000A4MjAAK","Pricing_Variable_Code__c":"REC_MNTH_STD_PRC","Pricing_Var_Binding_Field__c":"vlocity_cmt__RecurringCharge__c","Type__c":"Override","Description__c":"Após R$ 249,99","Group__c":"GN","Promotion__c":"R$ 199,99 por 12 meses","Target_Product__c":"'+varItem3.Product2Id+'","PricingValue__c":199.99,"Modalidade__c":"INDIVIDUAL","TipoFatura__c":"Email","Forma_de_Pagamento__c":"Débito Automático","Id":"a5Mg00000001ZopEAE","attributes":{"url":"/services/data/v48.0/sobjects/Pricing_Matrix__c/a5Mg00000001ZopEAE","type":"Pricing_Matrix__c"}}';
        varItem5.DescricaoPromocao__c = 'Testing Promo';
        varItem5.vlocity_cmt__LineNumber__c = '0001';
        varItem5.Group__c = 'GN';
        varItem5.TemplateMinQty__c = '1';
        varItem5.TemplateDefaultQty__c = '1';
        varItem5.TemplateMaxQty__c = '1';
        itemsLst.add(varItem5);

        OrderItem varItem6 = CEC_SobjectFactory.getOrderItem(varOrder, varEntry6);
        varItem6.vlocity_cmt__Product2Id__c = varItem6.Product2Id;
        varItem6.vlocity_cmt__AssetReferenceId__c = varItem6.Product2Id;
        varItem6.Promotion_Log__c = '{"isPromotion":true,"RecordTypeId":"012g0000000A4MjAAK","Pricing_Variable_Code__c":"REC_MNTH_STD_PRC","Pricing_Var_Binding_Field__c":"vlocity_cmt__RecurringCharge__c","Type__c":"Override","Description__c":"Após R$ 249,99","Group__c":"GN","Promotion__c":"R$ 199,99 por 12 meses","Target_Product__c":"'+varItem3.Product2Id+'","PricingValue__c":199.99,"Modalidade__c":"INDIVIDUAL","TipoFatura__c":"Email","Forma_de_Pagamento__c":"Débito Automático","Id":"a5Mg00000001ZopEAE","attributes":{"url":"/services/data/v48.0/sobjects/Pricing_Matrix__c/a5Mg00000001ZopEAE","type":"Pricing_Matrix__c"}}';
        varItem6.DescricaoPromocao__c = 'Testing Promo';
        varItem6.vlocity_cmt__LineNumber__c = '0001';
        varItem6.Group__c = 'GN';
        varItem6.TemplateMinQty__c = '1';
        varItem6.TemplateDefaultQty__c = '1';
        varItem6.TemplateMaxQty__c = '1';
        itemsLst.add(varItem6);
        

        OrderItem varItem7 = CEC_SobjectFactory.getOrderItem(varOrder, varEntry7);

        varItem7.vlocity_cmt__Product2Id__c = varItem7.Product2Id;
        varItem7.vlocity_cmt__AssetReferenceId__c = varItem7.Product2Id;
        varItem7.vlocity_cmt__LineNumber__c = '0001';
        varItem7.Group__c = 'GN';
        varItem7.TemplateMinQty__c = '1';
        varItem7.TemplateDefaultQty__c = '1';
        varItem7.TemplateMaxQty__c = '1';
        itemsLst.add(varItem7);

        insert itemsLst;
        
        List<Pricing_Matrix__c> lstPrincingMatrix = new List<Pricing_Matrix__c>();
        Pricing_Matrix__c promotion = new Pricing_Matrix__c();
        promotion.Cart_State__c = varOrder.Cart_State__c;
        promotion.Target_Product__c = varProduct.Id;
        promotion.Produto_Opcional__c = varProduct5.Id;
        promotion.RecordTypeId = Schema.SObjectType.Pricing_Matrix__c.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId();
        promotion.Group__c = '-';
        promotion.Single__c = 35.99;
        promotion.Forma_de_Pagamento__c = 'Débito Automático';
        promotion.Modalidade__c = 'INDIVIDUAL';
        promotion.TipoFatura__c = 'Email';
        promotion.Promotion__c = '30 R$';
        promotion.Double__c = 30.99;
        promotion.Triple__c = 25.90;
        promotion.Combo_Multi__c = 0;
        promotion.Description__c = 'Durante 3 meses';
        promotion.Internet__c = varProduct.Id;
        promotion.Start_Date__c = date.newInstance(2019, 5, 13);
        lstPrincingMatrix.add(promotion);        
        
        Pricing_Matrix__c matrix = new Pricing_Matrix__c();
        matrix.DDD__c = '-';
        matrix.RecordTypeId = Schema.SObjectType.Pricing_Matrix__c.getRecordTypeInfosByDeveloperName().get('Pricing').getRecordTypeId();
        matrix.Duration__c = 0;
        matrix.Group__c = '-';
        matrix.Source_Product__c = varProduct.Id;
        matrix.Modalidade__c = 'INDIVIDUAL';
        matrix.Single__c = 35.99;
        matrix.Promotion__c = '30 R$';
        matrix.Forma_de_Pagamento__c = 'Débito Automático';
        matrix.Double__c = 30.99;
        matrix.Triple__c = 25.90;
        matrix.Combo_Multi__c = 0;
        matrix.Start_Date__c = date.newInstance(2019, 5, 13);
        matrix.Active__c = true;
        lstPrincingMatrix.add(matrix);
        
        Pricing_Matrix__c matrix2 = new Pricing_Matrix__c();
        matrix2.DDD__c = '-';
        matrix2.RecordTypeId = Schema.SObjectType.Pricing_Matrix__c.getRecordTypeInfosByDeveloperName().get('Pricing').getRecordTypeId();
        matrix2.Duration__c = 12;
        matrix2.Group__c = '-';
        matrix2.Source_Product__c = varProduct2.Id;
        matrix2.Single__c = 35.99;
        matrix2.Promotion__c = '30 R$';
        matrix2.Forma_de_Pagamento__c = 'Débito Automático';
        matrix2.Modalidade__c = 'INDIVIDUAL';
        matrix2.Double__c = 30.99;
        matrix2.Triple__c = 25.90;
        matrix2.Combo_Multi__c = 0;
        matrix2.PricingValue__c = 12;
        matrix2.Active__c = true;
        matrix2.Start_Date__c = date.newInstance(2019, 5, 13);
        lstPrincingMatrix.add(matrix2);
        
        Pricing_Matrix__c pol1 = new Pricing_Matrix__c();
        pol1.DDD__c = '-';
        pol1.RecordTypeId = Schema.SObjectType.Pricing_Matrix__c.getRecordTypeInfosByDeveloperName().get('Politica_Commercial').getRecordTypeId();
        pol1.Duration__c = 0;
        pol1.Group__c = '-';
        pol1.Source_Product__c = varProduct.Id;
        pol1.Modalidade__c = 'INDIVIDUAL';
        pol1.Single__c = 35.99;
        pol1.Promotion__c = '30 R$';
        pol1.Forma_de_Pagamento__c = 'Débito Automático';
        pol1.Double__c = 30.99;
        pol1.Triple__c = 25.90;
        pol1.Combo_Multi__c = 0;
        pol1.PricingValue__c = 12;
        pol1.Active__c = true;
        pol1.Start_Date__c = date.newInstance(2019, 5, 13);
        lstPrincingMatrix.add(pol1);
        
        Pricing_Matrix__c pol2 = new Pricing_Matrix__c();
        pol2.DDD__c = '-';
        pol2.RecordTypeId = Schema.SObjectType.Pricing_Matrix__c.getRecordTypeInfosByDeveloperName().get('Politica_Commercial').getRecordTypeId();
        pol2.Duration__c = 12;
        pol2.Group__c = 'G1';
        pol2.Source_Product__c = varProduct.Id;
        pol2.Modalidade__c = 'INDIVIDUAL';
        pol2.Single__c = 35.99;
        pol2.Promotion__c = '30 R$';
        pol2.Forma_de_Pagamento__c = 'Débito Automático';
        pol2.Double__c = 30.99;
        pol2.Triple__c = 25.90;
        pol2.Combo_Multi__c = 0;
        pol2.PricingValue__c = 12;
        pol2.Active__c = true;
        pol2.Start_Date__c = date.newInstance(2019, 5, 13);
        lstPrincingMatrix.add(pol2);
        
        Product2 varOptionalProd = CEC_SobjectFactory.getProduct();
        varOptionalProd.vlocity_cmt__SubType__c = 'Esportes';
        varOptionalProd.ProductCode = '98377123747';
        varOptionalProd.vlocity_cmt__Type__c = 'A la carte';
        varOptionalProd.Family = 'TV';
        varOptionalProd.TemplateOrderId__c = varOrder.Id;        
        insert varOptionalProd; 
        
        Pricing_Matrix__c promotion2 = new Pricing_Matrix__c();
        promotion2.Cart_State__c = varOrder.Cart_State__c;
        promotion2.Source_Product__c = varOptionalProd.Id;
        promotion2.RecordTypeId = Schema.SObjectType.Pricing_Matrix__c.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId();
        promotion2.Group__c = '-';
        promotion2.Single__c = 35.99;
        promotion2.Promotion__c = '30 R$';
        promotion2.Forma_de_Pagamento__c = 'Débito Automático';
        promotion2.Modalidade__c = 'INDIVIDUAL';
        promotion2.TipoFatura__c = 'Email';
        promotion2.Double__c = 30.99;
        promotion2.Triple__c = 25.90;
        promotion2.Combo_Multi__c = 0;
        promotion2.Description__c = 'Durante 3 meses';
        promotion2.Internet__c = varOptionalProd.Id;
        promotion2.Start_Date__c = date.newInstance(2019, 5, 13);
        lstPrincingMatrix.add(promotion2);
        
        Pricing_Matrix__c packagePrice = new Pricing_Matrix__c();
        packagePrice.Cart_State__c = varOrder.Cart_State__c;
        packagePrice.Target_Product__c = varOptionalProd.Id;
        packagePrice.RecordTypeId = Schema.SObjectType.Pricing_Matrix__c.getRecordTypeInfosByDeveloperName().get('Package_Pricing').getRecordTypeId();
        packagePrice.Group__c = 'G1';
        packagePrice.Duration__c = null;
        packagePrice.DDD__c = '';
        packagePrice.PricingValue__c = 35.99;
        packagePrice.Promotion__c = '30 R$';
        packagePrice.Forma_de_Pagamento__c = 'Débito Automático';
        packagePrice.Modalidade__c = 'INDIVIDUAL';
        packagePrice.Description__c = 'Durante 3 meses';
        packagePrice.Internet__c = varOptionalProd.Id;
        packagePrice.Start_Date__c = date.newInstance(2019, 5, 13);        
        lstPrincingMatrix.add(packagePrice);
        insert lstPrincingMatrix;
        
        PricebookEntry varEntryStdOpt = CEC_SobjectFactory.getStdPricebookEntry(varOptionalProd);
        varEntryStdOpt.UnitPrice = 1;
        insert varEntryStdOpt;
        
        PricebookEntry varEntryOpt = CEC_SobjectFactory.getPricebookEntry(varOptionalProd, varPrice);
        varEntryOpt.UnitPrice = 1;
        insert varEntryOpt;   
        
        OrderItem varItemOpt = CEC_SobjectFactory.getOrderItem(varOrder, varEntryOpt);
        varItemOpt.vlocity_cmt__Product2Id__c = varItemOpt.Product2Id;
        varItemOpt.vlocity_cmt__AssetReferenceId__c = varItemOpt.Product2Id;
        varItemOpt.vlocity_cmt__LineNumber__c = '0002';
        varItemOpt.Group__c = 'G1;';
        insert varItemOpt;    
        
        vlocity_cmt__PricingVariable__c priceVariable = new vlocity_cmt__PricingVariable__c();
        priceVariable.vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC_ADJ_ABS';
        insert priceVariable;
        
        vlocity_cmt__VlocityAttachment__c attach = new vlocity_cmt__VlocityAttachment__c();
        attach.vlocity_cmt__UrlLong__c = 'www.teste.com';
        attach.vlocity_cmt__ObjectId__c = varProduct.Id;
        attach.Name = 'Teste Class';
        insert attach;
        
        List<vlocity_cmt__ProductAvailability__c> lstAvailabilities = new List<vlocity_cmt__ProductAvailability__c>();
        
        vlocity_cmt__ProductAvailability__c avaiability1 = new vlocity_cmt__ProductAvailability__c();
        avaiability1.Type__c = 'Available';
        avaiability1.vlocity_cmt__City__c = 'Sao Paulo';
        avaiability1.vlocity_cmt__StartDate__c = date.newInstance(2020, 11, 4);
        avaiability1.vlocity_cmt__Product2Id__c = varProduct.Id;
        lstAvailabilities.add(avaiability1);

        
        vlocity_cmt__ProductAvailability__c avaiability2 = new vlocity_cmt__ProductAvailability__c();
        avaiability2.Type__c = 'Not Available';
        avaiability2.vlocity_cmt__StartDate__c = date.newInstance(2020, 11, 4);
        avaiability2.vlocity_cmt__City__c = 'Sao Paulo';
        lstAvailabilities.add(avaiability2);
        
        vlocity_cmt__ProductAvailability__c avaiability3 = new vlocity_cmt__ProductAvailability__c();
        avaiability3.vlocity_cmt__StartDate__c = date.newInstance(2020, 11, 4);
        avaiability3.Type__c = 'Available';
        avaiability3.vlocity_cmt__City__c = 'Sao Paulo';
        avaiability3.vlocity_cmt__Product2Id__c = varProduct5.Id;
        lstAvailabilities.add(avaiability3);

        vlocity_cmt__ProductAvailability__c avaiability4 = new vlocity_cmt__ProductAvailability__c();
        avaiability4.Type__c = 'Available';
        avaiability4.vlocity_cmt__StartDate__c = date.newInstance(2020, 11, 4);
        avaiability4.vlocity_cmt__City__c = 'Sao Paulo';
        avaiability4.vlocity_cmt__Product2Id__c = varProduct6.Id;
        lstAvailabilities.add(avaiability4);
        
        vlocity_cmt__ProductAvailability__c avaiability5 = new vlocity_cmt__ProductAvailability__c();
        avaiability5.Type__c = 'Available';
        avaiability5.vlocity_cmt__StartDate__c = date.newInstance(2020, 11, 4);
        avaiability5.vlocity_cmt__City__c = 'SAO PAULO';
        avaiability5.vlocity_cmt__Product2Id__c = varProduct7.Id;
        lstAvailabilities.add(avaiability5);

        insert lstAvailabilities;

        Bonus__c bonus = new Bonus__c();
        bonus.Name = 'Teste Bonus';
        bonus.Cidade__c = 'SAO PAULO';
        bonus.Tipo_Bonus__c = 'Dobro';
        bonus.Modalidade__c = 'INDIVIDUAL';
        bonus.Produto__c = varProduct.Id;
        bonus.Start_Date__c = date.newInstance(2019, 5, 13);
        insert bonus;

        vlocity_cmt__ProductRelationship__c relationship = new vlocity_cmt__ProductRelationship__c();
        relationship.vlocity_cmt__RelationshipType__c = 'Not Sell';
        relationship.vlocity_cmt__Product2Id__c = varProduct.Id;
        relationship.vlocity_cmt__MaxQuantity__c = 1;
        relationship.vlocity_cmt__MinQuantity__c = 1;
        relationship.vlocity_cmt__DefaultQuantity__c = 1;
        relationship.Modalidade__c = 'INDIVIDUAL';
        
        insert relationship;
    }

    @isTest
    static void testGetPriceMatrix() 
    {
        map<String, Object> lInputMap = new map<String, Object>(), 
            lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        SObject varOrder = [SELECT Id, Order.TechViabilityHFC__c, Order.TechViabilityFibra__c FROM Order LIMIT 1];
        
        List<OrderItem> orderItemList = [SELECT   Id, PricebookEntryId, Meses_de_Fidelidade__c, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c, Order.TechViabilityHFC__c, Order.TechViabilityFibra__c
                FROM OrderItem WHERE OrderId = :varOrder.Id];
        
        lInputMap.put('cartId', varOrder.id);
        map<Id, Decimal> mapItensFidelity = new map<Id, Decimal>();
        for(OrderItem item : orderItemList)
        {
            mapItensFidelity.put(item.Id, 12);
        }
        
        Test.startTest();
        
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        vlocity_cmt.PricingPlanService.putInPricingContext('ItemsFidelity', mapItensFidelity);
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', varOrder);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        
        Boolean returnValue = controller.invokeMethod('getMatrixPriceComercial', lInputMap, lOutMap, lOptions); 
        system.assertEquals(lOutMap.get('error'), null);
        Test.stopTest();
    }
    
    @isTest
    static void testGetPromotion() {
        map<String, Object> lInputMap = new map<String, Object>(), 
        lOutMap = new map<String, Object>(),
        lOptions = new map<String, Object>();
        
        List<Order> lstOrder = [SELECT Id FROM Order LIMIT 1];
        
        lInputMap.put('cartId', lstOrder[0].id);
        
        Test.startTest();
        
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        
        Boolean returnValue = controller.invokeMethod('getPromotion', lInputMap, lOutMap, lOptions);
        system.debug('lOutMap: '+lOutMap);
        system.assertNotEquals(lOutMap.get('getPromotions'), null);
        Test.stopTest();
    }
    
    @isTest 
    static void testSetOptProducts() 
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        List<Order> lstOrder = [SELECT Id FROM Order LIMIT 1];
        List<OrderItem> orderItemList = [SELECT Id, ReliesOnReferenceId__c FROM OrderItem WHERE OrderId = :lstOrder[0].Id];
        
        lInputMap.put('TemplateId', lstOrder[0].Id);
        lInputMap.put('planName', 'TESTECLASS');
        lInputMap.put('ReliesOnReferenceId', orderItemList[0].ReliesOnReferenceId__c);
        lInputMap.put('ExistingId', lstOrder[0].Id);
        
        Test.startTest();
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        
        controller.invokeMethod('SetOptionalProducts', lInputMap, lOutMap, lOptions); 
        system.assertEquals(8, [SELECT count() FROM OrderItem WHERE OrderId = :lstOrder[0].Id]);
        Test.stopTest();            
    }
     @isTest 
    static void testGetCartState() 
    {
   map<String, Object> lInputMap = new map<String, Object>(), 
            lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        SObject varOrder = [SELECT Id FROM Order LIMIT 1];
        
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c
                FROM OrderItem WHERE OrderId = :varOrder.Id];
        
        lInputMap.put('cartId', varOrder.id);
        
        Test.startTest();
        
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', varOrder);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        
        Boolean returnValue = controller.invokeMethod('GetCartState', lInputMap, lOutMap, lOptions); 
        system.assertEquals(lOutMap.get('error'), null);
        Test.stopTest();            
    }
  @isTest 
    static void testGetOptionalProducts() 
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        String recTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('OrderTemplate').getRecordTypeId();

        List<Order> lstOrder = [SELECT Id, RecordTypeId FROM Order LIMIT 10];
        
        lstOrder[0].RecordTypeId = recTypeId;
        update lstOrder;
        
        List<OrderItem> orderItemList = [SELECT Id, vlocity_cmt__AssetReferenceId__c, ReliesOnReferenceId__c, OrderId, Product2Id FROM OrderItem WHERE OrderId =: lstOrder[0].Id];
        for(OrderItem oi : orderItemList){
            oi.vlocity_cmt__AssetReferenceId__c = oi.Product2Id;
            oi.ReliesOnReferenceId__c = oi.Id;
        }
        update orderItemList;
        
        lInputMap.put('OrderId', lstOrder[0].Id);
        lInputMap.put('TemplateOrderId', lstOrder[0].Id);
        lInputMap.put('Group', 'GN');
        
        Test.startTest();
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        
        controller.invokeMethod('getOptionalProducts', lInputMap, lOutMap, lOptions); 
        system.assertNotEquals(lOutMap.get('TemplateProducts'), null);
        Test.stopTest();            
    }
    @isTest 
    static void testSetMemberFee() 
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        SObject varOrder = [SELECT Id FROM Order LIMIT 1];
        
        List<OrderItem> orderItemList = [SELECT   Id, PricebookEntryId, Meses_de_Fidelidade__c, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c
                FROM OrderItem WHERE OrderId = :varOrder.Id];
        
        map<Id, Decimal> mapItensFidelity = new map<Id, Decimal>();
        for(OrderItem item : orderItemList)
        {
            mapItensFidelity.put(item.Id, item.Meses_de_Fidelidade__c);
        }
        
        
        Test.startTest();
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', varOrder);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('CartState', 'INDIVIDUAL');
        vlocity_cmt.PricingPlanService.putInPricingContext('ItemsFidelity', mapItensFidelity);

        controller.invokeMethod('SetMemberFeePricingPlan', lInputMap, lOutMap, lOptions);
        controller.invokeMethod('setOneTimeChargeToZero', lInputMap, lOutMap, lOptions); 
        system.assertEquals(lOutMap.get('error'), null);
        Test.stopTest();            
    }
     @isTest 
    static void testSetPromotionAdjust() 
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        SObject varOrder = [SELECT Id FROM Order LIMIT 1];
        List<vlocity_cmt__PricingVariable__c> priceVariables = [SELECT id, vlocity_cmt__Code__c FROM vlocity_cmt__PricingVariable__c];
        
        List<OrderItem> orderItemList = [SELECT   Id, PricebookEntryId, Meses_de_Fidelidade__c, Forma_de_Pagamento__c, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c
                FROM OrderItem WHERE OrderId = :varOrder.Id];
        
        map<Id, Decimal> mapItensFidelity = new map<Id, Decimal>();
        for(OrderItem item : orderItemList)
        {
            mapItensFidelity.put(item.Id, item.Meses_de_Fidelidade__c);
        }

        Test.startTest();
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', varOrder);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('CartState', 'INDIVIDUAL');
        vlocity_cmt.PricingPlanService.putInPricingContext('priceVariables', priceVariables);
        vlocity_cmt.PricingPlanService.putInPricingContext('ItemsFidelity', mapItensFidelity);

        controller.invokeMethod('SetPromotionAdjust', lInputMap, lOutMap, lOptions); 
        system.assertEquals(lOutMap.get('error'), null);
        Test.stopTest();            
    }
    @isTest 
    static void testSetPaymentAdjust() 
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        SObject varOrder = [SELECT Id FROM Order LIMIT 1];
        
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, Order.vlocity_cmt__PriceListId__r.Name, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c, Product2.vlocity_cmt__Type__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c, Acrescimo_Desconto__c
                FROM OrderItem WHERE OrderId = :varOrder.Id]; 
        
        map<String, Decimal> mapItemAdjustment = new map<String, Decimal>();
        mapItemAdjustment.put(orderItemList[0].Id, 5);
        
        List<vlocity_cmt__PricingVariable__c> priceVariables = [SELECT id, vlocity_cmt__Code__c FROM vlocity_cmt__PricingVariable__c];
        
        Test.startTest();
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        vlocity_cmt.PricingPlanService.putInPricingContext('priceVariables', priceVariables);
        vlocity_cmt.PricingPlanService.putInPricingContext('adjustments', mapItemAdjustment);
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', varOrder);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('newItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('CartState', 'INDIVIDUAL');
        
        controller.invokeMethod('SetPaymentAdjust', lInputMap, lOutMap, lOptions); 
        system.assertEquals(lOutMap.get('error'), null);
        Test.stopTest();            
    }
    @isTest
    static void testGetProducts() 
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        Order varOrder = [SELECT Id FROM Order LIMIT 1];
        lInputMap.put('city', 'SAO PAULO');
        lInputMap.put('businessUnit', 'Residencial');
        lInputMap.put('isMovel', false);
        lInputMap.put('OrderId', varOrder.Id);
        
        Test.startTest();
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
    CEC_CustomPricingPlanStep.TechnicalDescription techD = new CEC_CustomPricingPlanStep.TechnicalDescription();
        techD.Download = '30 MB';
        techD.Franquia = '100 GB';
        techD.Upload = '15 MB';
        techD.HDTV = new CEC_CustomPricingPlanStep.HDTV();
        techD.Channels = new CEC_CustomPricingPlanStep.Channels();
        techD.HDTV.Technology = 'HD';
        techD.Channels.Digital = '5';
        techD.Channels.HD = '56';
        
        controller.invokeMethod('getProducts', lInputMap, lOutMap, lOptions);
        
        varOrder.AnaliseCredito__c = 'OFERTAR APENAS ACESSO VIRTUA SINGLE';
        update varOrder;
        controller.invokeMethod('getProducts', lInputMap, lOutMap, lOptions);
        system.assertNotEquals(lOutMap.get('productsByFamily'), null);
        Test.stopTest();            
    }
    @isTest



    static void testGetProducts2() 
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        Order varOrder = [SELECT Id FROM Order LIMIT 1];
        lInputMap.put('city', 'SAO PAULO');
        lInputMap.put('businessUnit', 'Residencial');
        lInputMap.put('isMovel', true);
        lInputMap.put('OrderId', varOrder.Id);
        
        Test.startTest();
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
    CEC_CustomPricingPlanStep.TechnicalDescription techD = new CEC_CustomPricingPlanStep.TechnicalDescription();
        techD.Download = '30 MB';
        techD.Franquia = '100 GB';
        techD.Upload = '15 MB';
        techD.HDTV = new CEC_CustomPricingPlanStep.HDTV();
        techD.Channels = new CEC_CustomPricingPlanStep.Channels();
        techD.HDTV.Technology = 'HD';
        techD.Channels.Digital = '5';
        techD.Channels.HD = '56';
        
        controller.invokeMethod('getProducts', lInputMap, lOutMap, lOptions);
        
        varOrder.AnaliseCredito__c = 'OFERTAR APENAS ACESSO VIRTUA SINGLE';
        update varOrder;
        controller.invokeMethod('getProducts', lInputMap, lOutMap, lOptions);
        system.assertNotEquals(lOutMap.get('productsByFamily'), null);
        Test.stopTest();            
    }
    @isTest



    static void testGetCatalogProducts() 
    {
        Boolean hfc = true;
        Boolean fibra = false;
        List<Product2> prodList = [SELECT Id, ProductCode from Product2 WHERE Family = 'Movel' LIMIT 1];
        prodList[0].ProductCode = 'COM_POS_100GB_SUPER_000001';
        update prodList;
        
        Test.startTest();

        List<Product2> newProdList = CEC_CustomPricingPlanStep.getCatalogProducts(hfc, fibra, prodList, true);

        Test.stopTest();            
    }
    @isTest 
    static void testGetBonus() 
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        SObject varOrder = [SELECT Id FROM Order LIMIT 1];
        
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, Order.vlocity_cmt__PriceListId__r.Name, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c, Product2.vlocity_cmt__Type__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c, Acrescimo_Desconto__c
                FROM OrderItem WHERE OrderId = :varOrder.Id]; 
        
        map<String, Decimal> mapItemAdjustment = new map<String, Decimal>();
        mapItemAdjustment.put(orderItemList[0].Id, 5);
        
        List<vlocity_cmt__PricingVariable__c> priceVariables = [SELECT id, vlocity_cmt__Code__c FROM vlocity_cmt__PricingVariable__c];
        
        Test.startTest();
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        vlocity_cmt.PricingPlanService.putInPricingContext('priceVariables', priceVariables);
        vlocity_cmt.PricingPlanService.putInPricingContext('adjustments', mapItemAdjustment);
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', varOrder);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('newItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('CartState', 'INDIVIDUAL');
        
        controller.invokeMethod('getBonus', lInputMap, lOutMap, lOptions);
        Bonus__c bonus = [SELECT id FROM Bonus__c];
        delete bonus;
        controller.invokeMethod('getBonus', lInputMap, lOutMap, lOptions);
        system.assertEquals(lOutMap.get('error'), null);
        Test.stopTest();            
    }
    @isTest
       static void testNotSellProducts() 
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        SObject varOrder = [SELECT Id FROM Order LIMIT 1];
        
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, Order.vlocity_cmt__PriceListId__r.Name, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c, Product2.vlocity_cmt__Type__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c, Acrescimo_Desconto__c
                FROM OrderItem WHERE OrderId = :varOrder.Id]; 
        
        map<String, Decimal> mapItemAdjustment = new map<String, Decimal>();
        mapItemAdjustment.put(orderItemList[0].Id, 5);
        
        List<vlocity_cmt__PricingVariable__c> priceVariables = [SELECT id, vlocity_cmt__Code__c FROM vlocity_cmt__PricingVariable__c];
        
        Test.startTest();
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        vlocity_cmt.PricingPlanService.putInPricingContext('priceVariables', priceVariables);
        vlocity_cmt.PricingPlanService.putInPricingContext('adjustments', mapItemAdjustment);
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', varOrder);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('newItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('CartState', 'INDIVIDUAL');
        
        controller.invokeMethod('notSellProducts', lInputMap, lOutMap, lOptions); 
        system.assertEquals(lOutMap.get('error'), null);
        Test.stopTest();            
    }
    @isTest
    static void testSetFidelity() 
    {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        SObject varOrder = [SELECT Id FROM Order LIMIT 1];
        
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId,Fidelidade__c, Order.vlocity_cmt__PriceListId__r.Name, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                                       vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c, Product2.vlocity_cmt__Type__c,
                                       vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c, Acrescimo_Desconto__c
                                       FROM OrderItem WHERE OrderId = :varOrder.Id]; 
        
        map<String, Decimal> mapItemAdjustment = new map<String, Decimal>();
        mapItemAdjustment.put(orderItemList[0].Id, 5);
        
        List<vlocity_cmt__PricingVariable__c> priceVariables = [SELECT id, vlocity_cmt__Code__c FROM vlocity_cmt__PricingVariable__c];
        
        Test.startTest();
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        vlocity_cmt.PricingPlanService.putInPricingContext('priceVariables', priceVariables);
        vlocity_cmt.PricingPlanService.putInPricingContext('adjustments', mapItemAdjustment);
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', varOrder);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('newItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('CartState', 'INDIVIDUAL');
        
        controller.invokeMethod('SetFidelity', lInputMap, lOutMap, lOptions); 
        system.assertEquals(lOutMap.get('error'), null);
        Test.stopTest();            
    }

    @isTest
    static void testGetDependentEmbeddedProducts() {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        SObject varOrder = [SELECT Id FROM Order LIMIT 1];
        
        Test.startTest();
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        lInputMap.put('templateOrderIds', varOrder.Id);
        lInputMap.put('Group', 'GN');
        lInputMap.put('city', 'SAO PAULO');
        lInputMap.put('cartState', 'INDIVIDUAL');
        controller.invokeMethod('getDependentEmbeddedProducts', lInputMap, lOutMap, lOptions); 
        system.assertEquals(lOutMap.get('error'), null);
        Test.stopTest();            
    }

    @isTest
    static void testSetDiscountPricing() {
        map<String, Object> lInputMap = new map<String, Object>(), lOutMap = new map<String, Object>(),
            lOptions = new map<String, Object>();
        
        SObject varOrder = [SELECT Id FROM Order LIMIT 1];
    
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId,Fidelidade__c, Order.vlocity_cmt__PriceListId__r.Name, PricebookEntry.Product2.Name, 
                                        PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.vlocity_cmt__Type__c, Quantity, Grupo__c,
                                        vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c, Product2.vlocity_cmt__Type__c,
                                        vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c, Acrescimo_Desconto__c
                                        FROM OrderItem WHERE OrderId = :varOrder.Id]; 
        
        List<vlocity_cmt__PricingVariable__c> priceVariables = [SELECT id, vlocity_cmt__Code__c FROM vlocity_cmt__PricingVariable__c];
        
        Test.startTest();
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('priceVariables', priceVariables);
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', varOrder);
        vlocity_cmt.PricingPlanService.putInPricingContext('priceListName', 'Comercial Residencial');
        controller.invokeMethod('setDiscountPricing', lInputMap, lOutMap, lOptions); 
        system.assertEquals(lOutMap.get('error'), null);
        Test.stopTest();            
    }

    @isTest
    static void testTechAvailable() 
    {
        CEC_CustomPricingPlanStep controller = new CEC_CustomPricingPlanStep();
        CEC_CustomPricingPlanStep.parseTechnical('{"HDTV": {"Technology": "HD"},"Channels": {"HD": "78","Digital": "154"}}', false);
    }
    
    @isTest
    static void testAttributes() 
    {
        CEC_CustomPricingPlanStep.Attributes newAttributes = new CEC_CustomPricingPlanStep.Attributes();
        newAttributes.ATT_COM_Franquia = 'test';
        newAttributes.ATTR_Indica_Rest = true;
    }
    
    @isTest
    public static void mainTest() {
        CEC_CustomPricingPlanStep.padLeft(1);
        new CEC_CustomPricingPlanStep().setup(null
                                                         ,null
                                                         ,null
                                                         ,null
                                                         ,null
                                                         ,null
                                                        );
    }
    
    
    
}