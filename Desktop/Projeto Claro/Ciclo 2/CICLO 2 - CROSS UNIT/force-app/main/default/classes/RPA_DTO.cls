/*----------------------------------------------------------
  EMPRESA - Accenture
  DESCRICÃO - classe responsavel por estruturar as mensagens de requisicão dos callouts
  Autor - Diego Silva
  Versão - 1.0
  ------------------------------------------------------------*/

public class RPA_DTO  {
	
	/*
	  Estrutura REQUEST Aprovisionamento
	*/
	public RPA_Data data = new RPA_Data();

	public class RPA_Data {
		public String orderId;
		public String operationType		= '';
		public String operatorCode		= '';
		public String schedulingDate	= '';
		public String schedulingPeriod	= '';
		public String accountHolder     = '';
		public String telephoneNumber   = '';
		public String motherName        = '';
		public String rg                = '';
		public String cpf               = '';
		public String supervisorId      = '';
		public String serviceProvider   = '';
		public String salesmanName      = '';
		public RPA_exemption exemption  = new RPA_exemption();
		public RPA_contact contact      = new RPA_contact();
		public List<RPA_tasks> tasks	= new List<RPA_tasks>();
	}

	public class RPA_exemption {
		public String type	= '';
		public String value	= '';
	}

	public class RPA_contact {
		public String reason	= '';
		public String subreason	= '';
		public String result    = '';
	}

	public class RPA_tasks {
		public String taskId					 = '';
		public String solicitationType			 = '';
		public String action					 = '';
		public String city						 = '';
		public String salesmanUser				 = '';
		public String saleTypeId				 = '';
		public String campaignId				 = '';
		public String acquisitionType			 = '';
		public String revokeType				 = '';
		public String revokeReason				 = '';
		public String paymentMethod				 = '';
		public String channel					 = '';
		public String notes						 = '';
		public String result                     = '';
		public String resultReason               = '';
		public String resultNotes                = '';
		public String fidelityPenaltyPrice       = '';
		public String hasFidelity                = '';
		public String flagFidelityRenewal        = '';
		public RPA_customer customer			 = new RPA_customer();
		public RPA_targetProduct targetProduct	 = new RPA_targetProduct();
	}

	public class RPA_customer {
		public String contractNumber	= '';
		public String profile			= '';
		public String status			= '';
	}

	public class RPA_targetProduct {
		public String type			          = '';
		public String name			          = '';
		public String point			          = '';
		public String serialNumber            = '';
		public String technologyId            = '';
		public String pointType               = '';
		public String fidelityRenewalDate     = '';
		public String fidelityExpirationDate  = '';
		public String telephoneNumber         = '';
	}
}