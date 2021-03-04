/**
 * @description       :
 * @author            : Joao Neves
 * @group             :
 * @last modified on  : 26-01-2021
 * @last modified by  : Joao Neves
 * Modifications Log
 * Ver   Date         Author       Modification
 * 1.0   19-01-2021   Joao Neves   Initial Version
 **/
public class FinancialNegotiationEfetivationResponse extends ClaroAPIBaseResponse {
	public String startDate;
	public String endDate;
	public Long termRenegotiationId;
	public Long contactNumber;
	public Integer cityCode;
	public String errorMessageRDCC;
	public String errorMessageRollback;
	public String digitizableLine;
	public String messageRenegotiation;
	public Double barCode;
	public Long chargeCode;
	public Integer enableFirstInstallmentSeparateDebts;
	public String singleBille;
	public String expirydatesinglebill;
	public Double paymentsinglebill;

	public FinancialNegotiationEfetivationResponse() {
	}

	public FinancialNegotiationEfetivationResponse(String specificClassType, Map<String, String> initMap) {
		super(specificClassType, initMap);
	}
}