/*
* Autor: Marcos Silva - Deloitte
* Data: 09/01/2019
* Descrição: CEC FASE 1 + SQUAD PME: Realiza o envio do pedido para o RPA
*/
public without sharing class CEC_PME_EnvioPedido_Service {
    public class CEC_PME_EnvioPedido_ServiceException extends Exception{}
    private CEC_PME_EnvioPedido_Service(){}
  
    //constantes   
    static final String INTERNATIONAL_CODE = '55';
    static final String CONST_MOBILE_PHONE = 'Celular';
    static final String CONST_HOME_PHONE = 'Residencial';
	static final String TIPO_PEDIDO_NOVO = 'Novo';  
    static final String TIPO_MSG_NOVO = 'novo';
    static final String CONST_SIM = 'Sim'; 
    static final String CONST_SIM_MAIUSC = 'SIM';
    static final String ACAO_MSG_INCLUIR = 'incluir';    
    static final String TIPO_PEDIDO_REENVIO = 'SUBMETERORDEM';
    static final String TIPO_ASSINATURA = 'SignatureType';
    static final String API_VERSION = '1;2018-12-17';
    static final String TRANSACTION_ID = 'Id-';
    static final String NOME_SERVICO = 'CEC_PME_EnvioPedido';
    static final String TIPO_CNAE = 'primário';
    static final String GERENTE_CONTA = 'GERENTE_CONTA';
    static final String TIPO_PROD_APARELHO = 'Aparelho';
    static final String TIPO_PROD_APARELHOS = 'Aparelhos';
    static final String PROD_SIMCARD_AVULSO = 'SimCard Avulso';    
    static final String PROD_SIMCARD_APARELHO = 'SimCard Aparelho';
    static final String ACAO_PEDIDO_ATIVAR = 'ATIVAR';
    static final String PLANO_IND = 'Individual';    
    static final String PLANO_COMP= 'Compartilhado'; 
    static final String TIPO_FRANQUIA_IND = Label.CEC_PME_FRANQ_INDIVIDUAL;
    static final String TIPO_FRANQUIA_COMP = Label.CEC_PME_FRANQ_COMPARTILHADA;
    static final String BOOL_FALSE = 'false';
    static final String BOOL_TRUE = 'true';
    static final String ESTADO_SP = 'SP';
    static final String PERIODO_24MESES = '24_MESES';
    static final String TIPO_REQ_TRANSF = 'TT PF/PJ';
    static final String TIPO_PROD_PLUGIN = 'Plug-In';
    static final String NAO_DISPOSITIVO = 'NotIsADevice';
    static final String NAO_DISP_OPCIONAIS = 'dontHaveOptionalDevices';
    static final String TIPO_PROD_SERVICO = 'Serviço';
    static final String TIPO_PROD_GESTOR = 'Gestor Online'; 
    static final String EMPRESA_PUBLICA = 'Empresa Pública';
    static final String EMPRESA_PRIVADA = 'Empresa Privada';
    static final String TITULO = 'Prezado';
    static final String HORA_ANIVERSARIO = 'T00:00:00.000Z';
    static final String ERRO_PONTOS = 'Erro:';
    static final String ERRO_INT = 'Erro na integração';
    
    private static CEC_PME_FromToUtil fromTo;
    private static Map<String,String> mapColorSapId;
    private static Map<String,Object> jsonMap;
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para o envio de pedidos novos
    */    
    public static CEC_PME_EnvioPedido_Response enviarPedido(String idPedido){
        try {
            return enviarPedido(idPedido, TIPO_PEDIDO_NOVO);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }            
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para o reenvio de pedidos
    */     
    public static CEC_PME_EnvioPedido_Response renviarPedido(String idPedido){
        try {
            return enviarPedido(idPedido, TIPO_PEDIDO_REENVIO);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }            
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Realiza a montagem do json a ser enviado e faz a chamada ao end point de destino
    */     
    private static CEC_PME_EnvioPedido_Response enviarPedido(String idPedido, String tipoEnvio){
        
        CEC_PME_EnvioPedidoRequest req = new CEC_PME_EnvioPedidoRequest();
        fromTo = new CEC_PME_FromToUtil(TIPO_ASSINATURA);
        
        Order ord = getOrder(idPedido);
        Account acc = getAccount(ord);
        List<Contact> lstContact = getListContact(acc);
        
        Set<Id> setIds = getRelatedContactIdList(ord.Related_Contacts__c);
        List<AccountContactRelation> lstAccCttRelation = getListAccCttRelation(setIds);
        
        User usr = getUser(ord);
        List<OrderItem> lstOrderItem = getListOrderItem(ord);
        List<OrderItem> lstDeviceColors = generateMapSAPColors(lstOrderItem);
        
        req.apiVersion = API_VERSION;
        req.transactionId = TRANSACTION_ID + order.OrderNumber;
        
        mapColorSapId = getMapColorSapId(lstOrderItem);
        
        req.data = getData(usr, acc, ord, lstOrderItem, lstDeviceColors, lstContact, lstAccCttRelation, tipoEnvio);
        
		String endPointMethod = '';
        String serviceName = NOME_SERVICO; 
        ServiceParameter__c param = ServiceParameter__c.getInstance(serviceName); 
		
        try{
            endPointMethod = param.EndPoint__c + endPointMethod;      
        
            if(Test.isRunningTest()){
                Test.setMock(HttpCalloutMock.class, new CEC_PME_EnvioPedido_Mock());
            }

            //Adicionar gestor online quando plano individual US 24075
            /*if (req.data.salesOrders != null) {
                for(CEC_PME_EnvioPedidoRequest.SalesOrders salesOrder : req.data.salesOrders) {
                    if (salesOrder.order != null) {
                        for(CEC_PME_EnvioPedidoRequest.Plans plan : salesOrder.order.plans) {                          
                            addGestorOnline(plan);                          
                        }
                    }                
                }
            }*/

			jsonMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(req));  
			removeAttributes(jsonMap);
			
            System.Debug('Request JSON: ' + JSON.serializePretty(jsonMap));
            
            HttpResponse res = CEC_PME_HttpReq.sendReqBody(serviceName, endPointMethod, jsonMap);
            
            if(res.getStatusCode() < 200 || res.getStatusCode() > 300) {
                throw new CEC_PME_EnvioPedido_ServiceException(ERRO_INT +'(' + res.getStatusCode() + '):' + res.getStatus());
            }
            
            System.Debug('Response JSON: ' + res.getBody());
            
            CEC_PME_EnvioPedido_Response response = (CEC_PME_EnvioPedido_Response)JSON.deserialize(res.getBody(), CEC_PME_EnvioPedido_Response.class);
            
            system.debug('response ' + Json.serialize(response));
            return response;
            
        } catch(Exception e) {
            System.debug('Message: ' + e.getMessage());   
            return null;
        }
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para preenchimento do pedido
    */ 
    private static CEC_PME_EnvioPedidoRequest.Data getData(User usr, Account acc, Order ord, List<OrderItem> lstOrderItem, List<OrderItem> lstDeviceColors, List<Contact> lstContact, List<AccountContactRelation> lstAccCttRelation, String tipoEnvio){
        CEC_PME_EnvioPedidoRequest.Data data = new CEC_PME_EnvioPedidoRequest.Data();
        
        try {
            data.salesOrders = getListSalesOrders(usr, acc, ord, lstOrderItem, lstDeviceColors, lstContact, lstAccCttRelation, tipoEnvio);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }        
        return data;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para o preenchimento da lista de pedidos
    */     
    private static List<CEC_PME_EnvioPedidoRequest.SalesOrders> getListSalesOrders(User usr, Account acc, Order ord, List<OrderItem> lstOrderItem, List<OrderItem> lstDeviceColors, List<Contact> lstContact, List<AccountContactRelation> lstAccCttRelation, String tipoEnvio){
        List<CEC_PME_EnvioPedidoRequest.SalesOrders> lstSalesOrders = new List<CEC_PME_EnvioPedidoRequest.SalesOrders>();
        
        try {
            lstSalesOrders.add(getSalesOrders(usr, acc, ord, lstOrderItem, lstDeviceColors, lstContact, lstAccCttRelation, tipoEnvio));
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return lstSalesOrders;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para o preenchimento do pedido
    */     
    private static CEC_PME_EnvioPedidoRequest.SalesOrders getSalesOrders(User usr, Account acc, Order ord, List<OrderItem> lstOrderItem, List<OrderItem> lstDeviceColors, List<Contact> lstContact, List<AccountContactRelation> lstAccCttRelation, String tipoEnvio){
        CEC_PME_EnvioPedidoRequest.SalesOrders salesOrders = new CEC_PME_EnvioPedidoRequest.SalesOrders();
        
        try {
            salesOrders.salesParty = getSalesParty(usr, acc.CommercialSegment__c);
            salesOrders.customer = getCustomer(acc, lstContact, lstAccCttRelation, ord);
            salesOrders.equipmentDelivery = getEquipmentDelivery(ord, acc);
            salesOrders.order = getOrder(ord, lstOrderItem, lstDeviceColors, tipoEnvio, acc);
            salesOrders.summary = getSummary(lstOrderItem);
            salesOrders.subscriberAcceptances = getSubscriberAcceptances(ord);
            salesOrders.documents = getListDocuments(ord);
            salesOrders.message = getMessage(tipoEnvio);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return salesOrders;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para o preenchimento dos documentos do pedido
    */     
    private static List<CEC_PME_EnvioPedidoRequest.Documents> getListDocuments(Order ord){
        List<CEC_PME_EnvioPedidoRequest.Documents> lstDocuments = new List<CEC_PME_EnvioPedidoRequest.Documents>();
        Set<String> setContentLink = new Set<String>();
        
        try {
            for(ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: ord.Id]){
                setContentLink.add(cdl.ContentDocumentId);
            }
            
            for(ContentVersion cv : [SELECT Id, PathOnClient, CEC_Tipo_de_Anexo__c,Title FROM ContentVersion WHERE ContentDocumentId =: setContentLink and  IsLatest = true]){
                CEC_PME_EnvioPedidoRequest.Documents documents = new CEC_PME_EnvioPedidoRequest.Documents();
                
                documents.id = cv.Id;
                documents.name = cv.CEC_Tipo_de_Anexo__c;
                documents.fileName = cv.Title;
                
                lstDocuments.add(documents);
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return lstDocuments;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para o preenchimento do tipo de mensagem
    */     
    private static CEC_PME_EnvioPedidoRequest.Message getMessage(String tipoEnvio){
        CEC_PME_EnvioPedidoRequest.Message msg = new CEC_PME_EnvioPedidoRequest.Message();
        
        try {
            if(TIPO_PEDIDO_NOVO.equals(tipoEnvio)){
                msg.type = TIPO_MSG_NOVO;
                msg.action = ACAO_MSG_INCLUIR;    
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return msg;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para o preenchimento do nó recebedores
    */     
    private static CEC_PME_EnvioPedidoRequest.SubscriberAcceptances getSubscriberAcceptances(Order ord){
        CEC_PME_EnvioPedidoRequest.SubscriberAcceptances subscriberAcceptances = new CEC_PME_EnvioPedidoRequest.SubscriberAcceptances();
        
        try {
            subscriberAcceptances.flagAcceptSmsPublicity = false; //Não obtido no fluxo de vendas.
            subscriberAcceptances.flagAcceptLD21Manager = CONST_SIM.equalsIgnoreCase(ord.LD21__c); 
            subscriberAcceptances.flagAuthorizesDataSharing = false; //Não obtido no fluxo de vendas.
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return subscriberAcceptances;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para o preenchimento do nó resumo
    */    
    private static CEC_PME_EnvioPedidoRequest.Summary getSummary(List<OrderItem> lstOrderItem){
        CEC_PME_EnvioPedidoRequest.Summary summary = new CEC_PME_EnvioPedidoRequest.Summary();
        
        try {
            summary.lineQuantity = getLineQuantity(lstOrderItem);
            summary.deviceQuantity = getDeviceQuantity(lstOrderItem);
            summary.simcardQuantity = getSimcardQuantity(lstOrderItem);
            summary.totalValueOfEquipments = getTotalValueOfEquipments(lstOrderItem);
            summary.totalValueOfServices = getTotalValueOfServices(lstOrderItem);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return summary;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para o preenchimento do nó serviços
    */    
    private static String getTotalValueOfServices(List<OrderItem> lstOrderItem){
        Decimal valor = 0;
        
        try {
            for(OrderItem item : lstOrderItem){
                if(!(TIPO_PROD_APARELHO.equals(item.Product2.vlocity_cmt__Type__c) || TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c))){
                    valor+= item.vlocity_cmt__RecurringTotal__c;
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return String.Valueof(valor);
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para calcular o valor total de equipamentos
    */    
    private static String getTotalValueOfEquipments(List<OrderItem> lstOrderItem){
        Decimal valor = 0;
        
        try {
            for(OrderItem item : lstOrderItem){
                if(TIPO_PROD_APARELHO.equals(item.Product2.vlocity_cmt__Type__c) || TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c)){
                    valor+= item.vlocity_cmt__RecurringTotal__c;
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return String.Valueof(valor);
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para calcular a quantidade de simcards
    */      
    private static string getSimcardQuantity(List<OrderItem> lstOrderItem){
        Integer qtd = 0;
        
        try {
            for(OrderItem item : lstOrderItem){
                if(PROD_SIMCARD_AVULSO.equals(item.Product2.vlocity_cmt__SubType__c) || PROD_SIMCARD_APARELHO.equals(item.Product2.vlocity_cmt__SubType__c)){
                    qtd+= Integer.ValueOf(item.Quantity);
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return String.Valueof(qtd);
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para calcular a quantidade de dispositivos
    */      
    private static String getDeviceQuantity(List<OrderItem> lstOrderItem){
        Integer qtd = 0;
        
        try {
            for(OrderItem item : lstOrderItem){
                if(TIPO_PROD_APARELHO.equals(item.Product2.vlocity_cmt__Type__c) || TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c)){
                    qtd+= Integer.ValueOf(item.Quantity);
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return String.Valueof(qtd);
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado para calcular a quantidade de linhas
    */      
    private static String getLineQuantity(List<OrderItem> lstOrderItem){
        Integer qtd = 0;
        
        try {
            for(OrderItem item : lstOrderItem){
                if(PROD_SIMCARD_AVULSO.equals(item.Product2.vlocity_cmt__SubType__c) || PROD_SIMCARD_APARELHO.equals(item.Product2.vlocity_cmt__SubType__c)){
                    qtd+= Integer.ValueOf(item.Quantity);
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return String.Valueof(qtd);
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó pedido
    */      
    private static CEC_PME_EnvioPedidoRequest.Order getOrder(Order ord, List<OrderItem> lstOrderItem, List<OrderItem> lstDeviceColors, String tipoEnvio, Account acc){
        CEC_PME_EnvioPedidoRequest.Order order = new CEC_PME_EnvioPedidoRequest.Order();
        
        try {
            order.orderId = ord.OrderNumber;
            order.orderAction = ACAO_PEDIDO_ATIVAR;
            order.plans = getListPlans(lstOrderItem, ord, lstDeviceColors, acc);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return order;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó planos
    */    
    private static List<CEC_PME_EnvioPedidoRequest.Plans> getListPlans(List<OrderItem> lstOrderItem, Order ord, List<OrderItem> lstDeviceColors, Account acc){
        List<CEC_PME_EnvioPedidoRequest.Plans> lstPlans = new List<CEC_PME_EnvioPedidoRequest.Plans>();
        
        try {
            for(OrderItem itemPlano : lstOrderItem){
                CEC_PME_EnvioPedidoRequest.Plans plans = new CEC_PME_EnvioPedidoRequest.Plans();
                if(TIPO_FRANQUIA_IND.equals(itemPlano.Product2.ProductCode)){
                    plans.planId = itemPlano.vlocity_cmt__AssetReferenceId__c;
                    plans.name = itemPlano.Product2.Name;
                    plans.flagSharedPlan = BOOL_FALSE;
                    if (acc.CommercialSegment__c == 'TOP PME') {
                    	plans.tradeIn = itemPlano.TradeIn__c != null && itemPlano.TradeIn__c != 'Não' ? itemPlano.TradeIn__c.substring(0,1) : itemPlano.TradeIn__c;
                    }
                    plans.groups = getListGroups(PLANO_IND, itemPlano, lstOrderItem, ord, lstDeviceColors, acc);
                    lstPlans.add(plans);
                } else if(TIPO_FRANQUIA_COMP.equals(itemPlano.Product2.ProductCode)){
                    plans.planId = itemPlano.vlocity_cmt__AssetReferenceId__c;
                    plans.name = itemPlano.Product2.Name;
                    if (acc.CommercialSegment__c == 'TOP PME') {
                    	plans.tradeIn = itemPlano.TradeIn__c != null && itemPlano.TradeIn__c != 'Não' ? itemPlano.TradeIn__c.substring(0,1) : itemPlano.TradeIn__c;
                    }
                    plans.flagSharedPlan = BOOL_TRUE;
                    plans.groups = getListGroups(PLANO_COMP, itemPlano, lstOrderItem, ord, lstDeviceColors, acc);
                    lstPlans.add(plans);
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return separatePlansByRegional(lstPlans);
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na separação de planos pro regional
    */     
    private static List<CEC_PME_EnvioPedidoRequest.Plans> separatePlansByRegional(List<CEC_PME_EnvioPedidoRequest.Plans> listOldPlans) {
        List<CEC_PME_EnvioPedidoRequest.Plans> listSeparatedPlans = new List<CEC_PME_EnvioPedidoRequest.Plans>();
        
        try{
            for(CEC_PME_EnvioPedidoRequest.Plans oldPlan : listOldPlans) {
                Map<String, List<CEC_PME_EnvioPedidoRequest.Groups>> mapCKeyLstGroups = new Map<String, List<CEC_PME_EnvioPedidoRequest.Groups>>();
                
                for(CEC_PME_EnvioPedidoRequest.Groups varGroup : oldPlan.groups) {
                    if(mapCKeyLstGroups.containsKey(varGroup.Regional)) {
                        mapCKeyLstGroups.get(varGroup.Regional).add(varGroup);
                    } else {
                        mapCKeyLstGroups.put(varGroup.Regional, new List<CEC_PME_EnvioPedidoRequest.Groups>{varGroup});
                    }
                }
                
                for(List<CEC_PME_EnvioPedidoRequest.Groups> listGroups : mapCKeyLstGroups.values()) {
                    CEC_PME_EnvioPedidoRequest.Plans newPlan = oldPlan.clone();
                    newPlan.groups = listGroups;
                    listSeparatedPlans.add(newPlan);
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return listSeparatedPlans;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó grupos
    */     
    private static List<CEC_PME_EnvioPedidoRequest.Groups> getListGroups(String plano, OrderItem itemPlano, List<OrderItem> lstOrderItem, Order ord, List<OrderItem> lstDeviceColors, Account acc){
        List<CEC_PME_EnvioPedidoRequest.Groups> lstGroups = new List<CEC_PME_EnvioPedidoRequest.Groups>();
        
        try {
            if(PLANO_IND.equals(plano)){
                for(OrderItem itemFranquia : lstOrderItem){
                    if(itemFranquia.ReliesOnReferenceId__c == itemPlano.vlocity_cmt__AssetReferenceId__c){
                        CEC_PME_EnvioPedidoRequest.Groups groups = new CEC_PME_EnvioPedidoRequest.Groups();
                                                       
                        groups.groupId = itemFranquia.vlocity_cmt__AssetReferenceId__c;
                        groups.name = itemFranquia.Product2.Name;
                        groups.requestType = itemFranquia.TypeOfRequest__c;
                        groups.stateAbbreviation = itemFranquia.Group__c;
                        if(ESTADO_SP.equalsIgnoreCase(itemFranquia.Group__c)) {
                            groups.regional = itemFranquia.ParentGroup__c;
                        } else {
                            groups.regional = itemFranquia.Group__c;
                        }
                        groups.areaCode = itemFranquia.Subgroup__c;
                        groups.franchise = itemFranquia.Product2.Name;
                        //groups.value = String.ValueOf(itemFranquia.vlocity_cmt__RecurringCharge__c);
                        groups.value = itemFranquia.vlocity_cmt__RecurringDiscountPrice__c != null ? String.ValueOf(itemFranquia.UnitPrice) : String.ValueOf(itemFranquia.vlocity_cmt__RecurringCharge__c);
                        groups.overRateValue = ''; //Mandar valor em branco, sem uso no RPA.
                        groups.contractPeriod = PERIODO_24MESES;
                        groups.paymentMethod = ord.Payment_Term__c;
                        if(fromTo.hasTo(itemPlano.Product2.ProductCode)) {
                            groups.plugin = fromTo.getTo(itemPlano.Product2.ProductCode) + ' ' + itemFranquia.Product2.Name;
                        }
                        
                        groups.additionalServices = getListAdditionalServices(itemFranquia, lstOrderItem);
                        groups.includedServices = getListIncludedServices(itemFranquia, lstOrderItem, true);
                        //groups.specialOffer = getSpecialOffer(itemFranquia, acc);
                      
                        if(TIPO_REQ_TRANSF.equals(itemFranquia.TypeOfRequest__c)){
                            List<CEC_PME_EnvioPedidoRequest.LineDetails> lineDetailsTransf = getListLinesTransf(itemFranquia, lstOrderItem, lstDeviceColors);
                            
                            groups.specialOffer = getSpecialOffer(itemFranquia, acc, 1);
                            
                            for(CEC_PME_EnvioPedidoRequest.LineDetails detailTransf : lineDetailsTransf){
                                List<CEC_PME_EnvioPedidoRequest.Groups> lstGroupsTransf = new List<CEC_PME_EnvioPedidoRequest.Groups>();
                                List<CEC_PME_EnvioPedidoRequest.LineDetails> lstItem = new List<CEC_PME_EnvioPedidoRequest.LineDetails>();
                                CEC_PME_EnvioPedidoRequest.Groups groupsTransf = groups.clone();
                                lstItem.add(detailTransf);
                                groupsTransf.lineDetails = lstItem;
                               
                                lstGroupsTransf.add(groupsTransf);
                                lstGroups.addAll(lstGroupsTransf);
                            }                                                           
                        } else {
                            List<CEC_PME_EnvioPedidoRequest.LineDetails> lineDetailsAvulso = getListAvulso(itemFranquia, lstOrderItem, lstDeviceColors);
                            
                            if(lineDetailsAvulso.size() > 0){     
								groups.specialOffer = getSpecialOffer(itemFranquia, acc, lineDetailsAvulso.size());
                                
                                List<CEC_PME_EnvioPedidoRequest.Groups> lstGroupsAvulso = new List<CEC_PME_EnvioPedidoRequest.Groups>();
                                CEC_PME_EnvioPedidoRequest.Groups groupsAvulso = groups.clone();
                                groupsAvulso.lineDetails = lineDetailsAvulso;
                                
                                lstGroupsAvulso.add(groupsAvulso);
                                lstGroups.addAll(lstGroupsAvulso);
                            } 
                           
                            Set<String> setDistinctDevices = getDistinctDevices(itemFranquia, lstOrderItem);
                            
                            for(String device : setDistinctDevices){
                                List<CEC_PME_EnvioPedidoRequest.LineDetails> lineDetailsLineAparelho = getListLineAparelho(itemFranquia, lstOrderItem, lstDeviceColors, device);
                                
                                if(lineDetailsLineAparelho.size() > 0){
                                    groups.specialOffer = getSpecialOffer(itemFranquia, acc, lineDetailsLineAparelho.size());
                                    
                                    List<CEC_PME_EnvioPedidoRequest.Groups> lstGroupsAparelho = new List<CEC_PME_EnvioPedidoRequest.Groups>();
                                    CEC_PME_EnvioPedidoRequest.Groups groupsAparelho = groups.clone();
                                    groupsAparelho.lineDetails = lineDetailsLineAparelho;
                                  
                                    lstGroupsAparelho.add(groupsAparelho);
                                    lstGroups.addAll(lstGroupsAparelho);                                      
                                }
                            }                              
                        }
                    }
                }    
            } else {
                // Compartilhado 
                for(OrderItem itemFranquia : lstOrderItem){
                    if(itemFranquia.ReliesOnReferenceId__c == itemPlano.vlocity_cmt__AssetReferenceId__c){
                        for(OrderItem itemPlugin : lstOrderItem){
                            if(itemPlugin.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                                if(TIPO_PROD_PLUGIN.equals(itemPlugin.Product2.vlocity_cmt__Type__c)){
                                    CEC_PME_EnvioPedidoRequest.Groups groups = new CEC_PME_EnvioPedidoRequest.Groups();    
                                    groups.groupId = itemFranquia.vlocity_cmt__AssetReferenceId__c;
                                    groups.name = itemFranquia.Product2.Name;
                                    groups.requestType = itemPlugin.TypeOfRequest__c;
                                  
                                    if(ESTADO_SP.equalsIgnoreCase(itemFranquia.Group__c)) {
                                        groups.regional = itemFranquia.ParentGroup__c;
                                    } else {
                                        groups.regional = itemFranquia.Group__c;
                                    }
                                    groups.stateAbbreviation = itemFranquia.Group__c;
                                    groups.areaCode = itemPlugin.Subgroup__c;
                                    groups.franchise = itemFranquia.Product2.Name;
                                    groups.value = String.ValueOf(itemFranquia.vlocity_cmt__RecurringCharge__c);
                                    groups.overRateValue = ''; //Mandar valor em branco, sem uso no RPA.
                                    groups.contractPeriod = ord.Payment_Term__c;
                                    groups.paymentMethod = ord.Payment_Term__c;
                                    groups.plugin = ''; //Definir como será o valor.
                                    groups.additionalServices = getListAdditionalServices(itemPlugin, lstOrderItem);
                                    groups.additionalServices = getListAdditionalServices(itemFranquia, lstOrderItem);
                                   
                                    if(fromTo.hasTo(itemPlugin.Product2.ProductCode)) {
                                        groups.plugin = fromTo.getTo(itemPlugin.Product2.ProductCode);
                                    }
                                    groups.includedServices = getListIncludedServices(itemPlugin, lstOrderItem, false);
                                    
                                    if(TIPO_REQ_TRANSF.equals(itemFranquia.TypeOfRequest__c)){
                                        List<CEC_PME_EnvioPedidoRequest.LineDetails> lineDetailsTransf = getListLinesTransf(itemPlugin, lstOrderItem, lstDeviceColors);
                                        
                                        for(CEC_PME_EnvioPedidoRequest.LineDetails detailTransf : lineDetailsTransf){
                                            List<CEC_PME_EnvioPedidoRequest.Groups> lstGroupsTransf = new List<CEC_PME_EnvioPedidoRequest.Groups>();
                                            List<CEC_PME_EnvioPedidoRequest.LineDetails> lstItem = new List<CEC_PME_EnvioPedidoRequest.LineDetails>();
                                            CEC_PME_EnvioPedidoRequest.Groups groupsTransf = groups.clone();
                                            lstItem.add(detailTransf);
                                            groupsTransf.lineDetails = lstItem;
                                            lstGroupsTransf.add(groupsTransf);
                                            lstGroups.addAll(lstGroupsTransf);
                                        }
                                    } else {
                                        List<CEC_PME_EnvioPedidoRequest.LineDetails> lineDetailsAvulso = getListAvulso(itemPlugin, lstOrderItem, lstDeviceColors);
                                        
                                        if(lineDetailsAvulso.size() > 0){
                                            List<CEC_PME_EnvioPedidoRequest.Groups> lstGroupsAvulso = new List<CEC_PME_EnvioPedidoRequest.Groups>();
                                            CEC_PME_EnvioPedidoRequest.Groups groupsAvulso = groups.clone();
                                            groupsAvulso.lineDetails = lineDetailsAvulso;
                                            lstGroupsAvulso.add(groupsAvulso);
                                            lstGroups.addAll(lstGroupsAvulso);
                                           
                                        } 
                                        
                                        Set<String> setDistinctDevices = getDistinctDevices(itemPlugin, lstOrderItem);
                                        
                                        for(String device : setDistinctDevices){
                                            List<CEC_PME_EnvioPedidoRequest.LineDetails> lineDetailsLineAparelho = getListLineAparelho(itemPlugin, lstOrderItem, lstDeviceColors, device);
                                            
                                            if(lineDetailsLineAparelho.size() > 0){
                                                List<CEC_PME_EnvioPedidoRequest.Groups> lstGroupsAparelho = new List<CEC_PME_EnvioPedidoRequest.Groups>();
                                                CEC_PME_EnvioPedidoRequest.Groups groupsAparelho = groups.clone();
                                                groupsAparelho.lineDetails = lineDetailsLineAparelho;
                                                lstGroupsAparelho.add(groupsAparelho);
                                                lstGroups.addAll(lstGroupsAparelho);                                                  
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } 
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return separateGroup(lstGroups);
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na separação de grupos com detalhes 
    */      
    private static List<CEC_PME_EnvioPedidoRequest.Groups> separateGroup(List<CEC_PME_EnvioPedidoRequest.Groups> listGroups) {
        List<CEC_PME_EnvioPedidoRequest.Groups> separetedListGroups = new List<CEC_PME_EnvioPedidoRequest.Groups>();
        
        try {
            for(CEC_PME_EnvioPedidoRequest.Groups oldGroup : listGroups) {
                Map<String, List<CEC_PME_EnvioPedidoRequest.LineDetails>> mapCKeyLstLineDetails = new Map<String, List<CEC_PME_EnvioPedidoRequest.LineDetails>>();
                
                for(CEC_PME_EnvioPedidoRequest.LineDetails lineDetail : oldGroup.lineDetails) {
                    
                    String lineDetailKey = builderLineDetailsKey(lineDetail); 
                    
                    if(mapCKeyLstLineDetails.containsKey(lineDetailKey)) {
                        mapCKeyLstLineDetails.get(lineDetailKey).add(lineDetail);
                    } else {
                        mapCKeyLstLineDetails.put(lineDetailKey, new List<CEC_PME_EnvioPedidoRequest.LineDetails>{lineDetail});
                    }
                }
                
                for(List<CEC_PME_EnvioPedidoRequest.LineDetails> listLineDetails : mapCKeyLstLineDetails.values()) {
                    CEC_PME_EnvioPedidoRequest.Groups newGroup = oldGroup.clone();
                    newGroup.lineDetails = listLineDetails;
                    separetedListGroups.add(newGroup);
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        
        return separetedListGroups;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na geração da chave de linha de detalhes
    */      
    private static String builderLineDetailsKey(CEC_PME_EnvioPedidoRequest.LineDetails lineDetail) {
		String key;   
        
        try {
            String operator = String.isBlank(lineDetail.operator) ? '' : lineDetail.operator;
            if(lineDetail.device == null) {
                return NAO_DISPOSITIVO + operator;
            }
            
            key = operator + lineDetail.Device.manufacturerName + lineDetail.Device.modelName + lineDetail.Device.color;
            
            if(lineDetail.Device.optionalDevicesSap == null || lineDetail.Device.optionalDevicesSap.isEmpty()) {
                key = key + NAO_DISP_OPCIONAIS;
            } else {
                for(CEC_PME_EnvioPedidoRequest.OptionalDevicesSap optionalDevicesSap : lineDetail.Device.optionalDevicesSap) {
                    key = key + optionalDevicesSap.Id;
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }            
        return key;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na pesquisa da lista de linhas de transferencia
    */      
    private static List<CEC_PME_EnvioPedidoRequest.LineDetails> getListLinesTransf(OrderItem itemFranquia, List<OrderItem> lstOrderItem, List<OrderItem> lstDeviceColors){
        List<CEC_PME_EnvioPedidoRequest.LineDetails> lstLineTrans = new List<CEC_PME_EnvioPedidoRequest.LineDetails>();
        
        try {
            for(OrderItem item : lstOrderItem){
                if(item.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                    if(TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c) || PROD_SIMCARD_AVULSO.equals(item.Product2.vlocity_cmt__SubType__c)){
                        lstLineTrans.add(getLineDetails(item, lstDeviceColors, lstOrderItem));
                    }
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lstLineTrans;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no filtro de dispositivos distintos
    */      
    private static Set<String> getDistinctDevices(OrderItem itemFranquia, List<OrderItem> lstOrderItem){
        Set<String> setDevices = new Set<String>();
        
        try {
            for(OrderItem item : lstOrderItem){
                if(item.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                    if(TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c)){
                        setDevices.add(item.Product2.Name);
                    }
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return setDevices;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no filtro da lista de aparelho
    */      
    private static List<CEC_PME_EnvioPedidoRequest.LineDetails> getListLineAparelho(OrderItem itemFranquia, List<OrderItem> lstOrderItem, List<OrderItem> lstDeviceColors, String aparelho){
        List<CEC_PME_EnvioPedidoRequest.LineDetails> lstLineAparelho = new List<CEC_PME_EnvioPedidoRequest.LineDetails>();
        
        try {
            for(OrderItem item : lstOrderItem){
                if(item.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                    if(aparelho.equals(item.Product2.Name)){
                        lstLineAparelho.add(getLineDetails(item, lstDeviceColors, lstOrderItem));
                    }
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        } 
        
        return lstLineAparelho;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no filtro de simcards Avulso
    */      
    private static List<CEC_PME_EnvioPedidoRequest.LineDetails> getListAvulso(OrderItem itemFranquia, List<OrderItem> lstOrderItem, List<OrderItem> lstDeviceColors){
        List<CEC_PME_EnvioPedidoRequest.LineDetails> lstLineAvulso = new List<CEC_PME_EnvioPedidoRequest.LineDetails>();
        
        try {
            for(OrderItem item : lstOrderItem){
                if(item.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                    if(PROD_SIMCARD_AVULSO.equals(item.Product2.vlocity_cmt__SubType__c)){
                        lstLineAvulso.add(getLineDetails(item, lstDeviceColors, lstOrderItem));    
                    }
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lstLineAvulso;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no filtro da lista de linha de detalhes
    */      
    private static List<CEC_PME_EnvioPedidoRequest.LineDetails> getListLineDetails(OrderItem itemFranquia, List<OrderItem> lstOrderItem, List<OrderItem> lstDeviceColors){
        List<CEC_PME_EnvioPedidoRequest.LineDetails> lstLineDetails = new List<CEC_PME_EnvioPedidoRequest.LineDetails>();
        
        try {
            for(OrderItem item : lstOrderItem){
                if(item.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                    lstLineDetails.add(getLineDetails(item, lstDeviceColors, lstOrderItem));
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lstLineDetails;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó linha de detalhes
    */      
    private static CEC_PME_EnvioPedidoRequest.LineDetails getLineDetails(OrderItem item, List<OrderItem> lstDeviceColors, List<OrderItem> lstOrderItem){
        CEC_PME_EnvioPedidoRequest.LineDetails lineDetails = new CEC_PME_EnvioPedidoRequest.LineDetails();
        
        try {
            lineDetails.telephoneNumber = item.PortabilityNumber__c;
            lineDetails.donor = getDonor(item, lstOrderItem);
            lineDetails.operator = item.Operator__c;
            lineDetails.simcard = getSimcard(item, lstOrderItem);
            if(!PROD_SIMCARD_AVULSO.equals(item.Product2.vlocity_cmt__SubType__c)) {
                lineDetails.device = getDevice(item, lstDeviceColors);
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lineDetails;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó dispositivos
    */      
    private static CEC_PME_EnvioPedidoRequest.Device getDevice(OrderItem item, List<OrderItem> lstDeviceColors){
        CEC_PME_EnvioPedidoRequest.Device device = new CEC_PME_EnvioPedidoRequest.Device();
        
        try {
            device.manufacturerName = item.Product2.Name;
            device.modelName = item.Product2.Model__c;
            device.color = item.Product2.Color__c;
            device.value = String.valueOf(item.vlocity_cmt__RecurringCharge__c);
            device.flagAcceptAnotherColor = item.DeviceSecondOptionColor__c == CONST_SIM_MAIUSC ? true : false;
            device.chosenDeviceSap = getChosenDeviceSap(item);
            device.optionalDevicesSap = getListOptionalDevicesSap(item, lstDeviceColors);
            device.imei = item.IMEI__c;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return device;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó lista de dispositivos opcionais
    */      
    private static List<CEC_PME_EnvioPedidoRequest.OptionalDevicesSap> getListOptionalDevicesSap(OrderItem item, List<OrderItem> lstDeviceColors){
        List<CEC_PME_EnvioPedidoRequest.OptionalDevicesSap> lstOptionalDevicesSap = new List<CEC_PME_EnvioPedidoRequest.OptionalDevicesSap>();
        
        try {
            String chave = item.Product2.Manufacturer__c + item.Product2.Model__c;
            List<String> listChoosenColor = new List<String>();
            
            if(String.isNotBlank(item.AnotherDeviceColor__c)){
                
                listChoosenColor = item.AnotherDeviceColor__c.split(', ');
            }
            
            for(String choosenColor : listChoosenColor) {
                if(mapColorSapId.containsKey(chave + choosenColor)) {
                    lstOptionalDevicesSap.add(getOptionalDevicesSap(mapColorSapId.get(chave + choosenColor)));
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lstOptionalDevicesSap;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó dispositivos opcionais
    */     
    private static CEC_PME_EnvioPedidoRequest.OptionalDevicesSap getOptionalDevicesSap(String sapId){
        CEC_PME_EnvioPedidoRequest.OptionalDevicesSap optionalDevicesSap = new CEC_PME_EnvioPedidoRequest.OptionalDevicesSap();
        
        try {
            optionalDevicesSap.id = sapId;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return optionalDevicesSap;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó de dispositivos escolhidos
    */     
    private static CEC_PME_EnvioPedidoRequest.ChosenDeviceSap getChosenDeviceSap(OrderItem item){
        CEC_PME_EnvioPedidoRequest.ChosenDeviceSap chosenDeviceSap = new CEC_PME_EnvioPedidoRequest.ChosenDeviceSap();
        
        try {
            chosenDeviceSap.id = item.Product2.SAPID__c;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return chosenDeviceSap;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó simcard
    */     
    private static CEC_PME_EnvioPedidoRequest.Simcard getSimcard(OrderItem item, List<OrderItem> lstOrderItem){
        CEC_PME_EnvioPedidoRequest.Simcard simcard = new CEC_PME_EnvioPedidoRequest.Simcard();
        
        try {
            simcard.iccid = item.ICCID__c;
            simcard.type = ''; //Analisar onde obtém a informação.
            if(item.vlocity_cmt__RecurringCharge__c == 0) {
                simcard.value = String.ValueOf(1);
            } else {
                simcard.value = String.ValueOf(item.vlocity_cmt__RecurringCharge__c);
            }
            
            simcard.sap = getSap(item, lstOrderItem);
            
            for(OrderItem itemSimcard : lstOrderItem){
                if(itemSimcard.ReliesOnReferenceId__c == item.vlocity_cmt__AssetReferenceId__c){
                    simcard.value = String.ValueOf(itemSimcard.vlocity_cmt__RecurringCharge__c);
                    simcard.sap = getSap(itemSimcard, lstOrderItem);
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return simcard;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó sap
    */     
    private static CEC_PME_EnvioPedidoRequest.Sap getSap(OrderItem item, List<OrderItem> lstOrderItem){
        CEC_PME_EnvioPedidoRequest.Sap sap = new CEC_PME_EnvioPedidoRequest.Sap();
        
        try {
            if(TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c)){
                for(OrderItem itemSimCardAparelho : lstOrderItem){
                    if(itemSimCardAparelho.ReliesOnReferenceId__c == item.vlocity_cmt__AssetReferenceId__c){
                        sap.id = itemSimCardAparelho.SAP_ID__c;
                        break;
                    }
                }
            } else {
                sap.id = item.SAP_ID__c;    
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return sap;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó doador
    */     
    private static CEC_PME_EnvioPedidoRequest.Donor  getDonor(OrderItem item, List<OrderItem> lstOrderItem){
        CEC_PME_EnvioPedidoRequest.Donor donor = new CEC_PME_EnvioPedidoRequest.Donor();
        
        try {
            donor.name = item.DonatorName__c;
            donor.cpf = item.DonatorDocumentNumber__c;
            donor.Phones = getDonorPhones(item);
            donor.emailAddress  = item.DonatorEmail__c;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return donor;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento de telefones dos doadores
    */     
    private static List<CEC_PME_EnvioPedidoRequest.Phones> getDonorPhones(OrderItem item){
        List<CEC_PME_EnvioPedidoRequest.Phones> lstPhones = new List<CEC_PME_EnvioPedidoRequest.Phones>();
        CEC_PME_EnvioPedidoRequest.Phones phone = new CEC_PME_EnvioPedidoRequest.Phones();
        
        try {
            phone.telephoneNumber = item.DonatorPhone__c;
            if(String.isBlank(item.DonatorPhone__c)){
                phone.areaCode = '';    
                phone.internationalCode = '';
            } else {
                phone.areaCode = item.DonatorPhone__c.mid(0,2);    
                phone.internationalCode = INTERNATIONAL_CODE;
            }
            
            phone.contactMediumRole = '';
            
            lstPhones.add(phone);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lstPhones;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó lista serviços inclusos
    */     
    private static List<CEC_PME_EnvioPedidoRequest.IncludedServices> getListIncludedServices(OrderItem itemFranquia, List<OrderItem> lstOrderItem, Boolean planoInd){
        List<CEC_PME_EnvioPedidoRequest.IncludedServices> lstIncludedServices = new List<CEC_PME_EnvioPedidoRequest.IncludedServices>();
        Boolean hasGestor = false;
        
        try {
            for(OrderItem item : lstOrderItem){
                if(item.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                    if(!(TIPO_PROD_APARELHO.equals(item.Product2.vlocity_cmt__Type__c) || TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c))){
                        if(item.vlocity_cmt__RecurringTotal__c == 0) { 
                            lstIncludedServices.add(getIncludedServices(item));
                            
                            if (item.Product2.vlocity_cmt__Type__c == Label.CEC_PME_GestorOnline) {
                                hasGestor = true;
                            }
                        }
                    }
                }
            }
            
            if (planoInd && !hasGestor) {
                lstIncludedServices.add(buildGestorOnline());
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lstIncludedServices;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó serviços inclusos
    */     
    private static CEC_PME_EnvioPedidoRequest.IncludedServices getIncludedServices(OrderItem item){
        CEC_PME_EnvioPedidoRequest.IncludedServices includedServices = new CEC_PME_EnvioPedidoRequest.IncludedServices();
        
        try {
            includedServices.name = item.Product2.Name;
            if(TIPO_PROD_SERVICO.equals(item.Product2.vlocity_cmt__Type__c)){
                includedServices.type = item.Product2.Name;
            } else {
                includedServices.type = item.Product2.vlocity_cmt__Type__c;
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return includedServices;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó lista de serviços adicionais
    */     
    private static List<CEC_PME_EnvioPedidoRequest.AdditionalServices> getListAdditionalServices(OrderItem itemFranquia, List<OrderItem> lstOrderItem){
        List<CEC_PME_EnvioPedidoRequest.AdditionalServices> lstAdditionalServices = new List<CEC_PME_EnvioPedidoRequest.AdditionalServices>();

        try {
            for(OrderItem item : lstOrderItem){
                if(item.Product2.vlocity_cmt__Type__c == TIPO_PROD_GESTOR) {
                    //system.debug(TIPO_PROD_GESTOR + ' ' + itemFranquia.vlocity_cmt__AssetReferenceId__c);
                }
                
                if(item.ReliesOnReferenceId__c == itemFranquia.vlocity_cmt__AssetReferenceId__c){
                    if(!(TIPO_PROD_APARELHO.equals(item.Product2.vlocity_cmt__Type__c) || TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c))){
                        if(item.vlocity_cmt__RecurringTotal__c != 0){ 
                            lstAdditionalServices.add(getAdditionalServices(item));
                        }
                    }
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lstAdditionalServices;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó serviços adicionais
    */     
    private static CEC_PME_EnvioPedidoRequest.AdditionalServices getAdditionalServices(OrderItem item){
        CEC_PME_EnvioPedidoRequest.AdditionalServices additionalServices = new CEC_PME_EnvioPedidoRequest.AdditionalServices();
        
        try {
            additionalServices.name = item.Product2.Name;
            additionalServices.value = String.ValueOf(item.vlocity_cmt__RecurringCharge__c );
            if(TIPO_PROD_SERVICO.equals(item.Product2.vlocity_cmt__Type__c)){
                additionalServices.type = item.Product2.Name;
            } else {
                additionalServices.type = item.Product2.vlocity_cmt__Type__c;
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return additionalServices;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó equipamentos
    */     
    private static CEC_PME_EnvioPedidoRequest.EquipmentDelivery getEquipmentDelivery(Order ord, Account acc){
        CEC_PME_EnvioPedidoRequest.EquipmentDelivery equipmentDelivery = new CEC_PME_EnvioPedidoRequest.EquipmentDelivery();
        
        try {
            equipmentDelivery.type = ord.DeliveryMethod__c;
            equipmentDelivery.address = getAddress(acc);
            equipmentDelivery.receivers = getLstReceivers(ord);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return equipmentDelivery;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó recebedores
    */     
    private static List<CEC_PME_EnvioPedidoRequest.Receivers> getLstReceivers(Order ord){
        List<CEC_PME_EnvioPedidoRequest.Receivers> lstReceivers = new List<CEC_PME_EnvioPedidoRequest.Receivers>();
        
        try {
            if(String.isNotBlank(ord.ReceiverFullName1__c)){
                CEC_PME_EnvioPedidoRequest.Receivers receivers1 = new CEC_PME_EnvioPedidoRequest.Receivers();
                receivers1.name = ord.ReceiverFullName1__c;
                receivers1.rg = ord.ReceiverRG1__c;
                receivers1.phone = getReceiverPhones(ord.ReceiverMobile1__c);
                lstReceivers.add(receivers1);
            }
            
            if(String.isNotBlank(ord.ReceiverFullName2__c)){
                CEC_PME_EnvioPedidoRequest.Receivers receivers2 = new CEC_PME_EnvioPedidoRequest.Receivers();
                receivers2.name = ord.ReceiverFullName2__c;
                receivers2.rg = ord.ReceiverRG2__c;
                receivers2.phone = getReceiverPhones(ord.ReceiverMobile2__c);
                lstReceivers.add(receivers2);
            }
            
            if(String.isNotBlank(ord.ReceiverFullName3__c)){
                CEC_PME_EnvioPedidoRequest.Receivers receivers3 = new CEC_PME_EnvioPedidoRequest.Receivers();
                receivers3.name = ord.ReceiverFullName3__c;
                receivers3.rg = ord.ReceiverRG3__c;
                receivers3.phone = getReceiverPhones(ord.ReceiverMobile3__c);
                lstReceivers.add(receivers3);
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lstReceivers;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do telefone do recebedor
    */     
    private static CEC_PME_EnvioPedidoRequest.Phones getReceiverPhones(String telefone){
        CEC_PME_EnvioPedidoRequest.Phones phone = new CEC_PME_EnvioPedidoRequest.Phones();
        
        try {
            phone.telephoneNumber = telefone.substring(2);
            phone.areaCode = telefone.mid(0,2);
            phone.internationalCode = INTERNATIONAL_CODE;
            phone.contactMediumRole = '';
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return phone;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó cliente
    */     
    private static CEC_PME_EnvioPedidoRequest.Customer getCustomer(Account acc, List<Contact> lstContact, List<AccountContactRelation> lstAccCttRelation, Order ord){
        CEC_PME_EnvioPedidoRequest.Customer customer = new CEC_PME_EnvioPedidoRequest.Customer();
        
        try {
            customer.companyName = acc.Name;
            customer.tradingName = ''; //VERIFICAR
            customer.stateRegistration = acc.StateSubscription__c;
            customer.municipalRegistration = acc.MunicipalSubscription__c;
            customer.cnaes = getListCnaes(acc);
            customer.cnpj = acc.DocumentNumber__c;
            customer.flagNetSubscriber = acc.NETClient__c;
            customer.flagEmbratelSubscriber = acc.EmbratelClient__c;
            customer.customerAccountId = acc.Id;
            customer.contactPhone = getContactPhoneCustomer(ord);
            customer.employeeQuantity = acc.NumberOfEmployeesList__c;
            customer.accountType = String.isBlank(acc.CompanyClass__c) ? EMPRESA_PUBLICA : EMPRESA_PRIVADA;
            customer.accountSegment = Label.CEC_PME_GGD_Segmento;
            customer.territory = acc.Hierarchy__r.Name;//getTerritory(acc.OwnerId);
            customer.Contacts = getListContacts(lstAccCttRelation);
            customer.addresses = getListAddresses(acc);
            customer.billingSpec = getBillingSpec(acc);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return customer;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na pesquisa do telefone do contato
    */     
    private static CEC_PME_EnvioPedidoRequest.ContactPhone getContactPhoneCustomer(Order order){
        CEC_PME_EnvioPedidoRequest.ContactPhone contactPhone = new CEC_PME_EnvioPedidoRequest.ContactPhone();
        
        try {
            contactPhone.telephoneNumber = order.ReceiverMobile1__c;
            
            if(String.isNotBlank(contactPhone.telephoneNumber)) {
                contactPhone.areaCode = contactPhone.telephoneNumber.mid(0,2);
                contactPhone.telephoneNumber = contactPhone.telephoneNumber.substring(2);
            }
            
            contactPhone.internationalCode = INTERNATIONAL_CODE;
            contactPhone.contactMediumRole = '';
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        } 
        
        return contactPhone;
    }
        
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na pesquisa do território
    */     
    private static String getTerritory(String ownerId) {
        List<Member__c> members;
        
        try {
            members = [SELECT Id, Hierarchy__r.Name 
                                       FROM Member__c 
                                       WHERE User__c = :ownerId
                                       AND Hierarchy__r.Name  != null];
            
            if(members.isEmpty()) {
                throw new CEC_PME_EnvioPedido_ServiceException(ERRO_PONTOS + Label.CEC_PME_RPA_Erro_Terr);
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return members.get(0).Hierarchy__r.Name;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó pagamento
    */     
    private static CEC_PME_EnvioPedidoRequest.BillingSpec getBillingSpec(Account acc){
        CEC_PME_EnvioPedidoRequest.BillingSpec billingSpec = new CEC_PME_EnvioPedidoRequest.BillingSpec();
        
        try {
            billingSpec.paymentDayDue = acc.DueDay__c;
            billingSpec.address = getBillingAddress(acc);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return billingSpec;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó endereço de cobrança
    */     
    //Editor: Diogo Braga, adicionei esse método
    private static CEC_PME_EnvioPedidoRequest.Address getBillingAddress(Account varAccount) {
        CEC_PME_EnvioPedidoRequest.Address address = new CEC_PME_EnvioPedidoRequest.Address();
        
        try {
            address.addressType = Label.CEC_PME_GGD_End_Cob;
            address.postcode = varAccount.BillingPostalCode;
            address.streetType = varAccount.CEC_BillingAddressType__c;
            address.streetName = varAccount.BillingStreet;
            address.streetNr = Integer.ValueOf(varAccount.CEC_BillingNumber__c);
            address.complement = varAccount.CEC_BillingComplement__c;
            address.neighborhood = varAccount.CEC_BillingNeighborhood__c;
            address.cityName = varAccount.BillingCity;
            address.stateAbbreviation = varAccount.BillingState;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return address;
    }
       
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó endereço
    */     
    private static CEC_PME_EnvioPedidoRequest.Address getAddress(Account acc){
        CEC_PME_EnvioPedidoRequest.Address address = new CEC_PME_EnvioPedidoRequest.Address();
        
        try {
            address.addressType = Label.CEC_PME_RPA_End_Ent;
            address.postcode = acc.ShippingPostalCode;
            address.streetType = acc.CEC_ShippingAddressType__c;
            address.streetName = acc.ShippingStreet;
            address.streetNr = Integer.ValueOf(acc.CEC_ShippingNumber__c);
            address.complement = acc.CEC_ShippingComplement__c;
            address.neighborhood = acc.CEC_ShippingNeighborhood__c;
            address.cityName = acc.ShippingCity;
            address.stateAbbreviation = acc.ShippingState;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return address;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento da lista de endereços
    */     
    private static List<CEC_PME_EnvioPedidoRequest.Addresses> getListAddresses(Account acc){
        List<CEC_PME_EnvioPedidoRequest.Addresses> lstAddresses = new List<CEC_PME_EnvioPedidoRequest.Addresses>();
        
        try {
            lstAddresses.add(getAddresses(acc));
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lstAddresses;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do endereço
    */     
    private static CEC_PME_EnvioPedidoRequest.Addresses getAddresses(Account acc){
        CEC_PME_EnvioPedidoRequest.Addresses addresses = new CEC_PME_EnvioPedidoRequest.Addresses();
        
        try {
            addresses.addressType = Label.CEC_PME_RPA_End_Pad;
            addresses.postcode = acc.ShippingPostalCode;
            addresses.streetType = acc.CEC_ShippingAddressType__c;
            addresses.streetName = acc.ShippingStreet;
            addresses.streetNr = Integer.ValueOf(acc.CEC_ShippingNumber__c);
            addresses.complement = acc.CEC_ShippingComplement__c;
            addresses.neighborhood = acc.CEC_ShippingNeighborhood__c;
            addresses.cityName = acc.ShippingCity;
            addresses.stateAbbreviation = acc.ShippingState;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return addresses;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó lista de administradores
    */     
    private static List<CEC_PME_EnvioPedidoRequest.Contacts> getListContacts(List<AccountContactRelation> lstAccCttRelation){
        List<CEC_PME_EnvioPedidoRequest.Contacts> lstContacts = new List<CEC_PME_EnvioPedidoRequest.Contacts>();
        
        try {
            for(AccountContactRelation accCttRelation : lstAccCttRelation){
                if(String.isNotEmpty(accCttRelation.Contact.DocumentNumber__c)){
                    lstContacts.add(getContacts(accCttRelation));            
                }
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lstContacts;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó administradores
    */     
    private static CEC_PME_EnvioPedidoRequest.contacts getContacts(AccountContactRelation accCttRelation){
        CEC_PME_EnvioPedidoRequest.Contacts contacts = new CEC_PME_EnvioPedidoRequest.Contacts();
        
        try {
            contacts.title = TITULO; //Não tempos de-para no salesforce, mandar valor fixo.
            contacts.firstName = accCttRelation.Contact.FirstName;
            contacts.lastName = accCttRelation.Contact.LastName;
            contacts.cpf = accCttRelation.Contact.DocumentNumber__c;
            contacts.gender = accCttRelation.Contact.Gender__c;
            contacts.birthDate = accCttRelation.Contact.Birthdate != null ? String.Valueof(accCttRelation.Contact.Birthdate) + HORA_ANIVERSARIO : null;
            contacts.phones = getListPhones(accCttRelation);
            contacts.emailAddress = accCttRelation.Email__c;
            contacts.isLegalRepresentative = true;
            contacts.jobTitle = accCttRelation.roles;
            contacts.occupation = accCttRelation.roles;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return contacts;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento da lista de telefones
    */     
    private static List<CEC_PME_EnvioPedidoRequest.Phones> getListPhones(AccountContactRelation accCttRelation){
        List<CEC_PME_EnvioPedidoRequest.Phones> lstPhones = new List<CEC_PME_EnvioPedidoRequest.Phones>();

        try {
            if(String.isNotBlank(accCttRelation.MobilePhone__c)) {
                CEC_PME_EnvioPedidoRequest.Phones mobilePhone = new CEC_PME_EnvioPedidoRequest.Phones();
                mobilePhone.telephoneNumber = accCttRelation.MobilePhone__c.substring(2);
                mobilePhone.areaCode = accCttRelation.MobilePhone__c.mid(0,2);
                mobilePhone.internationalCode = INTERNATIONAL_CODE;
                mobilePhone.contactMediumRole = CONST_MOBILE_PHONE;
                lstPhones.add(mobilePhone);
            }
            
            if(String.isNotBlank(accCttRelation.Phone__c)) {
                CEC_PME_EnvioPedidoRequest.Phones phones = new CEC_PME_EnvioPedidoRequest.Phones();
                phones.telephoneNumber = accCttRelation.Phone__c.substring(2);
                phones.areaCode = accCttRelation.Phone__c.mid(0,2);
                phones.internationalCode = INTERNATIONAL_CODE;
                phones.contactMediumRole = CONST_HOME_PHONE;
                lstPhones.add(phones);
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lstPhones;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do telefone do administrador
    */     
    private static CEC_PME_EnvioPedidoRequest.ContactPhone getContactPhone(AccountContactRelation accCttRelation){
        CEC_PME_EnvioPedidoRequest.ContactPhone contactPhone = new CEC_PME_EnvioPedidoRequest.ContactPhone();
        
        try {
            if(String.isNotBlank(contactPhone.telephoneNumber)) {
                contactPhone.telephoneNumber = contactPhone.telephoneNumber.substring(2);
                contactPhone.areaCode = contactPhone.telephoneNumber.mid(0,2);
            }
            contactPhone.internationalCode = INTERNATIONAL_CODE;
            contactPhone.contactMediumRole = CONST_MOBILE_PHONE;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return contactPhone;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento da lista de CNAEs
    */     
    private static List<CEC_PME_EnvioPedidoRequest.Cnaes> getListCnaes(Account acc){
        List<CEC_PME_EnvioPedidoRequest.Cnaes> lstCnaes = new List<CEC_PME_EnvioPedidoRequest.Cnaes>();
        
        try {
            if(String.isNotBlank(acc.CNAE__c)){
                CEC_PME_EnvioPedidoRequest.Cnaes cnaes = new CEC_PME_EnvioPedidoRequest.Cnaes();
                cnaes.type = TIPO_CNAE;
                cnaes.code = acc.CNAE__c;
                cnaes.description = '';
                lstCnaes.add(cnaes);
            }
            
            if(String.isNotBlank(acc.CNAE2__c)){
                CEC_PME_EnvioPedidoRequest.Cnaes cnaes2 = new CEC_PME_EnvioPedidoRequest.Cnaes();
                cnaes2.type = TIPO_CNAE;
                cnaes2.code = acc.CNAE2__c;
                cnaes2.description = '';
                lstCnaes.add(cnaes2);
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return lstCnaes;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó parceiro
    */     
    private static CEC_PME_EnvioPedidoRequest.SalesParty getSalesParty(User usr, String comercialSegment){
        CEC_PME_EnvioPedidoRequest.SalesParty salesParty = new CEC_PME_EnvioPedidoRequest.SalesParty();
        
        try {
            salesParty.salesmanId = usr.ConsultantCode__c;
            salesParty.salesmanJobTitle = GERENTE_CONTA;
            salesParty.salesmanName = usr.Name;
            salesParty.companyName = usr.Resale__c;
            salesParty.cnpj =  usr.CNPJResale__c;
            salesParty.vendorId = usr.ResaleCode__c;
            salesParty.salesChannelId = usr.Channel__c;
            salesParty.comercialSegment = comercialSegment;
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return salesParty;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do mapa de cores
    */     
    private static List<OrderItem> generateMapSAPColors(List<OrderItem> lstOrderItem){
        List<OrderItem> lstDeviceColors = new List<OrderItem>();
        Set<String> setIdProduct = new Set<String>();
        
        try {
            for(OrderItem item : lstOrderItem){
                if(TIPO_PROD_APARELHOS.equals(item.Product2.vlocity_cmt__Type__c)){
                    setIdProduct.add(item.Product2Id);
                }
            }
            
            return [SELECT Product2.Manufacturer__c, Product2.Model__c, Product2.Color__c, Product2.SAPID__c FROM OrderItem WHERE Id =: setIdProduct];
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }        
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do mapa de cores
    */     
    private static Map<String, String> getMapColorSapId(List<OrderItem> listOrderItem) {
        Map<String, String> mapColorIdSap = new Map<String, String>();
        
        List<String> listManufacturers = new List<String>();
        List<String> listModels = new List<String>();
        
        try{
            for(OrderItem orderItem : listOrderItem) {
                if(TIPO_PROD_APARELHOS.equals(orderItem.Product2.vlocity_cmt__Type__c)) {
                    listManufacturers.add(orderItem.Product2.Manufacturer__c);
                    listModels.add(orderItem.Product2.Model__c);
                }
            }
            
            List<Product2> listProduct2 = [SELECT Id, 
                                           Manufacturer__c, 
                                           Model__c,
                                           SAPID__c,
                                           Color__c
                                           FROM Product2 
                                           WHERE Manufacturer__c IN :listManufacturers 
                                           AND Model__c IN :listModels];
            
            for(Product2 product2 : listProduct2) {
                mapColorIdSap.put(product2.Manufacturer__c + product2.Model__c + product2.Color__c, product2.SAPID__c);
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return mapColorIdSap;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na pesquisa do usuário
    */     
    private static User getUser(Order ord){
        try {
            return [SELECT id,
                    ConsultantCode__c,
                    Resale__c,
                    CNPJResale__c,
                    ResaleCode__c,
                    FirstName,
                    LastName,
                    Channel__c,
                    Profile.Name,
                    name
                    FROM User
                    Where id =: ord.CreatedById];
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }            
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na pesquisa dos produtos do pedido
    */     
    private static List<OrderItem> getListOrderItem(Order ord){
        try {
            return [SELECT id,
                    ICCID__c,
                    Quantity,
                    Product2.ProductCode,
                    TradeIn__c,
                    vlocity_cmt__RecurringTotal__c,
                    Product2.vlocity_cmt__Type__c,
                    Product2.vlocity_cmt__SubType__c,
                    vlocity_cmt__AssetReferenceId__c,
                    Product2.Name,
                    TypeOfRequest__c,
                    ParentGroup__c,
                    Group__c,
                    Subgroup__c,
                    ReliesOnReferenceId__c,
                    PortabilityNumber__c,
                    Operator__c,
                    Product2.Model__c,
                    Product2.Manufacturer__c,
                    DeviceSecondOptionColor__c,
                    AnotherDeviceColor__c,
                    Product2.Color__c,
                    Product2.SAPID__c,
                    TotalPrice,
                    IMEI__c,
                    SAP_ID__c,
                    vlocity_cmt__RecurringCharge__c,
                    DonatorName__c,
                    DonatorDocumentNumber__c,
                    DonatorPhone__c,
                    DonatorEmail__c,
                    BonusValue__c,
                    vlocity_cmt__RecurringDiscountPrice__c,
                    UnitPrice
                    FROM OrderItem
                    WHERE orderId =: ord.id];
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }            
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na pesquisa do pedido
    */     
    private static Order getOrder(String idPedido){
        try {
            return [SELECT id,
                    AccountId,
                    CreatedById,
                    OrderNumber,
                    Payment_Term__c,
                    DeliveryMethod__c,
                    ReceiverFullName1__c,
                    ReceiverFullName2__c,
                    ReceiverFullName3__c,
                    ReceiverRG1__c,
                    ReceiverRG2__c,
                    ReceiverRG3__c,
                    ReceiverMobile1__c,
                    ReceiverMobile2__c,
                    ReceiverMobile3__c,
                    Related_Contacts__c,
                    LD21__c
                    FROM Order
                    WHERE id =: idPedido];
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }            
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na pesquisa da conta
    */     
    private static Account getAccount(Order ord) {
        try {
            return [SELECT Id,
                    Name,
                    StateSubscription__c,
                    MunicipalSubscription__c,
                    DocumentNumber__c,
                    NETClient__c,
                    EmbratelClient__c,
                    NumberOfEmployeesList__c,
                    CompanyClass__c,
                    CommercialSegment__c,
                    Hierarchy__r.Name,
                    ShippingPostalCode,
                    ShippingStreet,
                    ShippingCity,
                    ShippingState,
                    CEC_ShippingNeighborhood__c,
                    CEC_ShippingComplement__c,
                    CEC_ShippingNumber__c,
                    CEC_ShippingAddressType__c,
                    CNAE__c,
                    CNAE2__c,
                    DueDay__c,
                    OwnerId,
                    BillingPostalCode,
                    CEC_BillingAddressType__c,
                    BillingStreet,
                    CEC_BillingNumber__c,
                    CEC_BillingComplement__c,
                    CEC_BillingNeighborhood__c,
                    BillingCity,
                    BillingState,
                    Phone
                    FROM Account
                    WHERE id =: ord.AccountId];
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na pesquisa de contatos
    */     
    private static List<Contact> getListContact(Account acc){
        try {
            return [SELECT Id
                    FROM Contact
                    WHERE AccountId =: acc.Id];
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }            
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado na pesquisa de administradores
    */     
    private static List<AccountContactRelation> getListAccCttRelation(Set<Id> setIds){
        try {
            return [SELECT Id,
                    AccountId,
                    ContactId,
                    Roles,
                    Email__c,
                    MobilePhone__c,
                    Phone__c,
                    ResponsibleForTheSignature__c,
                    Contact.FirstName,
                    Contact.LastName,
                    Contact.DocumentNumber__c,
                    Contact.Gender__c,
                    Contact.Birthdate,
                    Contact.Name
                    
                    FROM AccountContactRelation
                    WHERE Id =: setIds];
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }            
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Metodo que recebe uma string com os ids de AccountContactRelation, concatenados e separados por ponto-e-virgula, 
    * e os coloca em um Set de Ids para retorno
    */
    private static Set<Id> getRelatedContactIdList(String ids) {
        if (ids == null || String.isBlank(ids)) {
            return new Set<Id>();
        }
        // Filtrando o ultimo ponto-e-virgula caso haja:
        ids = ids.endsWith(';') ? ids.substring(0, ids.length()-1) : ids;
        List<String> idList = ids.split(';');
        Set<Id> idSet = new Set<Id>();
        try {
            for (String rcId : idList) {
                // Validação de ID Salesforce:
                Boolean isValid = Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(rcId).matches();
                if (isValid) idSet.add(Id.valueOf(rcId));
            }
        }
        catch (Exception ex) {
            System.debug('>> Exception <<\n'
                         + 'Cause: '                                   + ex.getCause()                                                       + '\n'
                         + 'Line: '                    + ex.getLineNumber()                                     + '\n'
                         + 'Message: '                             + ex.getMessage()                                          + '\n'
                         + 'Stacktrace: '         + ex.getStackTraceString()                   + '\n'
                        );
        }
        
        return idSet;
    }  
    
 	/*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó oferta especial
    */     
    private static CEC_PME_EnvioPedidoRequest.SpecialOffer getSpecialOffer(OrderItem item, Account acc, Integer lineDetails){
        CEC_PME_EnvioPedidoRequest.SpecialOffer specialOffer;
        
        try {
            if (item.BonusValue__c != null || item.vlocity_cmt__RecurringDiscountPrice__c != null) {
                specialOffer = new CEC_PME_EnvioPedidoRequest.SpecialOffer();
                    
            	specialOffer.bonus = getBonus(item, acc);
            	specialOffer.progressiveDiscount = getProgressiveDiscount(item, lineDetails);                
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return specialOffer;
    } 
    
 	/*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó bonus
    */     
    private static CEC_PME_EnvioPedidoRequest.Bonus getBonus(OrderItem item, Account acc){
        CEC_PME_EnvioPedidoRequest.Bonus bonus;
        
        try {
            if (item.BonusValue__c != null) {
                bonus = new CEC_PME_EnvioPedidoRequest.Bonus();                
                bonus.isDoubleBonus = acc.NETClient__c || acc.EmbratelClient__c ? true : false;
                bonus.value = item.BonusValue__c;
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return bonus;
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Utilizado no preenchimento do nó desconto progressivo
    */     
    private static CEC_PME_EnvioPedidoRequest.ProgressiveDiscount getProgressiveDiscount(OrderItem item, Integer lineDetails){
        CEC_PME_EnvioPedidoRequest.ProgressiveDiscount progressiveDiscount;
        
        try {
            if (item.vlocity_cmt__RecurringDiscountPrice__c != null) {
                progressiveDiscount = new CEC_PME_EnvioPedidoRequest.ProgressiveDiscount();
                //progressiveDiscount.quantity = item.Quantity;
                progressiveDiscount.quantity = lineDetails;
                progressiveDiscount.value = item.vlocity_cmt__RecurringDiscountPrice__c;
            }
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }             
        
        return progressiveDiscount;
    } 
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Build gestor online US 24075
    */    
    private static CEC_PME_EnvioPedidoRequest.IncludedServices buildGestorOnline() {
        CEC_PME_EnvioPedidoRequest.IncludedServices includedServiceGO = new CEC_PME_EnvioPedidoRequest.IncludedServices();
        
        try {
            includedServiceGO.name = Label.CEC_PME_GestorOnline; //'Gestor Online';
            includedServiceGO.type = Label.CEC_PME_GestorOnline; //'Gestor Online';
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        return includedServiceGO;
    }

	/*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Remover tags do json
    */    
    private static void removeAttributes(Map<String,Object> jsonObj)  {
        for(String key : jsonObj.keySet()) {                       
            if (jsonObj.get(key) == null) {
                if (key == 'progressiveDiscount' || key == 'bonus') {
                	jsonObj.remove(key);                    
                }
            } else {
                if(jsonObj.get(key) instanceof Map<String,Object>) {
                    removeAttributes((Map<String,Object>)jsonObj.get(key));
                }
                if(jsonObj.get(key) instanceof List<Object>) {
                    for(Object listItem : (List<Object>)jsonObj.get(key)) {
                        if(listItem instanceof Map<String,Object>)  {
                            removeAttributes((Map<String,Object>)listItem);
                        }
                    }
                }
            }
        }  
    }     
}