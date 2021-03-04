@IsTest
public class CEC_CC_ContentDocumentLinkHandlerTest {
    
    @testSetup
    private static void setup()
    {
        ServiceParameter__c varServiceParameter = CEC_SobjectFactory.getServiceParameter('CEC_OAG_NET_Ocurrency', 
                                                                                         'https://apiuat.net.com.br:7443/sdp/interactions', 
                                                                              			 'POST','x1234','APP_TESTE');
        insert varServiceParameter;
    }
    
     @isTest 
    public static void createDocumentCEC() 
    {
        String errorTxt;
        
        SubjectAdministration__c outputSubject = new SubjectAdministration__c();
        outputSubject.Name = 'Teste';
        outputSubject.Classification__c = 'Pós';
        outputSubject.BusinessUnit__c = 'NET';
        outputSubject.OutputSubject__c = true;
        outputSubject.SubReason__c = 'Teste';
        database.insert(outputSubject);
        
        DataInfo data 	= new DataInfo();

        data.varAccount = CEC_SobjectFactory.getAccount();
        database.insert(data.varAccount);
        
        data.varCase = CEC_SobjectFactory.getCase(data.varAccount);
        data.varCase.Contract__c = '999/999999999';
        data.varCase.BusinessUnit__c = 'NET';
        data.varCase.Product__c = 'Claro NET Fone';
        data.varCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Consumidor_GOV').getRecordTypeId();        
        database.insert(data.varCase);

        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new CEC_HttpResponseNetSmsTest());
           
            
            data.varCase.Status = 'Encerrado';
            data.varCase.SubStatus__c = 'Encerrado';
            data.varCase.Output_Subject__c = outputSubject.Id;
            data.varCase.Resolution__c = 'TESTESTESTESTESTETESTESTESTESTESTETESTESTESTESTESTETESTESTESTESTESTE';
            data.varCase.Relevant__c = 'Sim';
            database.update(data.varCase);
            
            data.lstContent = CEC_SobjectFactory.getListContentVersion(2);
            database.insert(data.lstContent);
            
            list<ContentDocument> lDocument = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
            
            try{
                ContentDocumentLink lContentDocumentLink = CEC_SobjectFactory.getContentDocumentLink(lDocument[0].Id);
                lContentDocumentLink.LinkedEntityId = data.varCase.Id;
                database.insert(lContentDocumentLink);
            }
            catch(Exception e) {
                errorTxt = e.getMessage();
                errorTxt = errorTxt.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ' , ': [');
            }
            
            system.assertEquals('Não é possível inserir anexo para caso encerrado', errorTxt,
                                'Falha na validação de inserção de anexo para casos encerrado.');
        
        test.stopTest();
    }
    
    public class DataInfo
    {
        public Account varAccount {get;set;}
        public Case varCase {get;set;}
        public List<ContentVersion> lstContent {get;set;}
        public List<String> lstString {get;set;}        
    }
}