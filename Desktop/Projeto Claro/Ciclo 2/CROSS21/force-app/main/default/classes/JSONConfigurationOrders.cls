public with sharing class JSONConfigurationOrders {
    public String apiVersion;
	public String transactionId;
	public Data data;
	
	public Error error;
    public class Link{
        public String rel;
        public String href;
    }
    
    public class Error{
        public String httpCode;
        public String errorCode;
        public String message;
        public String detailedMessage;
        public Link link;
    }

	public class ConfigurationOrders {
		public String cityId;
		public String operatorCode;
		public String contractNumber;
		public Integer requestID;
		public Integer configurationOrderID;
		public Integer configurationorderTypeID;
		public String configurationorderTypeDescription;
		public Integer productID;
		public String productDescription;
		public String status;
		public String statusDescription;
		public String closeUser;
		public String terminationDate;
		public Integer pointID;
	}

	public class Data {
		public List<ConfigurationOrders> configurationorders;
	}
}