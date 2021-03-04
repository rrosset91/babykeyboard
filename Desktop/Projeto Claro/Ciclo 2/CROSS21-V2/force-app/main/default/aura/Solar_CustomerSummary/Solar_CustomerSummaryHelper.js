({
    loadData : function(component) {
        component.set('v.isLoading', true);
        let recordId = component.get('v.recordId');
        let sObjectName = component.get('v.sObjectName');
        let action = component.get('c.loadData');
        action.setParams({recordId : recordId, sObjectName: sObjectName});
        action.setCallback(this, function(response) {
            let state = response.getState();
            let data = response.getReturnValue();
            if (state === "SUCCESS") {
				component.set('v.customerInfo', this.setCustomerInfo(component, data.customerData)); 
                component.set('v.customerURL', data.customerUrl);
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },
    //colocar Custom Labels AQUI
    setComponentLabels : function(){
        let componentLabels = {};
        componentLabels.formattedUrl = 'Mais Informações na Aba de Cliente';
        componentLabels.loadingText = 'Carregando...';
        componentLabels.mobilePhone = 'Celular: ';
        componentLabels.phone = 'Telefone: ';
        componentLabels.email = 'E-mail: ';
        componentLabels.segment = 'Segmento: ';
        return componentLabels;
    },
    
    setCustomerInfo : function(component, customerData) {
        let customerInfo = {};
        customerInfo.name = customerData.Name;
        customerInfo.documentId = this.setMaskedDocument(component, customerData.FormattedDocument__c);
        customerInfo.mobilePhone = (customerData.CellPhone__c) ? this.setMaskedPhone(customerData.CellPhone__c) : '';
        customerInfo.phone = (customerData.Phone) ? this.setMaskedPhone(customerData.Phone) : '';
        customerInfo.email = (customerData.vlocity_cmt__BillingEmailAddress__c) ? customerData.vlocity_cmt__BillingEmailAddress__c : '';
        customerInfo.segment = (customerData.vlocity_cmt__CustomerValue__c) ? customerData.vlocity_cmt__CustomerValue__c: '';
        customerInfo.id = customerData.Id;
        return customerInfo;
    },
    
    setMaskedDocument: function(component, documentId) {
        if(documentId){
            if(documentId.length === 14){
                documentId = '***.***.***-' + documentId.substring(12,14); //CPF
                component.set('v.documentIdLabel', 'CPF: '); //Colocar Custom Label
            }else{
                documentId = '**.***.***/' + documentId.substring(11,18); //CPNJ
                component.set('v.documentIdLabel', 'CNPJ: '); //Colocar Custom Label
            }
            return documentId;
        }else{
            return '';
        }
    },
    
    setMaskedPhone: function(phoneNumber) {
        let formattedPhoneNumber = '';
        let ddd = '';
        let numbers = '';
        let numbersFsrtPart = '';
        let numbersSecPart = '';
        if(phoneNumber){
            ddd = phoneNumber.substring(0,2);
            numbers = phoneNumber.substring(2);
            if(numbers.length === 9){
                numbersFsrtPart = numbers.substring(0, 5);
                numbersSecPart = numbers.substring(5, 9); 
            }else if(numbers.length === 8){
				numbersFsrtPart = numbers.substring(0, 4);
                numbersSecPart = numbers.substring(5, 8);				               
            }
            formattedPhoneNumber = '(' + ddd + ')' + numbersFsrtPart + '-' + numbersSecPart;
            return formattedPhoneNumber;
        }else{
            return '';
        }
    }
})