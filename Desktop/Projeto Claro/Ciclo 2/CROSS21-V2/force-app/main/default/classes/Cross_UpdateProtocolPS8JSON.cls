public class Cross_UpdateProtocolPS8JSON {
    /************* Request ***************************/
    public class Request{
        public string transactionId {get; set;} 
        public Data data {get; set;} 
    }
    
    public class Data {
        public string companyId {get; set;}  
        public string operatorCode {get; set;}  
        public string directionCode {get; set;}  
        public string callId {get; set;}  
        public string orderId {get; set;}  
        public Customer customer {get; set;}  
        public Interaction interaction {get; set;}  
        public string productComponentId {get; set;}  
        public string channelRequestId {get; set;}  
        public string situation {get; set;}  
        public string reasonCode1 {get; set;}  
        public string reasonCode2 {get; set;}  
        public string reasonCode3 {get; set;}  
        public string reasonCode4 {get; set;}  
        public string reasonCode5 {get; set;}  
        public string summary {get; set;}  
        public string description {get; set;}  
        public Address address {get; set;}  
        public string contactTypeId {get; set;}  
        public string contactTelephoneNumber {get; set;}  
        public string contactEmail {get; set;}  
        public string contactName {get; set;}  
        public string contactReturnType {get; set;}  
        public string result {get; set;}  
        public List<Attachment> attachments {get; set;}  
        public Survey survey {get; set;}  
        public sfCase sfcase {get; set;}  //nome original = Case case
        public List<RelatedCas> relatedCases {get; set;}  
        public Sms sms {get; set;}  
    }
    
    public class Customer    {
        public string crmId {get; set;} 
        public string accountId {get; set;}  
        public string partyId {get; set;}  
        public string contractNumber {get; set;}  
        public string msisdn {get; set;}  
    }
    
    public class UserAuthenticated    {
        public string userId {get; set;}  
        public string authenticationDatetime {get; set;}  
        public string authenticationReason {get; set;}  
        public string sourceAppId {get; set;}  
        public string sourceOperationId {get; set;}  
    }
    
    public class Interaction {
        public string interactionId {get; set;} 
        public string protocolNumber {get; set;}  
        public string interactionStartDateTime {get; set;} 
        public string context {get; set;}  
        public string mainProtocol {get; set;} 
        public UserAuthenticated userAuthenticated {get; set;}  
        public string sendType {get; set;} 
    }
    
    public class Address {
        public string prefix {get; set;} 
        public string streetAddress {get; set;} 
        public string streetNumber {get; set;} //Nome da variavel original: number
        public string complement {get; set;} 
        public string district {get; set;} 
        public string city {get; set;} 
        public string state {get; set;} 
        public string zipCode {get; set;} 
    }
    
    public class Attachment {
        public string sequence {get; set;} 
        public string name {get; set;} 
        public string url {get; set;} 
    }
    
    public class Answer {
        public string id {get; set;} 
        public string text {get; set;} 
        public string comments {get; set;} 
    }
    
    public class Question {
        public string id {get; set;} 
        public List<Answer> answers {get; set;} 
    }
    
    public class Survey {
        public string id {get; set;} 
        public string effectiveDate {get; set;} 
        public List<Question> questions {get; set;} 
    }
    
    public class sfCase {
        public string caseTypeId {get; set;} 
        public string severity {get; set;} 
        public string slaDueDate {get; set;} 
        public string priorityExecution {get; set;} 
    }
    
    public class RelatedCas {
        public string id {get; set;} 
        public string systemRelatedCaseId {get; set;} 
    }
    
    public class Sms {
        public string content {get; set;} 
        public Boolean priority {get; set;} 
    }
    
    /************* Response ***************************/
    public class Response{
        public string apiVersion {get; set;}  
        public string transactionId {get; set;}  
        public DataResp data {get; set;}
        public Error error { get; set; }
    }
    
    public class DataResp {
        public string protocolNumber {get; set;}  
        public string interactionNumber {get; set;}  
    }
    
    public class Error    {
        public string httpCode { get; set; } 
        public string errorCode { get; set; } 
        public string message { get; set; } 
        public string detailedMessage { get; set; } 
        public Link link { get; set; } 
    }
    
    public class Link    {
        public string rel { get; set; } 
        public string href { get; set; } 
    }
}