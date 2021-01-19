public with sharing class JSONContactRecordsPost {
    // import com.fasterxml.jackson.databind.ObjectMapper; // version 2.11.1
    // import com.fasterxml.jackson.annotation.JsonProperty; // version 2.11.1
    /* ObjectMapper om = new ObjectMapper();
    Root root = om.readValue(myJsonString), Root.class); */
    public class PartyId{
        public String numberString; //number
        public String type;
    }

    public class Emailcontact{
        public String emailAddress;
    }

    public class Telephone{
        public String areaCode;
        public String numberString; //number
        public String extensionNumber;
    }

    public class User{
        public String login;
        public String userName;
        public PartyId partyId;
        public Emailcontact emailcontact;
        public Telephone telephone;
    }

    public class EventType{
        public String identifier;
        public String description;
    }

    public class Type{
        public String identifier;
        public String description;
    }

    public class PartyId2{
        public String numberString; //number
        public String type;
    }

    public class Emailcontact2{
        public String emailAddress;
    }

    public class Telephone2{
        public String areaCode;
        public String numberString; //number
        public String extensionNumber;
    }

    public class User2{
        public String login;
        public String userName;
        public PartyId2 partyId;
        public Emailcontact2 emailcontact;
        public Telephone2 telephone;
    }

    public class ContactType{
        public String identifier;
        public String description;
    }

    public class Telephone3{
        public String areaCode;
        public String numberString; //number
        public String extensionNumber;
    }

    public class Emailcontact3{
        public String emailAddress;
    }

    public class PartyId3{
        public String addressId;
        public String country;
        public String placeId;
        public String cityId;
        public String cityName;
        public String postCode;
        public String neighborhood;
        public String streetType;
        public String streetTypeId;
        public String streetName;
        public String streetNrFirst;
        public String urbanPropertySubAddress;
        public String complementarySubAddress;
        public String boxNr;
    }

    public class ContactMedium{
        public Telephone3 telephone;
        public Emailcontact3 emailcontact;
        public PartyId3 partyId;
    }

    public class Contact{
        public User2 user;
        public ContactType contactType;
        public String name;
        public String interactionNumber;
        public String protocol;
        public ContactMedium contactMedium;
    }

    public class ContactRecord{
        public User user;
        public String eventDate;
        public String note;
        public String sourceEvent;
        public EventType eventType;
        public Type type;
        public Contact contact;
    }

    public class Data{
        public List<ContactRecord> contactRecords;
    }

    public String apiVersion;
    public String transactionId;
    public Data data;
    public Error error;
    public class Link{
        public String rel;
        public String href;
    }
    
    public class Error{
        public String httpCode;
        public String errorCode;
        public String message;
        public String detailedMessage;
        public Link link;
    }


    public class DataPost{
        public String login;
        public String note;
        public String sourceEvent;
        public String identifier;
        public String identifierType;
        public String description;
        public String name;
        public String areaCode;
        public String telephoneNumber;
        public String extensionNumber;
        public String telephoneType;
        public String contractNumber;
        public String operatorCode;
        public String cityId;
        public String MACAddress;
        public String AliasDatabase;
        public String protocol;
        public String interactionNumber;
    }
    
    public class PostBody{
        public String transactionId;
        public DataPost data;
    }

}