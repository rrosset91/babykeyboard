global class CEC_IntegrationPhoneNumberReservation {

    public PhoneNumberReservationDTO.IntegrationTestTelephoneInfo consultar(String DDD, String qtd) {
        PhoneNumberReservationDTO.TelephoneNumberReservationInfo o
                = new PhoneNumberReservationDTO.TelephoneNumberReservationInfo();

        o.areaCode = DDD;
        o.numberOfReserv = qtd; // quantidade de orderitems plano

        PhoneNumberReservationDTO.IntegrationTestTelephoneNumbersReservations request
                = new PhoneNumberReservationDTO.IntegrationTestTelephoneNumbersReservations();

        request.data = o;
        system.debug('hh  o.areaCode'+DDD);
        system.debug('hh  o.numberOfReserv'+qtd);
        return consultar(request);
    }

    public ServiceParameter__c param;

    public PhoneNumberReservationDTO.IntegrationTestTelephoneInfo consultar(
            PhoneNumberReservationDTO.IntegrationTestTelephoneNumbersReservations request) {
        param = ServiceParameter__c.getInstance('TelephoneNumberReservation');
        system.debug('hh param'+param);
        String bodyResponse, statusResponse = '-1';

        PhoneNumberReservationDTO.IntegrationTestTelephoneNumbersReservations lrequest = request;
        PhoneNumberReservationDTO.IntegrationTestTelephoneInfo response;

        try {
            HttpRequest req = CEC_HttpReq.genHttpReq(param, '');

            HTTPResponse res = CEC_HttpReq.sendReq(req, request);

            bodyResponse = res.getBody();
            map<String, String> lMapResWord = new map<String, String>{
                    '" :' => '":', '"number":' => '"number_z":'
            };
            for (String iJsonAttr : lMapResWord.keyset()) {
                bodyResponse = bodyResponse.replace(iJsonAttr, lMapResWord.get(iJsonAttr));
            }
            statusResponse = String.valueOf(res.getStatusCode());

            response = (PhoneNumberReservationDTO.IntegrationTestTelephoneInfo)
                    JSON.deserialize(bodyResponse, PhoneNumberReservationDTO.IntegrationTestTelephoneInfo.class);
            
            system.debug('RESPONSE_FONE: '+json.serialize(response));
        } catch (Exception ex) {
            if (param.IsActive__c) {
                system.debug('EXCEPTION: ' + ex.getMessage());
            }
        }
        return response;
    }


    public PhoneNumberReservationDTO.IntegrationTestTelephoneInfo testResponse() {
        String responseJsonString = '{"data": {"telephoneNumbers": [{"number": "1191000000"}]}}';

        responseJsonString = responseJsonString.replaceAll('number', 'number_Z');

        PhoneNumberReservationDTO.IntegrationTestTelephoneInfo response = (PhoneNumberReservationDTO.IntegrationTestTelephoneInfo)
                JSON.deserialize(responseJsonString, PhoneNumberReservationDTO.IntegrationTestTelephoneInfo.class);

        return response;
    }
}