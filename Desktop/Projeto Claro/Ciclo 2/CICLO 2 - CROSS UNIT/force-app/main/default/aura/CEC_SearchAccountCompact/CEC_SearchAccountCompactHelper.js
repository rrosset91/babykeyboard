({
    formatCPF:function(component,helper) {
        var doc = component.find("txtDoc").get("v.value");
        
        if(doc){
            var rep = doc.replace(/[-/.]/g, ''); 
            var res = rep.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4");
            component.set("v.doc", res);
        }
    },
    
    formatCNPJ:function(component,helper) {
        var doc = component.find("txtDoc").get("v.value");
        
        if(doc){
            var rep = doc.replace(/[-/.]/g, ''); 
            var res = rep.replace(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, "$1.$2.$3/$4-$5");
            component.set("v.doc", res);
        }
    },
    
    formatRNE:function(component,helper) {
        var field = component.find("txtDoc").get("v.value");
        var res = field.replace(/[^A-Za-z0-9]/g, '');
        component.set("v.doc", res)
        
        if(field){
            var tam = field.length;
            var rep = res.replace(/[-/.]/g, ''); 
            var mas = rep.replace(/(\w{7})(\w{1})/, "$1-$2");
            if(tam > 9)
                component.set("v.doc", mas.substring(0, 9));
        }
    },
    
    formatPassaporte : function(component,helper){
        var doc = component.find("txtDoc").get("v.value");
        var tam;
        
        if(doc != null){
            tam = doc.length;
            if(tam > 9)
                component.set("v.doc",doc.substring(0,9));
        }     
    }
})