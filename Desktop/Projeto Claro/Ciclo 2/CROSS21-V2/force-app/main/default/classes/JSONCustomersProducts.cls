public with sharing class JSONCustomersProducts {

    public class Consumption{
        public Integer contractNumber;
        public String cityId;
        public Integer typeSaleId;
        public String typeSaleDescription;
        public Date saleDate;
        public String salesChannelsDescription;
        public Integer salesStatusId;
        public String salesStatusDescription;
        public String eventId;
        public String eventDescription;
        public String eventName;
        public String eventDuration;
        public Double price;
        public Integer categoryPPVId;
        public String categoryPPVDescription;
        public Integer typePPVId;
        public String typePPVDescription;
    }

    public class Link{
        public String rel;
        public String href;
    }

    public class Pagination{
        public Integer totalCount;
        public Integer page;
        public Integer totalPages;
        public List<Link> links;
    }

    public class Data{
        public List<Consumption> consumption;
        public Pagination pagination;
    }

    public String apiVersion;
    public String transactionId;
    public Data data;
    public Error error;
    
    public class Error{
        public String httpCode;
        public String errorCode;
        public String message;
        public String detailedMessage;
        public Link link;
    }


}