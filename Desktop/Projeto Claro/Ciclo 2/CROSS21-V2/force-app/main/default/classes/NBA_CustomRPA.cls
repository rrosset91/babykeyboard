/*----------------------------------------------------------
  EMPRESA   - Accenture
  DESCRICÃO - classe responsavel por realizar chamadas externas 
  Autor     - Diego Silva
  Versão    - 2.0
  ------------------------------------------------------------*/

  public with sharing class NBA_CustomRPA  { 

	private static final Id recordTypeIdNBAOffer = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('NBAOffer').getRecordTypeId();
	

	public static void sendProvisionamento(String idOrder){
		System.debug('Diego Silva -- > INICIANDO FLUXO DE ENVIO PARA O RPA');
		if(checkTasks(idOrder)){
			NBA_IntegrationUtils.HttpResponseModel res = NBA_IntegrationServices.provisionamento( idOrder );
			updateStatusSolic( res,  idOrder);
			updateOrder(res, idOrder );
		}else {
			System.debug('Diego Silva -- > PEDIDO SEM SOLIC - ' + idOrder);
		}
	}

	public static NBA_IntegrationModels.RPA_Data provisionamento(String idOrder){
		if(idOrder != null && String.isNotBlank(idOrder)){
			/*DDP 133864 - INI*/
            List<CEC_City_CarrierCode__mdt> lstCity = [SELECT CodigoOperadora__c, Label FROM CEC_City_CarrierCode__mdt];
            Map<String, String> mapCity = new Map<String, String>();
            for(CEC_City_CarrierCode__mdt cityIt : lstCity){
                mapCity.put(cityIt.CodigoOperadora__c, cityIt.Label);
            }
            /*DDP 133864 - FIM*/
			List<Order> listOrder = [SELECT		Id, 
												SchedulingDate__c, 
												SchedulingTime__c,
												AccountId, 
												Account.Name, 
												Account.MothersName__c,
												Account.Phone, 
												TaxExemptionType__c, 
												TaxExemptionValue__c, 
												Account.RG__c, 
												Account.DocumentNumber__c, 
												OrderNumber, 
												TVMovement__c, 
												VirtuaMovement__c, 
												NETFoneMovement__c, 
												MobileMovement__c, 
												FeeAddValuePaymentForm__c, 
												FeeUpgradePaymentForm__c, 
												ContractId, 
												Contract.CityCode__c, 
												Contract.ContractNumber, 
												Contract.ContractNumber__c, 
												Contract.LegacyStatus__c,
												OwnershipProfile__c, //
												Owner.Profile.Name,
												Owner.Name,
												CreatedDate,
												subscriberId__c,
												OfferValidationRequest__c
										FROM	Order 
										WHERE	Id = :idOrder 
										AND		RecordTypeId = :recordTypeIdNBAOffer];
			
			User user = [SELECT	Id, 
								Profile.name, 
								NetServicos__c, 
								FederationIdentifier, 
								Name, 
								Claro__c
						FROM	User 
						WHERE	Id = :UserInfo.getUserId()];

			Map<String, User> mapUser = new Map<String, User>([SELECT Id,Profile.name,NetServicos__c,FederationIdentifier,Name, Claro__c FROM	User]);

			if(listOrder != null && !listOrder.isEmpty()){
				Order order = listOrder.get(0);
				/*DDP 133864 - INI*/
                String operadora = '';
                if(String.isNotBlank(order.Contract.CityCode__c)){
                   operadora  = mapCity.containsKey(order.Contract.CityCode__c.leftPad(3, '0')) ? mapCity.get(order.Contract.CityCode__c.leftPad(3, '0')) : '';
                }
                /*DDP 133864 - FIM*/ 
				Account acct = getAccountFromOrder( order.AccountId, order.Account.DocumentNumber__c );

				List<Case> lstCaso = [SELECT	Id, 
												A_la_Carte__c, 
												Fixo__c, 
												Movel__c, 
												ProductTV__c, 
												broadband__c, 
												AssetId, 
												CallReason__c, 
												CallResult__c, 
												Order__c, 
												Subreason__c, 
												TVN1Result__c, 
												TVN2Result__c, 
												TVN3Result__c, 
												PhoneN3Result__c, 
												PhoneN2Result__c, 
												PhoneN1Result__c, 
												MobileN2Result__c, 
												MobileN3Result__c, 
												MobileN1Result__c, 
												BLN3Result__c, 
												BLN2Result__c, 
												BLN1Result__c, 
												ALaCarteN3Result__c, 
												ALaCarteN2Result__c, 
												ALaCarteN1Result__c,
												EPS_Operador__c 
									  FROM		Case 
									  WHERE		Order__c = :order.Id];
				
				Case caso = (lstCaso != null && !lstCaso.isEmpty() ? lstCaso[0] : new Case());
				Solic_NBA__c solicMobile = getSolicMobile(idOrder);
				
				NBA_IntegrationModels.RPA_Data dt	= new NBA_IntegrationModels.RPA_Data();
				dt.data.orderId						= order.Id;
				dt.data.accountHolder				= order.Account.Name;
				dt.data.contact.reason				= caso.CallReason__c;
				dt.data.contact.subreason			= caso.Subreason__c;
				dt.data.contact.result				= getCaseResult( caso );
				dt.data.cpf							= order.Account.DocumentNumber__c;
				dt.data.customer					              = new NBA_IntegrationModels.RPA_customer();
				// Agregado Informativo Alexandre amaro
				if(solicMobile != null){
					dt.data.customer.rgIssuer						  =	solicMobile.RGEmitter__c != null ? solicMobile.RGEmitter__c : '';
					dt.data.customer.birthDate                        = solicMobile.BirthDate__c != null ? String.valueOf(solicMobile.BirthDate__c.format()) : acct != null && acct.Contacts != null && !acct.Contacts.isEmpty() && String.valueOf(acct.Contacts.get(0).BirthDate) != null ? String.valueOf(acct.Contacts.get(0).BirthDate.format()) : String.valueOf( acct.BirthDate__c ) != null ? acct.BirthDate__c.format() : '';
					String formatDate								  = solicMobile.RGDate__c != null ? solicMobile.RGDate__c.format() : '';
					dt.data.customer.rgIssueDate					  = formatDate;
					
					dt.data.telephoneNumber							  = acct.Phone != null ? acct.Phone : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Phone) ? acct.Contacts[0].Phone : '';
					dt.data.customer.billingAddress.cityName          = acct.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c != null ? acct.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Premises__r.vlocity_cmt__City__c) ? acct.Contacts[0].Premises__r.vlocity_cmt__City__c : '';
					dt.data.customer.billingAddress.operadora		  = String.isNotBlank(operadora) ? operadora : dt.data.customer.billingAddress.cityName; /*DDP 133864*/
					dt.data.customer.billingAddress.complement        = acct.vlocity_cmt__PremisesId__r.Complement__c != null ? acct.vlocity_cmt__PremisesId__r.Complement__c : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Premises__r.Complement__c) ? acct.Contacts[0].Premises__r.Complement__c : '';
					dt.data.customer.billingAddress.neighborhood      = acct.vlocity_cmt__PremisesId__r.Neighborhood__c != null ? acct.vlocity_cmt__PremisesId__r.Neighborhood__c : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Premises__r.Neighborhood__c ) ? acct.Contacts[0].Premises__r.Neighborhood__c  : '';
					dt.data.customer.billingAddress.postcode          = acct.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c != null ? acct.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Premises__r.vlocity_cmt__PostalCode__c ) ? acct.Contacts[0].Premises__r.vlocity_cmt__PostalCode__c : '';
					dt.data.customer.billingAddress.stateAbbreviation = acct.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c != null ? acct.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Premises__r.vlocity_cmt__State__c ) ? acct.Contacts[0].Premises__r.vlocity_cmt__State__c  : '';
					dt.data.customer.billingAddress.streetName        = acct.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c != null ? acct.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Premises__r.vlocity_cmt__StreetAddress__c ) ? acct.Contacts[0].Premises__r.vlocity_cmt__StreetAddress__c  : '';
					dt.data.customer.billingAddress.streetNr          = String.valueOf(acct.vlocity_cmt__PremisesId__r.Number__c) != null ? String.valueOf(acct.vlocity_cmt__PremisesId__r.Number__c) : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(String.valueOf(acct.Contacts[0].Premises__r.Number__c )) ? String.valueOf(acct.Contacts[0].Premises__r.Number__c)  : '';
					dt.data.customer.billingAddress.streetType        = null;

				} else {
					
					dt.data.customer.rgIssuer						  =	acct != null && acct.Contacts != null && !acct.Contacts.isEmpty() && acct.Contacts.get(0) != null && acct.Contacts.get(0).RGEmitter__c != null ? acct.Contacts.get(0).RGEmitter__c : acct.RGEmitter__c != null ? acct.RGEmitter__c : '';
					dt.data.customer.birthDate                        = acct != null && acct.Contacts != null && !acct.Contacts.isEmpty() && String.valueOf(acct.Contacts.get(0).BirthDate) != null ? String.valueOf(acct.Contacts.get(0).BirthDate.format()) : String.valueOf( acct.BirthDate__c ) != null ? acct.BirthDate__c.format() : '';
					dt.data.telephoneNumber							  = acct.Phone != null ? acct.Phone : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Phone) ? acct.Contacts[0].Phone : '';
					dt.data.customer.billingAddress.cityName          = acct.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c != null ? acct.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Premises__r.vlocity_cmt__City__c) ? acct.Contacts[0].Premises__r.vlocity_cmt__City__c : '';
					dt.data.customer.billingAddress.operadora		  = String.isNotBlank(operadora) ? operadora : dt.data.customer.billingAddress.cityName; /*DDP 133864*/
					dt.data.customer.billingAddress.complement        = acct.vlocity_cmt__PremisesId__r.Complement__c != null ? acct.vlocity_cmt__PremisesId__r.Complement__c : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Premises__r.Complement__c) ? acct.Contacts[0].Premises__r.Complement__c : '';
					dt.data.customer.billingAddress.neighborhood      = acct.vlocity_cmt__PremisesId__r.Neighborhood__c != null ? acct.vlocity_cmt__PremisesId__r.Neighborhood__c : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Premises__r.Neighborhood__c ) ? acct.Contacts[0].Premises__r.Neighborhood__c  : '';
					dt.data.customer.billingAddress.postcode          = acct.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c != null ? acct.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Premises__r.vlocity_cmt__PostalCode__c ) ? acct.Contacts[0].Premises__r.vlocity_cmt__PostalCode__c : '';
					dt.data.customer.billingAddress.stateAbbreviation = acct.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c != null ? acct.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Premises__r.vlocity_cmt__State__c ) ? acct.Contacts[0].Premises__r.vlocity_cmt__State__c  : '';
					dt.data.customer.billingAddress.streetName        = acct.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c != null ? acct.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(acct.Contacts[0].Premises__r.vlocity_cmt__StreetAddress__c ) ? acct.Contacts[0].Premises__r.vlocity_cmt__StreetAddress__c  : '';
					dt.data.customer.billingAddress.streetNr          = String.valueOf(acct.vlocity_cmt__PremisesId__r.Number__c) != null ? String.valueOf(acct.vlocity_cmt__PremisesId__r.Number__c) : acct.Contacts != null && !acct.Contacts.isEmpty() && String.isNotBlank(String.valueOf(acct.Contacts[0].Premises__r.Number__c )) ? String.valueOf(acct.Contacts[0].Premises__r.Number__c)  : '';
					dt.data.customer.billingAddress.streetType        = null;
				}
				//dt.data.customer.birthDate                        = acct != null && acct.Contacts != null && !acct.Contacts.isEmpty() && String.valueOf(acct.Contacts.get(0).BirthDate) != null ? String.valueOf(acct.Contacts.get(0).BirthDate.format()) : String.valueOf( acct.BirthDate__c ) != null ? acct.BirthDate__c.format() : '';
				dt.data.customer.contractNumber		              = getCodAssinate( order.Contract.CityCode__c, order.Contract.ContractNumber__c);
				if(acct.Foreign__c){
					dt.data.customer.nationality = NBA_Constants.RPA_ESTRANGEIRO;
				}else{
					dt.data.customer.nationality = NBA_Constants.RPA_BRASILEIRO;
				}
				dt.data.customer.profile			= order.OwnershipProfile__c;
				dt.data.customer.status				= order.Contract.LegacyStatus__c != null ? order.Contract.LegacyStatus__c : '';
				dt.data.customer.mobileDependentAmount = null;

				if(solicMobile != null){
					//dt.data.telephoneNumber				= solicMobile.ContactPhone__c != null ? solicMobile.ContactPhone__c : '';
					dt.data.motherName					= solicMobile.MothersName__c !=null ? solicMobile.MothersName__c : '';
					dt.data.rg							= solicMobile.RG__c != null ? solicMobile.RG__c : '';
				} else if (acct != null && acct.Contacts != null && !acct.Contacts.isEmpty()) {
					dt.data.telephoneNumber				= acct.Contacts.get(0).Phone != null ? acct.Contacts.get(0).Phone : '';
					dt.data.motherName					= acct.Contacts.get(0).MothersName__c != null ? acct.Contacts.get(0).MothersName__c : '';
					dt.data.rg							= acct.Contacts.get(0).RG__c != null ? acct.Contacts.get(0).RG__c : '';
				} else {
					dt.data.telephoneNumber				= order.Account.Phone != null ? order.Account.Phone : '';
					dt.data.motherName					= order.Account.MothersName__c != null ? order.Account.MothersName__c : '';
					dt.data.rg							= order.Account.RG__c != null ? order.Account.RG__c : '';
				}					

				if (String.isNotBlank(getOperationType( mapUser.get(order.Ownerid).Profile.name ))) {
					dt.data.operationType = getOperationType( mapUser.get(order.Ownerid).Profile.name );
				} else {
					dt.data.operationType = null;
				}
				dt.data.operatorCode				= 'netsp';

				dt.data.salesmanId              = null;
				dt.data.salesmanName				= order.Owner.Name != null ? order.Owner.Name : '';
				dt.data.salesTeam        		= null;

				if (order.SchedulingDate__c != null) {
					dt.data.schedulingDate				= order.SchedulingDate__c.format();
					dt.data.schedulingPeriod			= order.SchedulingTime__c;
				} else {
					dt.data.schedulingDate				= System.today().addDays(1).format();
					dt.data.schedulingPeriod			= null;
				}

				dt.data.serviceProvider				= caso.EPS_Operador__c != null ? caso.EPS_Operador__c : null;
				dt.data.serviceProviderId			= null;
				dt.data.supervisorId				    = null;

				if(caso.A_la_Carte__c){
					dt.data.surveyProductTypes.add(NBA_Constants.TV_A_LA_CARTE);
				}
				if(caso.ProductTV__c){
					dt.data.surveyProductTypes.add(NBA_Constants.TV_PACOTE);
				}
				if(caso.broadband__c){
					dt.data.surveyProductTypes.add(NBA_Constants.BL_ASSINATURA);
				}
				if(caso.Fixo__c){
					dt.data.surveyProductTypes.add(NBA_Constants.NET_FONE);
				}
				if(caso.Movel__c){
					dt.data.surveyProductTypes.add(NBA_Constants.MOVEL_ASSINATURA);
				}

				List<NBA_IntegrationModels.RPA_tasks> listTks	= new List<NBA_IntegrationModels.RPA_tasks>();
				String strMoviment								= getRPAMovement( getSolics( order.Id ) );
				System.debug('TIPO DE MOVIMENTAÇÂO ---> ' + strMoviment);

				if(strMoviment == 'N/A'){
					dt.data.exemption.type		= order.TaxExemptionType__c;
					dt.data.exemption.value		= order.TaxExemptionValue__c;
				}else {
					dt.data.exemption.type		= null;
					dt.data.exemption.value		= null;
				}
				Decimal multa = 0;


				String resultIsTv = isHasTvPacote( order.Id );

				if(strMoviment == 'N/A'){
				
					for(Solic_NBA__c solic : getSolics( order.Id )){
						if(String.valueOf(solic.PenaltyPrice__c) == ''){
							dt.data.penaltyPrice = '0.00';
						}else{
							dt.data.penaltyPrice = '0.00';
						}
						if(solic.ProductType__c != NBA_Constants.MOVEL_ASSINATURA_RPA && solic.ProductType__c != NBA_Constants.MOVEL_DEPENDENTES){
							
							Boolean tipoTv					= ( solic.ProductType__c == NBA_Constants.PONTOS_OPCIONAIS || solic.ProductType__c == NBA_Constants.TV_PACOTE) ? true : false;
							if(solicMobile == null){
								dt.data.customer.rgIssueDate	= String.valueOf(solic.RGDate__c) != null ? String.valueOf(solic.RGDate__c) : '';
								dt.data.customer.rgIssuer		= String.valueOf(solic.RGEmitter__c) != null ? String.valueOf(solic.RGEmitter__c) : '';
							}
							dt.data.customer.isComboMulti	= NBA_Constants.RPA_NAO;

							NBA_IntegrationModels.RPA_tasks tks	= new NBA_IntegrationModels.RPA_tasks();
							tks.taskId							= solic.Id;
							tks.solicitationType				= solic.SolicitationType__c != null ? solic.SolicitationType__c : '';
							tks.action							= solic.Movement__c != null ? solic.Movement__c : '';
							tks.city							= order.Contract.CityCode__c != null ? order.Contract.CityCode__c.leftPad(3, '0') : '';
							tks.salesmanUser					= mapUser.containsKey( order.OwnerId ) && mapUser.get( order.Ownerid ).NetServicos__c != null ? mapUser.get( order.Ownerid ).NetServicos__c + ' | ' + user.Claro__c : mapUser.get( order.Ownerid ).FederationIdentifier + ' | ' + user.Claro__c;
							tks.saleTypeId						= 'Padrão';
							tks.campaignId						= 'Padrão';
							tks.acquisitionType					= 'Padrão';
							tks.revokeType						= null;
							tks.revokeReason					= null;					
							tks.paymentMethod					= String.isNotBlank(solic.PaymentMethod__c) && String.isNotBlank(solic.PromotionName__c) ? solic.PromotionName__c + ' * ' + solic.PaymentMethod__c :  String.isNotBlank(solic.PaymentMethod__c) ? solic.PaymentMethod__c : solic.PromotionName__c + ' * ISENTO';		
							//tks.paymentMethod					= ( solic.PaymentMethod__c != null && String.isNotBlank(solic.PaymentMethod__c) ) ? solic.PromotionName__c + ' * ' + solic.PaymentMethod__c : solic.PromotionName__c + ' * ISENTO';
							tks.channel							= 'Padrão';
							tks.targetProduct.name				= solic.LegacyNameProduct__c != null ? solic.LegacyNameProduct__c : '';
						
							if(solic.Movement__c == NBA_Constants.MOVIMENTO_AQUISICAO && (solic.ProductType__c == NBA_Constants.BL_ADICIONAIS || solic.ProductType__c == NBA_Constants.MOVEL_ADICIONAIS || solic.ProductType__c == NBA_Constants.TV_A_LA_CARTE || solic.ProductType__c == NBA_Constants.TV_PONTOS_ADICIONAIS)){
								tks.targetProduct.point			= solic.MainPoint__c;
							}else if(solic.Movement__c == NBA_Constants.MOVIMENTO_AQUISICAO && ( solic.ProductType__c == NBA_Constants.BL_ASSINATURA || solic.ProductType__c == NBA_Constants.NET_FONE )){
								tks.targetProduct.point			= String.isNotBlank(resultIsTv) ? resultIsTv : solic.MainPoint__c;
							}else {
								tks.targetProduct.point			= solic.CurrentProduct__c;
							}

							tks.targetProduct.currentMobileSubscriptionType = null;
							tks.targetProduct.discountDuration				= String.isNotBlank( solic.QuantityPromoMonths__c ) ? solic.QuantityPromoMonths__c : '0';
							tks.targetProduct.discountValue					= String.valueOf(solic.PromotionValue__c);
							tks.targetProduct.pointType						= solic.SpotType__c;
							tks.targetProduct.pricing						= String.valueOf(solic.TotalValue__c);
							tks.targetProduct.profile						= solic.ComboProfile__c != null ? solic.ComboProfile__c : null;
							tks.targetProduct.serialNumber					= solic.SerialNumber__c != null ? solic.SerialNumber__c : null;
							tks.targetProduct.technologyId					= solic.TechnologyType__c;
							tks.targetProduct.telephoneNumber				= null;
							tks.notes										= null;
							tks.targetProduct.isPortabilityRequest			= null;
							tks.targetProduct.mobileAdditionalServiceName	= null;
							tks.targetProduct.mobileAdditionalServiceType	= null;
							tks.targetProduct.mobileAppliedDiscount			= null;
							tks.targetProduct.mobileDataPlan				= null;
							tks.targetProduct.mobileDependentAmountToAdd	= null;
							tks.targetProduct.mobileOfferType				= null;
							tks.targetProduct.mobilePlanName				= null;
							tks.targetProduct.mobilePromotionalOffer		= null;
							tks.targetProduct.newMobileSubscriptionType		= null;
							tks.targetProduct.fidelityRenewalDate			= solic.RenewFidelity__c ? convertDatetimeToDate( order.CreatedDate ) : null;
							tks.targetProduct.fidelityExpirationDate		= solic.RenewFidelity__c ? convertDatetimeToDate( order.CreatedDate.addDays(365) ) : null;
							tks.targetProduct.msisdn						= solic.MSISDN__c;
							tks.fidelityPenaltyPrice						= solic.Penality_Price__c;
							tks.targetProduct.type							= solic.ProductType__c;
							tks.flagFidelityRenewal							= solic.RenewFidelity__c ? 'SIM' : 'NÃO';							
							tks.hasFidelity									= solic.Fidelity__c ? 'SIM' : 'NÃO';
							tks.targetProduct.pointId 						= solic.pointId__c; 
						
							if(solic.FeePrice__c != null && solic.FeePrice__c > 0){
								tks.fee.price						 = String.valueOf(solic.FeePrice__c);
								//tks.fee.price						 = String.isNotBlank(solic.PaymentMethod__c) ? String.valueOf(solic.FeePrice__c) + '|' + solic.PaymentMethod__c : String.valueOf(solic.FeePrice__c);
								tks.fee.type						 = solic.FeeType__c;
							}else {
								tks.fee.price						 = null;
								tks.fee.type						 = null;
							}

							String pType							 = solic.ProductType__c != null ? solic.ProductType__c : '';
						
							if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('TV PACOTE') || solic.ProductType__c.equalsIgnoreCase('TV PONTOS ADICIONAIS')){
								tks.result			= String.isNotBlank(caso.TVN1Result__c) ? caso.TVN1Result__c : '';
								tks.resultReason	= String.isNotBlank(caso.TVN2Result__c) ? caso.TVN2Result__c : '';
								tks.resultNotes		= String.isNotBlank(caso.TVN3Result__c) ? caso.TVN3Result__c : '';
						
							} else if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('CANAL A LA CARTE') || solic.ProductType__c.equalsIgnoreCase('TV A LA CARTE')){
								tks.result			= null;
								tks.resultReason	= null;
								tks.resultNotes		= null;
						
							} else if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('BL ASSINATURA') || solic.ProductType__c.equalsIgnoreCase('BL ADICIONAIS')){
								tks.result			= String.isNotBlank(caso.BLN1Result__c) ? caso.BLN1Result__c : '';
								tks.resultReason	= String.isNotBlank(caso.BLN2Result__c) ? caso.BLN2Result__c : '';
								tks.resultNotes		= String.isNotBlank(caso.BLN3Result__c) ? caso.BLN3Result__c : '';
						
							} else if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('NET FONE') || solic.ProductType__c.equalsIgnoreCase('NET ADICIONAIS')){
								tks.result			= String.isNotBlank(caso.PhoneN1Result__c) ? caso.PhoneN1Result__c : '';
								tks.resultReason	= String.isNotBlank(caso.PhoneN2Result__c) ? caso.PhoneN2Result__c : '';
								tks.resultNotes		= String.isNotBlank(caso.PhoneN3Result__c) ? caso.PhoneN3Result__c : '';

							} else if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('MOVEL ASSINATURA') || solic.ProductType__c.equalsIgnoreCase('MOVEL DEPENDENTES') || solic.ProductType__c.equalsIgnoreCase('MOVEL ADICIONAIS')){
								tks.result			= String.isNotBlank(caso.MobileN1Result__c) ? caso.MobileN1Result__c : '';
								tks.resultReason	= String.isNotBlank(caso.MobileN2Result__c) ? caso.MobileN2Result__c : '';
								tks.resultNotes		= String.isNotBlank(caso.MobileN3Result__c) ? caso.MobileN3Result__c : '';
							}
							listTks.add( tks );
						}
					}
	
					dt.data.tasks = listTks;

				} else if(strMoviment == 'Parcial'){

					for(Solic_NBA__c solic : getSolics( order.Id )){
						Boolean tipoTv = ( solic.ProductType__c == NBA_Constants.PONTOS_OPCIONAIS || solic.ProductType__c == NBA_Constants.TV_PACOTE) ? true : false;
						if(solic.Movement__c == 'Cancelamento' && solic.ProductType__c != NBA_Constants.MOVEL_ASSINATURA_RPA && solic.ProductType__c != NBA_Constants.MOVEL_DEPENDENTES){
							if(String.valueOf(solic.PenaltyPrice__c) == ''){
								multa += 0;
							}else if(String.valueOf(solic.PenaltyPrice__c) != null){
								multa += solic.PenaltyPrice__c;
							}
							dt.data.penaltyPrice = String.valueOf( multa.setScale(2) );
							if(solicMobile == null){
								dt.data.customer.rgIssueDate		= String.valueOf(solic.RGDate__c) != null ? String.valueOf(solic.RGDate__c) : '';
								dt.data.customer.rgIssuer			= String.valueOf(solic.RGEmitter__c) != null ? String.valueOf(solic.RGEmitter__c) : '';
							}
							dt.data.customer.isComboMulti		= NBA_Constants.RPA_NAO;
							
							NBA_IntegrationModels.RPA_tasks tks	= new NBA_IntegrationModels.RPA_tasks();
							tks.taskId							= solic.Id;
							tks.solicitationType				= null;
							tks.action							= 'Cancelamento';
							tks.city							= order.Contract.CityCode__c != null ? order.Contract.CityCode__c.leftPad(3, '0') : '';
							tks.salesmanUser					= mapUser.containsKey( order.OwnerId ) && mapUser.get( order.Ownerid ).NetServicos__c != null ? mapUser.get( order.Ownerid ).NetServicos__c + ' | ' + user.Claro__c : mapUser.get( order.Ownerid ).FederationIdentifier + ' | ' + user.Claro__c;
							tks.saleTypeId						= 'Padrão';
							tks.campaignId						= 'Padrão';
							tks.acquisitionType					= 'Padrão';
							tks.revokeType						= 'Parcial';
							
							if(String.isNotBlank(caso.CallReason__c) && caso.CallReason__c.equalsIgnoreCase('Inadimplente')){
								tks.revokeReason	= 'Inadimplente';
							}else {
								tks.revokeReason	= 'Opção';
							}

							tks.paymentMethod								= null;
							tks.channel										= 'Padrão';
							tks.targetProduct.name							= null;						
							tks.targetProduct.currentMobileSubscriptionType = null;
							tks.targetProduct.discountDuration				= null;
							tks.targetProduct.discountValue					= null;
							tks.targetProduct.point							= solic.CurrentProduct__c;
							tks.targetProduct.pointType						= solic.SpotType__c;
							tks.targetProduct.pricing						= null;
							tks.targetProduct.profile						= solic.ProductType__c == NBA_Constants.TV_PACOTE ? solic.ComboProfile__c : null;
							tks.targetProduct.serialNumber					= solic.SerialNumber__c != null ? solic.SerialNumber__c : null;
							tks.targetProduct.technologyId					= solic.TechnologyType__c; //tipoTv ?
							tks.targetProduct.telephoneNumber				= null;
							tks.notes										= null;
							tks.targetProduct.isPortabilityRequest			= null;
							tks.targetProduct.mobileAdditionalServiceName	= null;
							tks.targetProduct.mobileAdditionalServiceType	= null;
							tks.targetProduct.mobileAppliedDiscount			= null;
							tks.targetProduct.mobileDataPlan				= null;
							tks.targetProduct.mobileDependentAmountToAdd	= null;
							tks.targetProduct.mobileOfferType				= null;
							tks.targetProduct.mobilePlanName				= null;
							tks.targetProduct.mobilePromotionalOffer		= null;
							tks.targetProduct.newMobileSubscriptionType		= null;
							tks.targetProduct.fidelityRenewalDate			= null;
							tks.targetProduct.fidelityExpirationDate		= null;
							tks.targetProduct.msisdn						= solic.MSISDN__c;							
							tks.targetProduct.type							= solic.ProductType__c;
							tks.flagFidelityRenewal							= solic.RenewFidelity__c ? 'SIM' : 'NÃO';
							tks.targetProduct.pointId						= solic.pointId__c;

							if(String.valueOf(solic.PenaltyPrice__c) == ''){
								tks.fidelityPenaltyPrice = '0.00';
							}else if(String.valueOf(solic.PenaltyPrice__c) != null){
								tks.fidelityPenaltyPrice = String.valueOf( solic.PenaltyPrice__c.setScale(2) );
							}
							
							tks.hasFidelity							 = solic.Fidelity__c ? 'SIM' : 'NÃO';
							tks.fee.type							 = null;
							tks.fee.price							 = null;
							String pType							 = solic.ProductType__c != null ? solic.ProductType__c : '';

							if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('TV PACOTE') || solic.ProductType__c.equalsIgnoreCase('TV PONTOS ADICIONAIS')){
								tks.result			= String.isNotBlank(caso.TVN1Result__c) ? caso.TVN1Result__c : '';
								tks.resultReason	= String.isNotBlank(caso.TVN2Result__c) ? caso.TVN2Result__c : '';
								tks.resultNotes		= String.isNotBlank(caso.TVN3Result__c) ? caso.TVN3Result__c : '';
						
							} else if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('CANAL A LA CARTE') || solic.ProductType__c.equalsIgnoreCase('TV A LA CARTE')){
								tks.result			= null;
								tks.resultReason	= null;
								tks.resultNotes		= null;
						
							} else if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('BL ASSINATURA') || solic.ProductType__c.equalsIgnoreCase('BL ADICIONAIS')){
								tks.result			= String.isNotBlank(caso.BLN1Result__c) ? caso.BLN1Result__c : '';
								tks.resultReason	= String.isNotBlank(caso.BLN2Result__c) ? caso.BLN2Result__c : '';
								tks.resultNotes		= String.isNotBlank(caso.BLN3Result__c) ? caso.BLN3Result__c : '';
						
							} else if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('NET FONE') || solic.ProductType__c.equalsIgnoreCase('NET ADICIONAIS')){
								tks.result			= String.isNotBlank(caso.PhoneN1Result__c) ? caso.PhoneN1Result__c : '';
								tks.resultReason	= String.isNotBlank(caso.PhoneN2Result__c) ? caso.PhoneN2Result__c : '';
								tks.resultNotes		= String.isNotBlank(caso.PhoneN3Result__c) ? caso.PhoneN3Result__c : '';

							} else if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('MOVEL ASSINATURA') || solic.ProductType__c.equalsIgnoreCase('MOVEL DEPENDENTES') || solic.ProductType__c.equalsIgnoreCase('MOVEL ADICIONAIS')){
								tks.result			= String.isNotBlank(caso.MobileN1Result__c) ? caso.MobileN1Result__c : '';
								tks.resultReason	= String.isNotBlank(caso.MobileN2Result__c) ? caso.MobileN2Result__c : '';
								tks.resultNotes		= String.isNotBlank(caso.MobileN3Result__c) ? caso.MobileN3Result__c : '';
							}
						 
							listTks.add( tks );
						}else if(solic.ProductType__c != NBA_Constants.MOVEL_ASSINATURA_RPA && solic.ProductType__c != NBA_Constants.MOVEL_DEPENDENTES) {
							if(solicMobile == null){
								dt.data.customer.rgIssueDate	= String.valueOf(solic.RGDate__c) != null ? String.valueOf(solic.RGDate__c) : '';
								dt.data.customer.rgIssuer		= String.valueOf(solic.RGEmitter__c) != null ? String.valueOf(solic.RGEmitter__c) : '';
							}	
							dt.data.customer.isComboMulti	= NBA_Constants.RPA_NAO;
							
							NBA_IntegrationModels.RPA_tasks tks	= new NBA_IntegrationModels.RPA_tasks();
							tks.taskId							= solic.Id;
							tks.solicitationType				= solic.SolicitationType__c != null ? solic.SolicitationType__c : '';
							tks.action							= solic.Movement__c != null ? solic.Movement__c : '';
							tks.city							= order.Contract.CityCode__c != null ? order.Contract.CityCode__c.leftPad(3, '0') : '';
							tks.salesmanUser					= mapUser.containsKey( order.OwnerId ) && mapUser.get( order.Ownerid ).NetServicos__c != null ? mapUser.get( order.Ownerid ).NetServicos__c + ' | ' + user.Claro__c : mapUser.get( order.Ownerid ).FederationIdentifier + ' | ' + user.Claro__c;
							tks.saleTypeId						= 'Padrão';
							tks.campaignId						= 'Padrão';
							tks.acquisitionType					= 'Padrão';
							tks.revokeType						= null;
							tks.revokeReason					= null;
							tks.paymentMethod					= String.isNotBlank(solic.PaymentMethod__c) && String.isNotBlank(solic.PromotionName__c) ? solic.PromotionName__c + ' * ' + solic.PaymentMethod__c :  String.isNotBlank(solic.PaymentMethod__c) ? solic.PaymentMethod__c : solic.PromotionName__c + ' * ISENTO'; 
							//tks.paymentMethod					= ( solic.PaymentMethod__c != null && String.isNotBlank(solic.PaymentMethod__c) ) ? solic.PromotionName__c + ' * ' + solic.PaymentMethod__c : solic.PromotionName__c + ' * ISENTO';														
							tks.channel							= 'Padrão';
							tks.targetProduct.name				= solic.LegacyNameProduct__c != null ? solic.LegacyNameProduct__c : '';
						
							if(solic.Movement__c == NBA_Constants.MOVIMENTO_AQUISICAO && (solic.ProductType__c == NBA_Constants.BL_ADICIONAIS || solic.ProductType__c == NBA_Constants.MOVEL_ADICIONAIS || solic.ProductType__c == NBA_Constants.TV_A_LA_CARTE || solic.ProductType__c == NBA_Constants.TV_PONTOS_ADICIONAIS)){
								tks.targetProduct.point			= solic.MainPoint__c;
							}else if(solic.Movement__c == NBA_Constants.MOVIMENTO_AQUISICAO && ( solic.ProductType__c == NBA_Constants.BL_ASSINATURA || solic.ProductType__c == NBA_Constants.NET_FONE )){
								tks.targetProduct.point			= String.isNotBlank(resultIsTv) ? resultIsTv : solic.MainPoint__c;
							}else {
								tks.targetProduct.point			= solic.CurrentProduct__c;
							}

							tks.targetProduct.currentMobileSubscriptionType = null;
							tks.targetProduct.discountDuration				= String.isNotBlank( solic.QuantityPromoMonths__c ) ? solic.QuantityPromoMonths__c : '0';
							tks.targetProduct.discountValue					= String.valueOf(solic.PromotionValue__c);
							tks.targetProduct.pointType						= solic.SpotType__c;
							tks.targetProduct.pricing						= String.valueOf(solic.TotalValue__c);
							tks.targetProduct.profile						= solic.ComboProfile__c != null ? solic.ComboProfile__c : null;
							tks.targetProduct.serialNumber					= solic.SerialNumber__c != null ? solic.SerialNumber__c : null;
							tks.targetProduct.technologyId					= solic.TechnologyType__c;
							tks.targetProduct.telephoneNumber				= null;
							tks.notes										= null;
							tks.targetProduct.isPortabilityRequest			= null;
							tks.targetProduct.mobileAdditionalServiceName	= null;
							tks.targetProduct.mobileAdditionalServiceType	= null;
							tks.targetProduct.mobileAppliedDiscount			= null;
							tks.targetProduct.mobileDataPlan				= null;
							tks.targetProduct.mobileDependentAmountToAdd	= null;
							tks.targetProduct.mobileOfferType				= null;
							tks.targetProduct.mobilePlanName				= null;
							tks.targetProduct.mobilePromotionalOffer		= null;
							tks.targetProduct.newMobileSubscriptionType		= null;
							tks.targetProduct.fidelityRenewalDate			= solic.RenewFidelity__c ? convertDatetimeToDate( order.CreatedDate ) : null;
							tks.targetProduct.fidelityExpirationDate		= solic.RenewFidelity__c ? convertDatetimeToDate( order.CreatedDate.addDays(365) ) : null;
							tks.targetProduct.msisdn						= solic.MSISDN__c;
							tks.fidelityPenaltyPrice						= solic.Penality_Price__c;
							tks.targetProduct.type							= solic.ProductType__c;
							tks.flagFidelityRenewal							= solic.RenewFidelity__c ? 'SIM' : 'NÃO';							
							tks.hasFidelity									= solic.Fidelity__c ? 'SIM' : 'NÃO';
							tks.targetProduct.pointId						= solic.pointId__c;
						
							if(solic.FeePrice__c != null && solic.FeePrice__c > 0){
								tks.fee.price						 =  String.valueOf(solic.FeePrice__c);
								//tks.fee.price						 = ( solic.PaymentMethod__c != null || String.isNotBlank(solic.PaymentMethod__c) ) ? String.valueOf(solic.FeePrice__c) + '|' + solic.PaymentMethod__c : String.valueOf(solic.FeePrice__c);
								tks.fee.type						 = solic.FeeType__c;
							}else {
								tks.fee.price						 = null;
								tks.fee.type						 = null;
							}

							String pType							 = solic.ProductType__c != null ? solic.ProductType__c : '';
						
							if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('TV PACOTE') || solic.ProductType__c.equalsIgnoreCase('TV PONTOS ADICIONAIS')){
								tks.result			= String.isNotBlank(caso.TVN1Result__c) ? caso.TVN1Result__c : '';
								tks.resultReason	= String.isNotBlank(caso.TVN2Result__c) ? caso.TVN2Result__c : '';
								tks.resultNotes		= String.isNotBlank(caso.TVN3Result__c) ? caso.TVN3Result__c : '';
						
							} else if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('CANAL A LA CARTE') || solic.ProductType__c.equalsIgnoreCase('TV A LA CARTE')){
								tks.result			= null;
								tks.resultReason	= null;
								tks.resultNotes		= null;
						
							} else if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('BL ASSINATURA') || solic.ProductType__c.equalsIgnoreCase('BL ADICIONAIS')){
								tks.result			= String.isNotBlank(caso.BLN1Result__c) ? caso.BLN1Result__c : '';
								tks.resultReason	= String.isNotBlank(caso.BLN2Result__c) ? caso.BLN2Result__c : '';
								tks.resultNotes		= String.isNotBlank(caso.BLN3Result__c) ? caso.BLN3Result__c : '';
						
							} else if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('NET FONE') || solic.ProductType__c.equalsIgnoreCase('NET ADICIONAIS')){
								tks.result			= String.isNotBlank(caso.PhoneN1Result__c) ? caso.PhoneN1Result__c : '';
								tks.resultReason	= String.isNotBlank(caso.PhoneN2Result__c) ? caso.PhoneN2Result__c : '';
								tks.resultNotes		= String.isNotBlank(caso.PhoneN3Result__c) ? caso.PhoneN3Result__c : '';

							} else if(solic.ProductType__c != null && solic.ProductType__c.equalsIgnoreCase('MOVEL ASSINATURA') || solic.ProductType__c.equalsIgnoreCase('MOVEL DEPENDENTES') || solic.ProductType__c.equalsIgnoreCase('MOVEL ADICIONAIS')){
								tks.result			= String.isNotBlank(caso.MobileN1Result__c) ? caso.MobileN1Result__c : '';
								tks.resultReason	= String.isNotBlank(caso.MobileN2Result__c) ? caso.MobileN2Result__c : '';
								tks.resultNotes		= String.isNotBlank(caso.MobileN3Result__c) ? caso.MobileN3Result__c : '';
							}
							listTks.add( tks );
						}
					}
				
					dt.data.tasks = listTks;
					
				} else if(strMoviment == 'Total'){
					dt.data.customer.profile					= null;
					dt.data.customer.isComboMulti				= NBA_Constants.RPA_NAO;
					for(Solic_NBA__c solic : getSolics( order.Id )){
						
						Boolean tipoTv							= ( solic.ProductType__c == NBA_Constants.PONTOS_OPCIONAIS || solic.ProductType__c == NBA_Constants.TV_PACOTE) ? true : false;
						
						dt.data.toComboMulti					= NBA_Constants.RPA_NAO;
						dt.data.customer.mobileDependentAmount	= String.valueOf(solic.NumberDep__c) != null ? String.valueOf(solic.NumberDep__c) : '0';
						if(solicMobile == null){
							dt.data.customer.rgIssueDate			= String.valueOf(solic.RGDate__c) != null ? String.valueOf(solic.RGDate__c) : '';
							dt.data.customer.rgIssuer				= String.valueOf(solic.RGEmitter__c) != null ? String.valueOf(solic.RGEmitter__c) : '';
						}
						NBA_IntegrationModels.RPA_tasks tks		= new NBA_IntegrationModels.RPA_tasks();
						tks.taskId								= solic.Id;
						tks.solicitationType					= null;
						tks.action								= solic.Movement__c != null ? solic.Movement__c : '';
						tks.city								= order.Contract.CityCode__c != null ? order.Contract.CityCode__c.leftPad(3, '0') : '';
						tks.salesmanUser						= mapUser.containsKey( order.OwnerId ) && mapUser.get( order.Ownerid ).NetServicos__c != null ? mapUser.get( order.Ownerid ).NetServicos__c + ' | ' + user.Claro__c : mapUser.get( order.Ownerid ).FederationIdentifier + ' | ' + user.Claro__c;
						tks.saleTypeId							= 'Padrão';
						tks.campaignId							= 'Padrão';
						tks.acquisitionType						= 'Padrão';
						tks.revokeType							= 'Total';
						
						if(String.isNotBlank(caso.CallReason__c) && caso.CallReason__c.equalsIgnoreCase('Inadimplente')){
							tks.revokeReason	= 'Inadimplente';
						}else {
							tks.revokeReason	= 'Opção';
						}
						tks.paymentMethod		= null;
						tks.channel				= 'Padrão';
						
						tks.targetProduct.name				= null;

						if(solic.ProductType__c	!= NBA_Constants.TV_A_LA_CARTE){
							tks.targetProduct.point			= solic.CurrentProduct__c;
						}else{
							tks.targetProduct.point			= null;
						}

						tks.targetProduct.currentMobileSubscriptionType = null;
						tks.targetProduct.discountDuration				= null;
						tks.targetProduct.discountValue					= null;
						tks.targetProduct.point							= solic.CurrentProduct__c;
						tks.targetProduct.pointType						= solic.SpotType__c;
						tks.targetProduct.pricing						= null;
						tks.targetProduct.profile						= null;
						tks.targetProduct.serialNumber					= null;
						tks.targetProduct.technologyId					= null;
						tks.targetProduct.telephoneNumber				= null;
						tks.notes										= null;
						tks.targetProduct.isPortabilityRequest			= null;
						tks.targetProduct.mobileDataPlan				= null;
						tks.targetProduct.mobileAdditionalServiceName	= null;
						tks.targetProduct.mobileAdditionalServiceType	= null;
						tks.targetProduct.mobileAppliedDiscount			= null;
						tks.targetProduct.mobileDependentAmountToAdd	= null;
						tks.targetProduct.mobileOfferType				= null;
						tks.targetProduct.mobilePlanName				= null;
						tks.targetProduct.mobilePromotionalOffer		= null;
						tks.targetProduct.name							= null;
						tks.targetProduct.newMobileSubscriptionType		= null;
						tks.flagFidelityRenewal							= null;
						tks.targetProduct.fidelityRenewalDate			= null;
						tks.targetProduct.fidelityExpirationDate		= null;
						tks.targetProduct.msisdn						= solic.MSISDN__c;
						tks.fidelityPenaltyPrice						= solic.Penality_Price__c;
						tks.targetProduct.type							= solic.ProductType__c;
						tks.hasFidelity									= solic.Fidelity__c ? 'SIM' : 'NÃO';
						tks.fee.type									= null;
						tks.fee.price									= null;
						tks.targetProduct.pointId						= solic.pointId__c;

						if(String.isNotBlank(caso.TVN1Result__c) && caso.TVN1Result__c.equalsIgnoreCase('NÃO RETIDO')){
							tks.result								 = caso.TVN1Result__c;
							tks.resultReason						 = String.isNotBlank(caso.TVN2Result__c) ? caso.TVN2Result__c : '';
							tks.resultNotes							 = String.isNotBlank(caso.TVN3Result__c) ? caso.TVN3Result__c : '';

						}else if(String.isNotBlank(caso.BLN1Result__c) && caso.BLN1Result__c.equalsIgnoreCase('NÃO RETIDO')){
							tks.result								 = caso.BLN1Result__c;
							tks.resultReason						 = String.isNotBlank(caso.BLN2Result__c) ? caso.BLN2Result__c : '';
							tks.resultNotes							 = String.isNotBlank(caso.BLN3Result__c) ? caso.BLN3Result__c : '';
						
						} else if(String.isNotBlank(caso.PhoneN1Result__c) && caso.PhoneN1Result__c.equalsIgnoreCase('NÃO RETIDO')){
							tks.result								 = caso.PhoneN1Result__c;
							tks.resultReason						 = String.isNotBlank(caso.PhoneN2Result__c) ? caso.PhoneN2Result__c : '';
							tks.resultNotes							 = String.isNotBlank(caso.PhoneN3Result__c) ? caso.PhoneN3Result__c : '';
						
						} else {
							tks.result								 = null;
							tks.resultReason						 = null;
							tks.resultNotes							 = null;
						}

						listTks.add( tks );
						
						dt.data.penaltyPrice =  String.valueOf(solic.PenaltyPrice__c) != null ? String.valueOf( solic.PenaltyPrice__c.setScale(2) ) : '0.00';
						break;
					}

					dt.data.tasks	= listTks;
				}

				//ATRIBUIÇÃO DE DEPENDENTE MÓVEL DEFAULT
				for(NBA_IntegrationModels.RPA_tasks tk : dt.data.tasks){
					NBA_IntegrationModels.RPA_MobileDependent dep		= new NBA_IntegrationModels.RPA_MobileDependent(); 
					dep.action											= null;
					dep.appliedDiscount									= null;
					dep.offerType										= null;
					dep.isPortabilityRequest							= null;
					dep.msisdn											= null;
					dep.profile											= null;
					tk.targetProduct.mobileDependent.add( dep );
				}

				// VALIDAÇÃO DE OFERTA
				dt.data.subscriberId = order.subscriberId__c;
                if(String.isNotBlank(order.OfferValidationRequest__c)){
					dt.data.promotionValidationPayload = (Map<String, Object>) JSON.deserializeUntyped(order.OfferValidationRequest__c);
					if(order.SchedulingDate__c!=null && order.SchedulingTime__c!=null){
						Map<String, Object> scheduling = new Map<String, Object> ();
						scheduling.put('date', String.ValueOf(order.SchedulingDate__c) + 'T' + order.SchedulingTime__c.substring(0, 8) + 'Z');
						dt.data.promotionValidationPayload.put('scheduling', scheduling);
					}
				}
				dt.data.customer.pointsQuantity = getPointsQuantity(order.Id);
				
				//MOVEL
				dt = createTaskMovel(getSolics( order.Id ), dt, order, caso, user, mapUser);
				System.debug('[REQUEST JSON] ---> ' + JSON.serialize( dt ));
				return dt;
			}else {
				System.debug('ORDER NÃO LOCALIZADA!');
			}
		}
		return null;
	}

	public static String getPointsQuantity(Id orderId){
		AggregateResult CountPointsQuantity = [
			SELECT 	COUNT(Id) qtd 
			FROM 	Solic_NBA__c 
			WHERE 	Order__c = :orderId AND 
					Movement__c != :NBA_Constants.MOVIMENTO_AQUISICAO AND (
						ProductType__c = :NBA_Constants.TV_PACOTE OR
						ProductType__c = :NBA_Constants.TV_PONTOS_ADICIONAIS OR
						ProductType__c = :NBA_Constants.PONTOS_OPCIONAIS
					)
		];
		return String.valueOf(CountPointsQuantity.get('qtd'));
	}
	
	public static NBA_IntegrationModels.RPA_Data createTaskMovel(List<Solic_NBA__c> lstSolic, NBA_IntegrationModels.RPA_Data dt, Order order, Case caso, User user, Map<String, User> mapUser){		
		//GET TITULAR MOVEL COMO MOVIMENTAÇÃO
		Solic_NBA__c solicTitularMovel;
		Boolean hasTitularOrDep							= false;
		Boolean hasDependente							= false;
		List<Solic_NBA__c> lstMovelDep					= new List<Solic_NBA__c>();
		List<NBA_IntegrationModels.RPA_tasks> lstTask	= new List<NBA_IntegrationModels.RPA_tasks>();

		for(Solic_NBA__c solic : lstSolic){
			if(solic.ProductType__c == NBA_Constants.MOVEL_ASSINATURA_RPA){
				solicTitularMovel = solic;
				hasTitularOrDep = true;
			}else if(solic.ProductType__c == NBA_Constants.MOVEL_DEPENDENTES){
				lstMovelDep.add( solic );
				hasDependente = true;
			}
		}

		//GET TITULAR SEM MOVIMENTAÇÃO (OBS: LATERAL)
		if(solicTitularMovel == null){
			List<Solic_NBA__c> lstSolicTitular = [SELECT 
											Message__c, Order__c, Asset__c, Status__c, ProductName__c, CurrentProduct__c, Value__c, FeeType__c, FeePrice__c,
											LegacyNameProduct__c, ComboProfile__c, SerialNumber__c, PaymentMethod__c, RenewFidelity__c, FullCancel__c,
											TechnologyType__c, Movement__c, SolicitationType__c, ProductType__c, PenaltyPrice__c, OfferType__c, Fidelity__c,
											AcceptedOffer__c, Priority__c, Family__c, PromotionName__c, Name, CurrentPlan__c, MobilePlan__c, Portability__c,
											QuantityPromoMonths__c, PromotionValue__c, SpotType__c, Penality_Price__c, Id, MainPoint__c, MSISDN__c, DependentProfile__c, IsComboMulti__c,
											RGDate__c, RGEmitter__c, MothersName__c, NumberDep__c, DataPlan__c, MobileName__c, TotalValue__c
								  FROM Solic_NBA__c WHERE Order__c = :order.Id AND ProductType__c = :NBA_Constants.MOVEL_ASSINATURA_RPA];
			if(lstSolicTitular != null && !lstSolicTitular.isEmpty()){
				solicTitularMovel = lstSolicTitular.get(0);
				hasTitularOrDep = true;
			}
		}

		//REGRA PARA MUDANÇA DE PACOTE
		Boolean hasMudancaPacote	= false;
		if(solicTitularMovel != null && !solicTitularMovel.IsComboMulti__c && solicTitularMovel.CurrentPlan__c == solicTitularMovel.MobilePlan__c){
			hasMudancaPacote		= true; 
		}

		//COUNT TOTAL DE DEPENDNETE COM MOVIMENTO DE AQUISIÇÃO.
		List<Solic_NBA__c> lstSolicDep			= [SELECT Id FROM Solic_NBA__c  WHERE Order__c = :order.Id AND ProductType__c = :NBA_Constants.MOVEL_DEPENDENTES AND Movement__c = :NBA_Constants.MOVIMENTO_AQUISICAO];
		List<Solic_NBA__c> lstSolicDepCancel	= [SELECT Id FROM Solic_NBA__c  WHERE Order__c = :order.Id AND ProductType__c = :NBA_Constants.MOVEL_DEPENDENTES AND Movement__c = :NBA_Constants.MOVIMENTO_CANCELAMENTO];
		
		if(hasTitularOrDep){
			dt.data.customer.isComboMulti			= solicTitularMovel.IsComboMulti__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
			
			if(solicTitularMovel.Movement__c == NBA_Constants.MOVIMENTO_AQUISICAO && String.isNotBlank(solicTitularMovel.Status__c)){
				dt.data.customer.hasMobileProduct = NBA_Constants.RPA_NAO;
			}else{				
				dt.data.customer.hasMobileProduct = NBA_Constants.RPA_SIM;
			}

			//AQUISIÇÃO DE MOVEL TITULAR
			if(solicTitularMovel.Movement__c == NBA_Constants.MOVIMENTO_AQUISICAO && String.isNotBlank(solicTitularMovel.Status__c)){ //AQUISIÇÃO
				dt.data.toComboMulti							= NBA_Constants.RPA_SIM;
				
				NBA_IntegrationModels.RPA_tasks tks				= new NBA_IntegrationModels.RPA_tasks();
				tks.acquisitionType								= null;
				tks.action										= solicTitularMovel.Movement__c != null ? solicTitularMovel.Movement__c : '';
				tks.campaignId									= null;
				tks.channel										= null;
				tks.city										= order.Contract.CityCode__c != null ? order.Contract.CityCode__c.leftPad(3, '0') : '';
				tks.fee.price									= null;
				tks.fee.type									= null;
				tks.fidelityPenaltyPrice						= String.valueOf(solicTitularMovel.PenaltyPrice__c) != null ? String.valueOf(solicTitularMovel.PenaltyPrice__c) : '0.00';
				tks.flagFidelityRenewal							= null;
				tks.hasFidelity									= solicTitularMovel.RenewFidelity__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
				tks.notes										= null;
				tks.paymentMethod								= null;
				tks.result			                            = String.isNotBlank(caso.MobileN1Result__c) ? caso.MobileN1Result__c : '';
				tks.resultReason	                            = String.isNotBlank(caso.MobileN2Result__c) ? caso.MobileN2Result__c : '';
				tks.resultNotes		                            = String.isNotBlank(caso.MobileN3Result__c) ? caso.MobileN3Result__c : '';
				tks.revokeReason					            = null;
				tks.revokeType						            = null;
				tks.salesmanUser								= mapUser.containsKey( order.OwnerId ) && mapUser.get( order.Ownerid ).NetServicos__c != null ? mapUser.get( order.Ownerid ).NetServicos__c + ' | ' + user.Claro__c : mapUser.get( order.Ownerid ).FederationIdentifier + ' | ' + user.Claro__c;
				tks.saleTypeId						            = null;
				tks.solicitationType				            = solicTitularMovel.SolicitationType__c != null ? solicTitularMovel.SolicitationType__c : '';
				tks.targetProduct.currentMobileSubscriptionType = null;
				tks.targetProduct.discountDuration              = String.valueOf(solicTitularMovel.QuantityPromoMonths__c) != null ? String.valueOf(solicTitularMovel.QuantityPromoMonths__c) : '0';
				tks.targetProduct.discountValue					= String.valueOf(solicTitularMovel.PromotionValue__c);
				tks.targetProduct.fidelityExpirationDate        = solicTitularMovel.RenewFidelity__c ? convertDatetimeToDate( order.CreatedDate.addDays(365) ) : null;
				tks.targetProduct.fidelityRenewalDate           = solicTitularMovel.RenewFidelity__c ? convertDatetimeToDate( order.CreatedDate ) : null;
				tks.targetProduct.isPortabilityRequest          = solicTitularMovel.Portability__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
				tks.targetProduct.mobileAdditionalServiceName   = null;
				tks.targetProduct.mobileAdditionalServiceType   = null;
				tks.targetProduct.mobileAppliedDiscount         = '';
				tks.targetProduct.mobileOfferType               = '';
				tks.targetProduct.mobileDataPlan                = null;
				tks.targetProduct.mobilePlanName                = null;
				tks.targetProduct.mobilePromotionalOffer        = solicTitularMovel.PromotionName__c;
				tks.targetProduct.msisdn                        = solicTitularMovel.MSISDN__c != null ? solicTitularMovel.MSISDN__c : '';
				tks.targetProduct.name				            = solicTitularMovel.LegacyNameProduct__c != null ? solicTitularMovel.LegacyNameProduct__c : '';
				tks.targetProduct.newMobileSubscriptionType		= null;
				tks.targetProduct.point				            = null;							
				tks.targetProduct.pointType						= null;
				tks.targetProduct.pricing						= String.valueOf(solicTitularMovel.TotalValue__c);
				tks.targetProduct.profile						= solicTitularMovel.ComboProfile__c != null ? solicTitularMovel.ComboProfile__c : '';
				tks.targetProduct.serialNumber					= null;
				tks.targetProduct.technologyId					= null;
				tks.targetProduct.telephoneNumber				= null;
				tks.targetProduct.type                          = solicTitularMovel.ProductType__c != null ? solicTitularMovel.ProductType__c : '';
				tks.taskId										= solicTitularMovel.Id;
				tks.targetProduct.pointId 						= solicTitularMovel.pointId__c;

				if(!lstMovelDep.isEmpty()){
					//CHECK DEP. MOVEL
					for(Solic_NBA__c solicDep : lstMovelDep){
						if(solicDep.Movement__c == NBA_Constants.MOVIMENTO_AQUISICAO){
						NBA_IntegrationModels.RPA_MobileDependent dep	= new NBA_IntegrationModels.RPA_MobileDependent(); 
							dep.action									= solicDep.Movement__c;
							dep.appliedDiscount							= '';
							dep.offerType								= '';
							dep.isPortabilityRequest					= solicDep.Portability__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
							dep.msisdn									= solicDep.MSISDN__c != null ? solicDep.MSISDN__c : '';
							dep.profile									= solicDep.LegacyNameProduct__c;
						tks.targetProduct.mobileDependent.add( dep );
					}

				}
				}
				tks.targetProduct.mobileDependentAmountToAdd = String.valueOf(tks.targetProduct.mobileDependent.size());
				dt.data.customer.mobileDependentAmount	= tks.targetProduct.mobileDependentAmountToAdd;

				//BONUS AND DISCOUNT
				lstTask.addAll(
						getTaskBonusDiscountWithDependent(lstMovelDep,order,caso, mapUser, isHasTvPacote(order.Id),
								lstMovelDep != null ? String.valueOf( lstMovelDep.size() ) : '0')
				);
				lstTask.addAll(
						getTaskBonusDiscountForMovel(solicTitularMovel, order,caso, mapUser, isHasTvPacote(order.Id),
										 	 lstMovelDep != null ? String.valueOf( lstMovelDep.size() ) : '0')
				);

				lstTask.add( tks );
			}
			else if(solicTitularMovel.Movement__c == NBA_Constants.MOVIMENTO_UPGRADE || solicTitularMovel.Movement__c == NBA_Constants.MOVIMENTO_DOWNGRADE || (solicTitularMovel.Movement__c == NBA_Constants.MOVIMENTO_LATERAL && String.isNotBlank(solicTitularMovel.SolicitationType__c))){ //UPGRADE | DOWNGRAD | LATERAL COM MOVIMENTAÇÃO
				dt.data.toComboMulti							= NBA_Constants.RPA_SIM;
				
				NBA_IntegrationModels.RPA_tasks tks				= new NBA_IntegrationModels.RPA_tasks();
				tks.acquisitionType								= null;
				tks.action										= solicTitularMovel.Movement__c != null ? solicTitularMovel.Movement__c : '';
				tks.campaignId									= null;
				tks.channel										= null;
				tks.city										= order.Contract.CityCode__c != null ? order.Contract.CityCode__c.leftPad(3, '0') : '';
				tks.fee.price									= null;
				tks.fee.type									= null;
				tks.fidelityPenaltyPrice						= String.valueOf(solicTitularMovel.PenaltyPrice__c) != null ? String.valueOf(solicTitularMovel.PenaltyPrice__c) : '0.00';
				tks.flagFidelityRenewal							= solicTitularMovel.RenewFidelity__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
				tks.hasFidelity									= solicTitularMovel.Fidelity__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
				tks.notes										= null;
				tks.paymentMethod								= null;
				tks.result			                            = String.isNotBlank(caso.MobileN1Result__c) ? caso.MobileN1Result__c : '';
				tks.resultReason	                            = String.isNotBlank(caso.MobileN2Result__c) ? caso.MobileN2Result__c : '';
				tks.resultNotes		                            = String.isNotBlank(caso.MobileN3Result__c) ? caso.MobileN3Result__c : '';
				tks.revokeReason					            = null;
				tks.revokeType						            = null;
				tks.salesmanUser					            = mapUser.containsKey( order.OwnerId ) && mapUser.get( order.Ownerid ).NetServicos__c != null ? mapUser.get( order.Ownerid ).NetServicos__c + ' | ' + user.Claro__c : mapUser.get( order.Ownerid ).FederationIdentifier + ' | ' + user.Claro__c;
				tks.saleTypeId						            = null;
				tks.solicitationType				            = (solicTitularMovel.Movement__c == NBA_Constants.MOVIMENTO_LATERAL && String.isBlank(solicTitularMovel.SolicitationType__c)) ? NBA_Constants.SOLICITATION_TYPE_DEP : solicTitularMovel.SolicitationType__c;
				tks.targetProduct.discountValue					= String.valueOf(solicTitularMovel.PromotionValue__c);
				tks.targetProduct.fidelityExpirationDate        = solicTitularMovel.RenewFidelity__c ? convertDatetimeToDate( order.CreatedDate.addDays(365) ) : null;
				tks.targetProduct.fidelityRenewalDate           = solicTitularMovel.RenewFidelity__c ? convertDatetimeToDate( order.CreatedDate ) : null;
				tks.targetProduct.isPortabilityRequest          = solicTitularMovel.Portability__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
				tks.targetProduct.mobileAdditionalServiceName   = null;
				tks.targetProduct.mobileAdditionalServiceType   = null;
				tks.targetProduct.mobileAppliedDiscount         = '';
				tks.targetProduct.mobileOfferType               = '';
				tks.targetProduct.mobileDependentAmountToAdd    = '0'; 
				tks.targetProduct.mobilePromotionalOffer        = solicTitularMovel.PromotionName__c;
				tks.targetProduct.msisdn                        = solicTitularMovel.MSISDN__c != null ? solicTitularMovel.MSISDN__c : '';
				tks.targetProduct.currentMobileSubscriptionType = String.isNotBlank( solicTitularMovel.CurrentPlan__c ) ? solicTitularMovel.CurrentPlan__c : '';
				tks.targetProduct.discountDuration              = String.isNotBlank( solicTitularMovel.QuantityPromoMonths__c ) ? solicTitularMovel.QuantityPromoMonths__c : '0';
				tks.targetProduct.mobileDataPlan                = String.isNotBlank( solicTitularMovel.DataPlan__c ) ? solicTitularMovel.DataPlan__c : '';
				tks.targetProduct.mobilePlanName                = String.isNotBlank( solicTitularMovel.MobilePlan__c ) ? solicTitularMovel.MobilePlan__c : ''; // String.isNotBlank( solicTitularMovel.MobileName__c ) ? solicTitularMovel.MobileName__c : '';
				tks.targetProduct.name				            = String.isNotBlank( solicTitularMovel.LegacyNameProduct__c ) ? solicTitularMovel.LegacyNameProduct__c : '';
				tks.targetProduct.newMobileSubscriptionType		= solicTitularMovel.TechnologyType__c; // String.isNotBlank( solicTitularMovel.MobilePlan__c ) ? solicTitularMovel.MobilePlan__c : '';
				tks.targetProduct.point				            = solicTitularMovel.CurrentProduct__c != null ? solicTitularMovel.CurrentProduct__c : '';							
				tks.targetProduct.pointType						= null;
				tks.targetProduct.pricing						= String.valueOf(solicTitularMovel.TotalValue__c);
				tks.targetProduct.profile						= solicTitularMovel.ComboProfile__c != null ? solicTitularMovel.ComboProfile__c : '';
				tks.targetProduct.serialNumber					= null;
				tks.targetProduct.technologyId					= null; 
				tks.targetProduct.telephoneNumber				= null;
				tks.targetProduct.type                          = solicTitularMovel.ProductType__c != null ? solicTitularMovel.ProductType__c : '';
				tks.taskId										= solicTitularMovel.Id;
				tks.action										= solicTitularMovel.Movement__c;
				tks.targetProduct.pointId 						= solicTitularMovel.pointId__c;

				if(!lstMovelDep.isEmpty()){
					Map<String, NBA_IntegrationModels.RPA_tasks> dependentsByMovement = new Map<String, NBA_IntegrationModels.RPA_tasks>();

					for(Solic_NBA__c solicDep : getDependente(order.Id)){
						if(!dependentsByMovement.containsKey(solicDep.Movement__c)){
							dependentsByMovement.put(solicDep.Movement__c, new NBA_IntegrationModels.RPA_tasks());
							if(solicDep.Movement__c==NBA_Constants.MOVIMENTO_AQUISICAO) 
								dependentsByMovement.get(solicDep.Movement__c).solicitationType = solicDep.SolicitationType__c;
				}

						NBA_IntegrationModels.RPA_MobileDependent dep	= new NBA_IntegrationModels.RPA_MobileDependent(); 
						dep.action										= solicDep.Movement__c;
							dep.offerType								= '';					
							dep.appliedDiscount							= '';							
							dep.isPortabilityRequest					= solicDep.Portability__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
							dep.msisdn									= solicDep.MSISDN__c != null ? solicDep.MSISDN__c : '';
						dep.profile										= solicDep.LegacyNameProduct__c; //solicDep.DependentProfile__c;
						
						dependentsByMovement.get(solicDep.Movement__c).targetProduct.mobileDependent.add(dep);
					}
					for(NBA_IntegrationModels.RPA_tasks dependentTask : dependentsByMovement.values())
						dependentTask.targetProduct.mobileDependentAmountToAdd = String.valueOf(dependentTask.targetProduct.mobileDependent.size());
					
					dt.data.customer.mobileDependentAmount = dependentsByMovement.containsKey(NBA_Constants.MOVIMENTO_AQUISICAO) ? dependentsByMovement.get(NBA_Constants.MOVIMENTO_AQUISICAO).targetProduct.mobileDependentAmountToAdd : '0';
					lstTask.addAll(dependentsByMovement.values());
						}

				//BONUS AND DISCOUNT
				lstTask.addAll(
						getTaskBonusDiscountWithDependent(lstMovelDep,order,caso, mapUser, isHasTvPacote(order.Id),
								lstMovelDep != null ? String.valueOf( lstMovelDep.size() ) : '0')
				);
				lstTask.addAll(
						getTaskBonusDiscountForMovel(solicTitularMovel, order,caso, mapUser, isHasTvPacote(order.Id),
								lstMovelDep != null ? String.valueOf( lstMovelDep.size() ) : '0')
				);

				lstTask.add( tks );
			}
			else if(solicTitularMovel.Movement__c == NBA_Constants.MOVIMENTO_CANCELAMENTO && String.isNotBlank(solicTitularMovel.Status__c)){ //CANCELAMENTO
				dt.data.toComboMulti							= NBA_Constants.RPA_NAO;
				dt.data.customer.mobileDependentAmount			= String.valueOf(solicTitularMovel.NumberDep__c) != null ? String.valueOf(solicTitularMovel.NumberDep__c) : '0';
				
				NBA_IntegrationModels.RPA_tasks tks				= new NBA_IntegrationModels.RPA_tasks();
				tks.acquisitionType								= null;
				tks.action										= solicTitularMovel.Movement__c != null ? solicTitularMovel.Movement__c : '';
				tks.campaignId									= null;
				tks.channel										= null;
				tks.city										= order.Contract.CityCode__c != null ? order.Contract.CityCode__c.leftPad(3, '0') : '';
				tks.fee.price									= null;
				tks.fee.type									= null;
				tks.fidelityPenaltyPrice						= String.valueOf(solicTitularMovel.PenaltyPrice__c) != null ? String.valueOf(solicTitularMovel.PenaltyPrice__c) : '0.00';
				tks.flagFidelityRenewal							= solicTitularMovel.RenewFidelity__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
				tks.hasFidelity									= solicTitularMovel.Fidelity__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
				tks.notes										= null;
				tks.paymentMethod								= null;
				tks.result			                            = String.isNotBlank(caso.MobileN1Result__c) ? caso.MobileN1Result__c : '';
				tks.resultReason	                            = String.isNotBlank(caso.MobileN2Result__c) ? caso.MobileN2Result__c : '';
				tks.resultNotes		                            = String.isNotBlank(caso.MobileN3Result__c) ? caso.MobileN3Result__c : '';
				tks.revokeReason					            = NBA_Constants.RPA_OPCAO;
				tks.revokeType						            = NBA_Constants.RPA_PARCIAL;
				tks.salesmanUser					            = mapUser.containsKey( order.OwnerId ) && mapUser.get( order.Ownerid ).NetServicos__c != null ? mapUser.get( order.Ownerid ).NetServicos__c + ' | ' + user.Claro__c : mapUser.get( order.Ownerid ).FederationIdentifier + ' | ' + user.Claro__c;
				tks.saleTypeId						            = null;
				tks.solicitationType				            = null;
				tks.targetProduct.currentMobileSubscriptionType = solicTitularMovel.CurrentPlan__c;
				tks.targetProduct.discountDuration              = null;
				tks.targetProduct.discountValue					= null;
				tks.targetProduct.fidelityExpirationDate        = null;
				tks.targetProduct.fidelityRenewalDate           = null;
				tks.targetProduct.isPortabilityRequest          = solicTitularMovel.Portability__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
				tks.targetProduct.mobileAdditionalServiceName   = null;
				tks.targetProduct.mobileAdditionalServiceType   = null;
				tks.targetProduct.mobileAppliedDiscount         = '';
				tks.targetProduct.mobileOfferType               = ''; 
				tks.targetProduct.mobileDataPlan                = null;
				tks.targetProduct.mobileDependentAmountToAdd    = null; 
				tks.targetProduct.mobilePlanName                = null;
				tks.targetProduct.mobilePromotionalOffer        = null;
				tks.targetProduct.msisdn                        = solicTitularMovel.MSISDN__c != null ? solicTitularMovel.MSISDN__c : '';
				tks.targetProduct.name				            = null;
				tks.targetProduct.newMobileSubscriptionType		= null;
				tks.targetProduct.point				            = solicTitularMovel.CurrentProduct__c != null ? solicTitularMovel.CurrentProduct__c : '';							
				tks.targetProduct.pointType						= null;
				tks.targetProduct.pricing						= null;
				tks.targetProduct.profile						= solicTitularMovel.ComboProfile__c != null ? solicTitularMovel.ComboProfile__c : '';
				tks.targetProduct.serialNumber					= null;
				tks.targetProduct.technologyId					= null; //tipoTv ? 
				tks.targetProduct.telephoneNumber				= null;
				tks.targetProduct.type                          = solicTitularMovel.ProductType__c != null ? solicTitularMovel.ProductType__c : '';
				tks.taskId										= solicTitularMovel.Id;
				tks.targetProduct.pointId 						= solicTitularMovel.pointId__c;

				if(lstMovelDep.isEmpty()){	
					NBA_IntegrationModels.RPA_MobileDependent dep	= new NBA_IntegrationModels.RPA_MobileDependent(); 
					dep.action										= null;
					dep.appliedDiscount								= '';
					dep.offerType									= '';
					dep.isPortabilityRequest						= null;
					dep.msisdn										= null;
					dep.profile										= null;
					tks.targetProduct.mobileDependent.add( dep );
				}else {
					//CHECK DEP MOVIMENT	
					for(Solic_NBA__c solicDep : lstMovelDep){
						NBA_IntegrationModels.RPA_MobileDependent dep	= new NBA_IntegrationModels.RPA_MobileDependent(); 
						dep.action										= solicDep.Movement__c;
						dep.appliedDiscount								= '';
						dep.offerType									= '';
						dep.isPortabilityRequest						= null;
						dep.msisdn										= solicDep.MSISDN__c;
						dep.profile										= null;
						tks.targetProduct.mobileDependent.add( dep );
					}
				}
				lstTask.add( tks );
			}
			if(solicTitularMovel.Movement__c == NBA_Constants.MOVIMENTO_LATERAL){
				dt.data.toComboMulti			= NBA_Constants.RPA_SIM;
			}
		}
		else if(!hasTitularOrDep && hasDependente){ //LATERAL SEM MOVIMENTAÇÃO
			
			NBA_IntegrationModels.RPA_tasks tks				= new NBA_IntegrationModels.RPA_tasks();

			//CHECK DEP. MOVEL	
			for(Solic_NBA__c solicDep : lstMovelDep){
				NBA_IntegrationModels.RPA_MobileDependent dep	= new NBA_IntegrationModels.RPA_MobileDependent(); 
				dep.action										= solicDep.Movement__c;
				dep.offerType									= '';					
				dep.appliedDiscount								= '';							
				dep.isPortabilityRequest						= solicDep.Portability__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
				dep.msisdn										= solicDep.MSISDN__c != null ? solicDep.MSISDN__c : '';
				dep.profile										= solicDep.DependentProfile__c;
				tks.targetProduct.mobileDependent.add( dep );
			}
			lstTask.add( tks );
		}
		else{
			dt.data.customer.hasMobileProduct	= NBA_Constants.RPA_NAO;
			dt.data.customer.isComboMulti		= NBA_Constants.RPA_NAO;
			dt.data.toComboMulti				= NBA_Constants.RPA_NAO;
			
			NBA_IntegrationModels.RPA_MobileDependent dep	= new NBA_IntegrationModels.RPA_MobileDependent(); 
			dep.action										= null;
			dep.appliedDiscount								= null;
			dep.offerType									= null;
			dep.isPortabilityRequest						= null;
			dep.msisdn										= null;
			dep.profile										= null;
		}
		
		dt.data.tasks.addAll(lstTask);
		return dt;
	}

	public static void updateStatusSolic(NBA_IntegrationUtils.HttpResponseModel res, String idOrder){
		List<Solic_NBA__c> listSolicUpdate = new List<Solic_NBA__c>();
		if(res.success){
			for(Solic_NBA__c solic : [SELECT Id, Status__c FROM Solic_NBA__c WHERE Order__c = :idOrder AND ( Status__c = 'Em aberto' OR Status__c = 'Não enviado' OR Status__c = 'Erro' ) ]){
				solic.Status__c	   = 'Em processamento';
				listSolicUpdate.add( solic );
			}
		}else {
			for(Solic_NBA__c solic : [SELECT Id, Status__c FROM Solic_NBA__c WHERE Order__c = :idOrder AND Status__c = 'Em aberto']){
				solic.Status__c	   = 'Não enviado';
				listSolicUpdate.add( solic );
			}
		}
		update listSolicUpdate;
	}

	public static List<Solic_NBA__c> getDependente(String orderId){
		return [SELECT Id, Portability__c, Movement__c, MSISDN__c, Order__c, DependentProfile__c, SolicitationType__c, LegacyNameProduct__c, ProductName__c  FROM Solic_NBA__c WHERE Order__c = :orderId AND ProductType__c = :NBA_Constants.MOVEL_DEPENDENTES];
	}

	public static String getRPAMovement(List<Solic_NBA__c> listSolic){
		Integer counMovement			= 0;
		String result					= '';
		if(listSolic != null && !listSolic.isEmpty()){
			for(Solic_NBA__c solic : listSolic){
				if((solic.Movement__c == 'Cancelamento' && solic.FullCancel__c) || counMovement==999){
					counMovement = 999;
				}else if(solic.Movement__c == 'Cancelamento'){
					counMovement += 1;
				}
			}

			if(counMovement == 999){
				result = 'Total';
			}else if(counMovement > 0 && counMovement <= listSolic.size()){
				result = 'Parcial';
			}else {
				result = 'N/A';
			}
		}
		return result;
	}

	public static List<Solic_NBA__c> getSolics(String idOrder){
		List<Solic_NBA__c> listSolic = new List<Solic_NBA__c>();
		for(Solic_NBA__c solic : [SELECT 
											Message__c, Order__c, Asset__c, Status__c, ProductName__c, CurrentProduct__c, Value__c, FeeType__c, FeePrice__c,
											LegacyNameProduct__c, ComboProfile__c, SerialNumber__c, PaymentMethod__c, RenewFidelity__c, FullCancel__c,
											TechnologyType__c, Movement__c, SolicitationType__c, ProductType__c, PenaltyPrice__c, OfferType__c, Fidelity__c,
											AcceptedOffer__c, Priority__c, Family__c, PromotionName__c, Name, CurrentPlan__c, MobilePlan__c, QuantityPromoMonths__c, 
											PromotionValue__c, SpotType__c, Penality_Price__c, Id, MainPoint__c, Portability__c, MSISDN__c, DependentProfile__c, IsComboMulti__c,
											RGDate__c, RGEmitter__c, MothersName__c, NumberDep__c, DataPlan__c, MobileName__c, TotalValue__c, Bonus__c, Discount__c, pointId__c
								  FROM Solic_NBA__c WHERE Order__c = :idOrder AND ( Status__c = 'Em aberto' OR Status__c = 'Não enviado' OR Status__c = 'Erro' )]){
			listSolic.add( solic );
		}
		return listSolic;
	}
	// Agregado Informativo Alexandre Amaro
	public static Solic_NBA__c getSolicMobile( String idOrder){
		Solic_NBA__c solicMobile = null;
		List<Solic_NBA__c> lstSolic = [SELECT Id, MothersName__c, RG__c, RGDate__c, RGEmitter__c, Discount__c,
									   Order__c, ProductType__c, SolicitationType__c,Movement__c, BirthDate__c , Bonus__c, pointId__c
									   FROM Solic_NBA__c WHERE Order__c =:idOrder  ];
		if(!lstSolic.isEmpty()){
			for(Solic_NBA__c sl : lstSolic){
				if(sl.ProductType__c.contains('MOVEL') && sl.SolicitationType__c != null && sl.Movement__c != NBA_Constants.MOVIMENTO_CANCELAMENTO ){
					solicMobile = sl;
					break;
				}
			}
		}
		
		return solicMobile;
	}

	public static String getOperationType(String operationType){
		if(operationType != null && String.isNotBlank(operationType) && operationType.contains('Retencao')){
			return 'Retencao';
		}else if(operationType != null && String.isNotBlank(operationType) && operationType.contains('Rentabilizacao Ativo')){
			return 'Rentabilizacao Ativo';
		}else if(operationType != null && String.isNotBlank(operationType) && operationType.contains('Rentabilizacao Receptivo')){
			return 'Rentabilizacao Receptivo';
		}
		return '';
	}

	public static String getCodAssinate(String cityCode, String contractNumber){
		if(cityCode != null && contractNumber != null){
			return cityCode.leftPad(3, '0') + ' ' + contractNumber;
		}
		return '';
	}

	public static String convertDatetimeToDate(Datetime dt){
		Date d = Date.newInstance(dt.year(), dt.month(), dt.day());
		return d.format();
	}

	public static Account getAccountFromOrder(String idAccount, String documentoNumber){
		Account accountResult		= new Account();
		List<Account> listAccount	= [SELECT Id, Name, Phone, MothersName__c, RG__c, DocumentNumber__c, BirthDate__c, Foreign__c, Account.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
											  Account.vlocity_cmt__PremisesId__r.Complement__c, Account.vlocity_cmt__PremisesId__r.Neighborhood__c, 
											  Account.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c, Account.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,
											  Account.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c, Account.vlocity_cmt__PremisesId__r.Number__c, RGEmitter__c,
											  (SELECT Id, Phone, MothersName__c, RG__c, RGEmitter__c, BirthDate, Premises__r.vlocity_cmt__State__c, Premises__r.vlocity_cmt__City__c,
											   Premises__r.vlocity_cmt__PostalCode__c, Premises__r.Neighborhood__c, Premises__r.vlocity_cmt__StreetAddress__c, Premises__r.Number__c, 
											   Premises__r.Complement__c FROM Contacts WHERE DocumentNumber__c = :documentoNumber LIMIT 1) 
									   FROM Account 
									   WHERE Id = :idAccount LIMIT 1];
		if(listAccount != null && !listAccount.isEmpty()){
			accountResult = listAccount.get(0);
		}
		return accountResult;
	}

	public static String getCaseResult(Case caso){
		String result = '';
		if(caso.CallResult__c != null && String.isNotBlank(caso.CallResult__c)){
			if(caso.CallResult__c.equalsIgnoreCase('VENDA') || caso.CallResult__c.equalsIgnoreCase('NÃO VENDA') || caso.CallResult__c.equalsIgnoreCase('RETIDO PARCIAL') || caso.CallResult__c.equalsIgnoreCase('RETIDO')){
				result = 'RETIDO';
			}else if(caso.CallResult__c.equalsIgnoreCase('CANCELADO')){
				result = 'NÃO RETIDO';
			}else if(caso.CallResult__c.equalsIgnoreCase('INFORMATIVO')){
				result = 'OCORRÊNCIA INFORMATIVA';
			}
		}else {
			result = '';
		}
		return result;
	}

	public static void updateOrder(NBA_IntegrationUtils.HttpResponseModel res, String orderId){
		List<Order> lisOrder = [SELECT Id, OrderCase__c FROM Order WHERE ID = :orderId];
		if(lisOrder != null && !lisOrder.isEmpty()){
			List<Case> listCase = [SELECT Id FROM Case WHERE Order__c = :lisOrder.get(0).Id];
			if(listCase != null && !listCase.isEmpty()){
				Order order = lisOrder.get(0);
				if (res.success) {
					Order.Status = 'Em Processamento';
				} else {
					Order.Status = 'Erro Envio';
				}
				order.OrderCase__c = listCase.get(0).Id;
				update order;
			}
		}
	}

	public static Boolean checkTasks(String idOrder){
		Boolean result = false;
		if(idOrder != null && String.isNotBlank(idOrder)){
			List<Solic_NBA__c> listSolic = [SELECT id FROM Solic_NBA__c WHERE Order__c = :idOrder AND ( Status__c = 'Em aberto' OR Status__c = 'Não enviado' OR Status__c = 'Erro' )];
			if(listSolic != null && !listSolic.isEmpty()){
				result = true;
			}
		}
		return result;
	}

	public static String isHasTvPacote(String idOrder){
		System.debug('INICIANDO');
		String result = '';
		if(idOrder != null && String.isNotBlank(idOrder)){
			List<Solic_NBA__c> listSolic = [SELECT id, LegacyNameProduct__c FROM Solic_NBA__c WHERE Order__c = :idOrder AND ProductType__c = :NBA_Constants.TV_PACOTE AND ( Status__c = 'Em aberto' OR Status__c = 'Não enviado' OR Status__c = 'Erro' )];
			if(listSolic != null && !listSolic.isEmpty()){
				System.debug('SOU UMA TV');
				result = listSolic.get(0).LegacyNameProduct__c;
			}else {
				System.debug('NÃO SOU UMA TV');
			}
		}
		return result;
	}

	public static NBA_IntegrationModels.RPA_tasks createDefaultSolicForBonusDiscount(Solic_NBA__c solicMobile, Order order,
																					Case caso, Map<String, User> mapUser,
																					String resultIsTv, String totalDependent){

			NBA_IntegrationModels.RPA_tasks task = new NBA_IntegrationModels.RPA_tasks();
			task.taskId 							 	 = solicMobile.Id;
			task.targetProduct.type						 = solicMobile.ProductType__c;
			task.targetProduct.profile					 = solicMobile.ComboProfile__c != null ? solicMobile.ComboProfile__c : null;
			task.targetProduct.pricing						= String.valueOf(solicMobile.TotalValue__c);

			if(solicMobile.Movement__c == NBA_Constants.MOVIMENTO_AQUISICAO && (solicMobile.ProductType__c == NBA_Constants.BL_ADICIONAIS || solicMobile.ProductType__c == NBA_Constants.MOVEL_ADICIONAIS || solicMobile.ProductType__c == NBA_Constants.TV_A_LA_CARTE || solicMobile.ProductType__c == NBA_Constants.TV_PONTOS_ADICIONAIS)){
				task.targetProduct.point			= solicMobile.MainPoint__c;
			}else if(solicMobile.Movement__c == NBA_Constants.MOVIMENTO_AQUISICAO && ( solicMobile.ProductType__c == NBA_Constants.BL_ASSINATURA || solicMobile.ProductType__c == NBA_Constants.NET_FONE )){
				task.targetProduct.point			= String.isNotBlank(resultIsTv) ? resultIsTv : solicMobile.MainPoint__c;
			}else {
				task.targetProduct.point			= solicMobile.CurrentProduct__c;
			}

			task.targetProduct.mobileDependentAmountToAdd = totalDependent;
			task.targetProduct.fidelityRenewalDate		 = solicMobile.RenewFidelity__c ? convertDatetimeToDate( order.CreatedDate ) : null;
			task.targetProduct.fidelityExpirationDate	 = solicMobile.RenewFidelity__c ? convertDatetimeToDate( order.CreatedDate.addDays(365) ) : null;
			task.solicitationType					 	 = solicMobile.SolicitationType__c != null ? solicMobile.SolicitationType__c : '';
			task.salesmanUser							 = mapUser.containsKey( order.OwnerId ) && mapUser.get( order.Ownerid ).NetServicos__c != null ? mapUser.get( order.Ownerid ).NetServicos__c + ' | ' + user.Claro__c : mapUser.get( order.Ownerid ).FederationIdentifier + ' | ' + user.Claro__c;
			task.result								 	 = String.isNotBlank(caso.TVN1Result__c) ? caso.TVN1Result__c : '';
			task.resultReason						 	 = String.isNotBlank(caso.TVN2Result__c) ? caso.TVN2Result__c : '';
			task.resultNotes						 	 = String.isNotBlank(caso.TVN3Result__c) ? caso.TVN3Result__c : '';
			task.hasFidelity							 = solicMobile.Fidelity__c ? 'SIM' : 'NÃO';
			task.fidelityPenaltyPrice					 = solicMobile.Penality_Price__c;
			task.action								 	 = NBA_Constants.INCLUSAO_OFERTA;
			task.city									 = order.Contract.CityCode__c != null ? order.Contract.CityCode__c.leftPad(3, '0') : '';

			return task;
		}

	public static List<NBA_IntegrationModels.RPA_tasks> getTaskBonusDiscountForMovel(Solic_NBA__c solicMobile, Order order,
																					Case caso, Map<String, User> mapUser,
																				    String resultIsTv, String totalDependent){
		List<NBA_IntegrationModels.RPA_tasks> tasks = new List<NBA_IntegrationModels.RPA_tasks>();

		if(solicMobile.Discount__c != null && solicMobile.Discount__c.length()>0){
			NBA_IntegrationModels.RPA_tasks task = createDefaultSolicForBonusDiscount(solicMobile,order,caso,mapUser,resultIsTv,totalDependent);
			task.targetProduct.mobileOfferType 		 	 = NBA_Constants.DESCONTO;
			task.targetProduct.mobileAppliedDiscount 	 = solicMobile.Discount__c;
			tasks.add(task);
		}

		if(solicMobile.Bonus__c != null && solicMobile.Bonus__c.length()>0){
			NBA_IntegrationModels.RPA_tasks task = createDefaultSolicForBonusDiscount(solicMobile,order,caso,mapUser,resultIsTv,totalDependent);
			task.targetProduct.mobileOfferType = NBA_Constants.BONUS;
			task.targetProduct.mobileAppliedDiscount = solicMobile.Bonus__c;
			tasks.add(task);
		}

		return tasks;
	}

	public static List<NBA_IntegrationModels.RPA_tasks> getTaskBonusDiscountWithDependent(List<Solic_NBA__c> DependentsSolic,
																						 Order order,Case caso, Map<String, User> mapUser,
																					     String resultIsTv, String totalDependent){
		List<NBA_IntegrationModels.RPA_tasks> dependentsTask = new List<NBA_IntegrationModels.RPA_tasks>();

		for(Solic_NBA__c solicDep : DependentsSolic){
			if(solicDep.Discount__c != null && solicDep.Discount__c.length()>0){
				NBA_IntegrationModels.RPA_tasks task = createDefaultSolicForBonusDiscount(solicDep,order,caso,mapUser,resultIsTv,totalDependent);
				NBA_IntegrationModels.RPA_MobileDependent dep = new NBA_IntegrationModels.RPA_MobileDependent();
				dep.offerType 								= NBA_Constants.DESCONTO;
				dep.appliedDiscount 						= solicDep.Discount__c;
				dep.action									= solicDep.Movement__c;
				dep.isPortabilityRequest					= solicDep.Portability__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
				dep.msisdn									= solicDep.MSISDN__c != null ? solicDep.MSISDN__c : '';
				dep.profile									= solicDep.DependentProfile__c != null ? solicDep.DependentProfile__c : '';
				task.targetProduct.mobileDependent.add(dep);
				dependentsTask.add(task);
			}

			if(solicDep.Bonus__c != null && solicDep.Bonus__C.length()>0){
				NBA_IntegrationModels.RPA_tasks task = createDefaultSolicForBonusDiscount(solicDep,order,caso,mapUser,resultIsTv,totalDependent);
				NBA_IntegrationModels.RPA_MobileDependent dep = new NBA_IntegrationModels.RPA_MobileDependent();
				dep.offerType 								= NBA_Constants.BONUS;
				dep.appliedDiscount 						= solicDep.Bonus__c;
				dep.isPortabilityRequest					= solicDep.Portability__c ? NBA_Constants.RPA_SIM : NBA_Constants.RPA_NAO;
				dep.msisdn									= solicDep.MSISDN__c != null ? solicDep.MSISDN__c : '';
				dep.profile									= solicDep.DependentProfile__c != null ? solicDep.DependentProfile__c : '';
				task.targetProduct.mobileDependent.add(dep);
				dependentsTask.add(task);
			}
		}
		return dependentsTask;
	}
}