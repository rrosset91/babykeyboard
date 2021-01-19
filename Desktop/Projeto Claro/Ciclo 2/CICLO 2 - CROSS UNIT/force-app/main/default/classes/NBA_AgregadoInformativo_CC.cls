public class NBA_AgregadoInformativo_CC {

   @AuraEnabled
   public static Retorno init(id recordId){		
			
		Boolean fromAccount = true;
		Retorno retorno = new Retorno();

		List<Case> lstCase = [SELECT Id, ContractNumber__r.AccountId FROM case WHERE id =:recordId];
		if(! lstCase.isEmpty()){
			case caso = lstCase[0];
			System.debug('caso ' + caso);
			List<Account> lstAccount = [SELECT id,
											   DocumentNumber__c,
											   Birthdate__c,
											   MothersName__c,
											   RG__c,
											   RGEmitter__c,
											   Phone,
											   Name,
											   vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
											   vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
											   vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
											   vlocity_cmt__PremisesId__r.Neighborhood__c,
											   vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
											   vlocity_cmt__PremisesId__r.Number__c,
											   vlocity_cmt__PremisesId__r.Complement__c
											   FROM Account WHERE id =: caso.ContractNumber__r.AccountId];
			if(!lstAccount.isEmpty()){
				Account conta = lstAccount[0];
				System.debug('conta ' + conta);
				List<Contact> lstContato = [SELECT id,
												   DocumentNumber__c,
												   Birthdate,
												   MothersName__c,
												   RG__c,
												   Phone,
												   RGEmitter__c,
												   Premises__r.vlocity_cmt__State__c,
												   Premises__r.vlocity_cmt__City__c,
												   Premises__r.vlocity_cmt__PostalCode__c,
												   Premises__r.Neighborhood__c,
												   Premises__r.vlocity_cmt__StreetAddress__c,
												   Premises__r.Number__c,
												   Premises__r.Complement__c,
												   AccountId 
												   FROM Contact WHERE AccountId =: conta.Id];
                
				if(!lstContato.isEmpty()){
					for(Integer x = 0; x < lstContato.size(); x++){
					System.debug('contato ' + lstContato);
						if(lstContato[x].DocumentNumber__c == conta.DocumentNumber__c){
							retorno.numeroDoCPF = lstContato[x].DocumentNumber__c;
							retorno.dataeNascimentodoTitular = lstContato[x].Birthdate;
							retorno.nomeDaMae = lstContato[x].MothersName__c;
							retorno.numeroDoRG = lstContato[x].RG__c;
							retorno.orgaoEmissorRG = lstContato[x].RGEmitter__c;
							retorno.nomeDoTitular = conta.Name;

							fromAccount = false;
						}
                       
					}
					
				}

				if(fromAccount){
						retorno.numeroDoCPF = conta.DocumentNumber__c;
						retorno.dataeNascimentodoTitular = conta.Birthdate__c;
						retorno.nomeDaMae = conta.MothersName__c;
						retorno.numeroDoRG = conta.RG__c;
						retorno.orgaoEmissorRG = conta.RGEmitter__c;
						retorno.nomeDoTitular = conta.Name;
					}
			}			

		}				
				
		List<NBA_OrgaosEmissores__mdt> lstOrgaosEmissores = [SELECT id, label FROM NBA_OrgaosEmissores__mdt];
		if(! lstOrgaosEmissores.isEmpty()){
			retorno.orgaosEmissores = lstOrgaosEmissores;
		}

		return retorno;   
   }
   
    public Class Retorno{

	   @AuraEnabled public Date dataeNascimentodoTitular ;
	   @AuraEnabled public String nomeDaMae = '';
	   @AuraEnabled public String numeroDoCPF = '';
	   @AuraEnabled public String numeroDoRG = '';
	   @AuraEnabled public String orgaoEmissorRG = '' ;
	   @AuraEnabled public String nomeDoTitular = '';
	   @AuraEnabled public List<NBA_OrgaosEmissores__mdt> orgaosEmissores = new List<NBA_OrgaosEmissores__mdt>(); 

    }   
    
}