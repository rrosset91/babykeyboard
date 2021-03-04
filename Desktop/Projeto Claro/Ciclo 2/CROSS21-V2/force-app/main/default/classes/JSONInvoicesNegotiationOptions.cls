/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 21-01-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-01-2021   Diego Almeida   Initial Version
**/
public with sharing class JSONInvoicesNegotiationOptions extends ClaroAPIBaseResponse{

    public JSONInvoicesNegotiationOptions() {
	}

	public JSONInvoicesNegotiationOptions(String specificClassType, Map<String, String> initMap, Boolean errorControl) {
		super(specificClassType, initMap, errorControl);
    }

    public Integer termRenegotiationId;
    public String cityId;
    public Integer contractId;
    public Integer functionalityRuleId;
    public String checkUseItemRenegotiation;
    public Integer enableFirstInstallmentSeparateDebts;
    public String firstInstallmentValue;
    public String firstInstallmentMinimumValue;
    public String checkChargeNegativity;
    public String discountType;
    public String maximumDiscountPerProfile;
    public String calcTotal;
    public String totalDebt;
    public String totalTicket;
    public String totalInterest;
    public String total;
    public List<InvoicesItensUnification> invoicesItensUnification;
    public List<Bill> bills;
    public List<Statement> statements;
    public List<InstallmentOption> installmentOptions;
    public List<NegotiationReason> negotiationReason;
    public List<ProfileList> profileList;
    public List<PaymentList> paymentList;
    public List<AssociatedBank> associatedBanks;
    public List<ContractSubscriber> contractSubscriber;
    public List<SendMethod> sendMethod;


    public class InvoicesItensUnification{
        public String debtValue;
        public String ticketValue;
        public String interestValue;
        public String totalDebt;
        public String floatingPointDifValue;
        public String proportionalDiscountValue;
        public Integer partnerId;
        public String partnerName;
        public Integer serviceTypeId;
        public String serviceTypeDescription;
    }

    public class Bill{
        public Integer bill;
    }

    public class Statement{
        public Integer statement;
    }

    public class InstallmentOption{
        public Integer installmentNumber;// number;
        public Integer amount;
        public Integer amountInter;
        public String firstValue;
        public String intermediaryValue;
        public String lastValue;
        public String dueDate;
        public String firstInterest;
        public String firstTicket;
        public String intermediaryInterest;
        public String intermediaryTicket;
        public String lastInterest;
        public String lastTicket;
    }

    public class NegotiationReason{
        public String reasonId;
        public String description;
    }

    public class ProfileList{
        public Integer exemptProfileCode;
        public String exemptionStatus;
        public Integer profileCode;
    }

    public class PaymentList{
        public Integer methodCode;
        public String methodDescription;
    }

    public class AssociatedBank{
        public Integer bankCode;
        public String bankName;
    }

    public class ContractSubscriber{
        public Integer subscriberId;
        public String name;
        public String mail;
        public String cellPhoneSubscriber;
    }

    public class SendMethod{
        public String typeShippingCode;
        public String typeShippingDescription;
    }



}