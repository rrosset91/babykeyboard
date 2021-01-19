/**
 * @description       : Wrapper de envio de dados para o componente LWC solarFinanceiroDetalhedaFatura

 * @author            : Caio Cesar Leite de Oliveira
 * @group             : IBM
 * @last modified on  : 08-12-2020
 * @last modified by  : Caio Cesar
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   20-10-2020   Caio Cesar Leite de Oliveira   Initial Version
**/
public without sharing class FinancialMobileInvoicesDetailsWrapper {
    

    public class ResponseInvoiceDetailsWrapper 
    {
        @AuraEnabled public Integer responseCode;
        @AuraEnabled public String  errorMessage;
        @AuraEnabled public List<ResponseInvoiceDetails> responseData;


        // @AuraEnabled Public List<Columns> gridColumns;
        // @AuraEnabled Public List<DataTreeGridWrapper> gridMobile;
    }


    public class ResponseInvoicesDetails{
		public String apiVersion;
		public String transactionId;
		public Data data;
    }
    
    public class Data{
		public List<billedCharged> billedCharged;
    }
    
    public class billedCharged{
        @AuraEnabled public String  chargeId;
        @AuraEnabled public String payChannelId;
        @AuraEnabled public String  activityCode;
        @AuraEnabled public String  activityReasonCode;
        @AuraEnabled public Decimal originalActivityAmount;
        @AuraEnabled public Decimal originalActivityTaxAmount;
        @AuraEnabled public Decimal activityAmountIncludingTax;
        @AuraEnabled public String  activityDate;
        @AuraEnabled public Integer invoiceSequenceNumber;
        @AuraEnabled public String  chargeCode;
        @AuraEnabled public String  chargeRevenueCode;
        @AuraEnabled public Decimal currentAmount;
        @AuraEnabled public Decimal currentTaxAmount;
        @AuraEnabled public String  invoiceType;
        @AuraEnabled public String  chargeCodeDesc;
        @AuraEnabled public String  subscriberNo;
        @AuraEnabled public String chargeSeqNo;
        @AuraEnabled public String  ldInd;
        @AuraEnabled public Integer purgeSeqNo;
        @AuraEnabled public Integer dismSeqNo;
        @AuraEnabled public Integer paSeqNo;
        @AuraEnabled public Integer relToPaInd;
        @AuraEnabled public String  colExcludeInd;
    }

    public class ResponseInvoiceDetails{
        @AuraEnabled public String chargeId;
        @AuraEnabled public String payChannelId;
        @AuraEnabled public String activityCode;
        @AuraEnabled public String activityReasonCode;
        @AuraEnabled public Decimal originalActivityAmount;
        @AuraEnabled public Decimal originalActivityTaxAmount;
        @AuraEnabled public Decimal valor;             
        @AuraEnabled public String dataLancamento;                           
        @AuraEnabled public Integer invoiceSequenceNumber;
        @AuraEnabled public String chargeCode;
        @AuraEnabled public String chargeRevenueCode;
        @AuraEnabled public Decimal ajuste;                          
        @AuraEnabled public Decimal currentTaxAmount;
        @AuraEnabled public String invoiceType;
        @AuraEnabled public String item;                          
        @AuraEnabled public String linha;                           
        @AuraEnabled public String chargeSeqNo;
        @AuraEnabled public String ldInd;
        @AuraEnabled public Integer purgeSeqNo;
        @AuraEnabled public Integer dismSeqNo;
        @AuraEnabled public Integer paSeqNo;
        @AuraEnabled public Integer relToPaInd;
        @AuraEnabled public String colExcludeInd;
        @AuraEnabled public String consumo;
        @AuraEnabled public String contestavel;  
    }


    // public class Columns
    // {
    //     @AuraEnabled public String  label;
    //     @AuraEnabled public String  fieldName;
    //     @AuraEnabled public String  type;
    //     @AuraEnabled public Boolean hideDefaultActions;
    //     @AuraEnabled public Boolean sortable;
    //     @AuraEnabled public Integer  initialWidth;
    //     @AuraEnabled public AtributeColumns typeAttributes;
    // }

    // public class AtributeColumns
    // {
    //     @AuraEnabled public String  currencyCode;
    //     @AuraEnabled public String  iconName;
    //     @AuraEnabled public String  label;
    //     @AuraEnabled public String  name;
    //     @AuraEnabled public String  tooltip;
    //     @AuraEnabled public String  target;
    //     @AuraEnabled public Boolean  disabled;
    //     @AuraEnabled public List<RowAction>  rowActions;
    // }

    // public class RowAction
    // {
    //     @AuraEnabled public String  label;
    //     @AuraEnabled public String  name;
    // }

    // public class DataTreeGridWrapper
    // {
    //     @AuraEnabled public Long    lineId;         //id linha deve ser um numero acima de 0
    //     @AuraEnabled public String  description;    //Item
    //     @AuraEnabled public String  lineNumber;     //Linha
    //     @AuraEnabled public String  dataShow;       //Data de Lancamento
    //     // @AuraEnabled public String  dataSort;
    //     @AuraEnabled public String  contestation;   //Contestacao
    //     @AuraEnabled public String  adjustment;     //Ajuste
    //     // @AuraEnabled public Decimal realAdjustment;
    //     @AuraEnabled public String  hour;           //Hora
    //     @AuraEnabled public String  callOrigin;     //Origem
    //     @AuraEnabled public String  callNumber;     //Numero
    //     @AuraEnabled public String  callLength;     //Duracao
    //     @AuraEnabled public String  consumption;    //Consumo
    //     @AuraEnabled public String  rate;           //Tarifa
    //     // @AuraEnabled public Decimal realRate;
    //     // @AuraEnabled public Long    invoiceItemDetailId;
    //     @AuraEnabled public String  value;          //Valor
    //     // @AuraEnabled public Decimal realValue;
    //     @AuraEnabled public List<DataTreeGridWrapper> children; //Controle de hierarquia do DataTree (tem q alterar para _children no componente)

    // }


}