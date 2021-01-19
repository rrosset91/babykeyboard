/**
 * @description       : Wrapper de envio de dados para o componente LWC solarFinanceiroDetalhedaFatura
 * @author            : Diego Almeida
 * @group             : IBM
 * @last modified on  : 30-10-2020
 * @last modified by  : Diego Almeida
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   20-10-2020   Diego Almeida   Initial Version
 * 1.1   29-10-2020   Diego Almeida   Changed data structure to TreeGrid
**/
public without sharing class FinancialMobileInvoicesDetailsWrapper {
    public class ResponseWrapper 
    {
        @AuraEnabled public Integer responseCode;
        @AuraEnabled public string  errorMessage;

        @AuraEnabled Public List<Columns> gridColumns;
        @AuraEnabled Public List<DataTreeGridWrapper> gridMobile;
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
        @AuraEnabled public Boolean  disabled;
    }


    public class DataTreeGridWrapper
    {
        @AuraEnabled public Long    lineId;         //id linha deve ser um numero acima de 0
        @AuraEnabled public String  description;    //Item
        @AuraEnabled public String  lineNumber;     //Linha
        @AuraEnabled public String  dataShow;       //Data de Lancamento
        // @AuraEnabled public String  dataSort;
        @AuraEnabled public String  contestation;   //Contestacao
        @AuraEnabled public String  adjustment;     //Ajuste
        // @AuraEnabled public Decimal realAdjustment;
        @AuraEnabled public String  hour;           //Hora
        @AuraEnabled public String  callOrigin;     //Origem
        @AuraEnabled public String  callNumber;     //Numero
        @AuraEnabled public String  callLength;     //Duracao
        @AuraEnabled public String  consumption;     //Consumo
        @AuraEnabled public String  rate;           //Tarifa
        // @AuraEnabled public Decimal realRate;
        // @AuraEnabled public Long    invoiceItemDetailId;
        @AuraEnabled public String  value;          //Valor
        // @AuraEnabled public Decimal realValue;
        @AuraEnabled public List<DataTreeGridWrapper> children; //Controle de hierarquia do DataTree (tem q alterar para _children no componente)

    }

}