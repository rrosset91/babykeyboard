/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint ]
Classe utilizada como estrutura dos dados referente ao retorno do serviço de consulta de número de telefone (PME_ConsultarOperadoraTelefone).
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/
public with sharing class PME_ConsultarOperadoraTelefone_Response {
	public Data data									{ get; set; }

	public class Data{
		public List<ValidRequests> validRequests		{ get; set; }
		public List<RejectedRequests> rejectedRequests	{ get; set; }
	}
	
	public class ValidRequests{
		public DonorOperator DonorOperator 				{ get; set; }
		public List<RequestedTickets> requestedTickets		{ get; set; }
	}
	
	public class DonorOperator{
		public String name								{ get; set; }
	}
	
	public class RequestedTickets{
		public PhoneLineNumberType phoneLineNumberType	{ get; set; }
	}
	
	public class PhoneLineNumberType{
		public String phoneLineNumber					{ get; set; }
	}
	
	public class RejectedRequests{
		public String detail								{ get; set; }
		public List<RequestedTickets> requestedTickets		{ get; set; }
        public RejectionReason rejectionReason				{ get; set; }
	}
    
    public class RejectionReason{
        public String reasonId								{ get; set; }
    }
}