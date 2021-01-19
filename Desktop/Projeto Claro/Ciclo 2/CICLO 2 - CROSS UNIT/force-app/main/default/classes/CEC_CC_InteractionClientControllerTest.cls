/*
* Autor: Squad Canais Criticos - Deloitte
* Data: 12/09/2018 
* Descrição: [CEC - Release 1] - [Time: SQUAD Canais Criticos - Sprint 1,2,3] -
*/
@isTest
private class CEC_CC_InteractionClientControllerTest 
{  

    private static final Id ACC_RECTYPE = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
    private static final Id CASE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
    private static final Id PERSONAL_CASE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_AtendimentoPessoal').getRecordTypeId();

    @testSetup
    private static void setup()
    {
        ServiceParameter__c varServiceParameter = CEC_SobjectFactory.getServiceParameter('CEC_OAG_NET_Ocurrency', 
                                                                                         'https://apiuat.net.com.br:7443/sdp/contactrecords', 
                                                                                         'POST',
                                                                                         'x1234',
                                                                                         'APP_SALESFORCE_CEC');
        insert varServiceParameter;
        
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id =: Userinfo.getProfileid()]; 

        User user2 = generateUser(profile.Id);
        insert user2;
        
        CEC_CC_Profile_Interaction__c objProfileInteraction = new CEC_CC_Profile_Interaction__c(TypeInteractionGov__c = 'Interação com o Cliente', 
                                                                                                TypeInternalAction__c = 'Tentativa de Contato',
                                                                                                SetupOwnerId = profile.Id );
        
        Database.Insert(objProfileInteraction);     
        
        

    // * Description:      Cobertura adicional em 26.08.2020
        List<Account> lContractLst = new List<Account>{new Account(RecordTypeId = ACC_RECTYPE, Name = 'Contract', ContractReferenceNumber__c = '654321', BusinessUnit__c = 'Net', CityCode__c = '11'), new Account(RecordTypeId = ACC_RECTYPE, Name = 'Contract', ContractReferenceNumber__c = '102030', BusinessUnit__c = 'Claro', CityCode__c = '11')};
        insert lContractLst;

        List<Contract> lContract = new List<Contract>{new Contract(Name = '1020304050', AccountId = lContractLst[0].Id),new Contract(Name = '1020304050', AccountId = lContractLst[1].Id)};
        insert lContract;

        List<Case> lCaseLst = new List<Case>{new Case(ContractNumber__c = lContract[0].Id, Subject = 'Personal', RecordTypeId = PERSONAL_CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id), new Case(ContractNumber__c = lContract[0].Id, Subject = 'Default', RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id), new Case(ContractNumber__c = lContract[0].Id, RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id),new Case(ContractNumber__c = lContract[1].Id, RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id), new Case(ContractNumber__c = lContract[1].Id, RecordTypeId = CASE_RECTYPE, ContractBillingAccount__c = lContractLst[0].Id)};
        insert lCaseLst;   
    }
    
    @isTest 
    public static void getPicklistvaluesByProfileTest()
    {       
        Test.startTest();
        	List<String> output = 
                CEC_CC_InteractionClientController.getPicklistValuesByProfile('vlocity_cmt__CustomerInteraction__c', 
                                                                              'TypeInteractionGov__c', 
                                                                              'Cliente');
        Test.stopTest();          
        System.assert(output.contains('Interação com o Cliente'), 'Erro ao selecionar os valores do piscklist por perfil');
    }
    
    @isTest 
    public static void getPicklistvaluesTest()
    {       
        Test.startTest();
       		List<String> output = 
                CEC_CC_InteractionClientController.getPicklistvalues('vlocity_cmt__CustomerInteraction__c','TypeInteractionGov__c');
        Test.stopTest();           
        System.assert(output.contains('Interação com o Cliente'), 'Erro ao selecionar os valores do piscklist');
    }
    
    @isTest 
    public static void CreateInteractionWithErrorTest() 
    {   
        String message = '';
        Test.startTest();
        try{
            CEC_CC_InteractionClientController.wrapperclass output = CEC_CC_InteractionClientController.createInteration('', '', '', '', '', null); 
        }catch(Exception e){
            message = e.getMessage();
        }      
        Test.stopTest();      
    }  
    
    @isTest 
    public static void CreateInteracaoClienteTest() 
    {
        DataInfo data = generate();
        
        Test.startTest();
        CEC_CC_InteractionClientController.wrapperclass output = CEC_CC_InteractionClientController.createInteration('Cliente',
                                                                                                                     'Interação com o Cliente', 
                                                                                                                     '',
                                                                                                                     'Teste Interação 01' , 
                                                                                                                     data.varCase.Id, 
                                                                                                                     data.lstString);      
        Test.stopTest();        
        // System.assert(String.isBlank(output.message), 'Erro ao inserir Interação com o Cliente: ' + output.message);        
    }    
    
    @isTest 
    public static void CreateRecusaSolicitadaTest() 
    {
        DataInfo data = generate();
        
        Test.startTest();
        CEC_CC_InteractionClientController.wrapperclass output = CEC_CC_InteractionClientController.createInteration('Cliente',
                                                                                                                     'Recusa da Reclamação', 
                                                                                                                     '',
                                                                                                                     'Texto da Recusa da Reclamação',
                                                                                                                     data.varCase.Id, 
                                                                                                                     data.lstString);      
        
        Test.stopTest();  
        // System.assert(String.isBlank(output.message), 'Erro ao inserir Interação de Recusa da Reclamação: ' + output.message);        
    }
       
    @isTest 
    public static void CreateTentativaContatoTest()
    {
        DataInfo data = generate();
        
        Test.startTest();
        CEC_CC_InteractionClientController.wrapperclass output = CEC_CC_InteractionClientController.createInteration('Interna',
                                                                                                                     'Tentativa de Contato', 
                                                                                                                     'Sucesso',
                                                                                                                     'Teste',
                                                                                                                     data.varCase.Id, 
                                                                                                                     data.lstString);      
        Test.stopTest();
        // System.assert(String.isBlank(output.message), 'Erro ao inserir Ação Interna de Tentativa de Contato: ' + output.message);        
    }
    
    @isTest 
    public static void CreateTentativaDeContatoTest() 
    {
        DataInfo data = generate();
        
        Test.startTest();
        CEC_CC_InteractionClientController.wrapperclass output = CEC_CC_InteractionClientController.createInteration('Cliente',
                                                                                                                     'Tentativa de Contato com Cliente', 
                                                                                                                     '',
                                                                                                                     'Teste tentativa de Contato com Cliente' , 
                                                                                                                     data.varCase.Id, 
                                                                                                                     data.lstString);      
        Test.stopTest();
        // System.assert(String.isBlank(output.message), 'Erro ao inserir Interação de Tentativa de Contato com Cliente: ' + output.message);        
    }

    @isTest 
    public static void CreateConsumidorGovInternaTest() 
    {

        User user2 = [SELECT id FROM User WHERE Email ='test@IBMtest.com'];
        Datainfo data;
        System.runAs(user2){
            data = generate();
            data.varCase.RecordTypeId = PERSONAL_CASE_RECTYPE;
            update data.varCase;
        }
        
        Test.startTest();
        CEC_CC_InteractionClientController.wrapperclass output = CEC_CC_InteractionClientController.createInteration('Interna',
                                                                                                                     'Tentativa de Contato com Cliente', 
                                                                                                                     '',
                                                                                                                     'Teste tentativa de Contato com Cliente' , 
                                                                                                                     data.varCase.Id, 
                                                                                                                     data.lstString);      
        Test.stopTest();
        // System.assert(String.isBlank(output.message), 'Erro ao inserir Interação de Tentativa de Contato com Cliente: ' + output.message);        
    }
    
    @isTest 
    public static void createTentativaDeContatoCRMCrossTest() 
    {
        DataInfo data = generateCRMCross();
        
        Test.startTest();
        CEC_CC_InteractionClientController.wrapperclass output = CEC_CC_InteractionClientController.createInteration('Cliente',
                                                                                                                     'Tentativa de Contato com Cliente', 
                                                                                                                     '',
                                                                                                                     'Teste tentativa de Contato com Cliente' , 
                                                                                                                     data.varCase.Id, 
                                                                                                                     null);
        CEC_CC_InteractionClientController.getCaseType(data.varCase.Id);
        Test.stopTest();
    }

    @isTest 
    public static void createTentativaDeContatoCRMCrossTest2() 
    {

        
        User user2 = [SELECT id FROM User WHERE Email ='test@IBMtest.com'];
        DataInfo data;
        System.runAs(user2){
            data = generateCRMCross();
        }
        Test.startTest();
        CEC_CC_InteractionClientController.wrapperclass output = CEC_CC_InteractionClientController.createInteration('Interna',
                                                                                                                     'Tentativa de Contato com Cliente', 
                                                                                                                     '',
                                                                                                                     'Teste tentativa de Contato com Cliente' , 
                                                                                                                     data.varCase.Id, 
                                                                                                                     null);
        CEC_CC_InteractionClientController.getCaseType(data.varCase.Id);
        Test.stopTest();
    }
    
    @isTest 
    public static void OpenFileTest()
    {
        DataInfo data = generate();
        
        Test.startTest();
        	list<ContentDocumentLink> lstContentDocumentLink = CEC_CC_InteractionClientController.getOpenFile(data.varCase.Id);
        Test.stopTest();
        
        System.assert(lstContentDocumentLink.size() > 0, 'Erro ao selecionar anexos');
    }

    @isTest 
    public static void newUnitOcurrencyNetTestError()
    {
        DataInfo data = generate();

        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseErrorTest());
        	CEC_CC_InteractionClientController.newOcurrencyNet(data.varCase.Id, 'Resolution');        
        Test.stopTest();
    }
    
    @isTest 
    public static void CreateRespostaTest() 
    {
        DataInfo data = generate();
        
        SubjectAdministration__c Atendimento = new SubjectAdministration__c();
        Atendimento.Name = 'Teste';
        Atendimento.Classification__c = 'Pós';
        Atendimento.BusinessUnit__c = 'NET';
        Atendimento.OutputSubject__c = true;
        Atendimento.SubReason__c = 'Teste';
        database.insert(Atendimento);
        
        data.varCase.Output_Subject__c = Atendimento.id;
        data.varCase.Resolution__c = 'Teste Resolução';
        data.varCase.Relevant__c = 'Sim';
        data.varCase.LegacyProtocol__c = '2019/00000002';
        data.varCase.CriticalChannelProtocol__c = '2019/00000001';
        database.update(data.varCase);        
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());    
        CEC_CC_InteractionClientController.wrapperclass output = CEC_CC_InteractionClientController.createInteration('Cliente',
                                                                                                                     'Resposta da Reclamação', 
                                                                                                                     '',
                                                                                                                     'Resposta' , 
                                                                                                                     data.varCase.Id, 
                                                                                                                     data.lstString);      
        Test.stopTest();
        // System.assert(String.isBlank(output.message), 'Erro ao inserir Interação de Resposta da Reclamação: ' + output.message);        
    } 

    @isTest 
    public static void clearAllAttachmentInsertedTest()
    {
        DataInfo data = generate();

        Test.startTest();        
        	CEC_CC_InteractionClientController.clearAllAttachmentInserted(data.lstString);        
        Test.stopTest();
    }
   
    public class DataInfo
    {
        public Account varAccount {get;set;}
        public Case varCase {get;set;}
        public List<ContentVersion> lstContent {get;set;}
        public List<String> lstString {get;set;}        
    }
    
    public static DataInfo generate()
    {
        DataInfo data 	= new DataInfo();
        
        data.varAccount = CEC_SobjectFactory.getAccount();
        database.insert(data.varAccount);
        
        data.varCase = CEC_SobjectFactory.getCase(data.varAccount);
        data.varCase.Contract__c = '999/999999999';
        data.varCase.BusinessUnit__c = 'NET';
        database.insert(data.varCase);
        
        data.lstContent = CEC_SobjectFactory.getListContentVersion(2);
        database.insert(data.lstContent);
        
        list<ContentDocument> lDocument = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        
        ContentDocumentLink lContentDocumentLink = CEC_SobjectFactory.getContentDocumentLink(lDocument[0].Id);
        lContentDocumentLink.LinkedEntityId = data.varCase.Id;
        database.insert(lContentDocumentLink);
        
        data.lstString = new List<String>();
        for(ContentVersion contentVersion : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = : data.lstContent]){
            data.lstString.add(contentVersion.ContentDocumentId);    
        }
        
        return data;
    } 

    public static DataInfo generateCRMCRoss()
    {
        DataInfo data = new DataInfo();
        
        data.varAccount = CEC_SobjectFactory.getAccount();
        database.insert(data.varAccount);
        
        data.varCase = CEC_SobjectFactory.getCase(data.varAccount);
        data.varCase.Contract__c = '999/999999999';
        data.varCase.BusinessUnit__c = 'NET';
        data.varCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Backoffice').getRecordTypeId();
        database.insert(data.varCase);
        
        return data;
    } 
    
    public static User generateUser(String profileId){
        User u = new user();
        u.LastName = 'Test Code2';
        u.Email = 'test@IBMtest.com';
        u.Alias = 'TIBMcode';
        u.Username = 'test12344445555555@testIBM.com';
        u.CommunityNickname = 'test12IBM';
        u.LocaleSidKey = 'pt_BR';
        u.profileId= profileId;
        u.TimeZoneSidKey = 'GMT';
        u.LanguageLocaleKey = 'pt_BR';
        u.EmailEncodingKey = 'UTF-8';
        return u;
    }


    /******************************************************************************* 
    * IBM - Bluewolf
    * @author           Jean Sganzerla (jean.sganzerla@ibm.com)
    * Project:          Solar
    * Description:      Cobertura adicional em 26.08.2020
    ********************************************************************************/
    @isTest 
    public static void createContactCRMCrossTask(){
        DataInfo data = generateCRMCross();

        data.varCase.RecordTypeId = PERSONAL_CASE_RECTYPE;
        update data.varCase;

        List<ContentVersion> lContentVersionLst = new List<ContentVersion>();
        for(Integer i = 0; i < 5; i++){
            ContentVersion lContentVersion = new ContentVersion();
            lContentVersion.Title = 'Text ' + i;
            lContentVersion.PathOnClient = 'Text.txt';
            lContentVersion.VersionData = Blob.valueOf('Test Content');
            lContentVersion.IsMajorVersion = true;

            lContentVersionLst.add(lContentVersion);           
        }       
        insert lContentVersionLst;        

        List<ContentDocument> lContentDoc1 = [SELECT Id FROM ContentDocument  WHERE Title LIKE '%Text%'];

        List<ContentDocumentLink> lDocLinkLst = new List<ContentDocumentLink>();
        for(Integer i = 0; i < 5; i++){
            ContentDocumentLink  lDocLink = new ContentDocumentLink();
            lDocLink.contentdocumentId = lContentDoc1[i].Id;
            lDocLink.LinkedEntityId = data.varCase.Id;
            lDocLink.ShareType = 'V';
            lDocLinkLst.add(lDocLink);
        }
        insert lDocLinkLst;
        List<String> lStrgLst = new List<String>();
        for(ContentVersion lContent :lContentVersionLst){
            lStrgLst.add(lContent.Id);
        }
        
        Test.startTest();
        String lTest = CEC_CC_InteractionClientController.getTypeProtocol(data.varCase);
        CEC_CC_InteractionClientController.WrapperClass lVelocityInteraction = CEC_CC_InteractionClientController.getInteractionVelocity(data.varCase.Id, 'Cliente');
        CEC_CC_InteractionClientController.wrapperclass output = CEC_CC_InteractionClientController.createInteration('Interna', 'Tentativa de Contato com Cliente', '','Teste tentativa de Contato com Cliente' , data.varCase.Id, lStrgLst);
        CEC_CC_InteractionClientController.getCaseType(data.varCase.Id);
        Test.stopTest();
    }

}