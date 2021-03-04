/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 19-11-2020
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   18-11-2020   Joao Neves   Initial Version
 **/
global class SolarVlocityCustomFunction implements vlocity_cmt.VlocityOpenInterface {
	global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options) {
		switch on methodName {
			when 'toObject' {
				List<Object> arguments = (List<Object>) inputs.get('arguments');
				output.put('result', toObject(arguments));
			}
			when 'getHistory' {
				output.put('result', getObject(inputs));
			}
		}

		return true;
	}

	List<Map<String, String>> toObject(List<Object> arrayItems) {
		List<Map<String, String>> objList = new List<Map<String, String>>();
		System.debug('Valor entrado ->' + JSON.serializePretty(arrayItems));

		Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(arrayItems[0]));
		if (!objMap.containsKey('ContractNumber'))
			return objList;

		for (Object obj : String.valueOf(objMap.get('Invoices')).split(',')) {
			Map<String, String> stg = new Map<String, String>();
			stg.put('contractNumber', String.valueOf(objMap.get('ContractNumber')));
			stg.put('invoice', String.valueOf(obj));
			objList.add(stg);
		}

		return objList;
	}

	List<Map<String, Object>> getObject(Map<String, Object> arrayItems) {
		System.debug('Valor ->' + arrayItems);
		if (arrayItems == null || arrayItems.isEmpty())
			return new List<Map<String, Object>>();

		Map<String, Object> objMap = deserializeUntyped(arrayItems);
		if (!objMap.containsKey('GetCaseInfos') || objMap.get('GetCaseInfos') == null)
			return new List<Map<String, Object>>();

		if (objMap.get('GetCaseInfos') instanceof List<Object>) {
			if (((List<Object>) objMap.get('GetCaseInfos')).isEmpty())
				return new List<Map<String, Object>>();
		}

		Map<String, Object> getCaseInfos = deserializeUntyped(objMap.get('GetCaseInfos'));
		if (!getCaseInfos.containsKey('case') || getCaseInfos.get('case') == null)
			return new List<Map<String, Object>>();

		List<Object> cases = new List<Object>();
		try {
			cases.addAll((List<Object>) getCaseInfos.get('case'));
		} catch (Exception e) {
			System.debug('@@@@@@ exception ' + e.getMessage());
			cases.add(getCaseInfos.get('case'));
		}

		Map<String, Object> relatedCases = new Map<String, Object>();
		for (Object instCase : cases)
			relatedCases.put(String.valueOf(deserializeUntyped(instCase).get('id')), instCase);

		List<CaseHistory> relatedHistory = [SELECT CreatedDate, OldValue, NewValue, CaseId FROM CaseHistory WHERE CaseId IN :relatedCases.keySet() AND Field = 'Status'];

		Map<String, List<CaseHistory>> caseHistoryMap = new Map<String, List<CaseHistory>>();
		for (CaseHistory ch : relatedHistory) {
			if (caseHistoryMap.containsKey(ch.CaseId)) {
				List<CaseHistory> historyList = caseHistoryMap.get(ch.CaseId);
				historyList.add(ch);
				caseHistoryMap.put(ch.CaseId, historyList);
			} else {
				caseHistoryMap.put(ch.CaseId, new List<CaseHistory>{ ch });
			}
		}

		List<Map<String, Object>> retMap = new List<Map<String, Object>>();
		for (String caseId : relatedCases.keySet()) {
			Object caseObject = relatedCases.get(caseId);
			List<Object> genericHistory = new List<Object>();

			if (caseHistoryMap.get(caseId) != null) {
				List<CaseHistory> caseHistory = caseHistoryMap.get(caseId);
				for (CaseHistory ch : caseHistory)
					genericHistory.add(new HistoryCaseJson(String.valueOf(ch.OldValue), String.valueOf(ch.NewValue), String.valueOfGmt(ch.CreatedDate)));
			}

			Map<String, Object> untypedObject = deserializeUntyped(caseObject);
			untypedObject.put('history_items', genericHistory);

			retMap.add(deserializeUntyped(untypedObject));
		}

		return retMap;
	}

	private Map<String, Object> deserializeUntyped(Object obj) {
		return (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
	}

	public class HistoryCaseJson {
		public String old_value { get; set; }
		public String new_value { get; set; }
		public String created_date { get; set; }

		public HistoryCaseJson() {
		}

		public HistoryCaseJson(String ov, String nv, String createdDate) {
			this.old_value = ov;
			this.new_value = nv;
			this.created_date = createdDate;
		}
	}
}