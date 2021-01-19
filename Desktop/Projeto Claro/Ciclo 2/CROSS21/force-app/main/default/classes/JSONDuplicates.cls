/*
* @author: Roger Rosset
* @company: IBM - Bluewolf
* @description: Classe com objetivo de converter o JSON retornado do serviço "Duplicates"
*/
public class JSONDuplicates {
	public String apiVersion;
	public String transactionId;
	public Data data;
    public Error error;	
    
	public class Data {
        public List<SendMethods> listSendMethod;
        public List<Reasons> listReason;
        public String userHasAccess;
        public String billAllowsSending;
        public String billExtend;
        public String contractNumber;
        public String name;
        public String email;
        public String phoneNumber;
        public String note;
    }
    
    public class SendMethods{
        public String sendMethodId;
        public String sendMethodDescription;
        public String isExtended;
    }

    public class Reasons{
        public Integer reasonId;
        public String descriptionReason;
        public String isExtended;
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