@isTest
global class SolaFinanceiroContestacaoCtrlTest 
{
	@isTest
	public static void getInvoices() 
    {
		Test.startTest();
            List<SolaFinanceiroContestacaoWrapper> contestationTest = SolaFinanceiroContestacaoCtrl.getInvoices('testGonc');
            System.assert(contestationTest.isEmpty() == false);
		Test.stopTest();
	}
}