({
	initialLoad: function (component) {
		Promise.all([this.setTipoPessoa(component), this.setTipoConta(component), this.setBancoReembolso(component), this.setMotivoReembolso(component)])
			.then((resolve) => {
				const contextBill = component.get("v.bill");
				console.log("contextBill ", JSON.parse(JSON.stringify(contextBill)));

				if (!contextBill.contestation || !contextBill.contestation.reembolso) return;

				const reembolso = JSON.parse(contextBill.contestation.reembolso);
				console.log("reembolso -> ", reembolso);

				component.set("v.pessoa", reembolso.paymentForm.pessoa);
				component.set("v.layoutTipoPessoaFisica", reembolso.paymentForm.pessoa == "Pessoa Física");
				component.set("v.nomeTitular", reembolso.paymentForm.nomeTitular);
				component.set("v.cpf", reembolso.paymentForm.cpf);
				component.set("v.cnpj", reembolso.paymentForm.cnpj);
				component.set("v.motivoReemb", reembolso.paymentForm.motivoReemb);
				component.set("v.reembDobro", reembolso.paymentForm.reembDobro == "Sim");
				if (reembolso.paymentForm.tel1) {
					const firstTel = reembolso.paymentForm.tel1;
					component.set("v.ddd", firstTel.substring(0, 2));
					component.set("v.telefone", firstTel.substring(2, firstTel.length));
				}
				if (reembolso.paymentForm.tel2) {
					const secondTel = reembolso.paymentForm.tel2;
					component.set("v.ddd2", secondTel.substring(0, 2));
					component.set("v.telefone2", secondTel.substring(2, secondTel.length));
				}
				component.set("v.dddSMS", reembolso.dddSMS);
				component.set("v.telefoneSMS", reembolso.telefoneSMS);
				component.set("v.vencimentoFatura", reembolso.paymentForm.vencimentoFatura);
				component.set("v.email", reembolso.paymentForm.email);
				component.set("v.descricao", reembolso.paymentForm.descricao);

				//REEMBOLSO CC
				component.set("v.titular", reembolso.paymentForm.titular);
				component.set("v.banco", reembolso.paymentForm.banco);
				component.set("v.agencia", reembolso.paymentForm.agencia);
				component.set("v.conta", reembolso.paymentForm.conta);
				component.set("v.digito", reembolso.paymentForm.digito);
			})
			.catch((err) => {
				this.showToast("Erro", "Não foi possivel carregar os dados", "error");
				console.log("Erro em alguma promise", err);
			});
	},

	setTipoPessoa: function (component, event, callback) {
		return new Promise(function (resolve, reject) {
			let action = component.get("c.getPickListTipoPessoa");
			action.setCallback(this, function (response) {
				var lista = response.getReturnValue();
				var x;
				var position = 0;
				var items = [];
				for (x of lista) {
					var item = {
						label: "" + lista.slice(position, position + 1) + "",
						value: "" + lista.slice(position, position + 1) + ""
					};
					items.push(item);
					position++;
				}
				component.set("v.tipoPessoa", items);
				console.log("setTipoPessoa OK");
				resolve();
			});
			$A.enqueueAction(action);
		});
	},

	setTipoConta: function (component, event, callback) {
		return new Promise(function (resolve, reject) {
			let action = component.get("c.getPickListConta");
			action.setCallback(this, function (response) {
				var lista = response.getReturnValue();
				var x;
				var position = 0;
				var items = [];
				for (x of lista) {
					var item = {
						label: "" + lista.slice(position, position + 1) + "",
						value: "" + lista.slice(position, position + 1) + ""
					};
					items.push(item);
					position++;
				}
				component.set("v.tipoConta", items);
				console.log("setTipoConta OK");
				resolve();
			});
			$A.enqueueAction(action);
		});
	},

	setBancoReembolso: function (component, event, callback) {
		return new Promise(function (resolve, reject) {
			let action = component.get("c.getPickListBanco");
			action.setCallback(this, function (response) {
				var lista = response.getReturnValue();
				var x;
				var position = 0;
				var items = [];
				for (x of lista) {
					var item = {
						label: "" + lista.slice(position, position + 1) + "",
						value: "" + lista.slice(position, position + 1) + ""
					};
					items.push(item);
					position++;
				}
				component.set("v.bancoReembolso", items);
				console.log("setBancoReembolso OK");
				resolve();
			});
			$A.enqueueAction(action);
		});
	},

	setMotivoReembolso: function (component, event, callback) {
		return new Promise(function (resolve, reject) {
			let action = component.get("c.getPickListMotivo");
			action.setCallback(this, function (response) {
				var lista = response.getReturnValue();
				var x;
				var position = 0;
				var items = [];
				for (x of lista) {
					var item = {
						label: "" + lista.slice(position, position + 1) + "",
						value: "" + lista.slice(position, position + 1) + ""
					};
					items.push(item);
					position++;
				}
				component.set("v.motivoReembolso", items);
				console.log("setMotivoReembolso OK");
				resolve();
			});
			$A.enqueueAction(action);
		});
	},

	//MÃ‰TODO PARA POST DE REEMBOLSO
	postRefund: function (component, invoice, callback) {
		var genInfoMaker = this.createStringInfoMaker(component);
		var reembDobro = component.get("v.reembDobro");
		if (reembDobro == true) {
			var reembDobroStr = "Sim";
		} else {
			var reembDobroStr = "Não";
		}
		var reembolsoCC = component.get("v.refundcc");
		var telephone1 = component.get("v.ddd") + component.get("v.telefone");
		var telephone2 = component.get("v.ddd2") + component.get("v.telefone2");
		if (reembolsoCC == true) {
			var refundWrp = {
				refundType: "CC",
				titular: component.get("v.titular"), //String
				agencia: component.get("v.agencia"), //Integer
				conta: component.get("v.conta"), //Integer
				digito: component.get("v.digito"), //Integer
				nomeTitular: component.get("v.nomeTitular"), //String
				banco: component.get("v.banco"), //String
				motivoReemb: component.get("v.motivoReemb"), //String
				reembDobro: reembDobroStr, //Boolean to string
				descricao: component.get("v.descricao"), //String
				pessoa: component.get("v.pessoa"), //String
				email: component.get("v.email"), //String
				vencimentoFatura: component.get("v.vencimentoFatura"), //Date
				cpf: component.get("v.cpf"), //Integer
				cnpj: component.get("v.cnpj"), //Integer
				tel1: telephone1,
				tel2: telephone2
			};
		} else {
			var refundWrp = {
				refundType: "OP",
				nomeTitular: component.get("v.nomeTitular"), //String
				motivoReemb: component.get("v.motivoReemb"), //String
				reembDobro: reembDobroStr, //Boolean to string
				descricao: component.get("v.descricao"), //String
				pessoa: component.get("v.pessoa"), //String
				email: component.get("v.email"), //String
				vencimentoFatura: component.get("v.vencimentoFatura"), //Date
				cpf: component.get("v.cpf"), //Integer
				cnpj: component.get("v.cnpj"), //Integer
				tel1: telephone1,
				tel2: telephone2
			};
		}

		console.log("@@@REFUNDWRP" + refundWrp);

		const hasAuth = component.get("v.hasAuthority");
		if (hasAuth) {
			let action = component.get("c.postInvoiceRefund");
			action.setParams({
				areaCode: component.get("v.ddd"),
				contractNumber: component.get("v.contractId"),
				name: component.get("v.nomeTitular"),
				infoMaker: genInfoMaker,
				operatorCode: component.get("v.operatorId"),
				phone: component.get("v.telefone"),
				recordId: component.get("v.recordId"),
				paymentForm: refundWrp
			});
			action.setCallback(this, function (response) {
				const state = response.getState();
				const data = response.getReturnValue();
				if (state === "SUCCESS") {
					if (data.success) {
						component.set("v.title", $A.get("$Label.c.Fin_send_title_success"));
						component.set("v.typeIcon", "utility:success");
						component.set("v.typeVariant", "success");
						component.set("v.message", $A.get("$Label.c.Reembolso_Message_Success"));
						component.set("v.showButton1", true);
						component.set("v.showButton2", true);
						component.set("v.dialogModal", true);
						component.set("v.dialogModal", true);
						component.set("v.showButtonX", false);
						component.set("v.showSecond", true);
						component.find("modalMessage").open();
					} else {
						component.set("v.title", $A.get("$Label.c.Fin_send_title_error"));
						component.set("v.typeIcon", "utility:warning");
						component.set("v.typeVariant", "error");
						component.set("v.message", $A.get("$Label.c.Reembolso_Message_Error"));
						component.set("v.dialogModal", true);
						component.find("modalMessage").open();
					}
				} else if (state === "ERROR") {
					component.set("v.title", "Alerta:");
					component.set("v.typeIcon", "utility:warning");
					component.set("v.typeVariant", "warning");
					component.set("v.message", $A.get("$Label.c.Reembolso_Message_Error"));
					component.set("v.dialogModal", true);
					component.find("modalMessage").open();

					var errors = response.getError();
					console.log("Errors -> ", errors);

					if (errors[0] && errors[0].message) {
						component.set("v.message", errors[0].message);
					}
				}
			});
			$A.enqueueAction(action);
		} else {
			const postParams = {
				areaCode: component.get("v.ddd"),
				contractNumber: component.get("v.contractId"),
				name: component.get("v.nomeTitular"),
				infoMaker: genInfoMaker,
				operatorCode: component.get("v.operatorId"),
				phone: component.get("v.telefone"),
				recordId: component.get("v.recordId"),
				paymentForm: refundWrp,
				dddSMS: component.get("v.dddSMS"),
				telefoneSMS: component.get("v.telefoneSMS")
			};

			let action = component.get("c.saveDuplicateField");
			action.setParams({
				refundSerialized: JSON.stringify(postParams),
				caseId: component.get("v.caseId")
			});
			action.setCallback(this, function (response) {
				const state = response.getState();

				if (state === "SUCCESS") {
					component.set("v.title", "Reembolso salvo");
					component.set("v.typeIcon", "utility:success");
					component.set("v.typeVariant", "success");
					component.set("v.message", "Reembolso salvo para o analista N2");
					component.set("v.showButton1", true);
					component.set("v.showButton2", true);
					component.set("v.dialogModal", true);
					component.set("v.dialogModal", true);
					component.set("v.showButtonX", false);
					component.set("v.showSecond", true);
					component.find("modalMessage").open();
				} else if (state === "ERROR") {
					var errors = response.getError();
					if (errors[0] && errors[0].message) {
						this.showToast("Erro", errors[0].message, "error");
						component.set("v.errorOnCall", true);
					}
				}
			});
			$A.enqueueAction(action);
		}
	},

	createStringInfoMaker: function (component, event, helper) {
		let bankCode = new Map();
		bankCode.set("Banco ABC Brasil S.A.", "246");
		bankCode.set("Banco Alfa S.A.", "025");
		bankCode.set("Banco Alvorada S.A.", "641");
		bankCode.set("Banco Banestado S.A.", "038");
		bankCode.set("Banco Barclays S.A.", "740");
		bankCode.set("Banco BBM S.A.", "107");
		bankCode.set("Banco Beg S.A.", "031");
		bankCode.set("Banco BM&F de Serviços de Liquidação e Custódia S.A", "096");
		bankCode.set("Banco BNP Paribas Brasil S.A.", "752");
		bankCode.set("Banco Boavista Interatlântico S.A.", "248");
		bankCode.set("Banco Brascan S.A.", "225");
		bankCode.set("Banco BVA S.A.", "044");
		bankCode.set("Banco Cacique S.A.", "263");
		bankCode.set("Banco Calyon Brasil S.A.", "222");
		bankCode.set("Banco Cargill S.A.", "040");
		bankCode.set("Banco Comercial e de Investimento Sudameris S.A.", "215");
		bankCode.set("Banco Cooperativo do Brasil S.A. - BANCOOB", "756");
		bankCode.set("Banco Cooperativo Sicredi S.A.", "748");
		bankCode.set("Banco Credit Suisse (Brasil) S.A.", "505");
		bankCode.set("Banco Cruzeiro do Sul", "229");
		bankCode.set("Banco da Amazônia S.A.", "003");
		bankCode.set("Banco Daycoval S.A.", "707");
		bankCode.set("Banco de Pernambuco S.A. - BANDEPE", "024");
		bankCode.set("Banco de Tokyo-Mitsubishi UFJ Brasil S.A.", "456");
		bankCode.set("Banco Dibens S.A.", "214");
		bankCode.set("Banco do Brasil", "001");
		bankCode.set("Banco do Estado de Santa Catarina S.A.", "027");
		bankCode.set("Banco do Estado de Sergipe S.A.", "047");
		bankCode.set("Banco do Estado do Pará S.A.", "037");
		bankCode.set("Banco do Nordeste do Brasil S.A.", "004");
		bankCode.set("Banco Fator S.A.", "265");
		bankCode.set("Banco Fibra S.A.", "224");
		bankCode.set("Banco Ficsa S.A.", "626");
		bankCode.set("Banco Finasa S.A.", "175");
		bankCode.set("Banco Fininvest S.A.", "252");
		bankCode.set("Banco GE Capital S.A.", "233");
		bankCode.set("Banco Gerdau S.A.", "734");
		bankCode.set("Banco Guanabara S.A.", "612");
		bankCode.set("Banco Ibi S.A. Banco Múltiplo", "063");
		bankCode.set("Banco Industrial do Brasil S.A.", "604");
		bankCode.set("Banco Industrial e Comercial S.A.", "320");
		bankCode.set("Banco Indusval S.A.", "653");
		bankCode.set("BANCO INTER", "077");
		bankCode.set("Banco Intercap S.A.", "630");
		bankCode.set("Banco J. P. Morgan S.A.", "376");
		bankCode.set("Banco J. Safra S.A.", "074");
		bankCode.set("Banco Luso Brasileiro S.A.", "600");
		bankCode.set("Banco Mercantil do Brasil S.A.", "389");
		bankCode.set("Banco Merrill Lynch de Investimentos S.A.", "755");
		bankCode.set("Banco Opportunity S.A.", "045");
		bankCode.set("BANCO ORIGINAL S.A.", "212");
		bankCode.set("Banco Panamericano S.A.", "623");
		bankCode.set("Banco Paulista S.A.", "611");
		bankCode.set("Banco Pine S.A.", "643");
		bankCode.set("Banco Prosper S.A.", "638");
		bankCode.set("Banco Rabobank International Brasil S.A.", "747");
		bankCode.set("Banco Rendimento S.A.", "633");
		bankCode.set("Banco Rural Mais S.A.", "072");
		bankCode.set("Banco Rural S.A.", "453");
		bankCode.set("Banco Safra S.A.", "422");
		bankCode.set("Banco Schahin S.A.", "250");
		bankCode.set("Banco Simples S.A.", "749");
		bankCode.set("Banco Société Générale Brasil S.A.", "366");
		bankCode.set("Banco Sofisa S.A.", "637");
		bankCode.set("Banco Sumitomo Mitsui Brasileiro S.A.", "464");
		bankCode.set("Banco Triângulo S.A.", "634");
		bankCode.set("Banco UBS Pactual S.A.", "208");
		bankCode.set("Banco Único S.A.", "116");
		bankCode.set("Banco Votorantim S.A.", "655");
		bankCode.set("Banco VR S.A.", "610");
		bankCode.set("Banco WestLB do Brasil S.A.", "370");
		bankCode.set("BANESTES S.A. Banco do Estado do Espírito Santo", "021");
		bankCode.set("Banif-Banco Internacional do Funchal (Brasil)S.A.", "719");
		bankCode.set("Bankpar Banco Multiplo S.A..", "204");
		bankCode.set("Banrisul", "041");
		bankCode.set("BB Banco Popular do Brasil S.A.", "073");
		bankCode.set("BPN Brasil Banco Mútiplo S.A.", "069");
		bankCode.set("BRB - Banco de Brasília S.A.", "070");
		bankCode.set("Caixa Econômica Federal", "104");
		bankCode.set("Citibank", "745");
		bankCode.set("Deutsche Bank S.A. - Banco Alemão", "487");
		bankCode.set("Dresdner Bank Brasil S.A. - Banco Múltiplo", "751");
		bankCode.set("Hipercard Banco Múltiplo S.A.", "062");
		bankCode.set("ING Bank N.V.", "492");
		bankCode.set("Itaú", "341");
		bankCode.set("JPMorgan Chase Bank", "488");
		bankCode.set("NuBank", "260");
		bankCode.set("Ordem de Pagamento", "000");
		bankCode.set("Santander", "033");
		bankCode.set("Unibanco", "409");
		bankCode.set("Unicard Banco Múltiplo S.A.", "230");
		bankCode.set("Bradesco", "237");

		var doubleRefund = component.get("v.reembDobro");
		if (doubleRefund == true) {
			var doubleRefundStr = "REEMBOLSO EM DOBRO_SIM";
		} else {
			var doubleRefundStr = "REEMBOLSO EM DOBRO_NÃƒO";
		}
		var nomeTitular = component.get("v.nomeTitular") === undefined ? "" : component.get("v.nomeTitular").toUpperCase();
		var cpf = component.get("v.cpf") === undefined ? "" : component.get("v.cpf");
		var cnpj = component.get("v.cnpj") === undefined ? "" : component.get("v.cnpj");
		var banco = bankCode.get(component.get("v.banco"));
		var agencia = component.get("v.agencia") === undefined ? "" : component.get("v.agencia");
		var conta = component.get("v.conta") === undefined ? "" : component.get("v.conta");
		var digito = component.get("v.digito") === undefined ? "" : component.get("v.digito");
		var motivoReemb = component.get("v.motivoReemb") === undefined ? "" : component.get("v.motivoReemb").toUpperCase();
		var reembDobro = component.get("v.reembDobro") === undefined ? "" : doubleRefundStr;
		var ddd = component.get("v.ddd") === undefined ? "" : component.get("v.ddd");
		var telefone = component.get("v.telefone") === undefined ? "" : component.get("v.telefone");
		var ddd2 = component.get("v.ddd2") === undefined ? "" : component.get("v.ddd2");
		var telefone2 = component.get("v.telefone2") === undefined ? "" : component.get("v.telefone2");
		var dddSMS = component.get("v.dddSMS") === undefined ? "" : component.get("v.dddSMS");
		var telefoneSMS = component.get("v.telefoneSMS") === undefined ? "" : component.get("v.telefoneSMS");
		var descricao = component.get("v.descricao") === undefined ? "" : component.get("v.descricao").toUpperCase();
		var email = component.get("v.email") === undefined ? "" : component.get("v.email");

		var formattedDate = component.get("v.vencimentoFatura").split("-");
		var vencimentoFatura = formattedDate[2] + "/" + formattedDate[1] + "/" + formattedDate[0];

		if (component.get("v.pessoa") == "Pessoa Física") {
			var pessoa = "PESSOA_FISICA";
			var docNumb = cpf;
		} else {
			var pessoa = "PESSOA_JURIDICA";
			var docNumb = cnpj;
		}

		if (component.get("v.titular") == "Cliente NET") {
			var titular = "CLIENTE";
		} else {
			var titular = "TERCEIRO";
		}

		//OP#PESSOA_JURIDICA#BRUNO RAFAEL RAMOS DE MATTOS#18745792000199#DESCONEXÃƒO POR OPÃ‡ÃƒO#REEMBOLSO EM DOBRO_SIM#TESTE 123#19-36038372#11-9999999#16-8888888#BRUNO.MATTOS@GMAIL.COM#08/08/2020 - 08/08/2020 - 08/08/2020 - 08/08/2020 - 08/08/2020 - 08/08/2020#
		var outputCC =
			"CC" +
			"#" +
			pessoa +
			"#" +
			titular +
			"#" +
			nomeTitular +
			"#" +
			docNumb +
			"#" +
			banco +
			"#" +
			agencia +
			"#" +
			conta +
			"#" +
			digito +
			"#" +
			motivoReemb +
			"#" +
			reembDobro +
			"#" +
			descricao +
			"#" +
			ddd +
			"-" +
			telefone +
			"#" +
			ddd2 +
			"-" +
			telefone2 +
			"#" +
			dddSMS +
			"-" +
			telefoneSMS +
			"#" +
			email +
			"#" +
			vencimentoFatura +
			" - - - - - #";
		console.log("outputCC", outputCC);

		var outputOP =
			"OP" +
			"#" +
			pessoa +
			"#" +
			titular +
			"#" +
			nomeTitular +
			"#" +
			docNumb +
			"#" +
			motivoReemb +
			"#" +
			reembDobro +
			"#" +
			descricao +
			"#" +
			ddd +
			"-" +
			telefone +
			"#" +
			ddd2 +
			"-" +
			telefone2 +
			"#" +
			dddSMS +
			"-" +
			telefoneSMS +
			"#" +
			email +
			"#" +
			vencimentoFatura +
			" - - - - - #";
		console.log("outputOP", outputOP);

		if (component.get("v.layoutReembolsoCC") == true) {
			var infoMaker = outputCC;
		} else {
			var infoMaker = outputOP;
		}
		return infoMaker;
	}
});