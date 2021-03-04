public with sharing class JSONCustomersContractsBillsDebts {

    public class Detail{

        public Long idDetExtractItem;

        public Integer sequenceNumber;
        public String startDate;
        public String endDate;
        public String startTime;
        public String endTime;
        public String origin;
        public String destination;
        public String destinationCountry;
        public String callDuration;
        public String callDurationUnit;
        public Double callValue;
        public Double callDetailValue;
        public String originTerminal;

        public Long targetTerminal;

        public String taxType;
        public String entryDate;
    }

    public class PartnerExtract{
        public Integer idExtractItem;
        public Integer installmentNumber;
        public Integer totalInstallments;
        public String dueDate;
        public String entryDate;
        public Integer partnerItemId;
        public String partnerItemDescription;
        public Integer idExtractItemType;
        public String itemDescription;
        public String amount;

        // public Boolean isContested;

        public String addressComplement;
        public List<Detail> details;
    }

    public class Detail2{

        public Long idDetExtractItem;

        public Integer sequenceNumber;
        public String startDate;
        public String endDate;
        public String startTime;
        public String endTime;
        public String origin;
        public String destination;
        public String destinationCountry;
        public String callDuration;
        public String callDurationUnit;
        public Double callValue;
        public Double callDetailValue;
        public String originTerminal;

        public Long targetTerminal;

        public String taxType;
        public String entryDate;
    }

    public class PartnerExtract2{
        public Integer idExtractItem;
        public Integer installmentNumber;
        public Integer totalInstallments;
        public String dueDate;
        public String entryDate;
        public Integer partnerItemId;
        public String partnerItemDescription;
        public Integer idExtractItemType;
        public String itemDescription;
        public String amount;

        // public Boolean isContested;

        public String addressComplement;
        public List<Detail2> details;
    }

    public class PartnerPhone{
        public String originTerminal;
        public String amount;
        public List<PartnerExtract2> partnerExtracts;
    }

    public class ServiceGroup{
        public Integer groupId;
        public String groupDescription;
        public Integer partnerServiceId;
        public String partnerServiceDescription;
        public String partnerServiceAmount;
        public List<PartnerExtract> partnerExtracts;
        public List<PartnerPhone> partnerPhones;
    }

    public class Proportionality{
        public String entryDate;
        public String finishDate;
        public Integer quantity;
        public String amount;
        public String amountDiscount;
        public String message;
    }

    public class ExtractItem{
        public Integer idExtractItem;
        public Integer idExtractItemType;
        public String itemDescription;
        public Integer installmentNumber;
        public Integer totalInstallments;
        public String dueDate;
        public String entryDate;

        public Double sourceValue;

        public String addressComplement;
        public Integer poIntegerId;
        public Integer productId;
        public String productDescription;
        public Integer order;
        public Integer itemGrouper;
        public List<Proportionality> proportionality;
    }

    public class DebtGroup{
        public Integer groupId;
        public String groupDescription;
        public Double amount;
        public Integer order;
        public List<ExtractItem> extractItems;
    }

    public class PartnerDebt{
        public Integer partnerId;
        public String partnerName;
        public Integer chargeId;
        public String generationDate;
        public String originalDueDate;
        public String dueDate;
        public String amountCharge;
        public String amountPaid;
        public String balance;
        public Boolean isExternalCollecting;
        public Integer statusId;
        public String status;
        public String chargeModality;
        public List<ServiceGroup> serviceGroup;
        public List<DebtGroup> debtGroup;
    }

    public class Data{
        public List<PartnerDebt> partnerDebts;
    }

    public String apiVersion;
    public String transactionId;
    public Data data;

    public Error error;
    public class Link{
        public String rel;
        public String href;
    }
    
    public class Error{
        public String httpCode;
        public String errorCode;
        public String message;
        public String detailedMessage;
        public Link link;
    }
}