/**
 * @description       : 
 * @author            : Joao Neves
 * @group             : 
 * @last modified on  : 19-01-2021
 * @last modified by  : Joao Neves
 * Modifications Log 
 * Ver   Date         Author       Modification
 * 1.0   19-01-2021   Joao Neves   Initial Version
**/
public class FinancialNegotiationEfetivationJSON {
    public String apiVersion;
	public String transactionId;
	public Data data;

	public class Data {
		public String operatorcode;
		public Long contractnumber;
		public String username;
		public String checkUseitemrenegotiation;
		public Decimal total;
		public Decimal discountvalue;
		public String discounttype;
		public Long amountinstallments;
		public Boolean exemptInterestticket;
		public String totalticket;
		public Decimal totalinterest;
		public Long negociationreasonid;
		public Decimal firstInstallmentvalue;
		public Decimal intermediaryinstallmentvalue;
		public Decimal lastinstallmentvalue;
		public Decimal firstinstallmentinterest;
		public Decimal firstInstallmentTicket;
		public Decimal intermediaryInstallmenInterest;
		public Decimal intermediaryInstallmenTicket;
		public Decimal lastInstallmentInterest;
		public Decimal lastInstallmentTicket;
		public Long checkChargeNegativity;
		public Boolean checkChargeApart;
		public String paymentMethodCode;
		public String typeShippingCode;
		public Long bankcode;
		public Long agencynumber;
		public Long accountnumber;
		public Long typenumber;
		public Long cardOperatorcode;
		public String nrip;
		public List<Long> bills;
		public List<Long> statements;
	}
}