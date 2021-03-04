public class Cross_ProtocolPS8Request {
    public DataRequest data { get; set; }
    
    public class DataRequest {
        public Customer customer { get; set; }        
        public String companyId { get; set; }
        public String channelRequestId { get; set; }
        public String situation { get; set; }
        public String reasonCode1 { get; set; }
        public String reasonCode2 { get; set; }
        public String reasonCode3 { get; set; }
        public String reasonCode4 { get; set; }
        public String reasonCode5 { get; set; }
        public String summary { get; set; }
        public String description { get; set; }
        public String contactTypeId { get; set; }
        public String contactName { get; set; }        
        public String contactEmail { get; set; }
        public String result { get; set; }
    }
    
    public class Customer {
        public string msisdn { get; set; }
    }
}