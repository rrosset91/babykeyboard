@isTest
public class SOLAR_PME_IntegrationInputOrderTest {
    private final static String jsonObject = '{"attributes":{"type":"Order"},"ReceiverFullName1__c":"Victor Henrique Martim Battaglia","ReceiverFullName2__c":"Victor Henrique Martim Battaglia","ReceiverFullName3__c":"Ricardo Almeida","ReceiverMobile1__c":"19992228273","ReceiverMobile2__c":"19992222873","ReceiverMobile3__c":"19992222837","OrderNumber":"00018968","LD21__c":"Não selecionado","OrderItems":{"totalSize":9,"done":true,"records":[{"attributes":{"type":"OrderItem","url":"/services/data/v50.0/sobjects/OrderItem/8021g000001AfQxAAK"},"OrderId":"8011g0000016ZGcAAM","Id":"8021g000001AfQxAAK","Quantity":1.00,"TradeIn__c":"Não","vlocity_cmt__AssetReferenceId__c":"e2af87b8-4eea-da2c-5cf1-7f75da46b6a4","TotalPrice":0.00,"UnitPrice":0.00,"Product2Id":"01t1g000004SMdUAAW","Product2":{"attributes":{"type":"Product2","url":"/services/data/v50.0/sobjects/Product2/01t1g000004SMdUAAW"},"vlocity_cmt__Type__c":"Plano","vlocity_cmt__SubType__c":"Pós-Pago","ProductCode":"COM_POS_15GB_SUPER_000001","Name":"Claro Pós 15GB Super","vlocity_cmt__ObjectTypeId__c":"a270U000001SOGGQA4","Family":"Movel","Id":"01t1g000004SMdUAAW"}},{"attributes":{"type":"OrderItem","url":"/services/data/v50.0/sobjects/OrderItem/8021g000001AfRSAA0"},"OrderId":"8011g0000016ZGcAAM","Id":"8021g000001AfRSAA0","Quantity":1.00,"TradeIn__c":"Não","vlocity_cmt__AssetReferenceId__c":"03390fe3-ae7d-0d04-4e91-518031c20fbc","ReliesOnReferenceId__c":"e2af87b8-4eea-da2c-5cf1-7f75da46b6a4","TotalPrice":0.00,"UnitPrice":0.00,"Product2Id":"01t1H000006LcrLQAS","Product2":{"attributes":{"type":"Product2","url":"/services/data/v50.0/sobjects/Product2/01t1H000006LcrLQAS"},"vlocity_cmt__Type__c":"Serviço","vlocity_cmt__SubType__c":"Combo SVA","ProductCode":"COM_CLARO_PREMIUM_CLARO_VIDEO_LIVROS_NOTICIAS_APP_000001","Name":"Claro Banca Premium + Video + livros Digitais + Notícias","vlocity_cmt__ObjectTypeId__c":"a270U000001SOG8QAO","Family":"Serviços Adicionais","Id":"01t1H000006LcrLQAS"}},{"attributes":{"type":"OrderItem","url":"/services/data/v50.0/sobjects/OrderItem/8021g000001AfRTAA0"},"OrderId":"8011g0000016ZGcAAM","Id":"8021g000001AfRTAA0","Quantity":1.00,"TradeIn__c":"Não","vlocity_cmt__AssetReferenceId__c":"28e0599b-418e-75f5-982b-900cc4681e66","ReliesOnReferenceId__c":"e2af87b8-4eea-da2c-5cf1-7f75da46b6a4","TotalPrice":0.00,"UnitPrice":0.00,"Product2Id":"01t1g000004SMdSAAW","Product2":{"attributes":{"type":"Product2","url":"/services/data/v50.0/sobjects/Product2/01t1g000004SMdSAAW"},"vlocity_cmt__Type__c":"Dependente","vlocity_cmt__SubType__c":"Controle","ProductCode":"COM_INT_RES_DEP_CONTROL_SUP_3GB_000001","Name":"Claro Controle SUPER 3GB + SVA","vlocity_cmt__ObjectTypeId__c":"a270U000001SOGGQA4","Family":"Movel","Id":"01t1g000004SMdSAAW"}},{"attributes":{"type":"OrderItem","url":"/services/data/v50.0/sobjects/OrderItem/8021g000001AfRUAA0"},"OrderId":"8011g0000016ZGcAAM","Id":"8021g000001AfRUAA0","Quantity":1.00,"TradeIn__c":"Não","vlocity_cmt__AssetReferenceId__c":"cf6fb3e5-b88f-0c93-2a38-05c9ad1b55aa","ReliesOnReferenceId__c":"e2af87b8-4eea-da2c-5cf1-7f75da46b6a4","TotalPrice":0.00,"UnitPrice":0.00,"Product2Id":"01t1g000004SMdTAAW","Product2":{"attributes":{"type":"Product2","url":"/services/data/v50.0/sobjects/Product2/01t1g000004SMdTAAW"},"vlocity_cmt__Type__c":"Dependente","vlocity_cmt__SubType__c":"Controle","ProductCode":"COM_INT_RES_DEP_CONTROL_SUP_4GB_000001","Name":"Claro Controle SUPER 4GB + SVA","vlocity_cmt__ObjectTypeId__c":"a270U000001SOGGQA4","Family":"Movel","Id":"01t1g000004SMdTAAW"}},{"attributes":{"type":"OrderItem","url":"/services/data/v50.0/sobjects/OrderItem/8021g000001AfRCAA0"},"OrderId":"8011g0000016ZGcAAM","Id":"8021g000001AfRCAA0","Quantity":1.00,"TradeIn__c":"Não","vlocity_cmt__AssetReferenceId__c":"b00efe6c-e71d-839c-39c8-9bdc7fb135bf","ReliesOnReferenceId__c":"e2af87b8-4eea-da2c-5cf1-7f75da46b6a4","TotalPrice":0.00,"UnitPrice":0.00,"Product2Id":"01t1g000004SMTrAAO","Product2":{"attributes":{"type":"Product2","url":"/services/data/v50.0/sobjects/Product2/01t1g000004SMTrAAO"},"vlocity_cmt__Type__c":"Dependente","vlocity_cmt__SubType__c":"Controle","ProductCode":"COM_INT_RES_DEP_CONTROL_SUP_5GB_000001","Name":"Claro Controle SUPER 5GB + SVA","vlocity_cmt__ObjectTypeId__c":"a270U000001SOGGQA4","Family":"Movel","Id":"01t1g000004SMTrAAO"}},{"attributes":{"type":"OrderItem","url":"/services/data/v50.0/sobjects/OrderItem/8021g000001AfRDAA0"},"OrderId":"8011g0000016ZGcAAM","Id":"8021g000001AfRDAA0","Quantity":1.00,"TradeIn__c":"Não","vlocity_cmt__AssetReferenceId__c":"f58c26e9-ca69-0f20-2c1e-3dcc3756df02","ReliesOnReferenceId__c":"e2af87b8-4eea-da2c-5cf1-7f75da46b6a4","TotalPrice":0.00,"UnitPrice":0.00,"Product2Id":"01t1H000006LcrgQAC","Product2":{"attributes":{"type":"Product2","url":"/services/data/v50.0/sobjects/Product2/01t1H000006LcrgQAC"},"vlocity_cmt__Type__c":"Dependente","vlocity_cmt__SubType__c":"None","ProductCode":"COM_PLANO_DEP_MOVEL_POS_APP_000001","Name":"Dependente Super com comp. Total","vlocity_cmt__ObjectTypeId__c":"a270U000001SOGGQA4","Family":"Internet Móvel","Id":"01t1H000006LcrgQAC"}},{"attributes":{"type":"OrderItem","url":"/services/data/v50.0/sobjects/OrderItem/8021g000001AfREAA0"},"OrderId":"8011g0000016ZGcAAM","Id":"8021g000001AfREAA0","Quantity":1.00,"TradeIn__c":"Não","vlocity_cmt__AssetReferenceId__c":"97d8e5be-eeb9-d07a-e45e-99500d13c353","ReliesOnReferenceId__c":"e2af87b8-4eea-da2c-5cf1-7f75da46b6a4","TotalPrice":0.00,"UnitPrice":0.00,"Product2Id":"01t1g000004SMdVAAW","Product2":{"attributes":{"type":"Product2","url":"/services/data/v50.0/sobjects/Product2/01t1g000004SMdVAAW"},"vlocity_cmt__Type__c":"None","vlocity_cmt__SubType__c":"None","ProductCode":"COM_SMARTID_000001","Name":"Smart ID","vlocity_cmt__ObjectTypeId__c":"a270U000001SOG8QAO","Id":"01t1g000004SMdVAAW"}},{"attributes":{"type":"OrderItem","url":"/services/data/v50.0/sobjects/OrderItem/8021g000001AfQgAAK"},"OrderId":"8011g0000016ZGcAAM","Id":"8021g000001AfQgAAK","Quantity":1.00,"TradeIn__c":"Não","vlocity_cmt__AssetReferenceId__c":"01aad091-e99c-9767-9d5c-697c590b1e7e","ReliesOnReferenceId__c":"e2af87b8-4eea-da2c-5cf1-7f75da46b6a4","TotalPrice":0.00,"UnitPrice":0.00,"Product2Id":"01t1H000006LcrbQAC","Product2":{"attributes":{"type":"Product2","url":"/services/data/v50.0/sobjects/Product2/01t1H000006LcrbQAC"},"vlocity_cmt__Type__c":"Dependente","vlocity_cmt__SubType__c":"None","ProductCode":"COM_PLANO_DEP_COMP_MOVEL_POS_APP_000001","Name":"Dependente Super Int. compartilhada","vlocity_cmt__ObjectTypeId__c":"a270U000001SOGGQA4","Family":"Movel","Id":"01t1H000006LcrbQAC"}},{"attributes":{"type":"OrderItem","url":"/services/data/v50.0/sobjects/OrderItem/8021g000001AfQhAAK"},"OrderId":"8011g0000016ZGcAAM","Id":"8021g000001AfQhAAK","Quantity":1.00,"TradeIn__c":"Não","vlocity_cmt__AssetReferenceId__c":"5d4a901e-6e7b-da84-b3e1-a23c304e38f4","ReliesOnReferenceId__c":"e2af87b8-4eea-da2c-5cf1-7f75da46b6a4","TotalPrice":0.00,"UnitPrice":0.00,"Product2Id":"01t1H000004XHHmQAO","Product2":{"attributes":{"type":"Product2","url":"/services/data/v50.0/sobjects/Product2/01t1H000004XHHmQAO"},"vlocity_cmt__Type__c":"Serviço","vlocity_cmt__SubType__c":"Passaporte","ProductCode":"COM_PASSAMER_00001","Name":"Passaporte América","vlocity_cmt__ObjectTypeId__c":"a270U000001SOGEQA4","Family":"Serviços Adicionais","Id":"01t1H000004XHHmQAO"}}]},"Account":{"attributes":{"type":"Account","url":"/services/data/v50.0/sobjects/Account/0010U00000ziZcYQAU"},"Id":"0010U00000ziZcYQAU","Name":"Conta Comercial","DocumentNumber__c":"84928690036","NETClient__c":false,"EmbratelClient__c":false,"CEC_ShippingNumber__c":"44","CEC_ShippingNeighborhood__c":"LOTEAMENTO ALPHAVILLE CAMPINAS","ShippingCity":"CAMPINAS","ShippingState":"SP", "OwnerId":"0051H00000B07x2QAB"},"CreatedBy":{"attributes":{"type":"User","url":"/services/data/v50.0/sobjects/User/0051g000003dp5mAAA"},"Id":"0051g000003dp5mAAA","FirstName":"CEC","LastName":"SF_COPADO_USER","ProfileId":"00e1H000001SkRMQA0","Name":"CEC SF_COPADO_USER","Profile":{"attributes":{"type":"Profile","url":"/services/data/v50.0/sobjects/Profile/00e1H000001SkRMQA0"},"Name":"Administrador do sistMQA0"}}}' ;
    private final static String jsonItem = '{"attributes":{"type":"OrderItem"},"Quantity":1.00,"TradeIn__c":"Não","vlocity_cmt__AssetReferenceId__c":"e2af87b8-4eea-da2c-5cf1-7f75da46b6a4","TotalPrice":0.00,"UnitPrice":0.00}';
    private final static String productItem = '{"attributes":{"type":"Product2"},"vlocity_cmt__Type__c":"Plano","vlocity_cmt__SubType__c":"Pós-Pago","ProductCode":"COM_POS_15GB_SUPER_000001","Name":"Claro Pós 15GB Super","Family":"Movel"}';
    private final static String priceItem = '{"attributes":{"type":"PricebookEntry"},"Name":"Claro Pós 15GB Super"}';
    private final static String bookItem = '{"attributes":{"type":"Pricebook2"},"Name":"Standard Price Book","IsArchived":false,"IsStandard":true,"vlocity_cmt__IsDefault__c":true,"vlocity_cmt__IsOpportunityDefault__c":true}';
    private final static String accountItem = '{"Name":"Deloitte","StateSubscription__c":"123","DocumentNumber__c":"97056416000163","NETClient__c":false,"EmbratelClient__c":false,"NumberOfEmployeesList__c":"Até 10","CompanyClass__c":"Empresa de Pequeno Porte","CommercialSegment__c":"TOP PME","ShippingPostalCode":"13098310","ShippingStreet":"JATAI","ShippingCity":"CAMPINAS","ShippingState":"SP","CEC_ShippingNeighborhood__c":"LOTEAMENTO ALPHAVILLE CAMPINAS","CEC_ShippingNumber__c":"44","CNAE__c":"456","DueDay__c":"28","OwnerId":"0051H00000B0BFJQA3","BillingPostalCode":"13098310","BillingStreet":"JATAI","CEC_BillingNumber__c":"44","CEC_BillingNeighborhood__c":"LOTEAMENTO ALPHAVILLE CAMPINAS","BillingCity":"CAMPINAS","BillingState":"SP"}';
    private final static String contact= '{"attributes":{"type":"Contact"},"FirstName":"teste","LastName":"teste","Name":"teste teste"}';
    private final static String accountContactRelation = '{"attributes":{"type":"AccountContactRelation"},"Roles":"Titular","ResponsibleForTheSignature__c":false}';
    //private static SOLAR_PME_IntegrationInputOrder integration = new SOLAR_PME_IntegrationInputOrder();
    
    @TestSetup
    static void testSetup(){
        Id pricebookId = Test.getStandardPricebookId();
        
        Account acc = (Account)JSON.deserialize(accountItem, Account.class);
        database.insert(acc);

        Account accRecord2=new account();
        accRecord2.Name='Test Acc2';
        insert accRecord2;
        
        contact c = (Contact)JSON.deserialize(contact, Contact.class);
        c.AccountId = acc.Id;
        database.insert(c);
        
        AccountContactRelation relation = (AccountContactRelation)JSON.deserialize(accountContactRelation, AccountContactRelation.class);
        relation.AccountId =accRecord2.Id;
        relation.ContactId = c.id;
        database.insert(relation);
        
        Order order = (Order)JSON.deserialize(jsonObject, Order.class);
        order.EffectiveDate = Date.today();
        order.Status = 'Em Andamento';
        order.Pricebook2Id  = pricebookId;
        order.AccountId = acc.id;
        order.Related_Contacts__c = ''+ c.Id+';'+acc.Id+';';
        database.insert(order);
        
        Product2 product = (Product2) JSON.deserialize(productItem, Product2.class);
        product.ProductCode = Label.CEC_PME_FRANQ_COMPARTILHADA;
        product.vlocity_cmt__Type__c = 'Plug-In';
        product.vlocity_cmt__SubType__c='SimCard Avulso';
        product.vlocity_cmt__JSONAttribute__c = '{"PME_CT_ATT_Controle_Pontos":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1H000006I6AVQA0","attributeid__c":"a0L0U000001xARCUA2","attributecategoryid__c":"a0K0U000002dQDmUAM","categorycode__c":"PME_CT_ATT_Controle_Pontos","categoryname__c":"Controle de Pontos","attributeuniquecode__c":"PME_ATT_Controle_Pontos","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Controle de Pontos","displaysequence__c":"null","categorydisplaysequence__c":180,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I0U000003hRGJUA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":"Acumula pontos","valuedatatype__c":"Checkbox","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":true},"$$AttributeDefinitionEnd$$":null}]}';
        database.insert(product);
        
        Product2 product3 = (Product2) JSON.deserialize(productItem, Product2.class);
        product3.ProductCode = Label.CEC_PME_FRANQ_INDIVIDUAL;
        product3.vlocity_cmt__Type__c = 'Aparelhos';
        product3.vlocity_cmt__SubType__c='SimCard Aparelho';
        product3.vlocity_cmt__JSONAttribute__c = '{"PME_CT_ATT_Controle_Pontos":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1H000006I6AVQA0","attributeid__c":"a0L0U000001xARCUA2","attributecategoryid__c":"a0K0U000002dQDmUAM","categorycode__c":"PME_CT_ATT_Controle_Pontos","categoryname__c":"Controle de Pontos","attributeuniquecode__c":"PME_ATT_Controle_Pontos","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Controle de Pontos","displaysequence__c":"null","categorydisplaysequence__c":180,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I0U000003hRGJUA2","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":"Acumula pontos","valuedatatype__c":"Checkbox","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":true},"$$AttributeDefinitionEnd$$":null}]}';
        database.insert(product3);
        
        Pricebookentry price = (Pricebookentry) JSON.deserialize(priceItem, Pricebookentry.class);
        price.UnitPrice=10.0;
        price.Pricebook2Id = pricebookId;
        price.Product2Id = product.Id;
        database.insert(price);  
        
        Pricebookentry price2 = (Pricebookentry) JSON.deserialize(priceItem, Pricebookentry.class);
        price2.UnitPrice=10.0;
        price2.Pricebook2Id = pricebookId;
        price2.Product2Id = product3.Id;
        database.insert(price2);   
       		
        OrderItem item = (OrderItem)JSON.deserialize(jsonItem, OrderItem.class);
        item.OrderId = order.Id;
        item.Product2Id = product.id;
        item.PricebookEntryId = price.id;
        item.BonusValue__c = '4GB';
        item.vlocity_cmt__AssetReferenceId__c = '8021g00000177wcAAA';
        item.ReliesOnReferenceId__c = '8021g00000177wcAAA';
        item.vlocity_cmt__RecurringDiscountPrice__c = 5;
        item.vlocity_cmt__RecurringTotal__c=5;
        database.insert(item);
        
        OrderItem item2 = (OrderItem)JSON.deserialize(jsonItem, OrderItem.class);
        item2.OrderId = order.Id;
        item2.Product2Id = product3.id;
        item2.TradeIn__c ='2 Meses';
        item2.BonusValue__c = '4GB';
        item2.vlocity_cmt__RecurringDiscountPrice__c = 5;
        item2.vlocity_cmt__RecurringTotal__c=5;
        item2.PricebookEntryId = price2.id;
        item2.vlocity_cmt__AssetReferenceId__c = '8021g00000170AUAAY';
        item2.ReliesOnReferenceId__c = '8021g00000170AUAAY';
        item2.TypeOfRequest__c = 'TT PF/PJ';
        database.insert(item2);
        
        ServiceParameter__c srvP = CEC_PME_OrderTestMethods.createParameter('CEC_PME_EnvioPedido');
        insert srvP;
    }
    
    @isTest
    static void send() {
        Boolean hasError = false;
        try{
            test.startTest();
            SOLAR_PME_IntegrationInputOrder integration = new SOLAR_PME_IntegrationInputOrder();
            Order order = [select id FROM Order LIMIT 1];
            integration.send(order.Id);
            } catch(Exception e) {
            hasError = true;
        }
        System.assert(hasError);
       	test.stopTest(); 
    }
    
    @isTest
    static void stringToInteger() {
        test.startTest();
        SOLAR_PME_IntegrationInputOrder integration = new SOLAR_PME_IntegrationInputOrder();
        Integer value = integration.stringToInteger('123');
        System.debug(value);
        System.assert(value>0);
       	test.stopTest();    
         
    }
    
     @isTest
    static void getOnJSONPeriod() {
        test.startTest();
        OrderItem item3 = (OrderItem)JSON.deserialize(jsonItem, OrderItem.class);
        item3.vlocity_cmt__JSONAttribute__c ='{"ATT_CAT_FRANQ":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1g000004o9hzAAA","attributeid__c":"a0L1g000001HoRrEAK","attributecategoryid__c":"a0K0U000002dQDlUAM","categorycode__c":"ATT_CAT_FRANQ","categoryname__c":"Franquia","attributeuniquecode__c":"ATT_PME_BonusValue","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Valor Bonus","displaysequence__c":"20","categorydisplaysequence__c":20,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I1g000002ztUpEAI","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"5GB","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"5 GB","id":"e64b2b03-993f-5c92-1372-560f789976c5","sequence":60,"value":"5GB"}],"values":[{"displayText":"500 MB","id":"578af91a-9369-26a1-17f3-cafa3e264bd3","sequence":10,"value":"500MB"},{"displayText":"1 GB","id":"27e8adf3-a7c3-7859-65bc-0cacbe1f641a","sequence":20,"value":"1GB"},{"displayText":"2 GB","id":"2f016b51-e1c9-da1f-0f4a-ce92937b8981","sequence":30,"value":"2GB"},{"displayText":"3 GB","id":"4413952c-3c29-ede4-b646-f9289b303bf5","sequence":40,"value":"3GB"},{"displayText":"4 GB","id":"23a1b397-c2b4-d8e1-88da-2747d6710eea","sequence":50,"value":"4GB"},{"displayText":"5 GB","id":"e64b2b03-993f-5c92-1372-560f789976c5","sequence":60,"value":"5GB"},{"displayText":"6 GB","id":"9145f10e-d36b-5e64-3a63-f2b1d036c3a4","sequence":70,"value":"6GB"},{"displayText":"7 GB","id":"2b14e0bb-dcd2-801d-56f8-9804670770ec","sequence":80,"value":"7GB"},{"displayText":"8 GB","id":"1ddf094a-e05f-69c0-1d35-6dc858d1b94c","sequence":90,"value":"8GB"},{"displayText":"9 GB","id":"17e23fc7-5adc-52ac-ff8f-7ae07f778681","sequence":100,"value":"9GB"},{"displayText":"10 GB","id":"027ee8fa-c5e8-35c2-7296-22bc73ede29d","sequence":110,"value":"10GB"},{"displayText":"12 GB","id":"ad6f0a51-bb81-1b9b-6c48-513f5c0bf437","sequence":120,"value":"12GB"},{"displayText":"15 GB","id":"57258bbc-0e2c-a019-d40e-8aa9d3bacb5b","sequence":130,"value":"15GB"},{"displayText":"20 GB","id":"59655167-09df-d219-46be-9048379be467","sequence":140,"value":"20GB"},{"displayText":"25 GB","id":"bcf57064-1bf6-3ddc-a138-84235e1a17f6","sequence":150,"value":"25GB"},{"displayText":"30 GB","id":"5b31e5f0-163b-9b1e-0d7c-714bef4a4c4a","sequence":160,"value":"30GB"},{"displayText":"35 GB","id":"3c3da4ea-246c-d141-1861-4edeb7cfded4","sequence":170,"value":"35GB"},{"displayText":"40 GB","id":"aea51f2c-4705-8fca-afea-518beb11b136","sequence":180,"value":"40GB"},{"displayText":"45 GB","id":"b15c69f7-ad9a-be82-99b9-1103176b7d58","sequence":190,"value":"45GB"},{"displayText":"50 GB","id":"1906ff62-21c7-6ca4-9b5b-21073ab961c0","sequence":200,"value":"50GB"},{"displayText":"60 GB","id":"de270b25-2d60-bc1b-d90c-f666941602a1","sequence":210,"value":"60GB"},{"displayText":"70 GB","id":"7912e2ab-2f07-9709-c7e0-7a10d88a49bc","sequence":220,"value":"70GB"},{"displayText":"80 GB","id":"bf704b22-1b5f-5b78-ca6b-2c312ca97488","sequence":230,"value":"80GB"},{"displayText":"90 GB","id":"37a772d5-00a1-0798-5d33-4e9855d8cdb2","sequence":240,"value":"90GB"},{"displayText":"100 GB","id":"c3b924f5-4692-3115-cafc-e9c1971125ef","sequence":250,"value":"100GB"},{"displayText":"140 GB","id":"333a57d3-7bee-10b4-b4a9-7673b13623e9","sequence":260,"value":"140GB"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1g000004o9hzAAA","attributeid__c":"a0L1g000001HwNyEAK","attributecategoryid__c":"a0K0U000002dQDlUAM","categorycode__c":"ATT_CAT_FRANQ","categoryname__c":"Franquia","attributeuniquecode__c":"ATT_PME_BonusValidity","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Validade Bonus","displaysequence__c":"20","categorydisplaysequence__c":20,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I1g000002ztUoEAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"24 meses"},"$$AttributeDefinitionEnd$$":null}],"PME_CT_ATT_Controle_Pontos":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"a271g0000013CFVAA2","attributeid__c":"a0L0U000001xARCUA2","attributecategoryid__c":"a0K0U000002dQDmUAM","categorycode__c":"PME_CT_ATT_Controle_Pontos","categoryname__c":"Controle de Pontos","attributeuniquecode__c":"PME_ATT_Controle_Pontos","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Controle de Pontos","displaysequence__c":"180","categorydisplaysequence__c":180,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I1g000002tzZTEAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":"Acumula pontos","valuedatatype__c":"Checkbox","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":true},"$$AttributeDefinitionEnd$$":null}]}';
       SOLAR_PME_IntegrationInputOrder integration = new SOLAR_PME_IntegrationInputOrder();
        System.assert(integration.getOnJSONPeriod(item3.vlocity_cmt__JSONAttribute__c) != null );
       	test.stopTest();    
    }
    
     @isTest
    static void getOnJSONP() {
        test.startTest();
        SOLAR_PME_IntegrationInputOrder integration = new SOLAR_PME_IntegrationInputOrder();
         Product2 product = (Product2) JSON.deserialize(productItem, Product2.class);
        product.ProductCode = Label.CEC_PME_FRANQ_COMPARTILHADA;
        product.vlocity_cmt__Type__c = 'Plug-In';
        product.vlocity_cmt__SubType__c='SimCard Avulso';
        product.vlocity_cmt__JSONAttribute__c = '{"ATT_CAT_FRANQ":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1g000004o9hzAAA","attributeid__c":"a0L1g000001HoRrEAK","attributecategoryid__c":"a0K0U000002dQDlUAM","categorycode__c":"ATT_CAT_FRANQ","categoryname__c":"Franquia","attributeuniquecode__c":"ATT_PME_BonusValue","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Valor Bonus","displaysequence__c":"20","categorydisplaysequence__c":20,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I1g000002ztUpEAI","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"5GB","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"5 GB","id":"e64b2b03-993f-5c92-1372-560f789976c5","sequence":60,"value":"5GB"}],"values":[{"displayText":"500 MB","id":"578af91a-9369-26a1-17f3-cafa3e264bd3","sequence":10,"value":"500MB"},{"displayText":"1 GB","id":"27e8adf3-a7c3-7859-65bc-0cacbe1f641a","sequence":20,"value":"1GB"},{"displayText":"2 GB","id":"2f016b51-e1c9-da1f-0f4a-ce92937b8981","sequence":30,"value":"2GB"},{"displayText":"3 GB","id":"4413952c-3c29-ede4-b646-f9289b303bf5","sequence":40,"value":"3GB"},{"displayText":"4 GB","id":"23a1b397-c2b4-d8e1-88da-2747d6710eea","sequence":50,"value":"4GB"},{"displayText":"5 GB","id":"e64b2b03-993f-5c92-1372-560f789976c5","sequence":60,"value":"5GB"},{"displayText":"6 GB","id":"9145f10e-d36b-5e64-3a63-f2b1d036c3a4","sequence":70,"value":"6GB"},{"displayText":"7 GB","id":"2b14e0bb-dcd2-801d-56f8-9804670770ec","sequence":80,"value":"7GB"},{"displayText":"8 GB","id":"1ddf094a-e05f-69c0-1d35-6dc858d1b94c","sequence":90,"value":"8GB"},{"displayText":"9 GB","id":"17e23fc7-5adc-52ac-ff8f-7ae07f778681","sequence":100,"value":"9GB"},{"displayText":"10 GB","id":"027ee8fa-c5e8-35c2-7296-22bc73ede29d","sequence":110,"value":"10GB"},{"displayText":"12 GB","id":"ad6f0a51-bb81-1b9b-6c48-513f5c0bf437","sequence":120,"value":"12GB"},{"displayText":"15 GB","id":"57258bbc-0e2c-a019-d40e-8aa9d3bacb5b","sequence":130,"value":"15GB"},{"displayText":"20 GB","id":"59655167-09df-d219-46be-9048379be467","sequence":140,"value":"20GB"},{"displayText":"25 GB","id":"bcf57064-1bf6-3ddc-a138-84235e1a17f6","sequence":150,"value":"25GB"},{"displayText":"30 GB","id":"5b31e5f0-163b-9b1e-0d7c-714bef4a4c4a","sequence":160,"value":"30GB"},{"displayText":"35 GB","id":"3c3da4ea-246c-d141-1861-4edeb7cfded4","sequence":170,"value":"35GB"},{"displayText":"40 GB","id":"aea51f2c-4705-8fca-afea-518beb11b136","sequence":180,"value":"40GB"},{"displayText":"45 GB","id":"b15c69f7-ad9a-be82-99b9-1103176b7d58","sequence":190,"value":"45GB"},{"displayText":"50 GB","id":"1906ff62-21c7-6ca4-9b5b-21073ab961c0","sequence":200,"value":"50GB"},{"displayText":"60 GB","id":"de270b25-2d60-bc1b-d90c-f666941602a1","sequence":210,"value":"60GB"},{"displayText":"70 GB","id":"7912e2ab-2f07-9709-c7e0-7a10d88a49bc","sequence":220,"value":"70GB"},{"displayText":"80 GB","id":"bf704b22-1b5f-5b78-ca6b-2c312ca97488","sequence":230,"value":"80GB"},{"displayText":"90 GB","id":"37a772d5-00a1-0798-5d33-4e9855d8cdb2","sequence":240,"value":"90GB"},{"displayText":"100 GB","id":"c3b924f5-4692-3115-cafc-e9c1971125ef","sequence":250,"value":"100GB"},{"displayText":"140 GB","id":"333a57d3-7bee-10b4-b4a9-7673b13623e9","sequence":260,"value":"140GB"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1g000004o9hzAAA","attributeid__c":"a0L1g000001HwNyEAK","attributecategoryid__c":"a0K0U000002dQDlUAM","categorycode__c":"ATT_CAT_FRANQ","categoryname__c":"Franquia","attributeuniquecode__c":"ATT_PME_BonusValidity","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Validade Bonus","displaysequence__c":"20","categorydisplaysequence__c":20,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I1g000002ztUoEAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"24 meses"},"$$AttributeDefinitionEnd$$":null}],"PME_CT_ATT_Controle_Pontos":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"a271g0000013CFVAA2","attributeid__c":"a0L0U000001xARCUA2","attributecategoryid__c":"a0K0U000002dQDmUAM","categorycode__c":"PME_CT_ATT_Controle_Pontos","categoryname__c":"Controle de Pontos","attributeuniquecode__c":"PME_ATT_Controle_Pontos","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Controle de Pontos","displaysequence__c":"180","categorydisplaysequence__c":180,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I1g000002tzZTEAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":"Acumula pontos","valuedatatype__c":"Checkbox","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":true},"$$AttributeDefinitionEnd$$":null}]}';
       System.assert(integration.getOnJSON(product.vlocity_cmt__JSONAttribute__c,'value__c') != null );
       	test.stopTest();    
         
    }
    
    @isTest
    public static void builderLineDetailsKey() {
        new SOLAR_PME_IntegrationInputOrder().builderLineDetailsKey(new SOLAR_PME_IntegrationInputOrderModel.LineDetails());
    }
    
    @isTest
    public static void buildBonus() {
        new SOLAR_PME_IntegrationInputOrder().buildBonus(new OrderItem());
    }
  
}