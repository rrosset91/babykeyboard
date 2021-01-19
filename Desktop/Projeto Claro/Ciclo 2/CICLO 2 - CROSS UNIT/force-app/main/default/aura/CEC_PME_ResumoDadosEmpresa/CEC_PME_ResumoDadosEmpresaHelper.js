({
	loadTemporaryDadosEmpresa : function(cmp) {
        // Cria dados fictícios temporários para testar o componente
        let data = {
            "razaoSocial": "Empresa Algo",
            "cnpj": "10.000.000/0001-00",
            "inscricaoEstadual": "100.000.000.000",
            "inscricaoEstadualIsento": false,
            "inscricaoMunicipal": "200.000.000.000",
            "inscricaoMunicipalIsento": false,
            "cnaePrimario": "1000",
            "cnaeSecundario": "1000/0",
            "numeroFuncionarios": "Até 10 (Pequena Empresa)",
            "tipoEmpresa": "Empresa de pequeno porte",
            "segmentoComercial": "Televendas AACE",
            "dataVencimentoFatura": "10",
            "possuiServicos": [
                {
                    "nome": "NET",
                    "valor": false
                },
                {
                    "nome": "Embratel",
                    "valor": false
                }
            ],
            "numeroContrato": "999/12345678912345" };
        
        cmp.set("v.dadosEmpresa", data);
	}
})