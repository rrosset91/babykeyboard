({   
    
    getCleanExpandableTV : function(component,event,helper,index){
        var list = component.get("v.tvList");
        component.set("v.tvSubList",null);
        for(var i = 0; i< list.length ;i++){
            if(i != index){
                list[i].isExpandable = false;
            }
        }
        component.set("v.tvList",list);
        console.dir(list);
    },

    getCleanExpandableTell : function(component,event,helper,index){
        var list = component.get("v.tellList");
        component.set("v.tellSubList",null);
        for(var i = 0; i< list.length ;i++){
            if(i != index){
                list[i].isExpandable = false;
            }
        }
        component.set("v.tellList",list);
        console.dir(list);
    },
    
    getCleanExpandableNet : function(component,event,helper,index){
        var list = component.get("v.netList");
        component.set("v.netSubList",null);
        for(var i = 0; i< list.length ;i++){
            if(i != index){
                list[i].isExpandable = false;
                list[i].msisdn = this.formatMSISDN(list[i].msisdn);
            }
        }
        component.set("v.netList",list);
        console.dir(list);
    },
    
    getCleanExpandableMov : function(component,event,helper,index){
        var list = component.get("v.movList");
        component.set("v.movSubList",null);
        for(var i = 0; i< list.length ;i++){
            if(i != index){
                list[i].isExpandable = false;
            }
        }
        component.set("v.movList",list);
        console.dir(list);
    },

    getAssetsTV : function(component,event,helper){
        var action = component.get("c.getAssets");
        action.setParams({
            id: component.get("v.recordId"),
            recordType: 'CECTV'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                    console.log('AsetsTVResults: ' + JSON.stringify(result));
                if(result.length != 0){
                    for (var i = 0; i < result.length; i++) {
                        result[i].msisdn = this.formatMSISDN(result[i].msisdn);
                        var res = result[i].Preco;
                        if (res != null) {
                          result[i].Preco = res.toFixed(2);
                          var rep = result[i].Preco.replace(".", ",");
                          res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                          var cash = "R$";
                          result[i].Preco = cash.concat(res);
                        }
                      }
                    component.set("v.hasTV",true);                    
                    component.set("v.tvList", result);
                    var teste =  component.get("v.tvList");
                    console.log('tvList: ' + JSON.stringify(teste));
                }
                else component.set("v.hasTV",false);                     
            }
        });
        $A.enqueueAction(action);
    },

    getSubAssetsTV: function(component,event,helper,accountId, spotid){
        console.log('getSubAssetsTV');
        var action = component.get("c.getSubAssetsRes");
        action.setParams({
            AccountId: accountId,
            SpotId : spotid
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('subAsetsTVResults: ' + JSON.stringify(result));
                console.dir(result);
                if(result.length != 0){
                    for (var i = 0; i < result.length; i++) {
                        var res = result[i].PriceDec__c;
                        if (res != null) {
                          result[i].PriceDec__c = res.toFixed(2);
                          var rep = result[i].PriceDec__c.replace(".", ",");
                          res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                          var cash = "R$";
                          result[i].PriceDec__c = cash.concat(res);
                          console.log('Result i: ' + result[i].PriceDec__c);
                        }
                      }
                      component.set("v.hasSubTV", true);
                      component.set("v.tvSubList", result);                }
            }
        });
        $A.enqueueAction(action);
        
    },

    getAssetsTell : function(component,event,helper){
        var action = component.get("c.getAssets");
        action.setParams({
            id: component.get("v.recordId"),
            recordType: 'CECFixo'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length != 0){
                    for (var i = 0; i < result.length; i++) {
                        result[i].msisdn = this.formatMSISDN(result[i].msisdn);
                        var res = result[i].Preco;
                        if (res != null) {
                            result[i].Preco = res.toFixed(2);
                            var rep = result[i].Preco.replace(".", ",");
                            res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                            var cash = "R$";
                            result[i].Preco = cash.concat(res);
                        }
                    }
                    component.set("v.hasTell",true);
                    component.set("v.tellList",result);
                }
                else component.set("v.hasTell",false);                     
            }
        });
        $A.enqueueAction(action);
    },

    getSubAssetsTell: function(component,event,helper,accountId, spotid){
        console.log('getSubAssetsTell');
        var action = component.get("c.getSubAssetsRes");
        action.setParams({
            AccountId: accountId,
            SpotId : spotid
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.dir(result);
                if(result != null){
                    if(result.length != 0){
                        for (var i = 0; i < result.length; i++) {
                            var res = result[i].PriceDec__c;
                        if (res != null) {
                          result[i].PriceDec__c = res.toFixed(2);
                          var rep = result[i].PriceDec__c.replace(".", ",");
                          res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                          var cash = "R$";
                          result[i].PriceDec__c = cash.concat(res);
                          console.log('Result i: ' + result[i].PriceDec__c);
                            }
                          }
                          component.set("v.hasSubTell", true);
                          component.set("v.tellSubList", result);                    } 
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    
    getAssetsNet : function(component,event,helper){
        var action = component.get("c.getAssets");
        action.setParams({
            id: component.get("v.recordId"),
            recordType: 'CECInternetFixa'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.netList",result);
                if(result.length != 0){
                    for (var i = 0; i < result.length; i++) {
                        result[i].msisdn = this.formatMSISDN(result[i].msisdn);
                        var res = result[i].Preco;
                        if (res != null) {
                          result[i].Preco = res.toFixed(2);
                          var rep = result[i].Preco.replace(".", ",");
                          res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                          var cash = "R$";
                          result[i].Preco = cash.concat(res);
                        }
                      }
                    component.set("v.hasNet",true);
                }   
                else component.set("v.hasNet",false);                     
            }
        });
        $A.enqueueAction(action);        
    },

    getSubAssetsNet: function(component,event,helper,accountId, spotid){
        console.log('getSubAssetsNet');
        var action = component.get("c.getSubAssetsRes");
        action.setParams({
            AccountId: accountId,
            SpotId : spotid
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length != 0){
                    for (var i = 0; i < result.length; i++) {
                        var res = result[i].PriceDec__c;
                        if (res != null) {
                          result[i].PriceDec__c = res.toFixed(2);
                          var rep = result[i].PriceDec__c.replace(".", ",");
                          res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                          var cash = "R$";
                          result[i].PriceDec__c = cash.concat(res);
                          console.log('Result i: ' + result[i].PriceDec__c);
                        }
                      }
                      component.set("v.hasSubNet", true);
                      component.set("v.netSubList", result);                 
                    }
            }
        });
        $A.enqueueAction(action);
        
    },
    
    getAssetsMov : function(component,event,helper){
        var action = component.get("c.getAssets");
        action.setParams({
            id: component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.movList",result);
                console.dir(result);
                if(result.length != 0){
                    for (var i = 0; i < result.length; i++) {
                        result[i].msisdn = this.formatMSISDN(result[i].msisdn);
                        var res = result[i].Preco;
                        if (res != null) {
                          result[i].Preco = res.toFixed(2);
                          var rep = result[i].Preco.replace(".", ",");
                          res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                          var cash = "R$";
                          result[i].Preco = cash.concat(res);
                        }
                      }
                    component.set("v.hasMov",true);
                }        
                else component.set("v.hasMov",false);   
                
                console.log(component.get("v.hasMov"));
                console.log(component.get("v.hasTell"));
                console.log(component.get("v.hasTV"));
                console.log(component.get("v.hasNet"));
            }
        });
        $A.enqueueAction(action);
    },

    getSubAssetsMov : function(component,event,helper,msisdn){
        console.log('getSubAssetsMov');
        var action = component.get("c.getSubAssetsMov");
        action.setParams({
            msisdn : msisdn
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length != 0){
                    for (var i = 0; i < result.length; i++) {
                        var res = result[i].PriceDec__c;
                        if (res != null) {
                          result[i].PriceDec__c = res.toFixed(2);
                          var rep = result[i].PriceDec__c.replace(".", ",");
                          res = rep.replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
                          var cash = "R$";
                          result[i].PriceDec__c = cash.concat(res);
                          console.log('Result i: ' + result[i].PriceDec__c);
                        }
                      }
                      component.set("v.hasSubMov", true);
                      component.set("v.movSubList", result);                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    /* ----------------------- Métodos de Tratativa de Dados ----------------------- */
    formatMSISDN: function(msi) {
        var inputValue = msi;
        if(msi) {
            var rep = msi.replace(/[^0-9]/g, '');
            var res = rep.replace(/(\d{2})(\d{4})(\d{4})/, "($1) $2-$3");
            inputValue = res.substring(0,15);
            if(msi.length >= 11) {
                var res = rep.replace(/(\d{2})(\d{5})(\d{4})/, "($1) $2-$3");
                inputValue = res.substring(0,15);
            }
        }
        return inputValue;
    },
    
    getCleanExpandable : function(component,event,helper,index,nameList,nameSubList){
        
        var list = component.get(nameList);
        component.set(nameSubList,null);
        
        for(var i = 0; i< list.length ;i++){
            if(i != index){
                list[i].isExpandable = false;
            }
        }
        component.set(nameList,list);
    },
})