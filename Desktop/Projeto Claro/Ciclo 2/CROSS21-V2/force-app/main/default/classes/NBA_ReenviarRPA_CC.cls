public class NBA_ReenviarRPA_CC  {
	
	@AuraEnabled
	public static Retorno sendPedido(String idOrder){
		NBA_IntegrationUtils.HttpResponseModel res;
		Retorno retorn	= new Retorno();
		
		//if(!Test.isRunningTest()){
			res				= NBA_IntegrationServices.provisionamento( idOrder );
		//}else {
			//res				= new NBA_IntegrationUtils.HttpResponseModel();
			//res.success		= true;
			//res.statusCode  = 200;
			//res.status		= 'Sucess';
		//}
		
		if(res != null && res.success){
			retorn.message		= 'Enviado com sucesso!';
			retorn.isSuccess	= true;
			NBA_CustomRPA.updateStatusSolic( res,  idOrder);
		}else if(res != null && !res.success) {
			retorn.message		= res.status + '\nCod - ' + String.valueOf(res.statusCode);
			retorn.isSuccess	= false;
			NBA_CustomRPA.updateStatusSolic( res,  idOrder);
		}
		return retorn;
	}
	
	@AuraEnabled
	public static Retorno showComponent(String idOrder){
		Retorno ret					  = new Retorno();
		List<Solic_NBA__c> listResult = getSolicFromOrder( idOrder );

		if(listResult.isEmpty()){
			ret.isSuccess = false;
		}else {
			ret.isSuccess = true;
		}
		return ret;
	}

	@TestVisible
	private static List<Solic_NBA__c> getSolicFromOrder(String idOrder){
		List<Solic_NBA__c> listResult = new List<Solic_NBA__c>();
		for(Solic_NBA__c solic : [SELECT id, Status__c, Order__c FROM Solic_NBA__c WHERE Order__c = :idOrder AND (Status__c = 'Em aberto' OR Status__c = 'Não enviado')]){
			listResult.add( solic );
		}
		return listResult;
	}

	public class Retorno {
		@AuraEnabled
		public String message;
		@AuraEnabled
		public Boolean isSuccess;
	}
}