/**
 * ---------------------------------------------------------------
 * Data: 16/10/2020
 * Autor: Squad Anatel/Ouvidoria - Sysmap Solutions
 * Descrição: Ouvidoria - Teste do Controller para Consulta de protocolo no PS8, NETSMS, e PSAC
 * ---------------------------------------------------------------
 */
@isTest
global class CEC_CC_OuvidoriaControllerTest {

    public static final String MAIOR_180 = 'INVÁLIDO - PROTOCOLO MAIOR QUE 180 DIAS';
    public static final String DENTRO_PRAZO = 'INVÁLIDO - PROTOCOLO DENTRO DO PRAZO DE 5 DIAS';
    public static final String OK = 'VÁLIDO';


    public static final String COD_PS8 = '002';
    public static final String COD_NETSMS = '001';
    public static final String COD_PSAC = '003';

    @TestSetup
    public static void setup(){
        Account customer = new Account(
            name = 'SARA SOPHIE DA CONCEIÇÃO',
            DocumentType__c = 'CPF',
            Phone = '11940564346',
            DocumentNumber__c = '90827823835',
            Email__c = 'sara.conceicao@teste.com.br',
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName()
                .get('Consumer')
                .getRecordTypeId()
        );

        Account customer2 = new Account(
            name = 'MARINEIDE PEREIRA SOUZA',
            DocumentType__c = 'CPF',
            Phone = '11940564346',
            DocumentNumber__c = '42737230268',
            Email__c = 'marineire.@teste.com.br',
            RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName()
                .get('Consumer')
                .getRecordTypeId()
        );
        List<Account> customers = new List<Account>{ customer, customer2 };

        insert customers;

       

        Contact ctt = new Contact ();
        ctt.FirstName  = customer.Name;
        ctt.LastName = '.';
        ctt.AccountId = customer.Id;
        ctt.DocumentNumber__c =  customer.DocumentNumber__c;
        ctt.DocumentType__c = 'CPF';
        ctt.Email= customer.Email__c;
        ctt.MobilePhone = customer.Phone;
        insert ctt;

         Asset ass = new Asset(
            Status='Ativo',
            Name='CLARO CONTROLE',
            AccountId = customer.Id,
            RecordTypeId = Schema.Sobjecttype.Asset.getRecordTypeInfosByDeveloperName()
                .get('CECMovelPreControle')
                .getRecordTypeId(),
            MSISDN__c = '11940564346'

        );
        insert ass;

    }

    @IsTest
    static void ClientNotFountTest(){
        
        RestRequest req= new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI='/services/apexrest/searchProtocol';
    
        req.httpMethod='GET';
        req.addParameter('protocolNumber', '202023084');
        req.addParameter('cpf', '99999999988');
        req.addParameter('companyId', COD_NETSMS);
        RestContext.request =req;
        RestContext.response =res;    
        Test.startTest();
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.getProtocol();

        Test.stopTest();
        System.assertEquals(500,res.statusCode);
        System.assertNotEquals(null,resp.error);
        System.assert(resp.error.message.contains('Não foi encontrado um cliente com o CPF'));
        
        
    }

    @isTest
    public static void CEC_PS8ProtocolTest()
    {
        RestRequest req= new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI='/services/apexrest/searchProtocol';
        

        req.httpMethod='GET';
        req.addParameter('protocolNumber', '202023084');
        req.addParameter('cpf', '90827823835');
        req.addParameter('companyId', COD_PS8);
        RestContext.request =req;
        RestContext.response =res;

        CEC_CC_OuvidoriaControllerMock.CEC_PS8_Within180Days_Mock mock = new CEC_CC_OuvidoriaControllerMock.CEC_PS8_Within180Days_Mock();
        
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        
        Test.startTest();
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.getProtocol();
        system.debug(resp);
        system.debug(res);
        Test.stopTest();
        System.assertEquals(200,res.statusCode); // statuscode =400 is blank 200 is sucess
        System.assertNotEquals(400, res.statusCode);
    }

    @isTest
    public static void CEC_PS8ProtocolFailTest()
    {
        RestRequest req= new RestRequest();
        RestResponse res= new RestResponse();

        req.requestURI='/services/apexrest/searchProtocol';

        req.httpMethod='GET';
        RestContext.request =req;
        RestContext.response=res;

        Test.startTest();
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.getProtocol();
        System.debug(resp);
        System.debug(res);
        Test.stopTest();

        System.assertEquals(400, res.statusCode);
        System.assertNotEquals(200, res.statusCode);
        System.assertEquals(null, resp.data);
    }

    @isTest
    public static void CEC_ProtocolNotFound404Test()
    {
        RestRequest req= new RestRequest();
        RestResponse res= new RestResponse();

        req.requestURI='/services/apexrest/searchProtocol';

        req.httpMethod='GET';
        req.addParameter('protocolNumber', '5050');// protocolo que não pode existir
        req.addParameter('companyId', COD_PSAC);
        RestContext.request =req;
        RestContext.response=res;

        CEC_CC_OuvidoriaControllerMock.CEC_PSAC_NotFound2_Mock mock = new CEC_CC_OuvidoriaControllerMock.CEC_PSAC_NotFound2_Mock();
    
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.getProtocol();
        System.debug(resp);
        System.debug(res);
        Test.stopTest();
        
        System.assertNotEquals(null, resp.error);
        System.assertEquals(500, res.statusCode);
    }


    //TESTES DE PRAZOS (elegibility)
    @isTest
    public static void CEC_EntradaOKTest()//ABERTO MAIS DE 5 DIAS
    {

        RestRequest req= new RestRequest();
        RestResponse res= new RestResponse();
        req.requestURI='/services/apexrest/searchProtocol'; // Busca dentro da urlmapping  da Api ouvidoria

        req.httpMethod='GET';
        req.addParameter('protocolNumber', '202023084'); // pegando protocolo valido
        req.addParameter('companyId', COD_PS8);
        RestContext.request =req;
        RestContext.response =res;

        CEC_CC_OuvidoriaControllerMock.CEC_PS8_OpenMoreThan5Days_Mock mock = new CEC_CC_OuvidoriaControllerMock.CEC_PS8_OpenMoreThan5Days_Mock();
    
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();//INICIANDO TESTE
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.getProtocol();
        System.debug(resp);
        test.stopTest(); //FIM DO TESTE

        SYSTEM.assertEquals(OK, resp.eligibility);
        System.assertEquals('ABERTO', resp.data.status);
    }
 


    @isTest
    public static void CEC_CCDentroDoPrazoTest()//ABERTO HA MENOS DE 5 DIAS
    {

        RestRequest req= new RestRequest();
        RestResponse res= new RestResponse();
        req.requestURI='/services/apexrest/searchProtocol'; // Busca dentro da urlmapping  da Api ouvidoria

        req.httpMethod='GET';
        req.addParameter('protocolNumber', '202023084'); // pegando protocolo valido
        req.addParameter('companyId', COD_PS8);
        RestContext.request =req;
        RestContext.response =res;

        CEC_CC_OuvidoriaControllerMock.CEC_PS8_Within5Days_Mock mock = new CEC_CC_OuvidoriaControllerMock.CEC_PS8_Within5Days_Mock();
    
        Test.setMock(HttpCalloutMock.class, mock);
        
        test.startTest();//INICIANDO TESTE
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.getProtocol();// PEGANDO RESULTADO

        test.stopTest(); //FIM DO TESTE

        SYSTEM.assertEquals(DENTRO_PRAZO, resp.eligibility);
        System.assertEquals('ABERTO', resp.data.status);
    }

    @isTest

    public static void PS8_ForadoPrazoTest()//MAIOR QUE 180 DIAS
    {
        RestRequest req= new RestRequest();
        RestResponse res= new RestResponse();
        req.requestURI='/services/apexrest/searchProtocol'; // Busca dentro da urlmapping  da Api ouvidoria

        req.httpMethod='GET';
        req.addParameter('protocolNumber', '202023084'); // pegando protocolo valido
        req.addParameter('companyId', COD_PS8);
        RestContext.request =req;
        RestContext.response =res;

        CEC_CC_OuvidoriaControllerMock.CEC_PS8_ClosedMoreThan180Days_Mock mock = new CEC_CC_OuvidoriaControllerMock.CEC_PS8_ClosedMoreThan180Days_Mock();
    
        Test.setMock(HttpCalloutMock.class, mock);

        test.startTest();//INICIANDO TESTE
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.GETprotocol();// PEGANDO RESULTADO

        test.stopTest(); //FIM DO TESTE

        SYSTEM.assertEquals(MAIOR_180, resp.eligibility);
        System.assertEquals('CONCLUÍDO', resp.data.status);
    }

    @isTest
    public static void NETSMS_ForaPrazoTest()
    {

        RestRequest req= new RestRequest();
        RestResponse res= new RestResponse();
        req.requestURI='/services/apexrest/searchProtocol'; // Busca dentro da urlmapping  da Api ouvidoria

        req.httpMethod='GET';
        req.addParameter('protocolNumber', '040203852518986'); // pegando protocolo valido
        req.addParameter('companyId', COD_NETSMS);
        RestContext.request =req;
        RestContext.response =res;

        CEC_CC_OuvidoriaControllerMock.NETSMS_ClosedMoreThan180Days_Mock mock= new CEC_CC_OuvidoriaControllerMock.NETSMS_ClosedMoreThan180Days_Mock();
        Test.setMock(HttpCalloutMock.class, mock);
       
        test.startTest();//INICIANDO TESTE
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.GETprotocol();// PEGANDO RESULTADO

        test.stopTest(); //FIM DO TESTE

        System.assertEquals(MAIOR_180, resp.eligibility);
        // Verifica se retorna 4 attendances
        System.assertEquals(4, ((CEC_CC_OuvidoriaController.DataProtocols)resp.legacyData).attendances.size());
        System.assertEquals('RESOLVIDO', resp.data.status);
    }

    @isTest
    public static void CEC_NETSMS_EntradaOkTest()
    {
        RestRequest req= new RestRequest();
        RestResponse res= new RestResponse();
        req.requestURI='/services/apexrest/searchProtocol'; // Busca dentro da urlmapping  da Api ouvidoria
        req.httpMethod='GET';
        req.addParameter('protocolNumber', '040203852518986'); // pegando protocolo valido
        req.addParameter('companyId', COD_NETSMS);
        RestContext.request =req;
        RestContext.response =res;

        CEC_CC_OuvidoriaControllerMock.NETSMSOpenMoreThan5DaysMock mock= new CEC_CC_OuvidoriaControllerMock.NETSMSOpenMoreThan5DaysMock();
        Test.setMock(HttpCalloutMock.class, mock);
       
        test.startTest();//INICIANDO TESTE
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.GETprotocol();// PEGANDO RESULTADO
        test.stopTest(); //FIM DO TESTE

        System.assertEquals(OK, resp.eligibility);
        // Verifica se retorna 4 attendances
        System.assertEquals(4, ((CEC_CC_OuvidoriaController.DataProtocols)resp.legacyData).attendances.size());
        System.assertEquals('ABERTO', resp.data.status);

    }
    @isTest
    public static void CEC_NETSMS_Menos5DiasTest()
    {
        // Neste caso o mock do NETSMS deve ter ao enos um protocolo aberto
        // a regra será a do protocolo aberto mais recente

        RestRequest req= new RestRequest();
        RestResponse res= new RestResponse();
        req.requestURI='/services/apexrest/searchProtocol'; // Busca dentro da urlmapping  da Api ouvidoria
        req.httpMethod='GET';
        req.addParameter('protocolNumber', '040203852518986'); // pegando protocolo valido
        req.addParameter('companyId', COD_NETSMS);
        RestContext.request =req;
        RestContext.response =res;

        CEC_CC_OuvidoriaControllerMock.NETSMS_OpenWithin5Days_Mock mock= new CEC_CC_OuvidoriaControllerMock.NETSMS_OpenWithin5Days_Mock();
        Test.setMock(HttpCalloutMock.class, mock);
       
        test.startTest();//INICIANDO TESTE
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.GETprotocol();// PEGANDO RESULTADO
        test.stopTest(); //FIM DO TESTE

        System.assertEquals(DENTRO_PRAZO, resp.eligibility);
        // Verifica se retorna 4 attendances
        System.assertEquals(4, ((CEC_CC_OuvidoriaController.DataProtocols)resp.legacyData).attendances.size());
    }
    
    @isTest
    public static void CEC_NETSMS_AbertoMais5DiasTest()
    {
        RestRequest req= new RestRequest();
        RestResponse res= new RestResponse();
        req.requestURI='/services/apexrest/searchProtocol';
        req.httpMethod='GET';
        req.addParameter('protocolNumber', '040203852518986');
        req.addParameter('companyId', COD_NETSMS);
        RestContext.request =req;
        RestContext.response =res;

        CEC_CC_OuvidoriaControllerMock.NETSMSOpenMoreThan5DaysMock mock= new CEC_CC_OuvidoriaControllerMock.NETSMSOpenMoreThan5DaysMock();
        Test.setMock(HttpCalloutMock.class, mock);
       
        test.startTest();//INICIANDO TESTE
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.GETprotocol();// PEGANDO RESULTADO
        test.stopTest(); //FIM DO TESTE

        System.assertEquals(OK, resp.eligibility);
        // Verifica se retorna 4 attendances
        System.assertEquals(4, ((CEC_CC_OuvidoriaController.DataProtocols)resp.legacyData).attendances.size());
        System.assertEquals('406665295', resp.data.interactionNumber);
    }
    
    @isTest
    public static void CEC_NETSMS_FechadoMenos180DiasTest()
    {
        RestRequest req= new RestRequest();
        RestResponse res= new RestResponse();
        req.requestURI='/services/apexrest/searchProtocol';
        req.httpMethod='GET';
        req.addParameter('protocolNumber', '040203852518986');
        req.addParameter('companyId', COD_NETSMS);
        RestContext.request =req;
        RestContext.response =res;

        CEC_CC_OuvidoriaControllerMock.NETSMS_ClosedWithin180Days_Mock mock= new CEC_CC_OuvidoriaControllerMock.NETSMS_ClosedWithin180Days_Mock();
        Test.setMock(HttpCalloutMock.class, mock);
       
        test.startTest();//INICIANDO TESTE
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.GETprotocol();// PEGANDO RESULTADO
        test.stopTest(); //FIM DO TESTE
        
         Datetime agora = Datetime.now();
         DateTime dt1 = agora.addDays(-50);
         String dateString = dt1.format('yyyy-MM-dd\'T\'hh:mm:ss');

        System.assertEquals(OK, resp.eligibility);
        System.assertEquals(dateString, resp.data.interactionClosingDate);
        System.assertEquals('406665295', resp.data.interactionNumber);
        System.assertEquals(4, ((CEC_CC_OuvidoriaController.DataProtocols)resp.legacyData).attendances.size());
    }
    
    @isTest
    public static void CEC_PSAC_EntradaOkTest()
    {
        RestRequest req= new RestRequest();
        RestResponse res= new RestResponse();
        req.requestURI='/services/apexrest/searchProtocol';
        req.httpMethod='GET';
        req.addParameter('protocolNumber', '20202323213');
        req.addParameter('companyId', COD_PSAC);
        RestContext.request = req;
        RestContext.response = res;

        CEC_CC_OuvidoriaControllerMock.CEC_PSAC_LessThan180Days_Mock mock= new CEC_CC_OuvidoriaControllerMock.CEC_PSAC_LessThan180Days_Mock();
        Test.setMock(HttpCalloutMock.class, mock);
       
        test.startTest();//INICIANDO TESTE
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.GETprotocol();// PEGANDO RESULTADO
        test.stopTest(); //FIM DO TESTE

        System.assertEquals(OK, resp.eligibility);
        System.assertNotEquals(null, resp.data);
        System.assertEquals(null, resp.error);
        System.assertEquals('PSAC', resp.data.legacy);
        System.assertEquals(200, res.statusCode);
        System.assertEquals('20202323213', ((CEC_PSAC_Response.DataProtocols)resp.legacyData).attendances.interactionNumber);
    }
    
    @isTest
    public static void CEC_PSAC_MoreThan180DaysTest()
    {
        RestRequest req= new RestRequest();
        RestResponse res= new RestResponse();
        req.requestURI='/services/apexrest/searchProtocol';
        req.httpMethod='GET';
        req.addParameter('protocolNumber', '20202323213');
        req.addParameter('companyId', COD_PSAC);
        RestContext.request = req;
        RestContext.response = res;

        CEC_CC_OuvidoriaControllerMock.CEC_PSAC_MoreThan180Days_Mock mock= new CEC_CC_OuvidoriaControllerMock.CEC_PSAC_MoreThan180Days_Mock();
        Test.setMock(HttpCalloutMock.class, mock);
       
        test.startTest();//INICIANDO TESTE
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.GETprotocol();// PEGANDO RESULTADO
        test.stopTest(); //FIM DO TESTE

        System.assertEquals(MAIOR_180, resp.eligibility);
        System.assertNotEquals(null, resp.data);
        System.assertEquals(null, resp.error);
        System.assertEquals('PSAC', resp.data.legacy);
        System.assertEquals(200, res.statusCode);
        System.assertEquals('20202323213', ((CEC_PSAC_Response.DataProtocols)resp.legacyData).attendances.interactionNumber);
    }


    @isTest
    public static void CEC_NETSMS_ProtocoloNaoPertenceAoCPF_Test()
    {
        RestRequest req= new RestRequest(); 
        RestResponse res= new RestResponse();
        req.requestURI='/services/apexrest/searchProtocol';
        req.httpMethod='GET';
        req.addParameter('protocolNumber', '040203852518986');
        req.addParameter('cpf', '90827823835'); 
        req.addParameter('companyId', COD_NETSMS);
        RestContext.request =req;
        RestContext.response =res;

        CEC_CC_OuvidoriaControllerMock.CEC_CustomerContract_Mock mock= new CEC_CC_OuvidoriaControllerMock.CEC_CustomerContract_Mock();
        Test.setMock(HttpCalloutMock.class, mock);
       
        test.startTest();//INICIANDO TESTE
        CEC_CC_LegacyProtocolResponse resp = CEC_CC_Api_Ouvidoria.GETprotocol();// PEGANDO RESULTADO
        test.stopTest(); //FIM DO TESTE 
        
      
        System.assertEquals(null, resp.data);
        System.assertNotEquals(null, resp.error);
        System.assert(resp.error.detailedMessage.contains('Protocolo não pertence ao cliente'));
        
    }
}