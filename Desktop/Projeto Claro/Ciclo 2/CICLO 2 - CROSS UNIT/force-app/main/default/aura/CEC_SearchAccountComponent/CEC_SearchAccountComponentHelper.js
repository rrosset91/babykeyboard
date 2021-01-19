({ //Function que valida campos de endereço, antes de chamar a busca. 
    validAddress : function(component,helper){
        var action;
        var cep = component.find("txtCep").get("v.value");
        var logradouro = component.find("txtLogradouro").get("v.value");
        var numero = component.find("txtNumero").get("v.value");
        var complemento = component.find("txtComplemento").get("v.value");
        var cidade = component.find("txtCidade").get("v.value");
        var uf = component.find("txtUF").get("v.value");
        
        
        if(cep  && !logradouro && !complemento && !numero && !cidade && !uf)
        { 
            action = component.get("c.adressCEP");
            action.setParams({"cep":cep});
        }else if(logradouro && !cep && !numero && !complemento && !cidade && !uf)
        {   //Busca por Logradouro
            action = component.get("c.adressLogradouro");
            action.setParams({"logradouro":logradouro});
        }else if(logradouro && cep && !numero && !complemento && !cidade && !uf){
            //Busca por CEP e Logradouro
            action = component.get("c.adressCEPLogradouro");
            action.setParams({"cep":cep,"logradouro":logradouro})
        }else if(logradouro && (numero || complemento) && !cidade && !uf)
        { //Busca por Logradouro + num + complemento 
            if(complemento && !numero)
            {   component.set("v.errorMessage",'O complemento precisa do Logradouro e do Número.');
             helper.displayError(component,helper);  
            }else{
                action = component.get("c.adressLogNumComp");
                action.setParams({"logradouro":logradouro,"numero":numero,"complemento":complemento});
            }
        }else if((cidade || uf) && logradouro ){ 
            //Busca por Log + Num + cidade + estado
            if ((cidade && !uf) || (uf && !cidade)){ 
                component.set("v.errorMessage",'Cidade e Estado devem ser preenchidos juntos !');
                helper.displayError(component,helper);      
            }else{ 
                action = component.get("c.adressLogCityComp");
                action.setParams({"logradouro":logradouro,"cidade":cidade,"uf":uf});
            }
        }else if(cidade || uf ){  
            if ((cidade  && !uf ) || (uf && !cidade)){ 
                component.set("v.errorMessage",'Cidade e Estado devem ser preenchidos juntos !');
                helper.displayError(component,helper);      
            }else{ 
                action = component.get("c.adressCityUF");
                action.setParams({"cidade":cidade,"uf":uf});
            }
        }else if (cep  && logradouro  && numero && cidade && uf){
            action = component.get("c.adressComplete");
            action.setParams({"cep":cep,"logradouro":logradouro,"numero":numero,"cidade":cidade,"uf":uf});
        }else{
            component.set("v.errorMessage",'Por Favor, valide o preenchimento dos campos de endereço.');
            helper.displayError(component,helper);
        }
        
        return action;
    },   
    
    displayError: function(component,helper)
    { 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Alerta', 
            type: 'error', 
            duration:'4000',
            message:component.get("v.errorMessage"),
        });
        toastEvent.fire();  
    },
    
    getName : function(component,helper){
        var nome = component.find("txtNome").get("v.value");
        var sobrenome = component.find("txtSobrenome").get("v.value");
        var action;
        
        if(((nome =='') && (sobrenome != '')) || (nome != '') && (sobrenome == '')){
            component.set("v.errorMessage",'Preencha os campos Nome e Sobrenome.');
            helper.displayError(component,helper);
        }else{
            action = component.get("c.getAccountName");
            action.setParams({"nome":nome,"sobrenome":sobrenome});
        }
        return action;
    }, 
    
    formatDoc : function (component,helper) {
        
        var docType = component.find("cmbDoc").get("v.value");
        var doc = component.find("txtDoc").get("v.value");
        var rep;
        var res; 
        
        if(docType == 'CPF' && doc != ''){
            rep = doc.replace(/[^0-9]/g,'');   
            res = rep.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4");
            component.set("v.doc", res.substring(0,14));          
        }
        if(docType == 'CNPJ' && doc!= ''){
            rep = doc.replace(/[^0-9]/g,'');  
            res = rep.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, "$1.$2.$3/$4-$5");
            component.set("v.doc",res.substring(0, 18));
        }
        if(docType == 'Passaporte' && doc!=''){
            component.set("v.doc",doc.substring(0,20));
        } 
        if(docType == 'RNE' && doc!=''){
            res = doc.replace(/(\w{7})(\w{1})/, "$1-$2");
            component.set("v.doc",res.substring(0,9));
        }
        
    },
    
    formatMSISDN: function(component, helper) {
        var msi = component.find("txtDoc").get("v.value");
        if(msi) {
            var rep = msi.replace(/[^0-9]/g, '');
            var res = rep.replace(/(\d{2})(\d{4})(\d{4})/, "($1) $2-$3");
            component.set("v.doc", res.substring(0,15));
            if(msi.length >= 15) {
                var res = rep.replace(/(\d{2})(\d{5})(\d{4})/, "($1) $2-$3");
                component.set("v.doc", res.substring(0,15));
            }
        }
    },
    
    formatContrato: function(component,helper) {
        var doc = component.get("v.doc");
        var doc2 = component.get("v.doc2");
        
        if(doc){
            var contrato = component.get("v.doc");;
            var rep = contrato.replace(/[^0-9]/g, '');
            component.set("v.doc", rep.substring(0,9));
        }
        if(doc2){
            var contrato = component.get("v.doc2");
            var rep = contrato.replace(/[^0-9]/g, '');
            component.set("v.doc2", rep.substring(0,9));
        }
        
    },
    
    formatNome: function(component, helper) {
        var nome = component.find("txtDoc").get("v.value");
        var res = nome.replace(/[^a-zA-Z ]/g, '');
        component.set("v.doc", res);
        
        if(nome != null){
            var tam = nome.length;
            var rep = res.replace(/[^a-zA-Z ]/g, '');
            if(tam > 50){
                component.set("v.doc", rep.substring(0, 50));
            }
        }
    },
    
    handleTipoInit : function(component,event,helper){
        
        var doc = component.find("radioDoc").getElement().checked;
        var nom = component.find("radioName").getElement().checked;
        var msi = component.find("radioMsisdn").getElement().checked;
        var con = component.find("radioContrato").getElement().checked;
        
        component.set("v.isMovel", true);
        component.set("v.isResidencial", false);
        
        if(doc) {
            component.set("v.label", 'Documento');
            component.set("v.documentType", false);
            component.set("v.doc", null);
            component.set("v.tipoContrato", false);
        }
        
        if(con) {
            component.set("v.label", 'BAN');
            component.set("v.documentType", true);
            component.set("v.doc", null);
            component.set("v.tipoContrato", true);
        }
        
        if(nom || msi) {
            if(nom) component.set("v.label", 'Nome');
            
            if(msi) component.set("v.label", 'Linha');
            
            component.set("v.documentType", true);
            component.set("v.doc", null);
            component.set("v.tipoContrato", false);
        }
    },
    
    nextHandler : function(component,event, handler){
        component.set("v.offset",offset+100);
    },
    
     getCriticalChannels : function(component, event, helper)
    {    
        let action = component.get("c.getProfileCanaisCriticos");

        action.setCallback(this, function(response)
        {
            let state = response.getState();

            if(state === "SUCCESS")
            {
                component.set("v.isProfileCanalCritico", response.getReturnValue());
            }
            else if(state === "ERROR" || state === "INCOMPLETE" )
            {
                let errors = response.getError();

                if(errors[0] && errors[0].message)
                {
                    this.methodModal(errors[0].message, 'info', '');
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    helperAddresSearch : function(component,event,helper){
        /* Variaveis pela busca por endereço */ 
        var cep = component.find("txtCep").get("v.value");
        var logradouro = component.find("txtLogradouro").get("v.value");
        var numero = component.find("txtNumero").get("v.value");
        var complemento = component.find("txtComplemento").get("v.value");
        var cidade = component.find("txtCidade").get("v.value");
        var uf = component.find("txtUF").get("v.value");
        var pageSize = component.get("v.pageSize");
        component.set("v.isProfileCanalCritico",false);
        
        /*Variável de retorno da ação*/
        var action;
        if(cep  || logradouro || numero || complemento || cidade || uf){
            action = helper.validAddress(component,helper);
        }else{
            component.set("v.errorMessage",'Não é possivel pesquisar sem as informações requeridas.');
            helper.displayError(component,helper);
        }
        
        if(action != null){ 
            component.set("v.spinner",true);
            action.setCallback(this,function(response){
                var state = response.getState();
                
                if(state=="SUCCESS"){
                    component.set("v.spinner",false);
                    var list =response.getReturnValue();    
                    component.set("v.acctList",list);
                    
                    if(list.length == 0){
                        component.set("v.errorMessage",'Endereço não encontrado.');
                        var actionProfile = component.get("c.getProfileCanaisCriticos"); 		
                        actionProfile.setCallback(this, function(response){ 		
                            component.set("v.isProfileCanalCritico", response.getReturnValue()); 		
                        }); 		
                        $A.enqueueAction(actionProfile); 
                        helper.displayError(component,helper);
                    }else{
                        component.set("v.totalSize",component.get("v.acctList").length - 1);
                        component.set("v.start", 0);
                        component.set("v.end", pageSize - 1);
                        if (component.get("v.acctList").length < 5) {
                            pageSize = component.get("v.acctList").length;
                        }
                        
                        var paginationList = [];
                        for (var i = 0; i < pageSize; i++) {
                            if(list[i] != null){
                                paginationList.push(list[i]);
                            }
                        }
                        component.set('v.paginationList', paginationList);
                        console.dir(paginationList);
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Sucesso", 
                            "type": "success", 
                            "message":'A busca encontrou resultados.',
                        });
                        toastEvent.fire();  
                    }
                }else if(state=="ERROR"){
                    component.set("v.spinner",false);
                    component.set("v.acctList",null);
                    var errors = response.getError();
                    component.set("v.errorMessage",errors[0].message)
                    helper.displayError(component,helper);
                }});
            $A.enqueueAction(action);
            
        }
    },
    
    showListContracts : function(component,event,helper){
        var action = component.get("c.getContractList");
        action.setParams({ accountId : event.target.getAttribute('data-id')});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent;
            component.set("v.showSpinner",false);
            if(state == 'SUCCESS'){
                var list = response.getReturnValue();
                if(list != null && list.length != 0){
                    component.set("v.hasContract",true);
                    component.set("v.showModalContractList",true);
                    component.set("v.contractList",list);
                    
                  }else{
                    component.set("v.hasContract",false);
                }
            }
            if(state == 'ERROR'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Erro!", 
                    "type": "Error", 
                    "message":'Não existem contratos para essa conta.'
                });
                toastEvent.fire();                
            }
            
        });  
        $A.enqueueAction(action);
    },

    sortBy: function(component, helper, field) {
        var sortAsc = component.get("v.sortAsc");
        var records = component.get("v.acctList");
        component.set("v.sortAsc", !sortAsc);
        if(records == null || records == undefined || records.length == 0){
            return; 
        }
        
        records.sort(function(a, b) {
            if(sortAsc){
                if (a[field] > b[field]) {
                    return 1;
                }
                if (a[field] < b[field]) {
                    return -1;
                }
            }else{
                if (a[field] > b[field]) {
                    return -1;
                }
                if (a[field] < b[field]) {
                    return 1;
                }
            }
            return 0;
        });
        
        
        component.set("v.sortField", field);
        component.set("v.acctList", records);
        
        helper.paginate(component, records);
    },

    paginate : function(component, records) {
        
        var dataList = records;
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        
        var paginationList = [];
        
        for (var i = start; i <= end; i++) {
            if(i >= dataList.length)
                break;
            if (i >= start && i <= end) {
                if (dataList[i] != null) paginationList.push(dataList[i]);
            }
        }
        
        component.set('v.paginationList', paginationList);
    }
})