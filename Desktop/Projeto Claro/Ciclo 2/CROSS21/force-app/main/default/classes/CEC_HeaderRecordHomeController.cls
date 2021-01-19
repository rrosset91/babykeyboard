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

public without sharing class CEC_HeaderRecordHomeController {
    public class HeaderRecordHomeException extends Exception {}

    /*
	* Autor: Marcos Aurélio - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint XX]
   	Método que obtém o papel e o profile do usuário logado.
	*/
    @AuraEnabled
    public static String getRoleAndProfile() {
        
    	String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        String cpcRole = [SELECT RolerFormula__c FROM User WHERE Id = :UserInfo.getUserId()].RolerFormula__c;
       
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
        return CEC_PME_TerritoryUtils.getListTerritorysRadios(orderId); 
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint XX]
   	* Método que obtém a lista de sub território do proprietário do pedido.
	*/
    @AuraEnabled
    public static void updateAccountTerritory(Id orderId, String territoryId) { 
        CEC_PME_TerritoryUtils.updateAccountTerritory(orderId, territoryId);
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
        system.debug('recordId ' + recordId);
        CEC_PME_IntegrationDocuSignRemoveSigners.SaveResult saveResult = new CEC_PME_IntegrationDocuSignRemoveSigners(recordId).removeAllStatusSent();
        
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
        
        changeStatus(recordId, retorno);
        return retorno;
    }
    
    @AuraEnabled
    public static Boolean isBackofficeUser(){
        User usr = [SELECT RolerFormula__c FROM User WHERE id =: UserInfo.getUserId()];
        return 'BACKOFFICE'.Equals(usr.RolerFormula__c);
    }
    
    @AuraEnabled
    public static String reenviarPedido(String recordId){
        System.Debug('Reenviando pedido: ' + recordId);
        CEC_PME_EnvioPedido_Response resEnviarPedido = CEC_PME_EnvioPedido_Service.enviarPedido(recordId);
	   	
        if(resEnviarPedido.Data == Null){
            return 'Erro no processamento. Por favor reenviar! ';
        }
        
        CEC_PME_HeaderRecordHomeController.changeStatus(recordId, 'Executando Input Automático');
		
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
		
	   	if(isInputManual(ord.Account.DocumentNumber__c)){
	   		changeStatus(recordId, 'Executando Input Manual');
   			return '';		
	   	}
	   	
		DesativarIntegracoes__c desativarIntegracoes = DesativarIntegracoes__c.getInstance('Habilitar Pedido RPA');
        if(desativarIntegracoes != Null && !desativarIntegracoes.isIntegracaoAtiva__c){
            throw new HeaderRecordHomeException(desativarIntegracoes.Mensagem__c);
        }
        
        CEC_PME_EnvioPedido_Response resEnviarPedido = CEC_PME_EnvioPedido_Service.enviarPedido(Ord.Id);
        
        
        if(resEnviarPedido == null || resEnviarPedido.Data == null){
            return 'Erro no processamento. Por favor reenviar! ';
        }
        
        changeStatus(recordId, 'Executando Input Automático');
        
        return '';
	}
    
    private static Boolean isInputManual(String cnpj) {
        Boolean activeLines = false;
        Boolean isClient = false;
       
        if(PME_ValidateCNPJ_Service.getClientMobile(cnpj).data != Null) {
            system.debug('PME_ValidateCNPJ_Service.getClientMobile(cnpj) ' + PME_ValidateCNPJ_Service.getClientMobile(cnpj));
                
            isClient = true;
            PME_ValidateCNPJ_Response res = PME_ValidateCNPJ_Service.getInfoByClientActive(cnpj);
            system.debug('res ' + res);
            activeLines = res.data != null && res.data.subscribers != null && !res.data.subscribers.isEmpty();
           
        } else {
            CEC_PME_MobileCorporateCustomer_Response resMobCorpCustomer = PME_ValidateCNPJ_Service.getMobileCorporateCustomer(cnpj);
            isClient = resMobCorpCustomer.data != Null;
            system.debug('isClient2 ' + isClient);
        }
        system.debug('isInputManual ' + (isClient && !activeLines));
        return isClient && !activeLines;
    }
    
    /*
	* Autor: Diogo Braga - Deloitte
	* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11]
   	Método responsável por deletar todos os arquivos não completed, solicitado por Botani
	*/ 
    @AuraEnabled
    public static void deleteContDocNComp(String recordId) {
        CEC_PME_OrderDocumentCleaner.deleteContDocNComp(recordId);
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
        
        List<ContentVersion> listContentVersion = [SELECT Id, 
                                                   CEC_Tipo_de_Anexo__c, 
                                                   ContentDocumentId, 
                                                   PathOnClient, 
                                                   FileExtension ,
                                                   ContentDocument.Title,
                                                   CreatedDate
                                                   FROM ContentVersion
                                                   WHERE ContentDocumentId =: setIdCDL 
                                                   AND IsLatest = true];
        
        Map<String, ContentVersion> mapLastVersionContent = new Map<String, ContentVersion>();
        for(ContentVersion contentVersion : listContentVersion) {
            String nameContent = contentVersion.ContentDocument.Title;
            nameContent = nameContent.substringBeforeLast('_');
            nameContent.remove('.pdf');
            
            if(mapLastVersionContent.containsKey(nameContent)) {
                if(contentVersion.CreatedDate > mapLastVersionContent.get(nameContent).CreatedDate) {
                    mapLastVersionContent.put(nameContent, contentVersion);
                }
            } else {
                mapLastVersionContent.put(nameContent, contentVersion);
            }
        }
        
		for(ContentVersion cv : mapLastVersionContent.values()) {
			if(String.isBlank(cv.CEC_Tipo_de_Anexo__c)){
				return false;
			}
		}
		
		return true;
	}
    
    @AuraEnabled
    public static String getSignatureContacts(Id orderId) {
        return new CEC_PME_ReSenderDocusignEnvelope().getSignatureContacts(orderId);
    }   
    
    @AuraEnabled
    public static void reSendDocusignEnvelope(String signers, Id orderId) {
        new CEC_PME_ReSenderDocusignEnvelope().reSendDocusignEnvelope(signers, orderId);
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