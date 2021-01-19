/**
 * @description       : 
 * @author            : lucas.soldi@ibm.com
 * @group             : 
 * @last modified on  : 01-04-2021
 * @last modified by  : lucas.soldi@ibm.com
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   12-31-2020   lucas.soldi@ibm.com   Initial Version
**/
public class SolarCross_IntegrationContactPhones {
    
    public static Map<String,Object> getContactPhones(String CPF_CNPJ){

        Map<String,Object> data = new Map<String,Object>();
        ServiceParameter__c serviceParam = ServiceParameter__c.getInstance('ContactPhones'); 
        System.debug('serviceParam: ' + serviceParam);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        System.debug('CPF_CNPJ: '+CPF_CNPJ);
        request.setEndpoint(serviceParam.endpoint__c.replace('CPFCNPJ',CPF_CNPJ));
        request.setMethod(serviceParam.Method__c);
        request.setTimeout(Integer.valueOf(serviceParam.Timeout__c));
        if(serviceParam.returnMock__c){
            data.put('statusCode',200);
            data.put('response','{"apiversion":"1;2019-11-02","transactionId":"Id-645c0060dd1e3f9c813ed373","data":{"customerDocument":"00896571000156","VIP":"true","customerPhones":[{"phoneNumber":"11940313777","rank":"0","doNotDisturb":"true"},{"phoneNumber":"19987736947","rank":"1","doNotDisturb":"true"},{"phoneNumber":"11994394610","rank":"2","doNotDisturb":"true"},{"phoneNumber":"11998538808","rank":"3","doNotDisturb":"false"},{"phoneNumber":"67991629087","rank":"4","doNotDisturb":"true"}]}}'
            );
            data.put('endPoint',serviceParam.endpoint__c.replace('CPFCNPJ',''));

            return data;
        }
        HttpResponse response = http.send(request);
        data.put('statusCode',response.getStatusCode());
        data.put('endPoint',serviceParam.endpoint__c.replace('CPFCNPJ',CPF_CNPJ));
        System.debug('response: '+ response);
        System.debug('endpoint:: ' + serviceParam.endpoint__c.replace('CPFCNPJ',CPF_CNPJ));
        data.put('response',response.getBody());
        return data;




    }

    public class JSONContactPhones{
        public String apiversion;
        public String transactionId;
        public Data data;
    }

    public class Data{
        public String customerDocument;
        public String VIP;
        public List<CustomerPhones> customerPhones;
    }

    public class CustomerPhones{
        public String phoneNumber;
        public String rank;
        public String doNotDisturb;
    }
}