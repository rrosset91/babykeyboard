/*-------------------------------------------------------------------------------------------------------
--- Company: Deloitte Brasil 
--- Author: RLdO
--- Description: CEC FASE 1 COMERCIAL: fabrica de objetos Salesforce para ser utilizada em classes de teste
--- Date: 17/10/2018
-------------------------------------------------------------------------------------------------------
--- Author: Squad Canais Críticos 
--- Description: Inclusão do método: HttpResponse sendReq(String serviceName, Object body)
--- 			 utilizando a config personalizada e a credencial nomeada referente a integração
--- Date: 03/06/2018
-------------------------------------------------------------------------------------------------------*/
@isTest
public class CEC_SobjectFactory
{
    public static final Profile PROF_ADM;
    static
    {
        list<Profile> lLstProf = [SELECT Id FROM Profile WHERE PermissionsAuthorApex = true limit 1];
        system.assert(!lLstProf.isEmpty(), 'Erro perfil');
        PROF_ADM = lLstProf[0];
    }
    
    public static User getUser()
    {
        User usuario1 = new user(firstName = 'test', lastName = 'test1', Alias = 'alias', Email = 'teste@claro.com.br',
                                 Username = 'teste@claro.com.br' + UserInfo.getOrganizationId(), Profileid = PROF_ADM.Id, LanguageLocaleKey = 'pt_BR',
                                 EmailEncodingKey = 'ISO-8859-1', LocaleSidKey = 'pt_BR', TimeZoneSidKey = 'America/Sao_Paulo', IsActive = true);
        usuario1.CommunityNickname = usuario1.lastName;
        usuario1.FederationIdentifier = '123456';
        return usuario1;
    }
    
    public static Product2 getProduct()
    {
        return new Product2(IsActive = true, Name = 'NomeProduto',  ProductCode = '1234');
    }
    
    public static PricebookEntry getPricebookEntry(Product2 aProd, Pricebook2 aPbk)
    {
        PricebookEntry lPbe = new PricebookEntry(IsActive = true, UnitPrice = 100);
        if (aProd != null && String.isNotBlank(aProd.Id)) lPbe.Product2Id = aProd.Id;
        if (aPbk != null && String.isNotBlank(aPbk.Id)) lPbe.Pricebook2Id = aPbk.Id;
        return lPbe;
    }
    
    public static PricebookEntry getStdPricebookEntry(Product2 aProd)
    {
        PricebookEntry lPbe = new PricebookEntry(IsActive = true, UnitPrice = 100);
        if (aProd != null && String.isNotBlank(aProd.Id)) lPbe.Product2Id = aProd.Id;
        lPbe.Pricebook2Id = Test.getStandardPricebookId();
        return lPbe;
    }
    
    public static Account getAccount()
    {
        return new Account(Name = 'Test Claro');
    }
    
    public static Contact getContact()
    {
        return getContact(null);
    }
    public static Contact getContact(Account aAcc)
    {
        Contact lCtt = new Contact(FirstName = 'Test', LastName = 'Contact');
        if (aAcc != null && String.isNotBlank(aAcc.Id)) lCtt.AccountId = aAcc.Id;
        return lCtt;
    }
    
    public static Opportunity getOpportunity(Account aAcc)
    {
        Opportunity lOpp = new Opportunity(Name = 'Opp Teste', StageName = 'Qualificação', CloseDate = system.today().addDays(7));
        if (aAcc != null && String.isNotBlank(aAcc.Id)) lOpp.AccountId = aAcc.Id;
        return lOpp;
    }
    
    public static OpportunityLineItem getOppLineItem(Opportunity aOpp, PricebookEntry aPbe)
    {
        OpportunityLineItem lOppLI = new OpportunityLineItem(Quantity = 1, UnitPrice = 100);
        if (aOpp != null && String.isNotBlank(aOpp.Id)) lOppLI.OpportunityId = aOpp.Id;
        if (aPbe != null && String.isNotBlank(aPbe.Id)) lOppLI.PricebookEntryId = aPbe.Id;
        return lOppLI;
    }
    
    public static Order getOrder(Account aAcc)
    {
        Order lOrder = new Order(EffectiveDate = system.today().addDays(7), Status = 'Em Andamento');
        if (aAcc != null && String.isNotBlank(aAcc.Id)) lOrder.AccountId = aAcc.Id;
        return lOrder;
    }
    
    public static OrderItem getOrderItem(Order aOrder, PricebookEntry aPbe)
    {
        OrderItem lOppLI = new OrderItem(Quantity = 1, UnitPrice = 100);
        if (aOrder != null && String.isNotBlank(aOrder.Id)) lOppLI.OrderId = aOrder.Id;
        if (aPbe != null && String.isNotBlank(aPbe.Id)) lOppLI.PricebookEntryId = aPbe.Id;
        return lOppLI;
    }
    
    public static ContentVersion getContentVersion()
    {
        ContentVersion lContentVersion = new ContentVersion(Title = 'RG', PathOnClient = 'rg.jpg',
                                                            VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        return lContentVersion;
    }
    
    public static List<ContentVersion> getListContentVersion(Integer aQuantity)
    {
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        for (Integer i = 0; i < aQuantity; i++) {
            ContentVersion sObjContentVersion = getContentVersion();
            lstContentVersion.add(sObjContentVersion);
        }
        return lstContentVersion;
    }
    
    public static ContentDocumentLink getContentDocLink(ContentDocument aDoc, Sobject aSobj)
    {
        ContentDocumentLink lCdl = new ContentDocumentLink(ShareType = 'I');
        if (aDoc != null && String.isNotBlank(aDoc.Id)) lCdl.ContentDocumentId = aDoc.Id;
        if (aSobj != null && String.isNotBlank(aSobj.Id)) lCdl.LinkedEntityId = aSobj.Id;
        return lCdl;
    }
    
    public static SubjectAdministration__c getSubjectAdministration()
    {
        SubjectAdministration__c lSubjectAdministration = new SubjectAdministration__c();
        lSubjectAdministration.Name = 'CANCELAMENTO > NÃO CONSEGUE CANCELAR';
        lSubjectAdministration.Reason__c = 'CANCELAMENTO';
        lSubjectAdministration.SubReason__c = 'NÃO CONSEGUE CANCELAR';
        lSubjectAdministration.BusinessUnit__c = 'Claro;Claro DTH;Embratel';
        lSubjectAdministration.Classification__c = 'TUP;Banda Larga;Claro Fone;';
        return lSubjectAdministration;
    }
    
    
    public static Case getCase()
    {
        Case lCase = new Case();
        lCase.BusinessUnit__c = 'Claro';
        lCase.Grouping__c = 'Consumidor.gov';
        lCase.Channel__c = 'Consumidor.gov';
        lCase.InputType__c = 'Site Consumidor.gov';
        lCase.Status = 'New';
        lCase.SubStatus__c = 'Não Iniciado';
        lCase.SituationCase__c = 'Open';
        lCase.InputType__c = 'Site Consumidor.gov';
        lCase.SupportArea__c = 'FINANCEIRO';
        lCase.AdditionalInformation__c = 'teste;teste2;teste3';
        lCase.SlaStartDate = System.now();
        lCase.IsStopped  = TRUE;
        lCase.OpenDateRobot__c = system.now();
        LCase.Contract__c = '999/999999999';
        
        return lCase;
    }
    
    public static Case getCaseLGPD()
    {
        Case lCase = new Case();
        lCase.BusinessUnit__c = 'Claro';
        lCase.Grouping__c = 'Consumidor.gov';
        lCase.Channel__c = 'Consumidor.gov';
        lCase.InputType__c = 'Site Consumidor.gov';
        lCase.Status = 'New';
        lCase.SubStatus__c = 'Não Iniciado';
        lCase.SituationCase__c = 'Open';
        lCase.InputType__c = 'Site Consumidor.gov';
        lCase.SupportArea__c = 'FINANCEIRO';
        lCase.AdditionalInformation__c = 'teste;teste2;teste3';
        lCase.SlaStartDate = System.now();
        lCase.IsStopped  = TRUE;
        lCase.OpenDateRobot__c = system.now();
        LCase.Contract__c = '999/999999999';
        LCase.RecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('LGPD').getRecordTypeId();
        
        return lCase;
    }    
    
    public static Case getCase(Account aAcc)
    {
        Case lCase = getCase();
        if (aAcc != null && String.isNotBlank(aAcc.Id)) lCase.AccountId = aAcc.Id;
        return lCase;
    }
    
    public static Case getCase(Contact aCtt)
    {
        Case lCase = getCase();
        if (aCtt != null && String.isNotBlank(aCtt.Id)) lCase.ContactId = aCtt.Id;
        return lCase;
    }
    
    public static Case getCaseLGPD(Contact aCtt)
    {
        Case lCase = getCaseLGPD();
        if (aCtt != null && String.isNotBlank(aCtt.Id)) lCase.ContactId = aCtt.Id;
        return lCase;
    }    
    
    public static  Entitlement getEntitlement()
    {
        return new Entitlement(Name = 'Consumidor.GOV');
    }
    
    public static Goal__c getGoal(Id aUserId)
    {
        Goal__c lGoal = new Goal__c();
        lGoal.Name = 'Meta'+ Math.random();
        lGoal.StartDate__c = system.today();
        lGoal.EndDate__c = system.today()+1;
        lGoal.Value_Calculation__c = 10;
        if (String.isNotBlank(aUserId)) lGoal.User__c = aUserId;
        return lGoal;
    }
    
    public static vlocity_cmt__CustomerInteraction__c getCustomerInteraction()
    {
        vlocity_cmt__CustomerInteraction__c varCustomerInteraction = new vlocity_cmt__CustomerInteraction__c();
        varCustomerInteraction.Name = 'Interação Consumidor.gov';
        varCustomerInteraction.vlocity_cmt__Type__c = 'Consumidor.gov';
        varCustomerInteraction.vlocity_cmt__Channel__c = 'Web';
        varCustomerInteraction.Author__c = 'Consumidor';
        varCustomerInteraction.Description__c = 'Teste';
        varCustomerInteraction.vlocity_cmt__Status__c = 'Completed';
        varCustomerInteraction.vlocity_cmt__StartDateTime__c = system.now();
        return varCustomerInteraction;
    }
    
    public static vlocity_cmt__CustomerInteractionTopic__c getCustomerInteractionTopic(vlocity_cmt__CustomerInteraction__c varCustomerInteraction,
                                                                                       Case varCase)
    {
        vlocity_cmt__CustomerInteractionTopic__c varCustomerInteractionTopic = new vlocity_cmt__CustomerInteractionTopic__c();
        if (varCustomerInteraction != null && String.isNotBlank(varCustomerInteraction.Id)) varCustomerInteractionTopic.vlocity_cmt__CustomerInteractionId__c = varCustomerInteraction.Id;
        if (varCase != null && String.isNotBlank(varCase.Id)) varCustomerInteractionTopic.vlocity_cmt__CaseId__c = varCase.Id;
        return varCustomerInteractionTopic;
    }
    
    public static ServiceParameter__c getServiceParameter(String aName, String aEndpoint,
                                                          String aMethod, String aPassword, String aUserName)
    {
        ServiceParameter__c lService = new ServiceParameter__c(Name = aName, Endpoint__c = aEndpoint,
                                                               Method__c = aMethod, Password__c =  aPassword, User__c = aUserName);
        return lService;
    }
    
    public static Quiz__c getQuiz()
    {
        Quiz__c lQuiz = new Quiz__c();
        lQuiz.Name = 'Area' + Math.random();
        lQuiz.SubArea__c = 'Sub Area' + Math.random();
        lQuiz.Active__c = true;
        lQuiz.BusinessUnit__c = 'Claro';
        return lQuiz;
    }
    
    public static List<Quiz__c> getListQuiz(Integer aQuantity)
    {
        List<Quiz__c> lstQuiz = new List<Quiz__c>();
        for (Integer i = 0; i < aQuantity; i++) {
            Quiz__c sObjQuiz = getQuiz();
            lstQuiz.add(sObjQuiz);
        }
        return lstQuiz;
    }
    
    public static ParamQuestion__c getParamQuestion(Quiz__c aQuiz)
    {
        ParamQuestion__c lParamQuestion = new ParamQuestion__c();
        lParamQuestion.Name = 'Pergunta ' + Math.random();
        lParamQuestion.TypeQuestion__c = 'Text';
        if (aQuiz != null && String.isNotBlank(aQuiz.Id)) lParamQuestion.Questionario__c = aQuiz.Id;
        return lParamQuestion;
    }
    
    public static List<ParamQuestion__c> getListParamQuestion(Integer aQuantity, Quiz__c aQuiz)
    {
        List<ParamQuestion__c> lstParamQuestion = new List<ParamQuestion__c>();
        for (Integer i = 0; i < aQuantity; i++) {
            ParamQuestion__c sObjParamQuestion = getParamQuestion(aQuiz);
            lstParamQuestion.add(sObjParamQuestion);
        }
        return lstParamQuestion;
    }
    
    public static ContentDocumentLink getContentDocumentLink(Id lDocument)
    {
        ContentDocumentLink lContentDocumentLink = New ContentDocumentLink();
        lContentDocumentLink.LinkedEntityId = UserInfo.getUserId();
        lContentDocumentLink.ContentDocumentId = lDocument;
        lContentDocumentLink.shareType = 'V';
        return lContentDocumentLink;
    }
    
    public static CEC_CC_Entitlement__c getCSEntitlement(String pName, String pArea, String pType){
        return new CEC_CC_Entitlement__c(Name = pName, SupportArea__c = pArea, TypeName__c  = pType);
    }
    
    public static  List<CEC_CC_Entitlement__c> getAllCSEntitlement()
    {
        List<CEC_CC_Entitlement__c> lstCSEntitlements = new List<CEC_CC_Entitlement__c>();
        
        lstCSEntitlements.add(getCSEntitlement('Anatel','CEC_CC_Anatel','CEC_CC_Anatel'));
        lstCSEntitlements.add(getCSEntitlement('CanaisInternos','Canais internos','CEC_CC_CanaisInternos'));        
        lstCSEntitlements.add(getCSEntitlement('ConsumidorGOV','Consumidor_GOV','Consumidor.GOV'));        
        lstCSEntitlements.add(getCSEntitlement('Fraude','Fraude','CEC-CC-Fraude'));
        lstCSEntitlements.add(getCSEntitlement('Procon','CEC_CC_Procon','CEC_CC_Procon'));        
         
        lstCSEntitlements.add(getCSEntitlement('SuporteApoio','CEC_CC_SuporteApoio','CEC_CC_SuporteApoio'));
        lstCSEntitlements.add(getCSEntitlement('SuporteCanaisInternos','Canais internos','CEC-CC-Suporte-Canais Internos'));
        lstCSEntitlements.add(getCSEntitlement('SuporteCobranca','Cobrança','CEC-CC-Suporte-Cobrança'));
        lstCSEntitlements.add(getCSEntitlement('SuporteContrato','Contrato','CEC-CC-Suporte-Contrato'));
        lstCSEntitlements.add(getCSEntitlement('SuporteFinanceiro','Financeiro','CEC-CC-Suporte-Financeiro'));
        lstCSEntitlements.add(getCSEntitlement('SuporteFraude','Fraude','CEC-CC-Suporte-Fraude'));
        lstCSEntitlements.add(getCSEntitlement('SuporteLogistica','Logística','CEC-CC-Suporte-Logística'));
        lstCSEntitlements.add(getCSEntitlement('SuporteOuvidoria','Ouvidoria','CEC_CC_Ouvidoria'));
        lstCSEntitlements.add(getCSEntitlement('SuportePortabilidade','Portabilidade','CEC-CC-Suporte-Portabilidade/Ouvidoria/Indevido'));
		lstCSEntitlements.add(getCSEntitlement('SuporteRelacionamento','Rcv','CEC-CC-Suporte-RCV/Relacionamento'));
        lstCSEntitlements.add(getCSEntitlement('SuporteResgateGravacao','Resgate gravação','CEC-CC-Suporte-Resgate Gravação'));
        lstCSEntitlements.add(getCSEntitlement('SuporteTecnico','Suporte técnico','CEC-CC-Suporte-Suporte Técnico'));
        
        lstCSEntitlements.add(getCSEntitlement('SuporteVendaMovimentacao','Venda/movimentação','CEC-CC-Suporte-Venda/Movimentação'));
        
        return lstCSEntitlements;
    }          
}