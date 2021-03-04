/*
 
* Autor: Diego Lima - Deloitte
* Data: 01/08/2019
* Descricao: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 9] + [Recurso estatico de controle de 
* exibicao dos icones dos componentes da pagina CEC_CTI_ControlSoftphone]

* Controle de Versao
* ---------------------------------------------------------------
* Data: 01/08/2019
* Autor: Diego Lima - Deloitte
* Alteracoes: [US 19333 - Solicitar ramal avaya]: Criacao das funcoes do recurso estatico
* ---------------------------------------------------------------
* Data: 02/09/2019
* Autor: Diego Lima - Deloitte
* Alteracoes: [US 18680 - Transferencia]: Criacao das funcoes de transfer�ncia
* ---------------------------------------------------------------
* Data: 12/09/2019
* Autor: Eduardo Marques - Deloitte
* Alteracoes: [US 15416 - Conferencia]: Desabilitar icones de limpar campo telefone
*/

//HABILITAR OU DESABILITAR AS FUNCOES DO COMPONENTE DO FOOTER (CEC_CTI_DefaultSoftphoneHeader)

function disableAllFooterIcons(){
    footerDeactivateHome();
    footerDeactivateExternalCall();
    footerDeactivateScheduling();
    footerDeactivateTransfer();
    footerDeactivateConference();
}

function disableAllCallAtionsIcons(){
    callActionActivateOffHold();
    callActionsDeactivateEndCall();
    callActionsDeactivateMute();
}


//ICONE DE PAUSA
function headerActivatePause(){
    $('.icon-pause.inactive').addClass('display-none');
    $('.icon-pause.active').removeClass('display-none');
}

function headerDeactivatePause(){
    $('.icon-pause.active').addClass('display-none');
    $('.icon-pause.inactive').removeClass('display-none');
}

//ICONE DE NOTIFICAO
function headerActivateNotification(){
    $('.icon-bell.inactive').addClass('display-none');
    $('.icon-bell.active').removeClass('display-none');
}

function headerDeactivateNotification(){
    $('.icon-bell.active').addClass('display-none');
    $('.icon-bell.inactive').removeClass('display-none');
}

//INPUT DO NUMERO DO CLIENTE, E ICONES PARA APAGAR UM OU TODOS OS DIGITOS
function headerDeactivateCallOptions(){
    $('.number-input').attr('readonly', true);
    $('.number-input').attr('disabled', true);
    $('.number-input').css('cursor', 'default');
    $('.delete-number-actions').addClass('display-none');
}

function headerActivateCallOptions(){
    $('.number-input').attr('readonly', false);
    $('.number-input').attr('disabled', false);
    $('.number-input').css('cursor', 'text');
    $('.delete-number-actions').removeClass('display-none');
}


//HABILITAR OU DESABILITAR AS FUNCOES DO COMPONENTE DO FOOTER (CEC_CTI_CallActions)

//ICONE DA CHAMADA EM ESPERA
function callActionsActiveHold(){
    setTimeout(function (){
    $('.wait.inactive').addClass('display-none');
    $('.wait.off').addClass('display-none');
    $('.wait.active').removeClass('display-none');
    }, 1200);
}

function callActionsActivateHold(){
    console.log('habilitar checkHoldCall = ' + checkHoldCall);
    if(checkHoldCall == true){
        setTimeout(function (){
            $('.wait.active').addClass('display-none');
            $('.wait.off').addClass('display-none');
            $('.wait.inactive').removeClass('display-none');
        }, 1200);
    }
}

function callActionActivateOffHold(){
    setTimeout(function (){
        $('.wait.active').addClass('display-none');
        $('.wait.inactive').addClass('display-none');
        $('.wait.off').removeClass('display-none');
    }, 1200);
}

//ICONE DE ATENDER A LIGACAO
function callActionsActivateStartCall(){
    
    $('.end-call.inactive').addClass('display-none');
    $('.end-call.active').addClass('display-none');
    $('.end-call-connecting.active').addClass('display-none');
    
    if(checkConferenceIconClicked){
        $('.start-call.normal-call.active').addClass('display-none');
        $('.start-call.conference.active').removeClass('display-none');
    } else {
        $('.start-call.conference.active').addClass('display-none');
        $('.start-call.normal-call.active').removeClass('display-none');
   }     
}

function callActionsActivateEndCall(){
    console.log('habilitar botao de desligar (checkFinishCall) = ' + checkFinishCall);
    console.log('habilitar botao de desligar (callFromSalesforce) = ' + callFromSalesforce);
    if(checkFinishCall == true || callFromSalesforce  == true){
        
        setTimeout(function (){
            $('.start-call.active').addClass('display-none');
            $('.end-call.inactive').addClass('display-none');
            $('.end-call-connecting.active').addClass('display-none');
            $('.end-call.active').removeClass('display-none');
        }, 2000);
    }
}

function callActionsActivateEndCallConnecting(){
    console.log('habilitar botao de desligar (checkFinishCall) = ' + checkFinishCall);
    console.log('habilitar botao de desligar (callFromSalesforce) = ' + callFromSalesforce);
    if(checkFinishCall == true || callFromSalesforce  == true){
        
        setTimeout(function (){
            $('.start-call.active').addClass('display-none');
            $('.end-call.inactive').addClass('display-none'); 
            $('.end-call.active').addClass('display-none');
            $('.end-call-connecting.active').removeClass('display-none');
        }, 2000);
    }
}

function callActionsDeactivateEndCall(){
    $('.start-call.active').addClass('display-none');
    $('.end-call.active').addClass('display-none');
    $('.end-call-connecting.active').addClass('display-none');
    $('.end-call.inactive').removeClass('display-none');
}

//ICONE DE LIGACAO NO MUDO
function callActionsActivateMute(){
    $('.mute.inactive').addClass('display-none');
    $('.mute.active').removeClass('display-none');
}

function callActionsDeactivateMute(){
    $('.mute.active').addClass('display-none');
    $('.mute.inactive').removeClass('display-none');
}

//HABILITAR OU DESABILITAR AS FUNCOES DO COMPONENTE DO FOOTER (CEC_CTI_DefaultSoftphoneFooter)

//ICONE DA HOME
function footerActivateHome(){
    $('.home.inactive').addClass('display-none');
    $('.home.current-page').addClass('display-none');
    $('.home.active').removeClass('display-none');
}

function footerDeactivateHome(){
    $('.home.active').addClass('display-none');
    $('.home.current-page').addClass('display-none');
    $('.home.inactive').removeClass('display-none');
}

function footerActivateHomeActive(){
    $('.home.inactive').addClass('display-none');
    $('.home.active').addClass('display-none');
    $('.home.current-page').removeClass('display-none');
}    

//ICONE DE LIGACAO EXTERNA
function footerActivateExternalCall(){
    if(checkExternalCall == true){
        $('.external-call.inactive').addClass('display-none');
        $('.external-call.current-page').addClass('display-none');
        $('.external-call.active').removeClass('display-none');
        footerActivateScheduling();
    } else{
        footerDeactivateExternalCall();
    }
} 

function footerDeactivateExternalCall(){
    $('.external-call.active').addClass('display-none');
    $('.external-call.current-page').addClass('display-none');
    $('.external-call.inactive').removeClass('display-none');
} 

function footerActivateExternalCallActive(){
    $('.external-call.active').addClass('display-none');
    $('.external-call.inactive').addClass('display-none');
    $('.external-call.current-page').removeClass('display-none');
}



//ICONE DO AGENDAMENTO
function footerActivateScheduling(){
    if(checkExternalCall == true){
        $('.scheduling.inactive').addClass('display-none');
        $('.scheduling.current-page').addClass('display-none');
        $('.scheduling.active').removeClass('display-none');
    }
} 

function footerDeactivateScheduling(){
    $('.scheduling.active').addClass('display-none');
    $('.scheduling.current-page').addClass('display-none');
    $('.scheduling.inactive').removeClass('display-none');
} 

function footerActivateSchedulingActive(){
    $('.scheduling.active').addClass('display-none');
    $('.scheduling.inactive').addClass('display-none');
    $('.scheduling.current-page').removeClass('display-none');
}

//ICONE DA TRANSFERENCIA
function footerActivateTransfer(){
    if(checkTransferCall == true){
        $('.transfer.inactive').addClass('display-none');
        $('.transfer.current-page').addClass('display-none');
        $('.transfer.active').removeClass('display-none');
    }
}   

function footerDeactivateTransfer(){
    $('.transfer.active').addClass('display-none');
    $('.transfer.current-page').addClass('display-none');
    $('.transfer.inactive').removeClass('display-none');
}   

function footerActivateTransferActive(){
    $('.transfer.active').addClass('display-none');
    $('.transfer.inactive').addClass('display-none');
    $('.transfer.current-page').removeClass('display-none');
}

//ICONE DA CONFERENCIA
function footerActivateConference(){
    if(checkConference == true && checkExternalCall == true){
        $('.conference.inactive').addClass('display-none');
        $('.conference.current-page').addClass('display-none');
        $('.conference.active').removeClass('display-none');
    }
}

function footerDeactivateConference(){
    $('.conference.active').addClass('display-none');
    $('.conference.current-page').addClass('display-none');
    $('.conference.inactive').removeClass('display-none');
}

function footerActivateConferenceActive(){
    $('.conference.active').addClass('display-none');
    $('.conference.inactive').addClass('display-none');
    $('.conference.current-page').removeClass('display-none');
    if(checkConference == true && checkExternalCall == true){
        $('.delete-number-actions.telefone-header2').addClass('display-none');
        $('.number-input.telefone-header2').attr('readonly', true);
    }
}