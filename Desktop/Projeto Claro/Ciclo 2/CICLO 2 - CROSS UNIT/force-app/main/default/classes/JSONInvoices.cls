/**
* @author: Rafael de Campos
* @company: IBM - Bluewolf
* @description: Classe com objetivo de converter o JSON retornado do serviço "Invoices" (Faturas em aberto)
*/
public class JSONInvoices {
	public String apiVersion;
	public String transactionId;
	public Data data;
	public Error error;	

	public class Invoices {
		public String invoiceId;
		public String statusInvoiceId;
		public String statusInvoiceDescription;
		public String dueDate;
		public Double invoiceAmount;
		public String paymentForm;
		//public String referenceMonth;
		//public String referenceYear;
		//public String startDate;
		//public String endDate;
		//public Integer amountToPay;
		//public Integer amountPaid;
		//public String invoiceDescription;
	}

	public class Data {
		public List<Invoices> invoices;
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