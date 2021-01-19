/**
 * @description       : 
 * @author            : Diego Almeida
 * @group             : 
 * @last modified on  : 05-11-2020
 * @last modified by  : Diego Almeida
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-11-2020   Diego Almeida   Initial Version
**/
public with sharing class FinancialMobileInvoicesConfirmWraper {
    public class ResponseWrapper 
    {
        @AuraEnabled public Integer responseCode;
        @AuraEnabled public string  errorMessage;
        @AuraEnabled public string  totalOriginalValue;         //Valor Original Total
        @AuraEnabled public string  totalCorrectedValue;        //Valor Corrigido Total

        @AuraEnabled Public List<Columns> columns;
        @AuraEnabled Public List<ContestationItens> lstChanged;
        @AuraEnabled Public List<ContestationItens> lstNotChanged;
    }
    public class ContestationItens 
    {
        @AuraEnabled public Long    lineId;                     //id linha deve ser um numero acima de 0
        @AuraEnabled public String  description;                //Item
        @AuraEnabled public Long    lineNumber;                 //Linha
        @AuraEnabled public String  dateShow;                   //Data de Lancamento
        @AuraEnabled public String  dateSort;                   //Data de Lancamento Ordenacao
        @AuraEnabled public String  adjustment;                 //Saldo
        @AuraEnabled public Decimal adjustmentSort;             //Saldo Ordenacao
        @AuraEnabled public String  originalValue;              //Valor Original
        @AuraEnabled public Decimal originalValueSort;          //ValorOrdenacao
        @AuraEnabled public String  correctedValue;             //Valor Corrigido
        @AuraEnabled public Decimal correctedValueSort;         //ValorOrdenacao
    }
    public class Columns
    {
        @AuraEnabled public String  label;
        @AuraEnabled public String  fieldName;
        @AuraEnabled public String  type;
        @AuraEnabled public Boolean hideDefaultActions;
        @AuraEnabled public Boolean sortable;
        @AuraEnabled public Integer  initialWidth;
        @AuraEnabled public AtributeColumns typeAttributes;
    }

    public class AtributeColumns
    {
        @AuraEnabled public String  currencyCode;
        @AuraEnabled public String  iconName;
        @AuraEnabled public String  label;
        @AuraEnabled public String  name;
        @AuraEnabled public String  tooltip;
        @AuraEnabled public String  target;
        @AuraEnabled public Boolean  disabled;
        @AuraEnabled public List<RowAction>  rowActions;
    }

    public class RowAction
    {
        @AuraEnabled public String  label;
        @AuraEnabled public String  name;
    }
}