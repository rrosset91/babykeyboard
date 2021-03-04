/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 22-01-2021
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   19-01-2021   Joao Neves   Initial Version
 **/
public class FinancialNegotiationEfetivationJSON {
	public Data data;

	public class Data {
		public String operatorCode;
		public Long contractNumber;
		public String userName;
		public String checkUseItemRenegotiation;
		public Decimal total;
		public Decimal discountValue;
		public String discountType;
		public Long amountInstallments;
		public Boolean exemptInterestTicket;
		public Decimal totalTicket;
		public Decimal totalInterest;
		public Long negociationReasonId;
		public Decimal firstInstallmentValue;
		public Decimal intermediaryInstallmentValue = 0;
		public Decimal lastInstallmentValue = 0;
		public Decimal firstInstallmentInterest;
		public Decimal firstInstallmentTicket;
		public Decimal intermediaryInstallmenInterest = 0;
		public Decimal intermediaryInstallmenTicket = 0;
		public Decimal lastInstallmentInterest = 0;
		public Decimal lastInstallmentTicket = 0;
		//public Long checkChargeNegativity;
		//public Boolean checkChargeApart;
		//public String paymentMethodCode;
		//public String typeShippingCode;
		//public Long bankCode;
		//public Long agencyNumber;
		//public Long accountNumber;
		//public Long typeNumber;
		//public Long cardOperatorCode;
		//public String nrip;
		public String hashAuthority;
		public List<String> bills;
		public List<String> statements;
	}
}