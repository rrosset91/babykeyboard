/* 	Autor: Danilo Fucuhara - Deloitte
   	Criação: 22/03/2019
   	Descrição:Classe para interfacear a busca via integração de Saldos.
   	Nome do projeto/ID: CEC FASE - Time: SQUAD 360. 
	Alterações: US17541(17/05/19)  
<!-- Alterações: Ajuste do botao aparecer para asset NET(12/06/19) -->*/

public class CEC_360_BalanceController {

	@AuraEnabled
	public static SObject getSObject(String recordId, String sObjectName) {
		return [SELECT Id, Name, Saldo__c, Account.Name FROM Asset WHERE Id =: recordId LIMIT 1];
	}
    
    @AuraEnabled
    public static Boolean getRecordType(String recordId){
        Asset a = [Select RecordType.DeveloperName from Asset where ID =: recordId LIMIT 1];
        String recordName = a.recordType.DeveloperName;
        system.debug(recordName);
        if(recordName.equals('CECMovelPreControle'))
        {
            return true;
        }else{
            return false; 
        }
    }
    
    @AuraEnabled
    public static String getBusinessUnit(String recordId) {
        Asset ass = [SELECT BusinessUnit__c FROM Asset WHERE Id =: recordId LIMIT 1];
        if(ass != null && ass.BusinessUnit__c != null) {
            return ass.BusinessUnit__c;
        } else {
            return null; 
        }
    }

	@AuraEnabled
	public static CEC_RestObjects.BalancesMain getBalance(String recordId) {
		CEC_RestObjects.BalancesMain balance = new CEC_RestObjects.BalancesMain();
		Asset record = [SELECT Id, MSISDN__c FROM Asset WHERE Id = :recordId];
        if(record.MSISDN__c != null) {
            balance = CEC_360_IntegrationBalances.getBalance(record.MSISDN__c);
            balance.data.balances.principalBalanceAmount = formatValor(String.valueOf(Decimal.valueOf(balance.data.balances.principalBalanceAmount)));
            balance.data.balances.principalExpirationDateCredit = formatDate(balance.data.balances.principalDateExpirationBalance, 0);
            balance.data.balances.principalDateExpirationBalance = formatDate(balance.data.balances.principalDateExpirationBalance, -1);
            balance.data.balances.principalDateBlockingCalls = formatDate(balance.data.balances.principalDateBlockingCalls, 0);
            balance.data.balances.principalDateExpirationService = formatDate(balance.data.balances.principalDateExpirationService, 0);
            balance.data.balances.principalDateExpirationPhone = formatDate(balance.data.balances.principalDateExpirationPhone, 0);
		}
		return balance;
	}

	public static String formatDate(String dateToFormat, Integer days) {
        Date dateAux = Date.valueOf(dateToFormat);
        if(days != 0) {
            dateAux.addDays(days);
            Date d = Date.newInstance(Integer.valueOf(dateAux.year()), Integer.valueOf(dateAux.month()), Integer.valueOf(dateAux.day()));
            dateAux = d.addDays(-1);
        }
        return dateAux.day() + '/' + dateAux.month() + '/' + dateAux.year();
    }

	@AuraEnabled
	public static CEC_RestObjects.Transactions getTransactionsLast(String recordId) {
		CEC_RestObjects.Transactions transactions = new CEC_RestObjects.Transactions();
		Asset record = [SELECT Id, MSISDN__c FROM Asset WHERE Id = :recordId];
		System.debug('record:: ' + record.MSISDN__c);
		if(record.MSISDN__c != null) {
			transactions = CEC_360_IntegrationTransactions.getTransactionsLast(record.MSISDN__c);
		}

		return transactions;
	}

	@AuraEnabled
	public static CEC_RestObjects.Transactions getTransactionsPeriod(String recordId, String dateStart, String dateEnd, String tipo, String subTipo) {
		CEC_RestObjects.Transactions transactions = new CEC_RestObjects.Transactions();
		Asset record = [SELECT Id, MSISDN__c FROM Asset WHERE Id = :recordId];
		if(record.MSISDN__c != null) {
			transactions = CEC_360_IntegrationTransactions.getTransactionsPeriod(record.MSISDN__c, dateStart, dateEnd, tipo, subTipo);
		}
		return transactions;
	}

	@AuraEnabled
	public static List<CEC_RestObjects.Accumulators> getOtherBalances(String recordId) {
		String date_aux;
		List<CEC_RestObjects.Accumulators> balancesAccumulators;
		List<CEC_RestObjects.Accumulators> retBalancesAccumulators = new List<CEC_RestObjects.Accumulators>();
		Asset record = [SELECT Id, MSISDN__c FROM Asset WHERE Id = :recordId];

		if(String.isNotBlank(record.MSISDN__c)) {
			balancesAccumulators = CEC_360_IntegrationBalances.getOtherBalances(record.MSISDN__c);
			for (Integer i = 0; i < balancesAccumulators.size(); i++) {
				if(balancesAccumulators[i].accumulatorDateEndValidity != null) {
					date_aux = balancesAccumulators[i].accumulatorDateEndValidity.format('dd/MM/YYYY');
					balancesAccumulators[i].accumulatorDateAux = date_aux;
				}

				if(balancesAccumulators[i].accumulatorMeasurementUnit != null
				   && balancesAccumulators[i].accumulatorBalance != null) {
					if(balancesAccumulators[i].accumulatorMeasurementUnit.equals('REAIS')) {
						balancesAccumulators[i].accumulatorBalance = CEC_360_BalanceController.formatValor(balancesAccumulators[i].accumulatorBalance);
					}else{
						if(balancesAccumulators[i].accumulatorBalance.substringAfter('.').length() > 2) {
							balancesAccumulators[i].accumulatorBalance = balancesAccumulators[i].accumulatorBalance.substringBefore('.') +  balancesAccumulators[i].accumulatorBalance.substringAfter('.').substring(0, 2);
						}
					}
					if(balancesAccumulators[i].accumulatorMeasurementUnit.equals('BOLEANO')) {
						if(balancesAccumulators[i].accumulatorBalance.equals('0.0')) {
							balancesAccumulators[i].accumulatorBalance = 'NÃO';
						}else {
							balancesAccumulators[i].accumulatorBalance = 'SIM';
						}
					}
					
					switch on balancesAccumulators[i].accumulatorMeasurementUnit {
						when  'REAIS'{
							if(Double.valueOf(balancesAccumulators[i].accumulatorBalance.substringAfter('R$ ').replace(',','.')) != 0)
								retBalancesAccumulators.add(balancesAccumulators[i]);
							
						}
						when 'BOLEANO'{
							if(balancesAccumulators[i].accumulatorBalance == 'SIM')
								retBalancesAccumulators.add(balancesAccumulators[i]);
						}
						when else {
							if(Double.valueOf(balancesAccumulators[i].accumulatorBalance) != 0)
								retBalancesAccumulators.add(balancesAccumulators[i]);
						}
					}
				}
			}
			//Adiciona total acumuladores
			if(retBalancesAccumulators.isEmpty())
				retBalancesAccumulators.add(balancesAccumulators.get(balancesAccumulators.size()-1));
		}
		return retBalancesAccumulators;
	}

	@AuraEnabled
	public static List<CEC_RestObjects.PromotionalBalances> getOtherBalancesPromotional(String recordId) {
		List<CEC_RestObjects.PromotionalBalances> balancesPromotional;
		List<CEC_RestObjects.PromotionalBalances> balancePromotional_aux = new List <CEC_RestObjects.PromotionalBalances>();

		Asset record = [SELECT Id, MSISDN__c FROM Asset WHERE Id =: recordId];
		Integer balanceAmount = 0;

		if(String.isNotEmpty(record.MSISDN__c)) {
			balancesPromotional = CEC_360_IntegrationBalances.getOtherBalancesPromotional(record.MSISDN__c);
			system.debug(balancesPromotional);
			if(balancesPromotional != null) {
				Integer countTypes = 0;
				for(Integer i = 0; i < balancesPromotional.size(); i++) {
					if(balancesPromotional[i].platformDescription.equals('Total Contas Dedicadas')) {
						countTypes++;
					}
				}

				if(balancesPromotional.size() == countTypes) {
					CEC_RestObjects.PromotionalBalances balance_aux = new CEC_RestObjects.PromotionalBalances();
					if(balancesPromotional[0].measurementUnit.equals('REAIS'))
					{
						balance_aux.balance = CEC_360_BalanceController.formatValor(balancesPromotional[0].balance);
					}else{
						if(balancesPromotional[0].balance.substringAfter('.').length() > 2) {
							balance_aux.balance = balancesPromotional[0].balance.substringBefore('.') +  balancesPromotional[0].balance.substringAfter('.').substring(0, 2);
						}
					}
					balance_aux.description = balancesPromotional[0].description;
					balance_aux.measurementUnit = balancesPromotional[0].measurementUnit;
					balancePromotional_aux.add(balance_aux);
				} else {
					for(Integer i = 0; i< balancesPromotional.size(); i++) {
						if((balancesPromotional[i].platformDescription.equals('Principal') == false) &&
						   (balancesPromotional[i].platformDescription.equals('Total Contas Dedicadas') == false)) {
							CEC_RestObjects.PromotionalBalances balance_aux = new CEC_RestObjects.PromotionalBalances();
							if(balancesPromotional[i].measurementUnit.equals('REAIS'))
							{
								balance_aux.balance = CEC_360_BalanceController.formatValor(balancesPromotional[i].balance);
							}else{
								system.debug('balance'+balancesPromotional[i].balance);
								if(balancesPromotional[i].balance.substringAfter('.').length() > 2) {
									balance_aux.balance = balancesPromotional[i].balance.substringBefore('.') +  balancesPromotional[i].balance.substringAfter('.').substring(0, 2);
								}else{
									balance_aux.balance = balancesPromotional[i].balance;
								}
							}
							balance_aux.description = balancesPromotional[i].description;
							balance_aux.measurementUnit = balancesPromotional[i].measurementUnit;
							balancePromotional_aux.add(balance_aux);
						}
					}
				}
			}
		}
		return balancePromotional_aux;
	}

	public static String formatValor(String value) {
		value = 'R$ ' + value.replace('.', ',');
		if(value.substringAfter(',').length() < 2)
			value = value + '0';

		if(value.substringAfter(',').length() > 2)
			value = value.substringBefore(',') + ',' + value.substringAfter(',').substring(0, 2);
		return value;
	}

    @AuraEnabled 
	public static CEC_RestObjects.Device getDevice(String recordId) {
		CEC_RestObjects.Device device = new CEC_RestObjects.Device();
		Asset record = [SELECT Id, MSISDN__c FROM Asset WHERE Id = :recordId];
		if(record.MSISDN__c != null) {
			device = CEC_360_IntegrationDevices.getDevice(record.msisdn__c);
		}
		return device;
    }    

}