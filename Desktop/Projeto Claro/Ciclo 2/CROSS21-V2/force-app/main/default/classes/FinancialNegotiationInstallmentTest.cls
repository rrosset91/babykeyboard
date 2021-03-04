/**
 * @description       : US101348
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 01-03-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-01-2021   Diego Almeida   Initial Version
**/
@isTest
public with sharing class FinancialNegotiationInstallmentTest {
    @TestSetup
    static void makeData(){
        List<ServiceParameter__c> lstParams = new List<ServiceParameter__c>();
            ServiceParameter__c customSetting = new ServiceParameter__c(
                Name = 'InvoicesNegotiationOptions',
                EndPoint__c = 'InvoicesNegotiationOptions',
                Method__c = 'POST',
                Timeout__c = 120
            );
            lstParams.add(customSetting);
            customSetting = new ServiceParameter__c(
                Name = 'CustomerProconPropensity',
                EndPoint__c = 'CustomerProconPropensity',
                Method__c = 'GET',
                Timeout__c = 120
            );
            lstParams.add(customSetting);
            customSetting = new ServiceParameter__c(
                Name = 'CustomerDefaultSegmetation',
                EndPoint__c = 'CustomerDefaultSegmetation',
                Method__c = 'GET',
                Timeout__c = 120
            );
            lstParams.add(customSetting);
        insert lstParams;


		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();
            Parameters__c parametro = new Parameters__c(
                name = 'Teste Param',
                Channel__c = 'Atendimento',
                Process__c = 'Negociação',
                Profile__c = 'CEC_Backoffice',
                RecordTypeId = recordTypeIdParameter,
                Active__c = true,
                Amount__c = 1000,
                Business_Division__c = 'Residencial'
            );
        insert parametro;


        Account contrato = AccountDataFactory.getSingleAccount('Billing');
			contrato.ContractReferenceNumber__c = ('229531991');
			contrato.StatusLegado__c = 'Conectado';
        insert contrato;

		Id consumerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Consumer').getRecordTypeId();
            Account consumer = new Account(
                DocumentNumber__c = '64204294987',
                DocumentType__c = 'CPF',
                Name = 'MassaInadimplencia Residencial - Consumidor',
                RecordTypeId = consumerRecordType
            );
		insert consumer;

		Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
            Case casoAtual = new Case(
                AccountId = consumer.id,
                ContractBillingAccount__c = contrato.id,
                RecordTypeId = caseRecordType,
                Subject = 'Caso Atual'
            );
        insert casoAtual;

        List<String> lstPermission = new List<String>();
		lstPermission.add('AttendanceN1');
		lstPermission.add('CEC_Backoffice');
		Map<String, List<sObject>> returnProfileMap = UserDataFactory.getMockUserRoleProfiles('System Administrator', 'SupervisorCRC', lstPermission);
		List<sObject> ps = returnProfileMap.get('permissions');
		List<sObject> role1 = returnProfileMap.get('role');
		List<sObject> profile1 = returnProfileMap.get('profile');

		//current user
		User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		//force to avoid mixed dml error
		System.runAs(currentUser) {
			User usuario = UserDataFactory.getSingleUser(role1[0].Id, profile1[0].Id, 'dabliudabliudabliu@gmail.com');
			insert usuario;
			insert new PermissionSetAssignment(AssigneeId = usuario.id, PermissionSetId = ps[0].Id);
		}
    }
    @IsTest
    static void getInstallmentPlanTest(){
        String casoAtual = [SELECT Id FROM Case WHERE Subject = 'Caso Atual' LIMIT 1].Id;
        String contractAccountSalesforceId = [SELECT Id FROM Account WHERE ContractReferenceNumber__c = '229531991' LIMIT 1].Id;
        User u = [SELECT id FROM User WHERE email = 'dabliudabliudabliu@gmail.com'];

		System.runAs(u){
            Test.startTest();
                String baseAtributes = '{"businessUnit":"Net","contractAccountSalesforceId":"'+contractAccountSalesforceId+'","contractId":"14053010","customerValue":"Black","isCase":true,"isMobileContract":false,"isN2User":true,"isViewOnly":false,"numeroCase":"05110067","operatorId":"011","recordId":"'+casoAtual+'","statusCase":"In Progress","typeCase":"Financeiro","caseId":"'+casoAtual+'"}';
                String baseDetails = '{"billsIdsString":["172648772"],"bills":[{"type":"Fatura","dataVencimento":"05/01/2020","invoiceAmount":399.1,"billId":"172648772"}],"selectedBills":["172648772"],"statements":[],"statementsIdsString":[],"fullSumSelectedItems":399.1}';
                Test.setMock(HttpCalloutMock.class, new Mock());

                Map<String,Object> result = FinancialNegotiationInstallment.getInstallmentPlan(baseAtributes, baseDetails);
                System.assertEquals(result.get('alcada'), true);
                System.debug('@@getInstallmentPlanTest:: result => '+ JSON.serializePretty(result));

            Test.stopTest();
        }

    }
    @IsTest
    static void getInstallmentValuesTest(){
        String casoAtual = [SELECT Id FROM Case WHERE Subject = 'Caso Atual' LIMIT 1].Id;
        String contractAccountSalesforceId = [SELECT Id FROM Account WHERE ContractReferenceNumber__c = '229531991' LIMIT 1].Id;

        User u = [SELECT id FROM User WHERE email = 'dabliudabliudabliu@gmail.com'];

		System.runAs(u) {
            Test.startTest();
                String baseAtributes = '{"businessUnit":"Net","contractAccountSalesforceId":"'+contractAccountSalesforceId+'","contractId":"14053010","customerValue":"Black","isCase":true,"isMobileContract":false,"isN2User":true,"isViewOnly":false,"numeroCase":"05110067","operatorId":"011","recordId":"'+casoAtual+'","statusCase":"In Progress","typeCase":"Financeiro","caseId":"'+casoAtual+'"}';
                String baseDetails = '{"billsIdsString":["172648773"],"bills":[{"type":"Fatura","dataVencimento":"05/01/2020","invoiceAmount":399.1,"billId":"172648773"}],"selectedBills":["172648773"],"statements":[],"statementsIdsString":["172648773"],"fullSumSelectedItems":399.1,"selectedInstallment":{"ofertaParcelamento":"A vista","descontoParcelamento":"Desconto de 25%","quantidadeParcelamento":3,"porcentagemDesconto":50,"primeiroVencimento":"05/02/2020"}}';
                Test.setMock(HttpCalloutMock.class, new Mock());

                Map<String,Object> result = FinancialNegotiationInstallment.getInstallmentValues(baseAtributes, baseDetails);
                System.assertEquals(result.get('success'), true);
                System.debug('@@getInstallmentValuesTest:: result => '+ JSON.serializePretty(result));
            Test.stopTest();
        }
    }

    @IsTest
    static void updateCaseTest(){
        String casoAtual = [SELECT Id FROM Case WHERE Subject = 'Caso Atual' LIMIT 1].Id;
        String contractAccountSalesforceId = [SELECT Id FROM Account WHERE ContractReferenceNumber__c = '229531991' LIMIT 1].Id;

        User u = [SELECT id FROM User WHERE email = 'dabliudabliudabliu@gmail.com'];

		System.runAs(u) {
            Test.startTest();
                String baseAtributes = '{"businessUnit":"Net","contractAccountSalesforceId":"'+contractAccountSalesforceId+'","contractId":"14053010","customerValue":"Black","isCase":true,"isMobileContract":false,"isN2User":true,"isViewOnly":false,"numeroCase":"05110067","operatorId":"011","recordId":"'+casoAtual+'","statusCase":"In Progress","typeCase":"Financeiro","caseId":"'+casoAtual+'"}';
                String baseDetails = '{"billsIdsString":["172648773"],"bills":[{"type":"Fatura","dataVencimento":"05/01/2020","invoiceAmount":399.1,"billId":"172648773"}],"selectedBills":["172648773"],"statements":[],"statementsIdsString":[],"fullSumSelectedItems":399.1,"selectedInstallment":{"ofertaParcelamento":"A vista","descontoParcelamento":"Desconto de 25%","quantidadeParcelamento":2,"porcentagemDesconto":50,"primeiroVencimento":"05/02/2020"}}';
                Test.setMock(HttpCalloutMock.class, new Mock());
                Map <String, Object> caseData = new Map <String, Object>();
                caseData.put('caseID', casoAtual);
                caseData.put('status', 'Closed');
                caseData.put('leavingReason', 'Negociação não realizada -Erro ao tentar negociar');
                caseData.put('errorMessage', 'Nao foi encontrada alcada referente ao solicitado');


                Case result = FinancialNegotiationInstallment.closeCaseNegotiation(caseData);
                System.assertEquals(result.Status, 'Closed');
                System.debug('@@getInstallmentValuesTest:: result => '+ JSON.serializePretty(result));
            Test.stopTest();
        }
    }

    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('InvoicesNegotiationOptions')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"apiVersion":"1;2019-11-06","transactionId":"Id-f6e809605218846c3de6bbb0","data":{"termRenegotiationId":null,"cityId":"08533","contractId":14053010,"functionalityRuleId":10,"checkUseItemRenegotiation":"N","enableFirstInstallmentSeparateDebts":0,"firstInstallmentValue":0.0,"firstInstallmentMinimumValue":0.0,"checkChargeNegativity":0,"discountType":"P","canGiveDiscount":true,"MaximumDiscountPerProfile":100.0,"calcTotal":357.46,"totalDebt":357.46,"totalTicket":7.97,"totalInterest":50.17,"total":399.1,"invoicesItensUnification":[{"debtValue":374.12,"ticketValue":7.48,"interestValue":47.03,"totalDebt":335.1,"floatingPointDifValue":0.0,"proportionalDiscountValue":0.0,"partnerId":1,"partnerName":"NET","serviceTypeId":1,"serviceTypeDescription":"CLARO GERAL"},{"debtValue":0.0,"ticketValue":0.0,"interestValue":0.0,"totalDebt":0.0,"floatingPointDifValue":0.0,"proportionalDiscountValue":0.0,"partnerId":1,"partnerName":"NET","serviceTypeId":2,"serviceTypeDescription":"CLARO TV"},{"debtValue":0.0,"ticketValue":0.0,"interestValue":0.0,"totalDebt":0.0,"floatingPointDifValue":0.0,"proportionalDiscountValue":0.0,"partnerId":1,"partnerName":"NET","serviceTypeId":3,"serviceTypeDescription":"CLARO INTERNET"},{"debtValue":24.98,"ticketValue":0.49,"interestValue":3.14,"totalDebt":22.36,"floatingPointDifValue":0.0,"proportionalDiscountValue":0.0,"partnerId":2,"partnerName":"EMBRATEL","serviceTypeId":null,"serviceTypeDescription":null}],"bills":[{"bill":172648773}],"statements":[],"installmentOptions":[{"number":1,"amount":0,"amountInter":0,"firstValue":357.47,"intermediaryValue":0.0,"lastValue":0.0,"dueDate":"2020-02-05","firstInterest":50.17,"firstTicket":7.97,"intermediaryInterest":0.0,"intermediaryTicket":0.0,"lastInterest":0.0,"lastTicket":0.0},{"number":2,"amount":1,"amountInter":0,"firstValue":178.75,"intermediaryValue":0.0,"lastValue":178.72,"dueDate":"2020-02-05","firstInterest":25.09,"firstTicket":3.99,"intermediaryInterest":0.0,"intermediaryTicket":0.0,"lastInterest":25.08,"lastTicket":3.98},{"number":3,"amount":2,"amountInter":1,"firstValue":119.19,"intermediaryValue":119.14,"lastValue":119.14,"dueDate":"2020-02-05","firstInterest":16.73,"firstTicket":2.67,"intermediaryInterest":16.72,"intermediaryTicket":2.65,"lastInterest":16.72,"lastTicket":2.65}],"negotiationReason":[{"reasonId":1,"description":"DESABILITACAO"},{"reasonId":2,"description":"RECUPERACAO"},{"reasonId":3,"description":"RECUPERACAO ESPECIAL"}],"profileList":[],"paymentList":[{"methodCode":1,"methodDescription":"BOLETO"}],"associatedBanks":[{"bankCode":237,"bankName":"BANCO BRADESCO S.A."},{"bankCode":1,"bankName":"BANCO DO BRASIL S.A."},{"bankCode":37,"bankName":"BANCO DO ESTADO DO PARA"},{"bankCode":77,"bankName":"BANCO INTER S.A."},{"bankCode":341,"bankName":"BANCO ITAU S.A."},{"bankCode":389,"bankName":"BANCO MERCANTIL DO BRASIL S.A."},{"bankCode":212,"bankName":"BANCO ORIGINAL S.A."},{"bankCode":422,"bankName":"BANCO SAFRA S/A"},{"bankCode":33,"bankName":"BANCO SANTANDER"},{"bankCode":47,"bankName":"BANESE"},{"bankCode":21,"bankName":"BANESTES S/A"},{"bankCode":41,"bankName":"BANRISUL"},{"bankCode":104,"bankName":"CAIXA ECONOMICA FEDERAL"},{"bankCode":745,"bankName":"CITIBANK"}],"contractSubscriber":[{"subscriberId":4488007,"name":"MARCEL AUGUSTUS BARBOSA CARVALHO","mail":"MARCEL.AUGUSTUS@GMAIL.COM","cellPhoneSubscriber":"67992179169"}],"sendMethod":[{"typeShippingCode":"C","typeShippingDescription":"Correio"},{"typeShippingCode":"E","typeShippingDescription":"E-mail"}]}}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('CustomerProconPropensity')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"apiVersion":"1;2020-10-01","transactionId":"da7c4d27-d7d2-4b47-bcb3-eb9092e25cfb","error":{"httpCode":504,"errorCode":"API-CUSTOMERPROCONSCORE-504","message":"Gateway Timeout","detailedMessage":"Gateway Timeout","link":{"rel":"related","href":"https://api.claro.com.br/docs"}}}');
                res.setStatusCode(500);
                return res;
            } else if (req.getEndpoint().startsWith('CustomerDefaultSegmetation')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"apiVersion":"1;2020-10-01","transactionId":"da7c4d27-d7d2-4b47-bcb3-eb9092e25cfb","error":{"httpCode":504,"errorCode":"API-CUSTOMERPROCONSCORE-504","message":"Gateway Timeout","detailedMessage":"Gateway Timeout","link":{"rel":"related","href":"https://api.claro.com.br/docs"}}}');
                res.setStatusCode(500);
                return res;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
}