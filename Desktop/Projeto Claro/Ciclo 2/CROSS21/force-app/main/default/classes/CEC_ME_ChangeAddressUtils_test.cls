@isTest
public class CEC_ME_ChangeAddressUtils_test {
    
    @isTest
    static void listParserTest_01() {
        Map<String,Object> options = new Map<String, Object>();
        options.put('SchedulingAction','');
        CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
        Test.startTest();
        testedClass.listParser(options);
        Test.stopTest();

    }

	@isTest
    static void getFilteredScheduledEntitiesTest() {
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> ordersMap = new Map<String,Object>();
        string step3 = '[{"isExempt":false,"orderId":"1900644890","cityId":"06139","contractNumber":"10156217","status":"CRIADA","typeDescription":"MUDANCAENDERECO-INSTALARSERVICOCONEXAOADICDIG","typeId":"55","note":"[INSTALARREPORTBACK][12/08/201919:39OPS$CECNET]SolicitacaoabertaautomaticamentepeloSIGMA.","eventDate":"2019-08-12","orderType":"OC"},{"isExempt":false,"orderId":"1900644889","cityId":"06139","contractNumber":"10156217","status":"CRIADA","typeDescription":"MUDANCADEENDERECO-INSTALARPONTOVOIP","typeId":"84","note":"[12/08/201919:39OPS$CECNET]SolicitacaoabertaautomaticamentepeloSIGMA.","eventDate":"2019-08-12","orderType":"OC"},{"isExempt":false,"orderId":"1900644878","cityId":"06139","contractNumber":"10156217","status":"CRIADA","typeDescription":"MUDANCADEENDERECO-INSTALARPONTOADICIONALVIRTUA","typeId":"45","note":"[12/08/201919:39OPS$CECNET]SolicitacaoabertaautomaticamentepeloSIGMA.","eventDate":"2019-08-12","orderType":"OC"},{"isExempt":false,"orderId":"1900644867","cityId":"06139","contractNumber":"10156217","status":"CRIADA","typeDescription":"MUDANCADEENDERECO-INSTALARASSINATURADIGITAL","typeId":"54","note":"[INSTALARREPORTBACK][12/08/201919:39OPS$CECNET]SolicitacaoabertaautomaticamentepeloSIGMA.","eventDate":"2019-08-12","orderType":"OC"},{"isExempt":false,"orderId":"1900644856","cityId":"06139","contractNumber":"10156217","status":"CRIADA","typeDescription":"MUDANCADEENDERECO-RETIRARPONTOS","typeId":"14","eventDate":"2019-08-12","orderType":"OC"},{"isExempt":false,"terminationDate":"2019-08-12T16:13:42","orderId":"1900592825","cityId":"06139","contractNumber":"10156217","status":"CANCELADA","typeDescription":"RETIRAREQUIPAMENTO","typeId":"5","note":"[12/08/201916:12N5973745]SOLICITACAOABERTAAUTOMATICAMENTE,COMOCANCELAMENTODAINSTALACAODOPONTOADICIONALNAMUDANCADEENDERECO.","eventDate":"2019-08-12","orderType":"OC"},{"isExempt":false,"terminationDate":"2019-08-12T16:13:31","orderId":"1900592803","cityId":"06139","contractNumber":"10156217","status":"CANCELADA","typeDescription":"RETIRAREQUIPAMENTO","typeId":"5","note":"[12/08/201916:12N5973745]SOLICITACAOABERTAAUTOMATICAMENTE,COMOCANCELAMENTODAINSTALACAODOPONTOADICIONALNAMUDANCADEENDERECO.","eventDate":"2019-08-12","orderType":"OC"},{"isExempt":false,"terminationDate":"2019-08-12T16:13:20","orderId":"1900592780","cityId":"06139","contractNumber":"10156217","status":"CANCELADA","typeDescription":"RETIRAREQUIPAMENTO","typeId":"5","note":"[12/08/201916:12N5973745]SOLICITACAOABERTAAUTOMATICAMENTE,COMOCANCELAMENTODAINSTALACAODOPONTOADICIONALNAMUDANCADEENDERECO.","eventDate":"2019-08-12","orderType":"OC"},{"isExempt":false,"terminationDate":"2019-08-12T00:00:00","orderId":"1900590643","cityId":"06139","contractNumber":"10156217","status":"CANCELADA","typeDescription":"MUDANCAENDERECO-INSTALARSERVICOCONEXAOADICDIG","typeId":"55","note":"[INSTALARREPORTBACK][12/08/201916:05OPS$CECNET]SolicitacaoabertaautomaticamentepeloSIGMA.","eventDate":"2019-08-12","orderType":"OC"},{"isExempt":false,"terminationDate":"2019-08-12T00:00:00","orderId":"1900590632","cityId":"06139","contractNumber":"10156217","status":"CANCELADA","typeDescription":"MUDANCADEENDERECO-INSTALARPONTOVOIP","typeId":"84","note":"[12/08/201916:05OPS$CECNET]SolicitacaoabertaautomaticamentepeloSIGMA.","eventDate":"2019-08-12","orderType":"OC"},{"isExempt":false,"terminationDate":"2019-08-12T00:00:00","orderId":"1900590621","cityId":"06139","contractNumber":"10156217","status":"CANCELADA","typeDescription":"MUDANCADEENDERECO-INSTALARPONTOADICIONALVIRTUA","typeId":"45","note":"[12/08/201916:05OPS$CECNET]SolicitacaoabertaautomaticamentepeloSIGMA.","eventDate":"2019-08-12","orderType":"OC"},{"isExempt":false,"terminationDate":"2019-08-12T00:00:00","orderId":"1900590610","cityId":"06139","contractNumber":"10156217","status":"CANCELADA","typeDescription":"MUDANCADEENDERECO-INSTALARASSINATURADIGITAL","typeId":"54","note":"[INSTALARREPORTBACK][12/08/201916:05OPS$CECNET]SolicitacaoabertaautomaticamentepeloSIGMA.","eventDate":"2019-08-12","orderType":"OC"},{"isExempt":false,"terminationDate":"2019-08-12T16:12:22","orderId":"1900590609","cityId":"06139","contractNumber":"10156217","status":"CANCELADA","typeDescription":"MUDANCADEENDERECO-RETIRARPONTOS","typeId":"14","eventDate":"2019-08-12","orderType":"OC"}]';
        List<Object> orders = (List<Object>) JSON.deserializeUntyped(step3);
        ordersMap.put('orders', orders);
        options.put('SchedulingAction','A');
        options.put('data',ordersMap);
        options.put('ObservationOnAppointment','Test Note');
       	CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
        Test.startTest();
        testedClass.invokeMethod('getFilteredScheduledEntities',inputMap,outMap, options);
        Test.stopTest();

    }
    
    @isTest
    static void getOpenWorkOrdersCanceladaTest() {
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> ordersMap = new Map<String,Object>();
        string step3 = '[{"isExempt": "false","terminationDate": "2019-06-21T00:00:00","orderId": "1933611373","cityId": "88412","contractNumber": "110163702","status": "CANCELADA","typeDescription": "MUDANCA ENDERECO - INSTALAR SERVICO CONEXAO ADIC DIG","typeId": "55","note": " [INSTALAR REPORT BACK]       [19/06/2019 21:33 OPS$SOAAPP] Solicitacao aberta automaticamente pelo SIGMA.","eventDate": "2019-06-19","orderType": "OC"}]';
        List<Object> orders = (List<Object>) JSON.deserializeUntyped(step3);
        ordersMap.put('orders', orders);
        options.put('data', ordersMap);
        CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
        Test.startTest();
        testedClass.invokeMethod('getOpenWorkOrders',inputMap,outMap, options);
        Test.stopTest();

    }

    @isTest
	static void getOpenWorkOrdersFechadaTest() {
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> ordersMap = new Map<String,Object>();
        string step3 = '[{"isExempt": "false","terminationDate": "2019-06-21T00:00:00","orderId": "1933611373","cityId": "88412","contractNumber": "110163702","status": "FECHADA","typeDescription": "MUDANCA ENDERECO - INSTALAR SERVICO CONEXAO ADIC DIG","typeId": "55","note": " [INSTALAR REPORT BACK]       [19/06/2019 21:33 OPS$SOAAPP] Solicitacao aberta automaticamente pelo SIGMA.","eventDate": "2019-06-19","orderType": "OC"}]';
        List<Object> orders = (List<Object>) JSON.deserializeUntyped(step3);
        ordersMap.put('orders', orders);
        options.put('data', ordersMap);
        CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
        Test.startTest();
        testedClass.invokeMethod('getOpenWorkOrders',inputMap,outMap, options);
        Test.stopTest();

    }

    @isTest
    static void getOpenWorkOrdersCriadaTest() {
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> ordersMap = new Map<String,Object>();
        string step3 = '[{"isExempt": "false","terminationDate": "2019-06-21T00:00:00","orderId": "1933611373","cityId": "88412","contractNumber": "110163702","status": "CRIADA","typeDescription": "MUDANCA ENDERECO - INSTALAR SERVICO CONEXAO ADIC DIG","typeId": "55","note": " [INSTALAR REPORT BACK]       [19/06/2019 21:33 OPS$SOAAPP] Solicitacao aberta automaticamente pelo SIGMA.","eventDate": "2019-06-19","orderType": "OC"}]';
        List<Object> orders = (List<Object>) JSON.deserializeUntyped(step3);
        ordersMap.put('orders', orders);
        options.put('data', ordersMap);
        CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
        Test.startTest();
        testedClass.invokeMethod('getOpenWorkOrders',inputMap,outMap, options);
        Test.stopTest();

    }

    @isTest
    static void getOpenWorkOrdersAgendadaTest() {
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> ordersMap = new Map<String,Object>();
        string step3 = '[{"isExempt": "false","terminationDate": "2019-06-21T00:00:00","orderId": "1933611373","cityId": "88412","contractNumber": "110163702","status": "AGENDADA","typeDescription": "MUDANCA ENDERECO - INSTALAR SERVICO CONEXAO ADIC DIG","typeId": "55","note": " [INSTALAR REPORT BACK]       [19/06/2019 21:33 OPS$SOAAPP] Solicitacao aberta automaticamente pelo SIGMA.","eventDate": "2019-06-19","orderType": "OC"}]';
        List<Object> orders = (List<Object>) JSON.deserializeUntyped(step3);
        ordersMap.put('orders', orders);
        options.put('data', ordersMap);
        CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
        Test.startTest();
        testedClass.invokeMethod('getOpenWorkOrders',inputMap,outMap, options);
        Test.stopTest();

    }

    @isTest
    static void getOpenWorkOrdersDespachadaTest() {
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> ordersMap = new Map<String,Object>();
        string step3 = '[{"isExempt": "false","terminationDate": "2019-06-21T00:00:00","orderId": "1933611373","cityId": "88412","contractNumber": "110163702","status": "DESPACHADA","typeDescription": "MUDANCA ENDERECO - INSTALAR SERVICO CONEXAO ADIC DIG","typeId": "55","note": " [INSTALAR REPORT BACK]       [19/06/2019 21:33 OPS$SOAAPP] Solicitacao aberta automaticamente pelo SIGMA.","eventDate": "2019-06-19","orderType": "OC"}]';
        List<Object> orders = (List<Object>) JSON.deserializeUntyped(step3);
        ordersMap.put('orders', orders);
        options.put('data', ordersMap);
        CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
        Test.startTest();
        testedClass.invokeMethod('getOpenWorkOrders',inputMap,outMap, options);
        Test.stopTest();

    }

    @isTest
    static void getOpenWorkOrdersReagendadaTest() {
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> ordersMap = new Map<String,Object>();
        string step3 = '[{"isExempt": "false","terminationDate": "2019-06-21T00:00:00","orderId": "1933611373","cityId": "88412","contractNumber": "110163702","status": "REAGENDADA","typeDescription": "MUDANCA ENDERECO - INSTALAR SERVICO CONEXAO ADIC DIG","typeId": "55","note": " [INSTALAR REPORT BACK]       [19/06/2019 21:33 OPS$SOAAPP] Solicitacao aberta automaticamente pelo SIGMA.","eventDate": "2019-06-19","orderType": "OC"}]';
        List<Object> orders = (List<Object>) JSON.deserializeUntyped(step3);
        ordersMap.put('orders', orders);
        options.put('data', ordersMap);
        CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
        Test.startTest();
        testedClass.invokeMethod('getOpenWorkOrders',inputMap,outMap, options);
        Test.stopTest();

    }
        @isTest
    static void getOpenWorkOrdersById() {
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        Map<String,Object> ordersMap = new Map<String,Object>();
        string step3 = '[{"isExempt": "false","terminationDate": "2019-06-21T00:00:00","orderId": "1933611373","cityId": "88412","contractNumber": "110163702","status": "REAGENDADA","typeDescription": "MUDANCA ENDERECO - INSTALAR SERVICO CONEXAO ADIC DIG","typeId": "55","note": " [INSTALAR REPORT BACK]       [19/06/2019 21:33 OPS$SOAAPP] Solicitacao aberta automaticamente pelo SIGMA.","eventDate": "2019-06-19","orderType": "OC"}]';
        string id = '1933611373';
        List<Object> orders = (List<Object>) JSON.deserializeUntyped(step3);
        ordersMap.put('orders', orders);
        options.put('data', ordersMap);
        options.put(id, ordersMap);
        CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
        Test.startTest();
        testedClass.invokeMethod('getOpenWorkOrders',inputMap,outMap, options);
        Test.stopTest();

    }
    
    @isTest
    static void getFilteredAssetsByRecordType_test() {
        //String methodName = 'getFilteredAssetsByRecordType';
        Map<String,Object> outMap = new Map<String, Object>();
        //<String, Object> empty = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        //List<Object> assetsList = new List<Object>();
        string step3 = '[{"ExternalID": "2_010_00278373_00009529","Name": "TV","RecordTypeDevName": "CECTV"}, {"ExternalID": "2_010_00278373_00009529","Name": "internet","RecordTypeDevName": "CECInternetMovel"}, {"ExternalID": "2_010_00278373_00009529","Name": "second internet","RecordTypeDevName": "CECInternetFixa"}, {"ExternalID": "2_010_00278373_00009529","Name": "phone","RecordTypeDevName": "CECFixo"}, {"ExternalID": "2_010_00278373_00009529","Name": "mobile","RecordTypeDevName": "CECMovel"}, {"ExternalID": "2_010_00278373_00009529","Name": "second mobile","RecordTypeDevName": "CECMovelPreControle"}]';
        List<Object> responseNode2 = (List<Object>) JSON.deserializeUntyped(step3);
        options.put('Asset',responseNode2);
       	CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
        Test.startTest();
        testedClass.invokeMethod('getFilteredAssetsByRecordType',inputMap,outMap, options);
        Test.stopTest();

    }
    
	@isTest
	static void getFilteredAssets_test() {
		Map<String,Object> outMap = new Map<String, Object>();
		Map<String,Object> options = new Map<String, Object>();
		Map<String,Object> inputMap = new Map<String, Object>();
		string step3 = '[{"pointId":"12345678","pointType":"A","productId":"12345678","productName":"BLEMPRESAS10MCOMTVOUFONEPMEFID","price":"94.90","technologyId":"3","classification":"VTA","productType":"PACOTE","installationDate":"2018-04-12-03:00"},{"pointId":"1111111","pointType":"A","productId":"11111111","productName":"ANALOGIGO/DIGITALTV","price":"94.90","technologyId":"1","classification":"VTA","productType":"PACOTE","installationDate":"2018-04-12-03:00"},{"pointId":"2222222","pointType":"A","productId":"2222222","productName":"FONEFIXO","price":"94.90","technologyId":"4","classification":"VTA","productType":"PACOTE","installationDate":"2018-04-12-03:00"}]';
		List<Object> responseNode2 = (List<Object>) JSON.deserializeUntyped(step3);
		options.put('Asset',responseNode2);
		CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
		testedClass.invokeMethod('getFilteredAssets',inputMap,outMap, options);
		Test.stopTest();
	}

	@isTest
	static void getFilteredAssetsByRecordType_test2() {
		//String methodName = 'getAddressViabilityStatus';
		Map<String,Object> outMap = new Map<String, Object>();
		//Map<String, Object> empty = new Map<String, Object>();
		Map<String,Object> options = new Map<String, Object>();
		Map<String,Object> inputMap = new Map<String, Object>();
		//List<Object> assetsList = new List<Object>();
		//string step3 = '[{"ExternalID": "2_010_00278373_00009529","Name": "TV","RecordTypeDevName": "CECTV"}, {"ExternalID": "2_010_00278373_00009529","Name": "internet","RecordTypeDevName": "CECInternetMovel"}, {"ExternalID": "2_010_00278373_00009529","Name": "second internet","RecordTypeDevName": "CECInternetFixa"}, {"ExternalID": "2_010_00278373_00009529","Name": "phone","RecordTypeDevName": "CECFixo"}, {"ExternalID": "2_010_00278373_00009529","Name": "mobile","RecordTypeDevName": "CECMovel"}, {"ExternalID": "2_010_00278373_00009529","Name": "second mobile","RecordTypeDevName": "CECMovelPreControle"}]';
		//List<Object> responseNode2 = (List<Object>) JSON.deserializeUntyped(step3);
		String step31 = '[{"TechnicalViability":{"TechValMoveInAddress": "Paulistânia, SP, 17150-000, Brasil","TechValViabilityStatus": "","TechValAddressStateNote": null},"Scheduling": {"ObservationOnAppointment": null,"NoDateHourSelected": null,"Scheduling_ContactPreferences": null,"Scheduling_ContactMovil": null,"Scheduling_ContactEmail": null,"MobileNumberFormula": null,"Scheduling_MobileNumberValidation": null}}]';
		list<Object> lstStep3 = (List<Object>) JSON.deserializeUntyped(step31);
		options.put('listAvailableServices',lstStep3);
		CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			testedClass.invokeMethod('getAddressViabilityStatus', inputMap, outMap, options);
		Test.stopTest();
	}

	@isTest
	static void getFilteredAssetsByRecordType_test19() {
	  //String methodName = 'getAddressViabilityStatus';
	  Map<String,Object> outMap = new Map<String, Object>();
	  //Map<String, Object> empty = new Map<String, Object>();
	  Map<String,Object> options = new Map<String, Object>();
	  Map<String,Object> inputMap = new Map<String, Object>();
	  //List<Object> assetsList = new List<Object>();
	  //string step3 = '[{"ExternalID": "2_010_00278373_00009529","Name": "TV","RecordTypeDevName": "CECTV"}, {"ExternalID": "2_010_00278373_00009529","Name": "internet","RecordTypeDevName": "CECInternetMovel"}, {"ExternalID": "2_010_00278373_00009529","Name": "second internet","RecordTypeDevName": "CECInternetFixa"}, {"ExternalID": "2_010_00278373_00009529","Name": "phone","RecordTypeDevName": "CECFixo"}, {"ExternalID": "2_010_00278373_00009529","Name": "mobile","RecordTypeDevName": "CECMovel"}, {"ExternalID": "2_010_00278373_00009529","Name": "second mobile","RecordTypeDevName": "CECMovelPreControle"}]';
	  //List<Object> responseNode2 = (List<Object>) JSON.deserializeUntyped(step3);
	  String step31 = '[{"TechnicalViability":"Sim"}]';
	  list<Object> lstStep3 = (List<Object>) JSON.deserializeUntyped(step31);
	  options.put('listAvailableServices',lstStep3);
	  CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
	  Test.startTest();
		testedClass.invokeMethod('getAddressViabilityStatus', inputMap, outMap, options);
	  Test.stopTest();
	}
    
    @isTest
	static void getAddressGEDTransformTest() {
	  Map<String,Object> outMap = new Map<String, Object>();
	  Map<String,Object> options = new Map<String, Object>();
	  Map<String,Object> inputMap = new Map<String, Object>();
	  String edificationString = '[{"domiciles":[{"locations":[],"availability":[],"requestSituationDate":null,"requestSituation":null,"installationsAmount":null,"roomsAmount":null,"tvPointsAmount":null,"domicileType":null,"number":null,"description":null,"id":"638589850"}],"address":{"preposition":null,"patentTitle":null,"neighborhoodId":"129","streetTitle":"S","boxNr":null,"sanitized":null,"complementarySubAddress":null,"urbanPropertySubAddress":"APTSN","streetNumber":"101","streetName":"FRANCISCO","streetId":"1275","streetType":"R","neighborhood":"VILABELAFLOR","postalCode":"8745250","city":"MOGIDASCRUZES","cityId":"05856","placeId":"SP","country":"BRASIL","addressId":null},"cablingType":null,"edificationType":"RESIDENCIAL","node":null,"numberOfInstallRealized":null,"numberOfInstallPreview":null,"numberOfDomicilesRealized":null,"numberOfDomicilesPreview":null,"description":null,"edificationId":"638589849"},{"domiciles":[{"locations":[],"availability":[],"requestSituationDate":null,"requestSituation":null,"installationsAmount":null,"roomsAmount":null,"tvPointsAmount":null,"domicileType":null,"number":null,"description":null,"id":"638898773"}],"address":{"preposition":null,"patentTitle":null,"neighborhoodId":"129","streetTitle":"S","boxNr":null,"sanitized":null,"complementarySubAddress":null,"urbanPropertySubAddress":"BL14,APT2","streetNumber":"101","streetName":"FRANCISCO","streetId":"1275","streetType":"R","neighborhood":"VILABELAFLOR","postalCode":"8745250","city":"MOGIDASCRUZES","cityId":"05856","placeId":"SP","country":"BRASIL","addressId":null},"cablingType":null,"edificationType":"RESIDENCIAL","node":null,"numberOfInstallRealized":null,"numberOfInstallPreview":null,"numberOfDomicilesRealized":null,"numberOfDomicilesPreview":null,"description":null,"edificationId":"638898774"}]';
	  list<Object> edifications = (List<Object>) JSON.deserializeUntyped(edificationString);
	  options.put('edifications',edifications);
	  CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
	  Test.startTest();
		testedClass.invokeMethod('getAddressGEDTransform', inputMap, outMap, options);
	  Test.stopTest();
	}

	@isTest
	static void getFilteredAssetsByRecordType_test4() {
		//String methodName = 'getTechValContractStatus';
		Map<String,Object> outMap = new Map<String, Object>();
		//Map<String, Object> empty = new Map<String, Object>();
		Map<String,Object> options = new Map<String, Object>();
		Map<String,Object> inputMap = new Map<String, Object>();
		String strJsonInput = '[{"city": "São Paulo","id": "5438120","type": "5438120","status": "Aberta, Conectado","name": "Maria do Carmo","telephoneNumber": "11978654567","installationAddress": "Rua Verbo Divino, 1344 - APto 12","partyIdentificationType": "CPF","partyIdentificationNumber": "12356789034"}]';
		List<Object> lstStep3 = (List<Object>) JSON.deserializeUntyped(strJsonInput);
		options.put('domicileHistory',lstStep3);
		CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			testedClass.invokeMethod('getTechValContractStatus', inputMap, outMap, options);
		Test.stopTest();
	}
    
    @isTest
	static void getTechValContractStatus_test1() {
		//String methodName = 'getTechValContractStatus';
		Map<String,Object> outMap = new Map<String, Object>();
		//Map<String, Object> empty = new Map<String, Object>();
		Map<String,Object> options = new Map<String, Object>();
		Map<String,Object> inputMap = new Map<String, Object>();
		String strJsonInput = '[{"city": "São Paulo","id": "5438120","type": "CONTRATO","status": "Conectado","name": "Maria do Carmo","telephoneNumber": "11978654567","installationAddress": "Rua Verbo Divino, 1344 - APto 12","partyIdentificationType": "CPF","partyIdentificationNumber": "12356789034"}]';
		List<Object> lstStep3 = (List<Object>) JSON.deserializeUntyped(strJsonInput);
		options.put('domicileHistory',lstStep3);
		CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			testedClass.invokeMethod('getTechValContractStatus', inputMap, outMap, options);
		Test.stopTest();
	}
     @isTest
	static void getTechValContractStatus_test2() {
		//String methodName = 'getTechValContractStatus';
		Map<String,Object> outMap = new Map<String, Object>();
		//Map<String, Object> empty = new Map<String, Object>();
		Map<String,Object> options = new Map<String, Object>();
		Map<String,Object> inputMap = new Map<String, Object>();
		String strJsonInput = '[{"city": "São Paulo","id": "5438120","type": "CONTRATO","status": "Desabilitado","name": "Maria do Carmo","telephoneNumber": "11978654567","installationAddress": "Rua Verbo Divino, 1344 - APto 12","partyIdentificationType": "CPF","partyIdentificationNumber": "12356789034"}]';
		List<Object> lstStep3 = (List<Object>) JSON.deserializeUntyped(strJsonInput);
		options.put('domicileHistory',lstStep3);
		CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			testedClass.invokeMethod('getTechValContractStatus', inputMap, outMap, options);
		Test.stopTest();
	}

	@isTest
	static void getFilteredAssetsByRecordType_test20() {
		// methodName = 'getTechValContractStatus';
		Map<String,Object> outMap = new Map<String, Object>();
		//Map<String, Object> empty = new Map<String, Object>();
		Map<String,Object> options = new Map<String, Object>();
		Map<String,Object> inputMap = new Map<String, Object>();
		String strJsonInput = '[{"city": "São Paulo","id": "5438120","type": "5438120","status": "Fechada","name": "Maria do Carmo","telephoneNumber": "11978654567","installationAddress": "Rua Verbo Divino, 1344 - APto 12","partyIdentificationType": "CPF","partyIdentificationNumber": "12356789034"}]';
		List<Object> lstStep3 = (List<Object>) JSON.deserializeUntyped(strJsonInput);
		options.put('domicileHistory',lstStep3);
		CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			testedClass.invokeMethod('getTechValContractStatus', inputMap, outMap, options);
		Test.stopTest();
	}

	@isTest
	static void sendContractInconsistencies_test01() {
		//String methodName = 'sendContractInconsistencies';
		Map<String,Object> inputMap = new Map<String, Object>();
		Map<String,Object> outMap = new Map<String, Object>();
		Map<String,Object> options = new Map<String, Object>();

		Id recordTypeIdME = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Mudança de Endereço').getRecordTypeId();

		//Nuevo Caso
		Case testCase = new Case(
			Status = 'New',
			RecordTypeId = recordTypeIdME
		);
		insert testCase;

		//Nuevo Customer Interaction
		vlocity_cmt__CustomerInteraction__c testCustInteraction = new vlocity_cmt__CustomerInteraction__c();
		insert testCustInteraction;

		String stringOccurrence = '[{"OccurrenceObservation": "Cliente com contrato n° , solicita mudança de endereço, porém, o sistema não permite a mudança de endereço devido a status NET Fone / Claro Fone.","OccurrenceStatus": "ABERTA","OccurrenceTypeId": "1989","OccurrenceType": "ME10 - REGULARIZAR CONTRATO OS/OC/CHAMADO ME","OccurrenceGroup": "SE1 - SERVICOS","Name": "Status Embratel"}]';
		List<Object> listOccurrences = (List<Object>) JSON.deserializeUntyped(stringOccurrence);
		options.put('contractInconsistencies', listOccurrences);
		options.put('protocolNumber', '004193054792279');
		options.put('operatorCode', '004');
		options.put('interactionNumber', '322722528');
		options.put('contractNumber', '10332171');
		options.put('caseId', testCase.Id);
		options.put('customerInteractionId', testCustInteraction.Id);
		CEC_ME_ChangeAddressUtils testedClass = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			testedClass.invokeMethod('sendContractInconsistencies', inputMap, outMap, options);
		Test.stopTest();
	}

	@isTest
	static void getFilteredAssetsByRecordType_test21() {
		//String strMethodName = 'getTechValAddressStatus';
		Map<String, object> outMap = new Map<String, object>();
		Map<String,Object> inputMap = new Map<String, Object>();
		Map<String,Object> options = new Map<String, Object>();
		String geoGraphicLocationResponse = '[{"TechnicalViability":"ComercialOK","CommercialViability":"TécnicaOK","ServiceType":"TVDIGITAL"},{"TechnicalViability":"ComercialOK","CommercialViability":"TécnicaOK","ServiceType":"BSOD"},{"TechnicalViability":"ComercialNãoOK","CommercialViability":"TécnicaNãoOK","ServiceType":"VIDEOONDEMAND"},{"TechnicalViability":"ComercialOK","CommercialViability":"TécnicaOK","ServiceType":"FONE"},{"TechnicalViability":"ComercialOK","CommercialViability":"TécnicaOK","ServiceType":"PAYTV"},{"TechnicalViability":"ComercialOK","CommercialViability":"TécnicaOK","ServiceType":"INTERNETVIACABO"}]';
		String noteDomicile = 'Status da HP: ENDERECO OK\nData ultima analise GED: 11/09/2012 00:00:00\nObservacao do Imovel: \n';
		Object lstStep3 = (Object) JSON.deserializeUntyped(geoGraphicLocationResponse);
		options.put('GeographicLocationsResponse',lstStep3);
		options.put('noteDomicile',noteDomicile);
		CEC_ME_ChangeAddressUtils testCustomeResponse = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			testCustomeResponse.invokeMethod('getTechValAddressStatus', inputMap, outMap, options);
			System.assertEquals('Endereço OK', outMap.get('Status'));
		Test.stopTest();
	}

	@isTest
	static void getFilteredAssetsByRecordType_test22() {
		//String strMethodName = 'getTechValAddressStatus';
		Map<String, object> outMap = new Map<String, object>();
		Map<String,Object> inputMap = new Map<String, Object>();
		Map<String,Object> options = new Map<String, Object>();
		String geoGraphicLocationResponse = '[{"TechnicalViability":"ComercialOK","CommercialViability":"TécnicaOK","ServiceType":"TVDIGITAL"},{"TechnicalViability":"ComercialOK","CommercialViability":"TécnicaOK","ServiceType":"BSOD"},{"TechnicalViability":"ComercialNãoOK","CommercialViability":"TécnicaNãoOK","ServiceType":"VIDEOONDEMAND"},{"TechnicalViability":"ComercialOK","CommercialViability":"TécnicaOK","ServiceType":"FONE"},{"TechnicalViability":"ComercialOK","CommercialViability":"TécnicaOK","ServiceType":"PAY TV"},{"TechnicalViability":"ComercialOK","CommercialViability":"TécnicaOK","ServiceType":"INTERNETVIACABO"}]';
		String noteDomicile = '';
		Object lstStep3 = (Object) JSON.deserializeUntyped(geoGraphicLocationResponse);
		options.put('GeographicLocationsResponse',lstStep3);
		options.put('noteDomicile',noteDomicile);
		CEC_ME_ChangeAddressUtils testCustomeResponse = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			testCustomeResponse.invokeMethod('getTechValAddressStatus', inputMap, outMap, options);
			System.assertEquals('Endereço OK', outMap.get('Status'));
		Test.stopTest();
	}
	
	@isTest
	static void getDiffDate_test() {
	  Map<String, object> outMap = new Map<String, object>();
	  Map<String,Object> inputMap = new Map<String, Object>();
	  Map<String,Object> options = new Map<String, Object>();
	  String originDate = String.valueOf(Date.newInstance(2016, 12, 9));
	  options.put('originDate', originDate);
	  options.put('diffDays', '1');
	  CEC_ME_ChangeAddressUtils testCustomeResponse = new CEC_ME_ChangeAddressUtils();
	  Test.startTest();
		  testCustomeResponse.invokeMethod('getDiffDate', inputMap, outMap, options);
		  System.assertEquals('2016-12-10', outMap.get('diffDate'));
	  Test.stopTest();
	}

	@isTest
	static void getCancellationWorkOrderSchedule_test() {
		//String strMethodName = 'getCancellationWorkOrderSchedule';
		Map<String, object> outMap = new Map<String, object>();
		Map<String,Object> inputMap = new Map<String, Object>();
		Map<String,Object> options = new Map<String, Object>();
		String orders ='[{"isExempt":"false","terminationDate":"2019-06-21T00:00:00","orderId":"1933611373","cityId":"88412","contractNumber":"110163702","status":"CANCELADA","typeDescription":"MUDANCAENDERECO-INSTALARSERVICOCONEXAOADICDIG","typeId":"55","note":"[INSTALARREPORTBACK][19/06/201921:33OPS$SOAAPP]SolicitacaoabertaautomaticamentepeloSIGMA.","eventDate":"2019-06-19","orderType":"OC"},{"isExempt":"false","terminationDate":"2019-06-21T00:00:00","orderId":"1933611362","cityId":"88412","contractNumber":"110163702","status":"CANCELADA","typeDescription":"MUDANCADEENDERECO-INSTALARASSINATURADIGITAL","typeId":"54","note":"[INSTALARREPORTBACK][19/06/201921:33OPS$SOAAPP]SolicitacaoabertaautomaticamentepeloSIGMA.","eventDate":"2019-06-19","orderType":"OC"},{"isExempt":"false","terminationDate":"2019-06-21T11:34:00","orderId":"1933611351","cityId":"88412","contractNumber":"110163702","status":"CANCELADA","typeDescription":"MUDANCADEENDERECO-RETIRARPONTOS","typeId":"14","eventDate":"2019-06-19","orderType":"OC"},{"isExempt":"false","terminationDate":"2019-06-21T14:19:51","orderId":"1933611238","cityId":"88412","contractNumber":"110163702","status":"CANCELADA","typeDescription":"RETIRAREQUIPAMENTO","typeId":"5","note":"[19/06/201919:19OPS$OSWAP]SOLICITACAOABERTAAUTOMATICAMENTE,COMOCANCELAMENTODAINSTALACAODOPONTOADICIONALNAMUDANCADEENDERECO.","eventDate":"2019-06-19","orderType":"OC"},{"isExempt":"false","terminationDate":"2019-06-19T00:00:00","orderId":"1933611115","cityId":"88412","contractNumber":"110163702","status":"CANCELADA","typeDescription":"MUDANCAENDERECO-INSTALARSERVICOCONEXAOADICDIG","typeId":"55","note":"[Agendamentopara23/06/2019(NAOUTILIZAR2)feitoporMCIDAem19/06/201916:35:10][INSTALARREPORTBACK][19/06/201909:19OPS$SOAAPP]SolicitacaoabertaautomaticamentepeloSIGMA.","eventDate":"2019-06-19","orderType":"OC"},{"isExempt":"false","terminationDate":"2019-06-19T00:00:00","orderId":"1933611104","cityId":"88412","contractNumber":"110163702","status":"CANCELADA","typeDescription":"MUDANCADEENDERECO-INSTALARASSINATURADIGITAL","typeId":"54","note":"[Agendamentopara23/06/2019(NAOUTILIZAR2)feitoporMCIDAem19/06/201916:35:10][INSTALARREPORTBACK][19/06/201909:19OPS$SOAAPP]SolicitacaoabertaautomaticamentepeloSIGMA.","eventDate":"2019-06-19","orderType":"OC"},{"isExempt":"true","terminationDate":"2019-06-19T19:19:54","orderId":"1933611092","cityId":"88412","contractNumber":"110163702","status":"CRIADA","typeDescription":"MUDANCADEENDERECO-RETIRARPONTOS","typeId":"14","note":"[19/06/201919:19OPS$OSWAP]REVISTA=NAOOK,TELEFONE=NAOOK[Agendamentopara23/06/2019(NAOUTILIZAR2)feitoporMCIDAem19/06/201916:33:12]","eventDate":"2019-06-19","orderType":"OC"}]'; 
		List<Object> ordersNode= (List<Object>)JSON.deserializeUntyped(orders);
		options.put('orders',ordersNode);
		CEC_ME_ChangeAddressUtils testCustomeResponse = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			testCustomeResponse.invokeMethod('getCancellationWorkOrderSchedule', inputMap, outMap, options);
			Map<String, object> cancellationOrder = (Map<String, object>)outMap.get('CancellationOrder');
			String isExempt= String.valueOf(cancellationOrder.get('isExempt'));
			System.assertEquals('true', isExempt);
		Test.stopTest();
	}

	@isTest
	static void getCasePaymentPlanValueLabel_Test1() {
		Map<String, object> outMap = new Map<String, object>();
		Map<String,Object> inputMap = new Map<String, Object>();
		Map<String,Object> options = new Map<String, Object>();
		options.put('valueSelected', '5');
		CEC_ME_ChangeAddressUtils testCustomeResponse = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			testCustomeResponse.invokeMethod('getCasePaymentPlanValueLabel', inputMap, outMap, options);
		Test.stopTest();
		System.assertEquals('R$ 45,00 x 2 vezes S/Juros', outMap.get('PaymentPlanLabel'));        
	}
	
	@isTest
	static void getCasePaymentPlanValueLabel_Test2() {
		Map<String, object> outMap = new Map<String, object>();
		Map<String,Object> inputMap = new Map<String, Object>();
		Map<String,Object> options = new Map<String, Object>();
		options.put('valueSelected', '1');
		CEC_ME_ChangeAddressUtils testCustomeResponse = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			testCustomeResponse.invokeMethod('getCasePaymentPlanValueLabel', inputMap, outMap, options);
		Test.stopTest();
		System.assertEquals('R$ 90,00 à vista', outMap.get('PaymentPlanLabel'));        
	}

	@isTest
	static void getCasePaymentPlanValueLabel_Test3() {
		Map<String, object> outMap = new Map<String, object>();
		Map<String,Object> inputMap = new Map<String, Object>();
		Map<String,Object> options = new Map<String, Object>();
		options.put('valueSelected', '26');
		CEC_ME_ChangeAddressUtils testCustomeResponse = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			testCustomeResponse.invokeMethod('getCasePaymentPlanValueLabel', inputMap, outMap, options);
		Test.stopTest();
		System.assertEquals('R$ 15,00 x 6 vezes S/Juros', outMap.get('PaymentPlanLabel'));
	}

	@isTest
	static void getOccurrencesConfig_01() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('ChangeAddress', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('Registro de Ocorrência', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}

	@isTest
	static void getOccurrencesConfig_02() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('Rescheduling', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('Reagendamento', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}

	@isTest
	static void getOccurrencesConfig_03() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('Cancellation', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('Cancelamento', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}

	//@isTest
	/*static void getOccurrencesConfig_04() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('Requests', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('OC/OS em aberto', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}*/

	@isTest
	static void getOccurrencesConfig_05() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('Debits', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('Débito de Contrato', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}

	@isTest
	static void getOccurrencesConfig_06() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('Portability', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('Status do Telefone', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}

	@isTest
	static void getOccurrencesConfig_07() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('Embratel', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('Status Embratel', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}

	@isTest
	static void getOccurrencesConfig_08() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('Suspension', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('Suspensão temporária', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}

	@isTest
	static void getOccurrencesConfig_09() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('SearchAddress', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('Pesquisa de endereço destino', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}

	@isTest
	static void getOccurrencesConfig_10() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('GEDOfflineAddress', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('Viabilidade Técnica Offline', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}

	@isTest
	static void getOccurrencesConfig_11() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('GEDAddressFail', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('Viabilidade Técnica', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}

	@isTest
	static void getOccurrencesConfig_12() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('GEDOfflineContract', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('Viabilidade Técnica Offline', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}

	@isTest
	static void getOccurrencesConfig_13() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('GEDContractFail', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('Viabilidade Técnica Online', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}
	@isTest
	static void getOccurrencesConfig_14() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('COPOnlineBaixaOSFail', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('OS em Aberto - COP.', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}
    @isTest
	static void getOccurrencesConfig_15() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('COPExcedido', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('OS em Aberto - COP.', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}
    @isTest
	static void getOccurrencesConfig_16() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('COPOfflineBaixaOSBKO', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('OS em Aberto - COP.', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}
    @isTest
	static void getOccurrencesConfig_17() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('OSCOPNaoElegivel', arguments);
		options.put('Occurrences', occurrences);

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('OS em Aberto - COP.', String.valueOf(occurrenceSetting.get('Name')));
		Test.stopTest();
	}
	//@isTest
	/*static void getOccurrencesConfig_14() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		Map<String, Object> occurrences = new Map<String, Object>();
		List<Object> arguments = new List<Object>{'ParamTest'};
		occurrences.put('Requests', arguments);
		options.put('Occurrences', occurrences);
		options.put('Prescheduling', true);
		options.put('data', 'dataTest');
		options.put('period', 'periodTest');

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getOccurrencesConfig', input, output, options);

			List<Object> listOccurrences = (List<Object>) output.get('ContractOccurrences');
			System.debug('occurrences: ' + JSON.serialize(listOccurrences));
			//System.assert(listOccurrences.size() == 1);
			Map<String, Object> occurrenceSetting = (Map<String, Object>) listOccurrences.get(0);
			System.assertEquals('OC/OS em aberto', String.valueOf(occurrenceSetting.get('Name')));
			System.assert(String.valueOf(occurrenceSetting.get('OccurrenceObservation')).contains('Preagendamento'));
		Test.stopTest();
	}*/

	@isTest
	static void getInconsistenciesMap_01() {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		Map<String, Object> options = new Map<String, Object>();
		//Map<String, Object> mapRequests = new Map<String, Object>();
		Map<String, Object> mapDebits = new Map<String, Object>();
		Map<String, Object> mapPortability = new Map<String, Object>();
		Map<String, Object> mapEmbratel = new Map<String, Object>();
		Map<String, Object> mapTemporarySuspension = new Map<String, Object>();
		//mapRequests.put('data', 'test');
		List<Object> debitList = (List<Object>) JSON.deserializeUntyped('[{"value": 107.4,"dueDate": "29/08/2019","issueDate": "06/07/2017","contractID": 110039401,"cityID": "88412","id": 290073684}]');
		mapDebits.put('data',debitList);
		String contractNumberTest = '1234567890';
		//options.put('Requests', mapRequests);
		options.put('Debits', mapDebits);
		options.put('Portability', mapPortability);
		options.put('Embratel', mapEmbratel);
		options.put('TemporarySuspension', mapTemporarySuspension);
		options.put('ContractNumber', contractNumberTest);
		options.put('data', 'test');

		CEC_ME_ChangeAddressUtils CAU = new CEC_ME_ChangeAddressUtils();
		Test.startTest();
			CAU.invokeMethod('getInconsistenciesMap', input, output, options);
			System.debug('test: ' + JSON.serialize(output));
			Map<String, Object> respOccurrences = (Map<String, Object>) output.get('Occurrences');
			//List<Object> respRequests = (List<Object>) respOccurrences.get('Requests');
			//System.debug('test: ' + JSON.serialize(respRequests));
		//System.assertEquals(contractNumberTest, String.valueOf(respRequests.get(0)));
			//System.assertEquals(true, output.get('HasInconsistences'));
			//System.assertEquals(true, output.get('HasBlockingInconsistences'));
		Test.stopTest();
	}

	
}