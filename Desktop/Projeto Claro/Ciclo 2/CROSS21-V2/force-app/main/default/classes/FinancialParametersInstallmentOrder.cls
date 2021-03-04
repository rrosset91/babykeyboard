/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 11-02-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-02-2021   Diego Almeida   Initial Version
**/
public class FinancialParametersInstallmentOrder implements Comparable {

    public Parameters__c paramy;

    // Constructor
    public FinancialParametersInstallmentOrder(Parameters__c pm) {
        paramy = pm;
    }

    // Compare paramortunities based on the paramortunity amount.
    public Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        FinancialParametersInstallmentOrder compareToparamy = (FinancialParametersInstallmentOrder)compareTo;

        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (Integer.valueof(paramy.Installments__c) > Integer.valueof(compareToparamy.paramy.Installments__c)) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (Integer.valueof(paramy.Installments__c) < Integer.valueof(compareToparamy.paramy.Installments__c)) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        //  else if ((paramy.Amount == null) && (compareToOppy.paramy.Amount != null)){
        //     // nulls-first implementation
        //     returnValue = -1;
        // } else if ((paramy.Amount != null) && (compareToOppy.paramy.Amount == null)){
        //     // nulls-first implementation
        //     returnValue = 1;
        // }
        return returnValue;
    }
}