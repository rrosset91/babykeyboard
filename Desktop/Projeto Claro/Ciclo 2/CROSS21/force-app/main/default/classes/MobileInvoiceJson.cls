/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 10-12-2020
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   10-12-2020   Joao Neves   Initial Version
 **/
public class MobileInvoiceJson {
	public String apiVersion;
	public String transactionId;
	public Invoices data;

	public class Invoices {
		public List<Invoice> invoices;
	}

	public class Invoice {
		public String referenceMonth;
		public String referenceYear;
		public String startDate;
		public String endDate;
		public String issuanceDate;
		public String documentNumber;
		public String noteFiscalNumber;
		public String dueDate;
		public String indicatorInvoiceNotPaid;
		public String indicatorSuspensionCauses;
		public String invoiceAmount;
		public String amountPaymentMade;
		public String amountAdjustmentMade;
		public String amountPreviousBalance;
		public String amountAfterBalance;
		public String amountPrincipal;
		public String amountPrincipalPaymentMade;

		public TypedInvoice getTypedInvoice() {
			TypedInvoice ti = new TypedInvoice();
			ti.referenceMonth = Integer.valueOf(this.referenceMonth);
			ti.referenceYear = Integer.valueOf(this.referenceYear);
			ti.startDate = new CustomDate(this.startDate);
			ti.endDate = new CustomDate(this.endDate);
			ti.issuanceDate = new CustomDate(this.issuanceDate);
			ti.documentNumber = Long.valueOf(this.documentNumber);
			ti.noteFiscalNumber = Long.valueOf(this.noteFiscalNumber);
			ti.dueDate = new CustomDate(this.dueDate);
			ti.indicatorInvoiceNotPaid = Boolean.valueOf(this.indicatorInvoiceNotPaid);
			ti.indicatorSuspensionCauses = Boolean.valueOf(this.indicatorSuspensionCauses);
			ti.invoiceAmount = Decimal.valueOf(this.invoiceAmount);
			ti.amountPaymentMade = Decimal.valueOf(this.amountPaymentMade);
			ti.amountAdjustmentMade = Decimal.valueOf(this.amountAdjustmentMade);
			ti.amountPreviousBalance = Decimal.valueOf(this.amountPreviousBalance);
			ti.amountAfterBalance = Decimal.valueOf(this.amountAfterBalance);
			ti.amountPrincipal = Decimal.valueOf(this.amountPrincipal);
			ti.amountPrincipalPaymentMade = Decimal.valueOf(this.amountPrincipalPaymentMade);
			return ti;
		}
	}

	public class TypedInvoice {
		public Integer referenceMonth;
		public Integer referenceYear;
		public CustomDate startDate;
		public CustomDate endDate;
		public CustomDate issuanceDate;
		public Long documentNumber;
		public Long noteFiscalNumber;
		public CustomDate dueDate;
		public Boolean indicatorInvoiceNotPaid;
		public Boolean indicatorSuspensionCauses;
		public Decimal invoiceAmount;
		public Decimal amountPaymentMade;
		public Decimal amountAdjustmentMade;
		public Decimal amountPreviousBalance;
		public Decimal amountAfterBalance;
		public Decimal amountPrincipal;
		public Decimal amountPrincipalPaymentMade;
	}

	public class CustomDate {
		public String rawDate;
		public Date parsedDate;

		public CustomDate() {
		}

		public CustomDate(String stgDate) {
			this.rawDate = stgDate;
			this.parsedDate = getDate(stgDate);
		}

		private Date getDate(String stgDate) {
			List<String> splitDate = stgDate.split('-');
			return Date.newInstance(Integer.valueOf(splitDate[0]), Integer.valueOf(splitDate[1]), Integer.valueOf(splitDate[2]));
		}
	}
}