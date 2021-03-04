public class CEC_360_LGPD_InteractionPS8_WP {

    public class InteractionPS8Request { 

        @AuraEnabled public Data   data                 =  new Data();  // "XJEET2346FhK", 
    }  

    public class Data {
        @AuraEnabled public String protocolnumber       =  '';  // "XJEET2346FhK",
        @AuraEnabled public String status               =  '';  // "FECHADO",
        @AuraEnabled public String details              =  '';  // "Codigo de rastreabilidade: 1234",
    /*  @AuraEnabled public String severity             =  '';  // "MINIMA",
        @AuraEnabled public String situation            =  '';  // "NOVO",
        @AuraEnabled public String notes                =  '';  // "Incidente resolvido com sucesso e sem resalvas",
        @AuraEnabled public String slaDueDate           =  '';  // "2018-01-12T12:10:30-03:00",
        @AuraEnabled public String priority             =  '';  // "BAIXA",
        @AuraEnabled public String caseTypeId           =  '';  // "12345", 
        @AuraEnabled public String systemRelatedCaseId  =  '';  // "SalesForce"
    */
    }
    
    public class InteractionPS8response {

        @AuraEnabled public String apiVersion    = ''; //"1;2020-06-11",
        @AuraEnabled public String transactionId = ''; //"e6e4e0f4-089d-4194-845e-78f45426f7c7",

        @AuraEnabled public Data  data  = new Data(); 
        @AuraEnabled public Error error = new Error(); 
    }

//    public class Data {
//        @AuraEnabled public String protocolnumber = ''; //"XJEET2346FhK"
//    }

    public class Error {
        @AuraEnabled public String httpCode        = ''; //"400",
        @AuraEnabled public String errorCode       = ''; //"API-CUSTOMERSINTERACTIONS-400",
        @AuraEnabled public String message         = ''; //"Bad Request",
        @AuraEnabled public String detailedMessage = ''; //"Bad Request",
        
        @AuraEnabled public Link link = new Link(); 
    }

    public class Link {
        @AuraEnabled public String rel  = ''; //"related"
        @AuraEnabled public String href = ''; //"https://api.claro.com.br/docs"
    } 
}