/* Autor: Letícia Freitas - Deloitte 
Criação: 23/04/2019
Descrição: Classe de conexão com a API de Invoice.
Nome do projeto/ID: CEC FASE - Time: SQUAD 360.
*  Controle de Versão
* ---------------------------------------------------------------
*  Data: 24-04-2019
*  Autor: Danilo Fucuhara.
*  Alterações: Classe refatorada para aceitar a classe CEC_RestObjects(InvoiceRest_object deletada).
*/
public class CEC_360_IntegrationInvoices {
    
    public static List<CEC_RestObjects.Invoice> getInvoiceResidencial(String companyId, String contractId, String operatorId, String startDate, String endDate) {
        CEC_RestObjects.InvoiceMain invoicesEntity = new CEC_RestObjects.InvoiceMain();
        List<CEC_RestObjects.Invoice> invoicesList;
        String serviceName;
        
        if(!Test.isRunningTest()){
            serviceName = CEC_360_ServiceName.getServiceName('Invoices');
        }else{
            serviceName = '/invoices';
        }
               
        try{
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro' + serviceName + 
                                '?companyId=' + companyId +
                				'&contractId=' + contractId + 
                                '&operatorId=' + operatorId + 
                                '&channelAttendanceId=' + '3' +
                				'&startDate=' + startDate + '-00:00' + 
                                '&endDate=' + endDate + '-00:00');
            system.debug('Endpoint'+request.getEndpoint());
            request.setMethod('GET');
            request.setTimeout(120000);
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('Response Body: ' + responseBody);
            
            invoicesEntity = (CEC_RestObjects.InvoiceMain)System.JSON.deserialize(responseBody, CEC_RestObjects.InvoiceMain.class);
            invoicesList = invoicesEntity.data.invoices;
            
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
        } catch(CalloutException e) {
            System.debug('Unknown Error: ' + e);
        }

        if(invoicesList != null) {
            for (Integer i = 0; i < invoicesList.size(); i++) {
                invoicesList[i].dueDate_aux = 	invoicesList[i].dueDate.subString(8,10) + '/' + 
                    							invoicesList[i].dueDate.subString(5,7) + '/'+ 
                    							invoicesList[i].dueDate.subString(0,4);
                String amount_aux = String.valueof(invoicesList[i].invoiceAmount);
                invoicesList[i].invoiceAmount_aux ='R$ ' + amount_aux.replace('.',',');
            }
        }
        
        return invoicesList;
    }
    
    public static List <CEC_RestObjects.Invoice> getInvoiceMovel(String companyId, String billingAccount, String startDate, String endDate) {
        CEC_RestObjects.InvoiceMain invoicesEntity = new CEC_RestObjects.InvoiceMain();
        List<CEC_RestObjects.Invoice> invoicesList;
        string serviceName;
        
           if(!Test.isRunningTest()){
            serviceName = CEC_360_ServiceName.getServiceName('Invoices');
        }else{
            serviceName = '/invoices';
        }

        try{
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro' + serviceName + 
                                '?companyId=' + companyId + 
                                '&billingAccountId=' + billingAccount + 
                                '&startDate=' + startDate + '-00:00' + 
                                '&endDate=' + endDate + '-00:00');
            
            request.setMethod('GET');
            request.setTimeout(120000);
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('Response Body: ' + responseBody);
            
            invoicesEntity = (CEC_RestObjects.InvoiceMain)System.JSON.deserialize(responseBody, CEC_RestObjects.InvoiceMain.class);
            invoicesList = invoicesEntity.data.invoices;
            
            if(response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
        } catch(CalloutException e) {
            System.debug('Unknown Error: ' + e);
        }
        
        if(invoicesList != null) {
            for (Integer i = 0; i < invoicesList.size(); i++) {
                invoicesList[i].dueDate_aux = 	invoicesList[i].dueDate.subString(8,10) + '/' + 
                    							invoicesList[i].dueDate.subString(5,7) + '/' + 
                    						  	invoicesList[i].dueDate.subString(0,4);
                String amount_aux = String.valueof(invoicesList[i].amountPrincipal);
                invoicesList[i].invoiceAmount_aux ='R$ ' + amount_aux.replace('.',',');
                invoicesList[i].statusInvoiceDescription = formatStatus(invoicesList[i].dueDate, invoicesList[i].indicatorInvoiceNotPaid,
                                                                        invoicesList[i].amountPrincipalPaymentMade, invoicesList[i].invoiceAmount);
            }
        }
        
        return invoicesList;
    }
    
    public static String getInvoicesURL(String companyId, String billingAccountId, String dueDate) {
        CEC_RestObjects.InvoiceMain invoicesEntity = new CEC_RestObjects.InvoiceMain();
        String invoiceUrl;
        String serviceName;
        
          if(!Test.isRunningTest()){
            serviceName = CEC_360_ServiceName.getServiceName('InvoicesPDF');
        }else{
            serviceName = '/invoicesPDF';
        }

        try{
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGClaro' + serviceName + 
                                '?companyId=' + companyId + 
                                '&billingAccountId=' + billingAccountId + 
                                '&dueDate=' + dueDate);
            
            request.setMethod('GET');
            request.setTimeout(120000);
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('Response Body: ' + responseBody);
            
            invoicesEntity = (CEC_RestObjects.InvoiceMain)System.JSON.deserialize(responseBody, CEC_RestObjects.InvoiceMain.class);
            invoiceUrl = invoicesEntity.data.invoicePDF.invoiceURL;
        } catch(CalloutException e) {
            System.debug('Unknown Error: ' + e);
        }
        
        return invoiceUrl;
    }
    
     public static String getInvoicesURLRes(String companyId, String invoiceId, String customerAccountId) {
        CEC_RestObjects.InvoiceMain invoicesEntity = new CEC_RestObjects.InvoiceMain();
        String invoiceUrl;
        String serviceName;
        
          if(!Test.isRunningTest()){
            serviceName = CEC_360_ServiceName.getServiceName('InvoicesPDF');
        }else{
            serviceName = '/invoicesPDF';
        }

        try{
            HTTPRequest request = new HTTPRequest();
            request.setEndpoint('callout:OAGNetCorp' + serviceName + 
                                '?companyId=' + companyId + 
                                '&externalId=000000' + invoiceId + 
                                '&customerAccountId=' + customerAccountId);
            
            request.setMethod('GET');
            request.setTimeout(120000);
            HTTP http = new HTTP();
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            System.debug('Response Body: ' + responseBody);
            String jsonReplacedString = responseBody.replace('retrieve', 'retrieveZ');
            System.debug('Response Body2: ' + jsonReplacedString);
            invoicesEntity = (CEC_RestObjects.InvoiceMain)System.JSON.deserialize(jsonReplacedString, CEC_RestObjects.InvoiceMain.class);
            invoiceUrl = invoicesEntity.data.retrieveZ.content;
        } catch(CalloutException e) {
            System.debug('Unknown Error: ' + e);
        }
        
        return invoiceUrl;
    }
    
    
    
    public static String formatStatus(String dueDate, String notPaid, Decimal amountPaid, Decimal invoiceAmount) {
        Date date1 = Date.newInstance(Integer.valueOf(dueDate.subString(0,4)), 
                                      Integer.valueOf(dueDate.subString(5,7)), 
                                      Integer.valueOf(dueDate.subString(8,10)));
      
        Date today = Date.today();
        String status;
    
        if((date1 >= today) && (notPaid == 'true')) {
            status = 'A pagar';
        } else {
            if(invoiceAmount <= amountPaid) {
                status = 'Paga';
            } else {
                status = 'Em atraso';
            }
        }
        
        return status;
    } 
    
    public static CEC_RestObjects.InvoiceMain generateMock() {
        CEC_RestObjects.InvoiceMain restObject = new CEC_RestObjects.InvoiceMain(); 
        List<CEC_RestObjects.Invoice> lstInvoice = new List<CEC_RestObjects.Invoice>();
        CEC_RestObjects.Invoice invoice = new CEC_RestObjects.Invoice();
        invoice.invoiceId = '2';
        invoice.statusInvoiceId = 'Total Contas Dedicadas';
        invoice.statusInvoiceDescription = 'Bônus para Ligações Locais';
        invoice.dueDate = '2017-02-20';
        invoice.invoiceAmount = 5.5;
        invoice.paymentForm = 'teste';
        invoice.dueDate_aux = '2017-02-20';
        invoice.amountPrincipal = 10;
        invoice.invoiceAmount_aux = '20';
        lstInvoice.add(invoice);
        restObject.data = new CEC_RestObjects.DataInvoice();
        restObject.data.invoices = new List<CEC_RestObjects.Invoice>();
        restObject.data.invoices.add(invoice);
        restObject.data.invoicePDF = new CEC_RestObjects.InvoicePDF();
        restObject.data.invoicePDF.invoiceURL = 'https://tester@teste.com';
        restObject.data.retrieveZ = new CEC_RestObjects.invoiceRetrive();
        restObject.data.retrieveZ.content = '123456789010 - Arquivo modelo';
        
        return restObject;
    } 
}