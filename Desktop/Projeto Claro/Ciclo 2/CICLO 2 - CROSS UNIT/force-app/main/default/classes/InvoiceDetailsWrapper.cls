/**
 * @author: Bruno Felix
 * @company: IBM - Bluewolf
 * @description: Wrapper para reunir os detalhes da fatura
 */
public class InvoiceDetailsWrapper {
	 @AuraEnabled public String tipoFatura { get; set; }
     @AuraEnabled public String formaPagamento {get;set;}
     @AuraEnabled public String modoRecebimento {get;set;}
     @AuraEnabled public String endereco {get;set;}
	 @AuraEnabled public String idFatura { get; set; }
	 @AuraEnabled public String status { get; set; }
	 @AuraEnabled public String produto { get; set; }
	 @AuraEnabled public String valor { get; set; }
	 @AuraEnabled public String dataVencimento { get; set; }
	 @AuraEnabled public String dataPagamento { get; set; }
	 @AuraEnabled public String dataBaixa { get; set; }
	 @AuraEnabled public Boolean canDispute { get; set; }
	 @AuraEnabled public List<InvoiceProducts> detalheProdutos { get; set; }

	public class InvoiceProducts {
		 @AuraEnabled public String invoiceItem { get; set; }
		 @AuraEnabled public String valor { get; set; }
		 @AuraEnabled public String descricao { get; set; }
		 @AuraEnabled public String dataLancamento { get; set; }
		 @AuraEnabled public String dataVencimento { get; set; }
		 @AuraEnabled public String descricaoProduto { get; set; }
		 @AuraEnabled public String totalParcela { get; set; }
		 @AuraEnabled public String numeroParcela { get; set; }
		 @AuraEnabled public String idItem { get; set; }
		 @AuraEnabled public String idParceiro { get; set; }
		 @AuraEnabled public String idPartnerStatement { get; set; }
		 @AuraEnabled public String idDetExtractItem { get; set; }
		 @AuraEnabled public String parceiro { get; set; }
		 @AuraEnabled public String dataProporcionalidade { get; set; }
		 @AuraEnabled public Integer groupIdParent;
		 @AuraEnabled public String sortentryDate;

		// @note Task 100089 : wrapper de exibicao de detalhes
		@AuraEnabled public String periodo { get; set; }
		@AuraEnabled public String telefoneDestino { get; set; }
		@AuraEnabled public String localDestino { get; set; }
		@AuraEnabled public String pais { get; set; }
		@AuraEnabled public String horarioInicio { get; set; }
		@AuraEnabled public Double duracao { get; set; }
		// @AuraEnabled public String valor { get; set; }
	}
	
}