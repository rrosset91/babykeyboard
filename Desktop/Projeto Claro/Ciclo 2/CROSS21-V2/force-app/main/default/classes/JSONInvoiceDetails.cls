/**
 * @author: Bruno Felix
 * @company: IBM - Bluewolf
 * @description: Classe com objetivo de converter o JSON retornado do serviço "InvoicesDetails" (Detalhes da fatura)
 */

public class JSONInvoiceDetails {
	public class Tax {
		public String taxType;
		public String value;
		public String aliquot;
	}
	public class InvoiceItem {
		public String name;
		public String description;
		public Double amount;
		public List<Tax> taxes;
	}
	public class Message {
		public String text;
	}
	public class ItemGroup {
		public Integer chargeId;
		public Integer groupId;
		public String groupDescription;
		public Integer groupIdParent;
		public String parentGroupDescription;
		public String amount;
		public String productDescription;
	}
	public class ExtractItem {
		public Long idExtractItem;
		public Long idExtractItemType;
		public String itemDescription;
		public Integer installmentNumber;
		public Integer totalInstallments;
		public String dueDate;
		public String entryDate;
		public double sourceValue;
		public String addressComplement;
		public Integer pointId;
		public Integer productId;
		public String productDescription;
		public Integer proRataUnificationGroup;
		public String proRataStartDate;
		public Integer order;
		public Integer itemGrouper;
		public double amount; //nao esta presente no swagger
	}
	public class DebtGroup {
		public Integer groupId;
		public String groupDescription;
		public double amount;
		public Integer order;
		public List<ExtractItem> extractItems;
	}
	public class Detail {
		public String idDetExtractItem;
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
		public String callValue;
		public Double callDetailValue;
		public String originTerminal;
		public String targetTerminal;
		public String taxType;
		public String entryDate;
	}
	public class PartnerExtract {
		public Long idExtractItem;
		public Integer installmentNumber;
		public Integer totalInstallments;
		public String dueDate;
		public String entryDate;
		public Integer partnerItemId;
		public String partnerItemDescription;
		public Integer idExtractItemType;
		public String itemDescription;
		public Double amount;
		public String isContested;
		public String addressComplement;
		public List<Detail> details;
	}
	public class Detail2 {
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
		public String callValue;
		public Double callDetailValue;
		public String originTerminal;
		public String targetTerminal;
		public String taxType;
		public String entryDate;
	}
	public class PartnerExtract2 {
		public Long idExtractItem;
		public Integer installmentNumber;
		public Integer totalInstallments;
		public String dueDate;
		public String entryDate;
		public Integer partnerItemId;
		public String partnerItemDescription;
		public Integer idExtractItemType;
		public String itemDescription;
		public Double amount;
		public String isContested;
		public String addressComplement;
		public List<Detail2> details;
	}
	public class PartnerPhone {
		public String originTerminal;
		public String amount;
		public List<PartnerExtract2> partnerExtracts;
	}
	public class ServiceGroup {
		public Integer groupId;
		public String groupDescription;
		public Integer partnerServiceId;
		public String partnerServiceDescription;
		public Double partnerServiceAmount;
		public List<PartnerExtract> partnerExtracts;
		public List<PartnerPhone> partnerPhones;
	}
	public class PartnerDebt {
		public Long partnerId;
		public String partnerName;
		public Integer chargeId;
		public String generationDate;
		public String originalDueDate;
		public String dueDate;
		public Double amountCharge;
		public String amountPaid;
		public Double balance;
		public String isExternalCollecting;
		public Integer statusId;
		public String status;
		public List<DebtGroup> debtGroup;
		public List<ServiceGroup> serviceGroup;
	}
	public class Data {
		public Integer invoiceId;
		public String dueDate;
		public String partners;
		public String paymentMethod;
		public String status;
		public String paymentDate;
		public String executeDate;
		public String cancelDate;
		public Integer dueDay;
		public Integer bestDayPaymentParameter;
		public double billCode;
		public String formatedBillCode;
		public String amount;
		public String totalTaxMessage;
		public Integer sourceInvoiceId;
		public List<InvoiceItem> invoiceItems;
		public List<Message> messages;
		public List<ItemGroup> itemGroups;
		public List<PartnerDebt> partnerDebts;
	}

	public String apiVersion;
	public String transactionId;
	public Data data;
	public Error error;

	public class Link {
		public string rel;
		public string href;
	}

	public class Error {
		public string httpCode;
		public string errorCode;
		public string message;
		public string detailedMessage;
		public Link link;
	}

	public static JSONInvoiceDetails parse(String json) {
		return (JSONInvoiceDetails) System.JSON.deserialize(json, JSONInvoiceDetails.class);
	}
}