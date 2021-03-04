@isTest
public class CEC_CC_ServiceLogScheduleTest {
    
    @testSetup
    public static void setup()
    {
        Account varAccount = CEC_SobjectFactory.getAccount();
        Database.insert(varAccount);
        
        List<Case> lstCases = new List<Case>();

        Case varCase = CEC_SobjectFactory.getCase(varAccount);
        varCase.BusinessUnit__c 	 = 'Claro DTH';
        varCase.Product__c 			 = 'Claro Fone';
        varCase.Contract__c = '999/999999999';
        lstCases.add(varCase);
        
        ServiceParameter__c varServiceParameter = CEC_SobjectFactory.getServiceParameter('CEC_OAG_NET_Ocurrency', 
                                                                                         'https://apiuat.net.com.br:7443/sdp/contactrecords', 
                                                                                         'POST',
                                                                                         'x1234',
                                                                                         'APP_SALESFORCE_CEC');
        insert varServiceParameter;
        
        
        ServiceParameter__c varServiceParameter02 = CEC_SobjectFactory.getServiceParameter('CEC_OAG_Claro_Protocol', 
                                                                                         'https://oagcechomolog.claro.com.br/P06CEC/corp/interactions', 
                                                                              			 'POST','x1234','APP_TESTE');
        varServiceParameter02.NamedCredential__c = 'OAGClaro';
        insert varServiceParameter02;
        
        Contact varContact = CEC_SobjectFactory.getContact();
        insert varContact;            
        
        Map<String, Map<String, CEC_CC_PS8Classification__mdt>> mapClassification = 
            CEC_CC_ClassificationMdtDAO.getClassificationType(new Set<String>{'Claro DTH'}, 
                                                              new Set<String>{'Claro Fone', 'Claro TV Livre'});
        
        for(CEC_CC_PS8Classification__mdt classification : mapClassification.get('Claro DTH').values()){
            Case varCase02 = CEC_SobjectFactory.getCase(varContact);
            varCase02.BusinessUnit__c 	 = 'Claro DTH';
            varCase02.Contract__c = '999/999999999';
            varCase02.Product__c = classification.product__c;
			lstCases.add(varCase02);
        }
        
        insert lstCases;
    }
    
    @IsTest
    public static void testScheduleSuccess()
    {
        String CRON_EXP = '0 0 0 15 3 ? *';        
                
        ServiceLog__b service = new ServiceLog__b();

        Test.StartTest();
        
            Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());

        	String jobId = System.schedule('CEC_CC_ServiceLogScheduleTest',  CRON_EXP, new CEC_CC_ServiceLogSchedule());
                				
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);    
        
    }
    
    @IsTest
    public static void testScheduleError() 
    {
		
        String CRON_EXP = '0 0 0 15 3 ? *';     
                
        ServiceLog__b service = new ServiceLog__b();

        Test.StartTest();
        
            Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseErrorTest());

        	String jobId = System.schedule('CEC_CC_ServiceLogScheduleTest',  CRON_EXP, new CEC_CC_ServiceLogSchedule());
                				
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);    
        
    }
    
                  

}