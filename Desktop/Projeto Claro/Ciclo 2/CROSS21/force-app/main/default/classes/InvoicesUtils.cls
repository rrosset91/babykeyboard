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
		} catch (StringException e) {
			System.debug('@@@ invalid id exception ' + e.getMessage());
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

		if (accsLst.isEmpty())
			return null;

		return accsLst[0];
	}

	public static String getCalloutUser(String calloutName) {
		if (isSandboxContext())
			return 'MCIDA';

		ServiceParameter__c srcParam = ServiceParameter__c.getInstance(calloutName);
		if (srcParam != null && srcParam.User__c != null)
			return srcParam.User__c;

		return 'CRM_SF_FINANCEIRO';
	}

	public static Boolean isSandboxContext() {
		return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
	}
}