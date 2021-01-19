({
    //carrega as informações vindas do server
    carregar: function(component) {
        //inicia o spinner
        component.set('v.isLoading', true);
        //pegar o parâmetro da URL
        let urlString = window.location.href;
        let url = new URL(urlString);
        let param = url.searchParams.get('id');
        component.set("v.idPedido", param);

        //server side action
        var action = component.get("c.carregarDados");
        action.setParams({
            idPedido : param
        });
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstData", response.getReturnValue());
                console.log('data: ' + JSON.stringify(response.getReturnValue()));
            }
            component.set('v.isLoading', false);
        }));
        $A.enqueueAction(action);
    },
    //habilita e esconde a sessão selecionada
    sectionDisplay: function(el, parent) {
        try{
            console.log('display: ' + el.style.display);
            if(parent){
                if($A.util.isEmpty(el.style.display)){
                    el.style.display = 'none';
                }else if(el.style.display === 'none') {
                    el.style.display = 'block';
                }else{
                    el.style.display = 'none';
                }
            }else{
                if($A.util.isEmpty(el.style.display)){
                    el.style.display = 'block';
                }else if(el.style.display === 'none') {
                    el.style.display = 'block';
                }else{
                    el.style.display = 'none';
                }
            } 
        }catch(err){
            console.log(err);
        }
    },
    //muda a seta para baixo ou para cima e altera a cor do mesmo
    toggleArrow: function(el) {
        try{
            el.classList.toggle('active');
            el.classList.toggle('arrow-child-color');
        }catch(err){
            console.log(err);
        }
    },
    //altera a cor da linha selecionada(cinza/marinho ou vice e versa)
    colorRow: function(el) {
        try{
            el.classList.toggle('child-navy-row');
            el.classList.toggle('child-gray-row');
        }catch(err){
            console.log(err);
        }
    },
    //altera a cor do text 'associação pendente'
    colorText: function(el) {
        try{
            el.classList.toggle('white-text');
        }catch(err){
            console.log(err);
        }
    },
    //altera a cor do text 'associação pendente'
    assocColorText: function(el, className) {
        try{
            if(className == 'red-text'){
                if(el.classList.contains('lightblue-text')){
                     el.classList.toggle('lightblue-text');
                }
                if(!el.classList.contains('red-text')){
                    el.classList.toggle('red-text');
                }
            }else if(className == 'lightblue-text'){
                if(el.classList.contains('red-text')){
                    el.classList.toggle('red-text');
                }
                if(!el.classList.contains('lightblue-text')){
                    el.classList.toggle('lightblue-text');
                }
            }else{
                el.classList.toggle(className);
            }
        }catch(err){
            console.log(err);
        }
    },
    
    //altera o texto 'associação pendente'
    assocText: function(el, strAssoc) {
        try{
            el.innerHTML = strAssoc;
        }catch(err){
            console.log(err);
        }
    },
    
    gravarPedido : function(cmp, helper) {
        if(cmp.get("v.ld21Seleted") == "") {
            cmp.set("v.showModalError", true);
            cmp.set("v.msgModalError", "A seleção do LD 21 é obrigatória");
        } else {
            
            var action = cmp.get("c.saveOrder");
            var data = cmp.get("v.lstData");
          
            action.setParams({
                'strData' : JSON.stringify(data)
            });
            action.setCallback(this, $A.getCallback(function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var retorno = response.getReturnValue();
                    cmp.set("v.showModalError", retorno.contemErro);
                    cmp.set("v.msgModalError", retorno.msgErro);
                    if(cmp.get("v.showModalError") == false){
                        this.redirectToOrder(cmp, event, helper);
                        this.fireCloseTabEvent(cmp, event);
                    }
                }
                else if(state === 'ERROR'){
                    var errors = response.getError();
                    if(errors[0] && errors[0].message){
                        console.log(errors[0].message);
                    }
                }
            }));
            $A.enqueueAction(action);
        }
    },
    
	gravarResumo : function(cmp, event, helper) {      
        var action = cmp.get("c.saveResumo");
        var data = cmp.get("v.lstData");
        
        action.setParams({
            'strData' : JSON.stringify(data)
        });
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
         
            if (state === "SUCCESS") {
                //var retorno = response.getReturnValue();
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if(errors[0] && errors[0].message){
                    console.log(errors[0].message);
                }
            }
        }));
        $A.enqueueAction(action);
    },    
    
    fireCloseTabEvent : function(cmp, event) {
        cmp.set("v.closeTab", "true");
        var externalEvent = $A.get("e.c:CEC_PME_CloseConsoleTabExternalEvent");
        externalEvent.setParams(
            {
                'data':
                {
                    type : "closeTab",
                    id : cmp.get("v.cTabId"),
                    value : cmp.get('v.closeTab')
                }
            }
        );
        externalEvent.fire();
    },
    redirectToOrder: function(component, event, helper) {
        let urlString = window.location.href;
        let urlLoc = new URL(urlString);
        let param = urlLoc.searchParams.get('id');
        
        let deviceType = $A.get("$Browser.formFactor");
        
        
        if (deviceType == 'DESKTOP' ) {
            var externalEvent = $A.get("e.c:CEC_PME_CloseConsoleTabExternalEvent");
            externalEvent.setParams(
                {
                    'data':
                    {
                        type : "openTab",
                        id : null,
                        value : ('/' + param)
                    }
                }
            );
            externalEvent.fire();
        }
        else { // Is Mobile
            window.open('/'+param,'_parent');            
        }
    },
    
    updateLD21Order : function(component, event, helper) {
        var action = component.get("c.updateLD21Order");
        
        action.setParams({ 
            "recordId" : component.get("v.idPedido") ,
            "ld21Seleted" : component.get("v.ld21Seleted")
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                console.log("SUCCESS");
                component.set("v.showModalError", false);
                component.set("v.msgModalError", '');
            } else {
                
                var errors = response.getError();
                var errorMessage = "Unknown error";
                if (errors && errors[0] && errors[0].message) {
                     console.log(errors[0].message);
                    errorMessage = errors[0].message;
                } else {
                    console.log("Unknown error");
                }
                
                component.set("v.showModalError", true);
                component.set("v.msgModalError", errorMessage);
            }
        });
        $A.enqueueAction(action);
    }
})