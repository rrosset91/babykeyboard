@isTest
public class FinancialMobileUtilsTest {
    
    @TestSetup static void charge(){
        ServiceParameter__c setting = new ServiceParameter__c();
        setting.Token__c = 'returnedToken';
        setting.Name = 'GetInteractions';
        setting.EndPoint__c = 'callout/mock';
        setting.Method__c = 'GET';
        insert setting;
        Account acc = AccountDataFactory.getSingleAccount('Billing');
        insert acc;
        Case cs = CaseDataFactory.getSingleCase('Billing', acc.Id);
        insert cs;
        Asset asst = new Asset();
        asst.vlocity_cmt__BillingAccountId__c = acc.Id;
        asst.AccountId = acc.Id;
        asst.Name = 'MockAsset';
        asst.MSISDN__c = '11999999999';
        insert asst;
    }
    
    @isTest
    public static void setErrorMessageTest(){
        test.startTest();
        String result = FinancialMobileutils.setErrorMessage(getMockJson());
        test.stopTest();
        system.assertEquals(false, result == null);
    }
    
    @isTest
    public static void formatBRLTest() {
        String testValue = '22.9';
        test.startTest();
        String result = FinancialMobileUtils.formatBRL(testValue);
        test.stopTest();
        system.assertEquals(true, result == 'R$ 22,90');
    }
    
    @isTest
    public static void getAuthTest(){
        test.startTest();
        String customSetting = 'GetInteractions';
        String result = FinancialMobileUtils.getAuth(customSetting);
        test.stopTest();
        system.assertEquals(true, result == 'returnedToken');
    }
    
    @isTest
    public static void formatResponseDateWithoutTimeTest(){
        String responseDate = '2018-12-19T14:26:38.000-02:00';
        Boolean appendTime = true;
        test.startTest();
        String result = FinancialMobileUtils.formatResponseDate(responseDate, appendTime);
        test.stopTest();
        system.assertEquals(false, result == null);
    }
    
    @isTest
    public static void formatResponseDateWithTimeTest(){
        String responseDate = '2018-12-19T14:26:38.000-02:00';
        Boolean appendTime = false;
        test.startTest();
        String result = FinancialMobileUtils.formatResponseDate(responseDate, appendTime);
        test.stopTest();
        system.assertEquals(false, result == null);
    }
    
    @isTest
    public static void getRealDateInstanceTest(){
		String mockDate = '01/01/2020';
        Test.startTest();
        Date result = FinancialMobileUtils.getRealDateInstance(mockDate);
        Test.stopTest();
        system.assertEquals(2020, result.year());
    }
    @isTest
    public static void getRealDateTimeInstanceTest(){
        String mockDate = '01/01/2020';
        String mockTime = '00:00:00';
        Test.startTest();
        Datetime result = FinancialMobileUtils.getRealDateTimeInstance(mockDate, mockTime);
        Test.stopTest();
        system.assertEquals(2020, result.year());
    }
    @isTest
    public static void formatInlineJsonTest(){
        Test.startTest();
        String result = FinancialMobileUtils.formatInlineJson(getMockJson());
        Test.stopTest();
        system.assertEquals(false, result == null);
    }
    
    @isTest
    public static void processResponseCodeTest200(){
        List<Integer> codesToTest = new List<Integer>();
		test.startTest();
        try{
	        FinancialMobileUtils.processResponseCode(200);    
        }catch (Exception e){
            system.debug(e);
        }
        try{
	        FinancialMobileUtils.processResponseCode(400);    
        }catch (Exception e){
            system.debug(e);
        }
        try{
	        FinancialMobileUtils.processResponseCode(401);    
        }catch (Exception e){
            system.debug(e);
        }
        try{
	        FinancialMobileUtils.processResponseCode(403);    
        }catch (Exception e){
            system.debug(e);
        }
        try{
	        FinancialMobileUtils.processResponseCode(500);    
        }catch (Exception e){
            system.debug(e);
        }
        try{
	        FinancialMobileUtils.processResponseCode(666);    
        }catch (Exception e){
            return;
        }
        test.startTest();
    }
      
    @isTest
    public static void getMsisdnText(){
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        test.startTest();

		List<String> result = FinancialMobileUtils.getMsisdn(caseId);
        test.stopTest();
        system.assert(result != null);

    }
    
    private static String getMockJson(){
        String mockJson = '{"apiVersion":"1;2019-10-06","transactionId":"Id-5848985f3ed403823963a44d","error":{"httpCode":"400","errorCode":"API-SUBSCRIVERVAS-001","message":"Invalid Request for operation","detailedMessage":null,"link":{"rel":"related","href":"https://oag.claro.com.br/docs/error_codes.html"}}}';
        return mockJson;
    }
}