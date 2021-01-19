public class InvoiceRest_object {
    
    public class invoice  {
        @AuraEnabled public String referenceMonth;
        @AuraEnabled public String referenceYear;
        @AuraEnabled public String startDate;
        @AuraEnabled public String endDate;
        @AuraEnabled public String issuanceDate;
        @AuraEnabled public String documentNumber;
        @AuraEnabled public String noteFiscalNumber;
        @AuraEnabled public String dueDate;
        @AuraEnabled public String indicatorInvoiceNotPaid;
        @AuraEnabled public String indicatorSuspensionCauses;
        @AuraEnabled public Decimal invoiceAmount;
        @AuraEnabled public Decimal amountPaymentMade;
        @AuraEnabled public Decimal amountAdjustmentMade;
        @AuraEnabled public Decimal amountPreviousBalance;
        @AuraEnabled public Decimal amountAfterBalance;
        @AuraEnabled public Decimal amountPrincipal;
        @AuraEnabled public Decimal amountPrincipalPaymentMade;
        @AuraEnabled public String invoiceId;
        @AuraEnabled public String statusInvoiceId;
        @AuraEnabled public String statusInvoiceDescription;
        @AuraEnabled public String paymentForm;
        @AuraEnabled public String dueDate_aux;
        @AuraEnabled public String invoiceAmount_aux;
    }
    
    public String apiVersion;
    public String transactionId;
    public Data data;
    
    
    public class Data {
        public List<Invoice> invoices;
        public InvoicePDF invoicePDF;
    }
    
    public class InvoicePDF {
        public String invoiceURL;
    }
    
}