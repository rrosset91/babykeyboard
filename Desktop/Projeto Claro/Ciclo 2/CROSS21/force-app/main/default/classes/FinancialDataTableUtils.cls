/**
 * @description       : Classe Wrapper para gerar dados para datatables (Colunas e campos de modal)
 * @author            : Roger Rosset
 * @group             : Financeiro

 * @last modified on  : 28-10-2020

 * @last modified by  : Roger Rosset
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   23-10-2020   Roger Rosset   Initial Version
**/
public with sharing class FinancialDataTableUtils {

    
    @AuraEnabled
    public static FinancialDataTableUtils.Columns generateButton(String name, String iconType){
        FinancialDataTableUtils.Columns button = new FinancialDataTableUtils.Columns();
        button.type = 'button';
        button.label = '';
        button.initialWidth = 73;
        FinancialDataTableUtils.RowActionAttributes buttonProps = new FinancialDataTableUtils.RowActionAttributes();
        buttonProps.disabled = false;
        buttonProps.label = '';
        buttonProps.iconPosition = 'center';
        buttonProps.name = name;
        buttonProps.iconName = iconType;

        button.typeAttributes = buttonProps;
        return button;
    }


	public class Columns{
		@AuraEnabled public String label;
		@AuraEnabled public String fieldName;
		@AuraEnabled public String type;
        @AuraEnabled public Boolean sortable;
        @AuraEnabled public RowActionAttributes typeAttributes;

        @AuraEnabled public Integer initialWidth;
	}
	public class RowActionAttributes{ 
        @AuraEnabled public String alternativeText;
        @AuraEnabled public String iconClass;
        @AuraEnabled public String variant;
        @AuraEnabled public String label;
        @AuraEnabled public String name;

        @AuraEnabled public String value;
        @AuraEnabled public String iconPosition;
        @AuraEnabled public Boolean disabled;
        @AuraEnabled public String iconName;
    }
	public class ModalFields{
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
    }
}