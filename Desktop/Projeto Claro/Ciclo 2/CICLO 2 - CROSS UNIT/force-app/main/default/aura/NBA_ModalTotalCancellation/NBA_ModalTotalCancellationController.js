({
	incluirModal: function (component, event, helper) {

		component.set('v.ShowModal', true );

		helper.varrerProdutos(component, event);
		helper.hasAgendamento(component, event);
	},

	closeAdicionalTV : function (component) {
	
		component.set('v.ShowModal', false );
	},

	fecharModal : function(component){
        component.set('v.confirmed', false);
        component.set('v.ShowModal', false);
    },
    
    click : function(component,event){
	
	var indexOfElementChanged = Number(event.getSource().get("v.name"));
	var currentList = component.get('v.schedule.data.schedule');
	var indexOne = 0 ;
	var myDate = component.get('v.myDate');

	for(var i = 0 ; i < currentList.length ; i++){
		if(currentList[i].dateSchedule === myDate){
			indexOne = i;
		}
	}
	for( var x = 0 ; x < currentList[indexOne].periods.length ; x++){
		currentList[indexOne].periods[x].cheked = false ;
		currentList[indexOne].periods[indexOfElementChanged].cheked = true ;
	}

	currentList[indexOne].periods[indexOfElementChanged].cheked = true ;
	var periodo = currentList[indexOne].periods[indexOfElementChanged].description;
		
	if(periodo !== undefined){
		component.set('v.periodoChecked', true);
	}

	component.set('v.description', periodo);
	component.set('v.renderizer', false);
	component.set('v.renderizer', true);

	},

	salvar : function(component, event, helper){

		var hasAgendamento = component.get('v.isAgendamento');
		var dataAgendamento  = component.get('v.myDate') !== null ? true : false ;
		//var periodoAgendamento = component.get('v.description') !== undefined ? true : false ; 
		var periodo = component.get('v.periodoChecked') ? true : false ; 		
		var semDatas = component.get('v.semDatasAgendamento');
		if(semDatas != null){
			dataAgendamento = true;
			//periodoAgendamento = true;
			periodo = true;
		}


		if(dataAgendamento && periodo){
			helper.endCase(component, event, helper);
			component.set('v.confirmed', true);
			component.set('v.ShowModal', false);
			return null;
		}else if(!periodo){
			 helper.toastEvent('Agendamento não solicitado', 'Adicione uma data para agendamento.', 'error');
		}

		//helper.endCase(component, event, helper);
		//component.set('v.confirmed', true);
		//component.set('v.ShowModal', false);

    },

	dateUpdate : function(component) {
        
		component.set('v.description', 'false');
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //Janeiro é 0!
        var yyyy = today.getFullYear();
     // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
    // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
     var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(component.get("v.myDate") != '' && component.get("v.myDate") < todayFormattedDate){
            component.set("v.dateValidationError" , true);
        }else{
            component.set("v.dateValidationError" , false);
        }

		var data = component.get('v.mydate');
		var listOne = component.get('v.schedule.data.schedule');
		var indexOne = 0;
		for(var i = 0 ; i < listOne.length ; i++){
			if(data === listOne[i].dateSchedule){
				indexOne = i;
			}
		}

		if(listOne[indexOne].periods.length > 0 ){
			component.set('v.hasDates', true );
		}
    }
})