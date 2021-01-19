({
    formatDoc: function(component, helper) {
        var docType = 'CPF';
        if (component.get('v.isCNPJ')) {
            docType = 'CNPJ'
        }

        var doc = component.get("v.inputValue");
        console.log("v.inputValue", +doc);
        var rep;
        var res;

        if (docType == 'CPF' && doc != '') {
        console.log("entrou");
            
            if (doc.includes(".")){
                var verify = component.get("v.inputValue");
                res = verify.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4");
                component.set("v.inputValue", doc);
                console.log("v.inputValueTest: ", +verify);
                console.log("entrou1");

            } else{
                console.log("entrou2");

                rep = doc.replace(/[^0-9]/g,'');   
                res = rep.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4");
                component.set("v.inputValue", res.substring(0,14));
            }
        }
        if (docType == 'CNPJ' && doc != '') {
            if (doc.includes("-")){
                var verify = component.get("v.inputValue");
                res = verify.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, "$1.$2.$3/$4-$5");
                component.set("v.inputValue", doc);
                console.log("v.inputValueTest: ", +verify);
                console.log("entrou1"); 

            } else{
                console.log("entrou2");

                rep = doc.replace(/[^0-9]/g,'');   
                res = rep.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, "$1.$2.$3/$4-$5");
                component.set("v.inputValue", res.substring(0,20));   
            }
        }
        if (docType == 'Passaporte' && doc != '') {
            component.set("v.inputValue", doc.substring(0, 20));
        }
        if (docType == 'RNE' && doc != '') {
            res = doc.replace(/(\w{7})(\w{1})/, "$1-$2");
            component.set("v.inputValue", res.substring(0, 9));
        }

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
    

    formatContrato: function(component,helper) {
        var contrato = component.get("v.inputValue");
        
        if(contrato){
            var rep = contrato.replace(/[^0-9]/g, '');
            component.set("v.inputValue", rep.substring(0,9));
        }
        
    },

    formatMSISDN: function(component, helper) {
        var msi = component.find("txtMSISDN").get("v.value");
        if(msi) {
            var rep = msi.replace(/[^0-9]/g, '');
            var res = rep.replace(/(\d{2})(\d{4})(\d{4})/, "($1) $2-$3");
            component.set("v.inputValue", res.substring(0,15));
            if(msi.length >= 11) {
                var res = rep.replace(/(\d{2})(\d{5})(\d{4})/, "($1) $2-$3");
                component.set("v.inputValue", res.substring(0,15));
            }
        }
    },

    formatNome: function(component, helper) {
        var nome = component.find("txtName").get("v.value");
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

    helperThatCallsHelper: function(component, event, helper)
    {
        var nomeCidade  = document.getElementById("txtNomeCidade").value;
              nomeCidade = nomeCidade.replace(new RegExp(/[àáâãäå]/g),"a");
              nomeCidade = nomeCidade.replace(new RegExp(/[ÀÁÂÃ]/g),"a");
              nomeCidade = nomeCidade.replace(new RegExp(/ç/g),"c");
              nomeCidade = nomeCidade.replace(new RegExp(/Ç/g),"c");
              nomeCidade = nomeCidade.replace(new RegExp(/[èéêë]/g),"e");
              nomeCidade = nomeCidade.replace(new RegExp(/[ÈÉÊË]/g),"e");
              nomeCidade = nomeCidade.replace(new RegExp(/[ìíîï]/g),"i");
              nomeCidade = nomeCidade.replace(new RegExp(/[ÌÍÎÏ]/g),"i");
              nomeCidade = nomeCidade.replace(new RegExp(/ñ/g),"n");                
              nomeCidade = nomeCidade.replace(new RegExp(/Ñ/g),"n");                
              nomeCidade = nomeCidade.replace(new RegExp(/[òóôõö]/g),"o");
              nomeCidade = nomeCidade.replace(new RegExp(/[ÒÓÔÕÖ]/g),"o");
              nomeCidade = nomeCidade.replace(new RegExp(/[ùúûü]/g),"u");
              nomeCidade = nomeCidade.replace(new RegExp(/[ÙÚÛÜ]/g),"u");
              nomeCidade = nomeCidade.replace(new RegExp(/[ýÿ]/g),"y");
              nomeCidade = nomeCidade.replace(new RegExp(/[Ý]/g),"y");
              nomeCidade = nomeCidade.toUpperCase();
        document.getElementById("txtNomeCidade").value = nomeCidade;
        component.set("v.nomeCidade", nomeCidade);
  
        console.log('nomeCidade: ' + nomeCidade);
  
        if (nomeCidade) {
          console.log('citycity: ' + nomeCidade);
          helper.helperCityByName(component, event, helper, nomeCidade);
  
        }
    },

    helperCityByName : function(component, event, helper, nomeCidade)
    {
        var action = component.get("c.getCityByName");
        action.setParams({
            name: nomeCidade
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            var result = response.getReturnValue();
            console.log(state);
            console.log(result);
            
            if(state === 'SUCCESS'){
                component.set('v.nomeCidade', result['MasterLabel']);
                component.set('v.UF', result['Estado__c']);
                component.set('v.codOperadoraValue', result['CodigoOperadora__c']); 
            }else{
                component.set('v.codOperadoraValue', null); 
                component.set('v.UF', null); 
                component.set("v.errorMessage", 'Cidade não localizada.');
                helper.displayError(component, helper);
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
        var cidade = component.get('v.nomeCidade');
        var uf = component.get("v.UF");
        
        var pageSize = component.get("v.pageSize");
        component.set("v.isProfileCanalCritico",false);
        
        console.log('helperAddresSearch cep: ' + cep + ' >>logradouro:' + logradouro + ' >>numero: ' + numero + ' >>cmplemento: ' + complemento + ' >>cidade:' + cidade + '>>uf: ' + uf);
        /*Variável de retorno da ação*/
        var action;
        if(cep  || logradouro || numero || complemento || cidade || uf){
            if(cep && numero){
                action = component.get("c.getByAddressCepAndNumber");
                action.setParams({"cep":cep,"numero":numero});   
            }
            //action = helper.validAddress(component,helper);
            action = component.get("c.getByAddress");
            action.setParams({"cep":cep,"logradouro":logradouro,"numero":numero,"complemento":complemento,"cidade":cidade,"uf":uf});
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
                    console.log('result get by address: ' + JSON.stringify(list));
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

    /*validAddress : function(component,helper){
        var action;
        var cep = component.find("txtCep").get("v.value");
        var logradouro = component.find("txtLogradouro").get("v.value");
        var numero = component.find("txtNumero").get("v.value");
        var complemento = component.find("txtComplemento").get("v.value");
        var cidade = component.get('v.nomeCidade');
        var uf = component.get('v.UF');
        
        var consultBy = '';
        if(cep  && !logradouro && !complemento && !numero && !cidade && !uf)
        { 
            consultBy = 'adressCEP';
            action = component.get("c.adressCEP");
            action.setParams({"cep":cep});
        }else if(logradouro && !cep && !numero && !complemento && !cidade && !uf)
        {   //Busca por Logradouro
            consultBy = 'adressLogradouro';
            action = component.get("c.adressLogradouro");
            action.setParams({"logradouro":logradouro});
        }else if(logradouro && cep && !numero && !complemento && !cidade && !uf){
            //Busca por CEP e Logradouro
            consultBy = 'adressCEPLogradouro';
            action = component.get("c.adressCEPLogradouro");
            action.setParams({"cep":cep,"logradouro":logradouro})
        }else if(logradouro && (numero || complemento) && !cidade && !uf)
        { //Busca por Logradouro + num + complemento 
            if(complemento && !numero)
            {   
                component.set("v.errorMessage",'O complemento precisa do Logradouro e do Número.');
                helper.displayError(component,helper);  
            }else{
                consultBy = 'adressLogNumComp';
                action = component.get("c.adressLogNumComp");
                action.setParams({"logradouro":logradouro,"numero":numero,"complemento":complemento});
            }
        }else if((cidade || uf) && logradouro ){ 
            //Busca por Log + Num + cidade + estado
            if ((cidade && !uf) || (uf && !cidade)){ 
                component.set("v.errorMessage",'Cidade e Estado devem ser preenchidos juntos !');
                helper.displayError(component,helper);      
            }else{ 
                consultBy = 'adressLogCityComp';
                action = component.get("c.adressLogCityComp");
                action.setParams({"logradouro":logradouro,"cidade":cidade,"uf":uf});
            }
        }else if(cidade || uf ){  
            if ((cidade  && !uf ) || (uf && !cidade)){ 
                component.set("v.errorMessage",'Cidade e Estado devem ser preenchidos juntos !');
                helper.displayError(component,helper);      
            }else{ 
                consultBy = 'adressCityUF';
                action = component.get("c.adressCityUF");
                action.setParams({"cidade":cidade,"uf":uf});
            }
        }else if (cep  && logradouro  && numero && cidade && uf){
            consultBy = 'adressComplete';
            action = component.get("c.adressComplete");
            action.setParams({"cep":cep,"logradouro":logradouro,"numero":numero,"cidade":cidade,"uf":uf});
        }else{
            component.set("v.errorMessage",'Por Favor, valide o preenchimento dos campos de endereço.');
            helper.displayError(component,helper);
        }
        console.log('aaction chamada: ' + consultBy);
        return action;
    }, */

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
    
    
    addCSS: function(component, helper) 
    {
        var searchBy = component.get('v.searchBy');
        console.log('searchBy: ' + searchBy); 

        var cmpDocument = component.find('Document');   
        var cmpContract = component.find('Contract'); 
        var cmpPhone = component.find('Phone');   
        var cmpAddress = component.find('Address'); 
        var cmpName = component.find('Name');   

        if(searchBy == "Document")
            $A.util.addClass(cmpDocument, 'aba-selecionada');
        else
            $A.util.removeClass(cmpDocument, 'aba-selecionada');

        if(searchBy == "Contract")
            $A.util.addClass(cmpContract, 'aba-selecionada');
        else
            $A.util.removeClass(cmpContract, 'aba-selecionada');

        if(searchBy == "Phone")
            $A.util.addClass(cmpPhone, 'aba-selecionada');
        else
            $A.util.removeClass(cmpPhone, 'aba-selecionada');

        if(searchBy == "Address")
            $A.util.addClass(cmpAddress, 'aba-selecionada');
        else
            $A.util.removeClass(cmpAddress, 'aba-selecionada');

        if(searchBy == "Name")
            $A.util.addClass(cmpName, 'aba-selecionada');
        else
            $A.util.removeClass(cmpName, 'aba-selecionada');
         
    }
 })