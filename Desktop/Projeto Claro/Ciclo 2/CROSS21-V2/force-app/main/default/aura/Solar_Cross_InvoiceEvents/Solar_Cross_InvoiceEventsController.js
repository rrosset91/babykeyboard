({
    doInit : function(component, event, helper) {
        var mock = {
            "apiVersion": "1;2019-11-21",
            "transactionId": "Id-8bbad85f6586a34f3ec4d0ee",
            "data": {"events":[{"invoiceID":170461766,"invoiceStatusID":2,"invoiceStatusDescription":"Pago","criticalReasonID":null,"criticalReasonDescription":null,"eventDate":"2019-11-07T00:00:00Z","eventDescription":"Evento de fatura disponivel para pagamento"},{"invoiceID":170461766,"invoiceStatusID":2,"invoiceStatusDescription":"Pago","criticalReasonID":null,"criticalReasonDescription":null,"eventDate":"2019-11-07T00:00:00Z","eventDescription":"Evento de envio de pagamento ao banco"},{"invoiceID":170461766,"invoiceStatusID":2,"invoiceStatusDescription":"Pago","criticalReasonID":null,"criticalReasonDescription":null,"eventDate":"2019-11-25T00:00:00Z","eventDescription":"Evento de pagamento de fatura"},{"invoiceID":170461766,"invoiceStatusID":2,"invoiceStatusDescription":"Pago","criticalReasonID":241,"criticalReasonDescription":"BAIXA DE DEBITO AUTOMATICO - DEBITO EFETUADO","eventDate":"2019-11-26T04:35:48Z","eventDescription":"Evento de retorno bancario"},{"invoiceID":172244786,"invoiceStatusID":1,"invoiceStatusDescription":"Em Aberto","criticalReasonID":null,"criticalReasonDescription":null,"eventDate":"2019-12-06T00:00:00Z","eventDescription":"Evento de fatura disponivel para pagamento"},{"invoiceID":172244786,"invoiceStatusID":1,"invoiceStatusDescription":"Em Aberto","criticalReasonID":null,"criticalReasonDescription":null,"eventDate":"2019-12-06T00:00:00Z","eventDescription":"Evento de envio de pagamento ao banco"}]}
        }
        component.set("v.data",mock);
        console.log(JSON.stringify( component.get("v.data")));
    }
})