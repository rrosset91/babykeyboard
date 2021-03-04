@isTest
public class IntegrationCreditAnalysisMobileDTOTest {
	@isTest
    static void mainTest() {        
        IntegrationCreditAnalysisMobileDTO.CredAnalysisItem item = new IntegrationCreditAnalysisMobileDTO.CredAnalysisItem();
        item.fieldId = '0001';
        item.fieldName = 'Teste';
        item.value = 'Valor';
        item.key = 'Chave';

        IntegrationCreditAnalysisMobileDTO.CredAnalysisItens items = new IntegrationCreditAnalysisMobileDTO.CredAnalysisItens();
        items.item = item;
        
        List<IntegrationCreditAnalysisMobileDTO.CredAnalysisItens> lstItems = new List<IntegrationCreditAnalysisMobileDTO.CredAnalysisItens>();
		lstItems.add(items);
        
		IntegrationCreditAnalysisMobileDTO.CredAnalysisData credData = new IntegrationCreditAnalysisMobileDTO.CredAnalysisData();
        credData.operatorCode = '0001';
        credData.itens = lstItems;
        
        IntegrationCreditAnalysisMobileDTO.CredAnalysisReq request = new IntegrationCreditAnalysisMobileDTO.CredAnalysisReq();
        request.data = credData;
        
        /**/
        IntegrationCreditAnalysisMobileDTO.RelatedAssessment asses = 
            new IntegrationCreditAnalysisMobileDTO.RelatedAssessment('0001', 'Type');
        
        IntegrationCreditAnalysisMobileDTO.SalesUser salesUser = 
            new IntegrationCreditAnalysisMobileDTO.SalesUser('0001');
        
        IntegrationCreditAnalysisMobileDTO.Aplication app =
            new IntegrationCreditAnalysisMobileDTO.Aplication('0001', 'Type', salesUser);
        
        IntegrationCreditAnalysisMobileDTO.CredAddress credAddress = 
            new IntegrationCreditAnalysisMobileDTO.CredAddress();
        
        IntegrationCreditAnalysisMobileDTO.Client client = 
            new IntegrationCreditAnalysisMobileDTO.Client('Type', 'Name', '01/01/2001', 'Mother', 'Male', '12312312345', credAddress);

        IntegrationCreditAnalysisMobileDTO.Channel channel = new IntegrationCreditAnalysisMobileDTO.Channel();
        channel.id = '0001';
        channel.regional = salesUser;
  
        IntegrationCreditAnalysisMobileDTO.SalesAgent salesAgent = new IntegrationCreditAnalysisMobileDTO.SalesAgent();
        salesAgent.id = '0001';
        salesAgent.channel = channel;  
        
        IntegrationCreditAnalysisMobileDTO.Seller seller = new IntegrationCreditAnalysisMobileDTO.Seller();
        seller.id = '0001';
        seller.salesAgent = salesAgent;

		IntegrationCreditAnalysisMobileDTO.CredOrder credOrder = new
            IntegrationCreditAnalysisMobileDTO.CredOrder(client, salesUser, seller);
        
        /**/
        
		IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileData mobileData = 
            new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileData('Type', 'Operation', app, credOrder, asses);
        
        /**/
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileRespData mobRespData = 
            new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileRespData('01/01/2001', '10000', 'Result', 'ResultReason', 'Description');
        
        IntegrationCreditAnalysisMobileDTO.CreditSituation creditSituation = new 
            IntegrationCreditAnalysisMobileDTO.CreditSituation(mobRespData);
        
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp mobResp = 
            new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp(mobRespData);
        
        IntegrationCreditAnalysisMobileDTO.CredAnalysisResp resp = new IntegrationCreditAnalysisMobileDTO.CredAnalysisResp(mobResp);
                
        IntegrationCreditAnalysisMobileDTO.CredAnalysisRespData respData = new IntegrationCreditAnalysisMobileDTO.CredAnalysisRespData();
        respData.creditSituation = creditSituation;
        
        IntegrationCreditAnalysisMobileDTO.CredAnalysisResp credResp = new IntegrationCreditAnalysisMobileDTO.CredAnalysisResp();
        resp.data = respData;
        
        IntegrationCreditAnalysisMobileDTO integration = new IntegrationCreditAnalysisMobileDTO();
		IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp analiMobResp = integration.CredAnalysisResp2CredAnalisysMobileResp(resp);        
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp sample = integration.getExempleResponse();
    }  
    
    @isTest
    static void testBlank() {
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileData mobData = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileData();
        IntegrationCreditAnalysisMobileDTO.RelatedAssessment asses = new IntegrationCreditAnalysisMobileDTO.RelatedAssessment();        
        IntegrationCreditAnalysisMobileDTO.Aplication app = new IntegrationCreditAnalysisMobileDTO.Aplication();        
        IntegrationCreditAnalysisMobileDTO.CredOrder credOrder = new IntegrationCreditAnalysisMobileDTO.CredOrder();        
        IntegrationCreditAnalysisMobileDTO.Client client = new IntegrationCreditAnalysisMobileDTO.Client();        
        IntegrationCreditAnalysisMobileDTO.SalesUser salesUser = new IntegrationCreditAnalysisMobileDTO.SalesUser();        
        IntegrationCreditAnalysisMobileDTO.CreditSituation credSituation = new IntegrationCreditAnalysisMobileDTO.CreditSituation();
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp mobResp = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp(); 
        IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileRespData mobRespData = new IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileRespData();
    }
}