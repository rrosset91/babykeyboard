public with sharing class NBA_AccordionCurrentProducts_CC {

	//@AuraEnabled
	//public static NBA_IntegrationModels.CurrentProductResponse consultarProdutoAtual(Id recordId) a{

		//NBA_IntegrationModels.CurrentProductResponse response = new NBA_IntegrationModels.CurrentProductResponse();

		//List<Case> lstCase = [SELECT ContractNumber__r.ContractNumber__c FROM Case WHERE Id = :recordId];
		//List<User> lstUser = [SELECT NetServicos__c, FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId()];

		//String contractNumber = '';
		//if (!lstCase.isEmpty()) {
			//contractNumber = lstCase[0].ContractNumber__r.ContractNumber__c;
		//}

		//String netServicos = '';
		//if (!lstUser.isEmpty()) {
			//netServicos = lstUser[0].NetServicos__c != null ? lstUser[0].NetServicos__c : lstUser[0].FederationIdentifier;
		//}

		//if (String.isNotBlank(contractNumber) && String.isNotBlank(netServicos)) {
			//Map<String, Object> request = new Map<String, Object> ();
			//request.put('operatorId', netServicos);
			//request.put('contractNumber', contractNumber);

			//response = NBA_IntegrationServices.getCurrentProduct(request);
		//}

		//return response;
	//}

	@AuraEnabled
	public static LIst<Asset> lista(Id recordId) {

		List<Asset> ltAsset = new List<Asset> ();
		List<Case> lstCase = [SELECT Id, Contract__c, ContractNumber__c FROM Case WHERE Id = :recordId];

		Id contractId = null;
		if (!lstCase.isEmpty()) {
			contractId = lstCase[0].ContractNumber__c;
		} else {
			contractId = recordId;
		}

		if (contractId != null) {
			ltAsset = [SELECT Id,
			           Name,
			           MSISDN__c,
			           RecordType.DeveloperName,
			           Terminal__c,
			           Product2.Name,
			           ServiceType__c,
			           ContractedLimit__c,
			           SpotType__c,
			           Price
			           FROM Asset
			           WHERE vlocity_cmt__ContractId__c = :contractId];
		}

		return ltAsset;
	}

	@AuraEnabled
	public static NBA_AccordionCurrentProducts_CC.HeaderContrato initContract(Id recordId) {
		
		Boolean combo = false; // Alexandre Amaro SPT14 US114 11/07/2019
		Date dtNascimento = null;
		List<Asset> lstAsset = new List<Asset> ();
		List<Asset> lstAssetEnd = new List<Asset> ();
		List<Contract> lstContract = new List<Contract> ();
		NBA_AccordionCurrentProducts_CC.HeaderContrato header = new NBA_AccordionCurrentProducts_CC.HeaderContrato();

		List<Case> lstCase = [SELECT Id, Contract__c, ContractNumber__c FROM Case WHERE Id = :recordId];
		Id idContract = null;
		if (!lstCase.isEmpty()) {
			idContract = lstCase[0].ContractNumber__c;
		} else {
			idContract = recordId;
		}

		if (idContract != null) {
			lstContract = [SELECT Id,
			               AccountId,
			               Account.Name,
			               CustomerSigned.Birthdate,
			               DocumentNumber__c,
			               ContractNumber__c,
			               LegacyStatus__c,
			               CityCode__c,
			               Segmentation__c,
			               PaymentMethod__c,
			               BillDeliveryMethod__c,
			               BillingStreet,
			               BillingCity,
			               BillingCountry,
			               BillingState,
			               BillingPostalCode,
						   Segment__c  // Alexandre Amaro SPT14 US114 11/07/2019

			               FROM Contract WHERE id = :idContract];

			lstAsset = [
				SELECT 	Name, recordType.DeveloperName 
				FROM 	Asset 
				WHERE 	(vlocity_cmt__ContractId__c = :idContract) OR 
						(vlocity_cmt__ContractId__r.AccountId = :lstContract[0].AccountId AND 
						RecordType.DeveloperName LIKE 'CEC%Movel%' AND
						Status = 'Ativo')
			];	
			
			lstAssetEnd = [SELECT RecordType.DeveloperName,
			               vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
			               vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
			               vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
			               vlocity_cmt__PremisesId__r.Number__c,
			               vlocity_cmt__PremisesId__r.Neighborhood__c,
			               vlocity_cmt__PremisesId__r.Complement__c
			               FROM Asset
			               WHERE vlocity_cmt__ContractId__c = :idContract and vlocity_cmt__PremisesId__c != null];



			if (lstContract != null && !lstContract.isEmpty()) {
				List<Contact> lstContact = [SELECT Id, Birthdate, DocumentNumber__c FROM Contact WHERE AccountId = :lstContract[0].AccountId];

				if (lstContact != null && !lstContact.isEmpty()) {
					for (Contact con : lstContact) {
						if (con.Birthdate != null && lstContract[0].DocumentNumber__c == con.DocumentNumber__c) {
							dtNascimento = con.Birthdate;
						}
					}
				}
			}
		}

		if (!lstContract.isEmpty()) {
			Contract c = lstContract[0];

			header.nameAccount = c.Account.Name;
			header.idConta = c.AccountId;
			header.documentNumber = c.DocumentNumber__c;
			header.contractNumber = c.ContractNumber__c;
			header.status = c.LegacyStatus__c;
			header.cityCode = c.CityCode__c;
			header.seguimento = c.Segmentation__c;
			header.formadepagamento = c.PaymentMethod__c;
			header.formadeenvio = c.BillDeliveryMethod__c;
			if (dtNascimento != null) {
				header.dtNascimento = dtNascimento.format();
			}

			//Pegar endereço de cobrança do contrato, pois é o mesmo da instalação
			header.endereco = ''; 
			if (String.isNotBlank(c.BillingStreet)) {
				header.endereco += c.BillingStreet + ', ';
			}

			if (String.isNotBlank(c.BillingCity)) {
				header.endereco += c.BillingCity + ', ';
			}
			if (String.isNotBlank(c.BillingState)) {
				header.endereco += c.BillingState + ' - ';
			}

			if (String.isNotBlank(c.BillingPostalCode)) {
				header.endereco += c.BillingPostalCode + ', ';
			}

			if (header.endereco.lastIndexOf(', ') > - 1) {
				header.endereco = header.endereco.removeEnd(', ');
			} 

			System.debug('Retorno do Contrato>>>' + c);
			System.debug('Retorno do Segmento do Contrato>>>' + c.Segmentation__c);
			//System.debug('Retorno do Segmento do Contrato>>>' + c.Segmentation__c.toLowerCase());

			if(c.Segmentation__c != null && c.Segmentation__c.toLowerCase() == 'purple'){  // Alexandre Amaro SPT14 US114 11/07/2019
				header.combo = true;
			}

		}

		if (!lstAsset.isEmpty()) {
			for (Asset a : lstAsset) {
				if (String.isNotBlank(a.RecordType.DeveloperName)) {
					switch on a.RecordType.DeveloperName {

						when 'CECFixo' {
							header.hasNetFone = true;
						}
						when 'CECInternetFixa' {
							header.hasVirtua = true;
						}
						when 'CECMovel', 'CECInternetMovel', 'CECMovelPreControle', 'CECMovelControle' {
							header.hasMovel = true;
						}
						when 'CECTV' {
							if (a.Name != 'ACESSO VIRTUA'){
								if(header.hasTV == false){
									header.hasTV = false;
								}else if(header.hasTV == true){
									header.hasTV = true;
								}else{
									header.hasTV = true;
								}								
							}else{
								header.hasTV = false;
							} 
						}
					}
				}
			}
			if (!lstAssetEnd.isEmpty()) {
				Asset ende = lstAssetEnd[0];
				header.endereco = '';
				if (String.isNotBlank(ende.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c)) {
					header.endereco += ende.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c + ', ';
				}

				if (String.isNotBlank(ende.vlocity_cmt__PremisesId__r.Number__c)) {
					header.endereco += ende.vlocity_cmt__PremisesId__r.Number__c + ', ';
				}
				if (String.isNotBlank(ende.vlocity_cmt__PremisesId__r.Complement__c)) {
					header.endereco += ende.vlocity_cmt__PremisesId__r.Complement__c + ', ';
				}
				if (String.isNotBlank(ende.vlocity_cmt__PremisesId__r.Neighborhood__c)) {
					header.endereco += ende.vlocity_cmt__PremisesId__r.Neighborhood__c + ', ';
				}
				if (String.isNotBlank(ende.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c)) {
					header.endereco += ende.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c + ', ';
				}
				if (String.isNotBlank(ende.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c)) {
					header.endereco += ende.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c + ', ';
				}

				if (header.endereco.lastIndexOf(', ') > - 1) {
					header.endereco = header.endereco.removeEnd(', ');
				}
				System.debug('AA' + lstContract);
				System.debug('BB' + lstAsset);
			}
		}

		return header;
	}

	public class HeaderContrato {
		@AuraEnabled public String nameAccount;
		@AuraEnabled public String dtNascimento;
		@AuraEnabled public String documentNumber;
		@AuraEnabled public String contractNumber;
		@AuraEnabled public String status;
		@AuraEnabled public String cityCode;
		@AuraEnabled public String endereco;
		@AuraEnabled public String seguimento;
		@AuraEnabled public String formadepagamento;
		@AuraEnabled public String formadeenvio;
		@AuraEnabled public Boolean hasTV;
		@AuraEnabled public String idConta;
		@AuraEnabled public Boolean hasVirtua;
		@AuraEnabled public Boolean hasMovel;
		@AuraEnabled public Boolean hasNetFone;
		@AuraEnabled public Boolean combo = false ; // Alexandre Amaro SPT14 US114 11/07/2019
	}

}