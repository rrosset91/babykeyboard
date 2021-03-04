/**
 * @description       : CustomerDefaultSegmetation
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 20-01-2021
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   23-12-2020   Diego Almeida   Initial Version
**/
public with sharing class JSONCustomerDefaultSegmetation {
    public String apiVersion;
    public String transactionId;
    public Data data;
    public Error error;

    public class Data{
		public String dscDefault;
		public String datReferenc;
		public String origin;
		public String contractNumber;
		public String numCpf;
		public String descCluster;
		public String dscClusterComplIM;
		public String operatorCode;
		public String codDefault;
		public String cellPhone;
		public String codCluster;
	}
    public class Error{
        public Integer httpCode;
        public String errorCode;
        public String message;
        public String detailedMessage;
        public Link link;
    }
    public class Link{
        public String rel;
        public String href;
    }
}