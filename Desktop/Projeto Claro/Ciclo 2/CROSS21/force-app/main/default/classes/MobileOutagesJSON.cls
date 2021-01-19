/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-01-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-01-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class MobileOutagesJSON {
    public String apiVersion;
    public String transactionId;
    public Data data;

    public class Data{
        public Boolean impact;
        public String expectedRegularizationDt;
    }
}