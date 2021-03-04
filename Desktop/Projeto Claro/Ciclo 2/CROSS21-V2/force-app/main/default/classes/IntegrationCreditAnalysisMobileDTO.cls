/**\
 * Created by 93668256 on 26/11/2019.
 */

global class IntegrationCreditAnalysisMobileDTO {

    global class CredAnalysisReq extends CEC_RestObjects.ResponseGen {
        global CredAnalysisData data;
    }

    global class CredAnalysisData {
        global String operatorCode;
        global List<CredAnalysisItens> itens;
    }
 
    global class CredAnalysisItens {
        global CredAnalysisItem item;
    }

    global class CredAnalysisItem {
        global String fieldId;
        global String fieldName;
        global String value;
        global String key;
    }

    global class CredAnalisysMobileReq extends CEC_RestObjects.ResponseGen {
        global CredAnalisysMobileData data;
    }

    global class CredAnalisysMobileData {
        global String type;
        global String operation;
        global Aplication aplication;
        global CredOrder order;
        global RelatedAssessment relatedAssessment;

        public CredAnalisysMobileData() {
        }

        public CredAnalisysMobileData(String type, String operation, Aplication aplication, CredOrder order, RelatedAssessment relatedAssessment) {
            this.type = type;
            this.operation = operation;
            this.aplication = aplication;
            this.order = order;
            this.relatedAssessment = relatedAssessment;
        }
    }


    public class RelatedAssessment {
        public String Id;
        public String type;

        public RelatedAssessment(String id, String type) {
            Id = id;
            this.type = type;
        }

        public RelatedAssessment() {
        }
    }

    public class Aplication {
        public string id;
        public String type;
        public SalesUser user;

        public Aplication(string id, String type, SalesUser user) {
            this.id = id;
            this.type = type;
            this.user = user;
        }

        public Aplication() {
        }
    }

    public class CredOrder {
        public Client client;
        public SalesUser pointSale;
        public Seller seller;

        public CredOrder(Client client, SalesUser pointSale, Seller seller) {
            this.client = client;
            this.pointSale = pointSale;
            this.seller = seller;
        }

        public CredOrder() {
        }
    }

    public class Client {
        public String typePerson;
        public String name;
        public String dateOfBirth;
        public String motherName;
        public String gender;
        public String documentNumberCPF;
        public CredAddress address;

        public Client(String typePerson, String name, String dateOfBirth, String motherName, String gender, String documentNumberCPF, CredAddress address) {
            this.typePerson = typePerson;
            this.name = name;
            this.dateOfBirth = dateOfBirth;
            this.motherName = motherName;
            this.gender = gender;
            this.documentNumberCPF = documentNumberCPF;
            this.address = address;
        }

        public Client() {
        }
    }


    global class CredAddress extends CEC_RestObjects.GenAddress {
    }

    global class Seller {
        global String id;
        global SalesAgent salesAgent;
    }

    global class SalesAgent {
        global String id;
        global Channel channel;
    }

    global class Channel {
        global String id;
        global SalesUser regional;
    }

    global class SalesUser {
        global String id;

        public SalesUser(String id) {
            this.id = id;
        }

        public SalesUser() {
        }
    }

    global class CredAnalysisResp extends CEC_RestObjects.ResponseGen {
        global CredAnalysisRespData data;

        global CredAnalysisResp() {
        }
        global CredAnalysisResp(CredAnalisysMobileResp aCredMobile) {
            if (aCredMobile == null) return;

            this.apiVersion = aCredMobile.apiVersion;
            this.transactionId = aCredMobile.transactionId;
            if (aCredMobile.error != null) this.error = aCredMobile.error;
            if (aCredMobile.data == null) return;
            CredAnalysisRespData lCaData = new CredAnalysisRespData();
            lCaData.creditSituation = new CreditSituation(aCredMobile.data);
            this.data = lCaData;
            this.formatMsg(true);
        }

        global void formatMsg(Boolean aMovel) {
            if (this.data == null || this.data.creditSituation == null || this.data.creditSituation.messages == null) return;
            for (CreditMessage iCM : this.data.creditSituation.messages) {
                if (String.isNotBlank(iCM.note)) iCM.note = iCM.note.replace('APROVADO', 'PRE-APROVADO');
            }
            if (!aMovel) return;
            CreditMessage lCM = new CreditMessage();
            lCM.identifier = '0';
            lCM.note = (String.isNotBlank(this.data.creditSituation.status) && this.data.creditSituation.status.toUpperCase().startsWith('APROV')) ? 'PRÉ-APROVADO' : 'REPROVADO';
            lCM.note += String.join(new String[]{
                    ' - Limite: ', this.data.creditSituation.creditLimit
            }, '');
            this.data.creditSituation.messages = new list<CreditMessage>{
                    lCM
            };
        }
        global void formatMsg() {
            this.formatMsg(false);
        }
    }

    global class CredAnalysisRespData {
        global CreditSituation creditSituation;
    }

    global class CreditSituation {
        global String status;
        global String resultDate;
        global String policy;
        global String reportZ;
        global String typeDecision;
        global String creditLimit;
        global String dataPolicy;
        global list<CreditMessage> messages;

        global CreditSituation() {
        }

        global CreditSituation(CredAnalisysMobileRespData aCredMobile) {
            if (aCredMobile == null) return;
            CreditMessage lMsg = new CreditMessage();
            lMsg.note = aCredMobile.reasonResultDescription;
            this.status = aCredMobile.result;
            this.resultDate = aCredMobile.resultDate;
            this.creditLimit = aCredMobile.creditLimit;
            this.messages = new list<CreditMessage>{
                    lMsg
            };
        }
    }

    global class CreditMessage {
        global String identifier;
        global String note;
    }

    global class CredAnalisysMobileResp extends CEC_RestObjects.ResponseGen {
        global CredAnalisysMobileRespData data;

        global CredAnalisysMobileResp() {}

        global CredAnalisysMobileResp(CredAnalisysMobileRespData data) {
            this.data = data;
        }
    }

    global class CredAnalisysMobileRespData {
        global String resultDate;
        global String creditLimit;
        global String result;
        global String reasonResult;
        global String reasonResultDescription;

        global CredAnalisysMobileRespData() {
        }

        global CredAnalisysMobileRespData(String resultDate, String creditLimit, String result, String reasonResult, String reasonResultDescription) {
            this.resultDate = resultDate;
            this.creditLimit = creditLimit;
            this.result = result;
            this.reasonResult = reasonResult;
            this.reasonResultDescription = reasonResultDescription;
        }
    }

    global IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp CredAnalysisResp2CredAnalisysMobileResp(CredAnalysisResp analysisResp){
        return new CredAnalisysMobileResp(
                new CredAnalisysMobileRespData(analysisResp.data.creditSituation.resultDate,analysisResp.data.creditSituation.creditLimit,
                        analysisResp.data.creditSituation.typeDecision,analysisResp.data.creditSituation.status,analysisResp.data.creditSituation.reportZ));
    }

    global CredAnalisysMobileResp getExempleResponse() {
        String jreq = '{"data":{"creditSituation":{"creditLimit":"3000.0","dataPolicy":null,"messages":[{"identifier":"0","note":"PRÉ-APROVADO - Limite: 3000.0"}],"policy":null,"reportZ":null,"resultDate":"2019-12-30T16:45:19.768-02:00","status":"Aprovar","typeDecision":null}},"apiVersion":"1;2019-14-01","error":null,"transactionId":"Id-bc450a5e6fbc0d18ade5d178"}';
        return (IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp) JSON.deserialize(jreq, IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp.class);
    }

}