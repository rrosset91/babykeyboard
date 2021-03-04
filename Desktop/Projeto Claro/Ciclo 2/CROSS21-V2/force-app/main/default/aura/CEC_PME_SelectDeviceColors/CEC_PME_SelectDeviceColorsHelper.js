({
    setPicklistDevices : function (cmp, event, helper, refresh) {
        try {
            var devices = cmp.get("v.devices");
            var tipoPlano = cmp.get("v.tipoPlano");

            var deviceOptions = [];

			this.setAssocAuto(cmp, event, helper);
                
            for (let i=0; i < devices.length; i++) {  
                if (tipoPlano == 'Portabilidade') {                       
                    if ((cmp.get("v.assocAuto") == false && this.getAparelhoLabel(devices[i].aparelho) != 'SimCard Avulso') || (cmp.get("v.assocAuto") == true && this.getAparelhoLabel(devices[i].aparelho) == 'SimCard Avulso')) {
                        deviceOptions.push(this.getAparelhoKeys(devices[i].aparelho));
                    }
                } else {
                    deviceOptions.push(this.getAparelhoKeys(devices[i].aparelho));
                }
            }   
          
            if(refresh){
                cmp.set('v.deviceSelected', {label:'--Selecione--', value:'--', cor:'--'});
            }
            cmp.set("v.deviceOptions", deviceOptions);
        } catch(ex) {
            console.log(ex);
        }
    },
    setDevices : function(cmp, event) {
        let device = {};
        let devices = cmp.get("v.devices");
        let deviceOptions = cmp.get("v.deviceOptions");
        let addedDevices = [];
        let selectedDevice = cmp.get("v.deviceSelected");
        let tipoPlano = cmp.get("v.tipoPlano");
        
        device = this.getAparelhoPorChave(selectedDevice, devices);
        console.table(device);
        for (let i = 0; i < deviceOptions.length; i++) {
            if (deviceOptions[i].key == selectedDevice) {
                addedDevices.push(deviceOptions[i]);
                deviceOptions.splice(i,1);
                break;
            }
        }
        if (deviceOptions.length == 0 && tipoPlano == 'Portabilidade') {
            cmp.set("v.assocAuto", true);
        }        
        
        console.table(deviceOptions);
        cmp.set("v.deviceOptions", deviceOptions);
        return device;
    },
    setDevicesOld : function(component, event) {
        try{
            let device = {};
            let devices = component.get('v.deviceOptions');
            let newDevices = [];
            console.log('devices: ' + JSON.stringify(devices));
            let selectedDevice = component.get('v.deviceSelected');
            console.log('selectedDevice: ' + JSON.stringify(selectedDevice));
            for(let i = 0; i < devices.length; i++) {
                if(devices[i].label === selectedDevice){
                    device = devices[i];
                }else{
                    newDevices.push(devices[i]);
                }
            }
            component.set('v.deviceOptions', newDevices);
            component.set('v.devices', newDevices);
            this.clearColorSelection(component);
            return device;
        }catch(err){
            console.log(err);
        }
    },
    
    toggleButton : function(component, radio) {
        try{
            if(radio == 'false'){
				this.enableIncluir(component);
            }else{
                this.disableIncluir(component);
            }
        }catch(err){
            console.log(err);
        }
    },
    
    checkSelectedColors : function(component, colors){
        try{
            console.log('colors: ' + colors);
            if($A.util.isEmpty(colors)){
                this.disableIncluir(component);
            }else{
                this.enableIncluir(component);
            }
        }catch(err){
            console.log(err);
        }
    },
    
    disableIncluir: function(component){
        component.get('v.adicionaAparelhoButton', true);
        component.set("v.adicionaAparelhoButtonDisabled", true);
    },
    
    enableIncluir: function(component){
        component.get('v.adicionaAparelhoButton', false);
        component.set("v.adicionaAparelhoButtonDisabled", false);
    },
    
    emptySection: function(component){
        component.set('v.aceitaCoresOptionValue', '');
        component.set('v.aceitaCoresSelected', false);
    },
    
    // Clearing color selection. Both string and checkboxes
	clearColorSelection : function(cmp) {
		cmp.set("v.colorsSelected", []);
        cmp.set("v.colorsSelectedString", "");
	},
    getAparelhoPorChave : function(deviceKey, devices) {
        console.log('>>>>>');
        console.log(deviceKey);
        console.log(devices);
        console.log('<<<<<');
        for(let i = 0; i < devices.length; i++) {
            let key = Object.keys(devices[i].aparelho)[0];
            if (key == deviceKey) { 
                return devices[i];
            }
        }
        return {aparelho: null};
	},
    getAparelhoKeys : function(aparelho) {
        let aparelhoKey = Object.keys(aparelho)[0];

        // Using 'deviceKey' to return corresponding value from 'aparelho'
        return { label: aparelho[aparelhoKey], key: aparelhoKey };
    },
    getAparelhoLabel : function(aparelho) {
        let aparelhoKey = Object.keys(aparelho)[0];

        // Using 'deviceKey' to return corresponding value from 'aparelho'
        return aparelho[aparelhoKey];
    },     
	initTable : function(component) {
        var tipoPlano = component.get("v.tipoPlano");
		var devices = component.get("v.devices");    
		let evt = component.getEvent('AdicionarListaAparelhos'); 
        
        let label = [];
        let value = [];
        let color = [];
        let colors = [];

        if (tipoPlano == 'Novo') {           
            for (let i=0; i < devices.length; i++) {           
                let deviceKey = Object.keys(devices[i].aparelho)[0];
                let device = devices[i].aparelho[deviceKey];

                if (device == 'SimCard Avulso') {
                	label.push(device);
                    value.push(deviceKey);
                    color.push('');
                    colors.push('Não');
                }
            }
            
            evt.setParams({
                'label' : label,
                'value' : value,
                'color' : color,
                'colors' : colors
            }); 

            evt.fire();          
        }
    },  
    assocAutoDevices : function(component) {   
		var devices = component.get("v.devices");
        let evt = component.getEvent('AdicionarListaAparelhos');
        
        let label = [];
        let value = [];
        let color = [];
        let colors = [];        

        for (let i=0; i < devices.length; i++) {           
            let deviceKey = Object.keys(devices[i].aparelho)[0];
            let device = devices[i].aparelho[deviceKey];

            if (device == 'SimCard Avulso') {
                label.push(device);
                value.push(deviceKey);
                color.push('');
                colors.push('Não');
            }
        }
        
        evt.setParams({
            'label' : label,
            'value' : value,
            'color' : color,
            'colors' : colors
        }); 
        
        evt.fire();     
    },
    setAssocAuto : function (cmp, event, helper) {
        var devices = cmp.get("v.devices");
        var tipoPlano = cmp.get("v.tipoPlano");
        
        var bDevice = false;            
        
        if (tipoPlano == 'Portabilidade') {                
            for (let i=0; i < devices.length; i++) {  
                if (this.getAparelhoLabel(devices[i].aparelho) != 'SimCard Avulso') {
                    bDevice = true;                        
                }
            } 
            
            if (!bDevice) {                    
                cmp.set("v.assocAuto", true); 
            } else {
                cmp.set("v.assocAuto", false);     
            }
        }    
    }
})