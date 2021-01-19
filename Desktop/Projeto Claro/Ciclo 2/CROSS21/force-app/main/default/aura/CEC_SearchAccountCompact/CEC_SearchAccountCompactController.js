({
    doInit : function(component, event, helper) {
        component.set("v.tipo",'CPF');
        var action = component.get("c.getDocumentType");
        var inputsel = component.find("cmbDoc");
        var opts=[];
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            inputsel.set("v.options", opts);
        });
        $A.enqueueAction(action); 
    },
    
    handleClick: function(component, event, helper) {
        var doc 		= component.find("txtDoc").get("v.value");
        var cmbBox 		= component.find("cmbDoc").get("v.value");
        var contrato 	= component.find("txtContrato").get("v.value");
        var msisdn 		= component.find("txtMSISDN").get("v.value");
        var navService;
        var pageReference;
        
        
        if (doc && cmbBox) {
            navService = component.find("navService");
            pageReference = {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__CEC_SearchAccountComponent"
                }, 
                "state": {
                    'c__doc': component.find("txtDoc").get("v.value"),
                    'c__tipo': component.find("cmbDoc").get("v.value"),
                    
                }
            };
            navService.navigate(pageReference);
            
        }else if(contrato) {  
           navService = component.find("navService");
            pageReference = {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__CEC_SearchAccountComponent"
                }, 
                "state": {
                    'c__doc': contrato,
                    'c__isContract': true
                }
            };
            navService.navigate(pageReference);
            
        }else if(msisdn) {
            navService = component.find("navService");
            pageReference = {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__CEC_SearchAccountComponent"
                }, 
                "state": {
                    'c__doc': component.find('txtMSISDN').get('v.value'),
                    'c__isMsisdn':true
                }
            };
            navService.navigate(pageReference); 
            
        }else if(cmbBox) {
            navService = component.find("navService");
            pageReference = {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__CEC_SearchAccountComponent"
                }, 
                "state": {
                    'c__tipo': component.find("cmbDoc").get("v.value"),
                    'c__isDoc':true
                }
            };
            navService.navigate(pageReference); 
            
        } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Revise os erros nesta página.",
                    "message": "Por favor, selecione alguma opção de busca!",
                    "type": "error"
                });
                toastEvent.fire();
                return;
            }
    },
    
    //Método para checar selecionado e limitar tamanho
    keyHandler: function(component, event, helper) {  
        var doc = component.find("txtDoc").get("v.value");
        var docType = component.find("cmbDoc").get("v.value");
        var sel = window.getSelection().toString();
        
        if(doc != null){
            var tam = doc.length;
            if(docType == 'CPF'){
                if(tam > 13 && sel == '')
                    event.preventDefault();
            }
            if(docType == 'CNPJ'){
                if(tam > 17 && sel =='')
                    event.preventDefault();
            }
            if(docType == 'Passaporte'){
                if(tam > 8 && sel =='')
                    event.preventDefault();
            }
        }   
    },
    
    keyHandlerMSI: function(component, event, helper) {  
        var msi = component.find("txtMSISDN").get("v.value");
        var sel = window.getSelection().toString();
        
        if(msi != null){
            var tam = msi.length;
            if(tam > 10 && sel == '')
                event.preventDefault();
        }   
    },
    
    keyHandlerContrato: function(component, event, helper) {  
        var msi = component.find("txtContrato").get("v.value");
        var sel = window.getSelection().toString();
        
        if(msi != null){
            var tam = msi.length;
            if(tam > 8 && sel == '')
                event.preventDefault();
        }   
    },
    
    //Método utilizado para eventos de tecla
    keyCheck: function(component, event, helper) {
        //Realiza busca se for tecla Enter
        if (event.which == 13 || event.keyCode == 13){
            var a = component.get('c.handleClick');
            $A.enqueueAction(a);
        }
        
    },
    
    formatMaskMSI: function(component, event, helper) {
        //Limpa caracteres do clipboard
        var msi = component.find("txtMSISDN").get("v.value");
        var res = msi.replace(/[^0-9]/g, '');
        component.set("v.msi", res);
        
        //Limita clipboard por tipo de documento
        if(msi){
            var tam = msi.length;
            var rep = res.replace(/[-/.]/g, '');
            if(tam > 9){
                component.set("v.msi", rep.substring(0, 11));
            }
        }
    },
    
    formatMaskContrato: function(component, event, helper) {
        //Limpa caracteres do clipboard
        var msi = component.find("txtContrato").get("v.value");
        var res = msi.replace(/[^0-9]/g, '');
        component.set("v.contrato", res);
        
        //Limita clipboard por tipo de documento
        if(msi){
            var tam = msi.length;
            var rep = res.replace(/[-/.]/g, '');
            if(tam > 8){
                component.set("v.contrato", rep.substring(0, 8));
            }
        }
    },
    
    //Método que limpa caracteres do clipboard e formata
    formatMask: function(component, event, helper) {
        //Limpa caracteres do clipboard
        var doc = component.find("txtDoc").get("v.value");
        var docType = component.find("cmbDoc").get("v.value");
        var res;
        var rep;
        
        if(docType != 'RNE'){
            res = doc.replace(/[^-0-9./]/g, '');
            rep = res.replace(/[-/.]/g, '');
            component.set("v.doc", res);   
        }
        
        //Limita clipboard por tipo de documento
        if(doc){
            var tam = doc.length;
            
            if(docType == 'CPF' && tam > 13){
                res = rep.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4");
                component.set("v.doc", res.substring(0, 14));
            }
            if(docType == 'CPF'){
                helper.formatCPF(component,helper);
            }
            if(docType == 'CNPJ' && tam > 17){
                res = rep.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, "$1.$2.$3/$4-$5");
                component.set("v.doc", res.substring(0, 18));
            }
            if(docType == 'CNPJ'){
                helper.formatCNPJ(component,helper);
            }
            if(docType == 'Passaporte'){
                component.set("v.doc", rep.substring(0, 9));
            }
            if(docType == 'RNE' && tam > 9){
                res = doc.replace(/(\w{7})(\w{1})/, "$1-$2");
                component.set("v.doc",res.substring(0,9));
            }
            if(docType == 'RNE'){
                helper.formatRNE(component,helper);
            }
        }
    },
    
    clearDocument : function(component,event,helper) {
        component.set("v.doc",'');
    }
})