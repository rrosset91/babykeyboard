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
		Boolean protocolChange = False;
        if(order != null && order.orderId != null && String.isNotBlank(order.orderId)){
			
			//String idOrde = order.orderId.leftPad(8, '0');
			//Atualizar Case - US105395
			List<Case> lstCase = [Select Id, ProtocolNumber__c From Case Where Order__c = :order.orderId];
			System.debug('lstCase size: ' + lstCase.size());
            List<Solic_NBA__c> lstSolicNba = [SELECT Id, Name, Message__c, Order__c, Asset__c, Status__c, FullCancel__c, ExecutionCode__c FROM Solic_NBA__c WHERE Order__c = :order.orderId];
            //List<Solic_NBA__c> solicCancelTotal = [SELECT Id, Name, Message__c, Order__c, Asset__c, Status__c, FullCancel__c FROM Solic_NBA__c WHERE Order__c = :order.orderId AND FullCancel__c = TRUE];
			List<Solic_NBA__c> solicCancelTotal = new List<Solic_NBA__c>();
            for(Solic_NBA__c itSolicNba : lstSolicNba){
                if(itSolicNba.FullCancel__c){
                    solicCancelTotal.add(itSolicNba);
                }
            }
            
            Map<String, Solic_NBA__c> mapTasks = new Map<String, Solic_NBA__c>(lstSolicNba);
            
            if(solicCancelTotal != null && !solicCancelTotal.isEmpty()){

				//Map<String, Solic_NBA__c> mapTasks = new Map<String, Solic_NBA__c>([SELECT Id, Name, Message__c, Order__c, Asset__c, Status__c, FullCancel__c, ExecutionCode__c FROM Solic_NBA__c WHERE Order__c = :order.orderId]);
				
				if(mapTasks != null && !mapTasks.values().isEmpty()){
					if(order.tasks != null && !order.tasks.isEmpty()){
						String statusSolic = '';
						for(RPA_tasks tks : order.tasks){
							if(mapTasks.containsKey(tks.taskId)){
                                System.debug('>>>>>tks.Status' + tks.Status);
								mapTasks.get(tks.taskId).Status__c  = tks.Status.equalsIgnoreCase('Sucesso') ? 'Concluído' : tks.Status;
								mapTasks.get(tks.taskId).Message__c = tks.message;
								mapTasks.get(tks.taskId).ExecutionCode__c = tks.executionCode;
								statusSolic							= tks.Status;

								for ( Case itCase : lstCase){
                                    if(itCase.ProtocolNumber__c != tks.protocolNumber){
                                        protocolChange = True;
                                        itCase.ProtocolNumber__c = tks.protocolNumber;
                                    }
                                    
								}
							}
						}
						for(Solic_NBA__c solic : mapTasks.values()){
							solic.Status__c = statusSolic;
						}	        
						update mapTasks.values();	
                        
                        if(lstCase.size() > 0 && protocolChange){
                            System.debug('1 - Entrou update Case: ' + lstCase);
                            update lstCase;
                        }
                       					
                        response.ord.orderId		= order.orderId;
						response.ord.tasks			= order.tasks;
					}	
				}else {
					response.ord.orderId		= order.orderId;
					response.ord.tasks			= order.tasks;
					response.error.message		= 'Error - Não localizamos Tasks para este OrderID';
				}
					
			}else {
				
				//Map<String, Solic_NBA__c> mapTasks = new Map<String, Solic_NBA__c>([SELECT Id, Name, Message__c, Order__c, Asset__c, Status__c, FullCancel__c, ExecutionCode__c FROM Solic_NBA__c WHERE Order__c = :order.orderId]);
				if(mapTasks != null && !mapTasks.values().isEmpty()){
					if(order.tasks != null && !order.tasks.isEmpty()){
						for(RPA_tasks tks : order.tasks){
							if(mapTasks.containsKey(tks.taskId)){
								mapTasks.get(tks.taskId).Status__c  = tks.Status.equalsIgnoreCase('Sucesso') ? 'Concluído' : tks.Status;
								mapTasks.get(tks.taskId).Message__c = tks.message;
								mapTasks.get(tks.taskId).ExecutionCode__c = tks.executionCode;

								for (Case itCase : lstCase){
									itCase.ProtocolNumber__c = tks.protocolNumber;
								}
							}
						}
						update mapTasks.values();	
						if(lstCase.size() > 0){
                            System.debug('2 - Entrou update Case: ' + lstCase);
                            update lstCase;
                        }
						response.ord.orderId		= order.orderId;
						response.ord.tasks			= order.tasks;
					}	
				}else {
					response.ord.orderId		= order.orderId;
					response.ord.tasks			= order.tasks;
					response.error.message		= 'Error - Não localizamos Tasks para este OrderID';
				}
			
			}
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
		@TestVisible String executionCode  = ''; //US105395
		@TestVisible String protocolNumber  = '';//US105395
		@TestVisible String message = '';
	}

}