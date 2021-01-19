@isTest
public class Solar_Cross_GenerateProtocolTest {
	
    @testSetup static void charge(){
        List<ServiceParameter__c> params = new List<ServiceParameter__c>();
        params.add(getServiceParameter('/interactions', 'POST', 'CEC_OAG_Claro_ProtocolNETSMS', 'MCIDAS', 'OAGNet'));
        params.add(getServiceParameter('/interactions', 'POST', 'CEC_OAG_Claro_Protocol', 'MCIDAS', 'OAGClaro'));
        insert params;
    }
    
        @isTest static void testCreateOcurrencyNETSMS(){
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"transactionId":null,"data":{"reasonId":"1","protocolNumber":null,"operatorCode":"004","contractNumber":"010332171"}}', 200));
        Solar_Cross_GenerateProtocol.FlowInputVariables flowVariables= new Solar_Cross_GenerateProtocol.FlowInputVariables();
        flowVariables.businessUnit = 'NET';
        flowVariables.product = 'Banda Larga';
        Test.startTest();
        Solar_Cross_GenerateProtocol.syncWithLegacySystems(new List<Solar_Cross_GenerateProtocol.FlowInputVariables>{flowVariables});
        Test.stopTest();
    	}
    
    @isTest static void testCreateProtocolPS8(){
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{}', 200));
        Solar_Cross_GenerateProtocol.FlowInputVariables flowVariables= new Solar_Cross_GenerateProtocol.FlowInputVariables();
        flowVariables.businessUnit = 'Claro';
        flowVariables.product = 'Banda Larga';
        Test.startTest();
        Solar_Cross_GenerateProtocol.syncWithLegacySystems(new List<Solar_Cross_GenerateProtocol.FlowInputVariables>{flowVariables});
        Test.stopTest();
    }
    
    private static ServiceParameter__c getServiceParameter(String endPoint, String method, String name, String userName, String namedCredential){
        ServiceParameter__c param = new ServiceParameter__c();
        param.Name = name;
        param.EndPoint__c = endPoint;
        param.IsActive__c = true;
        param.Method__c = method;
        param.User__c = userName;
        param.NamedCredential__c = namedCredential;
        return param;
    }    
}