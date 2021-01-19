public class SolarPFTokenServiceWrapper {
    
    
    public class RequestData {
        public String user { get; set; }
        public String name { get; set; }
        public String sourceSystem { get; set; }
        public String destinySystem { get; set; }
        public String applicationContext { get; set; }
        public String IpAddress { get; set; }
        public String indicatorSession { get; set; }
        public List<Properties> properties { get; set; }
    }   
    public class Request {
        public RequestData data { get; set; }
    }

    public class Properties {
        public String name { get; set; }
        public String value { get; set; }
    }

    public static SolarPFTokenServiceWrapper.RequestData parse(String json) {
        return (SolarPFTokenServiceWrapper.RequestData) System.JSON.deserialize(json, SolarPFTokenServiceWrapper.RequestData.class);
    }

    public class Response{
        public String apiVersion  { get; set; }
        public String transactionId { get; set; }
        public ResponseData data { get; set; }
        public ResponseError error { get; set; }
    }
								
	public class ResponseData{
		public Token token { get; set; }
    }
    

	public class Token{
		public String tokenId;
    }

    public class ResponseError{
        public String errorCode { get; set; }   
    }
    
  
}