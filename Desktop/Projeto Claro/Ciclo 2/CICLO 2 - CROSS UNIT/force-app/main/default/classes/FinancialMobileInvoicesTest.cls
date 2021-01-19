@isTest
global class FinancialMobileInvoicesTest {
	@isTest
	public static void getInvoices() {
		Test.startTest();
		List<MobileInvoiceWrapper> inv = FinancialMobileInvoices.getInvoices('2342424');
		System.assert(inv.isEmpty() == false);
		Test.stopTest();
	}
}