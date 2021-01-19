/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Classe utilizada como estrutura dos dados referente ao retorno do serviço de consulta de endereço (CEC_PME_ListarEndereco).
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/

public with sharing class CEC_PME_ListarEndereco_Response {
	public Data data						{ get; set; }
	public Error error						{ get; set; }
	public class Data{
		public List<Address> address		{ get; set; }
	}
	
	public class Address{
		public String addressType 			{ get; set; }
      	public String prefix 				{ get; set; }
      	public String logradouro 			{ get; set; }
      	//public String number 				{ get; set; }
      	public String addressComplement 	{ get; set; }
      	public String neighborhood 			{ get; set; }
      	public String mailbox 				{ get; set; }
      	public String city 					{ get; set; }
      	public String state 				{ get; set; }
      	public String zipCode 				{ get; set; }
      	public String ibgeCityId 			{ get; set; }
      	public String ibgeUfId 				{ get; set; }
      	public String ddd 					{ get; set; }
        public String ruralAreaIndicator 	{ get; set; }
	}

	public class Error{
		public String message				{ get; set; }
	}
}