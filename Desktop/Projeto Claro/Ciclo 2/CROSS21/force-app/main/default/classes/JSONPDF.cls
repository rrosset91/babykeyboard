public with sharing class JSONPDF {

    public String apiVersion;
    public String transactionId;
    public Data data;

    public class Data{
        public InvoicePDF invoicePDF;
        public ContentRetrieve retrieves;//retrieve
    }

    public class InvoicePDF{
        public String invoiceURL;
    }

    public class ContentRetrieve{
        public String content;
        public String name;
        public String notificationId;
        public String status;
        public String message;
    }

}