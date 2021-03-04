/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 27-01-2021
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   19-01-2021   Joao Neves   Initial Version
 **/
public class FinancialNegotiationEfetivationWrapper {
	public ApiData apiData;
	public List<String> selectedBills;
	public List<String> statementsIdsString;
	public Decimal negotiatedValue;
	public FinancialNegotiationEfetivationBase base;
	public String alcadaAprovada;
	public SelectedInstallment selectedInstallment;

	public class ApiData {
		public String totalDebt;
		public String totalTicket;
		public String totalInterest;
		public String total;
		public Integer amount;
		public Boolean exemptInterestTicket;
		public Decimal discountValue;
		public Decimal firstInstallmentValue;
		public Decimal firstInstallmentInterest;
		public Decimal firstInstallmentTicket;
		public Decimal intermediaryInstallmentValue;
		public Decimal intermediaryInstallmenInterest;
		public Decimal intermediaryInstallmenTicket;
		public Decimal lastInstallmentValue;
		public Decimal lastInstallmentInterest;
		public Decimal lastInstallmentTicket;
	}

	public class FinancialNegotiationEfetivationBase {
		public String caseId;
		public String contractAccountSalesforceId;
		public String contractId;
		public String operatorId;
		public String comment;
	}

	public class SelectedInstallment {
		public String descontoParcelamento;
		public Decimal quantidadeParcelamento;
	}
}