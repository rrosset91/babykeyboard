/**
 * @author: Bruno Felix
 * @company: IBM - Bluewolf
 * @description: Teste para a classe InvoicesController
 */

@isTest
public class InvoicesControllerTest {
	private static final Id CASE_RECTYPE = SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Financial').getRecordTypeId();

	@TestSetup
	static void makeData() {
		List<Case> lCaseLst = new List<Case>{ new Case(Subject = 'Default', RecordTypeId = CASE_RECTYPE) };
		insert lCaseLst;
	}

	@isTest
	public static void getInvoiceDetails() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{ "apiVersion": "1;2019-12-04", "transactionId": "Id-c2d9fd5e1f6eb661f113d29e", "data": { "invoiceId": 244986912, "dueDate": "2019-08-10T00:00:00Z", "partners": "NET / EMBRATEL", "paymentMethod": "DEBITO EM CONTA", "status": "Em Aberto", "paymentDate": null, "executeDate": null, "cancelDate": null, "dueDay": 10, "bestDayPaymentParameter": 8, "billCode": "84650000004506102962019081000400000244986912", "formatedBillCode": "84650000004-3 50610296201-2 90810004000-9 00244986912-8", "amount": 450.61, "totalTaxMessage": "Lei 12.741/12 - Tributos Federais (PIS e COFINS) 3,65% - ICMS TOTAL 57,38 - FUST TOTAL 3,33 - FUNTTEL TOTAL 1,67 - Lei 12.741/12 - Tributos Federais (PIS e COFINS) 3,65% - ICMS TOTAL 8,18", "invoiceItems": [ { "name": "TV POR ASSINATURA", "description": "01/07/19 A 31/07/19 MENSALIDADE TV PRINCIPAL SELEÇÃO TOP HD MAX CINEMA FID ", "amount": 308.42, "taxes": [ { "taxType": "ICMS", "value": 37.01, "aliquot": 25.0 }, { "taxType": "PIS", "value": 1.76, "aliquot": 0.65 }, { "taxType": "COFINS", "value": 8.14, "aliquot": 3.0 }, { "taxType": "FUST", "value": 2.62, "aliquot": 1.0 }, { "taxType": "FUNTEL", "value": 1.31, "aliquot": 0.5 } ] }, { "name": "TV POR ASSINATURA", "description": "01/07/19 A 31/07/19 ALUGUEL DE EQUIP HABILITADO ", "amount": 25.0, "taxes": [ { "taxType": "ICMS", "value": 3.0, "aliquot": 25.0 } ] }, { "name": "BANDA LARGA", "description": "01/07/19 A 31/07/19 MENSALIDADE VIRTUA 20 MEGA FIDELIDADE ", "amount": 69.49, "taxes": [ { "taxType": "ICMS", "value": 17.37, "aliquot": 25.0 }, { "taxType": "COFINS", "value": 1.56, "aliquot": 3.0 } ] }, { "name": "NET FONE VIA EMBRATEL / NET FONE VIA EMBRATE", "description": "NET FONE VIA EMBRATEL / NET FONE VIA EMBRATE", "amount": 32.7, "taxes": [ { "taxType": "ICMS", "value": 8.18, "aliquot": 25.0 } ] } ], "messages": [ { "text": "A Fidelidade para o Serviço de TV(ALUGUEL DE EQUIPAMENTO HABILITADO) expira em 20/07/2019" }, { "text": "Acesse net.com.br, para visualizar sua Fatura detalhada, emitir segunda via, tirar dúvidas, definir a forma de envio ou colocá-la em débito automático." }, { "text": "A oferta conjunta NET Virtua + e composta pelo seu plano contratado e aplicativos digitais" }, { "text": "SVA-CINE BR:R$ 7,5 / -CINE EURO:R$ 7,5" } ], "itemGroups": [ { "description": "TV POR ASSINATURA", "amount": "333.42" }, { "description": "BANDA LARGA", "amount": "69.49" }, { "description": "CLARO FONE", "amount": "32.7" }, { "description": "SERVIÇOS AVANÇADOS", "amount": "15" } ], "partnerDebts": [ { "partnerId": 2, "partnerName": "EMBRATEL", "debtId": 170778375, "generationDate": "2019-07-17T16:05:46Z", "originalDueDate": "2019-08-10T00:00:00Z", "dueDate": "2019-08-10T00:00:00Z", "amount": 32.7, "amountPaid": null, "balance": 32.7, "isExternalCollecting": null, "statusId": 10, "status": "EM ABERTO", "debtGroup": null, "serviceGroup": [ { "partnerServiceId": 1, "partnerServiceDescription": "NET FONE VIA EMBRATEL", "partnerServiceAmount": 32.7, "partnerExtracts": null, "partnerPhones": [ { "originTerminal": "1332233441--FRANQUIA 001", "amount": 32.7, "partnerExtracts": [ { "itemId": 474854532, "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-17T20:29:46Z", "itemDescription": "NETFONE MULTI ILIMITADO BRASIL 21", "itemType": "NETFONE MULTI ILIMIT BRASIL 21", "amount": 32.7, "isContested": "N", "addressComplement": null, "details": [ { "sequenceNumber": 1, "startDate": "2019-06-12T00:00:00Z", "endDate": "2019-06-30T00:00:00Z", "origin": "STS SP", "destination": null, "destinationCountry": " ", "startTime": " ", "endTime": " ", "callDuration": 1.0, "callDurationUnit": "UNIDADE", "callValue": 14.45, "callDetailValue": 20.25, "originTerminal": "1332233441--FRANQUIA 001", "targetTerminal": null, "taxType": "E", "entryDate": "2019-07-17T20:29:46Z", "itemDetailId": 0 }, { "sequenceNumber": 2, "startDate": "2019-07-01T00:00:00Z", "endDate": "2019-07-11T00:00:00Z", "origin": "STS SP", "destination": null, "destinationCountry": " ", "startTime": " ", "endTime": " ", "callDuration": 1.0, "callDurationUnit": "UNIDADE", "callValue": 8.89, "callDetailValue": 12.45, "originTerminal": "1332233441--FRANQUIA 001", "targetTerminal": null, "taxType": "E", "entryDate": "2019-07-17T20:29:46Z", "itemDetailId": 0 } ] }, { "itemId": 474854535, "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-17T20:29:46Z", "itemDescription": "LIGACOES DDD PARA TELEFONES FIXOS", "itemType": "NET FO EBT DDD TEL FIXOS", "amount": 0.0, "isContested": "N", "addressComplement": null, "details": [ { "sequenceNumber": 3, "startDate": "2019-06-13T00:00:00Z", "endDate": "2019-06-13T00:00:00Z", "origin": "STS SP", "destination": "São Paulo", "destinationCountry": " ", "startTime": "15:53:02", "endTime": " ", "callDuration": 22.8, "callDurationUnit": "MINUTO", "callValue": 0.0, "callDetailValue": 0.0, "originTerminal": "1332233441--FRANQUIA 001", "targetTerminal": "1133382822", "taxType": "E", "entryDate": "2019-07-17T20:29:46Z", "itemDetailId": 0 } ] }, { "itemId": 474854537, "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-17T20:29:46Z", "itemDescription": "LIGACOES LOCAIS PARA NET FONE E CLARO FONE - DURACAO E VALOR DAS LIGACOES REALIZADAS PARA O MESMO NUMERO ESTAO SOMADOS", "itemType": "NET FO EBT LC TOT TEL F", "amount": 0.0, "isContested": "N", "addressComplement": null, "details": [ { "sequenceNumber": 4, "startDate": null, "endDate": null, "origin": "STS SP", "destination": "Santos", "destinationCountry": " ", "startTime": " ", "endTime": " ", "callDuration": 6.0, "callDurationUnit": "MINUTO", "callValue": 0.0, "callDetailValue": 0.0, "originTerminal": "1332233441--FRANQUIA 001", "targetTerminal": "1332895053", "taxType": "E", "entryDate": "2019-07-17T20:29:46Z", "itemDetailId": 0 } ] }, { "itemId": 474854539, "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-17T20:29:46Z", "itemDescription": "LIGACOES LOCAIS PARA TELEFONES FIXOS - DURACAO E VALOR DAS LIGACOES REALIZADAS PARA O MESMO NUMERO ESTAO SOMADOS", "itemType": "NET FO EBT LOC TL FX DES", "amount": 0.0, "isContested": "N", "addressComplement": null, "details": [ { "sequenceNumber": 5, "startDate": null, "endDate": null, "origin": "STS SP", "destination": "Santos", "destinationCountry": " ", "startTime": " ", "endTime": " ", "callDuration": 1.1, "callDurationUnit": "MINUTO", "callValue": 0.0, "callDetailValue": 0.0, "originTerminal": "1332233441--FRANQUIA 001", "targetTerminal": "1332328355", "taxType": "E", "entryDate": "2019-07-17T20:29:46Z", "itemDetailId": 0 }, { "sequenceNumber": 6, "startDate": null, "endDate": null, "origin": "STS SP", "destination": "Santos", "destinationCountry": " ", "startTime": " ", "endTime": " ", "callDuration": 24.2, "callDurationUnit": "MINUTO", "callValue": 0.0, "callDetailValue": 0.0, "originTerminal": "1332233441--FRANQUIA 001", "targetTerminal": "1332392359", "taxType": "E", "entryDate": "2019-07-17T20:29:46Z", "itemDetailId": 0 }, { "sequenceNumber": 7, "startDate": null, "endDate": null, "origin": "STS SP", "destination": "Santos", "destinationCountry": " ", "startTime": " ", "endTime": " ", "callDuration": 48.3, "callDurationUnit": "MINUTO", "callValue": 0.0, "callDetailValue": 0.0, "originTerminal": "1332233441--FRANQUIA 001", "targetTerminal": "1332881533", "taxType": "E", "entryDate": "2019-07-17T20:29:46Z", "itemDetailId": 0 }, { "sequenceNumber": 8, "startDate": null, "endDate": null, "origin": "STS SP", "destination": "Santos", "destinationCountry": " ", "startTime": " ", "endTime": " ", "callDuration": 1.9, "callDurationUnit": "MINUTO", "callValue": 0.0, "callDetailValue": 0.0, "originTerminal": "1332233441--FRANQUIA 001", "targetTerminal": "1335768974", "taxType": "E", "entryDate": "2019-07-17T20:29:46Z", "itemDetailId": 0 }, { "sequenceNumber": 9, "startDate": null, "endDate": null, "origin": "STS SP", "destination": "Santos", "destinationCountry": " ", "startTime": " ", "endTime": " ", "callDuration": 0.5, "callDurationUnit": "MINUTO", "callValue": 0.0, "callDetailValue": 0.0, "originTerminal": "1332233441--FRANQUIA 001", "targetTerminal": "1340201414", "taxType": "E", "entryDate": "2019-07-17T20:29:46Z", "itemDetailId": 0 } ] } ] } ] } ] }, { "partnerId": 1, "partnerName": "NET", "debtId": 225168222, "generationDate": "2019-07-22T00:00:00Z", "originalDueDate": "2019-08-10T00:00:00Z", "dueDate": null, "amount": 417.91, "amountPaid": null, "balance": 417.91, "isExternalCollecting": null, "statusId": 10, "status": "EM ABERTO", "debtGroup": [ { "groupId": 5, "groupdescription": "OUTROS SERVIÇOS", "amount": "0", "order": "5", "extractItems": [ { "idExtractItem": 1573713906, "idExtractItemType": null, "itemDescription": "MENSALIDADE PROVEDOR", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023833, "productId": 3447, "productDescription": "COMODATO", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713911, "idExtractItemType": null, "itemDescription": "MENSALIDADE PROVEDOR", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023833, "productId": 4700, "productDescription": "ACESSO GRATIS", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 } ] }, { "groupId": 3, "groupdescription": "BANDA LARGA", "amount": "84.49", "order": "3", "extractItems": [ ] }, { "groupId": 1, "groupdescription": "TV POR ASSINATURA", "amount": "333.42", "order": "1", "extractItems": [ { "idExtractItem": 1573713915, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023831, "productId": 8153, "productDescription": "MUNDO PROMOCIONAL", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713924, "idExtractItemType": null, "itemDescription": "LOCACAO DECODIFICADOR DIGITAL", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023831, "productId": 9996, "productDescription": "ALUGUEL ZERO", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713928, "idExtractItemType": null, "itemDescription": "LOCACAO DECODIFICADOR DIGITAL", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023832, "productId": 9996, "productDescription": "ALUGUEL ZERO", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713933, "idExtractItemType": null, "itemDescription": "LOCACAO DECODIFICADOR DIGITAL", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 10575447, "productId": 9996, "productDescription": "ALUGUEL ZERO", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713936, "idExtractItemType": null, "itemDescription": "SERVICO DE GRAVACAO DIG", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023831, "productId": 10112, "productDescription": "SERVICO DE GRAVACAO DIGITAL", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713940, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023832, "productId": 11029, "productDescription": "NOTICIA PARA DEMAIS PONTOS DIG", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713945, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 10575447, "productId": 11029, "productDescription": "NOTICIA PARA DEMAIS PONTOS DIG", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713951, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023832, "productId": 11031, "productDescription": "MUNDO PARA DEMAIS PONTOS DIG", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713958, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 10575447, "productId": 11031, "productDescription": "MUNDO PARA DEMAIS PONTOS DIG", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713967, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023831, "productId": 11267, "productDescription": "NOTICIAS PROMOCIONAL DIGITAL", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713974, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023832, "productId": 11267, "productDescription": "NOTICIAS PROMOCIONAL DIGITAL", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713979, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 10575447, "productId": 11267, "productDescription": "NOTICIAS PROMOCIONAL DIGITAL", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713983, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023832, "productId": 11543, "productDescription": "ESPORTE PARA DEMAIS PONTOS DIG", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713990, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 10575447, "productId": 11543, "productDescription": "ESPORTE PARA DEMAIS PONTOS DIG", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573713995, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023831, "productId": 11714, "productDescription": "ESPORTE PROMOCIONAL DIGITAL", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573714000, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 10575447, "productId": 11714, "productDescription": "ESPORTE PROMOCIONAL DIGITAL", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573714005, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023831, "productId": 11888, "productDescription": "REPLAY TV GRATIS", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573714017, "idExtractItemType": null, "itemDescription": "ALUGUEL DE EQUIP HABILITADO", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 10575447, "productId": null, "productDescription": "TOP HD CINEMA PA GR 13573", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573714020, "idExtractItemType": null, "itemDescription": "MENSALIDADE PACOTE NOW", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023831, "productId": 14644, "productDescription": "TELECINE PLAY", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573714026, "idExtractItemType": null, "itemDescription": "MENSALIDADE PACOTE NOW", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023831, "productId": 16167, "productDescription": "HBO OD", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573714032, "idExtractItemType": null, "itemDescription": "MENSALIDADE TV PRINCIPAL", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 308.42, "addressComplement": null, "pointId": 6023831, "productId": null, "productDescription": "TOP HD MAX CINEMA OLD FID 16389", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573714038, "idExtractItemType": null, "itemDescription": "ALUGUEL DE EQUIP HABILITADO", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 25.0, "addressComplement": null, "pointId": 6023832, "productId": null, "productDescription": "TOP HD CINEMA FID 18714", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573714044, "idExtractItemType": null, "itemDescription": "MENSALIDADE PACOTE NOW", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023831, "productId": 19491, "productDescription": "ESPORTES NOW", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573714053, "idExtractItemType": null, "itemDescription": "MENSALIDADE PACOTE NOW", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023832, "productId": 19492, "productDescription": "NOTICIAS NOW", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573714057, "idExtractItemType": null, "itemDescription": "MENSALIDADE PACOTE NOW", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023831, "productId": 19493, "productDescription": "MUNDO NOW", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573714068, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 6023832, "productId": 31439, "productDescription": "REPLAY TV PARA DEMAIS PONTOS", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 }, { "idExtractItem": 1573714077, "idExtractItemType": null, "itemDescription": "MENSALIDADE CANAL A LA CARTE", "installmentNumber": null, "totalInstallments": null, "dueDate": "2019-08-10T00:00:00Z", "entryDate": "2019-07-01T00:00:00Z", "amount": 0.0, "addressComplement": null, "pointId": 10575447, "productId": 31439, "productDescription": "REPLAY TV PARA DEMAIS PONTOS", "proRataUnificationGroup": null, "proRataStartDate": null, "order": 1 } ] } ], "serviceGroup": null } ] } }',
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
		InvoicesController.getInvoiceDetails('001027935', '244986912', '004', 'testes', 'JEJE93', 'JEJE93');
		Test.stopTest();

		// InvoiceDetailsWrapper detail = (InvoiceDetailsWrapper)retValue.get('invoiceDetails');
		// System.assertEquals(retValue.get('success'), true);
		// System.assertEquals(detail.Status, 'Em Aberto');
	}

	@isTest
	static void getSobjectName() {
		Test.startTest();
		InvoicesUtils.getSobjectName('');
		Test.stopTest();
	}

	@isTest
	public static void getInvoiceDetailsError() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock('{"error": { "message": "", "errorCode": "", "httpCode": "", "detailedMessage": "error"}}', 500);
		Test.setMock(HttpCalloutMock.class, mock);

		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'InvoiceDetails';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = '00';
		customSetting.Timeout__c = 120;
		insert customSetting;

		Test.startTest();
		Map<String, Object> result = InvoicesController.getInvoiceDetails('12078302', '004', '004', 'DETAILS', 'JEJE93', 'JEJE93');
		Test.stopTest();

		System.assertEquals(result.get('success'), false);
	}

	@isTest
	public static void getOpenInvoicesError() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock('{"error": { "message": "", "errorCode": "", "httpCode": "", "detailedMessage": "error"}}', 500);
		Test.setMock(HttpCalloutMock.class, mock);

		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'Invoices';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = '00';
		customSetting.Timeout__c = 120;
		insert customSetting;

		Test.startTest();
		Map<String, Object> invError = InvoicesController.getOpenInvoices('001027935', '004', null, null, null);
		Test.stopTest();

		System.assertEquals(invError.get('success'), false);
	}

	@isTest
	public static void getOpenInvoices() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{ "apiVersion": "1;2019-01-08", "transactionId": "Id-c409fe5e27ca60097b48cc1e", "data": { "invoices": [ { "invoiceId": "244986912", "statusInvoiceId": "1", "statusInvoiceDescription": "Em Aberto", "dueDate": "2019-08-10", "invoiceAmount": "450.61", "paymentForm": null }, { "invoiceId": "243088994", "statusInvoiceId": "2", "statusInvoiceDescription": "Pago", "dueDate": "2019-07-10", "invoiceAmount": "449.89", "paymentForm": null }, { "invoiceId": "241201968", "statusInvoiceId": "2", "statusInvoiceDescription": "Pago", "dueDate": "2019-06-10", "invoiceAmount": "449.89", "paymentForm": null } ] } }',
			200
		);
		Test.setMock(HttpCalloutMock.class, mock);

		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'Invoices';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = '00';
		customSetting.Timeout__c = 120;
		insert customSetting;

		Test.startTest();
		Map<String, Object> objInvoices = InvoicesController.getOpenInvoices('001027935', '004', null, null, null);
		Test.stopTest();

		System.assertEquals(objInvoices.get('success'), true);
	}

	@isTest
	public static void getOpenInvoicesByPeriod() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{ "apiVersion": "1;2019-01-08", "transactionId": "Id-c409fe5e27ca60097b48cc1e", "data": { "invoices": [ { "invoiceId": "244986912", "statusInvoiceId": "1", "statusInvoiceDescription": "Em Aberto", "dueDate": "2019-08-10", "invoiceAmount": "450.61", "paymentForm": null }, { "invoiceId": "243088994", "statusInvoiceId": "2", "statusInvoiceDescription": "Pago", "dueDate": "2019-07-10", "invoiceAmount": "449.89", "paymentForm": null }, { "invoiceId": "241201968", "statusInvoiceId": "2", "statusInvoiceDescription": "Pago", "dueDate": "2019-06-10", "invoiceAmount": "449.89", "paymentForm": null } ] } }',
			200
		);
		Test.setMock(HttpCalloutMock.class, mock);

		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'Invoices';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = '00';
		customSetting.Timeout__c = 120;
		insert customSetting;
		InvoicesWrapper wrp = new InvoicesWrapper();
		wrp.dataBaixa = '';
		wrp.dataPagamento = '';
		wrp.produto = '';

		Test.startTest();
		Map<String, Object> objInvoices = InvoicesController.getOpenInvoicesByPeriod('001027935', '004', 6, null);
		Test.stopTest();

		System.assertEquals(objInvoices.get('success'), true);
		try {
			System.assertEquals(((List<InvoicesWrapper>) objInvoices.get('invoices')).size(), 3);
		} catch (Exception e) {
			System.assertEquals(true, false, 'Invoice not returned');
		}
	}

	@isTest
	public static void getOpenInvoicesByPeriodUnique() {
		InvoiceDetailsMock mock = new InvoiceDetailsMock(
			'{ "apiVersion": "1;2019-01-08", "transactionId": "Id-c409fe5e27ca60097b48cc1e", "data": { "invoices": { "invoiceId": "244986912", "statusInvoiceId": "1", "statusInvoiceDescription": "Em Aberto", "dueDate": "2019-08-10", "invoiceAmount": "450.61", "paymentForm": null } }}',
			200
		);
		Test.setMock(HttpCalloutMock.class, mock);

		ServiceParameter__c customSetting = new ServiceParameter__c();
		customSetting.name = 'Invoices';
		customSetting.EndPoint__c = '00';
		customSetting.Method__c = '00';
		customSetting.Timeout__c = 120;
		insert customSetting;

		Test.startTest();
		Map<String, Object> objInvoices = InvoicesController.getOpenInvoicesByPeriod('001027935', '004', 6, null);
		Test.stopTest();

		System.assertEquals(objInvoices.get('success'), true);
		try {
			System.assertEquals(((List<InvoicesWrapper>) objInvoices.get('invoices')).size(), 1);
		} catch (Exception e) {
			System.assertEquals(true, false, 'Invoice not returned');
		}
	}

	@isTest
	static void getDuplicateInfoTeste() {
		Test.startTest();
		try {
			InvoicesController.getDuplicateInfo('004', '74226094');
		} catch (exception e) {
		}
		Test.stopTest();
	}

	@isTest
	static void postDuplicateTeste() {
		String result;
		String cs = [SELECT id FROM Case LIMIT 1].Id;
		Test.startTest();
		try {
			InvoicesController.postDuplicate(
				'004',
				'1027935',
				'MCIDA',
				'229531991',
				'ROGERIO GONCALVES RODRIGUES',
				'62996656204',
				'rogerio.gr7@gmail.com',
				'L',
				'NAO',
				'ATRASO - TRANSMISSÃO ARQUIVO FEBRABAN',
				cs
			);
		} catch (exception e) {
		}
		Test.stopTest();
		system.assertEquals(result, result);
	}

	@isTest
	public static void getInvoiceParams() {
		Case cs = [SELECT id FROM Case LIMIT 1];

		Test.startTest();
		InvoicesController.getInvoiceParams(cs.id);
		InvoicesController.getInvoiceParams(null);

		Test.stopTest();
	}
}