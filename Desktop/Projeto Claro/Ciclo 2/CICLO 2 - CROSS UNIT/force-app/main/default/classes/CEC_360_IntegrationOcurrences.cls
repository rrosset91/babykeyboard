/*
 * Autor: [Letícia Freitas] + [Deloitte]
 * Data: [02/10/2019]
 * Descrição: [Nome do projeto/ID: CEC FASE 1 ] + [Time: SQUAD 360 - Sprint 13] +
 * [Classe apex para a chamada via integração de objetos.]
 *--------------------------------------------------------------------------------*
 */

public class CEC_360_IntegrationOcurrences {
	@AuraEnabled
	public static List<CEC_RestObjects.ocurrencesObj> getOcurrences(String contractNumber, String operatorCode, String startDate, String endDate) {
		CEC_RestObjects.occurrencesResponse occurrencesResponse = new CEC_RestObjects.occurrencesResponse();

		List<Cec_RestObjects.ocurrencesObj> lstOcr = new List<CEC_RestObjects.ocurrencesObj>();
		String service;
		if(!Test.isRunningTest()) {
			service = CEC_360_ServiceName.getServiceName('contactRecords');
		} else {
			service = '/contactrecords';
		}

		try {
            HTTPRequest request = new HTTPRequest();
				request.setEndpoint('callout:OAGClaro' + service +
							    '?contractNumber=' + contractNumber +
							    '&operatorCode=' + operatorCode +
							    '&startDate=' + startDate + '&endDate=' + endDate + '&page=5');
                                system.debug('entrou1');
			
            request.setMethod('GET');
			request.setTimeout(120000);

			HTTP http = new HTTP();
			HTTPResponse response = http.send(request);
			String responseBody = response.getBody();
			system.debug('responseBody' + responseBody);
			system.debug(response.getStatus());
			if(response.getStatusCode() == 200) {
				occurrencesResponse = (CEC_RestObjects.occurrencesResponse) JSON.deserialize(responseBody.replace('\"number\"','\"number_Z\"' ), CEC_RestObjects.occurrencesResponse.class);
				lstOcr = occurrencesResponse.data.data;
			}

		} 
		catch(CalloutException e) {
			System.debug('ERROR: ' + e);

		}
		system.debug('lstOcr: ' +lstOcr);
		return lstOcr;
	}

	public static String formatData(String data) {
		String dataAux;
		if(data != null && string.isNotBlank(data) && string.isNotEmpty(data)) {
			if(data.contains('T')) {
				dataAux = data.substring(8, 10) + '/' + data.substring(5, 7) + '/' +
				data.substring(0, 4) + ' às ' + data.substring(11, 16);
			} else {
				dataAux = data.substring(8, 10) + '/' + data.substring(5, 7) + '/' +
				data.substring(0, 4);
			}
		} else {
			dataAux= '--';
		}
		return dataAux;
	}

	public static CEC_RestObjects.occurrencesResponse generateMock() {
		CEC_RestObjects.occurrencesResponse objResponse = new CEC_RestObjects.occurrencesResponse();
		objResponse.apiVersion = '1';
		objResponse.transactionId = '1';
		CEC_RestObjects.ocurrencesData objData = new CEC_RestObjects.ocurrencesData();
		List<CEC_RestObjects.ocurrencesObj> lstOcurrences = new List<CEC_RestObjects.ocurrencesObj>();

		for (integer i = 0; i <= 5; i ++) {
			CEC_RestObjects.ocurrencesObj objOcurrences = new CEC_RestObjects.ocurrencesObj();
			objOcurrences.customerAccountId = '3456789';
			objOcurrences.number_Z = '23456790';
			objOcurrences.loginOpening = 'PROD_JD';
			objOcurrences.loginClosing = 'PROD_JD';
			objOcurrences.creationDate = '2019-01-03T16:26:55';
			objOcurrences.resolutionDate = '2019-01-03T16:26:55';
			objOcurrences.returnDate = '2019-01-03T16:26:55';
			objOcurrences.name = 'Jose Carlos' + string.valueOf(i);
			objOcurrences.phoneLineNumber = '5512981277410';
			objOcurrences.originId = '257';
			objOcurrences.areaOrigin = 'Padronização.';
			objOcurrences.groupTypeId = '9';
			objOcurrences.groupTypeDescription = 'F11 - Cobrança';
			objOcurrences.typeId = '1617';
			objOcurrences.typeDescription = 'FC12';
			objOcurrences.status = '1';
			objOcurrences.note = 'Notação';
			objOcurrences.attendanceNumber = '1';
			objOcurrences.description = 'Atendimento Informou';
			objOcurrences.protocolNumber = '12872712';
			lstOcurrences.add(objOcurrences);
		}

		objData.data = lstOcurrences;
		objResponse.data = objData;

		return objResponse;
	}

}