@isTest
public with sharing class FinancialDataTableUtilsTest {
    @TestSetup
    static void makeData(){
    }

    @isTest
    public static void FinancialDataTableUtilsTest() {
        test.startTest();
        String buttonName = 'MockButton';
        String buttonType = 'utility:preview';
        FinancialDataTableUtils.Columns result = FinancialDataTableUtils.generateButton( buttonName , buttonType );
        test.stopTest();
        system.assert(result.typeAttributes.name == buttonName);
    }
}