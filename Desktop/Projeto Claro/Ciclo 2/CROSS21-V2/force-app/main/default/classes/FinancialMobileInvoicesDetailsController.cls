/**
 * @description       : Classe de contro do componente solarFinanceiroDetalhedaFatura

 * @author            : Caio Cesar Leite de Oliveira
 * @group             : IBM
 * @last modified on  : 18-12-2020
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   08-12-2020   Caio Cesar   Initial Version
**/
public without sharing class FinancialMobileInvoicesDetailsController {

    @AuraEnabled
	public static FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetailsWrapper getInvoiceDetails(String noteFiscalNumber) {
		System.debug('getInvoiceDetails: ' + noteFiscalNumber);


		FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetailsWrapper response = new FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetailsWrapper();

		Map<String, String> params = new Map<String, String>();

            params.put('invoiceNumber', noteFiscalNumber);
			//params.put('invoiceNumber', '125890802001');//mock
		System.debug('getInvoiceDetails params: ' + params);

        Map<String, String> headers = new Map<String, String>();
            String authToken = getAuth('FinancialMobileBilledChargesDetails');
            //String authToken = '';//mock
			headers.put('X-Client-Auth', authToken);
		System.debug('getInvoiceDetails headers: ' + headers);

		Map<String, String> calloutResponse = OutboundCalloutHandler.sendRequest('', params, headers, 'FinancialMobileBilledChargesDetails');
		//Map<String, String> calloutResponse = new Map<String, String>();
		//BEGIN MOCK
        //calloutResponse.put('response', '{"apiVersion":"1;2020-02-23","transactionId":"efefdca0-3f6e-40cb-b6b7-ff5c76aa1f29","data":{"invoices":[{"billAmount":"250.00","paymentDueDate":"12/08/2020","status":"Aberta","billCode":"848100000008621501622013904151077916357018111559","name":"MARIA SILVA","partyIdentificationNumber":"12345678900","customerAccountId":"00612345679","telephoneNumber":"1129285598","secondary":{"telephoneNumbers":["1129285598"]},"paymentMethod":"BOLETO","company":"NET","origin":"NETSMS","isCombomulti":"true"}]},"pagination":{"start":"1","limit":"10","X-Total-Count":"1"}}');
        // calloutResponse.put('response','{"apiVersion":"1;2020-09-28","transactionId":"96dd1a35-6a3d-49d0-9121-c169ee1c25ce","data":{"billedCharged":[{"chargeId":"160588836313714428","payChannelId":"265.476.127","activityCode":"CHG","activityReasonCode": "R","originalActivityAmount":"0","originalActivityTaxAmount": 60,"activityAmountIncludingTax":60,"activityDate":"2018-12-23T00:00:00-03:00","invoiceSequenceNumber":"68","chargeCode":"FGPRS1","chargeRevenueCode":"R","currentAmount":"60","currentTaxAmount":"60","invoiceType":"B","chargeCodeDesc":"Assinatura Controle ","subscriberNo":"316,728,671","chargeSeqNo":"313,714,428","ldInd":"N","purgeSeqNo":"1","dismSeqNo":"1","paSeqNo":"1","relToPaInd": "1","colExcludeInd": "N"},'
        //                                                                                                                                            +'{"chargeId":"170588836313714428","payChannelId":"266.476.127","activityCode":"CHG","activityReasonCode": "R","originalActivityAmount":"0","originalActivityTaxAmount": 60,"activityAmountIncludingTax":60,"activityDate":"2018-12-23T00:00:00-03:00","invoiceSequenceNumber":"68","chargeCode":"FGPRS1","chargeRevenueCode":"R","currentAmount":"60","currentTaxAmount":"60","invoiceType":"B","chargeCodeDesc":"Assinatura Pós ","subscriberNo":"317,728,671","chargeSeqNo":"314,714,428","ldInd":"N","purgeSeqNo":"1","dismSeqNo":"1","paSeqNo":"1","relToPaInd": "1","colExcludeInd": "N"},'
        //                                                                                                                                            +'{"chargeId":"180588836313714428","payChannelId":"267.476.127","activityCode":"CHG","activityReasonCode": "R","originalActivityAmount":"0","originalActivityTaxAmount": 60,"activityAmountIncludingTax":0,"activityDate":"2018-12-23T00:00:00-03:00","invoiceSequenceNumber":"68","chargeCode":"FGPRS1","chargeRevenueCode":"R","currentAmount":"60","currentTaxAmount":"60","invoiceType":"B","chargeCodeDesc":"Assinatura Pré ","subscriberNo":"318,728,671","chargeSeqNo":"315,714,428","ldInd":"N","purgeSeqNo":"1","dismSeqNo":"1","paSeqNo":"1","relToPaInd": "1","colExcludeInd": "N"},'
        //                                                                                                                                            +'{"chargeId":"190588836313714428","payChannelId":"268.476.127","activityCode":"CHG","activityReasonCode": "R","originalActivityAmount":"0","originalActivityTaxAmount": 60,"activityAmountIncludingTax":60,"activityDate":"2018-12-23T00:00:00-03:00","invoiceSequenceNumber":"68","chargeCode":"FGPRS1","chargeRevenueCode":"R","currentAmount":"60","currentTaxAmount":"60","invoiceType":"B","chargeCodeDesc":"Assinatura Full ","subscriberNo":"319,728,671","chargeSeqNo":"316,714,428","ldInd":"N","purgeSeqNo":"1","dismSeqNo":"1","paSeqNo":"1","relToPaInd": "1","colExcludeInd": "N"}'
        //                                                                                                                                            +']}}');
        // calloutResponse.put('statusCode', '200');

		//END MOCK

		response.responseCode = Integer.valueOf(calloutResponse.get('statusCode'));
		if(response.responseCode < 400){
            System.debug('getInvoiceDetails calloutResponse: ' + JSON.serializePretty(calloutResponse));
			FinancialMobileInvoicesDetailsWrapper.ResponseInvoicesDetails responseObject = (FinancialMobileInvoicesDetailsWrapper.ResponseInvoicesDetails)JSON.deserialize(calloutResponse.get('response'), FinancialMobileInvoicesDetailsWrapper.ResponseInvoicesDetails.class);
            System.debug('getInvoiceDetails responseObject: ' + responseObject);
            response.responseData = processInvoiceDetailsResponse(responseObject);
		}else{
            response.errorMessage = calloutResponse.get('response');
            System.debug('getInvoiceDetails response.errorMessage: ' + response.errorMessage);

            FinancialMobileUtils.processResponseCode(response.responseCode);

		}
		System.debug('getInvoices response: ' + response);
		return response;
    }
    
    private static List<FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetails> processInvoiceDetailsResponse(FinancialMobileInvoicesDetailsWrapper.ResponseInvoicesDetails responseObject){
		List<FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetails> returnData = new List<FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetails>();
		FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetails invoiceDetailData = new FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetails();
		for (FinancialMobileInvoicesDetailsWrapper.billedCharged invoice : responseObject.data.billedCharged) {
			System.debug('processInvoiceDetailsResponse invoice: ' + invoice);

            invoiceDetailData = new FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetails();
            invoiceDetailData.chargeId = invoice.chargeId;
            invoiceDetailData.payChannelId = invoice.payChannelId;
            invoiceDetailData.activityCode = invoice.activityCode;
            invoiceDetailData.activityReasonCode = invoice.activityReasonCode;
            invoiceDetailData.originalActivityAmount = invoice.originalActivityAmount;
            invoiceDetailData.originalActivityTaxAmount = invoice.originalActivityTaxAmount;
            invoiceDetailData.valor = invoice.activityAmountIncludingTax;       
            invoiceDetailData.dataLancamento = invoice.activityDate; 
            invoiceDetailData.invoiceSequenceNumber = invoice.invoiceSequenceNumber;
            invoiceDetailData.chargeCode = invoice.chargeCode;
            invoiceDetailData.chargeRevenueCode = invoice.chargeRevenueCode;          
            invoiceDetailData.ajuste = invoice.currentAmount;
            invoiceDetailData.currentTaxAmount = invoice.currentTaxAmount;
            invoiceDetailData.invoiceType = invoice.invoiceType;                   
            invoiceDetailData.item = invoice.chargeCodeDesc;                    
            invoiceDetailData.linha = invoice.subscriberNo;
            invoiceDetailData.chargeSeqNo = invoice.chargeSeqNo;
            invoiceDetailData.ldInd = invoice.ldInd;
            invoiceDetailData.purgeSeqNo = invoice.purgeSeqNo;
            invoiceDetailData.dismSeqNo = invoice.dismSeqNo;
            invoiceDetailData.paSeqNo = invoice.paSeqNo;
            invoiceDetailData.relToPaInd = invoice.relToPaInd;
            invoiceDetailData.colExcludeInd  = invoice.colExcludeInd;                    

            invoiceDetailData.consumo = '';
            if(invoice.currentAmount > 0){

                invoiceDetailData.contestavel = 'Sim';
            }
            else{
                invoiceDetailData.contestavel = 'Não';
            }
            returnData.add(invoiceDetailData);
		}
        return returnData;
    }

    private static String getAuth(String customSetting){
        ServiceParameter__c setting = ServiceParameter__c.getValues(customSetting);
        String token = setting.Token__c;
        return token;
	}
    
    // /**
    // * @description return Method para LWC solarFinanceiroDetalhedaFatura
    // * @author Diego Almeida | 20-10-2020 
    // * @return FinancialMobileInvoicesDetailsWrapper.ResponseWrapper 
    // **/
    // @AuraEnabled
    // public static FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetailsWrapper getListInvoiceDetails(String dataInvoice) {
    //     System.debug('getListInvoiceDetails');
    //     System.debug('dataInvoice ==> ' + dataInvoice);
    //     FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetailsWrapper responseData = new FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetailsWrapper();
    //     responseData = makeDataGrid(responseData);

    //     return responseData;
    // }

    // /**
    // * @description Retorna o makeData para o DataTreeGrid
    // * @author Diego Almeida | 29-10-2020 
    // * @param response FinancialMobileInvoicesDetailsWrapper wrapper
    // * @return FinancialMobileInvoicesDetailsWrapper.ResponseWrapper 
    // **/
    // private static FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetailsWrapper makeDataGrid(FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetailsWrapper objResponse) {
    //     String stringResponse = '{"responseCode":200,"gridMobile":[{"lineId":55,"description":"Plano Contratado","value":"TOTAL R$ 159.90","children":[{"lineId":1,"description":"Oferta Conjunta Claro MIX","value":"TOTAL R$ 54.90","children":[{"lineId":2,"description":"Aplicativos Digitais","value":"TOTAL R$ 54.90","children":[{"lineId":3,"description":"Claro Video","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 19,90"},{"lineId":4,"description":"Claro Musica","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 12,90"}]},{"lineId":5,"description":"Claro Pos 15GB (155)","value":"TOTAL R$ 54.90","children":[{"lineId":6,"description":"15Gb de internet","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 19,90"},{"lineId":7,"description":"Claro Extra play 15Gb","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 12,90"},{"lineId":8,"description":"Ligacoes locais e LDN...","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 12,90","children":[{"lineId":9,"dataShow":"01/05/2020","hour":"09:49:22","callOrigin":"SAO PAULO","lineNumber":"077704913014","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":10,"dataShow":"01/05/2020","hour":"12:01:33","callOrigin":"SAO PAULO","lineNumber":"077704913014","callLength":"00:08:22","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":11,"dataShow":"04/05/2020","hour":"13:04:02","callOrigin":"SAO PAULO","lineNumber":"040432593388","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":12,"dataShow":"04/05/2020","hour":"16:30:59","callOrigin":"SAO PAULO","lineNumber":"040428455737","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"}]},{"lineId":13,"description":"Promocao WhatsApp","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 12,90"},{"lineId":14,"description":"Torpedos ilimitados","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 12,90"},{"lineId":15,"description":"Descontos Promocionais","value":"- R$ 30,00","children":[{"lineId":16,"description":"Desconto","value":"- R$ 30,00"}]}]}]}]},{"lineId":17,"description":"Linhas Dependentes","value":"R$ 27.99","children":[{"lineId":18,"description":"11 99165 3007","children":[{"lineId":19,"description":"Dependente play com comp. Total","value":"R$ 39,99"},{"lineId":20,"description":"Desconto por Permanecia","value":"-R$ 12,00"}]}]},{"lineId":21,"description":"Outros Lancamentos","value":"R$ 2,30","children":[{"lineId":22,"description":"Juros e Multa","value":"R$ 2,30"}]},{"lineId":23,"description":"Detalhamento de Ligacoes e servicos do celular (16) 98174-3007","children":[{"lineId":24,"description":"Resumo de ligacoes dentro da Franquia","children":[{"lineId":25,"description":"Ligacoes para celulares Claro","children":[{"lineId":26,"dataShow":"01/05/2020","hour":"09:49:22","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":27,"dataShow":"01/05/2020","hour":"12:01:33","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:08:22","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":28,"dataShow":"04/05/2020","hour":"13:04:02","callOrigin":"SAO PAULO","callNumber":"040432593388","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":29,"dataShow":"04/05/2020","hour":"16:30:59","callOrigin":"SAO PAULO","callNumber":"040428455737","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"}]},{"lineId":30,"description":"Ligacoes para celulares de outra Operadora","children":[{"lineId":31,"dataShow":"01/05/2020","hour":"09:49:22","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":32,"dataShow":"01/05/2020","hour":"12:01:33","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:08:22","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":33,"dataShow":"04/05/2020","hour":"13:04:02","callOrigin":"SAO PAULO","callNumber":"040432593388","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":34,"dataShow":"04/05/2020","hour":"16:30:59","callOrigin":"SAO PAULO","callNumber":"040428455737","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"}]},{"lineId":35,"description":"Ligacoes para fixos","children":[{"lineId":36,"dataShow":"01/05/2020","hour":"09:49:22","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":37,"dataShow":"01/05/2020","hour":"12:01:33","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:08:22","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":38,"dataShow":"04/05/2020","hour":"13:04:02","callOrigin":"SAO PAULO","callNumber":"040432593388","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":39,"dataShow":"04/05/2020","hour":"16:30:59","callOrigin":"SAO PAULO","callNumber":"040428455737","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"}]},{"lineId":40,"description":"Ligacoes para numeros especiais","children":[{"lineId":41,"dataShow":"01/05/2020","hour":"09:49:22","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":42,"dataShow":"01/05/2020","hour":"12:01:33","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:08:22","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":43,"dataShow":"04/05/2020","hour":"13:04:02","callOrigin":"SAO PAULO","callNumber":"040432593388","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":44,"dataShow":"04/05/2020","hour":"16:30:59","callOrigin":"SAO PAULO","callNumber":"040428455737","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"}]}]}]}]}';
    //     objResponse = (FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetailsWrapper)JSON.deserialize(stringResponse, FinancialMobileInvoicesDetailsWrapper.ResponseInvoiceDetailsWrapper.class);
    //     objResponse.gridColumns = returnColumns('gridColums');
    //     return objResponse;
    // }
    
    // /**
    // * @description Return layout of columns for each datatable
    // * @author Diego Almeida | 28-10-2020 
    // * @param layoutColumn String 'gridColums'
    // * @return List<FinancialMobileInvoicesDetailsWrapper.Columns> 
    // **/
    // private static List<FinancialMobileInvoicesDetailsWrapper.Columns> returnColumns(String layoutColumn) {
    //     List<FinancialMobileInvoicesDetailsWrapper.Columns> lstReturn = new List<FinancialMobileInvoicesDetailsWrapper.Columns>();
        

    //     if(layoutColumn == 'gridColums')
    //     {
    //         FinancialMobileInvoicesDetailsWrapper.Columns column = new FinancialMobileInvoicesDetailsWrapper.Columns();
    //         column.label = 'Item';
    //         column.fieldName = 'description';
    //         column.type = 'text';
    //         column.hideDefaultActions = true;
    //         column.sortable = true;
    //         column.typeAttributes = new FinancialMobileInvoicesDetailsWrapper.AtributeColumns();
    //             FinancialMobileInvoicesDetailsWrapper.AtributeColumns atributes = new FinancialMobileInvoicesDetailsWrapper.AtributeColumns();
    //             atributes.tooltip = 'Detalhar';
    //             atributes.target = '_blank';
    //             atributes.rowActions = new List<FinancialMobileInvoicesDetailsWrapper.RowAction>();
    //                 FinancialMobileInvoicesDetailsWrapper.RowAction actionsRow = new FinancialMobileInvoicesDetailsWrapper.RowAction();
    //                 actionsRow.name = 'demo';
    //                 actionsRow.label = 'Demo';
    //                 atributes.rowActions.add(actionsRow);
    //             column.typeAttributes = atributes;
    //         lstReturn.add(column);

    //         column = new FinancialMobileInvoicesDetailsWrapper.Columns();
    //         column.label = 'Linha';
    //         column.fieldName = 'lineNumber';
    //         column.type = 'text';
    //         column.hideDefaultActions = true;
    //         column.sortable = true;
    //         lstReturn.add(column);

    //         column = new FinancialMobileInvoicesDetailsWrapper.Columns();
    //         column.label = 'Data de Lancamento';
    //         column.fieldName = 'dataShow';
    //         column.type = 'text';
    //         column.hideDefaultActions = true;
    //         column.sortable = true;
    //         lstReturn.add(column);

    //         column = new FinancialMobileInvoicesDetailsWrapper.Columns();
    //         column.label = 'Hora';
    //         column.fieldName = 'hour';
    //         column.type = 'text';
    //         column.hideDefaultActions = true;
    //         column.sortable = true;
    //         lstReturn.add(column);

    //         column = new FinancialMobileInvoicesDetailsWrapper.Columns();
    //         column.label = 'Origem';
    //         column.fieldName = 'callOrigin';
    //         column.type = 'text';
    //         column.hideDefaultActions = true;
    //         column.sortable = true;
    //         lstReturn.add(column);

    //         column = new FinancialMobileInvoicesDetailsWrapper.Columns();
    //         column.label = 'Destino';
    //         column.fieldName = 'callNumber';
    //         column.type = 'text';
    //         column.hideDefaultActions = true;
    //         column.sortable = true;
    //         lstReturn.add(column);

    //         column = new FinancialMobileInvoicesDetailsWrapper.Columns();
    //         column.label = 'Consumo';
    //         column.fieldName = 'consumption';
    //         column.type = 'text';
    //         column.hideDefaultActions = true;
    //         column.sortable = true;
    //         lstReturn.add(column);

    //         column = new FinancialMobileInvoicesDetailsWrapper.Columns();
    //         column.label = 'Duracao';
    //         column.fieldName = 'callLength';
    //         column.type = 'text';
    //         column.hideDefaultActions = true;
    //         column.sortable = true;
    //         lstReturn.add(column);

    //         column = new FinancialMobileInvoicesDetailsWrapper.Columns();
    //         column.label = 'Contestavel';
    //         column.fieldName = 'contestation';
    //         column.type = 'text';
    //         column.hideDefaultActions = true;
    //         column.sortable = true;
    //         lstReturn.add(column);

    //         column = new FinancialMobileInvoicesDetailsWrapper.Columns();
    //         column.label = 'Tarifa';
    //         column.fieldName = 'rate';
    //         column.type = 'text';
    //         column.hideDefaultActions = true;
    //         column.sortable = true;
    //         lstReturn.add(column);

    //         column = new FinancialMobileInvoicesDetailsWrapper.Columns();
    //         column.label = 'Ajuste';
    //         column.fieldName = 'adjustment';
    //         column.type = 'text';
    //         column.hideDefaultActions = true;
    //         column.sortable = true;
    //         lstReturn.add(column);

    //         column = new FinancialMobileInvoicesDetailsWrapper.Columns();
    //         column.label = 'Valor';
    //         column.fieldName = 'value';
    //         column.type = 'text';
    //         column.hideDefaultActions = true;
    //         column.sortable = true;
    //         lstReturn.add(column);

    //         // column = new FinancialMobileInvoicesDetailsWrapper.Columns();
    //         //     column.type = 'button';
    //         //     column.typeAttributes = new FinancialMobileInvoicesDetailsWrapper.AtributeColumns();
                
    //         //     FinancialMobileInvoicesDetailsWrapper.AtributeColumns atribute = new FinancialMobileInvoicesDetailsWrapper.AtributeColumns();
    //         //     atribute.iconName = 'utility:preview';
    //         //     atribute.label = ' ';
    //         //     atribute.name = 'showDetail';
    //         //     atribute.disabled = false;
    //         //     column.typeAttributes = atribute;
    //         // lstReturn.add(column);
    //     }

    //     return lstReturn;
    // }


}