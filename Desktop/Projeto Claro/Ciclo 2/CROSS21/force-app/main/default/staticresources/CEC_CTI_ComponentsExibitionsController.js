/*
 
* Autor: Diego Lima - Deloitte
* Data: 01/08/2019
* Descricao: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 9] + [Recurso estatico de controle de 
* exibicao dos componentes da pagina CEC_CTI_ControlSoftphone]

* Controle de Versao
* ---------------------------------------------------------------
* Data: 01/08/2019
* Autor: Diego Lima - Deloitte
* Alteracoes: [US 19333 - Solicitar ramal avaya]: Criacao das funcoes do recurso estatico
* ---------------------------------------------------------------
* Data: 25/10/2019
* Autor: Diego Lima - Deloitte
* Alteracoes: [US 15416 - Possibilitar conferencia]: Criacao das funcoes do recurso estatico
* para a confencia e exibicao das mudancas de tela.
*/


var loginPageActive = false;

function disableAllComponents(){
    inactiveComponentHeader1();
    inactiveComponentHeader2();
    inactiveComponentHeader3();
    inactiveComponentHeaderNumConference();
    inactiveFooter();
    inactiveDiskNumber();
    inactiveCallActions();
    inactiveGeneralContentComponents();
    inactiveConferenceDialing();
    
}

function inactiveGeneralContentComponents(){
    inactiveAvailableToAttendance();
    inactiveDiskNumber();
    inactiveAttendance();
    inactiveCallback();
    inactiveConnectingCall();
    inactiveTransferCall();
    inactiveConferenceNewCall();
    inactiveMergeConferenceCall();
    inactiveInConferenceTwoNumbers();
    inactiveScheduling();
}

function completeHeaderFields(){
    /*
    $('#inputPhoneNumber').val('111000');  
    $('#inputCustomerName').val('NOME CLIENTE');  
    $('#inputDocNumber').val('112321');  
    $('#inputSecondPhoneNumber').val('222121'); 
    */
    var completeRamalNumber = $('#inputRamalNumber').val();  
	var completePhoneNumber = $('#inputPhoneNumber').val();  
    var completeCustomerName = $('#inputCustomerName').val();  
    var completeSecondPhoneNumber = $('#inputSecondPhoneNumber').val();  
    
    setTimeout(function(){
        $('#valueRamalHeader').text(completeRamalNumber);
        $('#nameInputVisible').val(completeCustomerName);
        $('#numberInput').val(completePhoneNumber);
        $('#numberInputConference').val(completeSecondPhoneNumber);
        console.log('===== FUNCTION COMPLETEHEADERFILEDS =====')
    }, 1200);
    
}

function clearHeaderAttendanceInfos(){
    $('#numberInput').val(null);
    $('#nameInputVisible').val(null);
    $('#spanCustomerName').remove();
    $('.customer-name').removeClass('pessoa-fisica');
    $('.customer-name .img-fisica').addClass('display-none');       
    $('.customer-name').removeClass('pessoa-juridica');
    $('.customer-name .img-juridica').addClass('display-none');
    
}

function inactiveComponentHeader1(){
    $(".header-page.open-call-infos").addClass("display-none");
    setComponentHeader1(false);
}

function activeComponentHeader1(){
    $('.header-page.open-call-infos').removeClass('display-none');
    setComponentHeader1(true);
}

function completeRamal(){
    var ramalNumber = $('#inputRamalNumber').val();
    $('#valueRamalHeader').text(ramalNumber);
}

function inactiveComponentHeader2(){
    setComponentHeader2(false);
}

function activeComponentHeader2(){
    setTimeout(function (){
        setComponentHeader2(true);
    }, 0800);   
}

function inactiveComponentHeader3(){
    setComponentHeader3(false);
}

function activeComponentHeader3(){
    setComponentHeader3(true);
}

function inactiveComponentHeaderNumConference(){
    setComponentHeaderNumConference(false);
}

function activeComponentHeaderNumConference(){
    setComponentHeaderNumConference(true);
}

function inactiveDiskNumber(){
    setDiskNumber(false);
}

function activeDiskNumber(){
    setDiskNumber(true);
}

function inactiveCallActions(){
    setCallActions(false);
}

function activeCallActions(){
    setTimeout(function (){
       	setCallActions(true);
    }, 0800);
}

function inactiveFooter(){
    $(".footer-page").addClass("display-none");
    //setFooter(false);
}

function activeFooter(){
    $(".footer-page").removeClass("display-none");
    //setFooter(true); 
}

function inactiveLoginPage(){
    loginPageActive = false;
	setLoginPage(false);
}

function activeLoginPage(){
    loginPageActive = true;
    setLoginPage(true);
    showControlSoftphonePage();
}


//GENERAL CONTENT 

function showControlSoftphonePage(){
    $('#controlSoftphone').removeClass('display-none');
}

function inactiveAvailableToAttendance(){
    $('#availableAttendanceComp').addClass('display-none');
    setAvailableToAttendance(false);
}

function activeAvailableToAttendance(){
    $('#availableAttendanceComp').removeClass('display-none');
    $('.general-content').removeClass('display-none');
    setTimeout(function (){
        setAvailableToAttendance(true);
    }, 0800);
}

function inactiveAttendance(){
    $('#attendanceComp').addClass('display-none');
    setAttendance1(false);
}

function activeAttendance(){
    $('.general-content').removeClass('display-none');
    $('#attendanceComp').removeClass('display-none');
    setTimeout(function (){
        setAttendance1(true);
    }, 0800);
}

function inactiveCallback(){
    $('#callbackComp').addClass('display-none');
    setCallback(false);
}

function activeCallback(){
    $('#callbackComp').removeClass('display-none');
    setTimeout(function (){
    	setCallback(true);
    }, 0800);
}

function inactiveConnectingCall(){
    $('#connectingCallComp').addClass('display-none');
    setConnectingCall(false);
}

function activeConnectingCall(){
    $('#connectingCallComp').removeClass('display-none');
    setTimeout(function (){
    	setConnectingCall(true);
    }, 0800);   
}

function inactiveTransferCall(){
    $('#transferCallComp').addClass('display-none');
    setTransferCall(false);
}

function activeTransferCall(){
    $('#transferCallComp').removeClass('display-none');
    setTimeout(function (){
    	setTransferCall(true);
    }, 0800);   
}

function inactiveConferenceNewCall(){
    $('#conferenceNewCallComp').addClass('display-none');
    setConferenceNewCall(false);
}

function activeConferenceNewCall(){
    $('#conferenceNewCallComp').removeClass('display-none');
    setTimeout(function (){
    	setConferenceNewCall(true);
    }, 0800);
}

function inactiveMergeConferenceCall(){
    $('#mergeConferenceCallComp').addClass('display-none');
    setMergeConferenceCall(false);
}

function activeMergeConferenceCall(){
    $('.general-content').removeClass('display-none');
    $('#mergeConferenceCallComp').removeClass('display-none');
    setTimeout(function (){
    	setMergeConferenceCall(true);
    }, 0800);
}

function inactiveInConferenceTwoNumbers(){
    $('#inConferenceTwoNumbersComp').addClass('display-none');
    setInConferenceTwoNumbers(false);
}

function activeInConferenceTwoNumbers(){
    $('.general-content').removeClass('display-none');
    $('#inConferenceTwoNumbersComp').removeClass('display-none');
    setTimeout(function (){
    	setInConferenceTwoNumbers(true);
        console.log('ativou conferencia 2 numeros');
    }, 1200);
    
}

function inactiveConferenceDialing(){
    $('#conferenceDialingComp').addClass('display-none');
    setConferenceDialing(false);
}

function activeConferenceDialing(){
    $('.general-content').removeClass('display-none');
    $('#conferenceDialingComp').removeClass('display-none');
    setTimeout(function (){
    	setConferenceDialing(true);
    }, 1200);
    
}

function inactiveScheduling(){
    $('#schedulingComp').addClass('display-none');
    setScheduling(false);
}

function activeScheduling(){
    $('#schedulingComp').removeClass('display-none');
    setTimeout(function (){
    	setScheduling(true);
    }, 0800);
}
