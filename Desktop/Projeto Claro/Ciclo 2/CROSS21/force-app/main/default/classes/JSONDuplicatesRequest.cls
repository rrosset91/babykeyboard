/*
* @author: Roger Rosset
* @company: IBM - Bluewolf
* @description: Classe com objetivo de gerar o JSON para requisição POST do serviço "Duplicates"
*/
public class JSONDuplicatesRequest {
	public String apiVersion;
	public String transactionId;
	public Data data;
    public Error error;	
    
	public class Data {
        public String operatorCode ;
        public String contractNumber ;
        public String userName ;
		public String billId ;
		public String name ;
        public String phoneNumber ;
        public String email ;
        public String sendMethod ;
		public String billExtend ;
		public integer reasonId ;
        public String descriptionReason ;
    }
    
    public class SendMethods{
        public Integer sendMethodId;
        public String sendMethodDescription;
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