@isTest
public class CEC_PME_IntegrationDocuSignObjFactTest {
	@isTest
    static void testObjectFactory() {
        CEC_PME_IntegrationDocuSignObjectFactory.ResponseEnvelope respEnv = new CEC_PME_IntegrationDocuSignObjectFactory.ResponseEnvelope();
        respEnv.envelopeId = '';
        respEnv.status = '';
        respEnv.statusDateTime = Date.today();
        respEnv.uri = '';
        respEnv.errorCode = '';
        respEnv.message = '';
        
        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeDefinition envDef = new CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeDefinition();
        envDef.emailSubject = '';
        envDef.status = '';   
        
		CEC_PME_IntegrationDocuSignObjectFactory.TextCustomFields testCustomFields = new CEC_PME_IntegrationDocuSignObjectFactory.TextCustomFields();        
        testCustomFields.name = '';
        testCustomFields.value = '';
        testCustomFields.required = false;
        testCustomFields.show = false;
        
        List<CEC_PME_IntegrationDocuSignObjectFactory.TextCustomFields> lstTextCustomFields = new List<CEC_PME_IntegrationDocuSignObjectFactory.TextCustomFields>();
        lstTextCustomFields.add(testCustomFields);
        
        CEC_PME_IntegrationDocuSignObjectFactory.AccountCustomFields accntCustomFields = new CEC_PME_IntegrationDocuSignObjectFactory.AccountCustomFields();        
        accntCustomFields.textCustomFields = lstTextCustomFields;
        
		CEC_PME_IntegrationDocuSignObjectFactory.Document document = new CEC_PME_IntegrationDocuSignObjectFactory.Document();        
        document.documentBase64 = '';
        document.documentId = '';
        document.fileExtension = '';
        document.name = '';
        document.uri = '';
        document.order = '';
        document.pages = '';
        document.display = '';
        document.includeInDownload = '';
        document.signerMustAcknowledge = '';
        document.templateLocked = '';
        document.templateRequired = '';
        document.documentGroup = ''; 
        
        List<CEC_PME_IntegrationDocuSignObjectFactory.Document> lstDocument = new List<CEC_PME_IntegrationDocuSignObjectFactory.Document>();        
        lstDocument.add(document);
        
        CEC_PME_IntegrationDocuSignObjectFactory.Signer signer = new CEC_PME_IntegrationDocuSignObjectFactory.Signer();
        signer.email = '';
        signer.name = '';
        signer.status = '';
        signer.recipientId = '';
        signer.routingOrder = '';
        signer.clientUserId = ''; 
        //Signer.tabs = envRecTab;
        
        List<CEC_PME_IntegrationDocuSignObjectFactory.Signer> lstSigner = new List<CEC_PME_IntegrationDocuSignObjectFactory.Signer>();
        lstSigner.add(signer);
        
        CEC_PME_IntegrationDocuSignObjectFactory.SignHere signHere = new CEC_PME_IntegrationDocuSignObjectFactory.SignHere();
        signHere.recipientId = '';
        signHere.anchorString = '';
        signHere.optional = '';
        
        List<CEC_PME_IntegrationDocuSignObjectFactory.SignHere> lstSignHere = new List<CEC_PME_IntegrationDocuSignObjectFactory.SignHere>();
        lstSignHere.add(signHere);        
        
        CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipientTabs envRecTabs = new CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipientTabs();
        envRecTabs.signHereTabs = lstSignHere;     
        
		CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients envRec = new CEC_PME_IntegrationDocuSignObjectFactory.EnvelopeRecipients();
        envRec.signers = lstSigner;        
        
        CEC_PME_IntegrationDocuSignObjectFactory.InlineTemplate inlineTemp = new CEC_PME_IntegrationDocuSignObjectFactory.InlineTemplate();
        
        inlineTemp.sequence = '1';        
        inlineTemp.customFields = accntCustomFields;
        inlineTemp.documents = lstDocument;
        inlineTemp.recipients = envRec;        
        List<CEC_PME_IntegrationDocuSignObjectFactory.InlineTemplate> lstInlineTemp = new List<CEC_PME_IntegrationDocuSignObjectFactory.InlineTemplate>();
        lstInlineTemp.add(inlineTemp);
        
        CEC_PME_IntegrationDocuSignObjectFactory.CompositeTemplate compTemp = new CEC_PME_IntegrationDocuSignObjectFactory.CompositeTemplate();
        compTemp.compositeTemplateId = '00001';
        compTemp.inlineTemplates = lstInlineTemp;     
        
        List<CEC_PME_IntegrationDocuSignObjectFactory.CompositeTemplate> lstCompTemp = new List<CEC_PME_IntegrationDocuSignObjectFactory.CompositeTemplate>();
        lstCompTemp.add(compTemp);
        envDef.compositeTemplates = lstCompTemp;
        
        
        

        

        
        
        
        
        
        
        
        
        
        
    }
}