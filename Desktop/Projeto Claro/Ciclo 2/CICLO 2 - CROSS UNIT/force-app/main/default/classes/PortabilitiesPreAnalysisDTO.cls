/**
 * Created by 93668256 on 25/11/2019.
 */

public class PortabilitiesPreAnalysisDTO {

    public class PortabilityPreAnalysisRequest {
        public ListOfPhoneNumber data;
    }
    public class ListOfPhoneNumber{
        public List<Map<String,Object>> telephoneNumbers;
    }

    public class PhoneNumber{
        public String number_z;
    }

    public class PortabilityPreAnalysis extends CEC_RestObjects.ResponseGen {
        public PortabilityPre data;

        public Tickets getTicketByNumber(String msisdn) {
            for(Tickets t :data.portabilty.availables.tickets)
                if(t.telephoneNumber.number_Z.equals(msisdn))
                    return t;
            for (Tickets t : data.portabilty.unavailables.tickets)
                if(t.telephoneNumber.number_Z.equals(msisdn))
                    return t;
            
            return null;
        }
    }

    public class PortabilityPre {
        public Vailables portabilty;
    }

    public class Vailables {
        public Unavailables unavailables;
        public Availables availables;
    }

    public class Unavailables {
        public String detail {get;set;}
        public String reasonId {get;set;}
        public List<Tickets> tickets {get;set;}

    }

    public class Tickets {
        public String id {get;set;}
        public TelephoneNumber telephoneNumber {get;set;}
    }

    public class Availables {
        public String portabilityIndicatorSource {get;set;}
        public String detail {get;set;}
        public String name {get;set;}
        public String spidCode {get;set;}
        public List<Tickets> tickets {get;set;}
    }

    public class TelephoneNumber {
        public String number_Z {get;set;} // in json: number
    }

    public class Portabilty {
        public Availables availables {get;set;}
        public Unavailables unavailables {get;set;}

    }

}