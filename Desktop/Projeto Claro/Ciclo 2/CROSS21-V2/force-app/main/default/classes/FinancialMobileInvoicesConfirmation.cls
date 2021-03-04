/**
 * @description       :
 * @author            : Diego Almeida
 * @group             :
 * @last modified on  : 05-11-2020
 * @last modified by  : Diego Almeida
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   05-11-2020   Diego Almeida   Initial Version
**/
public without sharing class FinancialMobileInvoicesConfirmation {
    /**
    * @description
    * @author Diego Almeida | 05-11-2020
    * @param dataInvoice
    * @return FinancialMobileInvoicesConfirmWraper.ResponseWrapper
    **/
    @AuraEnabled
    public static FinancialMobileInvoicesConfirmWraper.ResponseWrapper getListContestation(String dataInvoice) {
        System.debug('getListInvoiceDetails');
        System.debug('dataInvoice ==> ' + dataInvoice);
        FinancialMobileInvoicesConfirmWraper.ResponseWrapper responseData = new FinancialMobileInvoicesConfirmWraper.ResponseWrapper();
        responseData = makeData(responseData);

        return responseData;
    }
    /**
    * @description Make data for tests
    * @author Diego Almeida | 05-11-2020
    * @param objResponse
    * @return FinancialMobileInvoicesConfirmWraper.ResponseWrapper
    **/
    private static FinancialMobileInvoicesConfirmWraper.ResponseWrapper makeData(FinancialMobileInvoicesConfirmWraper.ResponseWrapper objResponse) {
        String stringResponse = '{"responseCode":200,"totalOriginalValue":"R$ 220,00","totalCorrectedValue":"R$ 89,00","lstChanged":[{"lineId":0,"description":"NET FO EBT LIG 1","lineNumber":11294557570,"dateShow":"01/05/2020","dateSort":"2020-05-01","adjustment":"R$ 10,00","adjustmentSort":10.00,"originalValue":"R$ 90,00","originalValueSort":90.00,"correctedValue":"R$ 0,00","correctedValueSort":0.00},{"lineId":1,"description":"NET FO EBT LIG 2","lineNumber":11294557571,"dateShow":"02/05/2020","dateSort":"2020-05-02","adjustment":"R$ 10,00","adjustmentSort":10.00,"originalValue":"R$ 65,00","originalValueSort":65.00,"correctedValue":"R$ 0,00","correctedValueSort":0.00},{"lineId":2,"description":"NET FO EBT LIG 3","lineNumber":11294557572,"dateShow":"03/05/2020","dateSort":"2020-05-03","adjustment":"R$ 10,00","adjustmentSort":10.00,"originalValue":"R$ 12,00","originalValueSort":12.00,"correctedValue":"R$ 6,00","correctedValueSort":6.00},{"lineId":3,"description":"NET FO EBT LIG 4","lineNumber":11294557573,"dateShow":"04/05/2020","dateSort":"2020-05-04","adjustment":"R$ 10,00","adjustmentSort":10.00,"originalValue":"R$ 12,00","originalValueSort":12.00,"correctedValue":"R$ 6,00","correctedValueSort":6.00}],"lstNotChanged":[{"lineId":0,"description":"NET FO EBT LIG 1","lineNumber":11294557570,"dateShow":"01/05/2020","dateSort":"2020-05-01","adjustment":"R$ 10,00","adjustmentSort":10.00,"originalValue":"R$ 90,00","originalValueSort":90.00,"correctedValue":"R$ 0,00","correctedValueSort":0.00},{"lineId":1,"description":"NET FO EBT LIG 2","lineNumber":11294557571,"dateShow":"02/05/2020","dateSort":"2020-05-02","adjustment":"R$ 10,00","adjustmentSort":10.00,"originalValue":"R$ 65,00","originalValueSort":65.00,"correctedValue":"R$ 0,00","correctedValueSort":0.00},{"lineId":2,"description":"NET FO EBT LIG 3","lineNumber":11294557572,"dateShow":"03/05/2020","dateSort":"2020-05-03","adjustment":"R$ 10,00","adjustmentSort":10.00,"originalValue":"R$ 12,00","originalValueSort":12.00,"correctedValue":"R$ 6,00","correctedValueSort":6.00},{"lineId":3,"description":"NET FO EBT LIG 4","lineNumber":11294557573,"dateShow":"04/05/2020","dateSort":"2020-05-04","adjustment":"R$ 10,00","adjustmentSort":10.00,"originalValue":"R$ 12,00","originalValueSort":12.00,"correctedValue":"R$ 6,00","correctedValueSort":6.00}]}';
        objResponse = (FinancialMobileInvoicesConfirmWraper.ResponseWrapper)JSON.deserialize(stringResponse, FinancialMobileInvoicesConfirmWraper.ResponseWrapper.class);
        objResponse.columns = returnColumns();
        return objResponse;
    }
    /**
    * @description Return layout of columns for each datatable
    * @author Diego Almeida | 05-11-2020
    * @param layoutColumn String 'gridColums'
    * @return List<FinancialMobileInvoicesConfirmWraper.Columns>
    **/
    private static List<FinancialMobileInvoicesConfirmWraper.Columns> returnColumns() {
        List<FinancialMobileInvoicesConfirmWraper.Columns> lstReturn = new List<FinancialMobileInvoicesConfirmWraper.Columns>();
        FinancialMobileInvoicesConfirmWraper.Columns column = new FinancialMobileInvoicesConfirmWraper.Columns();
            column.label = 'Item';
            column.fieldName = 'description';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            column.typeAttributes = new FinancialMobileInvoicesConfirmWraper.AtributeColumns();

            lstReturn.add(column);

            column = new FinancialMobileInvoicesConfirmWraper.Columns();
            column.label = 'Linha';
            column.fieldName = 'lineNumber';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesConfirmWraper.Columns();
            column.label = 'Data de Lancamento';
            column.fieldName = 'dateShow';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesConfirmWraper.Columns();
            column.label = 'Saldo';
            column.fieldName = 'adjustment';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesConfirmWraper.Columns();
            column.label = 'Valor Original';
            column.fieldName = 'originalValue';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

            column = new FinancialMobileInvoicesConfirmWraper.Columns();
            column.label = 'Valor Corrigido';
            column.fieldName = 'correctedValue';
            column.type = 'text';
            column.hideDefaultActions = true;
            column.sortable = true;
            lstReturn.add(column);

        return lstReturn;
    }
}