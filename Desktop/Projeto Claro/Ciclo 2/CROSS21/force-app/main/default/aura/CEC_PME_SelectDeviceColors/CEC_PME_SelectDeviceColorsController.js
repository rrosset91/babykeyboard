({
    initComponent : function (cmp, event, helper) {
        console.log('init select device colors component');
        helper.initTable(cmp);
        helper.setPicklistDevices(cmp, event, helper, false);
    },
    
    refreshPickList : function (cmp, event, helper) {
        console.log('refresh picklist');
        helper.setPicklistDevices(cmp, event, helper, true);
    },
    
    deviceSelectChanged : function (cmp, event, helper) {
        console.log("DEVICE SELECT CHANGED -->> ");
        var deviceList = cmp.get("v.devices");
        var deviceKey = cmp.get("v.deviceSelected");
        console.log('Key: ' + deviceKey);
		var device = helper.getAparelhoPorChave(deviceKey, deviceList);
        // If invalid device option
        if (device.aparelho == null || device.aparelho == "--") {
            console.log('>>>Não econtrou aparelho');
            // Set these to empty values and disable radio button
            cmp.set("v.showAcceptMessage", false);
            cmp.set("v.deviceColor", "");
            cmp.set("v.aceitaCoresSelected", false);
            cmp.set("v.aparelhoValido", false);
            cmp.set("v.aceitaCoresDisabled", true);
            cmp.set("v.adicionaAparelhoButtonDisabled", true);
        }
        else {
			//let itemKey = Object.keys(device.aparelho)[0];            
			//let itemDevice = device.aparelho[itemKey];
           
            cmp.set("v.aparelhoValido", true);
            //cmp.set("v.adicionaAparelhoButtonDisabled", false);
            if (cmp.get("v.tipoEntrega") == 'Local') {
                cmp.set("v.colorOptions", []);
                cmp.set("v.deviceColor", device.cor);
                cmp.set("v.aceitaCoresOptionValue", false);
                cmp.set("v.adicionaAparelhoButtonDisabled", false);
            }
            else {
                cmp.set("v.colorOptions", device.lstCoresDisponiveis);
                cmp.set("v.deviceColor", device.cor);
                cmp.set("v.aceitaCoresDisabled", false);
               
                if (!device.lstCoresDisponiveis || device.lstCoresDisponiveis.length == 0) {
                    cmp.set("v.showAcceptMessage", true);                        
                    cmp.set("v.adicionaAparelhoButtonDisabled", false);
                }
                else {
                    cmp.set("v.showAcceptMessage", false);
                    //desabilita o botão de incluir
                    helper.disableIncluir(cmp);                   
                }
                //limpa sim ou não de cores
                helper.emptySection(cmp);
                
                //limpa as cores selecionadas
                helper.clearColorSelection(cmp); // Clearing attributes values and visual elements whenever a different device is selected
            }
            
        }
    },
    onColorCheckboxChanged : function (cmp, event, helper) {
        var list = cmp.get("v.colorsSelected"); // List of selected colors
        var src = event.getSource(); // The checkbox component itself
        var checked = src.get("v.checked"); // If checkbox is checked or not
        var label = src.get("v.label"); // Label of the color
        var value = src.get("v.value"); // Value of the color
        var option = { label : '', value : ''};
        option.label = label;
        option.value = value;
        if (checked) { // If checkbox is checked, add color to list
            list.push(option); // Add option (color) to list
        }
        else { // Else checkbox is unchecked, remove color from list
            for (var i=0; i < list.length; i++){
                if (list[i].value == value){
                    list.splice(i, 1); // Removing corresponding index from list
                }
            }
        }
        
        // Setting selected colors list to human-readable text
        var selectedString = ""; // The human-readable text string
        for (var i=0; i < list.length; i++) {
            if (i==0) { // Ignore comma for first item
                selectedString += list[i].label;
			}
            else { // adding comma to the other items
                selectedString += ", " + list[i].label;
            }
        }
        //habilita ou não o botão de incluir
        helper.checkSelectedColors(cmp, selectedString);
        cmp.set("v.colorsSelected", list); // Updating selected colors list attribute
        cmp.set("v.colorsSelectedString", selectedString); // Updating the human-readable text
    },
    
    radioChanged : function(cmp, event, helper) {
        try{
            var option = cmp.get("v.aceitaCoresOptionValue");
            console.log(option);
            var device = cmp.get("v.deviceSelected");
            console.log("SELECTED: " + device);
            let devices = cmp.get("v.devices");
            if (device == '--') {
                option = false;
            }
            helper.toggleButton(cmp, option);
            cmp.set("v.colorsSelectedString", '');
            cmp.set("v.colorsSelected", []);
            cmp.set("v.aceitaCoresSelected", option);
            if(option == 'true'){
                cmp.set("v.adicionaAparelhoButtonDisabled", true);
            } else {
                cmp.set("v.adicionaAparelhoButtonDisabled", false);
            }
        } catch(err){
            console.log(err);
        }
    },
    // Function for onclick of 'Incluir' button
    addDevice : function(component, event, helper){
        try{
			var tipoPlano = component.get("v.tipoPlano");
            
            let deviceKey = component.get("v.deviceSelected");
            let device = helper.setDevices(component, event);
            let colors = component.get('v.colorsSelectedString');
            let allowColors = component.get("v.aceitaCoresOptionValue");
            if (allowColors == false) {
                colors = '';
            }
            let evt = component.getEvent('AdicionarAparelho');
            let color = component.get('v.deviceColor'); // Setting device color
            evt.setParams({
                'label' : device.aparelho[deviceKey],
                'value' : deviceKey,
                'color' : color,
                'colors' : $A.util.isEmpty(colors) ? 'Não' : colors,
				'associacao' : component.get('v.assocAuto')                
            });
            //evt.fire();
            helper.clearColorSelection(component);
            component.set("v.aceitaCoresDisabled", true);
           	component.set('v.aceitaCoresOptionValue', false);
            component.set('v.aceitaCoresSelected', false);
            component.set('v.aparelhoValido', false);
            //component.set("v.deviceSelected", {label: '--Selecione--', key: '--'});
            
            helper.disableIncluir(component);

            evt.fire(); //aqui deveria resolver bug do botão não sumir quando devia

            if (tipoPlano != 'Transferencia') {
				helper.setPicklistDevices(component, event, helper, true);                            
            }
        } catch(err) {
            console.log(err);
        }
    },
    assocAutoDevices : function(component, event, helper){
        helper.assocAutoDevices(component);
    }
})