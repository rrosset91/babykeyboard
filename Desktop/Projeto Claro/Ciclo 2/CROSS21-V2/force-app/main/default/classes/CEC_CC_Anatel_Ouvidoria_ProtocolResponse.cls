/**
 * ---------------------------------------------------------------
 * Data: 16/10/2020
 * Autor: Squad Anatel/Ouvidoria - Sysmap Solutions [Ello Serafim/Guilherme Cuencas]
 * Descrição: ANATEL - Classe de response para ANATEL
 * ---------------------------------------------------------------
*/
global class CEC_CC_Anatel_Ouvidoria_ProtocolResponse {
    global String statusWS;
    global String statusProtocolo;
    global String numero;
    global AtendimentoResponse atendimento;
    
    global CEC_CC_Anatel_Ouvidoria_ProtocolResponse(){
        this.statusWS = '';
        this.statusProtocolo = '';
        this.numero = '';
        this.atendimento = new AtendimentoResponse();
    }

    global class AtendimentoResponse{
        global String tipoDocumento = '';
        global String cpfCnpjConsumidor = '';
        global String dataHoraRegistro = '';
        global String prazoResposta = '';
        global String respondido = '';
        global String servicoReclamado = '';
        global String telContato = '';
    }
}