/*
* Autor: Otávio Fonseca - Deloitte
* Data: 03/06/2019
* Descrição: CEC FASE 1 + SQUAD PME: Classe utilizada para chamada do serviço do GGD.
*/

public without sharing class CEC_PME_SalesDocumentsService 
{
    public class CEC_PME_SalesDocumentsServiceException extends Exception{}
    private CEC_PME_SalesDocumentsService(){}
    
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
    public static String getDocuments(String idPedido)
    {
        
        if(String.isBlank(idPedido))
        {
            return Label.CEC_PME_GGD_Id_Pedido_Branco;
        }
        
        try
        {
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
            //System.debug('varRequest >> '+json.serialize(varRequest));
            System.debug('varRequestPretty >> '+json.serializePretty(varRequest));
            
            HttpResponse varResponse = CEC_PME_HttpReq.sendReqBody(NOME_SERVICO, endPointMethod, varRequest);
            
            System.Debug('Response JSON: ' + varResponse.getBody());
            System.debug(varResponse.getStatusCode());          
           
            if(varResponse.getStatusCode() == 202 || varResponse.getStatusCode() == 200)
            {
                Response objResponse = (Response)JSON.deserialize(varResponse.getBody(), Response.class);
                System.debug('resp >> '+objResponse);
                
                List<ContentVersion> lstContentVersion = new List<ContentVersion>();
                List<ContentDocumentLink> lstContentLink = new List<ContentDocumentLink>();
                
                for(SalesDocuments varDocument : objResponse.data.salesDocuments)
                {
                    if(String.isNotBlank(varDocument.content))
                    {
                        ContentVersion varContentVersion = new ContentVersion();
                        varContentVersion.Title = varDocument.documentName;
                        varContentVersion.PathOnClient = varDocument.documentName + CONST_PDF;
                        varContentVersion.VersionData = EncodingUtil.base64Decode(varDocument.content);
                        varContentVersion.Origin = CONT_VER_ORIGEM;
                        varContentVersion.IsMajorVersion = true;
                        
                        lstContentVersion.add(varContentVersion);
                    }
                }
                
                if(!lstContentVersion.isEmpty())
                {
                    Database.insert(lstContentVersion);
                    
                    Set<Id> setIdsContentVersion = new Set<Id>();
                    
                    for(ContentVersion varContentVersion : lstContentVersion)
                    {
                        setIdsContentVersion.add(varContentVersion.Id);
                    }
                    
                    List<ContentVersion> lstInsertedContentVersion = [SELECT Id, ContentDocumentId 
                                                                      FROM ContentVersion 
                                                                      WHERE Id IN: setIdsContentVersion];
                    system.debug('lstInsertedContentVersion ' + lstInsertedContentVersion);
                    
                    for(ContentVersion varContentVersion : lstInsertedContentVersion)
                    {
                        ContentDocumentLink varContentLink = new ContentDocumentLink();
                        varContentLink.LinkedEntityId = idPedido;
                        varContentLink.ContentDocumentId = varContentVersion.ContentDocumentId;
                        varContentLink.ShareType = CONT_LINK_COMPART;
                        varContentLink.Visibility = CONT_LINK_VISIBILIDADE;
                        
                        lstContentLink.add(varContentLink);
                    }
                    
                    if(!lstContentLink.isEmpty())
                    {
                        Database.insert(lstContentLink);
                    }
                }
                
        		return varResponse.getBody();
            } else if(varResponse.getStatusCode() == 400) {
                return varResponse.getBody();
            } else 
            {
                throw new CEC_PME_SalesDocumentsServiceException(varResponse.getBody());
            }
        } catch (Exception e)
        {
            System.debug('exception >> '+e.getMessage());
            System.debug('exception trace >> '+e.getStackTraceString());
            
            return 'Erro na integração: ' + e.getMessage() + '; ' + e.getStackTraceString();
        }
    }
    
    public class Response
    {
        public String apiVersion										{ get; set; }
        public String transactionId 									{ get; set; }
        public Data data 												{ get; set; }
    } 
    
    public class Data
    {
        public List<SalesDocuments> salesDocuments 						{ get; set; }
    }
    
    public class SalesDocuments
    {
        public  String documentId 										{ get; set; }
        public  String documentName  									{ get; set; }
        public  String content  										{ get; set; }
    }	
}