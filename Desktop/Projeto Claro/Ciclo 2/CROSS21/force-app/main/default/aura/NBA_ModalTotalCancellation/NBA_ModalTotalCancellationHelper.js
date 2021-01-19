({
	toastEvent: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
	},
	
	saveClickCancelation: function (component, event){
		var sPageURL = ' ' + window.location;
		var sURL = sPageURL.split('/');
		var recordId = sURL[sURL.length - 2];

		var action = component.get('c.saveClickCancelation');	
		action.setParams({
			"recordId" : recordId
		});

		action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
				console.log('Campo Gravado com Sucesso');
            } else if (state === "ERROR") {
				var errors = action.getError();
				if (errors.length > 0) {
					if (errors[0] && (errors[0].message || (errors[0].pageErrors[0] && errors[0].pageErrors[0].message))) {
						if (errors[0].pageErrors[0].message) {
							this.showToast('Erro!', errors[0].pageErrors[0].message, 'error');
						} else if (errors[0].message) {
							this.showToast('Erro!', errors[0].message, 'error');
						}
					}
				}
			}
    
        });
        $A.enqueueAction(action);

	},

    trocarstage : function (component, event){
        
        
        var sPageURL = ' ' + window.location;
        var sURL = sPageURL.split('/');
        var caseId = sURL[sURL.length - 2];
         
        
        var action = component.get("c.updateStage");
        action.setParams({
            "recordId" : caseId
        });
       action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                //this.refreshFocusedTab(component, event);
                component.getEvent("refresh").fire();
                
            }
        });
        $A.enqueueAction(action);
    },
    
      refreshFocusedTab : function(component, event) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                      tabId: focusedTabId,
                      includeAllSubtabs: true
             });
        })
        .catch(function(error) {
            
        });
    },
	
	varrerProdutos : function (component, event){
	
		var atual = component.get('v.produtoAtual');
		var productsPenalty = ''; 
		var productsNoPenalty = ''; 

		var hasFidelity = { 
			broadband : atual.broadband.planBroadband.fidelity.hasFidelity,
			tv :  atual.tv[0].planTv.fidelity.hasFidelity, 
			mobile : atual.mobile.planMobile.fidelity.hasFidelity,
			phone :  atual.phone.planPhone.fidelity.hasFidelity
		};

		var hasPenalty = { 
			broadband : atual.broadband.planBroadband.fidelity.hasPenalty && atual.broadband.planBroadband.label !== "NÃO POSSUI",
			tv :  atual.tv[0].planTv.fidelity.hasPenalty && atual.tv[0].planTv.label !== "NÃO POSSUI", 
			mobile : false, //atual.mobile.planMobile.fidelity.hasPenalty,
			phone :  atual.phone.planPhone.fidelity.hasPenalty && atual.phone.planPhone.label !== "NÃO POSSUI"
		};

		atual.showTotalPenalty = atual.totalPenalty;

		if(!hasPenalty.broadband) {
			atual.showTotalPenalty -= atual.broadband.planBroadband.fidelity.penalty;
		}

		if(!hasPenalty.tv) {
			atual.showTotalPenalty -= atual.tv[0].planTv.fidelity.penalty;
		}

		if(!hasPenalty.phone) {
			atual.showTotalPenalty -= atual.phone.planPhone.fidelity.penalty;
		}

		if(!hasPenalty.mobile) {
			atual.showTotalPenalty -= atual.mobile.planMobile.fidelity.penalty;
		}

		//Preencher produtos que tem fidelização na oferta 
		if(hasPenalty.tv && atual.tv[0].planTv.fidelity.penalty > 0){ productsPenalty += 'TV '; }
		if(hasPenalty.broadband && atual.broadband.planBroadband.fidelity.penalty > 0){ productsPenalty += 'BL '; }
		if(hasPenalty.phone && atual.phone.planPhone.fidelity.penalty > 0){ productsPenalty += 'Fone '; }
		//if(hasPenalty.mobile){ productsPenalty += 'Móvel '; }

		productsPenalty = productsPenalty.trim().replace(/ /g, ' + ');

		//Preencher produtos que não tem penalidade 
		if(!hasPenalty.tv){ productsNoPenalty += 'TV '; }
		if(!hasPenalty.broadband){ productsNoPenalty += 'BL '; }
		if(!hasPenalty.phone){ productsNoPenalty += 'Fone '; }
		//if(hasPenalty.mobile){ productsNoPenalty += 'Móvel '; }

		productsNoPenalty = productsNoPenalty.trim().replace(/ /g, ' + ');

		component.set('v.hasFidelity', hasFidelity);
		component.set('v.hasPenalty', hasPenalty);
		component.set('v.hasProductsPenalty', productsPenalty);
		component.set('v.hasProductsNoPenalty', productsNoPenalty);
		component.set('v.produtoAtual', atual);
	

	},

	endCase : function (component, event ){
		component.set('v.showSpinner', true);
		var sPageURL = ' ' + window.location;
        var sURL = sPageURL.split('/');
        var caseId = sURL[sURL.length - 2];
		var produto = component.get('v.produtoAtual');
		var atual = JSON.stringify(produto);
		var descriptionSchedule = component.get('v.description');
		var myDate = component.get('v.myDate');

		 var action = component.get("c.endCaseCancelation");
        action.setParams({
			"recordId" : caseId,
			"atual" : atual,
			"dateSchedule" : myDate,
			"descriptionSchedule" : descriptionSchedule
        });
       action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
				this.trocarstage(component, event );
            }
			component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
	},

	hasAgendamento : function (component, event){
	    
	  var produtoAtual = component.get('v.produtoAtual');
	  var cityCode = component.get('v.cityCode');
		if(!cityCode){
			cityCode = '';
		}

	  cityCode = cityCode.length > 0 ? '0'.repeat(5 - cityCode.length) + cityCode : '';
	  if(produtoAtual.movimentTv === 'Cancelamento' || produtoAtual.movimentBroadband === 'Cancelamento' || 
		 produtoAtual.movimentPhone === 'Cancelamento' || produtoAtual.movimentMobile === 'Cancelamento' ){
            component.set('v.isAgendamento', true);
      }

	  var idTv = produtoAtual.tv[0].planTv.key;
	  var idBroadband = component.get('v.produtoAtual.broadband.planBroadband.key');
	  var idPhone = component.get('v.produtoAtual.phone.planPhone.key');
	  var idProduto = {"idTvPosse":"","idBlPosse":"","idFnPosse":""};
	  idProduto.idTvPosse = produtoAtual.tv[0].planTv.key;
	  idProduto.idBlPosse = component.get('v.produtoAtual.broadband.planBroadband.key');
	  idProduto.idFnPosse = component.get('v.produtoAtual.phone.planPhone.key');

	  if(idTv !== '' ){
		//idProduto	= idTv;
		component.set('v.isAgendamento', true);
	  }else if(idBroadband !== ''){
		//idProduto = idBroadband;
		component.set('v.isAgendamento', true);
	  }else if(idPhone !== ''){
		//idProduto = idPhone;
		component.set('v.isAgendamento', true);
	  }

	  var sPageURL = ' ' + window.location;
        var sURL = sPageURL.split('/');
        var caseId = sURL[sURL.length - 2]; 

	component.set('v.showSpinner', true );
    component.set('v.ShowModal', false );

	if(idProduto != null){        
        var action = component.get("c.consultarAgendamento");
        action.setParams({
            "recordId" : caseId,
			"ofertaId" : JSON.stringify(idProduto),
			"cityCode" : cityCode,
			"produtoAntigo" : JSON.stringify(component.get('v.produtoAntigo')),

        });
		action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
              var data = response.getReturnValue();
			  if (data.data.schedule === null || data.data.schedule.length === 0){
				component.set('v.semDatasAgendamento', true);
				this.toastEvent('Erro!', $A.get("$Label.c.ERRO_AGENDAMENTO"), 'error');
			  	this.getRemainingDays(component, event);
			  } else {
				component.set('v.renderizer', true);
				var maxDate ;
				var minDate ;
				for(var i =0; i < data.data.schedule.length ; i++){
					minDate = minDate !== undefined ? minDate : data.data.schedule[0].dateSchedule;
					maxDate = maxDate !== undefined ? minDate : data.data.schedule[0].dateSchedule;
					if(data.data.schedule[i].dateSchedule > maxDate){
						maxDate = data.data.schedule[i].dateSchedule;
					}
					if(data.data.schedule[i].dateSchedule < minDate ){
						minDate = data.data.schedule[i].dateSchedule;
					}
				}
				 
				component.set('v.dateMin', minDate);
				component.set('v.dateMax', maxDate);
				component.set('v.schedule', data);

			  }   
            }
			if(state === "ERROR"){
				this.toastEvent('Erro!', $A.get("$Label.c.ERRO_AGENDAMENTO"), 'error');
				/*var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                       this.toastEvent('Erro de consulta', errors[0].message, 'error');
                    }
                }*/	

				this.getRemainingDays(component, event);
			}

			component.set('v.showSpinner', false );
            component.set('v.ShowModal', true );

        });
        $A.enqueueAction(action);
	}
	},

	getRemainingDays : function (component, event, helper){

		var remainingDaysTV = component.get('v.produtoAtual.tv[0].planTv.fidelity.remainingDays');
		var remainingDaysBL = component.get('v.produtoAtual.broadband.planBroadband.fidelity.remainingDays');
		var remainingDaysFone = component.get('v.produtoAtual.phone.planPhone.fidelity.remainingDays');
		var remainingDaysMovel = component.get('v.produtoAtual.mobile.planMobile.fidelity.remainingDays');
		//var remainingDate = Date.today().add(365);
		var result = new Date();
		result.setDate(result.getDate() + 365);
		var today = $A.localizationService.formatDate(result, "dd/MM/yyyy");
		component.set('v.today', today);

		var remainingDaysList = [remainingDaysTV, remainingDaysBL, remainingDaysFone, remainingDaysMovel];
		var order = remainingDaysList.sort(function (a,b) { return b - a});
	    component.set('v.remainingDays', order[0]);

	}
	   
    
})