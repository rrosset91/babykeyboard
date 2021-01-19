/**
* @author: Rafael de Campos
* @company: IBM - Bluewolf
* @description: do tipo wrapper para reunir as informações das faturas em aberto
*/
public class InvoicesWrapper {
	@AuraEnabled
    public String tipoFatura {get;set;}
    @AuraEnabled
    public String produto {get;set;}
    @AuraEnabled
    public String status {get;set;}
    @AuraEnabled
    public String cobranca {get;set;}
    @AuraEnabled
    public String dataVencimento {get;set;}
    @AuraEnabled
    public String dataPagamento {get;set;}
    @AuraEnabled
    public String dataBaixa {get;set;}
    @AuraEnabled
    public String valor {get;set;}
    @AuraEnabled
	public String idFatura {get;set;}
	@AuraEnabled
	public GeneralInvoicesController.ContestedInvoice contestation;
}