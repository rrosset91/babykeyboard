({

    doInit : function(component, event, helper) {
        helper.doInit(component,helper);

        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var todaySubtract = new Date();
        todaySubtract.setDate(todaySubtract.getDate() - 15);
        todaySubtract = $A.localizationService.formatDate(todaySubtract, "YYYY-MM-DD");
        var todayYear = new Date();
        todayYear.setYear(todayYear.getFullYear() - 5);
        todayYear = $A.localizationService.formatDate(todayYear, "YYYY-MM-DD");

        component.set("v.dataStartValue", todaySubtract);
        component.set("v.dataEndValue", today);
        component.set("v.minData", todayYear);
        component.set("v.maxData", today);
        component.set("v.showTable", false);
        component.set('v.dataTransactions', null);
        component.set('v.paginationList', null);
        component.set("v.tipoValue", null);
        component.set("v.subTipoValue", null);
        
        var list = [{value:null, label:"Selecione um tipo"},
                    {value:"RECARGAS", label:"Recargas"},
                    {value:"CHAMADAS", label:"Chamadas"},
                    {value:"SMS", label:"SMS"},
                    {value:"VAS", label:"VAS"},
                    {value:"DADOS%20BANDA%20LARGA", label:"Dados banda larga"},
                    {value:"AJUSTE", label:"Ajuste"}];
        
        component.set("v.tipo",list);
        helper.getTransactionsLast(component, helper);
    },

    buscarHandler : function(component, event, helper) {
        component.set("v.showTable", false);
        if(helper.validateField(component, event, helper)) {
            helper.getTransactionsPeriod(component,helper);
        }
    },

    populateCmbsubTipo : function(component, event, helper){
        component.set("v.subTipoValue", null)
        var tipo = component.find("cmbTipo").get("v.value");
        var subtipo = [];
        
        if(tipo == 'RECARGAS'){
            subtipo = [{value:null, label:"Selecione um subtipo"},
                       {value:"Recarga",label:"Recarga"}];
        }else if (tipo == 'CHAMADAS'){
            subtipo = [{value:null, label:"Selecione um subtipo"},
                       {value:"Chamadas%20Locais", label:"Chamadas locais"},
                       {value:"Chamadas%20Interurbanas", label:"Chamadas interurbanas"},
                       {value:"Chamadas%20Internacionais", label:"Chamadas internacionais"},
                       {value:"Numeros%20Especiais", label:"Números especiais"},
                       {value:"Deslocamento", label:"Deslocamento"},
                       {value:"Chamadas%20a%20Cobrar", label:"Chamadas a cobrar"},
                       {value:"Video%20Chamada", label:"Vídeo chamada"},
                       {value:"Chamadas%20Recebidas%20Roaming", label:"Chamadas recebidas roaming"}];
        }else if(tipo == 'SMS'){
            subtipo = [{value:null, label:"Selecione um subtipo"},
                       {value:"Torpedo",label:"Torpedo"}];
        }else if (tipo == 'VAS'){
            subtipo = [{value:null, label:"Selecione um subtipo"},
                       {value:"Serviços",label:"Serviços"}];
        }else if(tipo == 'DADOS%20BANDA%20LARGA'){
            subtipo = [{value:null, label:"Selecione um subtipo"},
                       {value:"Banda%20Larga",label:"Banda larga"},
                       {value:"Total%20Trafegado%20Banda%20Larga",label:"Total trafegado banda larga"}];
        }else if(tipo == 'AJUSTE'){
            subtipo = [{value:null, label:"Selecione um subtipo"},
                       {value:"Ajuste%20Automático",label:"Ajuste automático"}];
        }else {
            subtipo = [];
        }

        component.set('v.auxtipo', '');
        if(tipo !== null && tipo !== undefined){
            var auxTipo = tipo.replace(/%20/g,' ');
            component.set('v.auxtipo', auxTipo);
        }
        component.set('v.auxSubTipo', '');

        component.set("v.subTipo",subtipo);
    },

    handleSubTipo : function(component, event, helper) {
        
        component.set('v.auxSubTipo', '');
        var auxSubTipo = component.get('v.subTipoValue');
        if(auxSubTipo !== null && auxSubTipo !== undefined){
            auxSubTipo = auxSubTipo.replace(/%20/g,' ');
            component.set('v.auxSubTipo', auxSubTipo);
        }

    },

    handlePromotionalAfter : function(component, event, helper) {
        var items = component.get("v.paginationList"), index = event.getSource().get("v.value");
        if(JSON.stringify(items[index].usagePromotionalBalances) != '[]') {
            items[index].expanded = !items[index].expanded;
            component.set("v.paginationList", items);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Erro", 
                "type": "Error", 
                "message": "Não foi possível encontrar registros."
            });
            toastEvent.fire();
        }
    },

    proximoHandler : function(component, event, helper) {
        var dataList = component.get("v.dataTransactions");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        
        for(var i=end+1; i<end+pageSize+1; i++) {
            if(dataList.length > end) {
                if(dataList[i] != null) paginationList.push(dataList[i]);
                counter ++;
            }
        }
        start = start + counter;
        end = end + counter;
        
        component.set("v.start", start);
        component.set("v.end", end);
        component.set('v.paginationList', paginationList);
    },

    anteriorHandler : function(component, event, helper) {
        var dataList = component.get("v.dataTransactions");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++) {
            if(i > -1) {
                paginationList.push(dataList[i]);
                counter ++;
            }else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        
        component.set("v.start", start);
        component.set("v.end", end);
        component.set('v.paginationList', paginationList);
    },
})