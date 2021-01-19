/*
* Autor: Diego Lima - Deloitte
* Data: 23/05/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 6] + [Classe utilizada como Wrapper da classe
* CEC_CTI_DispAttendanceControler]
* 
* Controle de Versão
* ---------------------------------------------------------------
* Data: 17/07/2019
* Autor: Diego Lima - Deloitte
* Alterações: [US 18682 - Solicitar ramal Avaya] Criação das variáveis ramal e siteId
* ---------------------------------------------------------------
* Data: 19/07/2019
* Autor: Thamires Siman - Deloitte
* Alterações: [US 18156 - Realizar Ligações Externas Avaya] Inclusão da varável ligacaoExterna
* ---------------------------------------------------------------
* Data: 20/08/2019
* Autor: Diego Lima - Deloitte
* Alterações: [US 18680 - Realizar Transferência de Chamada] Inclusão da varável transferenciaChamada
* ---------------------------------------------------------------
* Data: 04/09/2019
* Autor: Diego Lima - Deloitte
* Alterações: [US 15412 - Espera de Chamada] Inclusão da varável chamadaEspera
* Alterações: [US 18154 - Desligar chamada] Inclusão da varável finalizarChamada
* ---------------------------------------------------------------
* Data: 10/09/2019
* Autor: Eduardo Marques - Deloitte
* Alterações: [US US15416 - Habilitar conferência] Inclusão da varável conferenciaChamada
* ---------------------------------------------------------------
* Data: 15/10/2019
* Autor: Wanderson Viena - Deloitte
* Alterações: [US 32422 - Enriquecer os dados de telefonia da URA] Inclusão da varável TipoDocumento
*----------------------------------------------------------------
* Data: 17/10/2019
* Autor: André Salgado - Claro
* Alterações: [US 32422 - Enriquecer os dados de telefonia da URA] Adequação para inclusão das classes genérica Data, Customer, Driver e URA para
* novo formato de Json para Huawei EXT1 com novo construtor CEC_CTI_SoftPhoneWrapper(DateCTI dateCTI) que realiza o mapping do json.
* Inclusão de metodo convertTimeStampString para ajuste do timeStamp para o controle do tempo da chamada da Ponta A(Cliente)
*----------------------------------------------------------------
* Data: 30/07/2020
* Autor: Wanderson Viena - Deloitte
* Alterações: [92254 - CTI - CRM CROSS - PROTOCOLO URA RESIDENCIAL + 92255 CTI - CRM CROSS - PROTOCOLO URA MÓVEL + 
* 92248 CTI - CRM CROSS - SCRIPT POINT NAVEGAÇÃO URA RESIDENCIAL] enriquecendo a CEC_CTI_SoftPhoneWrapper para gravar os campos nomeCliente,
* tipoDocumento, numeroDocumento, phoneNumber, postcode, scriptPoint, TicketIVR,
*/

global class CEC_CTI_SoftPhoneWrapper {

    //Informações da chamada
    public String numeroTelefone {get; set;}
    public String nomeCliente {get; set;}
    public String tipoDocumento {get; set;}
    public String numeroDocumento {get; set;}
    public String inicioChamadaDriver {get; set;}
    public String urlReturned {get; set;} //URL da página a ser aberta com esta ligação
    public String encryptValue {get; set;}
    public String phoneNumber {get; set;}
    public Boolean docIsCPF {get; set;}
    public Boolean docIsNull {get;set;}
    public String skillId {get;set;}
    public String vdnOrigin {get;set;}
    public String mpl{get;set;}
    public String postcode {get; set;}
    public String scriptPointCode {get; set;}
    public String ticketIVR {get; set;}
    
    public String codigoNet {get;set;}
    public String codCidade {get;set;}
    public String protocolo {get;set;}
    public String idExterno {get;set;}


    public String idExternoContrato {get;set;}
    public String idCustomerInteraction{get;set;}


    //Adição de campos TU29
    public String serviceType {get; set;}
    public String serviceSubType {get; set;}
    public String financialSituation {get; set;}
    public String invoiceLateDays {get; set;}
    public String isMovelType {get; set;}
    public String isNet {get; set;}
    public String scriptPointDetail {get; set;}
    public String lastAccessedSystem {get; set;}
    public String systemResponse {get; set;}
    
    //Informações de inicialização
    public String mensagemErro {get; set;}
    public String ramal {get; set;}
    public String siteId {get; set;}
       
    //Permissões
    public Boolean ligacaoExterna {get; set;}
    public Boolean transferenciaChamada {get; set;}
    public Boolean chamadaEspera {get; set;}
    public Boolean finalizarChamada {get; set;}
    public Boolean conferenciaChamada {get; set;}
    
    public DateCTI dateCTI {get; set;}
    
    public CEC_CTI_SoftPhoneWrapper(){
    }

    //INICIO TESTE    
    public CEC_CTI_SoftPhoneWrapper(DateCTI dateCTI){
        numeroTelefone = dateCTI.ura.ANI;
        nomeCliente = dateCTI.customer.customerName;
        tipoDocumento = dateCTI.customer.TaxIdentificationType;
        numeroDocumento = dateCTI.customer.TaxIdentificationNumber;
        skillId = dateCTI.driver.realSkill;
        vdnOrigin = dateCTI.ura.vdnOrigin;
        mpl = dateCTI.ura.MPL;
        encryptValue = dateCTI.toString();
        postcode=dateCTI.customer.postcode;
        idCustomerInteraction = '';
        scriptPointCode=dateCTI.customer.scriptPoint;
        //inicioChamadaDriver = dateCTI.ura.timeStamp;
		//## formata a data para o padrao esperado dd/mm/yyyy hh:mm:ss 
        inicioChamadaDriver = convertTimeStampString(dateCTI.driver.timeStamp);
        
        codigoNet = dateCTI.customer.customerAccountId;

        idExternoContrato = String.isNotBlank(dateCTI.customer.customerAccountId)?transformContractNumber(dateCTI.customer.customerAccountId):'';
        System.debug('condigoNet: ' + codigoNet);
        codCidade = dateCTI.customer.cityId;
        protocolo = dateCTI.customer.protocolNumber;
        idExterno = dateCTI.customer.TaxIdentificationType + dateCTI.customer.TaxIdentificationNumber;

        //Adição de campos TU29
        serviceType = dateCTI.customer.serviceType;
        serviceSubType = dateCTI.customer.serviceSubType;
        financialSituation = dateCTI.customer.financialSituation;
        invoiceLateDays = dateCTI.customer.invoiceLateDays;
        isMovelType = dateCTI.customer.isMovelType;
        isNet = dateCTI.customer.isNet;
        scriptPointDetail = dateCTI.customer.scriptPointDetail;
        lastAccessedSystem = dateCTI.customer.lastAccessedSystem;
        systemResponse = dateCTI.customer.systemResponse;
    }
    
    private String convertTimeStampString(String dtAux){
        String ano, mes, dia, hr, min, seg = '';
        String dt3;
        ano = dtAux.substring(0, 4);
        mes = dtAux.substring(4, 6);
        dia = dtAux.substring(6, 8);
        hr  = dtAux.substring(8, 10);
        min = dtAux.substring(10, 12);
        seg = dtAux.substring(12, 14);
        
        dt3 = dia + '/' + mes + '/' + ano + ' ' + hr + ':' + min  + ':' + seg;
        return dt3;
    }
    
    private String transformContractNumber(String strContractNum){
        String a = strContractNum.substring(0,3);
        String b = strContractNum.substring(3,strContractNum.length());

        String ab = a+'/'+b;
        return ab;
    }
    
    global class DateCTI{
       private CustomerDate customer;
       private URA ura;
       private Driver driver;
    }
    
    class URA {
        public String timeStamp {get; set;}
        public String callId {get; set;}
        public String ANI {get; set;}
        public String channelOrigin {get; set;}
        public String vdnOrigin {get; set;}
        public String vdnDestiny {get; set;}
        public String idDestiny {get; set;}
        public String skillDestiny {get; set;}
        public String MPL {get; set;}
        public String scriptPoint {get; set;}
        public String ivrFlow {get; set;}
        public String ivrInstance {get; set;}
        public String ivrHost {get; set;}
        public String ivriP {get; set;}
        public String ivrChannel {get; set;}
    }
    
    class Driver {
        public String siteId {get; set;}
        public String realSkill {get; set;}
        public String timeStamp {get; set;}
    }
    
    class CustomerDate{    
        public String customerAccountId {get; set;}
        public String customerName {get; set;}
        public String ANI {get; set;}
        public String MCDU {get; set;}
        public String UUI {get; set;}
        public String postcode {get; set;}
        public String streetNr {get; set;}
        public String partyIdentificationType {get; set;}
        public String partyIdentificationNumber {get; set;}
        public String IDDNIS {get; set;}
        public String cityId {get; set;}
        public String segmentCepNumCpf {get; set;}
        public String scriptPoint {get; set;}
        public String protocolNumber {get; set;}
        public String MCDUType {get; set;}
        public String status {get; set;}
        public String segment {get; set;}
        public String callId {get; set;}
        public String callsTodayIVR {get; set;}
        public String originCity {get; set;}
        public String callsThisMonthIVR {get; set;}
        public String previousContactIVR {get; set;}
        public String IDTypeIVR {get; set;}
        public String ANIMethodId {get; set;}
        public String serviceOffered {get; set;}
        public String serviceParams {get; set;}
        public String telephoneNumber {get; set;}
        public String Rg {get;set;}
        public String TaxIdentificationType {get;set;}
        public String TaxIdentificationNumber {get;set;}
        public String AutomationCall {get;set;}
        

        //Adição de campos TU29
        public String serviceType {get; set;}
        public String serviceSubType {get; set;}
        public String financialSituation {get; set;}
        public String invoiceLateDays {get; set;}
        public String isMovelType {get; set;}
        public String isNet {get; set;}
        public String scriptPointDetail {get; set;}
        public String lastAccessedSystem {get; set;}
        public String systemResponse {get; set;}
    }
}