/*
* Autor: Squad Canais Criticos
* Data: 18/09/2020
* Description: Teste da classe que realiza a carga do objeto CustomerBureau__c
* ---------------------------------------------------------------
*/
@IsTest
public without sharing class CEC_CC_CargaDadosOrgaoRegulatorioTest {
    @IsTest
    public static void testCarga() {
        
         String csv = 

         'Nome do órgão;Tipo de retorno principal (Se é E-mail, Telefone, Carta ou Site);Telefones;Site;E-mails;Nome do órgão principal (no caso de uma sub-unidade);CEPdoendereço;Logradouro do endereço;Número;Bairro;Cidade;Estado;Complemento;Tipo\r\n'+
         'CEJUSC MACEIO;E-MAIL;(82) 98802-3591;https://www.tjal.jus.br/;;;57015-090;Rua Humberto Santa Cruz;355;Vergel do Lago ;Maceió;AL;BASE COMUNITÁRIA DA PM NO VERGEL DO LAGO;CEJUSC\r\n'+
         'CEJUSC MACEIÓ- COMUNIDADE ESPÍRITA NOSSO LAR;E-MAIL;;https://www.tjal.jus.br/;; CEJUSC MACEIO;57015-582;Avenida Sen. Rui Palmeira;481;Vergel do Lago;Maceió;AL;;CEJUSC\r\n'+
         'CEJUSC SÃO PAULO;E-MAIL;(11) 3397-7032 ;http://www.tjsp.jus.br/;cejuscmunicipal@outlook.com;;;Avenida Liberdade;103;Bairro Liberdade;São Paulo;SP;CENTRAL – PREFEITURA DE SÃO PAULO;CEJUSC\r\n'+
         'POSTO AVANÇADO DE CONCILIAÇÃO PRÉ-PROCESSUAL – SIMPI;E-MAIL; (11) 3897-8404;http://www.tjsp.jus.br/;cejusc.central@tjsp.jus.br; CEJUSC SÃO PAULO;;Rua DR Fabricio Vampré;70;V. Mariana;São Paulo;SP;;CEJUSC';
        
         CEC_CC_CargaDadosOrgaoRegulatorio.run(csv,false);
    } 
}