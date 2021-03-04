/**
 * ---------------------------------------------------------------
 * Data: 28/10/2020
 * Autor: Squad Anatel/Ouvidoria - Sysmap Solutions
 * Descrição: Classe que representa o response da API PSAC  / EMBRATEL
 * ---------------------------------------------------------------
 */
global class CEC_PSAC_Response {
    public String apiVersion;
    public String transactionId;
    public DataProtocols data;
    public CEC_RestObjects.Error error;


    public class DataProtocols extends CEC_CC_LegacyProtocolResponse.LegacyProtocolRawData  {
        public Attendence attendances { get; set; }
    }

    global class Attendence {
        public String documentNumber;
        public String solicitationOpeningDate;
        public String solicitationDateClosing;
        public String categoryDescription;
        public String solicitationType;
        public String productDescription;
        public String subCategoryDescription;
        public String categoryId;
        public String processId;
        public String productId;
        public String subCategoryID;
        public String status;
        public String interactionNumber;
        public String msisdn;
        public String errorCode;
        public String message;
    }


}