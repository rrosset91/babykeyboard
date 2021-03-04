public with sharing class JSONContactRecords {

    @AuraEnabled public String apiVersion;
    @AuraEnabled public String transactionId;
    @AuraEnabled public Data data;
    @AuraEnabled public Error error;
    public class Link{
        @AuraEnabled public String rel;
        @AuraEnabled public String href;
    }
    
    public class Error{
        @AuraEnabled public String httpCode;
        @AuraEnabled public String errorCode;
        @AuraEnabled public String message;
        @AuraEnabled public String detailedMessage;
        @AuraEnabled public Link link;
    }

    public class Data{
        @AuraEnabled public List<Contactrecord> contactrecords;
    }

    public class Contactrecord{
        @AuraEnabled public String groupType;
        @AuraEnabled public String occurrenceSubGroup;
        @AuraEnabled public String customerAccountId;
        @AuraEnabled public String stringNumber;//number
        @AuraEnabled public String loginOpening;
        @AuraEnabled public String loginClosing;
        @AuraEnabled public String creationDate;
        @AuraEnabled public String resolutionDate;
        @AuraEnabled public String resolutionNote;
        @AuraEnabled public String returnDate;
        @AuraEnabled public String name;
        @AuraEnabled public String phoneLineNumber;
        @AuraEnabled public String originId;
        @AuraEnabled public String areaOrigin;
        @AuraEnabled public String groupTypeId;
        @AuraEnabled public String groupTypeDescription;
        @AuraEnabled public String typeId;
        @AuraEnabled public String typeDescription;
        @AuraEnabled public String status;
        @AuraEnabled public String note;
        @AuraEnabled public String attendanceNumber;
        @AuraEnabled public String description;
        @AuraEnabled public String protocolNumber;
    }


    
}