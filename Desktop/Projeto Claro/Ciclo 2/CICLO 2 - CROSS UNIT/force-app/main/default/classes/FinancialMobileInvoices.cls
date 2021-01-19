public without sharing class FinancialMobileInvoices {
	@AuraEnabled
	public static List<MobileInvoiceWrapper> getInvoices(String contractId) {
		List<MobileInvoiceWrapper> lst = new List<MobileInvoiceWrapper>();

		MobileinvoiceWrapper wrp = new MobileInvoiceWrapper();
		wrp.type = 'Boleto';
		wrp.product = 'Celular';
		wrp.status = 'Aberto';
		wrp.dueDate = '12/08/2020';
		wrp.payDate = '12/08/2020';
		wrp.contested = '';
		wrp.value = 'R$ 250,00';
		wrp.rawValue = 250.00;
		wrp.billId = '19299234';
		lst.add(wrp);

		MobileinvoiceWrapper wrp2 = new MobileInvoiceWrapper();
		wrp2.type = 'Fatura';
		wrp2.product = 'Celular';
		wrp2.status = 'Cancelado';
		wrp2.dueDate = '12/07/2020';
		wrp2.payDate = '12/07/2020';
		wrp2.contested = 'Contestado';
		wrp2.value = 'R$ 210,60';
		wrp2.rawValue = 210.60;
		wrp2.billId = '32230453';
		lst.add(wrp2);

		MobileinvoiceWrapper wrp3 = new MobileInvoiceWrapper();
		wrp3.type = 'Fatura';
		wrp3.product = 'Celular';
		wrp3.status = 'Pago';
		wrp3.dueDate = '12/06/2020';
		wrp3.payDate = '12/06/2020';
		wrp3.contested = '';
		wrp3.value = 'R$ 203,10';
		wrp3.rawValue = 203.10;
		wrp3.billId = '23939395';
		lst.add(wrp3);

		MobileinvoiceWrapper wrp4 = new MobileInvoiceWrapper();
		wrp4.type = 'Fatura';
		wrp4.product = 'Celular';
		wrp4.status = 'Pago';
		wrp4.dueDate = '12/05/2020';
		wrp4.payDate = '12/05/2020';
		wrp4.contested = '';
		wrp4.value = 'R$ 194,10';
		wrp4.rawValue = 194.10;
		wrp4.billId = '2342494';
		lst.add(wrp4);

		return lst;
	}
}