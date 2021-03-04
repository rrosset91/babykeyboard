public without sharing class SOLAR_PME_Contratos {
    public class ContratosException extends Exception {}
    
    static final String CONST_PDF = '.pdf';
    static final String CONT_VER_ORIGEM = 'H';
    static final String CONT_LINK_COMPART = 'I';
    static final String CONT_LINK_VISIBILIDADE = 'AllUsers';
    static final String CONTRATO_SMP = 'CONTRATO SMP';
    static final String SUMARIO_INDIVIDUAL = 'SUMÁRIO CLARO TOTAL INDIVIDUAL (Plano Claro Life)';
    static final String SUMARIO_COMPARTILHADO = 'SUMÁRIO CLARO TOTAL COMPARTILHADO (Plano Total Share)';
    static final String SUMARIO_PLANO_73_75 = 'SUMÁRIO PLANO 73 E 75';
    
    
    List<ContentVersion> lstContentVersion = new List<ContentVersion>();
    List<ContentDocumentLink> lstContentLink = new List<ContentDocumentLink>();
    Boolean isPlanoCompartilhado = false;
    Boolean isPlanoIndividual = false;
    
    public void criarContratos(String orderId){
        verificarPlanos(orderId);
        buildListContentVersion(orderId);
        buildListContentLink(orderId);
    }
    
    public void buildListContentVersion(String idPedido){
      
        this.lstContentVersion.add(getDocumentoTCPJ(idPedido));
        this.lstContentVersion.add(getAnexoContratoPermanencia(idPedido));         
        this.lstContentVersion.add(getContratoPermanencia(idPedido));        
        this.lstContentVersion.addAll(getTermosEstaticos());
        
        if(this.isPlanoIndividual || this.isPlanoCompartilhado){
            this.lstContentVersion.add(getTermoGestorOnline(idPedido));
            this.lstContentVersion.add(getTermoLd21(idPedido));
        }
    }
    
    public void buildListContentLink(String idPedido){
        
        
        if(!this.lstContentVersion.isEmpty()) {
                Database.insert(this.lstContentVersion);
                
                Set<Id> setIdsContentVersion = new Set<Id>();
                
                for(ContentVersion varContentVersion : this.lstContentVersion) {
                    setIdsContentVersion.add(varContentVersion.Id);
                }
                
                List<ContentVersion> lstInsertedContentVersion = [SELECT Id, ContentDocumentId 
                                                                  FROM ContentVersion 
                                                                  WHERE Id IN: setIdsContentVersion];
                
                
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
    }
       
    public static ContentVersion getAnexoContratoPermanencia(String orderId) {
        
        ContentVersion varContentVersion = new ContentVersion();
        
        PageReference pdf = Page.SOLAR_PME_AnexoContratoPermanenciaPdf;
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
    
    
    public static ContentVersion getTermoGestorOnline(String orderId) {
        
        ContentVersion varContentVersion = new ContentVersion();
        
        PageReference pdf = Page.SOLAR_PME_TermoGestorOnlinePdf;
        pdf.getParameters().put('id', orderId);
        
        varContentVersion.Title = 'Termo Gestor Online';
        varContentVersion.PathOnClient = 'Termo Gestor Online' + CONST_PDF;
        if(Test.isRunningTest()) {
            varContentVersion.VersionData = blob.valueOf('teste'); 
        } else {
            varContentVersion.VersionData = pdf.getContent(); 
        }
        varContentVersion.Origin = CONT_VER_ORIGEM;
        varContentVersion.IsMajorVersion = true;
        
        return varContentVersion;
    }
    
    public static ContentVersion getContratoPermanencia(String orderId) {
        
        ContentVersion varContentVersion = new ContentVersion();
        
        PageReference pdf = Page.SOLAR_PME_ContratoPermanenciaPdf;
        pdf.getParameters().put('id', orderId);
        
        varContentVersion.Title = 'CONTRATO DE PERMANENCIA';
        varContentVersion.PathOnClient = 'CONTRATO DE PERMANENCIA' + CONST_PDF;
        if(Test.isRunningTest()) {
            varContentVersion.VersionData = blob.valueOf('teste'); 
        } else {
            varContentVersion.VersionData = pdf.getContent(); 
        }
        varContentVersion.Origin = CONT_VER_ORIGEM;
        varContentVersion.IsMajorVersion = true;
        
        return varContentVersion;
    }
    
    public static ContentVersion getTermoLd21(String orderId) {
        
        ContentVersion varContentVersion = new ContentVersion();
        
        PageReference pdf = Page.SOLAR_PME_TermoLd21Pdf;
        pdf.getParameters().put('id', orderId);
        
        varContentVersion.Title = 'Termo LD21';
        varContentVersion.PathOnClient = 'Termo LD21' + CONST_PDF;
        if(Test.isRunningTest()) {
            varContentVersion.VersionData = blob.valueOf('teste'); 
        } else {
            varContentVersion.VersionData = pdf.getContent(); 
        }
        varContentVersion.Origin = CONT_VER_ORIGEM;
        varContentVersion.IsMajorVersion = true;
        
        return varContentVersion;
    }
    
    public void verificarPlanos(String idPedido){
        //pedido
        Order order = CEC_PME_SalesDocumentsQuerys.getOrder(idPedido);
        
        //itens do pedido
        List<OrderItem> orderItens = CEC_PME_SalesDocumentsQuerys.getOrderItens(idPedido);
        
        //SalesDocuments
        CEC_PME_SalesDocumentsRequest.SalesDocuments salesDocs = new CEC_PME_SalesDocumentsRequest.SalesDocuments();
        
        //SalesDocuments Payload
        CEC_PME_SalesDocumentsPayload createPayload = new CEC_PME_SalesDocumentsPayload();
        
        //Score
        Set<String> setRange = CEC_PME_SalesDocumentsPayload.getRange(orderItens);
        List<Product2> products = CEC_PME_SalesDocumentsQuerys.getRange(setRange);
        Map<String, String> mapRange = CEC_PME_SalesDocumentsPayload.getMapRange(products);
        
        //conta da empresa
        Account customerAccount = CEC_PME_SalesDocumentsQuerys.getCustomerAccount(order.AccountId);
        
        //planos
        salesDocs.plans = createPayload.getPlans(orderItens, mapRange, customerAccount.CommercialSegment__c);
        
        if(salesDocs.plans != null) {
            for(CEC_PME_SalesDocumentsRequest.Plans plan : salesDocs.plans) {                
                if(plan.name.contains('Individual')){
                    this.isPlanoIndividual = true;
                } 
                if(plan.name.contains('Compartilhado')){
                    this.isPlanoCompartilhado = true;
                } 
            } 
        }
        
    }
    
    public List<ContentVersion> getTermosEstaticos(){
        List<ContentVersion> listContentVersion = new List<ContentVersion>();
        List<String> listSelectTermos = new List<String>();
        
        listSelectTermos.add(CONTRATO_SMP);        
        if(this.isPlanoCompartilhado){
            listSelectTermos.add(SUMARIO_COMPARTILHADO);
        }
        if(this.isPlanoIndividual){
            listSelectTermos.add(SUMARIO_INDIVIDUAL);  
        }
        if(!this.isPlanoIndividual && !this.isPlanoCompartilhado){
           listSelectTermos.add(SUMARIO_PLANO_73_75); 
        }
        
        List<ContentWorkspace> listContentWorkspace = [SELECT Id
                                                       FROM ContentWorkspace 
                                                       WHERE Name = 'Solar PME Termos'
                                                       LIMIT 1];
        
        if((listContentWorkspace == null || listContentWorkspace.isEmpty()) && !test.isRunningTest()) {
			throw new ContratosException('Acesso a pasta Solar PME Termos não encontrado, entre em contato com o administrador do sistema');
        }
        
        String contentWorkspaceId = 'test';
        if(!test.isRunningTest()) {
            contentWorkspaceId = listContentWorkspace.get(0).Id;
        }
        
        List<ContentVersion> listCV = [SELECT Id, 
                                       Title, 
                                       PathOnClient, 
                                       VersionData, 
                                       Origin, 
                                       IsMajorVersion 
                                       FROM ContentVersion 
                                       WHERE ContentDocument.ParentId = :contentWorkspaceId 
                                       AND Title IN :listSelectTermos
                                       AND IsLatest = true];
		
        for(ContentVersion cv : listCV) {
            ContentVersion item = new ContentVersion();            
            item.VersionData = cv.VersionData;         
            item.Title = cv.Title;
            item.PathOnClient = cv.PathOnClient;
            item.Origin = CONT_VER_ORIGEM;
            item.IsMajorVersion = true;  
            system.debug( 'TESTE -> ' + item.Title);
            system.debug( 'TESTE -> ' + item.PathOnClient);
            
            listContentVersion.add(item);  
            
        }
        system.debug(listContentVersion);
        return listContentVersion;
    }
}