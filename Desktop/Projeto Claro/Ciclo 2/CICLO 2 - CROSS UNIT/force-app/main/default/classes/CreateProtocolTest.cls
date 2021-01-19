@isTest
public class CreateProtocolTest{
    
public static testMethod void  testtHttpPost() {
    string jsonrequest = '{ "cpf": "11111122222", "requestType": "Direitos-Acesso_Dados_Cadastrais", "nome": "Tiburcio ", "email": "Rodolfo@hotmail.com", "telefone": "11988887777", "canal": "Digital",persona": "NetCombo"}'; 
   string jsonresponse = '{ "Protocol": "202043525632477" }';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/createProtocol'; //Request URL
    req.httpMethod = 'POST';
    req.requestBody = blob.valueOf(jsonrequest);
    req.addHeader('Content-Type', 'application/json');
    res.statusCode = 200;
    res.responseBody = blob.valueOf(jsonresponse);
    RestContext.request = req;
    RestContext.response= res;
    
    string testresponse = res.responseBody.toString();

    CreateProtocol.createProtocolController('11111122237','Direitos-Acesso_Dados_Cadastrais','Tiburcio da silva','Rodolfo@hotmail.com','11988887777','Digital','netcombo');//HttpClass.updateCustomObject();
    //Test.stopTest();
 system.assert(testresponse.contains('Protocol'));

}
    public static testMethod void  testtHttpPost2() {

    string jsonrequest = '{ "cpf": "11111122222", "requestType": "Direitos-Acesso_Dados_Cadastrais", "nome": "Tiburcio ", "email": "Rodolfo@hotmail.com", "telefone": "11988887777", "canal": "Digital",persona": "NetCombo"}'; 
   string jsonresponse = '{ "Protocol": "202043525632477" }';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/createProtocol'; //Request URL
    req.httpMethod = 'POST';
    req.requestBody = blob.valueOf(jsonrequest);
    req.addHeader('Content-Type', 'application/json');
    res.statusCode = 200;
    res.responseBody = blob.valueOf(jsonresponse);
    RestContext.request = req;
    RestContext.response= res;
    
    
       
   CreateProtocol.createProtocolController('11111122231','Consentimento','Tiburcio da silva','Rodolfo@hotmail.com','2312412433','EX_CLIENTE_ATE6MESES','MCR-SITE');//HttpClass.updateCustomObject();

}
    public static testMethod void  testtHttpPost3() {

    string jsonrequest = '{ "cpf": "11111122222", "requestType": "Direitos-Acesso_Dados_Cadastrais", "nome": "Tiburcio ", "email": "Rodolfo@hotmail.com", "telefone": "11988887777", "canal": "Digital",persona": "NetCombo"}'; 
   string jsonresponse = '{ "Protocol": "202043525632477" }';
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/createProtocol'; //Request URL
    req.httpMethod = 'POST';
    req.requestBody = blob.valueOf(jsonrequest);
    req.addHeader('Content-Type', 'application/json');
    res.statusCode = 200;

    RestContext.request = req;
    RestContext.response= res;
     
                      Account acct = new Account(documentNumber__c = '52654647511', 
                                           name = 'NOME', 
                                           documentType__c ='CPF',
                                           Email__c  = 'email@hotmail.com',
                                           Phone = '1192356745',
                                           ExternalID_DL__c = 'CPF'+ '52654647511',
                                           vlocity_cmt__BillingEmailAddress__c = 'email@hotmail.com',
                                           CustomerTypeList__c = 'persona'
                                          );
        insert acct;
    

    CreateProtocol.createProtocolController('52654647511','Consentimento','Tiburcio da silva','Rodolfo@hotmail.com','2312412433','EX_CLIENTE_ATE6MESES','MCR-SITE');//HttpClass.updateCustomObject();


}
}