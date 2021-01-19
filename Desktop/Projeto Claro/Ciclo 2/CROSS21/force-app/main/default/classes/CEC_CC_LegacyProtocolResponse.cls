global class CEC_CC_LegacyProtocolResponse{
    global LegacyProtocolData data = new LegacyProtocolData();
//    global String error;
    public  CEC_RestObjects.Error error;
    global LegacyProtocolRawData legacyData;
    global String eligibility;

    global class LegacyProtocolData{
        global String interactionOpeningDate;
        global String interactionClosingDate;
        global String protocolNumber;
        global String status;
        global String legacy;

        global String interactionNumber;

    }

    global virtual class LegacyProtocolRawData{

    }

}