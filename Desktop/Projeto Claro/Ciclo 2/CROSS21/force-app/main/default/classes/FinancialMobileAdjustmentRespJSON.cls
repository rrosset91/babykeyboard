/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 29-12-2020
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   29-12-2020   Joao Neves   Initial Version
 **/
public without sharing class FinancialMobileAdjustmentRespJSON extends ClaroAPIBaseResponse {
	public Data data;

	public FinancialMobileAdjustmentRespJSON() {
	}

	public FinancialMobileAdjustmentRespJSON(String specificClassType, Map<String, String> initMap) {
		super(specificClassType, initMap);
	}

	public class Data {
		public String accountIdInfo;
		public Long adjustmentSequenceNumber;
	}
}