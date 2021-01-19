/*
* Autor: Otávio Fonseca - Deloitte
* Data: 03/06/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe utilizada para chamada do serviço do GGD.
*/

public without sharing class CEC_PME_SalesDocumentsService 
{
    public class CEC_PME_SalesDocumentsServiceException extends Exception{}
    private CEC_PME_SalesDocumentsService() {}
    
    static final String NOME_SERVICO = 'CEC_PME_SalesDocuments';
    static final String CONST_PDF = '.pdf';
    static final String CONT_VER_ORIGEM = 'H';
    static final String CONT_LINK_COMPART = 'I';
    static final String CONT_LINK_VISIBILIDADE = 'AllUsers';
    
    /*
* Autor: Otávio Fonseca
* Descrição: CEC FASE 1 + SQUAD PME: Utilizado na montagem do json com os dados do pedido a ser enviado ao GGD.
* Com o retorno base64 recebido, cria os arquivos e anexa ao pedido no Salesforce.
*/     
    @AuraEnabled
    public static String getDocuments(String idPedido) {
        system.debug('idPedido*** ' + idPedido);
        if(String.isBlank(idPedido)) {
            return Label.CEC_PME_GGD_Id_Pedido_Branco;
        }
        
        /*try
{*/
        String endPointMethod = '';
        
        ServiceParameter__c param = ServiceParameter__c.getInstance(NOME_SERVICO);
        endPointMethod = param.EndPoint__c;
        
        CEC_PME_SalesDocumentsPayload createPayload = new CEC_PME_SalesDocumentsPayload();
        
        //request
        CEC_PME_SalesDocumentsRequest varRequest = new CEC_PME_SalesDocumentsRequest();
        varRequest.apiVersion = createPayload.getApiVersion();
        
        //data
        CEC_PME_SalesDocumentsRequest.Data data = new CEC_PME_SalesDocumentsRequest.Data();
        
        //SalesDocuments
        CEC_PME_SalesDocumentsRequest.SalesDocuments salesDocs = new CEC_PME_SalesDocumentsRequest.SalesDocuments();
        
        //pedido
        Order order = CEC_PME_SalesDocumentsQuerys.getOrder(idPedido);
        varRequest.transactionId = createPayload.getTransactionId(order.OrderNumber);
        
        //itens do pedido
        List<OrderItem> orderItens = CEC_PME_SalesDocumentsQuerys.getOrderItens(idPedido);
        System.debug('orderItens >> '+orderItens.size());
        
        //conta da empresa
        Account customerAccount = CEC_PME_SalesDocumentsQuerys.getCustomerAccount(order.AccountId);
        
        //usuário de vendas
        User salesmanUser = CEC_PME_SalesDocumentsQuerys.getSalesUser(Order.OwnerId);
        
        //contatos/administradores
        Set<Id> setAdmins = CEC_PME_SalesDocumentsPayload.getRelatedContactIdList(order.Related_Contacts__c);
        List<AccountContactRelation> admins = CEC_PME_SalesDocumentsQuerys.getAccountRelations(setAdmins);
        
        //Score
        Set<String> setRange = CEC_PME_SalesDocumentsPayload.getRange(orderItens);
        List<Product2> products = CEC_PME_SalesDocumentsQuerys.getRange(setRange);
        Map<String, String> mapRange = CEC_PME_SalesDocumentsPayload.getMapRange(products);               
        
        //sales party
        salesDocs.salesParty = createPayload.getSalesParty(salesmanUser, customerAccount.CommercialSegment__c);
        
        //customer
        CEC_PME_SalesDocumentsRequest.customer customer = createPayload.getCustomer(customerAccount);
        
        //telefone de contato
        customer.contactPhone = createPayload.getCustomerContactPhone(customerAccount);
        
        //admins
        customer.administrators = createPayload.getAdmins(admins);
        
        //endereços
        customer.addresses = createPayload.getAddresses(customerAccount);
        customer.commercialReferences = createPayload.getCommercialReferences();
        customer.billingSpec = createPayload.getBillingSpec(customerAccount);
        
        //customer
        salesDocs.customer = customer;
        
        //recebedores dos equipamentos
        salesDocs.equipmentReceivers = createPayload.getEquipReceivers(order);
        
        //planos
        salesDocs.plans = createPayload.getPlans(orderItens, mapRange, customerAccount.CommercialSegment__c);
        
        //resumo
        salesDocs.summary =  createPayload.getSummary(order.Payment_Term__c);
        
        //
        salesDocs.subscriberAcceptances = createPayload.getSubAcceptances(order);
        
        //data
        data.SalesDocuments = new List<CEC_PME_SalesDocumentsRequest.SalesDocuments>();
        data.SalesDocuments.add(salesDocs);
        varRequest.data = data;
        
        //Adicionar gestor online quando plano individual US 24075
        if(salesDocs.plans != null) {
            for(CEC_PME_SalesDocumentsRequest.Plans plan : salesDocs.plans) {
                createPayload.addGestorOnline(plan);
            } 
        }
        
        //requisição
        SOLAR_IntegrationREST integrationREST = new SOLAR_IntegrationREST();
        HttpResponse varResponse = integrationREST.sendRequest(NOME_SERVICO, removeFomattedFields(varRequest));
        SOLAR_IntegrationMessageDAO integrationMessageDAO = new SOLAR_IntegrationMessageDAO(NOME_SERVICO);
        system.debug('varResponse ' + varResponse.getStatusCode() + varResponse.getBody());
        integrationMessageDAO.doSelect();
        
        if(varResponse.getStatusCode() == 202 || varResponse.getStatusCode() == 200) {
            Response objResponse = (Response)JSON.deserialize(varResponse.getBody(), Response.class);
            System.debug('resp >> '+objResponse);
            
            List<ContentVersion> lstContentVersion = new List<ContentVersion>();
            List<ContentDocumentLink> lstContentLink = new List<ContentDocumentLink>();
            
            for(SalesDocuments varDocument : objResponse.data.salesDocuments) {
                if(String.isNotBlank(varDocument.content)) {
                    ContentVersion varContentVersion = new ContentVersion();
                    varContentVersion.Title = varDocument.documentName;
                    varContentVersion.PathOnClient = varDocument.documentName + CONST_PDF;
                    varContentVersion.VersionData = EncodingUtil.base64Decode(varDocument.content);
                    varContentVersion.Origin = CONT_VER_ORIGEM;
                    varContentVersion.IsMajorVersion = true;
                    
                    if(!varDocument.documentName.equals('ANEXO AO CONTRATO DE PERMANENCIA') && !varDocument.documentName.equals('TERMO DE CONTRATACAO PESSOA JURIDICA')) {                          
                        lstContentVersion.add(varContentVersion);
                    }
                }
            }
            
            lstContentVersion.add(getDocumentoTCPJ(idPedido));
            lstContentVersion.add(getDocumentoContratoPermanencia(idPedido));
            
            if(!lstContentVersion.isEmpty()) {
                Database.insert(lstContentVersion);
                
                Set<Id> setIdsContentVersion = new Set<Id>();
                
                for(ContentVersion varContentVersion : lstContentVersion) {
                    setIdsContentVersion.add(varContentVersion.Id);
                }
                
                List<ContentVersion> lstInsertedContentVersion = [SELECT Id, ContentDocumentId 
                                                                  FROM ContentVersion 
                                                                  WHERE Id IN: setIdsContentVersion];
                system.debug('lstInsertedContentVersion ' + lstInsertedContentVersion);
                
                for(ContentVersion varContentVersion : lstInsertedContentVersion) {
                    ContentDocumentLink varContentLink = new ContentDocumentLink();
                    varContentLink.LinkedEntityId = idPedido;
                    varContentLink.ContentDocumentId = varContentVersion.ContentDocumentId;
                    varContentLink.ShareType = CONT_LINK_COMPART;
                    varContentLink.Visibility = CONT_LINK_VISIBILIDADE;
                    
                    lstContentLink.add(varContentLink);
                }
                
                if(!lstContentLink.isEmpty()) {
                    Database.insert(lstContentLink);
                }
            }
            
            return varResponse.getBody();
        } else {
            String messageCode = integrationMessageDAO.getCodeMessageByStatusCode(varResponse.getStatusCode());
            String stdMessage = SOLAR_IntegrationMessageDAO.STD_MESSAGE;
            throw new CEC_PME_SalesDocumentsServiceException(stdMessage.replace('{!messageCode}', messageCode));
        }
    }
    
    public static String removeFomattedFields(CEC_PME_SalesDocumentsRequest varRequest) {
        Map<String, Object> mapRequest = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(varRequest));
        Map<String, Object> mapData = (Map<String, Object>) mapRequest.get('data');
        List<Object> listSalesDocuments = (List<Object>) mapData.get('salesDocuments');
        for(Object objSalesDocuments : listSalesDocuments) {
            Map<String, Object> mapSalesDocuments = (Map<String, Object>) objSalesDocuments;
            
            Map<String, Object> mapSummary = (Map<String, Object>) mapSalesDocuments.get('summary');
            mapSummary.remove('formattedTotalValueOfEquipments');
            mapSummary.remove('formattedTotalValueOfServices');
            
            Map<String, Object> mapCustomer = (Map<String, Object>) mapSalesDocuments.get('customer');
            List<Object> listAdministrators = (List<Object>) mapCustomer.get('administrators');
            for(Object objAdministrators : listAdministrators) {
                Map<String, Object> mapAdministrators = (Map<String, Object>) objAdministrators;
                mapAdministrators.remove('formattedCpf');
                List<Object> listPhones = (List<Object>) mapAdministrators.get('phones');
                for(Object objPhones : listPhones) {
                    Map<String, Object> mapPhones = (Map<String, Object>) objPhones;
                    mapPhones.remove('formattedNumber');
                }
            }
            
            List<Object> listEquipmentReceivers = (List<Object>) mapSalesDocuments.get('equipmentReceivers');
            for(Object objEquipmentReceivers : listEquipmentReceivers) {
                Map<String, Object> mapEquipmentReceivers = (Map<String, Object>) objEquipmentReceivers;
                Map<String, Object> mapPhones= (Map<String, Object>) mapEquipmentReceivers.get('phones');
                mapPhones.remove('formattedNumber');
            }
            
            List<Object> listPlans = (List<Object>) mapSalesDocuments.get('plans');
            for(Object objPlans : listPlans) {
                Map<String, Object> mapPlans = (Map<String, Object>) objPlans;
                mapPlans.remove('formattedName');
                
                List<Object> listGroups = (List<Object>) mapPlans.get('groups');
                for(Object objGroups : listGroups) {
                    Map<String, Object> mapGroups = (Map<String, Object>) objGroups;
                    mapGroups.remove('formattedValue');
                    mapGroups.remove('listBonus');
                    mapGroups.remove('formattedProgressiveDiscount');
                    mapGroups.remove('formattedValueDiscount');
                    mapGroups.remove('formattedKit');
                    mapGroups.remove('hasLineDetails');
                    mapGroups.remove('listFormattedDevice');
                    
                    List<Object> listPlugins = (List<Object>) mapGroups.get('plugins');
                    if(listPlugins != null) {
                        for(Object objPlugins : listPlugins) {
                            Map<String, Object> mapPlugins = (Map<String, Object>) objPlugins;
                            mapPlugins.remove('formattedValue');
                        }
                    }
                    
                    List<Object> listAdditionalServices = (List<Object>) mapGroups.get('additionalServices');
                    for(Object objAdditionalServices : listAdditionalServices) {
                        Map<String, Object> mapAdditionalServices = (Map<String, Object>) objAdditionalServices;
                        mapAdditionalServices.remove('formattedValue');
                    }
                    
                    List<Object> listLineDetails = (List<Object>) mapGroups.get('lineDetails');
                    for(Object objLineDetails : listLineDetails) {
                        Map<String, Object> mapLineDetails = (Map<String, Object>) objLineDetails;
                        mapLineDetails.remove('formattedTelephoneNumber');
                        mapLineDetails.remove('formattedOperator');
                        
                        Map<String, Object> mapDonor = (Map<String, Object>) mapLineDetails.get('donor');
                        mapDonor.remove('formattedCpf');
                        List<Object> listPhones = (List<Object>) mapDonor.get('phones');
                        if(listPhones != null) {
                            for(Object objPhones : listPhones) {
                                Map<String, Object> mapPhones = (Map<String, Object>) objPhones;
                                mapPhones.remove('formattedNumber');
                            }
                        }
                        
                        Map<String, Object> mapSimcard = (Map<String, Object>) mapLineDetails.get('simcard');
                        mapSimcard.remove('formattedIccid');
                        mapSimcard.remove('formattedValue');
                        mapSimcard.remove('formattedBaseValue');
                        
                        Map<String, Object> mapDevice = (Map<String, Object>) mapLineDetails.get('device');
                        if(mapDevice != null) {
                            mapDevice.remove('formattedValue');
                            mapDevice.remove('formattedScore');
                            mapDevice.remove('formattedRange');
                            mapDevice.remove('formattedBaseValue');
                        }
                    }
                }
            }
        }
        
        system.debug('Request body ' + JSON.serialize(mapRequest));
        return JSON.serialize(mapRequest);
    }
    
    public static ContentVersion getDocumentoContratoPermanencia(String orderId) {
        
        ContentVersion varContentVersion = new ContentVersion();
        
        PageReference pdf = Page.SOLAR_PME_ContratoPermanencia;
        pdf.getParameters().put('id', orderId);
        
        varContentVersion.Title = 'ANEXO AO CONTRATO DE PERMANENCIA';
        varContentVersion.PathOnClient = 'ANEXO AO CONTRATO DE PERMANENCIA' + CONST_PDF;
        if(Test.isRunningTest()) {
            varContentVersion.VersionData = blob.valueOf('teste'); 
        } else {
            varContentVersion.VersionData = pdf.getContent(); 
        }
        
        varContentVersion.Origin = CONT_VER_ORIGEM;
        varContentVersion.IsMajorVersion = true;
        
        return varContentVersion;
    }
    
    public static ContentVersion getDocumentoTCPJ(String orderId) {
        
        ContentVersion varContentVersion = new ContentVersion();
        
        PageReference pdf = Page.SOLAR_PME_TcpjPdf;
        pdf.getParameters().put('id', orderId);
        
        varContentVersion.Title = 'TERMO DE CONTRATACAO PESSOA JURIDICA';
        varContentVersion.PathOnClient = 'TERMO DE CONTRATACAO PESSOA JURIDICA' + CONST_PDF;
        if(Test.isRunningTest()) {
            varContentVersion.VersionData = blob.valueOf('teste'); 
        } else {
            varContentVersion.VersionData = pdf.getContent(); 
        }
        varContentVersion.Origin = CONT_VER_ORIGEM;
        varContentVersion.IsMajorVersion = true;
        
        return varContentVersion;
    }
    
    public class Response {
        public String apiVersion {get; set;}
        public String transactionId {get; set;}
        public Data data {get; set;}
    } 
    
    public class Data {
        public List<SalesDocuments> salesDocuments {get; set;}
    }
    
    public class SalesDocuments {
        public  String documentId {get; set;}
        public  String documentName {get; set;}
        public  String content {get; set;}
    }	
}