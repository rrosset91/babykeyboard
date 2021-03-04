public class CEC_CloseOcurrencyNetRequest {
    public String source					{ get; set; } //Empresa que está consumindo o Serviço (ex. “Claro”).
	public String userLogin  				{ get; set; } //Id do Usuário que fez o fechamento.
	public Data resolution 					{ get; set; }
	
	public class Data{
        public String id				    { get; set; } //ID da resolução da ocorrência.
      	public String notes 				{ get; set; } //Observação do encerramento da Ocorrência.
	}	 
}