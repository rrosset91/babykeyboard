public class JSONHierarchyLimit {
    public Data data;
	public Error error;	
    
    public class Data {
        public String apiVersion;
        public String transactionId;
        public String returnCode;
        public String returnMessage;
        public boolean authorized;
        public String hashAuthority;
    }
    
	public class Link {
		public String rel;
		public String href;
	}
    
    public class Error {
		public String httpCode;
		public String errorCode;
		public String message;
		public String detailedMessage;
		public Link link;
	}
}