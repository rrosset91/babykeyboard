public class CEC_PME_EnvioPedido_Response {
    public String apiVersion 						{ get; set; }
  	public String transactionId						{ get; set; }
    public Data data 								{ get; set;}
    
    public class Data{
        public SalesOrder salesOrder	 			{ get; set; }
    }
    
    public class SalesOrder{
        public String orderId 						{ get; set; }
    }
    
    public class Error{
        public string httpCode 						{ get; set; }
        public string errorCode 					{ get; set; }
     	public string message 						{ get; set; }
     	public string detailedMessage 				{ get; set; }
        public Link link 							{ get; set; }
    }

    public class Link{
        public String rel 							{ get; set; }
        public String href 							{ get; set; } 
    }    	
}