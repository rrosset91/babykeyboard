/*
* Autor: Diogo Braga - Deloitte
* Data: 09/06/2019
* Integração para abrir envelope na docusign
*  ---------------------------------------------------------------
*/
public class CEC_PME_IntegrationDocuSignEnvelope {
    private CEC_PME_IntegrationDocuSignTemplate integTemplate;
    private Integer recipientId = 0;
    
    private SendParameters sendParameters;
    
    private ConfRadioButtonsDocusin__mdt confRadioButtonsDocusin;
    
    public class SendParameters {
        public String orderId; 
        public List<Recipient> listClients;
		public List<Recipient> listUsersBackOffice;
        public Recipient owner;
        public String accountId;
        public String templateId; 
        public Boolean isSigningRequired;
        public Boolean isEmbedded;
    }
    
    public class Recipient {
        public Recipient(String name,String email) {
            this.name = name;
            this.email = email;
        }
        
        public Recipient(String name,String email, String anchorString) {
            this.name = name;
            this.email = email;
            this.anchorString = anchorString;
        }
        public String name;
        public String email;
        public String anchorString;
        public String recipientId;
    }
    
    public CEC_PME_IntegrationDocuSignObjectFactory.ResponseEnvelope send(SendParameters sendParameters) {
        this.sendParameters = sendParameters;
        
        confRadioButtonsDocusin = getConfRadioButtonsDocusin();
        
        integTemplate = new CEC_PME_IntegrationDocuSignTemplate();
        integTemplate.send(sendParameters.accountId, sendParameters.templateId);
        
        ServiceParameter__c serviceParameter = ServiceParameter__c.getValues('CEC_PME_DocuSignCreateEnvelope');
        
        HTTPRequest request = new HTTPRequest();
        
		String endPointMethod = serviceParameter.EndPoint__c.replace('{!accountId}', sendParameters.accountId);
		request.setEndpoint('callout:DocuSign' + endPointMethod); 
        
        String authorizationHeader = '<DocuSignCredentials><Username>' + '{!$Credential.Username}';
        authorizationHeader = authorizationHeader +'</Username><Password>' + '{!$Credential.Password}';
        authorizationHeader = authorizationHeader + '</Password><IntegratorKey>' + serviceParameter.Token__c;
        authorizationHeader = authorizationHeader +'</IntegratorKey></DocuSignCredentials>';        
        
        request.setMethod(serviceParameter.Method__c);
        request.setTimeout(Integer.valueOf(serviceParameter.Timeout__c));
        request.setBody(builderBobyRequest());
        request.setHeader('X-DocuSign-Authentication', authorizationHeader);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        
        HTTP http = new HTTP();
        HTTPResponse response = http.send(request);
        new CEC_PME_IntegrationDocuSignObjectFactory.ReponseValidator().validate(response);
        
        return (CEC_PME_IntegrationDocuSignObjectFactory.ResponseEnvelope) JSON.deserialize(response.getBody(), CEC_PME_IntegrationDocuSignObjectFactory.ResponseEnvelope.class);
    }
    
    private ConfRadioButtonsDocusin__mdt getConfRadioButtonsDocusin() {
        return [SELECT Id, 
                QuantidadeGrupos__c, 
                QuantidadeItens__c 
                FROM ConfRadioButtonsDocusin__mdt 
                LIMIT 1]; 
    }
    
    private String builderBobyRequest() {
        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeDefinition  envelopeDefinition = builderdEnvelopeDefinition();
        envelopeDefinition.emailSubject = 'Assinatura de contrato - Claro Empresas';
        envelopeDefinition.status = 'sent';
        
        return setRecipientsbyTemplate(envelopeDefinition);
    }
    
    private String setRecipientsbyTemplate(CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeDefinition envelopeDefinition) {
        String jsonString = JSON.serialize(envelopeDefinition);
        Map<String, Object> mapEnvelope = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        List<Object> listCompositeTemplates = (List<Object>) mapEnvelope.get('compositeTemplates');
        for(Object varCompositeTemplates : listCompositeTemplates) {
            Map<String, Object> mapCompositeTemplates = (Map<String, Object>) varCompositeTemplates;
            List<Object> listInlineTemplates = (List<Object>) mapCompositeTemplates.get('inlineTemplates');
            Map<String, Object> mapInlineTemplate = (Map<String, Object>) listInlineTemplates.get(0);
            Map<String, Object> mapRecipients = (Map<String, Object>) mapInlineTemplate.get('recipients');
            List<Object> listSigners = (List<Object>) mapRecipients.get('signers');
            
            if(mapCompositeTemplates.get('compositeTemplateId') == '1' && !sendParameters.isSigningRequired) {
                
                for(Object varSigner : integTemplate.getListSigners()) {
                    Map<String, Object> mapSigner = (Map<String, Object>) varSigner;
                    String roleName = (String) mapSigner.get('roleName');
                    
                    if(mapSigner.get('roleName') != null && roleName.replace(' ','').equalsIgnoreCase('FakeUser')) {
                        listSigners.add(mapSigner);
                    }
                }
                
            } else if(mapCompositeTemplates.get('compositeTemplateId') == '2' && sendParameters.isSigningRequired) {
               
                for(Object varSigner : integTemplate.getListSigners()) {
                    Map<String, Object> mapSigner = (Map<String, Object>) varSigner;

                    if(mapSigner.get('roleName') != null) {
                        String roleName = (String) mapSigner.get('roleName');
                        
                        if(sendParameters.isEmbedded && !roleName.replace(' ','').equalsIgnoreCase('FakeUser')) {
                            listSigners.add(setSignersEmbedded(mapSigner));
                        } else {
                            
                            String routingOrder = '1';
                            routingOrder = String.valueOf(sendParameters.listClients.size() + 1);
                            
                            if(roleName.equalsIgnoreCase('cliente')) {
                                
                                for(Recipient recipient : sendParameters.listClients) {
                                    if(String.isNotBlank(recipient.anchorString) && !recipient.anchorString.contains('TTSF')) {
                                        System.debug('recipient ' + JSON.serialize(recipient));
                                        Map<String, Object> mapSignerClone = ((Map<String, Object>) varSigner).clone();
                                        mapSignerClone = removeIdsSigners(mapSignerClone);
                                        mapSignerClone.put('name', recipient.name);
                                        mapSignerClone.put('email', recipient.email);
                                        mapSignerClone.put('routingOrder', routingOrder);
                                        
                                        listSigners.add(mapSignerClone);
                                    }
                                }
                            } else if(roleName.replace(' ','').equalsIgnoreCase('BackOffice')) {
                                for(Recipient recipient : sendParameters.listUsersBackOffice) {
                                    Map<String, Object> mapSignerClone = ((Map<String, Object>) varSigner).clone();
                                    mapSignerClone = removeIdsSigners(mapSignerClone);
                                    mapSignerClone.put('name', recipient.name);
                                    mapSignerClone.put('email', recipient.email);
                                    mapSignerClone.put('routingOrder', routingOrder);
                                    listSigners.add(mapSignerClone);
                                }
                            } else if(roleName.equalsIgnoreCase('Vendededor')) {
                                Recipient recipient = sendParameters.owner;
                                mapSigner.put('name', recipient.name);
                                mapSigner.put('email', recipient.email);
                                mapSigner.put('routingOrder', routingOrder);
                                listSigners.add(mapSigner);
                            } else if(roleName.replace(' ','').equalsIgnoreCase('FakeUser')) {
                                mapSigner.put('routingOrder', routingOrder);
                                mapSigner.put('recipientId', '99');
                                listSigners.add(mapSigner);
                            } else {
                                mapSigner.put('routingOrder', routingOrder);
                                listSigners.add(mapSigner);
                            }
                        }
                    }
                }
            }
        }
        
        //System.debug('JSONBody ' + JSON.serialize(mapEnvelope));               
        System.debug('JSONBody ' + mapEnvelope); 
        return JSON.serialize(mapEnvelope);
    }   
    
    private Map<String, Object> setSignersEmbedded(Map<String, Object> mapSigner) {
        mapSigner.put('clientUserId', '1');
        mapSigner.put('recipientId', '1');
        mapSigner.put('routingOrder', '1');
        mapSigner.put('email', sendParameters.listClients.get(0).email);
        mapSigner.put('name', sendParameters.listClients.get(0).name);
        
        return mapSigner;
    }
    
    private Map<String, Object> removeIdsSigners(Map<String, Object> mapSigner) {
        if(mapSigner.containsKey('recipientId')) {
            recipientId++;
            mapSigner.put('recipientId', String.valueOf(recipientId));
        }
        
        if(mapSigner.containsKey('recipientIdGuid')) {
            mapSigner.remove('recipientIdGuid');
        }
        
        if(mapSigner.containsKey('tabs')) {
            Map<String, Object> mapTabs = (Map<String, Object>) mapSigner.get('tabs');
            if(mapTabs.containsKey('signerAttachmentTabs')) {
                for(Object objectTab : (List<Object>) mapTabs.get('signerAttachmentTabs')) {
                    Map<String, Object> mapTab = (Map<String, Object>) objectTab;
                    
                    mapTab.put('recipientId', recipientId);
                    mapTab.remove('tabLabel');
                }
            }
            
        }
        
        return mapSigner;
    }
    
    private CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeDefinition builderdEnvelopeDefinition() {
        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeDefinition  envelopeDefinition = new CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeDefinition();
        envelopeDefinition.compositeTemplates = builderdListCompositeTemplate(); 
        
        return envelopeDefinition;
    }
    
    private List<CEC_PME_IntegrationDocuSignObjectFactory.CompositeTemplate>  builderdListCompositeTemplate() {
        List<CEC_PME_IntegrationDocuSignObjectFactory.CompositeTemplate> listCompositeTemplate = new List<CEC_PME_IntegrationDocuSignObjectFactory.CompositeTemplate>();
        listCompositeTemplate.add(builderCompositeTemplate(true));
        listCompositeTemplate.add(builderCompositeTemplate(false));
        
        return listCompositeTemplate;
    }
    
    private CEC_PME_IntegrationDocuSignObjectFactory.CompositeTemplate builderCompositeTemplate(Boolean isByAnchor) {
        CEC_PME_IntegrationDocuSignObjectFactory.CompositeTemplate compositeTemplate = new CEC_PME_IntegrationDocuSignObjectFactory.CompositeTemplate();
        compositeTemplate.inlineTemplates = builderListInlineTemplates(isByAnchor);
        if(isByAnchor) {
            compositeTemplate.compositeTemplateId = '1';
        } else {
            compositeTemplate.compositeTemplateId = '2';
        }
        
        return compositeTemplate;
    }
    
    private List<CEC_PME_IntegrationDocuSignObjectFactory.InlineTemplate> builderListInlineTemplates(Boolean isByAnchor) {
        List<CEC_PME_IntegrationDocuSignObjectFactory.InlineTemplate> listInlineTemplates = new List<CEC_PME_IntegrationDocuSignObjectFactory.InlineTemplate>();
        listInlineTemplates.add(builderInlineTemplate(isByAnchor));
        
        return listInlineTemplates;
    }
    
    private CEC_PME_IntegrationDocuSignObjectFactory.InlineTemplate builderInlineTemplate(Boolean isByAnchor) {
        CEC_PME_IntegrationDocuSignObjectFactory.InlineTemplate inlineTemplate = new CEC_PME_IntegrationDocuSignObjectFactory.InlineTemplate();
        if(isByAnchor) {
            inlineTemplate.sequence = '1';
        } else {
            inlineTemplate.sequence = '2';
        }
        inlineTemplate.customFields = builderAccountCustomFields();
        inlineTemplate.documents = builderListDocuments(isByAnchor);
        inlineTemplate.recipients = builderEnvelopeRecipients(isByAnchor);
        
        return inlineTemplate;
    }
    
    private CEC_PME_IntegrationDocuSignObjectFactory.AccountCustomFields builderAccountCustomFields() {
        CEC_PME_IntegrationDocuSignObjectFactory.AccountCustomFields accountCustomFields = new CEC_PME_IntegrationDocuSignObjectFactory.AccountCustomFields();
        accountCustomFields.textCustomFields = builderListTextCustomFields();
        
        return accountCustomFields;
    }
    
    private List<CEC_PME_IntegrationDocuSignObjectFactory.TextCustomFields> builderListTextCustomFields() {
        List<CEC_PME_IntegrationDocuSignObjectFactory.TextCustomFields> listTextCustomFields = new List<CEC_PME_IntegrationDocuSignObjectFactory.TextCustomFields>();
        listTextCustomFields.add(builderTextCustomFields());
        
        return listTextCustomFields;
    }
    
    private CEC_PME_IntegrationDocuSignObjectFactory.TextCustomFields builderTextCustomFields() {
        CEC_PME_IntegrationDocuSignObjectFactory.TextCustomFields textCustomFields = new CEC_PME_IntegrationDocuSignObjectFactory.TextCustomFields();
        textCustomFields.name = '##SFOrder';
        textCustomFields.value = sendParameters.orderId; 
        textCustomFields.show = true;
        textCustomFields.required = false;
        
        return textCustomFields;
    }
    
    private List<CEC_PME_IntegrationDocuSignObjectFactory.Document> builderListDocuments(Boolean isByAnchor) {
        List<CEC_PME_IntegrationDocuSignObjectFactory.Document> listDocuments = new List<CEC_PME_IntegrationDocuSignObjectFactory.Document>();
        if(isByAnchor) {
            listDocuments.addAll(builderDocumentsOrder(listDocuments.size()));
        } else {
            listDocuments.addAll(builderDocumentsTemplate());
        }
        
        return listDocuments;
    }
    
    private List<CEC_PME_IntegrationDocuSignObjectFactory.Document> builderDocumentsOrder(Integer count) {
        List<CEC_PME_IntegrationDocuSignObjectFactory.Document> listDocuments = new List<CEC_PME_IntegrationDocuSignObjectFactory.Document>();
        
        List<ContentDocumentLink> listDocumentsLink = [SELECT Id,
                                                       LinkedEntityId, 
                                                       ContentDocumentId
                                                       FROM ContentDocumentLink 
                                                       WHERE LinkedEntityId = :sendParameters.orderId];
        
        Set<Id> setContentDocIds = new Set<Id>(); 
        for(ContentDocumentLink documentsLink : listDocumentsLink) {
            setContentDocIds.add(documentsLink.ContentDocumentId);
        }
        List<ContentVersion> listContentVersion = [SELECT Id,
                                                   ContentDocumentId,
                                                   FileExtension, 
                                                   Title, 
                                                   VersionData, 
                                                   IsLatest
                                                   FROM ContentVersion 
                                                   WHERE ContentDocumentId IN :setContentDocIds 
                                                   AND IsLatest = true];
        
        System.debug('TESTE -> Nome lista documentos enviados pra DocSign ' + listContentVersion);
        for(ContentVersion contentVersion : listContentVersion) { System.debug('TESTE -> Nome lista documentos enviados pra DocSign ' + contentVersion.Title);
            if(!contentVersion.Title.endsWithIgnoreCase('_Sent') && !contentVersion.Title.endsWithIgnoreCase('_Completed')) {
                count++;
                CEC_PME_IntegrationDocuSignObjectFactory.Document document = new CEC_PME_IntegrationDocuSignObjectFactory.Document();
                document.documentId       = String.valueOf(count);
                document.name             = contentVersion.Title;
                document.documentBase64   = EncodingUtil.base64Encode(contentVersion.VersionData); 
                document.fileExtension    = contentVersion.FileExtension;
                document.includeInDownload = 'true';
                document.order = '1';
                document.pages = '1';
                listDocuments.add(document);  
            }
        }
        System.debug('TESTE -> Nome lista documentos enviados pra DocSign  contentVersion contentVersion' + listDocuments);
        return listDocuments;
    }
    
    private List<CEC_PME_IntegrationDocuSignObjectFactory.Document> builderDocumentsTemplate() {
        List<CEC_PME_IntegrationDocuSignObjectFactory.Document> listDocuments = integTemplate.getListDocuments();
        for(CEC_PME_IntegrationDocuSignObjectFactory.Document varDocument : listDocuments) {
            varDocument.documentBase64 = new CEC_PME_IntegrationDocuSignDocument().send(sendParameters.templateId, varDocument.documentId, sendParameters.accountId);
        }
        
        return listDocuments;
    }
    
    private CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients builderEnvelopeRecipients(Boolean isByAnchor) {
        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients envelopeRecipients = new CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients();
        
        if (sendParameters.isSigningRequired) {
            envelopeRecipients.signers = builderListSigners(isByAnchor);
        } else {
        	envelopeRecipients.carbonCopies = builderListCarbons();
            envelopeRecipients.signers = new List<CEC_PME_IntegrationDocuSignObjectFactory.Signer>();
        }
        
        return envelopeRecipients;
    }
    
    private List<CEC_PME_IntegrationDocuSignObjectFactory.Signer> builderListSigners(Boolean isByAnchor) {
        List<CEC_PME_IntegrationDocuSignObjectFactory.Signer> listSigners =  new List<CEC_PME_IntegrationDocuSignObjectFactory.Signer>();

        if(isByAnchor) {
            for(Integer i = 1; i <= sendParameters.listClients.size(); i++) {
                listSigners.add(builderSigner(sendParameters.listClients.get(i-1), i));  
            }
        }
        
        return listSigners;
    }   
    
    private CEC_PME_IntegrationDocuSignObjectFactory.Signer builderSigner(Recipient recipient, Integer count) {
        CEC_PME_IntegrationDocuSignObjectFactory.Signer signer = new CEC_PME_IntegrationDocuSignObjectFactory.Signer();
        
        signer.tabs = builderEnvelopeRecipientTabs(recipient.anchorString, String.valueOf(recipientId));

        if(sendParameters.isEmbedded) {
            recipient.recipientId = '1';
            signer.clientUserId = '1';
            signer.recipientId = '1';
            signer.routingOrder = '1';
            signer.email = sendParameters.listClients.get(0).email;
            signer.name = sendParameters.listClients.get(0).name;
        } else {
            signer.routingOrder = String.valueOf(count);
            signer.email = recipient.email;
            signer.name = recipient.name;
            recipientId++;
            
            recipient.recipientId = String.valueOf(recipientId);
            signer.recipientId = String.valueOf(recipientId);            
        }
        
        return signer;
    }
	
    private List<CEC_PME_IntegrationDocuSignObjectFactory.Carbon> builderListCarbons() {
        List<CEC_PME_IntegrationDocuSignObjectFactory.Carbon> listCarbons =  new List<CEC_PME_IntegrationDocuSignObjectFactory.Carbon>();
        
        for(Integer i = 1; i <= sendParameters.listClients.size(); i++) {
            listCarbons.add(builderCarbon(sendParameters.listClients.get(i-1), i));  
        }
        
        return listCarbons;
    }     
    
    private CEC_PME_IntegrationDocuSignObjectFactory.Carbon builderCarbon(Recipient recipient, Integer count) {
        CEC_PME_IntegrationDocuSignObjectFactory.Carbon carbon = new CEC_PME_IntegrationDocuSignObjectFactory.Carbon();
        
        carbon.routingOrder = '1';
        carbon.email = recipient.email;
        carbon.name = recipient.name;
        
        recipientId++;
        carbon.recipientId = String.valueOf(recipientId);
        
        return carbon;
    }   
    
    private CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipientTabs builderEnvelopeRecipientTabs(String anchorString, String recipientId) {
        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipientTabs envelopeRecipientTabs = new CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipientTabs();
        envelopeRecipientTabs.signHereTabs = builderSignHereTabs(anchorString, recipientId);
        envelopeRecipientTabs.initialHereTabs = builderInitialHereTabs(anchorString, recipientId);
        if('RLSF#001'.equalsIgnoreCase(anchorString)) {
            envelopeRecipientTabs.radioGroupTabs =  builderRadioGroupTabs();
            envelopeRecipientTabs.textTabs = builderTextTabs();
            envelopeRecipientTabs.dateSignedTabs = builderDateSignedTabs();
        }
        
        return envelopeRecipientTabs;
    }
    
    private List<CEC_PME_IntegrationDocuSignObjectFactory.InitialHere> builderInitialHereTabs(String anchorString, String recipientId) {
        List<CEC_PME_IntegrationDocuSignObjectFactory.InitialHere> listInitialHere = new List<CEC_PME_IntegrationDocuSignObjectFactory.InitialHere>();
        listInitialHere.add(builderInitialHere(anchorString, recipientId));
        
        return listInitialHere;
    }
    
    private CEC_PME_IntegrationDocuSignObjectFactory.InitialHere builderInitialHere(String anchorString, String recipientId) {
        Boolean isContainsAnchor = String.isNotBlank(anchorString);
        isContainsAnchor &= anchorString.contains('RLSF#00') || anchorString.contains('TTSF#00');
        if(isContainsAnchor) {
            CEC_PME_IntegrationDocuSignObjectFactory.InitialHere initialHere = new CEC_PME_IntegrationDocuSignObjectFactory.InitialHere();
            initialHere.recipientId = recipientId;
            if(anchorString.contains('RLSF#00')) {
                initialHere.anchorString = anchorString.replace('RLSF#00','RBSF#0');
            } else {
                String strDonorPosition = anchorString.replace('TTSF#00', '');
                Integer intDonorPosition = integer.valueOf(strDonorPosition);
                initialHere.anchorString = 'RBSF#0' + (intDonorPosition + 4);
            }
            
            initialHere.required = String.valueOf(sendParameters.isSigningRequired);
            
            return initialHere;
        } else {
            return null;
        }
    }
    
    private List<CEC_PME_IntegrationDocuSignObjectFactory.DateSigned> builderDateSignedTabs() {
        List<CEC_PME_IntegrationDocuSignObjectFactory.DateSigned> dateSignedTabs = new List<CEC_PME_IntegrationDocuSignObjectFactory.DateSigned>();
        CEC_PME_IntegrationDocuSignObjectFactory.DateSigned dateSigned = new CEC_PME_IntegrationDocuSignObjectFactory.DateSigned();
        
        dateSigned.anchorString = 'DATE#1';
        dateSignedTabs.add(dateSigned);
        return dateSignedTabs;
    }
    
    private List<CEC_PME_IntegrationDocuSignObjectFactory.TextTab> builderTextTabs() {
        List<CEC_PME_IntegrationDocuSignObjectFactory.TextTab> listTextTabs = new List<CEC_PME_IntegrationDocuSignObjectFactory.TextTab>();
        CEC_PME_IntegrationDocuSignObjectFactory.TextTab textTab = new CEC_PME_IntegrationDocuSignObjectFactory.TextTab();
        textTab.anchorString = 'LOCALIZATION#1';
        textTab.required = 'true';
        textTab.width = '150';
        textTab.height = '20';
        textTab.anchorYOffset = '-10';
        listTextTabs.add(textTab);
        
        return listTextTabs;
    }
    
    private List<CEC_PME_IntegrationDocuSignObjectFactory.RadioGroupTab> builderRadioGroupTabs() {
        List<CEC_PME_IntegrationDocuSignObjectFactory.RadioGroupTab> radioGroupTabs = new List<CEC_PME_IntegrationDocuSignObjectFactory.RadioGroupTab>();
        for(integer i = 1; i <= confRadioButtonsDocusin.QuantidadeGrupos__c; i++) {
            String idRadioG;
            if(i < 10) {
                idRadioG = '0' + String.valueOf(i);
            } else {
                idRadioG = String.valueOf(i);
            }
            radioGroupTabs.add(builderRadioGroupTab('RADIO#' + idRadioG + '#'));
        }
        return radioGroupTabs;
    }
    
    private CEC_PME_IntegrationDocuSignObjectFactory.RadioGroupTab builderRadioGroupTab(String rootAnchorStringR) {
        CEC_PME_IntegrationDocuSignObjectFactory.RadioGroupTab radioGroupTab = new CEC_PME_IntegrationDocuSignObjectFactory.RadioGroupTab();
        radioGroupTab.radios = new List<CEC_PME_IntegrationDocuSignObjectFactory.Radio>();
        radioGroupTab.groupName = rootAnchorStringR;
        for(integer i = 1; i <= confRadioButtonsDocusin.QuantidadeItens__c; i++) {
            radioGroupTab.radios.add(builderRadio(rootAnchorStringR + i));
        }
        return radioGroupTab;
    }
    
    private CEC_PME_IntegrationDocuSignObjectFactory.Radio builderRadio(String anchorString) {
        CEC_PME_IntegrationDocuSignObjectFactory.Radio radio = new CEC_PME_IntegrationDocuSignObjectFactory.Radio();
        radio.anchorString = anchorString;
        radio.required = 'true';
        return radio;
    }
    
    private List<CEC_PME_IntegrationDocuSignObjectFactory.SignHere> builderSignHereTabs(String anchorString, String recipientId) {
        List<CEC_PME_IntegrationDocuSignObjectFactory.SignHere> listSignHere = new List<CEC_PME_IntegrationDocuSignObjectFactory.SignHere>();
        listSignHere.add(builderSignHere(anchorString, recipientId));
        
        return listSignHere;
    }
    
    private CEC_PME_IntegrationDocuSignObjectFactory.SignHere builderSignHere(String anchorString, String recipientId) {
        CEC_PME_IntegrationDocuSignObjectFactory.SignHere signHere = new CEC_PME_IntegrationDocuSignObjectFactory.SignHere();
        signHere.recipientId = recipientId;
        signHere.anchorString = anchorString;
        signHere.optional = String.valueOf(!sendParameters.isSigningRequired);
        
        return signHere;
    }

    public Set<String> setRequiredRecipientsId() {
        Set<String> setRecipientsId = new Set<String>();        
        for(Recipient recipient : sendParameters.listClients) {                          
            if(String.isNotBlank(recipient.recipientId)) {                
                setRecipientsId.add(recipient.recipientId);              
            }
        }         
        return setRecipientsId;   
    }
}