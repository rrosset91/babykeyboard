public class EventsHistoryWrapper {
    public class ExtractItensDetail {
        @AuraEnabled
        public string partnerId;
        @AuraEnabled
        public string partnerName;
        @AuraEnabled
        public string contractid;
        @AuraEnabled
        public string affiliatedContractid;
        @AuraEnabled
        public string installmentNumber;
        @AuraEnabled
        public string installmentsCount;
        @AuraEnabled
        public string productId;
        @AuraEnabled
        public string productDescription;
        @AuraEnabled
        public string detTypeExtractItemNote;
        @AuraEnabled
        public string registrationUser;
        @AuraEnabled
        public string note;
        @AuraEnabled
        public string isMinimumValueExtended;
    }

    public class BillDocumentList {
        @AuraEnabled
        public Long id;
        @AuraEnabled
        public Long billNo;
        @AuraEnabled
        public Long billId;
        @AuraEnabled
        public String paymentDueDate;
        @AuraEnabled
        public String billDate;
        @AuraEnabled
        public string description;
        @AuraEnabled
        public string name;
        @AuraEnabled
        public string installments;
        @AuraEnabled
        public Integer extractItemTypeId;
        @AuraEnabled
        public string extractItemTypeDescription;
        @AuraEnabled
        public double amountDue;
        @AuraEnabled
        public string isContestation;
        @AuraEnabled
        public string complement;
        @AuraEnabled
        public string reasonId;
        @AuraEnabled
        public string partnerId;
        @AuraEnabled
        public string reasonDescription;
        @AuraEnabled
        public string formattedAmount;
        @AuraEnabled
        public string partnerName;
        @AuraEnabled
        public Integer invoiceItemGroupDemoId;
        @AuraEnabled
        public string invoiceItemGroupDemoDescription;
        @AuraEnabled
        public List<ExtractItensDetail> extractItensDetails;
        @AuraEnabled
        public Boolean hasElegibility = false;
        @AuraEnabled
        public Decimal amountContested = 0;
        @AuraEnabled
        public List<FutureReleaseJson.ContestationReasonTypes> contestationOptions;
        @AuraEnabled
        public boolean isSfPendingItem;
        @AuraEnabled
        public vlocity_cmt__PaymentAdjustment__c dbAdjustment;
    }

    public class HistoryData {
        @AuraEnabled
        public List<BillDocumentList> billDocumentList;
    }
}