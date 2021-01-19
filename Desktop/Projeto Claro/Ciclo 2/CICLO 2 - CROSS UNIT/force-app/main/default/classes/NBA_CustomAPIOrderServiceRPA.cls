/*----------------------------------------------------------
  EMPRESA   - Accenture
  DESCRICÃO - classe responsavel por expor uma interface para ações de Order 
  Autor     - Diego Silva
  Versão    - 1.0
  ------------------------------------------------------------*/

@RestResource(urlMapping='/api/updateTasks/*')
global class NBA_CustomAPIOrderServiceRPA  {
	
	@HttpPost
	global static RPA_order_response doPost(RPA_order order){
		RPA_order_response response	= new RPA_order_response();

		if(order != null && order.orderId != null && String.isNotBlank(order.orderId)){
			
			//String idOrde = order.orderId.leftPad(8, '0'); 

			List<Solic_NBA__c> solicCancelTotal = [SELECT Id, Name, Message__c, Order__c, Asset__c, Status__c, FullCancel__c FROM Solic_NBA__c WHERE Order__c = :order.orderId AND FullCancel__c = TRUE];
			if(solicCancelTotal != null && !solicCancelTotal.isEmpty()){

				Map<String, Solic_NBA__c> mapTasks = new Map<String, Solic_NBA__c>([SELECT Id, Name, Message__c, Order__c, Asset__c, Status__c, FullCancel__c FROM Solic_NBA__c WHERE Order__c = :order.orderId]);
				
				if(mapTasks != null && !mapTasks.values().isEmpty()){
					if(order.tasks != null && !order.tasks.isEmpty()){
						String statusSolic = '';
						for(RPA_tasks tks : order.tasks){
							if(mapTasks.containsKey(tks.taskId)){
								mapTasks.get(tks.taskId).Status__c  = tks.Status;
								mapTasks.get(tks.taskId).Message__c = tks.message;
								statusSolic							= tks.Status;
							}
						}
						for(Solic_NBA__c solic : mapTasks.values()){
							solic.Status__c = statusSolic;
						}	        
						update mapTasks.values();					
						response.ord.orderId		= order.orderId;
						response.ord.tasks			= order.tasks;
					}	
				}else {
					response.ord.orderId		= order.orderId;
					response.ord.tasks			= order.tasks;
					response.error.message		= 'Error - Não localizamos Tasks para este OrderID';
				}
					
			}else {
				
				Map<String, Solic_NBA__c> mapTasks = new Map<String, Solic_NBA__c>([SELECT Id, Name, Message__c, Order__c, Asset__c, Status__c, FullCancel__c FROM Solic_NBA__c WHERE Order__c = :order.orderId]);
				if(mapTasks != null && !mapTasks.values().isEmpty()){
					if(order.tasks != null && !order.tasks.isEmpty()){
						for(RPA_tasks tks : order.tasks){
							if(mapTasks.containsKey(tks.taskId)){
								mapTasks.get(tks.taskId).Status__c  = tks.Status;
								mapTasks.get(tks.taskId).Message__c = tks.message;
							}
						}
						update mapTasks.values();					
						response.ord.orderId		= order.orderId;
						response.ord.tasks			= order.tasks;
					}	
				}else {
					response.ord.orderId		= order.orderId;
					response.ord.tasks			= order.tasks;
					response.error.message		= 'Error - Não localizamos Tasks para este OrderID';
				}
			
			}
			
			updateOrderStatus(order.orderId);
		}else {
			response.ord.orderId		= order.orderId;
			response.ord.tasks			= order.tasks;
			response.error.message		= 'Error - OrderID não localizada';
		}
		return response;	
	}


	global class RPA_order {
		@TestVisible  String orderId		  = '';
		@TestVisible  List<RPA_tasks> tasks	  = new List<RPA_tasks>();
	}

	global class RPA_order_response {
		@TestVisible  RPA_order ord   = new RPA_order(); 
		RPA_error error	= new RPA_error();
	}

	global class RPA_error {
		@TestVisible  String message = '';
	}

	
	global class RPA_tasks {
		@TestVisible String taskId  = '';
		@TestVisible String Status  = '';
		@TestVisible String message = '';
	}

	private static void updateOrderStatus(Id orderId) {
		List<Solic_NBA__c> allSolics = [SELECT Status__c FROM Solic_NBA__c WHERE Order__c = :orderId];
		Integer errorCount = 0;
		Integer sentCount = 0;
		Integer successCount = 0;

		for (Solic_NBA__c solic : allSolics) {
			if (solic.Status__c == 'Em processamento' || solic.Status__c == 'Erro' || solic.Status__c == 'Concluído') {
				sentCount++;
			}
			if (solic.Status__c == 'Concluído') {
				successCount++;
			}
			if (solic.Status__c == 'Erro') {
				errorCount++;
			}
		}

		String orderStatus;
		if (errorCount > 0) {
			orderStatus = 'Erro';
		} else if (successCount == sentCount) {
			orderStatus = 'Concluído';
		}

		if (orderStatus != null) {
			update new Order(Id = orderId, Status = orderStatus);
		}

	}
}