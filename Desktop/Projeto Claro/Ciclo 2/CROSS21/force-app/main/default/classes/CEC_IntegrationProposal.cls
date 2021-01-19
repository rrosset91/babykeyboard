public class CEC_IntegrationProposal {
    
    public static ServiceParameter__c param;
    
    public static CEC_RestObjects.ProposalData  consultar( CEC_RestObjects.DataProposal request, string operatorCod)
    {
        param  = ServiceParameter__c.getInstance('ProposalDXC');
        
        String bodyResponse, statusResponse = '-1';
        CEC_RestObjects.ProposalData response;
        
        system.debug(JSON.serialize(request));
        
        CEC_RestObjects.DataProposal lrequest = request;
        
        try {
            HttpRequest req = CEC_HttpReq.genHttpReq(param, '');
            req.setEndpoint(param.EndPoint__c+operatorCod);
            HTTPResponse res = CEC_HttpReq.sendReq(req, request);
            
            bodyResponse = res.getBody();
            system.debug(bodyResponse);
            statusResponse = String.valueOf(res.getStatusCode());
            
            response = (CEC_RestObjects.ProposalData) 
                JSON.deserialize(bodyResponse, CEC_RestObjects.ProposalData.class);
            
        }
        catch (Exception ex)
        {
            if(param.IsActive__c)
            {
                system.debug('EXCEPTION: ' +ex.getMessage());
            }
        }
        return response;
    }    
    
    public class Products {
        public Internet internet {get;set;} 
        public Internet paytv {get;set;} 
        public Internet phone {get;set;} 
        public Internet mobile {get;set;} 
        public Internet alacarte {get;set;} 
    }  
    public class Discount {
        public Integer validity {get;set;} 
    }
    public class Data extends CEC_RestObjects.ResponseGen{  
        public Prospect prospect {get;set;} 
        public Map<String,Object> charge {get;set;} 
        public Map<String,String> scheduling {get;set;} 
        public Map<String,Object> offer {get;set;} 
        //public Addres address {get;set;} 
        public Hp hp {get;set;} 
        public Map<String,String> billingAddress {get;set;} 
        public String seller {get;set;} 
        public String salesForceID {get;set;} 
    }
    public class Address {
        public String neighborhood {get;set;} 
        public String postalCode {get;set;} 
        public String street {get;set;} 
        public String complements {get;set;} 
        public String number_Z {get;set;} // in json: number    
    }
    public class Transitions {
        
    }
    public class Charge {
        public BankAccount bankAccount {get;set;} 
        public String type_Z {get;set;} // in json: type
        public String invoiceShippingEmail {get;set;} 
        public String invoiceDay {get;set;} 
    }
    public class Hp {
        public Integer id {get;set;} 
    }
    public class BankAccount {
        public Integer bank {get;set;} 
        public String agency {get;set;} 
        public String account {get;set;} 
        public String digit {get;set;} 
    }
    public class Scheduling {
        public String date_Z {get;set;} // in json: type 
        public String alternativeDate {get;set;} 
    }
    public class Rules {
        public Boolean fixedOffset {get;set;} 
        public List<Transitions> transitions {get;set;} 
        public List<Transitions> transitionRules {get;set;} 
    }	
    public class Adhesion {
        public Integer price {get;set;} 
        public Integer period {get;set;} 
    }
    public class DateZ {
        public Offset offset {get;set;} 
        public Integer dayOfYear {get;set;} 
        public String dayOfWeek {get;set;} 
        public String month {get;set;} 
        public Integer dayOfMonth {get;set;} 
        public Integer year {get;set;} 
        public Integer monthValue {get;set;} 
        public Integer nano {get;set;} 
        public Integer hour {get;set;} 
        public Integer minute {get;set;} 
        public Integer second {get;set;} 
    }
    public class Offset {
        public Integer totalSeconds {get;set;} 
        public String id {get;set;} 
        public Rules rules {get;set;} 
    }
    public class Additional {
        public List<Object> internet {get;set;} 
        public List<Object> paytv {get;set;} 
        public List<Object> phone {get;set;} 
        public List<Object> mobile {get;set;} 
        public List<Object> alacarte {get;set;} 
    }
    public class Characteristics {
        public String name {get;set;} 
        public String value {get;set;} 
    }
    public class Offer {
        public String type_Z {get;set;} // in json: type
        public Products products {get;set;} 
    }
    public class Prospect {
        public String name {get;set;} 
        public String birthday {get;set;} 
        public String cpf {get;set;} 
        public String rg {get;set;} 
        public String mobileAreaCode {get;set;} 
        public String mobileNumber {get;set;} 
        public String phoneAreaCode {get;set;} 
        public String phoneNumber {get;set;} 
        public String email {get;set;} 
        public String motherName {get;set;} 
        public Integer gender {get;set;} 
        public Integer maritalStatus {get;set;} 
    }
    public class Internet {
        public String name {get;set;} 
        public Double price {get;set;} 
        public Discount discount {get;set;} 
        public Adhesion adhesion {get;set;} 
        public Additional additional {get;set;} 
        public List<Characteristics> characteristics {get;set;} 
    }
    //Response
    public class Pendencies {
        public Integer id;
        public String title;
    }
    public class ProposalData extends CEC_RestObjects.ResponseGen{
		 public ProposalResponse data;
    }
    public class ProposalResponse{
        public String requestId;
        public Proposal proposal;
        public Contract contract;
    }
    public class Contract {
        public Integer id;
        public Integer customerId;
    }
    public class Proposal {
        public Integer id;
        public String created;
        public String scheduled;
        public List<String> telephones;
        public String status;
        public List<Pendencies> pendencies;
    }	    
}