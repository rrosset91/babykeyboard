/*
* Autor: Diogo Braga - Deloitte
* Data: 15/08/2019
* Descrição: CEC FASE 1 + SQUAD PME: Utilizada no controle dos botões exibidos na versão mobile da tela de pedido
*/
public class CEC_PME_MobileButtonsController { 
    public class MobileButtonsControllerException extends Exception{}
    
    private static final String STATUS = 'Status';
    private static final String CANCELADO = 'Cancelado';
    private static final String NENHUM = '-- Nenhum --';
    private static final String ORDER = 'Order';
    private static final String STATUS_QUOTE = 'StatusQuote__c';
    private static final String SUBSTATUS = 'SubStatus__c';
    private static final String VENDEDOR = 'VENDEDOR';
    private static final String ERRO_INTEGRACAO = 'Erro na integração:';
    private static final String ERROR = 'error';
    private static final String MESSAGE = 'message';
    private static final String DATA = 'data';
    private static final String SALES_DOCUMENTS = 'salesDocuments';
    private static final String HABILITAR_PEDIDO_RPA = 'Habilitar Pedido RPA';
    private static final String EXT_PDF = '.pdf';
    private static final String PROFILE_RCV = 'RCV PME';
    
    private static final String ORDER_STATUS_CPC = 'Status CPC';
    private static final String ORDER_INPUT_ERRO = 'Input com Erro';
    private static final String ORDER_TERRITORIO_ASSOCIADO = 'Território Associado';
    private static final String ORDER_DOCUMENTACAO_DEVOLVIDA = 'Documentação Devolvida';
    private static final String ORDER_PRE_ANALiSE_DOC = 'Pré Analise da Documentação';
    private static final String ORDER_DOC_APROVADA = 'Documentação Aprovada';
    private static final String ORDER_CONTRATO_CRIADO = 'Contrato criado';
    private static final String ORDER_CONTRATO_ASSINADO = 'Contrato Assinado';
    private static final String ORDER_AGUARDANDO_CRIACAO_CONTR = 'Aguardando criação contrato';
    private static final String ORDER_EXECUTANDO_INPUT_MANUAL = 'Executando Input Manual';
    private static final String ORDER_EXECUTANDO_INPUT_AUTOMATICO = 'Executando Input Automático';
    private static final String ORDER_AGUARDANDO_ASSINATURA = 'Aguardando Assinatura';
    
    
    
    private Order varOrder;
    
    /*
* Autor: Otávio Fonseca
* Descrição: CEC FASE 1 + SQUAD PME: Método construtor da classe
*/    
    public CEC_PME_MobileButtonsController(Id recordId) {
        varOrder = [SELECT Id,
                    OwnerId,
                    Status,
                    StatusQuote__c,
                    DocuSignReenviarAssinatura__c,
                    SubStatus__c, 
                    Complement__c, 
                    Account.Name,
                    Account.Email__c,
                    Account.DocumentNumber__c,
                    AccountId,
                    ManualInput__c,
                    OrderNumber,
                    ResaleSource__c,
                    Resale__c,
                    Observacoes__c,
                    NumberQuote__c,
                    ErroMsg__c,
                    (SELECT Id, 
                     NewValue 
                     FROM Histories 
                     WHERE Field = :STATUS)
                    FROM Order 
                    WHERE Id = :recordId];
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado no acionamento do botão "Cancelar Pedido"
*/       
    @AuraEnabled
    public static void cancelOrder(String recordId) {
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(recordId);
        controller.varOrder.Status = CANCELADO;
        update controller.varOrder;
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado na pesquisa dos valores disponíveis na lista do campo status cotação
*/     
    @AuraEnabled
    public static String getPicklistStausQuote() {
        List<String> listValues = new List<String>{NENHUM};
            for(Schema.PicklistEntry iPicklistEntry : Schema.getGlobalDescribe().get(ORDER).getDescribe().fields.getMap().get(STATUS_QUOTE).getDescribe().getPicklistValues()) {
                listValues.add(iPicklistEntry.getLabel());
            }
        
        return JSON.serialize(listValues);
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado no acionamento do botão "Status cotação"
*/       
    @AuraEnabled
    public static void setQuoteStatus(Order varOrder) {
        if(String.isBlank(varOrder.StatusQuote__c) || String.isBlank(varOrder.NumberQuote__c) ) {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_1);
        }
        
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(varOrder.Id);
        controller.varOrder.Status = ORDER_STATUS_CPC;
        controller.varOrder.Observacoes__c = varOrder.Observacoes__c;
        controller.varOrder.StatusQuote__c = varOrder.StatusQuote__c;
        controller.varOrder.NumberQuote__c = varOrder.NumberQuote__c;
        update controller.varOrder;
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado no acionamento do botão "Input com Erro"
*/       
    @AuraEnabled
    public static void setNotInputed(Order varOrder) {
        if(String.isBlank(varOrder.ErroMsg__c)) {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_2);
        }
        
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(varOrder.Id);
        controller.varOrder.Status = ORDER_INPUT_ERRO;
        controller.varOrder.ErroMsg__c = varOrder.ErroMsg__c;
        update controller.varOrder;
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado no acionamento do botão "Validação Backoffice"
*/     
    @AuraEnabled
    public static void sendToBackoffice(String recordId) {
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(recordId);
        
        if(!ORDER_TERRITORIO_ASSOCIADO.equalsIgnoreCase(controller.varOrder.Status) && !ORDER_DOCUMENTACAO_DEVOLVIDA.equalsIgnoreCase(controller.varOrder.Status)) {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_3);
        }
        
        controller.varOrder.Status = ORDER_PRE_ANALiSE_DOC;
        update controller.varOrder;
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PM1E: Método utilizado na pesquisa do papel do usuário
*/     
    public String getCpcRole() {
        return [SELECT RolerFormula__c 
                FROM User 
                WHERE Id = :UserInfo.getUserId()].RolerFormula__c;
    }     
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado no acionamento do botão "Aprovar"
*/     
    @AuraEnabled
    public static void approveDocumentation(String recordId) {
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(recordId);
        String cpcRole = controller.getCpcRole();
        
        if(!ORDER_PRE_ANALiSE_DOC.equalsIgnoreCase(controller.varOrder.Status)) {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_4);
        }
        
        if(String.isNotBlank(cpcRole) && cpcRole.contains(VENDEDOR)) {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_5);
        }
        
        controller.validateAttachments();
        
        new CEC_PME_IntegrationDocuSignRemoveSigners(recordId).removeAllStatusSent();
        
        controller.varOrder.Status = ORDER_DOC_APROVADA;
        update controller.varOrder;
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado na pesquisa dos valores disponíveis na lista do campo Sub status
*/     
    @AuraEnabled
    public static Map<String, List<String>> getPicklistOptions(String recordId) { 
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(recordId);
        String cpcRole = controller.getCpcRole();
        
        if(!ORDER_PRE_ANALiSE_DOC.equalsIgnoreCase(controller.varOrder.Status)) {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_7);
        } else if(String.isNotBlank(cpcRole) && cpcRole.contains(VENDEDOR)) {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_8);
        }
        
        Set<String> lstApiFields = new Set<String>(); 
        lstApiFields.add(SUBSTATUS);
        
        return getPicklistDescribe(ORDER, lstApiFields);
    } 
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Pesquisa os valores cadastrados em um picklist
*/     
    private static Map<String, List<String>> getPicklistDescribe(String sObjectName, Set<String> lstApiFields) { 
        
        Map<String, List<String>> mapPicklistDescribe = new Map<String, List<String>>();
        
        Schema.DescribeFieldResult descFieldResult;
        List<Schema.PicklistEntry> picklistEntry;
        List<String> lstPicklistValues;
        
        for(String apiName : lstApiFields) { 
            
            descFieldResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(apiName).getDescribe();
            picklistEntry = descFieldResult.getPicklistValues();
            lstPicklistValues = new List<String>();
            
            for(Schema.PicklistEntry pe : picklistEntry) { 
                lstPicklistValues.add(pe.getValue());
            }
            
            mapPicklistDescribe.put(apiName, lstPicklistValues);
        }
        
        return mapPicklistDescribe;
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado no acionamento do botão "Devolver"
*/     
    @AuraEnabled
    public static void disapproveDocumentation(String recordId, String subStatus, String complemento) {
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(recordId);
        controller.varOrder.Status = ORDER_DOCUMENTACAO_DEVOLVIDA;
        controller.varOrder.SubStatus__c = subStatus;
        controller.varOrder.Observacoes__c = complemento;
        update controller.varOrder;
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado no acionamento do botão "Assinar"
*/     
    @AuraEnabled
    public static String signContract(String recordId) {
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(recordId);
        
        if(!ORDER_CONTRATO_CRIADO.equalsIgnoreCase(controller.varOrder.Status)) {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_9);
        }
        
        Integration_Flow__c integrationFlow = Integration_Flow__c.getInstance(UserInfo.getProfileId());
        
        
        CEC_PME_ServiceEnvelope.SaveResult saveResult = new CEC_PME_ServiceEnvelope().open(controller.varOrder.Id, integrationFlow.isSigningRequired__c,
                                                                                           integrationFlow.isEmbedded__c, integrationFlow.AccountId__c, 
                                                                                           integrationFlow.TemplateId__c);
        
        if(saveResult.isError) { 
            throw new MobileButtonsControllerException(saveResult.message);
        } 
        
        return saveResult.urlEmbedded;
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado no acionamento do botão "Criar contrato"
*/     
    @AuraEnabled
    public static void createContract(String recordId) {
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(recordId);
        
        if(!ORDER_AGUARDANDO_CRIACAO_CONTR.equalsIgnoreCase(controller.varOrder.Status)) {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_10);
        }
        
        String jsonResponse = CEC_PME_SalesDocumentsService.getDocuments(controller.varOrder.Id);
        controller.validateResponse(jsonResponse);
        
        controller.varOrder.Status = ORDER_CONTRATO_CRIADO;
        update controller.varOrder;
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado na validação da resposta do serviço de criação de contrato
*/     
    @TestVisible
    private void validateResponse(String jsonResponse) {
        if(String.isBlank(jsonResponse)) {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_11);
        }
        
        System.debug('jsonResponse ' + jsonResponse);
        
        if(jsonResponse.contains(ERRO_INTEGRACAO)) {
            throw new MobileButtonsControllerException(jsonResponse);
        }
        
        Map<String, Object> mapJsonResponse = (Map<String, Object>) Json.deserializeUntyped(jsonResponse);
        if(mapJsonResponse.containsKey(ERROR) 
           && ((Map<String, Object>) mapJsonResponse.get(ERROR)).containsKey(MESSAGE) 
           && String.isNotBlank((String) ((Map<String, Object>) mapJsonResponse.get(ERROR)).get(MESSAGE))) {
               throw new MobileButtonsControllerException(ERRO_INTEGRACAO + ((Map<String, Object>) mapJsonResponse.get(ERROR)).get(MESSAGE));
           }
        
        if(mapJsonResponse.containsKey(DATA)) {
            Map<String, Object> mapData = (Map<String, Object>) mapJsonResponse.get(DATA);
            if(mapData.containsKey(SALES_DOCUMENTS)) {
                List<Object> listsalesDocuments = (List<Object>) mapData.get(SALES_DOCUMENTS);
                if(listsalesDocuments.isEmpty()) {
                    throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_12);
                } else {
                    for(Object objSalesDocument :  listsalesDocuments) {
                        Map<String, Object> mapSalesDocument = (Map<String, Object>) objSalesDocument;
                        if(!mapSalesDocument.containsKey('content') || String.isBlank((String) mapSalesDocument.get('content'))) {
                            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_13);
                        } 
                    }
                }
            } else {
                throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_14);
            }
        } else {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_15);
        }
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado na atualização do território do cliente
*/     
    @AuraEnabled
    public static void updateAccountTerritory(String recordId, String territoryId) { 
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(recordId);
        CEC_PME_TerritoryUtils.updateAccountTerritory(recordId, territoryId);
        
        new CEC_PME_SharerRecord().sharingRecordOrder(new List<Order>{controller.varOrder});
        
        controller.varOrder.Status = ORDER_TERRITORIO_ASSOCIADO;
        update controller.varOrder;
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado na montagem da lista de territórios disponíveis para associação
*/     
    @AuraEnabled
    public static String getListTerritorysRadios(String recordId) { 
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(recordId);
        
        if(!ORDER_CONTRATO_ASSINADO.equalsIgnoreCase(controller.varOrder.Status)) {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_16);
        }
        
        return CEC_PME_TerritoryUtils.getListTerritorysRadios(recordId); 
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado na exclusão de documentos do pedido 
*/     
    @AuraEnabled
    public static void deleteContDocNComp(String recordId) {
        CEC_PME_OrderDocumentCleaner.deleteContDocNComp(recordId);
    }
    
    /*
* Autor: Diogo Braga
* Descrição: CEC FASE 1 + SQUAD PME: Método utilizado no acionamento do botão "Submeter para Input"
*/     
    @AuraEnabled
    public static void inputOrder(String recordId) {
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(recordId);
        
        if(ORDER_DOC_APROVADA.equalsIgnoreCase(controller.varOrder.Status)) {
            controller.validateAttachments();
            
            if(controller.isInputManual()){
                controller.varOrder.Status = ORDER_EXECUTANDO_INPUT_MANUAL;
                update controller.varOrder;
            } else {
                
                CEC_PME_EnvioPedido_Response resEnviarPedido = CEC_PME_EnvioPedido_Service.enviarPedido(recordId);
                
                if(resEnviarPedido == null || resEnviarPedido.Data == null){
                    throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_18);
                }
                
                controller.varOrder.Status = ORDER_EXECUTANDO_INPUT_AUTOMATICO;
                update controller.varOrder;
            }
        } else if (ORDER_INPUT_ERRO.equalsIgnoreCase(controller.varOrder.Status)) {
            controller.varOrder.Status = ORDER_EXECUTANDO_INPUT_MANUAL;
            update controller.varOrder;
        } else {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_19);
        }
    }
    
    private void validateAttachments() {
        List<ContentDocumentLink> listContentDocumentLink = [SELECT ContentDocumentId 
                                                             FROM ContentDocumentLink 
                                                             WHERE LinkedEntityId =: varOrder.Id];
        
        Set<String> setContentDocumentIds = new Set<String>();
        for(ContentDocumentLink varContDocLink : listContentDocumentLink) {
            setContentDocumentIds.add(varContDocLink.ContentDocumentId);
        }
        
        if(!setContentDocumentIds.isEmpty()) {
            List<ContentVersion> listContentVersion = [SELECT Id, 
                                                       CEC_Tipo_de_Anexo__c,
                                                       ContentDocument.Title
                                                       FROM ContentVersion
                                                       WHERE ContentDocumentId IN :setContentDocumentIds 
                                                       AND IsLatest = true];
            
            Boolean isOnInput = ORDER_DOC_APROVADA.equalsIgnoreCase(varOrder.Status);
            for(ContentVersion varContentVersion : listContentVersion) {
                if(isOnInput && !varContentVersion.ContentDocument.Title.endsWithIgnoreCase('_Completed.pdf')) {
                    throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_23);
                }
                
                if(String.isBlank(varContentVersion.CEC_Tipo_de_Anexo__c)) {
                    throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_17);
                }
            }
        } else {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_17);
        }
    }
    
    /*
    * Autor: x - Deloitte
    * Descrição: verifica se o input é manual
    */
    private Boolean isInputManual() {
        String cnpj = varOrder.Account.DocumentNumber__c;
        
        if(varOrder.Histories != null) {
            for(OrderHistory iOrderHistory : varOrder.Histories) {
                if(ORDER_EXECUTANDO_INPUT_MANUAL.equals(iOrderHistory.NewValue)) {
                    return true;
                }
            }
        }
        
        Boolean activeLines = false;
        Boolean isClient = false;
        
        if(PME_ValidateCNPJ_Service.getClientMobile(cnpj).data != Null) {
            isClient = true;
            PME_ValidateCNPJ_Response res = PME_ValidateCNPJ_Service.getInfoByClientActive(cnpj);
            activeLines = res.data != null && res.data.subscribers != null && !res.data.subscribers.isEmpty();
            
        } else {
            CEC_PME_MobileCorporateCustomer_Response resMobCorpCustomer = PME_ValidateCNPJ_Service.getMobileCorporateCustomer(cnpj);
            isClient = resMobCorpCustomer.data != Null;
        }
        
        return isClient && !activeLines;
    }
    
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método utilizado no acionamento do botão "Reenviar"
    */     
    @AuraEnabled
    public static String getSignatureContacts(String orderId) {
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(orderId);
        String profileName = [SELECT Name FROM Profile WHERE Id = : System.UserInfo.getProfileId()].Name;
        
        Boolean isAguardandoAssinatura = ORDER_AGUARDANDO_ASSINATURA.equalsIgnoreCase(controller.varOrder.Status);
        Boolean isRCVProfile = profileName.equalsIgnoreCase(PROFILE_RCV);                                                              
        
        if(!(isAguardandoAssinatura && (controller.varOrder.DocuSignReenviarAssinatura__c || isRCVProfile ))) {
            throw new MobileButtonsControllerException(Label.CEC_PME_MobileButtonsController_20);
        }
        
        return new CEC_PME_ReSenderDocusignEnvelope().getSignatureContacts(orderId);
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método utilizado no acionamento do botão "Aprovar". Realiza o envio das informações para o DocuSign.
    */     
    @AuraEnabled
    public static void reSendDocusignEnvelope(String signers, Id orderId) {
        new CEC_PME_ReSenderDocusignEnvelope().reSendDocusignEnvelope(signers, orderId);
    }
    
    /*
    * Autor: Otávio Fonseca
    * Descrição: CEC FASE 1 + SQUAD PME: Método utilizado no acionamento do botão "Reenviar". Reenvia o pedido para o RPA.
    */     
    @AuraEnabled
    public static String reenviarPedido(String recordId){
        CEC_PME_EnvioPedido_Response resEnviarPedido = CEC_PME_EnvioPedido_Service.enviarPedido(recordId);
        
        if(resEnviarPedido.Data == Null){
            return Label.CEC_PME_MobileButtonsController_21;
        }
        
        CEC_PME_HeaderRecordHomeController.changeStatus(recordId, ORDER_EXECUTANDO_INPUT_AUTOMATICO);
        
        return Label.CEC_PME_MobileButtonsController_22;
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: CEC EXT + SQUAD PME: Método que obtém os campos do usuário logado
	*/
    @AuraEnabled
    public static User getUser() {
        return [SELECT Id,
                Profile.Name,
                RolerFormula__c
                FROM User
                WHERE Id = : System.UserInfo.getUserId()];
    } 
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: SOLAR + SQUAD PME: Método que obtém informações iniciais da tela
    */
    @AuraEnabled
    public static mobileButtonsVO getMobileButtonsVO(String recordId) { 
        CEC_PME_MobileButtonsController controller = new CEC_PME_MobileButtonsController(recordId); 
        MobileButtonsVO mobileButtonsVO = new MobileButtonsVO();
        mobileButtonsVO.order = controller.varOrder;
        mobileButtonsVO.user = getUser();
        mobileButtonsVO.access = new Access();
        mobileButtonsVO.access.hasAccBtnInputLegado = FeatureManagement.checkPermission('SOLAR_PME_BtnInputLegado');
        
        return mobileButtonsVO ;
    } 
    
    /*
    * Autor: Diogo Braga - Deloitte
	* Descrição: SOLAR + SQUAD PME: Objeto VO
    */
    public class MobileButtonsVO {
    @AuraEnabled

        public Order order {get; set;}
        @AuraEnabled
        public User user {get; set;}
        
        @AuraEnabled
        public Access access {get; set;}
    }
    

    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: SOLAR + SQUAD PME: Objeto VO de acesso

	*/    
    public class Access {
    @AuraEnabled
        public Boolean hasAccBtnInputLegado {get; set;}        
    }
    

}