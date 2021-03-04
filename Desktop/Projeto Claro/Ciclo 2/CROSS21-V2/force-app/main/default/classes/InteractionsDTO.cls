public class InteractionsDTO {

    public Request builderRequestForControle(String msisdn){
        Request request = new Request();
        request.data = new DataRequest('Movel',new Customer(msisdn),'FECHADO','150',
                '8198','9681','25538','AAPF','ATENDIDO');
        return request;
    }

    public Request builderRequestForPos(String msisdn){
        Request request = new Request();
        request.data = new DataRequest('Movel',new Customer(msisdn),'FECHADO','150',
                '8196','11235','25532','AAPF','ATENDIDO');
        return request;
    }

    public class Request {

        public DataRequest data;

    }

    public class Response {

        public DataResponse data;

    }


    public class Customer
    {
        public Customer(String msisdn) {
            this.msisdn = msisdn;
        }

        public String msisdn;
    }

    public class DataRequest
    {
        public DataRequest() {
        }

        public DataRequest(String companyId, Customer customer, String situation, String reasonCode1,
                           String reasonCode2, String reasonCode3, String reasonCode4, String contactTypeId,
                           String result) {
            this.companyId = companyId;
            this.customer = customer;
            this.situation = situation;
            this.reasonCode1 = reasonCode1;
            this.reasonCode2 = reasonCode2;
            this.reasonCode3 = reasonCode3;
            this.reasonCode4 = reasonCode4;
            this.contactTypeId = contactTypeId;
            this.result = result;
        }

        public String companyId;
        public Customer customer;
        public String situation;
        public String reasonCode1;
        public String reasonCode2;
        public String reasonCode3;
        public String reasonCode4;
        public String contactTypeId;
        public String result;
    }

    public class DataResponse
    {
        public DataResponse() {
        }

        public DataResponse(String protocolNumber) {
            this.protocolNumber = protocolNumber;
        }

        public String protocolNumber;
    }

}