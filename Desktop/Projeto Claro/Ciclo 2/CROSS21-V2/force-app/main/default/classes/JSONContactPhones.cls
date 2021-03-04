/**
 * @description       : 
 * @author            : lucas.soldi@ibm.com
 * @group             : 
 * @last modified on  : 01-04-2021
 * @last modified by  : lucas.soldi@ibm.com
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   01-04-2021   lucas.soldi@ibm.com   Initial Version
**/
public class JSONContactPhones {

    public String apiversion;
    public String transactionId;
    public Data data;


    public class Data{
        public String customerDocument;
        public String VIP;
        public List<CustomerPhones> customerPhones;
    }

    public class CustomerPhones{
        public String phoneNumber;
        public String rank;
        public String doNotDisturb;
    }
}