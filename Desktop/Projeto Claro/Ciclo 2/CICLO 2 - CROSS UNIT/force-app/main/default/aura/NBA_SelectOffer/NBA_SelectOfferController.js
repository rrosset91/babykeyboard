({
OfferValidationController: function (component, event, helper) {
	if(component.get('v.ofertaSelecionada.mobile.titularMobile.origem')=='Portabilidade' && (
	   component.get('v.ofertaSelecionada.mobile.titularMobile.numeroTelefone')==null || 
	   component.get('v.ofertaSelecionada.mobile.titularMobile.numeroTelefone')=='')){
			component.set('v.forceAdditionalMobile', true)
	   }
	else{
		component.set('v.showSpinner', true);
		helper.OfferValidationHelper(component, event);
	}
},
CloseOfferValidationMessage: function (component, event, helper) {
	component.set('v.ShowOfferValidationMessage', false);
},
incluirModal: function (component, event, helper) {
	helper.saveClickSelectOffer(component , event);
	if(component.get('v.OfferValidationMessage')!=''){
		component.set('v.ShowOfferValidationMessage', true);
		component.set('v.showSpinner', false);
	}
	else{
		var componentSelectOffer = component.get('v.componentSelectOffer');
		var selectedOffer		 = component.get('v.ofertaSelecionada');
		var actualProduct		 = component.get('v.produtoAntigo');
		var posseAtual			 = component.get('v.produtoAtual');
		
		if(!componentSelectOffer && (
			selectedOffer.movimentMobile=='Aquisição' || (
				!actualProduct.mobile.isComboMulti && (
					selectedOffer.movimentMobile=='Upgrade' ||
					selectedOffer.movimentMobile=='Downgrade' ||(
						selectedOffer.movimentMobile=='Lateral' && 
						selectedOffer.mobile.planMobile.label!='NÃO POSSUI' && 
						selectedOffer.mobile.planMobile.label!='MANTER'
					)
				)
			)
		)){
			component.set('v.showModalAgregado', true);	
			component.set('v.showSpinner', false);
		}
		
		else if(componentSelectOffer || posseAtual){
			if(JSON.stringify(actualProduct) === JSON.stringify(posseAtual) ){
				component.set('v.isProdutoAntigo', true);
			}
			component.set('v.isActualProduct', JSON.stringify(selectedOffer) === JSON.stringify(actualProduct));
			helper.varrerProdutos(component, event);
			helper.consultarContract(component, event);
			//component.set('v.showModalBonusDesconto', true );
			component.set('v.ShowModal', true );
			component.set('v.showContent', true );
			if(component.get('v.OfferValidationScheduling')) 
				helper.hasAgendamento(component, event);
			//helper.hasGestorCredito(component, event);
		}

		// atualiza dependentes móveis cancelados
		for(var i=0 ; i<actualProduct.mobile.listaDependentesMobile.length ; i++){
			for(var j=0 ; j<posseAtual.mobile.listaDependentesMobile.length ; j++){
				if(actualProduct.mobile.listaDependentesMobile[i].numeroTelefone == posseAtual.mobile.listaDependentesMobile[j].numeroTelefone){
					actualProduct.mobile.listaDependentesMobile[i].checked = posseAtual.mobile.listaDependentesMobile[j].checked;
				}
			}
		}

	}
},
myChange: function(component, event, helper){
    var motherName = component.find("nomeMae");
	var rg = component.find("numberRG");
	var expedicao = component.find("expedicaoRG");
    var newMotherName = motherName.get("v.value");
	var newRG = rg.get("v.value");
	var newExpedicao = expedicao.get("v.value");
	component.set('v.motherName', newMotherName);
	component.set('v.numberRG', newRG);
	component.set('v.emiterRG', newExpedicao);
}, 
cancel : function(component, event, helper) {
	//component.set('v.showModal', false);
	component.set('v.isVisibleRGContact', false);
},
handleSave : function(component, event, helper) {
	component.find("editForm").submit();
},
closeModel: function(component, event, helper) {
    component.set("v.isAnaliseCreditoModalOpen", false);
},
handleSuccess : function(component, event, helper) {
	//helper.updateContact(component, event, helper);
	component.set('v.saved', true);
	component.set('v.ShowModal', true);
	component.set('v.showContent', true);
	component.set('v.isVisibleRGContact', false);
},
fecharModal : function(component){
	var isAquisicao = component.get("v.isAquisicao"); 
	if(isAquisicao){
		component.set('v.confirmed', false);
		component.set('v.ShowModal', false);
		component.set('v.saved', false);
		component.set('v.isVisibleRGContact', true);
	}else{
		component.set('v.confirmed', false);
		component.set('v.ShowModal', false);
		component.set('v.saved', false);
		component.set('v.isVisibleRGContact', false);
	}        
},
click : function(component,event,helper){
var indexOfElementChanged = Number(event.getSource().get("v.name"));
var currentList = component.get('v.schedule.data.schedule');
// var orderList = currentList.sort(function (a,b) { return b.description - a.description});
var indexOne = 0 ;
var myDate = component.get('v.myDate');
for(var i = 0 ; i < currentList.length ; i++){
	if(currentList[i].dateSchedule === myDate){
		indexOne = i;
	}
}
for( var x = 0 ; x < currentList[indexOne].periods.length ; x++){
	currentList[indexOne].periods[x].cheked = false ;
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
	component.set('v.ShowModal', false);
	component.set('v.showSpinner', true );
	var ofertaSelect = component.get('v.ofertaSelecionada');
	var analise		= false;
    var hasAgendamento			= component.get('v.isAgendamento');
    var dataAgendamento			= component.get('v.myDate') !== null ? true : false ;
    var periodoAgendamento		;//= component.get('v.description') !== 'false' ? true : false ; 
    var periodo					= component.get('v.periodoChecked') ? true : false ; 		
    var semDatas				= component.get('v.semDatasAgendamento');
	if(ofertaSelect.movimentBroadband === 'Upgrade' || ofertaSelect.movimentPhone === 'Upgrade' || ofertaSelect.movimentTv === 'Upgrade' || 
	   ofertaSelect.movimentBroadband === 'Aquisição' || ofertaSelect.movimentPhone === 'Aquisição' || ofertaSelect.movimentTv === 'Aquisição'){
		helper.hasGestorCredito(component, event, helper);
		analise = component.get('v.hasAnalise');
	}else {
		if(semDatas){
			dataAgendamento = true;
			periodoAgendamento = true;
			periodo = true;
		}
		if(dataAgendamento && periodo){
			helper.endCase(component, event, helper);
			component.set('v.confirmed', true);
			component.set('v.ShowModal', false);
			return null;
		}else if(!periodo){
			helper.toastEvent('Agendamento não solicitado', 'Adicione uma data para agendamento.', 'error');
			component.set('v.showSpinner', false );
		}
	}
},
finalizarCaso : function(component, event, helper) {
	helper.encerrarCaso(component, event);
	component.set('v.isAnaliseCreditoModalOpen', false);
},
closeModalAnalise : function(component, event, helper) {
	component.set('v.isAnaliseCreditoModalOpen', false);
	component.set('v.showSpinner', false );
},
dateUpdate : function(component, event, helper) {

	// se alterou a data, reseta variáveis de controle
	if(component.get('v.myOldDate') != component.get('v.myDate')){

	component.set('v.description', 'false');
		component.set('v.periodoChecked', false);
		var dateList = component.get('v.schedule.data.schedule');
		for(var dateIndex = 0 ; dateIndex < dateList.length ; dateIndex++)
			for(var periodIndex = 0 ; periodIndex < dateList[dateIndex].periods.length ; periodIndex++)
				dateList[dateIndex].periods[periodIndex].cheked = false ;
		component.set('v.schedule.data.schedule', dateList);
	}
	component.set('v.myOldDate', component.get('v.myDate'));
	var today = new Date();        
	var dd = today.getDate();
	var mm = today.getMonth() + 1; //Janeiro Ã© 0!
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
	var data = component.get('v.myDate');
	var listOne = component.get('v.schedule.data.schedule');
	var indexOne = 0;
	if (listOne) {
		for(var i = 0 ; i < listOne.length ; i++){
			if(data === listOne[i].dateSchedule){
				indexOne = i;
			}
		}
		if(listOne[indexOne].periods.length > 0 ){
			component.set('v.hasDates', true );
		}
	}
 }
})