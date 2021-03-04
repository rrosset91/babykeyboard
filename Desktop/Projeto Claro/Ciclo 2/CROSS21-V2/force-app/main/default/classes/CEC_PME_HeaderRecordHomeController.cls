/*
* Autor: Marcos Aurélio - Deloitte
* Data: 26/02/2019
* Descrição: 	[CEC/ID: CEC FASE 1/ XXXXX]
				[Time: SQUAD PME - Sprint YYYYY]
				[Classe desenvolvida para acompanhamento do pedido. Acompanha a implementação de timeline contido
				no componente PME_OrderTimeLine.
				Contém fluxos para alteração de status conforme navegação da tela]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/
public class CEC_PME_HeaderRecordHomeController { 
    public class CEC_PME_HeaderRecordHomeControllerException extends Exception {}

    /*
	* Autor: Marcos Aurélio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint XX]
   	Método que obtém o papel e o profile do usuário logado.
	*/
    @AuraEnabled
    public static String getRoleAndProfile() {
        
    	String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        String cpcRole = [SELECT RoleCPC__c FROM User WHERE Id = :UserInfo.getUserId()].RoleCPC__c;
        
        return '{"profileName" : \"' + profileName + '\",' + '"cpcRole" : \"' + cpcRole + '\"}';
   }
    
    /*
	* Autor: Marcos Aurélio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint XX]
   	Método que obtém os campos da ordem.
	*/
    @AuraEnabled
    public static SObject getSObject(String recordId, String sObjectName) { 
        
        return [SELECT Status, 
                SubStatus__c, 
                Complement__c, 
                Account.Name,
                Account.Email__c,
                ManualInput__c,
                DocuSignReenviarAssinatura__c
                FROM Order 
                WHERE Id = :recordId];
            
    }
    
    /*
	* Autor: Marcos Aurélio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint XX]
   	Método que obtém a lista de sub status da ordem para ser utilizado em tela.
	*/
    @AuraEnabled
    public static map<String, list<String>> getPicklistOptions() { 
        
        set<String> lstApiFields = new set<String>(); 
        lstApiFields.add('SubStatus__c');
        
        return getPicklistDescribe('Order', lstApiFields);
    } 
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint XX]
   	* Método que obtém a lista de sub território do proprietário do pedido.
	*/
    @AuraEnabled
    public static String getListTerritorysRadios(Id orderId) { 
        List<Map<String,String>> listTerritorys = new List<Map<String,String>>();
        
        List<Member__c> listMembers = [SELECT Id, 
                                       Hierarchy__c,
                                       Hierarchy__r.name
                                       FROM Member__c
                                       WHERE User__c IN (SELECT OwnerId FROM Order WHERE Id = :orderId)];
        
        if(listMembers.isEmpty()) {
            throw new CEC_PME_HeaderRecordHomeControllerException('Não foi possivel encontrar um território');
        }
        
        for(Member__c member : listMembers) {
            Map<String,String> newOption = new Map<String,String>();
            newOption.put('value', member.Hierarchy__c);
            newOption.put('label', member.Hierarchy__r.name);
            listTerritorys.add(newOption);
        }
        return JSON.serialize(listTerritorys); 
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint XX]
   	* Método que obtém a lista de sub território do proprietário do pedido.
	*/
    @AuraEnabled
    public static void updateAccountTerritory(Id orderId, String territoryId) { 
        Order orderUp = [SELECT Id,
                         AccountId
                         FROM Order 
                         WHERE Id = :orderId];
        
        Account accountUp = new Account();
        accountUp.Id = orderUp.AccountId;
        accountUp.Hierarchy__c = territoryId;
        update accountUp;
    }
    
    /*
	* Autor: Marcos Aurélio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint XX]
   	Método que obtém a lista de status da ordem para ser utilizado em tela.
	*/
    private static map<String, list<String>> getPicklistDescribe(String sObjectName, set<String> lstApiFields) { 
        
        map<String, list<String>> mapPicklistDescribe = new map<String, list<String>>();
        
        Schema.DescribeFieldResult descFieldResult;
        list<Schema.PicklistEntry> picklistEntry;
        list<String> lstPicklistValues;
        
        for(String apiName : lstApiFields) { 
        
            descFieldResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().get(apiName).getDescribe();
            picklistEntry = descFieldResult.getPicklistValues();
            lstPicklistValues = new list<String>();
            
            for(Schema.PicklistEntry pe : picklistEntry) { 
                lstPicklistValues.add(pe.getValue());
            }
            
            mapPicklistDescribe.put(apiName, lstPicklistValues);
        }
        
        return mapPicklistDescribe;
    }    
    
    /*@AuraEnabled
    public List<SelectOption> getSubStatus() { 
        
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =
            Order.SubStatus__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    } */   
    
    /*
	* Autor: Marcos Aurélio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint XX]
   	Método que muda o status conforme fluxo da navegação em tela.
	*/
    @AuraEnabled
    public static void changeStatus(String recordId, String status) {
        Order ord = new Order(Id = recordId);
        ord.Status = status;
        update ord;
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: chamar integração para remover assinadores pendentes do envelope da docusign
	*/
    @AuraEnabled
    public static CEC_PME_IntegrationDocuSignRemoveSigners.SaveResult callRemoveSigners(String recordId) {
        System.debug('TYUMI => Entrou no método callRemoveSigners');
        CEC_PME_IntegrationDocuSignRemoveSigners.SaveResult saveResult = new CEC_PME_IntegrationDocuSignRemoveSigners(recordId).removeAllStatusSent();
        System.debug('TYUMI => saveResult: ' + saveResult);
        return saveResult;
    }
    
    /*
	* Autor: Marcos Aurélio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint XX]
   	Método que muda o sub status conforme fluxo da navegação em tela.
	*/
    @AuraEnabled
    public static void changeSubStatus(String recordId, String subStatus, String complemento) {
        
        Order ord = new Order(Id = recordId);
        ord.SubStatus__c = subStatus;
        ord.Complement__c = complemento;
        
        update ord;
        
    }    
	/*
	* Autor: Marcos Aurélio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint XX]
   	Método que muda o status da ordem dependendo da etapa que a mesma passou.
	Caso haja documentos inseridos pelo docusign, marcar como Pré Analise da Documentação, caso contrário
	marcar como Pré Analise.
	*/
    @AuraEnabled
	public static String changeStatusBackOffice(String recordId){
    	String retorno = '';
        List<dsfs__DocuSign_Status__c> docStatus = [SELECT Id FROM dsfs__DocuSign_Status__c WHERE Order__c =: recordId];
        
        if(docStatus.size() == 0){
            retorno = 'Pré Analise';
		} else {
        	retorno = 'Pré Analise da Documentação';
        }
        
        CEC_PME_HeaderRecordHomeController.changeStatus(recordId, retorno);
        return retorno;
    }
    
    @AuraEnabled
    public static Boolean isBackofficeUser(){
        User usr = [SELECT RolerFormula__c FROM User WHERE id =: UserInfo.getUserId()];
        return 'BACKOFFICE'.Equals(usr.RolerFormula__c);
    }
    
    @AuraEnabled
    public static String reenviarPedido(String recordId){
        /*System.Debug('Reenviando pedido: ' + recordId);
        CEC_PME_EnvioPedido_Response resEnviarPedido = CEC_PME_EnvioPedido_Service.enviarPedido(recordId);
	   	
        if(resEnviarPedido.Data == Null){
            return 'Erro no processamento. Por favor reenviar! ';
        }
        
        CEC_PME_HeaderRecordHomeController.changeStatus(recordId, 'Executando Input Automático');
		*/
        return '';
    }
    /*
	* Autor: Marcos Aurelio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 12]
   	Método que encerra o fluxo da ordem enviando o pedido ao RPA ou marcando como input manual conforme regras implementadas.
	*/    
    @AuraEnabled
	public static String closeOrder(String recordId){
		
		Order ord = [SELECT Id, ResaleSource__c, Resale__c, Account.DocumentNumber__c FROM Order WHERE Id =: recordId];
		/*
		if(ord.ResaleSource__c != ord.Resale__c){
			return 'Revenda alterada <Definir a mensagem a ser apresentada.>';
		}
		*/
		if(!validarTipoAnexo(recordId)){
			return 'Tipo de Anexo não preenchido ou anexo não encontrado.';
		}
		
		PME_ValidateCNPJ_Response res = PME_ValidateCNPJ_Service.getInfoByClient(ord.Account.DocumentNumber__c);
	   	if(res.data != Null){
	   		CEC_PME_HeaderRecordHomeController.changeStatus(recordId, 'Executando Input Manual');
   			return '';		
	   	}
	   	
		DesativarIntegracoes__c desativarIntegracoes = DesativarIntegracoes__c.getInstance('Habilitar Pedido RPA');
        if(desativarIntegracoes != Null && !desativarIntegracoes.isIntegracaoAtiva__c){
            throw new CEC_PME_HeaderRecordHomeControllerException(desativarIntegracoes.Mensagem__c);
        }
        
        CEC_PME_EnvioPedido_Response resEnviarPedido = CEC_PME_EnvioPedido_Service.enviarPedido(Ord.Id);
        
        
        if(resEnviarPedido.Data == Null){
            return 'Erro no processamento. Por favor reenviar! ';
        }
        
        CEC_PME_HeaderRecordHomeController.changeStatus(recordId, 'Executando Input Automático');
        
        return '';
	}
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11]
   	Método responsável por deletar todos os arquivos não completed, solicitado por Botani
	*/   
    public static void deleteContDocNComp(String recordId) {
        /*
        Set<String> setContentLink = new Set<String>();
        
        List<ContentDocumentLink> listContentDocumentLink = [SELECT Id,
                                                             ContentDocumentId 
                                                             FROM ContentDocumentLink 
                                                             WHERE LinkedEntityId = :recordId
                                                             AND (NOT ContentDocument.Title  LIKE '%completed.pdf')];
        system.debug('listContentDocumentLink ' + listContentDocumentLink);
        for(ContentDocumentLink contentDocumentLink : listContentDocumentLink) {
        	setContentLink.add(contentDocumentLink.ContentDocumentId);
        }
        
        List<ContentDocument> listContentDocument = [SELECT Id
                                                     FROM ContentDocument 
                                                     WHERE Id IN :setContentLink];
        
        system.debug('listContentDocument ' + listContentDocument);
        delete listContentDocument;*/
    }
    /*
	* Autor: Marcos Aurelio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11]
   	Método responsável por analisar se o pedido possue anexo, e se o tipo de anexo de cada anexo
	foi preenchido pelo usuário
	*/    
    private static Boolean validarTipoAnexo(String id){
		Set<String> setIdCDL = new Set<String>();
		
		for(ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: Id]){
			setIdCDL.add(cdl.ContentDocumentId);
		}
		
		if(setIdCDL.size() == 0){
			return false;
			
		}
		
		for(ContentVersion cv : [SELECT Id, CEC_Tipo_de_Anexo__c FROM ContentVersion WHERE ContentDocumentId =: setIdCDL and  IsLatest = true]){
			if(String.isBlank(cv.CEC_Tipo_de_Anexo__c)){
				return false;
			}
		}
		
		return true;
	}
    
    private static String getDocuSignAccountId() {
        Integration_Flow__c integrationFlow = Integration_Flow__c.getInstance(UserInfo.getProfileId());
        return integrationFlow.AccountId__c;
    }
    
    private static String getDocuSignEnvelopeId(Id orderId) {
        List<dsfs__DocuSign_Status__c> listStatusEnvelope = [SELECT Id, dsfs__DocuSign_Envelope_ID__c
                                                             FROM dsfs__DocuSign_Status__c
                                                             WHERE Order__c = :orderId
                                                             ORDER BY CreatedDate DESC];
        
        if(listStatusEnvelope.isEmpty()) {
            throw new CEC_PME_HeaderRecordHomeControllerException('Envelope Id não encontrado!');
        }
        return listStatusEnvelope.get(0).dsfs__DocuSign_Envelope_ID__c;
    }
  
    private static Set<String> getContactsNames(Id orderId) {
        Set<String> setContactsNames = new Set<String>();
        
        Order objOrder = [SELECT Id,
                       AccountId,
                       Related_Contacts__c
                       FROM Order
                       WHERE Id = :orderId];
        
        List<String> listAccContId = new List<String>();
        if(String.isNotBlank(objOrder.Related_Contacts__c) && objOrder.Related_Contacts__c.contains(';')) {
            listAccContId = objOrder.Related_Contacts__c.split(';');
        }
        
        List<AccountContactRelation> listRelatedContacts = [SELECT Contact.Name
                                                            FROM AccountContactRelation 
                                                            WHERE AccountId = :objOrder.AccountId 
                                                            AND ResponsibleForTheSignature__c = TRUE
                                                            AND Id IN :listAccContId];
        
        for(AccountContactRelation relatedContacts : listRelatedContacts) {
            setContactsNames.add(relatedContacts.Contact.Name);
        }
        
        return setContactsNames;
    }
    
    @AuraEnabled
    public static String getSignatureContacts(Id orderId) {
        String docuSignAccountId = getDocuSignAccountId();
        String docuSignEnvelopeId = getDocuSignEnvelopeId(orderId);
        Set<String> setContactsNames = getContactsNames(orderId);
        
        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients envelopeRecipients;
        envelopeRecipients = new CEC_PME_IntegrationDocuSignRecipient(docuSignAccountId, docuSignEnvelopeId).listRecipients();
        system.debug('envelopeRecipients ' + envelopeRecipients.signers);
        List<CEC_PME_IntegrationDocuSignObjectFactory.Signer> listSeparetedSigners = new List<CEC_PME_IntegrationDocuSignObjectFactory.Signer>();
        for(CEC_PME_IntegrationDocuSignObjectFactory.Signer signer : envelopeRecipients.signers) {
            if(!'completed'.equalsIgnoreCase(signer.status) && !setContactsNames.contains(signer.name)) {
                listSeparetedSigners.add(signer);
            }
        }
        
        return JSON.serialize(listSeparetedSigners);
    }   
    
    @AuraEnabled
    public static void reSendDocusignEnvelope(String signers, Id orderId) {
        String docuSignAccountId = getDocuSignAccountId();
        String docuSignEnvelopeId = getDocuSignEnvelopeId(orderId);
        
        System.debug('signers ' + signers);
        List<object> listObjects = (List<object>) JSON.deserializeUntyped(signers);
        List<CEC_PME_IntegrationDocuSignObjectFactory.Signer> listSigners = new List<CEC_PME_IntegrationDocuSignObjectFactory.Signer>();
        for(Object varObject : listObjects) {
            CEC_PME_IntegrationDocuSignObjectFactory.Signer signer = new CEC_PME_IntegrationDocuSignObjectFactory.Signer();
            Map<String, Object> mapObject = (Map<String, Object>) varObject;
            signer.recipientId = (String) mapObject.get('clientId');
            signer.email = (String) mapObject.get('clientEmail');
            listSigners.add(signer);
        }
        
        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients envelopeRecipients = new CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients();
        envelopeRecipients.signers = listSigners;
        
        new CEC_PME_IntegrationDocuSignRecipient(docuSignAccountId, docuSignEnvelopeId).updateRecipients(envelopeRecipients);
        
        Order updateOrder = new Order();
        updateOrder.Id = orderId;
        updateOrder.DocuSignReenviarAssinatura__c = false;
        update updateOrder;
    }

    /*
	* Autor: Rafael Barbaroto de Araújo - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
   	  Método responsável por atualizar destinos de envio do envelope para assinatura
	*/   
    @AuraEnabled
    public static String updateAccountContactRelationEmail(List<AccountContactRelation> relations){

        try{
            Database.update(relations);
            return 'E-mails atualizados com sucesso.';
        }
        catch(DmlException e) {
            return 'Falha ao atualizar e-mail de contatos.';
        }
        
    }

    /*
	* Autor: Rafael Barbaroto de Araújo - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
   	  Método responsável por enviar o envelope
	*/   
    @AuraEnabled
    public static CEC_PME_ServiceEnvelope.SaveResult openEnvelope(Id orderId, Boolean isSigningRequired, Boolean isEmbedded, String accountId, String templateId){

        CEC_PME_ServiceEnvelope.SaveResult saveResult = new CEC_PME_ServiceEnvelope().open(orderId, isSigningRequired, isEmbedded, accountId, templateId);

        return saveResult;
        
    }

    /*
	* Autor: Rafael Barbaroto de Araújo - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint XX]
   	  Método responsável por retornar a 'custom settings' Integration Flow
	*/ 
    @AuraEnabled
    public static Integration_Flow__c getIntegrationFlow(){

        //return Integration_Flow__c.getInstance('00e2C000000HlveQAC'); // Teste com profile 'Loja Propria', cujo campo isEmbedded__c é true
        return Integration_Flow__c.getInstance(UserInfo.getProfileId());
        
    }
    
    /*
	* Autor: Rafael A. Barbaroto de Araújo - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
   	* Método retorna a custom setting Desativar Integrações; switch de habilitação da integração com docusign.
	*/ 
    @AuraEnabled
    public static DesativarIntegracoes__c isIntegrationEnabled() {

        DesativarIntegracoes__c integrationSwitch = [SELECT isIntegracaoAtiva__c, 
                                                     Mensagem__c 
                                                     FROM DesativarIntegracoes__c
                                                     WHERE Name = 'Docusign'
                                                     LIMIT 1];

        return integrationSwitch;

    }

    /*
	* Autor: Rafael Chuluc P. da Graça - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 13]
   	Método responsável por chamar a classe para criar o contrato
	Otávio Fonseca: Alteração para retornar a string para o componente
	*/ 
    @AuraEnabled
    public static String createContractService(Id idPedido){
        return CEC_PME_SalesDocumentsService.getDocuments(idPedido);
    }     
    
}