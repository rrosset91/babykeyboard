/*
* Autor: Marcos Aurelio - Deloitte
* Data: 27/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 8]
Classe utilizada como estrutura dos dados referente ao retorno do serviço de consulta de cnpj (PME_ValidadeCNPJ).
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/

public class CEC_PME_MobileCorporateCustomer_Response {
	public Data data 												{ get; set; }
	public Error error												{ get; set; }
	
	public class Data{
		public MobileCustomers mobileCustomers						{ get; set; }
	}
	
	public class MobileCustomers{
		public String documentNumberCNPJ							{ get; set; }
	}

	public class Error{
		public String httpCode										{ get; set; }
		public String errorCode										{ get; set; }
		public String message										{ get; set; }
		public String detailedMessage								{ get; set; }

	}
}