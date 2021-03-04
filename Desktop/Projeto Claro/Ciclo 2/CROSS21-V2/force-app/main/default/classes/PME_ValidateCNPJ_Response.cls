/*
* Autor: --
* Data: --
* Descrição: --
* 
* Controle de Versão
* ---------------------------------------------------------------
* Autor: João Rodrigues
* Data: 02/06/2020
* Alterações: Inclusão do campo status para subscribers
*/

public with sharing class PME_ValidateCNPJ_Response {
	public Data data 												{ get; set; }
	public ParametroInvalidoFault parametroInvalidoFault			{ get; set; }
	public TechnicalFault technicalFault							{ get; set; }
	
	public class Data{
		public List<subscribers> subscribers						{ get; set; }
	}
	
	public class Subscribers{
		public Customer customer									{ get; set; }
		public String status										{ get; set; }
	}
	
	public class Customer{
		public String subType										{ get; set; }
	}
	
	public class ParametroInvalidoFault{
		public String mensagem										{ get; set; }
	}
	
	public class TechnicalFault{
		public String mensagem										{ get; set; }
	}
}