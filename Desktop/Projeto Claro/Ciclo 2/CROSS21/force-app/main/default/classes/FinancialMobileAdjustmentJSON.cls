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
public without sharing class FinancialMobileAdjustmentJSON {
	public Data data;

	public class Data {
		public Long accountIdInfo;
		public Long charged;
		public String adjustmentAmount;
		public String adjustmentReasonCode;
		public String userComment;
		public String cycleHeader;
		public Long subscriberNo;
		public Long voucher;
		public Long billSeqNo;
		public Long voucherSeqNo;
		public String externalProtocol;
		public String userMemo;
		public String adjustmentSequenceNumber;
	}
}