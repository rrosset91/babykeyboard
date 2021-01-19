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
public without sharing class FinancialMobileAdjustmentWrapper {
	public class Data {
		public AdjustmentItem data;
	}

	public class AdjustmentItem {
		public String accountIdInfo;
		public String charged;
		public String adjustmentAmount;
		public String adjustmentReasonCode;
		public String userComment;
		public String cycleHeader;
		public String subscriberNo;
		public String voucher;
		public String billSeqNo;
		public String voucherSeqNo;
		public String externalProtocol;
		public String userMemo;
		public String adjustmentSequenceNumber;
	}
}