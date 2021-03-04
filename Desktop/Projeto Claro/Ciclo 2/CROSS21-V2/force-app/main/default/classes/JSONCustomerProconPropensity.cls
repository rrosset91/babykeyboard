/**
 * @description       : CustomerProconPropensity
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 23-12-2020
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   23-12-2020   Diego Almeida   Initial Version
**/
public with sharing class JSONCustomerProconPropensity {
    public String apiVersion;
    public String transactionId;
    public Data data;
    public Error error;

    public class Data{
        public String phoneNumber;
        public String codRangePropensitydsc;
        public String datReferenc;
        public String modelCod;
        public String dscModel;
        public String origin;
        public String codRangePropensity;
        public String contractNumber;
        public String numCpf;
        public String operatorCode;
        public String datUploadData;
        public String valPropensity;
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