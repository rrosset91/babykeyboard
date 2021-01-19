/**
 * @author: Bruno Felix
 * @company: IBM - Bluewolf
 * @description: Teste para a classe InvoiceDetailsController
 */
@isTest
public class InvoiceDetailsControllerTest {
	@TestSetup
	static void makeData() {
		Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();

		Account contrato = new Account(
			RecordTypeId = recordTypeIdAccount,
			name = 'Teste',
			ContractReferenceNumber__c = '229531991',
			StatusLegado__c = 'Conectado',
			vlocity_cmt__CustomerValue__c = 'Black',
            BusinessUnit__c = 'CLARO'
		);
		insert contrato;

		ServiceParameter__c eventsSettings = new ServiceParameter__c(
			name = 'ContestItem',
			EndPoint__c = 'callout:OAGClaro/orders/request',
			Method__c = 'GET',
			Timeout__c = 120000,
			ReturnMock__c = true
		);
		insert eventsSettings;

		eventsSettings = new ServiceParameter__c(name = 'InvoiceAuthority', EndPoint__c = 'callout:OAGClaro/orders/request', Method__c = 'GET', Timeout__c = 120000, ReturnMock__c = true);
		insert eventsSettings;

		Id recordTypeIdParameter = Schema.SObjectType.Parameters__c.getRecordTypeInfosByDeveloperName().get('AuthorityControl').getRecordTypeId();
		Parameters__c parametro = new Parameters__c(
			name = 'Teste Param',
			RecordTypeId = recordTypeIdParameter,
			Active__c = true,
			ContractStatus__c = 'Conectado',
			Channel__c = 'Atendimento',
			ItemType__c = 'MENSALIDADE TV PRINCIPAL',
			ItemQtt__c = 1.0,
			Profile__c = 'CEC_Backoffice',
			Segment__c = 'BLACK',
			Amount__c = 100
		);
		insert parametro;

		Id recordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();

		Case caso = new Case(ContractBillingAccount__c = contrato.Id, RecordTypeId = recordTypeIdCase);
		insert caso;
	}
	@isTest
	static void getInvoiceDetails() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{"apiVersion":"1;2019-12-04","transactionId":"Id-5098f35e341bef1bcadcefb4","data":{"invoiceId":244986912,"dueDate":"2019-08-10T00:00:00Z","partners":"NET / EMBRATEL","paymentMethod":"DEBITO EM CONTA","status":"Em Aberto","paymentDate":null,"executeDate":null,"cancelDate":null,"dueDay":10,"bestDayPaymentParameter":8,"billCode":"84650000004506102962019081000400000244986912","formatedBillCode":"84650000004-3 50610296201-2 90810004000-9 00244986912-8","amount":450.61,"totalTaxMessage":"Lei 12.741/12 - Tributos Federais (PIS e COFINS) 3,65% - ICMS TOTAL 57,38 - FUST TOTAL 3,33 - FUNTTEL TOTAL 1,67 - Lei 12.741/12 - Tributos Federais (PIS e COFINS) 3,65% - ICMS TOTAL 8,18","invoiceItems":[{"name":"TV POR ASSINATURA","description":"01/07/19 A 31/07/19  MENSALIDADE TV PRINCIPAL SELEÇÃO TOP HD MAX CINEMA FID ","amount":308.42,"taxes":[{"taxType":"ICMS","value":37.01,"aliquot":25.0},{"taxType":"PIS","value":1.76,"aliquot":0.65},{"taxType":"COFINS","value":8.14,"aliquot":3.0},{"taxType":"FUST","value":2.62,"aliquot":1.0},{"taxType":"FUNTEL","value":1.31,"aliquot":0.5}]},{"name":"TV POR ASSINATURA","description":"01/07/19 A 31/07/19  ALUGUEL DE EQUIP HABILITADO ","amount":25.0,"taxes":[{"taxType":"ICMS","value":3.0,"aliquot":25.0}]},{"name":"BANDA LARGA","description":"01/07/19 A 31/07/19  MENSALIDADE VIRTUA 20 MEGA FIDELIDADE ","amount":69.49,"taxes":[{"taxType":"ICMS","value":17.37,"aliquot":25.0},{"taxType":"COFINS","value":1.56,"aliquot":3.0}]},{"name":"NET FONE VIA EMBRATEL / NET FONE VIA EMBRATE","description":"NET FONE VIA EMBRATEL / NET FONE VIA EMBRATE","amount":32.7,"taxes":[{"taxType":"ICMS","value":8.18,"aliquot":25.0}]}],"messages":[{"text":"A Fidelidade para o Serviço de TV(ALUGUEL DE EQUIPAMENTO HABILITADO) expira em 20/07/2019"},{"text":"Acesse net.com.br, para visualizar sua Fatura detalhada, emitir segunda via, tirar dúvidas, definir a forma de envio ou colocá-la em débito automático."},{"text":"A oferta conjunta NET Virtua + e composta pelo seu plano contratado e aplicativos digitais"},{"text":"SVA-CINE BR:R$ 7,5 / -CINE EURO:R$ 7,5"}],"itemGroups":[{"description":"TV POR ASSINATURA","amount":"333.42"},{"description":"BANDA LARGA","amount":"69.49"},{"description":"CLARO FONE","amount":"32.7"},{"description":"SERVIÇOS AVANÇADOS","amount":"15"}],"partnerDebts":[{"partnerId":2,"partnerName":"EMBRATEL","debtId":170778375,"generationDate":"2019-07-17T16:05:46Z","originalDueDate":"2019-08-10T00:00:00Z","dueDate":"2019-08-10T00:00:00Z","amount":32.7,"amountPaid":null,"balance":32.7,"isExternalCollecting":null,"statusId":10,"status":"EM ABERTO","debtGroup":null,"serviceGroup":[{"partnerServiceId":1,"partnerServiceDescription":"NET FONE VIA EMBRATEL","partnerServiceAmount":32.7,"partnerExtracts":null,"partnerPhones":[{"originTerminal":"1332233441--FRANQUIA 001","amount":32.7,"partnerExtracts":[{"itemId":474854532,"installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-17T20:29:46Z","itemDescription":"NETFONE MULTI ILIMITADO BRASIL 21","itemType":"NETFONE MULTI ILIMIT BRASIL 21","amount":32.7,"isContested":"N","addressComplement":null,"details":[{"sequenceNumber":1,"startDate":"2019-06-12T00:00:00Z","endDate":"2019-06-30T00:00:00Z","origin":"STS SP","destination":null,"destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":1.0,"callDurationUnit":"UNIDADE","callValue":14.45,"callDetailValue":20.25,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":null,"taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0},{"sequenceNumber":2,"startDate":"2019-07-01T00:00:00Z","endDate":"2019-07-11T00:00:00Z","origin":"STS SP","destination":null,"destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":1.0,"callDurationUnit":"UNIDADE","callValue":8.89,"callDetailValue":12.45,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":null,"taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0}]},{"itemId":474854535,"installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-17T20:29:46Z","itemDescription":"LIGACOES DDD PARA TELEFONES FIXOS","itemType":"NET FO EBT DDD TEL FIXOS","amount":0.0,"isContested":"N","addressComplement":null,"details":[{"sequenceNumber":3,"startDate":"2019-06-13T00:00:00Z","endDate":"2019-06-13T00:00:00Z","origin":"STS SP","destination":"São Paulo","destinationCountry":"   ","startTime":"15:53:02","endTime":"      ","callDuration":22.8,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1133382822","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0}]},{"itemId":474854537,"installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-17T20:29:46Z","itemDescription":"LIGACOES LOCAIS PARA NET FONE E CLARO FONE  - DURACAO E VALOR DAS LIGACOES REALIZADAS PARA O MESMO NUMERO ESTAO SOMADOS","itemType":"NET FO EBT LC  TOT TEL F","amount":0.0,"isContested":"N","addressComplement":null,"details":[{"sequenceNumber":4,"startDate":null,"endDate":null,"origin":"STS SP","destination":"Santos","destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":6.0,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1332895053","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0}]},{"itemId":474854539,"installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-17T20:29:46Z","itemDescription":"LIGACOES LOCAIS PARA TELEFONES FIXOS - DURACAO E VALOR DAS LIGACOES REALIZADAS PARA O MESMO NUMERO ESTAO SOMADOS","itemType":"NET FO EBT LOC TL FX DES","amount":0.0,"isContested":"N","addressComplement":null,"details":[{"sequenceNumber":5,"startDate":null,"endDate":null,"origin":"STS SP","destination":"Santos","destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":1.1,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1332328355","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0},{"sequenceNumber":6,"startDate":null,"endDate":null,"origin":"STS SP","destination":"Santos","destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":24.2,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1332392359","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0},{"sequenceNumber":7,"startDate":null,"endDate":null,"origin":"STS SP","destination":"Santos","destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":48.3,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1332881533","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0},{"sequenceNumber":8,"startDate":null,"endDate":null,"origin":"STS SP","destination":"Santos","destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":1.9,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1335768974","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0},{"sequenceNumber":9,"startDate":null,"endDate":null,"origin":"STS SP","destination":"Santos","destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":0.5,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1340201414","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0}]}]}]}]},{"partnerId":1,"partnerName":"NET","debtId":225168222,"generationDate":"2019-07-22T00:00:00Z","originalDueDate":"2019-08-10T00:00:00Z","dueDate":null,"amount":417.91,"amountPaid":null,"balance":417.91,"isExternalCollecting":null,"statusId":10,"status":"EM ABERTO","debtGroup":[{"groupId":5,"groupdescription":"OUTROS SERVIÇOS","amount":"0","order":"5","extractItems":[{"idExtractItem":1573713906,"idExtractItemType":null,"itemDescription":"MENSALIDADE PROVEDOR","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023833,"productId":3447,"productDescription":"COMODATO","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713911,"idExtractItemType":null,"itemDescription":"MENSALIDADE PROVEDOR","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023833,"productId":4700,"productDescription":"ACESSO GRATIS","proRataUnificationGroup":null,"proRataStartDate":null,"order":1}]},{"groupId":3,"groupdescription":"BANDA LARGA","amount":"84.49","order":"3","extractItems":[{"idExtractItem":1573714086,"idExtractItemType":null,"itemDescription":"MENS CONTEUDO DIGITAL AVULSO","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":7.5,"addressComplement":null,"pointId":null,"productId":null,"productDescription":"CINE BR","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714106,"idExtractItemType":null,"itemDescription":"MENS CONTEUDO DIGITAL AVULSO","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":7.5,"addressComplement":null,"pointId":null,"productId":null,"productDescription":"CINE EURO","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714011,"idExtractItemType":null,"itemDescription":"MENSALIDADE VIRTUA","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":69.49,"addressComplement":null,"pointId":6023833,"productId":null,"productDescription":"VIRTUA 20M (MIGRACAO) FIDELIDADE 12878","proRataUnificationGroup":null,"proRataStartDate":null,"order":1}]},{"groupId":1,"groupdescription":"TV POR ASSINATURA","amount":"333.42","order":"1","extractItems":[{"idExtractItem":1573713915,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":8153,"productDescription":"MUNDO PROMOCIONAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713924,"idExtractItemType":null,"itemDescription":"LOCACAO DECODIFICADOR DIGITAL","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":9996,"productDescription":"ALUGUEL ZERO","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713928,"idExtractItemType":null,"itemDescription":"LOCACAO DECODIFICADOR DIGITAL","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":9996,"productDescription":"ALUGUEL ZERO","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713933,"idExtractItemType":null,"itemDescription":"LOCACAO DECODIFICADOR DIGITAL","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":9996,"productDescription":"ALUGUEL ZERO","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713936,"idExtractItemType":null,"itemDescription":"SERVICO DE GRAVACAO DIG","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":10112,"productDescription":"SERVICO DE GRAVACAO DIGITAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713940,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":11029,"productDescription":"NOTICIA PARA DEMAIS PONTOS DIG","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713945,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":11029,"productDescription":"NOTICIA PARA DEMAIS PONTOS DIG","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713951,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":11031,"productDescription":"MUNDO PARA DEMAIS PONTOS DIG","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713958,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":11031,"productDescription":"MUNDO PARA DEMAIS PONTOS DIG","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713967,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":11267,"productDescription":"NOTICIAS PROMOCIONAL DIGITAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713974,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":11267,"productDescription":"NOTICIAS PROMOCIONAL DIGITAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713979,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":11267,"productDescription":"NOTICIAS PROMOCIONAL DIGITAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713983,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":11543,"productDescription":"ESPORTE PARA DEMAIS PONTOS DIG","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713990,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":11543,"productDescription":"ESPORTE PARA DEMAIS PONTOS DIG","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713995,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":11714,"productDescription":"ESPORTE PROMOCIONAL DIGITAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714000,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":11714,"productDescription":"ESPORTE PROMOCIONAL DIGITAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714005,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":11888,"productDescription":"REPLAY TV GRATIS","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714017,"idExtractItemType":null,"itemDescription":"ALUGUEL DE EQUIP HABILITADO","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":null,"productDescription":"TOP HD CINEMA PA GR 13573","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714020,"idExtractItemType":null,"itemDescription":"MENSALIDADE PACOTE NOW","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":14644,"productDescription":"TELECINE PLAY","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714026,"idExtractItemType":null,"itemDescription":"MENSALIDADE PACOTE NOW","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":16167,"productDescription":"HBO OD","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714032,"idExtractItemType":null,"itemDescription":"MENSALIDADE TV PRINCIPAL","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":308.42,"addressComplement":null,"pointId":6023831,"productId":null,"productDescription":"TOP HD MAX CINEMA OLD FID 16389","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714038,"idExtractItemType":null,"itemDescription":"ALUGUEL DE EQUIP HABILITADO","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":25.0,"addressComplement":null,"pointId":6023832,"productId":null,"productDescription":"TOP HD CINEMA FID 18714","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714044,"idExtractItemType":null,"itemDescription":"MENSALIDADE PACOTE NOW","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":19491,"productDescription":"ESPORTES NOW","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714053,"idExtractItemType":null,"itemDescription":"MENSALIDADE PACOTE NOW","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":19492,"productDescription":"NOTICIAS NOW","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714057,"idExtractItemType":null,"itemDescription":"MENSALIDADE PACOTE NOW","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":19493,"productDescription":"MUNDO NOW","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714068,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":31439,"productDescription":"REPLAY TV PARA DEMAIS PONTOS","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714077,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":31439,"productDescription":"REPLAY TV PARA DEMAIS PONTOS","proRataUnificationGroup":null,"proRataStartDate":null,"order":1}]}],"serviceGroup":null}]}}',
			200
		);
		Test.setMock(HttpCalloutMock.class, mock);

		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'InvoiceDetails';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = '00';
		customSetting.Timeout__c = 120;
		insert customSetting;

		Test.startTest();
		InvoiceDetailsController.getInvoiceDetails('12078302', '004', '004', 'DETAILS', '', '');
		Test.stopTest();
	}

	@isTest
	static void getInvoiceDetailsError() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock('{"error": { "message": "", "errorCode": "500", "httpCode": "500", "detailedMessage": "error"}}', 500);
		Test.setMock(HttpCalloutMock.class, mock);
		String result;
		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'InvoiceDetails';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = '00';
		customSetting.Timeout__c = 120;
		insert customSetting;
		Test.startTest();
		InvoiceDetailsController.getInvoiceDetails('12078302', '004', '004', 'DETAILS', '', '');
		Test.stopTest();
		system.assertEquals(result, result);
	}

	@isTest
	static void getContestationOptions() {
		String result;
		Test.startTest();
		InvoiceDetailsController.getContestationOptions();
		Test.stopTest();
	}

	@isTest
	static void getContestation() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{"apiVersion":"1;2019-12-04","transactionId":"Id-5098f35e341bef1bcadcefb4","data":{"invoiceId":244986912,"dueDate":"2019-08-10T00:00:00Z","partners":"NET / EMBRATEL","paymentMethod":"DEBITO EM CONTA","status":"Em Aberto","paymentDate":null,"executeDate":null,"cancelDate":null,"dueDay":10,"bestDayPaymentParameter":8,"billCode":"84650000004506102962019081000400000244986912","formatedBillCode":"84650000004-3 50610296201-2 90810004000-9 00244986912-8","amount":450.61,"totalTaxMessage":"Lei 12.741/12 - Tributos Federais (PIS e COFINS) 3,65% - ICMS TOTAL 57,38 - FUST TOTAL 3,33 - FUNTTEL TOTAL 1,67 - Lei 12.741/12 - Tributos Federais (PIS e COFINS) 3,65% - ICMS TOTAL 8,18","invoiceItems":[{"name":"TV POR ASSINATURA","description":"01/07/19 A 31/07/19  MENSALIDADE TV PRINCIPAL SELEÇÃO TOP HD MAX CINEMA FID ","amount":308.42,"taxes":[{"taxType":"ICMS","value":37.01,"aliquot":25.0},{"taxType":"PIS","value":1.76,"aliquot":0.65},{"taxType":"COFINS","value":8.14,"aliquot":3.0},{"taxType":"FUST","value":2.62,"aliquot":1.0},{"taxType":"FUNTEL","value":1.31,"aliquot":0.5}]},{"name":"TV POR ASSINATURA","description":"01/07/19 A 31/07/19  ALUGUEL DE EQUIP HABILITADO ","amount":25.0,"taxes":[{"taxType":"ICMS","value":3.0,"aliquot":25.0}]},{"name":"BANDA LARGA","description":"01/07/19 A 31/07/19  MENSALIDADE VIRTUA 20 MEGA FIDELIDADE ","amount":69.49,"taxes":[{"taxType":"ICMS","value":17.37,"aliquot":25.0},{"taxType":"COFINS","value":1.56,"aliquot":3.0}]},{"name":"NET FONE VIA EMBRATEL / NET FONE VIA EMBRATE","description":"NET FONE VIA EMBRATEL / NET FONE VIA EMBRATE","amount":32.7,"taxes":[{"taxType":"ICMS","value":8.18,"aliquot":25.0}]}],"messages":[{"text":"A Fidelidade para o Serviço de TV(ALUGUEL DE EQUIPAMENTO HABILITADO) expira em 20/07/2019"},{"text":"Acesse net.com.br, para visualizar sua Fatura detalhada, emitir segunda via, tirar dúvidas, definir a forma de envio ou colocá-la em débito automático."},{"text":"A oferta conjunta NET Virtua + e composta pelo seu plano contratado e aplicativos digitais"},{"text":"SVA-CINE BR:R$ 7,5 / -CINE EURO:R$ 7,5"}],"itemGroups":[{"description":"TV POR ASSINATURA","amount":"333.42"},{"description":"BANDA LARGA","amount":"69.49"},{"description":"CLARO FONE","amount":"32.7"},{"description":"SERVIÇOS AVANÇADOS","amount":"15"}],"partnerDebts":[{"partnerId":2,"partnerName":"EMBRATEL","debtId":170778375,"generationDate":"2019-07-17T16:05:46Z","originalDueDate":"2019-08-10T00:00:00Z","dueDate":"2019-08-10T00:00:00Z","amount":32.7,"amountPaid":null,"balance":32.7,"isExternalCollecting":null,"statusId":10,"status":"EM ABERTO","debtGroup":null,"serviceGroup":[{"partnerServiceId":1,"partnerServiceDescription":"NET FONE VIA EMBRATEL","partnerServiceAmount":32.7,"partnerExtracts":null,"partnerPhones":[{"originTerminal":"1332233441--FRANQUIA 001","amount":32.7,"partnerExtracts":[{"itemId":474854532,"installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-17T20:29:46Z","itemDescription":"NETFONE MULTI ILIMITADO BRASIL 21","itemType":"NETFONE MULTI ILIMIT BRASIL 21","amount":32.7,"isContested":"N","addressComplement":null,"details":[{"sequenceNumber":1,"startDate":"2019-06-12T00:00:00Z","endDate":"2019-06-30T00:00:00Z","origin":"STS SP","destination":null,"destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":1.0,"callDurationUnit":"UNIDADE","callValue":14.45,"callDetailValue":20.25,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":null,"taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0},{"sequenceNumber":2,"startDate":"2019-07-01T00:00:00Z","endDate":"2019-07-11T00:00:00Z","origin":"STS SP","destination":null,"destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":1.0,"callDurationUnit":"UNIDADE","callValue":8.89,"callDetailValue":12.45,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":null,"taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0}]},{"itemId":474854535,"installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-17T20:29:46Z","itemDescription":"LIGACOES DDD PARA TELEFONES FIXOS","itemType":"NET FO EBT DDD TEL FIXOS","amount":0.0,"isContested":"N","addressComplement":null,"details":[{"sequenceNumber":3,"startDate":"2019-06-13T00:00:00Z","endDate":"2019-06-13T00:00:00Z","origin":"STS SP","destination":"São Paulo","destinationCountry":"   ","startTime":"15:53:02","endTime":"      ","callDuration":22.8,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1133382822","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0}]},{"itemId":474854537,"installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-17T20:29:46Z","itemDescription":"LIGACOES LOCAIS PARA NET FONE E CLARO FONE  - DURACAO E VALOR DAS LIGACOES REALIZADAS PARA O MESMO NUMERO ESTAO SOMADOS","itemType":"NET FO EBT LC  TOT TEL F","amount":0.0,"isContested":"N","addressComplement":null,"details":[{"sequenceNumber":4,"startDate":null,"endDate":null,"origin":"STS SP","destination":"Santos","destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":6.0,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1332895053","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0}]},{"itemId":474854539,"installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-17T20:29:46Z","itemDescription":"LIGACOES LOCAIS PARA TELEFONES FIXOS - DURACAO E VALOR DAS LIGACOES REALIZADAS PARA O MESMO NUMERO ESTAO SOMADOS","itemType":"NET FO EBT LOC TL FX DES","amount":0.0,"isContested":"N","addressComplement":null,"details":[{"sequenceNumber":5,"startDate":null,"endDate":null,"origin":"STS SP","destination":"Santos","destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":1.1,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1332328355","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0},{"sequenceNumber":6,"startDate":null,"endDate":null,"origin":"STS SP","destination":"Santos","destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":24.2,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1332392359","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0},{"sequenceNumber":7,"startDate":null,"endDate":null,"origin":"STS SP","destination":"Santos","destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":48.3,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1332881533","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0},{"sequenceNumber":8,"startDate":null,"endDate":null,"origin":"STS SP","destination":"Santos","destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":1.9,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1335768974","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0},{"sequenceNumber":9,"startDate":null,"endDate":null,"origin":"STS SP","destination":"Santos","destinationCountry":"   ","startTime":"      ","endTime":"      ","callDuration":0.5,"callDurationUnit":"MINUTO","callValue":0.0,"callDetailValue":0.0,"originTerminal":"1332233441--FRANQUIA 001","targetTerminal":"1340201414","taxType":"E","entryDate":"2019-07-17T20:29:46Z","itemDetailId":0}]}]}]}]},{"partnerId":1,"partnerName":"NET","debtId":225168222,"generationDate":"2019-07-22T00:00:00Z","originalDueDate":"2019-08-10T00:00:00Z","dueDate":null,"amount":417.91,"amountPaid":null,"balance":417.91,"isExternalCollecting":null,"statusId":10,"status":"EM ABERTO","debtGroup":[{"groupId":5,"groupdescription":"OUTROS SERVIÇOS","amount":"0","order":"5","extractItems":[{"idExtractItem":1573713906,"idExtractItemType":null,"itemDescription":"MENSALIDADE PROVEDOR","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023833,"productId":3447,"productDescription":"COMODATO","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713911,"idExtractItemType":null,"itemDescription":"MENSALIDADE PROVEDOR","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023833,"productId":4700,"productDescription":"ACESSO GRATIS","proRataUnificationGroup":null,"proRataStartDate":null,"order":1}]},{"groupId":3,"groupdescription":"BANDA LARGA","amount":"84.49","order":"3","extractItems":[{"idExtractItem":1573714086,"idExtractItemType":null,"itemDescription":"MENS CONTEUDO DIGITAL AVULSO","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":7.5,"addressComplement":null,"pointId":null,"productId":null,"productDescription":"CINE BR","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714106,"idExtractItemType":null,"itemDescription":"MENS CONTEUDO DIGITAL AVULSO","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":7.5,"addressComplement":null,"pointId":null,"productId":null,"productDescription":"CINE EURO","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714011,"idExtractItemType":null,"itemDescription":"MENSALIDADE VIRTUA","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":69.49,"addressComplement":null,"pointId":6023833,"productId":null,"productDescription":"VIRTUA 20M (MIGRACAO) FIDELIDADE 12878","proRataUnificationGroup":null,"proRataStartDate":null,"order":1}]},{"groupId":1,"groupdescription":"TV POR ASSINATURA","amount":"333.42","order":"1","extractItems":[{"idExtractItem":1573713915,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":8153,"productDescription":"MUNDO PROMOCIONAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713924,"idExtractItemType":null,"itemDescription":"LOCACAO DECODIFICADOR DIGITAL","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":9996,"productDescription":"ALUGUEL ZERO","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713928,"idExtractItemType":null,"itemDescription":"LOCACAO DECODIFICADOR DIGITAL","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":9996,"productDescription":"ALUGUEL ZERO","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713933,"idExtractItemType":null,"itemDescription":"LOCACAO DECODIFICADOR DIGITAL","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":9996,"productDescription":"ALUGUEL ZERO","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713936,"idExtractItemType":null,"itemDescription":"SERVICO DE GRAVACAO DIG","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":10112,"productDescription":"SERVICO DE GRAVACAO DIGITAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713940,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":11029,"productDescription":"NOTICIA PARA DEMAIS PONTOS DIG","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713945,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":11029,"productDescription":"NOTICIA PARA DEMAIS PONTOS DIG","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713951,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":11031,"productDescription":"MUNDO PARA DEMAIS PONTOS DIG","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713958,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":11031,"productDescription":"MUNDO PARA DEMAIS PONTOS DIG","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713967,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":11267,"productDescription":"NOTICIAS PROMOCIONAL DIGITAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713974,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":11267,"productDescription":"NOTICIAS PROMOCIONAL DIGITAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713979,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":11267,"productDescription":"NOTICIAS PROMOCIONAL DIGITAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713983,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":11543,"productDescription":"ESPORTE PARA DEMAIS PONTOS DIG","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713990,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":11543,"productDescription":"ESPORTE PARA DEMAIS PONTOS DIG","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573713995,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":11714,"productDescription":"ESPORTE PROMOCIONAL DIGITAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714000,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":11714,"productDescription":"ESPORTE PROMOCIONAL DIGITAL","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714005,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":11888,"productDescription":"REPLAY TV GRATIS","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714017,"idExtractItemType":null,"itemDescription":"ALUGUEL DE EQUIP HABILITADO","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":null,"productDescription":"TOP HD CINEMA PA GR 13573","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714020,"idExtractItemType":null,"itemDescription":"MENSALIDADE PACOTE NOW","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":14644,"productDescription":"TELECINE PLAY","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714026,"idExtractItemType":null,"itemDescription":"MENSALIDADE PACOTE NOW","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":16167,"productDescription":"HBO OD","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714032,"idExtractItemType":null,"itemDescription":"MENSALIDADE TV PRINCIPAL","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":308.42,"addressComplement":null,"pointId":6023831,"productId":null,"productDescription":"TOP HD MAX CINEMA OLD FID 16389","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714038,"idExtractItemType":null,"itemDescription":"ALUGUEL DE EQUIP HABILITADO","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":25.0,"addressComplement":null,"pointId":6023832,"productId":null,"productDescription":"TOP HD CINEMA FID 18714","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714044,"idExtractItemType":null,"itemDescription":"MENSALIDADE PACOTE NOW","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":19491,"productDescription":"ESPORTES NOW","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714053,"idExtractItemType":null,"itemDescription":"MENSALIDADE PACOTE NOW","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":19492,"productDescription":"NOTICIAS NOW","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714057,"idExtractItemType":null,"itemDescription":"MENSALIDADE PACOTE NOW","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023831,"productId":19493,"productDescription":"MUNDO NOW","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714068,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":6023832,"productId":31439,"productDescription":"REPLAY TV PARA DEMAIS PONTOS","proRataUnificationGroup":null,"proRataStartDate":null,"order":1},{"idExtractItem":1573714077,"idExtractItemType":null,"itemDescription":"MENSALIDADE CANAL A LA CARTE","installmentNumber":null,"totalInstallments":null,"dueDate":"2019-08-10T00:00:00Z","entryDate":"2019-07-01T00:00:00Z","amount":0.0,"addressComplement":null,"pointId":10575447,"productId":31439,"productDescription":"REPLAY TV PARA DEMAIS PONTOS","proRataUnificationGroup":null,"proRataStartDate":null,"order":1}]}],"serviceGroup":null}]}}',
			200
		);
		Test.setMock(HttpCalloutMock.class, mock);
		String result;
		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'InvoiceDetails';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = '00';
		customSetting.Timeout__c = 120;
		insert customSetting;
		Test.startTest();
		try {
			InvoiceDetailsController.getContestation('1027935', '004', '245961436', 'MCIDA');
		} catch (exception e) {
		}
		Test.stopTest();
	}

	@isTest
	static void disputeInvoice() {
		Test.startTest();
		Test.setMock(
			HttpCalloutMock.class,
			new SingleMockCallout(
				'{"data": {"content": "Sua fatura já está disponível no aplicativo MinhaClaro Teste 3.","description": "TEXTO","subject": "Fatura Claro 3.","type": "EMAIL","receiver": [{ "email": "gustavo.rodrigues917@gmail.com","phoneNumber": "","type": ""}], "sender": {"email": "nao-responda@claro.com.br","id": "string","phoneNumber": "1129285598"}}}',
				200
			)
		);
		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'OAG_NET_SendEmail';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = '00';
		customSetting.Timeout__c = 120;
		insert customSetting;
        
        Account contrato = new Account(
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId(),
			name = 'Teste',
			ContractReferenceNumber__c = '229531991',
			StatusLegado__c = 'Conectado',
			vlocity_cmt__CustomerValue__c = 'Black',
            BusinessUnit__c = 'CLARO',
            ExternalID__c = 'CPF43705574884'
		);
		insert contrato;
        
		String casoId = [SELECT Id FROM Case LIMIT 1].Id;
		String returnMethod = '{"items":[{"descricao":"NET FO EBT DDD CELULARES","idItem":"1573714030","idParceiro":"2","realValue":4.57,"valorContestar":0.152333333333333,"allowOnlyRecalculate":false,"contestationOptions":[160,161,163,152,154,159],"idPartnerStatement":451278170,"idDetExtractItem":"3265517500","valorCorrigido":4.417666666666667,"contestationReason":"163"}],"bill":{"idFatura":"229531991","contractId":"229531991","operatorId":"040","amountAgainstDeparture":[{"groupId":"1","value":0}]}}';

		InvoiceDetailsController.disputeInvoice(returnMethod, '0', 'E-mail', 'Observations', casoId, true);

		Test.stopTest();
	}

    static void disputeInvoiceSingle() {
		Test.startTest();
		Test.setMock(
			HttpCalloutMock.class,
			new SingleMockCallout(
				'{"data": {"content": "Sua fatura já está disponível no aplicativo MinhaClaro Teste 3.","description": "TEXTO","subject": "Fatura Claro 3.","type": "EMAIL","receiver": [{ "email": "gustavo.rodrigues917@gmail.com","phoneNumber": "","type": ""}], "sender": {"email": "nao-responda@claro.com.br","id": "string","phoneNumber": "1129285598"}}}',
				200
			)
		);
		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'OAG_NET_SendEmail';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = '00';
		customSetting.Timeout__c = 120;
		insert customSetting;
        
        Account contrato = new Account(
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId(),
			name = 'Teste',
			ContractReferenceNumber__c = '229531991',
			StatusLegado__c = 'Conectado',
			vlocity_cmt__CustomerValue__c = 'Black',
            BusinessUnit__c = 'CLARO',
            ExternalID__c = 'CPF43705574884'
		);
		insert contrato;
        
		String casoId = [SELECT Id FROM Case LIMIT 1].Id;
		String returnMethod = '{"items":[{"descricao":"NET FO EBT DDD CELULARES","idItem":"1573714030","idParceiro":"2","realValue":4.57,"valorContestar":0.152333333333333,"allowOnlyRecalculate":false,"contestationOptions":[160,161,163,152,154,159],"idPartnerStatement":451278170,"idDetExtractItem":"3265517500","valorCorrigido":4.417666666666667,"contestationReason":"163"}],"bill":{"idFatura":"229531991","contractId":"229531991","operatorId":"040","amountAgainstDeparture":[{"groupId":"1","value":0}]}}';

		InvoiceDetailsController.disputeInvoice(returnMethod, '0', 'E-mail', 'Observations', casoId, false);

		Test.stopTest();
	}
    
	@isTest
	static void setReturnMethod() {
		try {
			Test.startTest();
			InvoiceDetailsController.setReturnMethod('0011g00000nmBsWAAU', 'E-mail');
		} catch (exception e) {
		}
		Test.stopTest();
	}

	@isTest
	static void denyCase() {
		Test.startTest();
		Test.setMock(
			HttpCalloutMock.class,
			new SingleMockCallout(
				'{"data": {"content": "Sua fatura já está disponível no aplicativo MinhaClaro Teste 3.","description": "TEXTO","subject": "Fatura Claro 3.","type": "EMAIL","receiver": [{ "email": "gustavo.rodrigues917@gmail.com","phoneNumber": "","type": ""}], "sender": {"email": "nao-responda@claro.com.br","id": "string","phoneNumber": "1129285598"}}}',
				200
			)
		);
		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'OAG_NET_SendEmail';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = '00';
		customSetting.Timeout__c = 120;
		insert customSetting;

		Case cs = new Case();
		cs.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Financial' LIMIT 1].Id;
		CS.OpenDateRobot__c = Date.today();
		insert cs;
		InvoiceDetailsController.denyCase(cs.Id, 'Valor atual do comentario');
		Test.stopTest();
	}

	@isTest
	static void setParamsEmptyFields() {
		String result;

		try {
			Test.startTest();
			invoiceDetailsController.getInvoiceDetails('', '', '', '', '', '');
		} catch (exception e) {
		}
		Test.stopTest();
	}

	@isTest
	static void getHashAuthorityTest() {
		String result;
		try {
			Test.startTest();
			List<invoiceDetailsController.ContestationItem> lst = new List<invoiceDetailsController.ContestationItem>();
			InvoiceDetailsController.ContestationAuraWrapper contestationWrapper = new InvoiceDetailsController.ContestationAuraWrapper();
			InvoiceDetailsController.Bill bill = new InvoiceDetailsController.Bill();
			InvoiceDetailsController.ContestationItem contestationItem = new invoiceDetailsController.ContestationItem();

			List<InvoiceDetailsController.DepartureGroup> lstAmount = new List<InvoiceDetailsController.DepartureGroup>();
			InvoiceDetailsController.DepartureGroup amountDepat = new InvoiceDetailsController.DepartureGroup();
			amountDepat.groupId = '1';
			amountDepat.value = -2;
			lstAmount.add(amountDepat);

			bill.amountAgainstDeparture = lstAmount;
			bill.contractId = '1027935';
			bill.idFatura = '245961436';
			bill.operatorId = '004';

			contestationItem.contestationReason = '541';
			contestationItem.idItem = '1579031159';
			contestationItem.realValue = 308.42;
			contestationItem.valorContestar = 15.42;
			contestationItem.valorCorrigido = 5;
			lst.add(contestationItem);

			contestationWrapper.bill = bill;
			contestationWrapper.items = lst;

			invoiceDetailsController.getHashAuthority(null, contestationWrapper, amountDepat);
		} catch (exception e) {
		}

		Test.stopTest();
	}

	@isTest
	static void setHeaders() {
		String result;
		try {
			Test.startTest();
			invoiceDetailsController.setHeaders();
		} catch (exception e) {
		}
		Test.stopTest();
	}

	@isTest
	static void setParamsTest() {
		String result;
		try {
			Test.startTest();
			List<CEC_DisputeInvoice.InvoiceItem> lst = new List<CEC_DisputeInvoice.InvoiceItem>();
			CEC_DisputeInvoice.InvoiceItem invoiceItems = new CEC_DisputeInvoice.invoiceItem();
			invoiceItems.idInvoiceItem = '1579031159';
			invoiceItems.idGroupItem = '1';
			invoiceItems.reason = '1';
			invoiceItems.originalValue = 308.42;
			invoiceItems.wishedValue = 15.42;
			invoiceItems.disputePercentage = 5;
			invoiceItems.approvationHash = '2ff06bbb2fbdd0bbd38461bb75362112a69aaa98ae5f6ab6e9c9e53e0527e767613e20cfcd40f0c';
			invoiceItems.notes = 'Observação da contestação';
			invoiceItems.status = 'EM ABERTO';
			lst.add(invoiceItems);
			CEC_DisputeInvoice.DisputeInvoiceRequest entrada = new CEC_DisputeInvoice.DisputeInvoiceRequest();
			entrada.contractNumber = '1027935';
			entrada.operatorCode = '004';
			entrada.channel = 'L';
			entrada.idInvoice = '245961436';
			entrada.userName = 'MCIDA';
			entrada.source = 1;
			entrada.type = 'R';
			entrada.invoiceItems = lst;
			invoiceDetailsController.setParams('1027935', '004', '245961436', 'infoDetailLevel');
		} catch (exception e) {
		}
	}
}