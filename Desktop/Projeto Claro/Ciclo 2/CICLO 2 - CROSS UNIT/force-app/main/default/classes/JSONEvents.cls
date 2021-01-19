/**
* @author: Caio Cesar Leite de Oliveira
* @company: IBM - Bluewolf
* @description: Classe com objetivo de converter o JSON retornado do serviço "Events"
*/
public class JSONEvents {
	public String apiVersion;
	public String transactionId;
	public Data data;
	public Error error;	

	public class Event {
		public String cityId;
		public String operatorCode;
		public String contractNumber;
		public String requestID;
		public Integer requestTypeID;
		public String requestTypeDescription;
		public String status;
		public String statusDescription;
		public String closeDate;
		public String closeUser;
		public String openUser;
		public String obs;
		public String cancelReasonID;
		public String cancelReasonDescription;
	}

	public class Data {
		public List<Event> requests;
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

	public class HistoryData {
		public List<BillDocument> billDocumentList;
	}

	public class BillDocument    {
        public Integer id; 
        public Integer billNo; 
        public Integer billId; 
        public DateTime paymentDueDate; 
        public DateTime billDate; 
        public string description; 
        public string name; 
        public object installments; 
        public Integer extractItemTypeId; 
        public string extractItemTypeDescription; 
        public double amountDue; 
        public string isContestation; 
        public object complement; 
        public object reasonId; 
        public object reasonDescription; 
        public Integer invoiceItemGroupDemoId; 
        public string invoiceItemGroupDemoDescription; 
        public List<ExtractItensDetail> extractItensDetails; 

    }

    public class ExtractItensDetail    {
        public string partnerId; 
        public string partnerName; 
        public string contractid; 
        public object affiliatedContractid; 
        public object installmentNumber; 
        public object installmentsCount; 
        public object productId; 
        public object productDescription; 
        public string detTypeExtractItemNote; 
        public string registrationUser; 
        public object note; 
        public string isMinimumValueExtended; 

    }
}