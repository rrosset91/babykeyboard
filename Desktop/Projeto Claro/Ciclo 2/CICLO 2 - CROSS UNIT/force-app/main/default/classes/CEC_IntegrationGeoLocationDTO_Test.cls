@IsTest
public class CEC_IntegrationGeoLocationDTO_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'   \"apiVersion\": \"1;2019-06-06\",'+
		'   \"transactionId\": \"Id-1aef325e289da594cf704b37\",'+
		'   \"data\": {\"domiciles\":[{\"id\":\"501844231\",\"description\":\"PSG PARTICULAR B     5\",\"noteDomicile\":\"Motivo Bloqueio PayTV: INVIABILIDADE COMERCIAL DA AREA\\nMotivo Bloqueio Tv Digital: INVIABILIDADE COMERCIAL DA AREA\\nStatus da HP: ENDERECO OK\\nData ultima analise GED: 11/09/2012 00:00:00\\nObservacao do Imovel: \\n\",\"nodeCharacteristic\":\"Ativado, retorno ativo e codificado com IPV4 NAT\",\"number\":\"5 \",\"domicileType\":\"1\",\"domicileTypeDescription\":\"SDU\",\"availability\":[{\"technicalSituation\":\"Técnica OK\",\"commercialSituation\":\"Comercial OK\",\"technicalSituationNote\":\"\",\"commercialSituationNote\":\"\",\"businessLine\":{\"id\":6,\"description\":\"BSOD\",\"businessLineFeatures\":{\"description\":\"BSOD\"}}},{\"technicalSituation\":\"Técnica Não OK\",\"commercialSituation\":\"Comercial Não OK\",\"technicalSituationNote\":\"TECNICO_ENDERECO_BLOQUEADO\",\"commercialSituationNote\":\"\",\"businessLine\":{\"id\":1,\"description\":\"PTV\",\"businessLineFeatures\":{\"description\":\"PAY TV\"}}},{\"technicalSituation\":\"Técnica OK\",\"commercialSituation\":\"Comercial OK\",\"technicalSituationNote\":\"\",\"commercialSituationNote\":\"\",\"businessLine\":{\"id\":4,\"description\":\"VOIP\",\"businessLineFeatures\":{\"description\":\"FONE\"}}},{\"technicalSituation\":\"Técnica Não OK\",\"commercialSituation\":\"Comercial Não OK\",\"technicalSituationNote\":\"\",\"commercialSituationNote\":\"\",\"businessLine\":{\"id\":100,\"description\":\"VOD\",\"businessLineFeatures\":{\"description\":\"VIDEO ON DEMAND\"}}},{\"technicalSituation\":\"Técnica Não OK\",\"commercialSituation\":\"Comercial Não OK\",\"technicalSituationNote\":\"TECNICO_ENDERECO_BLOQUEADO\",\"commercialSituationNote\":\"\",\"businessLine\":{\"id\":3,\"description\":\"DIGITAL\",\"businessLineFeatures\":{\"description\":\"TV DIGITAL\"}}},{\"technicalSituation\":\"Técnica OK\",\"commercialSituation\":\"Comercial OK\",\"technicalSituationNote\":\"\",\"commercialSituationNote\":\"\",\"businessLine\":{\"id\":2,\"description\":\"VIRTUA\",\"businessLineFeatures\":{\"description\":\"INTERNET VIA CABO\"}}}],\"node\":\"JDSI\"},{\"id\":\"501844231\",\"description\":\"PSG PARTICULAR B     5\",\"noteDomicile\":\"Motivo Bloqueio PayTV: INVIABILIDADE COMERCIAL DA AREA\\nMotivo Bloqueio Tv Digital: INVIABILIDADE COMERCIAL DA AREA\\nStatus da HP: ENDERECO OK\\nData ultima analise GED: 11/09/2012 00:00:00\\nObservacao do Imovel: \\n\",\"nodeCharacteristic\":\"Ativado, retorno ativo e codificado com IPV4 NAT\",\"number\":\"5 \",\"domicileType\":\"1\",\"domicileTypeDescription\":\"SDU\",\"availability\":[{\"technicalSituation\":\"Técnica OK\",\"commercialSituation\":\"Comercial OK\",\"technicalSituationNote\":\"\",\"commercialSituationNote\":\"\",\"businessLine\":{\"id\":6,\"description\":\"BSOD\",\"businessLineFeatures\":{\"description\":\"BSOD\"}}},{\"technicalSituation\":\"Técnica Não OK\",\"commercialSituation\":\"Comercial Não OK\",\"technicalSituationNote\":\"TECNICO_ENDERECO_BLOQUEADO\",\"commercialSituationNote\":\"\",\"businessLine\":{\"id\":1,\"description\":\"PTV\",\"businessLineFeatures\":{\"description\":\"PAY TV\"}}},{\"technicalSituation\":\"Técnica OK\",\"commercialSituation\":\"Comercial OK\",\"technicalSituationNote\":\"\",\"commercialSituationNote\":\"\",\"businessLine\":{\"id\":4,\"description\":\"VOIP\",\"businessLineFeatures\":{\"description\":\"FONE\"}}},{\"technicalSituation\":\"Técnica Não OK\",\"commercialSituation\":\"Comercial Não OK\",\"technicalSituationNote\":\"\",\"commercialSituationNote\":\"\",\"businessLine\":{\"id\":100,\"description\":\"VOD\",\"businessLineFeatures\":{\"description\":\"VIDEO ON DEMAND\"}}},{\"technicalSituation\":\"Técnica Não OK\",\"commercialSituation\":\"Comercial Não OK\",\"technicalSituationNote\":\"TECNICO_ENDERECO_BLOQUEADO\",\"commercialSituationNote\":\"\",\"businessLine\":{\"id\":3,\"description\":\"DIGITAL\",\"businessLineFeatures\":{\"description\":\"TV DIGITAL\"}}},{\"technicalSituation\":\"Técnica OK\",\"commercialSituation\":\"Comercial OK\",\"technicalSituationNote\":\"\",\"commercialSituationNote\":\"\",\"businessLine\":{\"id\":2,\"description\":\"VIRTUA\",\"businessLineFeatures\":{\"description\":\"INTERNET VIA CABO\"}}}],\"node\":\"JDSI\"}]}'+
		'}';
		CEC_IntegrationGeoLocationDTO r = CEC_IntegrationGeoLocationDTO.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CEC_IntegrationGeoLocationDTO.Availability objAvailability = new CEC_IntegrationGeoLocationDTO.Availability(System.JSON.createParser(json));
		System.assert(objAvailability != null);
		System.assert(objAvailability.technicalSituation == null);
		System.assert(objAvailability.commercialSituation == null);
		System.assert(objAvailability.technicalSituationNote == null);
		System.assert(objAvailability.commercialSituationNote == null);
		System.assert(objAvailability.businessLine == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CEC_IntegrationGeoLocationDTO.Domiciles objDomiciles = new CEC_IntegrationGeoLocationDTO.Domiciles(System.JSON.createParser(json));
		System.assert(objDomiciles != null);
		System.assert(objDomiciles.id == null);
		System.assert(objDomiciles.description == null);
		System.assert(objDomiciles.noteDomicile == null);
		System.assert(objDomiciles.nodeCharacteristic == null);
		System.assert(objDomiciles.number_Z == null);
		System.assert(objDomiciles.domicileType == null);
		System.assert(objDomiciles.domicileTypeDescription == null);
		System.assert(objDomiciles.availability == null);
		System.assert(objDomiciles.node == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CEC_IntegrationGeoLocationDTO.BusinessLineFeatures objBusinessLineFeatures = new CEC_IntegrationGeoLocationDTO.BusinessLineFeatures(System.JSON.createParser(json));
		System.assert(objBusinessLineFeatures != null);
		System.assert(objBusinessLineFeatures.description == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CEC_IntegrationGeoLocationDTO.BusinessLine objBusinessLine = new CEC_IntegrationGeoLocationDTO.BusinessLine(System.JSON.createParser(json));
		System.assert(objBusinessLine != null);
		System.assert(objBusinessLine.id == null);
		System.assert(objBusinessLine.description == null);
		System.assert(objBusinessLine.businessLineFeatures == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CEC_IntegrationGeoLocationDTO.Data objData = new CEC_IntegrationGeoLocationDTO.Data(System.JSON.createParser(json));
		System.assert(objData != null);
		System.assert(objData.domiciles == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		CEC_IntegrationGeoLocationDTO objCEC_IntegrationGeoLocationDTO = new CEC_IntegrationGeoLocationDTO(System.JSON.createParser(json));
		System.assert(objCEC_IntegrationGeoLocationDTO != null);
		System.assert(objCEC_IntegrationGeoLocationDTO.apiVersion == null);
		System.assert(objCEC_IntegrationGeoLocationDTO.transactionId == null);
		System.assert(objCEC_IntegrationGeoLocationDTO.data == null);
	}
}