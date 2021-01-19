/*
* Autor: Marcos Silva - Deloitte
* Data: 10/12/2018
* Descrição: CEC FASE 1 + SQUAD PME: Classe utilizada para exibição dos contratos anexados ao pedido.
*/
public class CEC_PME_FilePreviewController { 
  
    @TestVisible
    private CEC_PME_FilePreviewController() {}
    
    private static final String REC_STATUS_PREANALISE = 'Pré Analise da Documentação';
    private static final String REC_STATUS_DEVOLVIDA = 'Documentação Devolvida';
    private static final String REC_STATUS_APROVADA = 'Documentação Aprovada';
    private static final String CONTENT_VERSION = 'ContentVersion';
    private static final String SELECIONE = '-- Selecione --';
    private static final String TIPO_ANEXO = 'CEC_Tipo_de_Anexo__c';
    private static final String DOCUSIGN = 'Docusign';
    
    
    
   /*
   * *******  
   * 
   * COMENTADO EM 22/09/2020 - 
   * Autor:LUCIANO DO CARMO - GLobalhitss
   * Descrição: foi substituído pelo método isPMEAdmin 
   * 
   * 
   * ******** 
    private static final String PERFIL_ADMTI = 'Admin TI PME';
    private static final String PERFIL_ADMPT = 'Administrador do sistema';
    private static final String PERFIL_ADM = 'System Administrator';
    private static final String PERFIL_SUPORTE = 'Suporte Claro';
   */
    
    
    
    
    
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Método utilizado para carragamento dos anexos a serem exibidos na tela.
    */     
    @AuraEnabled
    public static List<ContentVersion> carregar(String Id){
        Order order = [SELECT Id, 
                       status 
                       FROM Order 
                       WHERE Id = :Id];
        
        Boolean isStatusBackOffice = checkIStatusBackOffice(order);
       
        if(!isStatusBackOffice && !isPMEAdmin() && !isNotActiveIntegration()) {
            return new List<ContentVersion>();
        }
       
 		Set<String> setContentLink = new Set<String>();
        
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId , ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: Id]) {
            setContentLink.add(cdl.ContentDocumentId);
        }
        
        List<ContentVersion> listContentVersion = [SELECT Id, 
                                                   CEC_Tipo_de_Anexo__c, 
                                                   ContentDocumentId, 
                                                   PathOnClient, 
                                                   FileExtension ,
                                                   ContentDocument.Title,
                                                   CreatedDate
                                                   FROM ContentVersion
                                                   WHERE ContentDocumentId =: setContentLink 
                                                   AND IsLatest = true];
        
        Map<String, ContentVersion> mapLastVersionContent = new Map<String, ContentVersion>();
        for(ContentVersion contentVersion : listContentVersion) {

            String nameContent = contentVersion.ContentDocument.Title;
            nameContent = nameContent.substringBeforeLast('.').substringBeforeLast('_');
            if(mapLastVersionContent.containsKey(nameContent)) {
                if(contentVersion.CreatedDate > mapLastVersionContent.get(nameContent).CreatedDate) {
                    mapLastVersionContent.put(nameContent, contentVersion);
                }
            } else {
                mapLastVersionContent.put(nameContent, contentVersion);
            }
        }      
        
        return mapLastVersionContent.values();
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método utilizado para verificar se o pedido encontra-se com um status da área de backoffice.
    */      
    private static Boolean checkIStatusBackOffice(Order order) {
        Boolean isStatusBackOffice = false;
        isStatusBackOffice = isStatusBackOffice || order.status.equalsIgnoreCase(REC_STATUS_PREANALISE);
        isStatusBackOffice = isStatusBackOffice || order.status.equalsIgnoreCase(REC_STATUS_DEVOLVIDA);
        isStatusBackOffice = isStatusBackOffice || order.status.equalsIgnoreCase(REC_STATUS_APROVADA);
        return isStatusBackOffice;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Método utilizado para carragamento dos valores disponível para o campo Tipo de anexo.
    */      
    @AuraEnabled
    public static List<String> obterPickListValues(){
    	List<String> pickListValuesList = new List<String>();
    	pickListValuesList.add(SELECIONE);
    	
    	Schema.DescribeFieldResult descFieldResult = Schema.getGlobalDescribe().get(CONTENT_VERSION).getDescribe().fields.getMap().get(TIPO_ANEXO).getDescribe();
        List<Schema.PicklistEntry> picklistEntry = descFieldResult.getPicklistValues();
        
    	for(Schema.PicklistEntry pe : picklistEntry){
    		pickListValuesList.add(pe.getValue());	
    	}
    	
    	return pickListValuesList;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Método utilizado para gravação do valor do campo Tipo de anexo escolhido em tela pelo usuário.
    */      
    @AuraEnabled
    public static void saveTipoAnexo(String Id, String tipoAnexo, String title)
    {
        String docTitle = title.substringBeforeLast('_');

     	Set<String> setContentLink = new Set<String>();
        
		for(ContentDocumentLink objContentDocumentLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: Id])
        {
            setContentLink.add(objContentDocumentLink.ContentDocumentId);
        }
        
        List<ContentVersion> listContentVersion = [SELECT Id, 
                                                   CEC_Tipo_de_Anexo__c, 
                                                   ContentDocumentId, 
                                                   PathOnClient, 
                                                   FileExtension ,
                                                   ContentDocument.Title,
                                                   CreatedDate
                                                   FROM ContentVersion
                                                   WHERE ContentDocumentId IN: setContentLink 
                                                   AND ContentDocument.Title LIKE :docTitle+'%'
                                                   AND IsLatest = true];        
       
        for(ContentVersion objContentVersion : listContentVersion)
        {
            objContentVersion.CEC_Tipo_de_Anexo__c = tipoAnexo;
        }
            	
    	update listContentVersion;
    }  

    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Método utilizado para pesquisar o papel CPC do usuário
    */      
    @AuraEnabled
    public static String fetchUser(String orderId) {
        if(isPMEAdmin()) {
            return 'Admin TI PME';
        }
        
        if(isNotActiveIntegration()) {
            return 'Not Active Integration';
        }
        
        User user = [SELECT id, RolerFormula__c FROM User where id =: userInfo.getUserId()];

        return user.RolerFormula__c;
    }
    
    /*
    * Autor: Diogo Braga
    * Descrição: CEC FASE 1 + SQUAD PME: Método utilizado para verificar se a integração do DocuSign esta ativa.
    */      
    @TestVisible
    private static Boolean isNotActiveIntegration() {
        
        DesativarIntegracoes__c integrationSwitch = [SELECT isIntegracaoAtiva__c, 
                                                     Mensagem__c 
                                                     FROM DesativarIntegracoes__c
                                                     WHERE Name = :DOCUSIGN
                                                     LIMIT 1];

        return !integrationSwitch.isIntegracaoAtiva__c;
    }
    
    /*
    * Autor: Marcos Silva
    * Descrição: CEC FASE 1 + SQUAD PME: Método utilizado para verificar se o usuário é um administrador do sistema.
    */ 
    
  /*
   * *******  
   * 
   * COMENTADO EM 22/09/2020 - 
   * Autor:LUCIANO DO CARMO - GLobalhitss
   * Descrição: foi substituído pelo método isPMEAdmin 
   * 
   * 
   * ********
    private static Boolean isPMEAdmin() {
        String userProfileName = [SELECT Id, 
                                  Name
                                  FROM Profile
                                  WHERE Id = : System.UserInfo.getProfileId()].name;
        
        boolean isAdm = userProfileName.equalsIgnoreCase(PERFIL_ADMTI);
        isAdm = isAdm || userProfileName.equalsIgnoreCase(PERFIL_ADMPT); 	// adição de perfil adm padrão
        isAdm = isAdm || userProfileName.equalsIgnoreCase(PERFIL_ADM); 		// adição de perfil adm padrão
        isAdm = isAdm || userProfileName.equalsIgnoreCase(PERFIL_SUPORTE); 	// adição de perfil adm que será utilizado em produção
        return isAdm;
    }
    
    */
    
      public static Boolean isPMEAdmin()
            {
                Boolean hasCustomPermission = FeatureManagement.checkPermission('SOLAR_PME_Termos'); 
                return hasCustomPermission;
            }      
    
    
}