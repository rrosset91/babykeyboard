/**
 * @description       : 
 * @author            : lucas.soldi@ibm.com
 * @group             : 
 * @last modified on  : 12-28-2020
 * @last modified by  : lucas.soldi@ibm.com
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-28-2020   lucas.soldi@ibm.com   Initial Version
**/
@isTest
public class Solar_Cross_PushNotificationAPITest {
    @TestSetup
    static void makeData(){
        
        List<ServiceParameter__c> lstService = new List<ServiceParameter__c>();

		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'CommunicationPush';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = 'POST';
		customSetting.Timeout__c = 120;

		ServiceParameter__c customSetting2 = new ServiceParameter__c();
		customSetting2.name = 'PushNotificationToken';
		customSetting2.EndPoint__c = '00';
		customSetting2.Method__c = 'GET';
		customSetting2.Timeout__c = 120;
		lstService.add(customSetting);
		lstService.add(customSetting2);
		insert lstService;
    }

    @isTest
    static void communicationAPITest(){
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource('/Solar_Cross_PushNotificationAPIToken','Solar_Cross_PushNotificationAPIToken');
        lMultimock.setStaticResource('/Solar_Cross_CommunicationPush','Solar_Cross_CommunicationPush');
        lMultimock.setStatusCode(200);
		lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);
        Solar_Cross_PushNotificationAPI.CommunicationAPIPayloadWrapper objCom = new Solar_Cross_PushNotificationAPI.CommunicationAPIPayloadWrapper();
        Solar_Cross_PushNotificationAPI.CommunicationResponseWrapper objResponse = new Solar_Cross_PushNotificationAPI.CommunicationResponseWrapper();
        objCom.data.campaign = 'OS74747';
        objCom.data.channel = '1';
        objCom.data.destination = '5511986498353';
        objCom.data.message = 'Olá SMS';
        objCom.data.templateCode ='';
        objCom.data.templateData = '';
        objCom.data.layout = '';
        objCom.data.customization = '';
        objCom.data.mobileClient = '1';
        objCom.data.project = 'Envio de protocolo';
        objCom.data.validator = '100';
        objCom.data.telephoneNumber ='5511999999999';
        Test.startTest();
        Solar_Cross_PushNotificationAPI.ComponentReturnWrapper objReturn = Solar_Cross_PushNotificationAPI.communicationAPI(objCom);
        Test.stopTest();
        System.assertEquals(true,objReturn.success);

    }

    @isTest
    static void communicationAPITokenTestError(){
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource('/Solar_Cross_PushNotificationAPIToken1','Solar_Cross_PushNotificationAPIToken');
        lMultimock.setStaticResource('/Solar_Cross_CommunicationPush1','Solar_Cross_CommunicationPush');
        lMultimock.setStatusCode(400);
		lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);
        Solar_Cross_PushNotificationAPI.CommunicationAPIPayloadWrapper objCom = new Solar_Cross_PushNotificationAPI.CommunicationAPIPayloadWrapper();
        Solar_Cross_PushNotificationAPI.TokenWrapper objToken = new Solar_Cross_PushNotificationAPI.TokenWrapper();
        objCom.data.campaign = 'OS74747';
        objCom.data.channel = '1';
        objCom.data.destination = '5511986498353';
        objCom.data.message = 'Olá SMS';
        objCom.data.templateCode ='';
        objCom.data.templateData = '';
        objCom.data.layout = '';
        objCom.data.customization = '';
        objCom.data.mobileClient = '1';
        objCom.data.project = 'Envio de protocolo';
        objCom.data.validator = '100';
        objCom.data.telephoneNumber ='5511999999999';
        Test.startTest();
        Solar_Cross_PushNotificationAPI.ComponentReturnWrapper objReturn = Solar_Cross_PushNotificationAPI.communicationAPI(objCom);
        Test.stopTest();
        System.assertEquals(false,objReturn.success);


    }

    @isTest
    static void communicationAPICommunicationTestError(){
        MultiStaticResourceCalloutMock lMultimock = new MultiStaticResourceCalloutMock();
        lMultimock.setStaticResource('/Solar_Cross_PushNotificationAPIToken','Solar_Cross_PushNotificationAPIToken');
        lMultimock.setStaticResource('/Solar_Cross_CommunicationPush111','Solar_Cross_CommunicationPush11');
        lMultimock.setStatusCode(200);
		lMultimock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, lMultimock);
        Solar_Cross_PushNotificationAPI.CommunicationAPIPayloadWrapper objCom = new Solar_Cross_PushNotificationAPI.CommunicationAPIPayloadWrapper();
        objCom.data.campaign = 'OS74747';
        objCom.data.channel = '1';
        objCom.data.destination = '5511986498353';
        objCom.data.message = 'Olá SMS';
        objCom.data.templateCode ='';
        objCom.data.templateData = '';
        objCom.data.layout = '';
        objCom.data.customization = '';
        objCom.data.mobileClient = '1';
        objCom.data.project = 'Envio de protocolo';
        objCom.data.validator = '100';
        objCom.data.telephoneNumber ='5511999999999';
        Test.startTest();
        Solar_Cross_PushNotificationAPI.ComponentReturnWrapper objReturn = Solar_Cross_PushNotificationAPI.communicationAPI(objCom);
        Test.stopTest();
        System.assertEquals(true,objReturn.message.startsWith('Communication'));

    }
}