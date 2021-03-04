({
    // Função para esconder uma seção ao clicar em outro elemento (como um header/label)
    toggleVisibilidadeSecao: function(cmp, headerName) {
        var query = 'secao' + headerName;
        var queryHeader = 'header' + headerName;
        var header = document.getElementById(queryHeader);
        var element = document.querySelectorAll(`div[id^=${query}]`);
        
        if(element.length != 0){
            for (var i=0 ; i < element.length ; i++){
                $A.util.toggleClass(element[i], "slds-hide");
            }
        }
        if (header) {
            $A.util.toggleClass(header, "active");
        }
        
        return null;
    },
    getLogisticaJSON : function(cmp) {
        return '{"data":{"tipoEntrega":"Logística","resumoDadosCliente":{"dadosEmpresa":{"razaoSocial":"Empresa Algo","cnpj":"10.000.000/0001-00","inscricaoEstadual":"100.000.000.000","inscricaoEstadualIsento":false,"inscricaoMunicipal":"200.000.000.000","inscricaoMunicipalIsento":false,"cnaePrimario":"1000","cnaeSecundario":"1000/0","numeroFuncionarios":"Até 10 (Pequena Empresa)","tipoEmpresa":"Empresa de pequeno porte","segmentoComercial":"Televendas AACE","dataVencimentoFatura":"10","possuiServicos":[{"nome":"NET","valor":false},{"nome":"Embratel","valor":false}],"numeroContrato":"999/12345678912345"},"enderecoPrincipal":{"cep":"01001-001","endereco":"Praça da Sé","logradouro":"Avenida","numero":68,"complemento":"Praça","bairro":"Sé","cidade":"São Paulo","uf":"SP"},"enderecoCobranca":{"cep":"01001-001","endereco":"Praça da Sé","logradouro":"Avenida","numero":70,"complemento":"Praça","bairro":"Sé","cidade":"São Paulo","uf":"SP"},"recebedor":{"recebedores":[{"nomeCompleto":"João Cleber Zuera","rg":"12.345.678-X","telefone":"11 4000-0000","celular":"11 99000-0000"},{"nomeCompleto":"Pesosnilda Santos","rg":"01.234.567-8","telefone":"11 4100-0000","celular":"11 99100-0000"}]},"contatosAdministrador":[{"nomeCompleto":"Adailton Pires","sexo":"M","nascimento":"01/01/1981","telefone":"11 4300-0000","celular":"11 99300-0000","email":"adailtonpires@email.com","representante":true,"cargo":"Rei das vendas"},{"nomeCompleto":"Chernobira Gomes","sexo":"F","nascimento":"02/02/1982","telefone":"11 4400-0000","celular":"11 99400-0000","email":"chernobiragomes@email.com","representante":false,"cargo":""},{"nomeCompleto":"Cronossauro Alves","sexo":"M","nascimento":"03/03/1983","telefone":"11 4500-0000","celular":"11 99500-0000","email":"cronossauroalves@email.com","representante":false,"cargo":""}]},"resumoPedido":{"linhas":13,"servicos":265086,"aparelhos":4,"equipamentos":1442900,"pontosAcumulados":1871,"pontosUtilizados":1000,"pontosSaldo":871,"planos":[{"tipoPlano":"Claro Total Compartilhado","tipo":"Transferência","regional":"BA/SE","uf":"BA","ddd":71,"qtdLinha":5,"grupo":1,"total":1000000,"grupos":[{"ddd":79,"linhas":5,"grupo":1,"produtos":[{"nome":"Celular","dados":"","valor":55863},{"nome":"Passaporte America 10GB","dados":"10GB","valor":27930},{"nome":"Passaporte Europa 10GB","dados":"10GB","valor":27993}]}],"produtos":[{"nome":"Franquia","dados":"70GB","valor":1000000},{"nome":"Gestor Online","dados":"70GB","valor":1000000},{"nome":"Backup Online","dados":"70GB","valor":1000000}],"equipamentos":[{"equipamento":"AP 3G SAMSUNG GALAXY NOTE N7000 PRETO","quantidade":2,"pontosUtilizados":140,"faixaUtilizada":"","valor":150000},{"equipamento":"AP 3G MOTOROLA PRETO","quantidade":2,"pontosUtilizados":"","faixaUtilizada":"80GB","valor":135000},{"equipamento":"Simcard Aparelho","quantidade":4,"pontosUtilizados":"","faixaUtilizada":"","valor":0},{"equipamento":"Simcard Avulso","quantidade":5,"pontosUtilizados":"","faixaUtilizada":"","valor":50}]},{"tipoPlano":"Claro Total Individual","tipo":"Novo","regional":"BA/SE","uf":"BA","ddd":71,"qtdLinha":6,"grupo":2,"total":1000000,"grupos":[],"produtos":[{"nome":"Franquia","dados":"70GB","valor":1000000},{"nome":"Passaporte América 10GB","dados":"10GB","valor":27990},{"nome":"Passaporte Europa 10GB","dados":"10GB","valor":27930}],"equipamentos":[{"equipamento":"AP 3G SAMSUNG GALAXY NOTE N7000 PRETO","quantidade":2,"pontosUtilizados":100,"faixaUtilizada":"","valor":250000},{"equipamento":"Simcard Aparelho","quantidade":2,"pontosUtilizados":"","faixaUtilizada":"","valor":0},{"equipamento":"Simcard Avulso","quantidade":4,"pontosUtilizados":"","faixaUtilizada":"","valor":50}]}]},"associacaoAparelhos":{"sessao":{"regional":"BA/SE","uf":"BA","ddd":"71","franquia":"70GB","qtdLinha":"7","tipoNovo":{"itens":[{"linha":"","modelo":"AP 3G SAMSUNG GALAXY NOTE N7000 PRETO","iccid":12345678900,"imei":12345678900,"cor":"PRETO","cores":"--"},{"linha":"","modelo":"AP 3G SAMSUNG GALAXY NOTE N7000 PRETO","iccid":12345678900,"imei":12345678900,"cor":"PRETO","cores":"--"}]},"tipoTransferencia":{"doadores":[{"nome":"doador um algo","cpf":"123.123.123-12","telefone":"11 91234-1234","email":"doador@um.algo","itens":[{"linha":"77 97777-7777","modelo":"AP 3G SAMSUNG GALAXY NOTE N7000 PRETO","iccid":12345678900,"imei":12345678900,"cor":"PRETO","cores":"Não"},{"linha":"66 96666-6666","modelo":"AP 3G SAMSUNG GALAXY NOTE N7000 PRETO","iccid":12345678900,"imei":12345678900,"cor":"PRETO","cores":"Não"}]},{"nome":"doador dois algo","cpf":"456.456.456-45","telefone":"11 94567-4567","email":"doador@dois.algo","itens":[{"linha":"55 95555-5555","modelo":"AP 3G SAMSUNG GALAXY NOTE N7000 PRETO","iccid":12345678900,"imei":12345678900,"cor":"PRETO","cores":"Azul, Branco"},{"linha":"44 94444-4444","modelo":"AP 3G SAMSUNG GALAXY NOTE N7000 PRETO","iccid":12345678900,"imei":12345678900,"cor":"PRETO","cores":"Não"}]}]},"tipoPortabilidade":{"itens":[{"linha":"99 99999-9999","modelo":"AP 3G SAMSUNG GALAXY NOTE N7000 PRETO","iccid":12345678900,"imei":12345678900,"cor":"PRETO","cores":"Não","operadora":"OI"},{"linha":"88 98888-8888","modelo":"AP 3G SAMSUNG GALAXY NOTE N7000 PRETO","iccid":12345678900,"imei":12345678900,"cor":"PRETO","cores":"Branco, Azul, Vermelho","operadora":"Vivo"}]}}}}}';
    },
    //carrega as informações vindas do server
    loadOrderId: function(cmp) {
        //inicia o spinner
        //cmp.set('v.isLoading', true);
        //pegar o parâmetro da URL
        let urlString = window.location.href;
        let url = new URL(urlString);
        let param = url.searchParams.get('id');

        console.log(param);
        
        //server side action
        var action = cmp.get("c.load");
        action.setParams( {
            //'idPedido' : '8012C0000005bjQQAQ' // Individual #1
            //'idPedido' : '8012C0000005aeeQAA' // Compartilhado #1
            //'idPedido' : '8012C0000005c4sQAA' // Compartilhado #2
            //'idPedido' : '8012C0000005c57QAA' //Individual = Compartilhado Novo + Port
            'idPedido' : param
        } ); 

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.pedido", response.getReturnValue());
                console.log("JSON >>> " + JSON.stringify(cmp.get("v.pedido")));
                console.table(cmp.get("v.pedido"));
            }
            else {
                var errors = response.getError();
                for (let i=0; i<errors.length;i++) { console.table(errors[i]); }
                if (!errors) { console.log("Unknown error"); }
            }
        });
        $A.enqueueAction(action);
    }
})