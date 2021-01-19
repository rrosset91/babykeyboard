({
    //função aonde é inicializada no carregamento inicial da page
    doInit: function(component, event, helper) {
        let device = $A.get("$Browser.formFactor");
        component.set('v.isDesktop', (device === 'DESKTOP') ? true : false);
        helper.carregar(component);
    },
    //expande a sessão abaixo do nome plano
    expandeSessao: function(component, event, helper) {
        try{
            let arrowId = event.currentTarget.id;
            console.log('arrowId: ' + arrowId);
            if($A.util.isEmpty(arrowId)){
                console.log('id não encontrado');
            }else{
                let sectionId = arrowId.replace('arrow', 'section');
                let rowId = arrowId.replace('arrow', 'row');
                let textId = arrowId.replace('arrow', 'rowtext');
                console.log('rowId: ' + rowId);
                helper.sectionDisplay(document.getElementById(sectionId), false);
                helper.toggleArrow(document.getElementById(arrowId));
                helper.colorRow(document.getElementById(rowId));
                //helper.colorText(document.getElementById(textId));
                helper.colorText(document.getElementById(rowId));
            }
        }catch(err){
            console.log(err);
        }
    },
    //expande a sessão do nome plano
    expandeSessaoPai: function(component, event, helper) {
        try{
            let arrowId = event.currentTarget.id;
            console.log('arrowId: ' + arrowId);
            helper.sectionDisplay(document.getElementById(arrowId.replace('row', 'section')), true);
            helper.toggleArrow(document.getElementById(arrowId));
        }catch(err){
            console.log(err);
        }
    },
    
    finalizarPedido : function(cmp, event, helper){
        helper.gravarPedido(cmp, helper);
    },
    
    closeModalError : function(cmp, event, helper){
        cmp.set("v.showModalError", false);
        cmp.set("v.msgModalError", '');
    },
    
    changeAssocPendente : function(component, event, helper){
        try{
            //parâmetro do evento
            let associacaoPendente = event.getParam('associacaoPendente');
            let idElemento = event.getParam('elemento');
            let elMobile = document.getElementById(idElemento.replace('rowtext', 'rowtext1'));
            let elBloco = document.getElementById(idElemento.replace('rowtext', 'rowtext2'));
            let elNoMobile = document.getElementById(idElemento.replace('rowtext', 'rowtext3'));
            let blnAssocPendente = (associacaoPendente == 'Sim');
            if(elMobile != null){
                //mudar os textos da associação pendente
                helper.assocText(elMobile, associacaoPendente);
                (blnAssocPendente) ? helper.assocColorText(elMobile, 'red-text') : helper.assocColorText(elMobile, 'lightblue-text');
            }
            if(elBloco != null){
                //mudar os textos da associação pendente
                helper.assocText(elBloco, associacaoPendente);
                (blnAssocPendente) ? helper.assocColorText(elBloco, 'red-text') : helper.assocColorText(elBloco, 'lightblue-text');
            }
            if(elNoMobile != null){
                //mudar os textos da associação pendente
                helper.assocText(elNoMobile, associacaoPendente);
                (blnAssocPendente) ? helper.assocColorText(elNoMobile, 'red-text') : helper.assocColorText(elNoMobile, 'lightblue-text');
            }
        }catch(err){
            console.log(err);
        }
    },
   
    openResumo : function(cmp, event, helper){
        helper.gravarResumo(cmp, event, helper);
        
        let orderId = cmp.get("v.idPedido");
        //window.open('/apex/CEC_PME_ResumoPedido?id='+cmp.get("v.idPedido"),'_blank');
        var eUrl= $A.get("e.force:navigateToURL");
        
        console.log("PedidoId " + orderId);
        if (eUrl) {
            eUrl.setParams({
                "url": "/apex/CEC_PME_ResumoPedido?id=" + orderId
            });

            eUrl.fire();
        } else {
            //window.location = '/apex/CEC_PME_ResumoPedido?id='+ orderId, '_blank'
            window.open("/apex/CEC_PME_ResumoPedido?id=" + orderId, '_blank');
        }
        
    },
    onCloseTab : function(cmp) {
        alert("event FIRED");
    },
    closeConsoleTabEventHandler : function(cmp, event, handler) {
        console.log(event.getParam('data'));
    },
    
    onChangeLd21 : function(component, event, helper) {
        helper.updateLD21Order(component, event, helper);
    },
})