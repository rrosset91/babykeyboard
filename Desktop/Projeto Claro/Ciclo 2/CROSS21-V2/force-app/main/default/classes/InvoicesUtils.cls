/**
 * @author: Rafael de Campos
 * @company: IBM - Bluewolf
 * @description: Classe com objetivo de agrupar métodos utilitários re-usáveis na frente/squad do financeiro
 */
public class InvoicesUtils {
	/*
	 * @description: Retorna uma data em String formatada de acordo com o GMT do usuário corrente
	 */
	public static String setFormattedDate(String datetimeStr) {
		return Date.valueOf(datetimeStr).format();
	}
	/*
	 * @description: Retorna o nome do objeto com base em uma string enviada
	 */
	public static String getSobjectName(String sobjectId) {
		if (sobjectId == null)
			return null;

		try {
			Id idParam = Id.valueOf(sobjectId);
			return String.valueOf(idParam.getsobjecttype());
		} catch (Exception e) {
			System.debug('@@@ error getting sobject name ' + e.getMessage());
		}

		return null;
	}

	public static Date toStartOfMonth(Date startDate) {
		if (startDate == null)
			startDate = System.today();

		return Date.newInstance(startDate.year(), startDate.month(), 1);
	}

	public static Date toEndOfMonth(Date endDate) {
		if (endDate == null)
			endDate = System.today();

		Integer daysMonth = Date.daysInMonth(endDate.year(), endDate.month());
		return Date.newInstance(endDate.year(), endDate.month(), daysMonth);
	}

	public static String formatDateToIntegration(Date formatDate, Boolean appendHours) {
		if (formatDate == null)
			formatDate = System.today();

		String month = formatDate.month() < 10 ? '0' + formatDate.month() : String.valueOf(formatDate.month());
		String day = formatDate.day() < 10 ? '0' + formatDate.day() : String.valueOf(formatDate.day());

		String dt = formatDate.year() + '-' + month + '-' + day;
		if (appendHours)
			dt = dt + '-00:00';

		return dt;
	}

	public static String formatIntegrationDateToSFDate(String integrationDate) {
		if (String.isBlank(integrationDate))
			return null;

		List<String> dateParts = integrationDate.split(' ');

		if (dateParts.size() != 6)
			return null;

		return dateParts.get(2) + '/' + getMonthNameInNumber(dateParts.get(1)) + '/' + dateParts.get(5);
	}

	public static Date convertFormattedDateToSFDate(String formattedDate) {
		
		if (String.isBlank(formattedDate))
			return null;

		List<String> dateParts = formattedDate.split('/');

		if (dateParts.size() != 3)
			return null;

		return Date.newInstance(Integer.valueOf(dateParts.get(2)), Integer.valueOf(dateParts.get(1)), Integer.valueOf(dateParts.get(0)));
	}

	public static Account getAccountFromCaseId(String csId) {
		if (csId == null)
			return null;

		List<Case> cs = [SELECT Id, ContractBillingAccount__c FROM Case WHERE Id = :csId];
		if (cs.isEmpty())
			return null;

		String accId = cs[0].ContractBillingAccount__c;
		if (accId == null)
			return null;

		List<Account> accsLst = [SELECT Id, ContractReferenceNumber__c, CityCode__c FROM Account WHERE Id = :accId];

		return accsLst.isEmpty() ? null : accsLst[0];
	}

	public static String getCalloutUser(String calloutName) {
		if (isSandboxContext())
			return 'MCIDA';

		ServiceParameter__c srcParam = ServiceParameter__c.getInstance(calloutName);
		if (srcParam != null && srcParam.User__c != null)
			return srcParam.User__c;

		return 'CRM_SF_FIN';
	}

	public static Boolean isSandboxContext() {
		return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
	}

	public static Integer getMonthNameInNumber(String month) {
		switch on month {
			when 'Jan' {
				return 1;
			}
			when 'Feb' {
				return 2;
			}
			when 'Mar' {
				return 4;
			}
			when 'Apr' {
				return 4;
			}
			when 'May' {
				return 5;
			}
			when 'Jun' {
				return 6;
			}
			when 'Jul' {
				return 7;
			}
			when 'Aug' {
				return 8;
			}
			when 'Sep' {
				return 9;
			}
			when 'Oct' {
				return 10;
			}
			when 'Nov' {
				return 11;
			}
			when 'Dec' {
				return 12;
			}
			when else {
				return null;
			}
		}
	}

	public static string getProfileName(id profileId){
		return [select id, name from Profile where id =:profileId].name;
	}

	public static Boolean isPermissionSet(Set<String> permissionSetNames) {
		AggregateResult[] countId = [
			SELECT count(Id) sets
			FROM PermissionSetAssignment
			WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name IN :permissionSetNames
		];
		Integer countNumber = 0;
		for (AggregateResult ar : countId) {
			countNumber = Integer.valueOf(ar.get('sets'));
		}
		if (countNumber > 0) {
			System.debug('GeneralInvoicesController-isPermissionSet ' + 'true');
			return true;
		}
		System.debug('GeneralInvoicesController-isPermissionSet ' + 'false');
		return false;
	}
}