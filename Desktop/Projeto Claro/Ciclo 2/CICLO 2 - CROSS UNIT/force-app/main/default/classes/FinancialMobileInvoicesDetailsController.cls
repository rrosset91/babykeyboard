/**
 * @description       : Classe de contro do componente solarFinanceiroDetalhedaFatura
 * @author            : Diego Almeida
 * @group             : IBM
 * @last modified on  : 30-10-2020
 * @last modified by  : Diego Almeida
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   20-10-2020   Diego Almeida   Initial Version
 * 1.1   29-10-2020   Diego Almeida   Changed data structure to TreeGrid
**/
public without sharing class FinancialMobileInvoicesDetailsController {
    /**
    * @description return Method para LWC solarFinanceiroDetalhedaFatura
    * @author Diego Almeida | 20-10-2020 
    * @return FinancialMobileInvoicesDetailsWrapper.ResponseWrapper 
    **/
    @AuraEnabled
    public static FinancialMobileInvoicesDetailsWrapper.ResponseWrapper getListInvoiceDetails(String dataInvoice) {
        System.debug('getListInvoiceDetails');
        System.debug('dataInvoice ==> ' + dataInvoice);
        FinancialMobileInvoicesDetailsWrapper.ResponseWrapper responseData = new FinancialMobileInvoicesDetailsWrapper.ResponseWrapper();
        responseData = makeDataGrid(responseData);

        return responseData;
    }

    /**
    * @description Retorna o makeData para o DataTreeGrid
    * @author Diego Almeida | 29-10-2020 
    * @param response FinancialMobileInvoicesDetailsWrapper wrapper
    * @return FinancialMobileInvoicesDetailsWrapper.ResponseWrapper 
    **/
    private static FinancialMobileInvoicesDetailsWrapper.ResponseWrapper makeDataGrid(FinancialMobileInvoicesDetailsWrapper.ResponseWrapper objResponse) {
        String stringResponse = '{"responseCode":200,"gridMobile":[{"lineId":55,"description":"Plano Contratado","value":"TOTAL R$ 159.90","children":[{"lineId":1,"description":"Oferta Conjunta Claro MIX","value":"TOTAL R$ 54.90","children":[{"lineId":2,"description":"Aplicativos Digitais","value":"TOTAL R$ 54.90","children":[{"lineId":3,"description":"Claro Video","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 19,90"},{"lineId":4,"description":"Claro Musica","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 12,90"}]},{"lineId":5,"description":"Claro Pos 15GB (155)","value":"TOTAL R$ 54.90","children":[{"lineId":6,"description":"15Gb de internet","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 19,90"},{"lineId":7,"description":"Claro Extra play 15Gb","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 12,90"},{"lineId":8,"description":"Ligacoes locais e LDN...","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 12,90","children":[{"lineId":9,"dataShow":"01/05/2020","hour":"09:49:22","callOrigin":"SAO PAULO","lineNumber":"077704913014","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":10,"dataShow":"01/05/2020","hour":"12:01:33","callOrigin":"SAO PAULO","lineNumber":"077704913014","callLength":"00:08:22","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":11,"dataShow":"04/05/2020","hour":"13:04:02","callOrigin":"SAO PAULO","lineNumber":"040432593388","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":12,"dataShow":"04/05/2020","hour":"16:30:59","callOrigin":"SAO PAULO","lineNumber":"040428455737","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"}]},{"lineId":13,"description":"Promocao WhatsApp","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 12,90"},{"lineId":14,"description":"Torpedos ilimitados","lineNumber":"1199259494","dataShow":"02/05/2020","contestation":"Nao","adjustment":"R$ 10,00","value":"R$ 12,90"},{"lineId":15,"description":"Descontos Promocionais","value":"- R$ 30,00","children":[{"lineId":16,"description":"Desconto","value":"- R$ 30,00"}]}]}]}]},{"lineId":17,"description":"Linhas Dependentes","value":"R$ 27.99","children":[{"lineId":18,"description":"11 99165 3007","children":[{"lineId":19,"description":"Dependente play com comp. Total","value":"R$ 39,99"},{"lineId":20,"description":"Desconto por Permanecia","value":"-R$ 12,00"}]}]},{"lineId":21,"description":"Outros Lancamentos","value":"R$ 2,30","children":[{"lineId":22,"description":"Juros e Multa","value":"R$ 2,30"}]},{"lineId":23,"description":"Detalhamento de Ligacoes e servicos do celular (16) 98174-3007","children":[{"lineId":24,"description":"Resumo de ligacoes dentro da Franquia","children":[{"lineId":25,"description":"Ligacoes para celulares Claro","children":[{"lineId":26,"dataShow":"01/05/2020","hour":"09:49:22","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":27,"dataShow":"01/05/2020","hour":"12:01:33","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:08:22","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":28,"dataShow":"04/05/2020","hour":"13:04:02","callOrigin":"SAO PAULO","callNumber":"040432593388","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":29,"dataShow":"04/05/2020","hour":"16:30:59","callOrigin":"SAO PAULO","callNumber":"040428455737","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"}]},{"lineId":30,"description":"Ligacoes para celulares de outra Operadora","children":[{"lineId":31,"dataShow":"01/05/2020","hour":"09:49:22","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":32,"dataShow":"01/05/2020","hour":"12:01:33","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:08:22","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":33,"dataShow":"04/05/2020","hour":"13:04:02","callOrigin":"SAO PAULO","callNumber":"040432593388","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":34,"dataShow":"04/05/2020","hour":"16:30:59","callOrigin":"SAO PAULO","callNumber":"040428455737","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"}]},{"lineId":35,"description":"Ligacoes para fixos","children":[{"lineId":36,"dataShow":"01/05/2020","hour":"09:49:22","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":37,"dataShow":"01/05/2020","hour":"12:01:33","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:08:22","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":38,"dataShow":"04/05/2020","hour":"13:04:02","callOrigin":"SAO PAULO","callNumber":"040432593388","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":39,"dataShow":"04/05/2020","hour":"16:30:59","callOrigin":"SAO PAULO","callNumber":"040428455737","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"}]},{"lineId":40,"description":"Ligacoes para numeros especiais","children":[{"lineId":41,"dataShow":"01/05/2020","hour":"09:49:22","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":42,"dataShow":"01/05/2020","hour":"12:01:33","callOrigin":"SAO PAULO","callNumber":"077704913014","callLength":"00:08:22","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":43,"dataShow":"04/05/2020","hour":"13:04:02","callOrigin":"SAO PAULO","callNumber":"040432593388","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"},{"lineId":44,"dataShow":"04/05/2020","hour":"16:30:59","callOrigin":"SAO PAULO","callNumber":"040428455737","callLength":"00:01:38","rate":"R$ 0,00","value":"R$ 0,00"}]}]}]}]}';
        objResponse = (FinancialMobileInvoicesDetailsWrapper.ResponseWrapper)JSON.deserialize(stringResponse, FinancialMobileInvoicesDetailsWrapper.ResponseWrapper.class);
        objResponse.gridColumns = returnColumns('gridColums');
        return objResponse;
    }
    
    /**
    * @description Return layout of columns for each datatable
    * @author Diego Almeida | 28-10-2020 
    * @param layoutColumn String 'gridColums'
    * @return List<FinancialMobileInvoicesDetailsWrapper.Columns> 
    **/
    private static List<FinancialMobileInvoicesDetailsWrapper.Columns> returnColumns(String layoutColumn) {
        List<FinancialMobileInvoicesDetailsWrapper.Columns> lstReturn = new List<FinancialMobileInvoicesDetailsWrapper.Columns>();
        

        if(layoutColumn == 'gridColums')
        {
            FinancialMobileInvoicesDetailsWrapper.Columns column = new FinancialMobileInvoicesDetailsWrapper.Columns();
            column.label = 'Item';
            column.fieldName = 'description';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesDetailsWrapper.Columns();
            column.label = 'Linha';
            column.fieldName = 'lineNumber';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesDetailsWrapper.Columns();
            column.label = 'Data de Lancamento';
            column.fieldName = 'dataShow';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesDetailsWrapper.Columns();
            column.label = 'Hora';
            column.fieldName = 'hour';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesDetailsWrapper.Columns();
            column.label = 'Origem';
            column.fieldName = 'callOrigin';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesDetailsWrapper.Columns();
            column.label = 'Destino';
            column.fieldName = 'callNumber';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesDetailsWrapper.Columns();
            column.label = 'Consumo';
            column.fieldName = 'consumption';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesDetailsWrapper.Columns();
            column.label = 'Duracao';
            column.fieldName = 'callLength';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesDetailsWrapper.Columns();
            column.label = 'Contestavel';
            column.fieldName = 'contestation';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesDetailsWrapper.Columns();
            column.label = 'Tarifa';
            column.fieldName = 'rate';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesDetailsWrapper.Columns();
            column.label = 'Ajuste';
            column.fieldName = 'adjustment';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesDetailsWrapper.Columns();
            column.label = 'Valor';
            column.fieldName = 'value';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesDetailsWrapper.Columns();
                column.label = '';
                column.initialWidth = 70;
                column.type = 'button';
                column.hideDefaultActions = true;
                column.typeAttributes = new FinancialMobileInvoicesDetailsWrapper.AtributeColumns();
                
                FinancialMobileInvoicesDetailsWrapper.AtributeColumns atribute = new FinancialMobileInvoicesDetailsWrapper.AtributeColumns();
                atribute.iconName = 'utility:preview';
                atribute.label = '';
                atribute.name = 'showDetail';
                atribute.disabled = false;
        }

        return lstReturn;
    }
}