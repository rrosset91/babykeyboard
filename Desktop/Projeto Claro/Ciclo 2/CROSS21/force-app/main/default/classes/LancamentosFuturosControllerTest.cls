@isTest public class LancamentosFuturosControllerTest {
 
    @TestSetup static void charge(){
        
        List<Case> lCaseLst = new List<Case>{ new Case(Subject = 'Default', RecordTypeId = CASE_RECTYPE) };
		insert lCaseLst;

        List<ServiceParameter__c> settings = new List<ServiceParameter__c>();
        
        ServiceParameter__c historySettings = new ServiceParameter__c();
        historySettings.name = 'futureReleaseAttributes';
        historySettings.EndPoint__c = 'https://api-test.claro.com.br/residential/v1/billingaccounts/contestationfuturereleaseitens';
        historySettings.Method__c = 'GET';
        historySettings.Timeout__c = 120000;
        historySettings.ReturnMock__c = true;
        settings.add(historySettings);
        insert settings;
        
        Id recordTypeIdAccount   = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId(); 
        Account contrato =  new Account(
            RecordTypeId = recordTypeIdAccount,
            name = 'Teste',
            ContractReferenceNumber__c = '001027935',
            StatusLegado__c  =  'Conectado' ,
            vlocity_cmt__CustomerValue__c = 'Black'
        );
        Insert contrato;
    }
    @isTest static void getCasedetailsTest(){
        String caseId = [SELECT Id FROM Case LIMIT 1].Id;
        Test.startTest();
        LancamentosFuturosController.getCasedetails(caseId);
        Test.stopTest();
    }
    
    @isTest static void getHistoryByDatePeriodFailTest(){
        Integer period = 24;
        Date startDate = Date.newInstance(2018, 09, 11);
        Date endDate = Date.newInstance(2020, 09, 10);
		Test.startTest();
        String contractId = '1027935';
		Map<String, Object> result = LancamentosFuturosController.getHistoryByDatePeriod(contractId, '038','FUTURE_RELEASE', period, startDate, endDate, null);
    	Test.stopTest();
        system.assertEquals(false, result.get('success'));
    }
    
    @isTest static void getHistoryByDatePeriodSuccessTest(){
        Integer period = 24;
        Date startDate = Date.newInstance(2018, 09, 11);
        Date endDate = Date.newInstance(2020, 09, 10);
		Test.startTest();
        String contractNumber = [SELECT ContractReferenceNumber__c FROM Account LIMIT 1].ContractReferenceNumber__c;
		Map<String, Object> result = LancamentosFuturosController.getHistoryByDatePeriod('1027935','038','MOCK_FUTURE_RELEASE', period, startDate, endDate, null);
    	Test.stopTest();
        system.assertEquals(true, result.get('success'));
    }

    @isTest static void getHistoryEventsTestError(){
        test.startTest();
            try{
            	LancamentosFuturosController.setParamsHistory('','','','','');
            }
        	catch(Exception e) {
                String exceptionMessage = e.getMessage();
                String expectedMessage = 'Todos os parâmetros para realizar a busca devem ser preenchidos';
            	System.assertEquals(exceptionMessage.contains(expectedMessage) , true);
            }
        test.stopTest();
    }
    
    @isTest static void setErrorTest(){
        test.startTest();
        LancamentosFuturosController.setErrorMessage(getSuccessReturnJson('error'));
        test.stopTest();
    }

    private static String getSuccessReturnJson(String state){
        String returnJson;
        if(state == 'success'){
        	returnJson = '{"billDocumentList":[{"id":1573714038,"billNo":225168222,"billId":244986912,"paymentDueDate":"2019-08-10T00:00:00Z","billDate":"2019-07-01T00:00:00Z","description":"ALUGUEL DE EQUIP HABILITADO","name":"Mensalidade NET TV","installments":null,"extractItemTypeId":452,"extractItemTypeDescription":"ALUGUEL DE EQUIP HABILITADO","amountDue":25,"isContestation":"NAO","complement":null,"reasonId":null,"reasonDescription":null,"invoiceItemGroupDemoId":13,"invoiceItemGroupDemoDescription":"Mensalidade NET TV","extractItemStatus":"ISSUED","extractItensDetails":[{"partnerId":"1","partnerName":"NET","contractid":"1027935","affiliatedContractid":null,"installmentNumber":null,"installmentsCount":1,"productId":18714,"productDescription":"TOP HD CINEMA FID 18714","detTypeExtractItemNote":"ALUGUEL DE EQUIP HABILITADO","registrationUser":"PROD_JD","note":null,"isMinimumValueExtended":"N"}]}]}';
        }else{
            returnJson = '{"apiVersion":"1","transactionId":"9daa3a97-8d4a-4f4a-8d82-4986d72710c9","error":{"httpCode":500,"errorCode":"API-CUSTOMERSFINANCIALACC-500","message":"Internal Server Error","detailedMessage":"Backend: [filtered exception]","link":{"rel":"related","href":"https://api.claro.com.br/docs"}}}';
        }
        return returnJson;
    }
    private static final Id CASE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
}