/*
* Autor: Diogo Braga - Deloitte
* Data: 09/06/2019
* classe contendo os Object Factorys utilizados nas integrtações com a Docusign 
*  ---------------------------------------------------------------
*/
public class CEC_PME_IntegrationDocuSignObjectFactory {
    
    virtual class Response {
        public String errorCode {get;set;} 
        public String message {get;set;}
    }
    
    public class ResponseEnvelope extends Response {
        public String envelopeId{get;set;}
        public String uri{get;set;}
        public Datetime statusDateTime{get;set;}
        public String status{get;set;}
    }

    public class EnvelopeDefinition {
        public String emailSubject{get;set;}
        public String status{get;set;}
        public List<CompositeTemplate> compositeTemplates{get;set;}
    }
    
    public class CompositeTemplate {
        public String compositeTemplateId{get;set;}
        public List<InlineTemplate> inlineTemplates{get;set;}
    }
    
    public class InlineTemplate {
        public AccountCustomFields customFields{get;set;}
        public List<Document> documents{get;set;}
        public String sequence{get;set;}
        public EnvelopeRecipients recipients{get;set;}
    }
    
    public class EnvelopeRecipients extends Response {
        
        public List<Signer> signers{get;set;}
        public List<Carbon> carbonCopies{get;set;}
    }
    
    public class Signer {
        public String email{get;set;}
        public String name{get;set;}
        public String status{get;set;}
        public String recipientId{get;set;}
        public String routingOrder{get;set;}
        public String clientUserId{get;set;}
        public String recipientIdGuid{get;set;}
        public EnvelopeRecipientTabs tabs{get;set;}
    }
    
    public class Carbon {
        public String email{get;set;}
        public String name{get;set;}
        public String recipientId{get;set;}
        public String routingOrder{get;set;}
        public String status{get;set;}        
        public String clientUserId{get;set;}
    }    
    
    public class EnvelopeRecipientTabs {
        public List<SignHere> signHereTabs{get;set;}
        public List<RadioGroupTab> radioGroupTabs{get;set;}
        public List<TextTab> textTabs{get;set;}
        public List<DateSigned> dateSignedTabs{get;set;}
    }
    
    public class DateSigned {
        public String anchorString{get;set;}
    }
    
    public class RadioGroupTab {
        public String groupName{get;set;}
        public List<Radio> radios{get;set;}
    }
    
    public class Radio {
        public String anchorString{get;set;}
        public String required{get;set;}
    }
    
    public class TextTab {
        public String anchorString{get;set;}
        public String anchorYOffset{get;set;}
        public String required{get;set;}
        public String width{get;set;}
        public String height{get;set;}
    }
    
    public class SignHere {
        public String recipientId{get;set;}
        public String anchorString{get;set;}
        public String optional{get;set;}
    }
    
    public class Document {
        public String documentBase64{get;set;}
        public String documentId{get;set;}
        public String fileExtension{get;set;}
        public String name{get;set;}
        public String uri{get;set;}
        public String order{get;set;}
        public String pages{get;set;}
        public String display{get;set;}
        public String includeInDownload{get;set;}
        public String signerMustAcknowledge{get;set;}
        public String templateLocked{get;set;}
        public String templateRequired{get;set;}
        public String documentGroup{get;set;}
    }
    
    public class AccountCustomFields {
        public List<TextCustomFields> textCustomFields{get;set;}
    }
    
    public class TextCustomFields {
        public String name{get;set;}
        public String value{get;set;}
        public Boolean show{get;set;}
        public Boolean required{get;set;}
    }
}