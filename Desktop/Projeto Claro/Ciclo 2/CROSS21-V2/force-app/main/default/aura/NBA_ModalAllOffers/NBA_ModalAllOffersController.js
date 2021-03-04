({
	resetIconAnimation: function (component){
		component.set('v.resetIconAnimation', false);
		component.set('v.resetIconAnimation', true);
	},
	
	showAllOffers: function (component, event, helper) {
		component.set('v.showSpinner', true);
		helper.consultarPerfilRetencao(component, helper);
		var isRetencao = component.get('v.isRetencao');
		component.set('v.showAllOffers', true);
		helper.saveClickSelectOffer(component, event);
		helper.getAllOffers(component, event);
		component.set('v.columns', [
			{ label: 'Perfil da Oferta', fieldName: 'offerProfile', type: 'text' },
			{ label: 'TV', fieldName: 'tv', type: 'text' },
			{ label: 'Movimento TV', fieldName: 'tvDif', type: 'text' },
			{ label: 'Virtua', fieldName: 'virtua', type: 'text' },
			{ label: 'Movimento Virtua', fieldName: 'virtuaDif', type: 'text' },
			{ label: 'Móvel', fieldName: 'movel', type: 'text' },
			{ label: 'Movimento Móvel', fieldName: 'movelDif', type: 'text' },
			{ label: 'Net Phone', fieldName: 'netPhone', type: 'text' },
			{ label: 'Movimento Net Phone', fieldName: 'netPhoneDif', type: 'text' },
			{ label: 'Preço', fieldName: 'price', type: 'text' },
			{ label: 'Variação $', fieldName: 'priceDif', type: 'text' }
		]);
	},

	detailTv: function (component, event, helper) {
		window.open('http://novofiqueligado/produtoseservicos/nettv/Selecoes.ashx');
	},

	detailBroadband: function (component, event, helper) {
		window.open('http://novofiqueligado/produtoseservicos/netvirtua/velocidades.ashx');
	},

	getCancelOffers:function(component, event, helper) {
		component.set('v.showSpinner', true);
		component.set('v.showCancelOffers', true);
		helper.getAllOffers(component, event);
	},

	closeAllOffersModal: function (component, event, helper) {
		component.set('v.showAllOffers', false);
	},

	chooseOffer: function (component, event, helper) {
		var selectedOfferPriority = event.currentTarget.id;
		var selectedOfferIndex = 0;
		var offersList = component.get('v.offersList'); 

		for (var i=0; i<offersList.data.recommendations.length; i++)
			if(offersList.data.recommendations[i].priority == selectedOfferPriority)
				selectedOfferIndex = i;
		var offerToChangeIndex = 2;

		offersList.data.recommendations = helper.arrayMove(offersList.data.recommendations, selectedOfferIndex, offerToChangeIndex);
		for (var i=0; i<offersList.data.recommendations.length; i++)
			offersList.data.recommendations[i].priority = (i+1).toString();
		localStorage['JSONOffers' + component.get('v.caseId') ] = JSON.stringify(offersList);

		helper.resetConfigActions(component, offersList); // retorna lista de ofertas para offerComparator
		helper.calculateOriginalValueOferta(component); // retorna oferta selecionada para offerCOmparator

		component.set('v.showAllOffers', false);
	},

	orderColumnByProfile: function (component, event, helper) {
		var offerObj = component.get('v.ofertas');
		var listOffers = offerObj.data.recommendations;
		if (component.get('v.sortType').includes('Descendent') || component.get('v.sortType') === 'Neutral') {
					
			listOffers.sort(function (a, b) {
				var aa = a.profile ? a.profile.toLowerCase() : 0;
				var bb = b.profile ? b.profile.toLowerCase() : 0;
				if (aa < bb) return -1;
				if (aa > bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Ascendent_Profile');
		} else {
			//var offerObj = component.get('v.ofertas');
			//var listOffers = offerObj.data.recommendations;
			listOffers.sort(function (a, b) {
				var aa = a.profile ? a.profile.toLowerCase() : 0;
				var bb = b.profile ? b.profile.toLowerCase() : 0;
				if (aa > bb) return -1;
				if (aa < bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Descendent_Profile');
		}
	},

	orderColumnByType: function (component, event, helper) {
		var offerObj = component.get('v.ofertas');
			var listOffers = offerObj.data.recommendations;
		if (component.get('v.sortType').includes('Descendent') || component.get('v.sortType') === 'Neutral') {
				listOffers.sort(function (a, b) {
				var aa = a.type ? a.type.toLowerCase() : 0;
				var bb = b.type ? b.type.toLowerCase() : 0;
				if (aa < bb) return -1;
				if (aa > bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Ascendent_Type');
		} else {			
			listOffers.sort(function (a, b) {
				var aa = a.type ? a.type.toLowerCase() : 0;
				var bb = b.type ? b.type.toLowerCase() : 0;
				if (aa > bb) return -1;
				if (aa < bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Descendent_Type');
		}
	},

	orderColumnByTV: function (component, event, helper) {
		var offerObj = component.get('v.ofertas');
		var listOffers = offerObj.data.recommendations;

		if (component.get('v.sortType').includes('Descendent') || component.get('v.sortType') === 'Neutral') {
			
			listOffers.sort(function (a, b) {
                var aa = a.nboTv !== null && a.nboTv.length > 0 ? a.nboTv[0].name : 0;
				var bb = b.nboTv !== null && b.nboTv.length > 0 ? b.nboTv[0].name : 0;
				if (aa < bb) return -1;
				if (aa > bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Ascendent_TV');
		} else {
			
			listOffers.sort(function (a, b) {
				var aa = a.nboTv !== null && a.nboTv.length > 0 ? a.nboTv[0].name : 0;
				var bb = b.nboTv !== null && b.nboTv.length > 0 ? b.nboTv[0].name : 0;
				if (aa > bb) return -1;
				if (aa < bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Descendent_TV');
		}
	},

	orderColumnByVirtua: function (component, event, helper) {
		var offerObj = component.get('v.ofertas');
		var listOffers = offerObj.data.recommendations;

		if (component.get('v.sortType').includes('Descendent') || component.get('v.sortType') === 'Neutral') {
			
			listOffers.sort(function (a, b) {
				var aa = a.nboBroadband!=null && !isNaN(a.nboBroadband.speed) ? Number(a.nboBroadband.speed) : (a.nboBroadband.name=='MANTER' ? -1 : 0);
				var bb = b.nboBroadband!=null && !isNaN(b.nboBroadband.speed) ? Number(b.nboBroadband.speed) : (b.nboBroadband.name=='MANTER' ? -1 : 0);
				if (aa < bb) return -1;
				if (aa > bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Ascendent_Virtua');
		} else {
			
			listOffers.sort(function (a, b) {
				var aa = a.nboBroadband!=null && !isNaN(a.nboBroadband.speed) ? Number(a.nboBroadband.speed) : (a.nboBroadband.name=='MANTER' ? -1 : 0);
				var bb = b.nboBroadband!=null && !isNaN(b.nboBroadband.speed) ? Number(b.nboBroadband.speed) : (b.nboBroadband.name=='MANTER' ? -1 : 0);
				if (aa > bb) return -1;
				if (aa < bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Descendent_Virtua');
		}
	},

	orderColumnByMobileNetPhone: function (component, event, helper) {
		var offerObj = component.get('v.ofertas');
		var listOffers = offerObj.data.recommendations;
		if (component.get('v.sortType').includes('Descendent') || component.get('v.sortType') === 'Neutral') {
			
			listOffers.sort(function (a, b) {
                var aa = a.nboMobile !== null  && a.nboMobile.length > 0 ? a.nboMobile[0].name : 0;
				var bb = b.nboMobile !== null  && b.nboMobile.length > 0 ? b.nboMobile[0].name : 0;
				if (aa < bb) return -1;
				if (aa > bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Ascendent_Mobile');
		} else {
			
			listOffers.sort(function (a, b) {
				var aa = a.nboMobile !== null && a.nboMobile.length > 0 ? a.nboMobile[0].name : 0;
				var bb = b.nboMobile !== null && b.nboMobile.length > 0 ? b.nboMobile[0].name : 0;
				if (aa > bb) return -1;
				if (aa < bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Descendent_Mobile');
		}
	},

	orderColumnByNetPhone: function (component, event, helper) {
		var offerObj = component.get('v.ofertas');
		var listOffers = offerObj.data.recommendations;
		if (component.get('v.sortType').includes('Descendent') || component.get('v.sortType') === 'Neutral') {
			
			listOffers.sort(function (a, b) {
                var aa = a.nboPhone !== null ? a.nboPhone.name : 0;
				var bb = b.nboPhone !== null ? b.nboPhone.name : 0;
				if (aa < bb) return -1;
				if (aa > bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Ascendent_Phone');
		} else {
			
			listOffers.sort(function (a, b) {
				var aa = a.nboPhone !== null ? a.nboPhone.name : 0;
				var bb = b.nboPhone !== null ? b.nboPhone.name : 0;
				if (aa > bb) return -1;
				if (aa < bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Descendent_Phone');
		}
	},

	orderColumnByMovimentTV: function (component, event, helper) {
		var offerObj = component.get('v.ofertas');
		var listOffers = offerObj.data.recommendations;
		if (component.get('v.sortType').includes('Descendent') || component.get('v.sortType') === 'Neutral') {
			
			listOffers.sort(function (a, b) {
				var aa = a.actionTv;
				var bb = b.actionTv;
				if (aa < bb) return -1;
				if (aa > bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Ascendent_MovimentTV');
		} else {
			
			listOffers.sort(function (a, b) {
				var aa = a.actionTv;
				var bb = b.actionTv;
				if (aa > bb) return -1;
				if (aa < bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Descendent_MovimentTV');
		}
	},

	orderColumnByMovimentVirtua: function (component, event, helper) {
		var offerObj = component.get('v.ofertas');
		var listOffers = offerObj.data.recommendations;
		if (component.get('v.sortType').includes('Descendent') || component.get('v.sortType') === 'Neutral') {
			listOffers.sort(function (a, b) {
				var aa = a.actionBroadband;
				var bb = b.actionBroadband;
				if (aa < bb) return -1;
				if (aa > bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Ascendent_MovimentVirtua');
		} else {
			
			listOffers.sort(function (a, b) {
				var aa = a.actionBroadband;
				var bb = b.actionBroadband;
				if (aa > bb) return -1;
				if (aa < bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Descendent_MovimentVirtua');
		}
	},

	orderColumnByMovimentMobileNetPhone: function (component, event, helper) {
		var offerObj = component.get('v.ofertas');
		var listOffers = offerObj.data.recommendations;
		if (component.get('v.sortType').includes('Descendent') || component.get('v.sortType') === 'Neutral') {
			
			listOffers.sort(function (a, b) {
				var aa = a.actionMobile;
				var bb = b.actionMobile;
				if (aa < bb) return -1;
				if (aa > bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Ascendent_MovimentMobile');
		} else {
			
			listOffers.sort(function (a, b) {
				var aa = a.actionMobile;
				var bb = b.actionMobile;
				if (aa > bb) return -1;
				if (aa < bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Descendent_MovimentMobile');
		}
	},

	orderColumnByMovimentNetPhone: function (component, event, helper) {
		var offerObj = component.get('v.ofertas');
		var listOffers = offerObj.data.recommendations;
		if (component.get('v.sortType').includes('Descendent') || component.get('v.sortType') === 'Neutral') {
			
			listOffers.sort(function (a, b) {
				var aa = a.actionPhone;
				var bb = b.actionPhone;
				if (aa < bb) return -1;
				if (aa > bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Ascendent_MovimentPhone');
		} else {
			listOffers.sort(function (a, b) {
				var aa = a.actionPhone;
				var bb = b.actionPhone;
				if (aa > bb) return -1;
				if (aa < bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Descendent_MovimentPhone');
		}
	},

	orderColumnByPrice: function (component, event, helper) {
		var offerObj = component.get('v.ofertas');
		var listOffers = offerObj.data.recommendations;
		if (component.get('v.sortType').includes('Descendent') || component.get('v.sortType') === 'Neutral') {
			
			listOffers.sort(function (a, b) {
				var aa = a.totalValue ? a.totalValue : 0;
				var bb = b.totalValue ? b.totalValue : 0;
				if (aa < bb) return -1;
				if (aa > bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Ascendent_Price');
		} else {
			
			listOffers.sort(function (a, b) {
				var aa = a.totalValue ? a.totalValue : 0;
				var bb = b.totalValue ? b.totalValue : 0;
				if (aa > bb) return -1;
				if (aa < bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Descendent_Price');
		}
	},

	orderColumnByPoints: function (component, event, helper) {
		var offerObj = component.get('v.ofertas');
		var listOffers = offerObj.data.recommendations;
		if (component.get('v.sortType').includes('Descendent') || component.get('v.sortType') === 'Neutral') {
			
			listOffers.sort(function (a, b) {
				var aa = a.rewardPoints ? parseInt(a.rewardPoints) : 0;
				var bb = b.rewardPoints ? parseInt(b.rewardPoints) : 0;
				if (aa < bb) return -1;
				if (aa > bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Ascendent_Points');
		} else {
			
			listOffers.sort(function (a, b) {
				var aa = a.rewardPoints ? parseInt(a.rewardPoints) : 0;
				var bb = b.rewardPoints ? parseInt(b.rewardPoints) : 0;
				if (aa > bb) return -1;
				if (aa < bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Descendent_Points');
		}
	},

	orderColumnByExpensesVariation: function (component, event, helper) {
		var offerObj = component.get('v.ofertas');
		var listOffers = offerObj.data.recommendations;
		if (component.get('v.sortType').includes('Descendent') || component.get('v.sortType') === 'Neutral') {
			
			listOffers.sort(function (a, b) {
				var aa = a.variation ? a.variation : 0;
				var bb = b.variation ? b.variation : 0;
				if (aa < bb) return -1;
				if (aa > bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Ascendent_ExpensesVariation');
		} else {
			
			listOffers.sort(function (a, b) {
				var aa = a.variation ? a.variation : 0;
				var bb = b.variation ? b.variation : 0;
				if (aa > bb) return -1;
				if (aa < bb) return 1;
				return 0;
			});
			offerObj.data.recommendations = listOffers;
			component.set('v.ofertas', offerObj);
			component.set('v.sortType', 'Descendent_ExpensesVariation');
		}
	},

	filterBy: function (component, event, helper) {

		var offerObj = JSON.parse(localStorage['JSONOffers' + component.get('v.caseId')]);
		var profile = component.find("searchPerfil").get("v.value");
		var type = component.find("searchType").get("v.value");
		var points = component.find("searchPoints") ? component.find("searchPoints").get("v.value") : null;

		points = points ? helper.removerAcento(points) : '';
		var TV = component.find("searchLikeTV").get("v.value");
		TV = TV ? helper.removerAcento(TV) : '';
		var movimentTV = component.find("searchMovimentTV").get("v.value");
		var virtua = component.find("searchLikeVirtua").get("v.value");
		virtua = virtua ? helper.removerAcento(virtua) : '';
		var movimentVirtua = component.find("searchMovimentVirtua").get("v.value");
		var mobile = component.find("searchLikeMobile").get("v.value");
		mobile = mobile ? helper.removerAcento(mobile) : '';
		var movimentMobile = component.find("searchMovimentMobile").get("v.value");
		var phone = component.find("searchLikePhone").get("v.value");
		phone = phone ? helper.removerAcento(phone) : '';
		var movimentPhone = component.find("searchMovimentPhone").get("v.value");
		var listOffersToFilter = offerObj.data.recommendations;
		var newListOffers = listOffersToFilter.filter(function (offer) {
			var offerType;
			if (type === "Exclusiva") {
				offerType = offer.exclusivo;
			} else if (type === "Blindagem") {
				offerType = offer.blindagem;
			} else if (type === "Combate") {
				offerType = offer.combate;
			} else if (type === "Padrão") {
				offerType = !offer.exclusivo && !offer.combate && !offer.blindagem;
			}
			var point = offer.rewardPoints !== null ? offer.rewardPoints : null;
			var hasPoint = (point && points ? parseInt(point) === parseInt(points) : false) || !points;
			var nameTv = offer.nboTv !== null && offer.nboTv.length > 0 && offer.nboTv[0].catalogName ? offer.nboTv[0].catalogName : null;
				nameTv = nameTv == '0' ? 'SEM PLANO' : nameTv;
			let keepTv = movimentTV == 'g' ? true : false;	
			nameTv = nameTv ? helper.removerAcento(nameTv) : null;
			var hasNameTv = (nameTv && TV ? nameTv.includes(TV.toLowerCase()) : false) || !TV;
			var nameBL = offer.nboBroadband.catalogName ? offer.nboBroadband.catalogName : null;
				nameBL = nameBL == '0' ? 'SEM PLANO' : nameBL;
			let keepBL = movimentVirtua == 'g' ? true : false;	
			nameBL = nameBL ? helper.removerAcento(nameBL) : null;
			var hasNameBL = (nameBL && virtua ? nameBL.toLowerCase().includes(virtua.toLowerCase()) : false) || !virtua;
			var nameFN = offer.nboPhone.catalogName ? offer.nboPhone.catalogName : null;
				nameFN = nameFN == '0' ? 'SEM PLANO' : nameFN;
			let keepFN = movimentPhone == 'g' ? true : false;
			nameFN = nameFN ? helper.removerAcento(nameFN) : null;
			var hasNameFN = (nameFN && phone ? nameFN.toLowerCase().includes(phone.toLowerCase()) : false) || !phone;
			var nameMV = offer.nboMobile !== null && offer.nboMobile.length > 0 && offer.nboMobile[0].name ? offer.nboMobile[0].name : offer.nboMobile !== null && offer.nboMobile.length > 0 && offer.nboMobile[0].name == null ? 'SEM PLANO' : null;			
				nameMV = nameMV == '0' ? 'SEM PLANO' : nameMV;
			let keepMV = movimentMobile == 'g' ? true : false;
			nameMV = nameMV ? helper.removerAcento(nameMV) : null;
			var hasNameMV = (nameMV && mobile ? nameMV.toLowerCase().includes(mobile.toLowerCase()) : false) || !mobile;
			return ((offer.profile === profile || !profile) && (offerType || !type) && hasPoint &&
				hasNameTv && (offer.actionTv === movimentTV || !movimentTV || (keepTv && offer.nboTv[0].catalogName == 'MANTER')) && 
				hasNameBL && (offer.actionBroadband === movimentVirtua || !movimentVirtua || (keepBL && offer.nboBroadband.catalogName == 'MANTER')) &&
				hasNameMV && (offer.actionMobile === movimentMobile || !movimentMobile || (keepMV && offer.nboMobile[0].name == 'MANTER')) &&
				hasNameFN && (offer.actionPhone === movimentPhone || !movimentPhone || (keepFN && offer.nboPhone.catalogName == 'MANTER')));
		});
		offerObj.data.recommendations = newListOffers;

		component.set('v.sortType', 'Neutral');
		component.set('v.ofertas', offerObj);
	},

	cleanFilters: function (component, event, helper) {
		component.find("searchPerfil").set("v.value", '');
		component.find("searchType").set("v.value", '');
		component.find("searchLikeTV").set("v.value", '');
		component.find("searchMovimentTV").set("v.value", '');
		component.find("searchLikeVirtua").set("v.value", '');
		component.find("searchMovimentVirtua").set("v.value", '');
		component.find("searchLikeMobile").set("v.value", '');
		component.find("searchMovimentMobile").set("v.value", '');
		component.find("searchLikePhone").set("v.value", '');
		component.find("searchMovimentPhone").set("v.value", '');

		let isRetencao = component.get('v.isRetencao');
		if (isRetencao) {
			component.find("searchPoints").set("v.value", '');
		}

		component.set('v.ofertas', JSON.parse(localStorage['JSONOffers' + component.get('v.caseId') ]));
	},

	showInput: function (component) {
		component.set('v.showInput', true);
	},

	hideInput: function (component) {
		component.set('v.showInput', false);
	}
})