public class JSONPostDuplicateRequest {
public String apiVersion;
	public String transactionId;
	public Data data;
    public Error error;	
    
	public class Data {
 	public String billId;
 	public String billNewId;
 	public String dueDate;
 	public String message;
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