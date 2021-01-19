({
    initialLoad : function(component) {
		this.setFilters(component);
		this.setColumns(component);
		this.getContestationOptons(component);
	},

	setFilters : function(component) {
        component.set('v.calcValues', [
            {'label': 'Cálculo por Dias', 'value': 'Dias'},
            {'label': 'Cálculo por Porcentagem', 'value': 'Porcentagem'},
        ]);
    },

    setColumns: function (component) {
		component.set('v.columns', [
            {label: $A.get('$Label.c.Fin_ItensSelecionadosContestar_Table_ItemSelecionado'), fieldName: 'descricao', type: 'text', editable: false, sortable: true, cellAttributes:{ class: 'table'}},
			{label: $A.get('$Label.c.Fin_ItensSelecionadosContestar_Table_ValorOriginal'), initialWidth: 160, fieldName: 'valor', type: 'text', editable: false, sortable: true, cellAttributes:{ class: 'table'}},
			{label: $A.get('$Label.c.Fin_ItensSelecionadosContestar_Table_Calculadora'),type: 'button',initialWidth: 200, typeAttributes: { label: $A.get('$Label.c.Fin_ItensSelecionadosContestar_Table_DiaPercentual'), name: 'CalcularButton'}},
            {label: $A.get('$Label.c.Fin_ItensSelecionadosContestar_Table_ValorContestar'),initialWidth: 185, fieldName: 'valorContestar', type: 'currency', typeAttributes: { currencyCode: 'BRL'}, editable: true, sortable: true, cellAttributes:{ class: 'table'}},
            {label: $A.get('$Label.c.Fin_ItensSelecionadosContestar_Table_Motivo'),type: 'button',initialWidth: 140, typeAttributes: { label: $A.get('$Label.c.Fin_ItensSelecionadosContestar_Table_Selecionar'), name: 'ItemMotivo',iconName:'utility:down' }},
            {label: $A.get('$Label.c.Fin_ItensSelecionadosContestar_Table_ValorCorrigido'), initialWidth: 180, fieldName: 'valorCorrigido', type: 'currency', typeAttributes: { currencyCode: 'BRL'}, editable: false, sortable: true, cellAttributes:{ class: 'table'}},
            {type: 'button', initialWidth: 75, typeAttributes: { name: 'Deletar', iconName: 'utility:delete'}},
		]);
    },
	
	handleDelete: function(component, helper, row){
		let invoiceItems = component.get('v.invoiceItens');
		let newArr = [];
		let idsItems = [];

		newArr = invoiceItems.filter(x => {
			if(x.idItem != row.idItem){
				idsItems.push(x.idItem);
				return true;
			}

			return false;
		});

		component.set('v.selectedRows', idsItems);
		component.set('v.invoiceItens', newArr);
	},

	handleSelectReason: function(component, row){
		component.set('v.reasonValues', []);
		component.set('v.reasonContext', row);

		const availableReasons = row.contestationOptions;

		let newReasons = [];
		const allReasons = component.get('v.reasonValuesOriginal');
		console.log('row -> ', JSON.parse(JSON.stringify(row)));
		console.log('allReasons', JSON.parse(JSON.stringify(allReasons)));
		console.log('availableReasons', JSON.parse(JSON.stringify(availableReasons)));

		newReasons = allReasons.filter(x => {
			return x.partnerId == row.idParceiro;
		});

		console.log('newReasons -> ', JSON.parse(JSON.stringify(newReasons)));

		let fixedReasons = [];

		for (let i = 0; i < newReasons.length; i++) {
			const reason = newReasons[i];
			
			for (let j = 0; j < availableReasons.length; j++) {
				const avReason = availableReasons[j];
				
				if(parseInt(reason.value) == avReason)
					fixedReasons.push(reason);
			}
		}

		console.log('fixedReasons -> ', JSON.parse(JSON.stringify(fixedReasons)));

		component.set('v.reasonValues', fixedReasons);
		component.find('reasonModal').open();
	},

	getContestationOptons: function(component){
		component.set('v.isLoading', true);

		let action = component.get('c.getContestationOptions');
        action.setCallback(this, function(response){
            var state = response.getState();
			var data = response.getReturnValue();
            
            if(state === 'SUCCESS'){
                component.set('v.reasonValuesOriginal', data);
            }else if(state === 'ERROR'){
                var errors = response.getError();
                if(errors[0] && errors[0].message){
                    this.showToast('Erro', errors[0].message, 'error');
                    component.set('v.errorOnCall', true);
                }     
            }
            
            component.set('v.isLoading', false);
        });
		$A.enqueueAction(action);
	}

})