@isTest
public class Solar_Cross_SyncLegacySystemsTest {
    @testSetup static void charge(){
        List<ServiceParameter__c> params = new List<ServiceParameter__c>();
        params.add(getServiceParameter('/contactrecords', 'POST', 'CEC_OAG_NET_Ocurrency', 'MCIDAS', 'OAGNet'));
        params.add(getServiceParameter('/interactions', 'POST', 'CEC_OAG_Claro_Protocol', 'MCIDAS', 'OAGClaro'));
        insert params;
    }
    @isTest static void testCreateOcurrencyNETSMS(){
        Case cs = getCase('NET', 'Banda Larga');
        insert cs;
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{}', 200));
        Test.startTest();
        Solar_Cross_SyncLegacySystems.syncWithLegacySystems(new List<Id>{cs.Id});
        Test.stopTest();
    }
    @isTest static void testCreateProtocolPS8(){
        Case cs = getCase('Claro', 'Banda Larga');
        insert cs;
        Test.setMock(HttpCalloutMock.class, new SingleMockCallout('{"apiVersion": "string","transactionId": "string","data": {"protocolNumber": "string","interactionNumber": "string"}}', 200));
        Test.startTest();
        Solar_Cross_SyncLegacySystems.syncWithLegacySystems(new List<Id>{cs.Id});
        Test.stopTest();
    }
    private static Case getCase(String businessUnit, String product){
        Case cs = new Case();
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();
        cs.Product__c = product;
        cs.BusinessUnit__c = businessUnit;
        cs.Resolution__c = 'Resolução da Resolução';
        cs.LegacyProtocol__c = '72645152';
        cs.InteractionNumber__c = '37856723673';
        cs.Channel__c = 'Atendimento Pessoal (ATP)';
        cs.Origin = 'Telefone';
        cs.Subject = 'Resolução da Resolução';
        cs.Description = 'Resolução da Resolução';
        cs.Status = 'Novo';
        cs.EntryReason__c = 'Validação de Contestação de Valores';
        cs.LeavingReason__c = 'Contestação Parcialmente Aprovada';
        cs.Type = 'Pergunta';
        cs.CallReason__c = 'Produto';
        cs.RequestSupport__c = 'Descrição';	
        return cs;
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