/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-12-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-12-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class OutagesReleaseJson {
    public String apiVersion;
    public String transactionId;
    public Data data;

    public class Data{
        public List<Installments> installments;
    }

    public class Installments{
        public String returnCode;
        public String OutageNumber;
        public List<productsOutages> products;
        public List<productsOutages> filteredPerType;
    }

    public class productsOutages{
        public String productType;
        public String affectedServices;
        public String symptom;
        public String coverage;
        public String nature;
        public String startDate;
        public String previsionDate;
        public String endDate;
        public String status;
        public String variant;
        public String responsible;
    }
}