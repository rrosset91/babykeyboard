@isTest
public class SOLAR_PME_ContratosTest {

    @testSetup 
    public static void setup() {
		CEC_PME_OrderTestMethods.generateAllData();
    }
    
    @isTest 
    static void main() {
        Test.startTest();
        Order ord = [SELECT Id FROM Order];
        SOLAR_PME_Contratos contrato = new SOLAR_PME_Contratos();
        contrato.criarContratos(ord.Id);
        Test.stopTest();
    }
}