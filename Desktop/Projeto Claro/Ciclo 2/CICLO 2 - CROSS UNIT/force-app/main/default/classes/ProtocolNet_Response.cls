public class ProtocolNet_Response {

	public String apiVersion 			{ get; set; }
	public String transactionId			{ get; set; }
	public Data data 					{ get; set; }
    public Error error 					{ get; set; }
    public Interaction interactions		{ get; set; }
    
    
    public class Interaction{
        public String protocol 	{ get; set; }
		public String interactionNumber	{ get; set; }

    }
    
	public class Data{
     	
        public Interaction interaction 	{ get; set; }
	}

	public class Error{
    	public String httpCode				{ get; set; }
        public String errorCode				{ get; set; }
    	public String message				{ get; set; }
    	public String detailedMessage 		{ get; set; }		
		public Link link 					{ get; set; }
	}
	
	public class Link{
		public String rel 					{ get; set; }
        public String href 					{ get; set; }
	}
}