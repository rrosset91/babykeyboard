public class ProtocolNet_Request {

	public String transactionId 		{ get; set; }
	public Data data					{ get; set; }

	public class Data{
		public String contractNumber 	{ get; set; }
    	public String operatorCode 		{ get; set; }
    	public String protocolNumber 	{ get; set; }
    	public String reasonId 			{ get; set; }	
    	
	}
}