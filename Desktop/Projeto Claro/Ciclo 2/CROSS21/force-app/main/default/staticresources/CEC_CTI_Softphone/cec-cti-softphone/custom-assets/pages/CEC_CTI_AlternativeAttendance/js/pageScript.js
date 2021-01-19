var api = getBettaDriverAPI();
var docNumber;
var pageURL;

api.onBettaDriverOpen = function(event){
    var strtype = event;     
    var today = new Date();
    var date = today.getDate()+'-'+(today.getMonth()+1)+'-'+today.getFullYear();
    var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
    var dateTime = date+' '+time;            
    
    $('.driver-datas #messages').append($('<br/><p>').text('['+dateTime+']: Driver - onBettaDriverOpen'));
    //console.log(strtype.type);
    
} 

api.onBettaDriverClose = function(event){
    var strtype = event;
    
    var today = new Date();
    var date = today.getDate()+'-'+(today.getMonth()+1)+'-'+today.getFullYear();
    var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
    var dateTime = date+' '+time;
   	$('.driver-datas #messages').append($('<br/><p>').text('['+dateTime+']: Driver - onBettaDriverClose'));
    
    //console.log(strtype.type);
    //$('#messages').append($('<li>').text(strtype.type));
} 
api.onBettaDriverError = function(event){
    var strtype = event;
    
    var today = new Date();
    var date = today.getDate()+'-'+(today.getMonth()+1)+'-'+today.getFullYear();
    var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
    var dateTime = date+' '+time; 
    $('.driver-datas #messages').append($('<br/><p>').text('['+dateTime+']: Driver - onBettaDriverError'));
    
    //console.log(strtype.type);
    //$('#messages').append($('<li>').text(strtype.type));
} 

api.onCallConnected = function(event){
    
    var today = new Date();
    var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
    var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
    var dateTime = date+' '+time;
    console.log('HORARIO -> ' + dateTime);
    //console.log('DATA => ' + event.data); 
    
    console.log("onCallConnected << ",event.type);
    console.log("onCallConnected data << ",event.data);
    //$('.customer-awaiting .customer-number').append($('h1').text(event.ani));  
    
    //screenPop(event);

    var varCrypto = event.data;
    sendVarToController(varCrypto);
	                                   
}      

api.onCallDisconnected = function(event){
    var strtype = event;
    
    var today = new Date();
    var date = today.getDate()+'-'+(today.getMonth()+1)+'-'+today.getFullYear();
    var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
    var dateTime = date+' '+time;
    $('.driver-datas #messages').append($('<br/><p>').text('['+dateTime+']: Driver - onCallDisconnected'));
    
    //console.log("onCallDisconnected << ",strtype.type);
    //$('#messages').append($('<li>').text(strtype.type));
}   
var callback = function(response) {
    if (response.success) {
        //console.log('API method call executed successfully! returnValue:', response.returnValue);
    } else { 
        //console.error('Something went wrong! Errors:', response.errors);
    }
};

function sendVarToController(varCrypto){ 
    
    Visualforce.remoting.Manager.invokeAction(
        '{!$RemoteAction.CEC_CTI_AltAttendanceController.decryptDriverData}',
        varCrypto, 
        function(result, event){
            if (event.status) {
                                                
                if(result.docIsCPF == true){
                    $('.customer-name').addClass('pessoa-fisica');
					$('.customer-name .img-fisica').removeClass('display-none');                                
                } 
                if (result.docIsCPF == false) {
                    $('.customer-name').addClass('pessoa-juridica');
                	$('.customer-name .img-juridica').removeClass('display-none');                
                }    
                
                if (result.docIsNull == true) {
                    $('.customer-name').addClass('pessoa-fisica');
                }    
                
                var today = new Date();
                var date = today.getDate()+'-'+(today.getMonth()+1)+'-'+today.getFullYear();
                var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
                var dateTime = date+' '+time;
                
                $('.driver-datas #messages').append($('<br/><p>').text('['+dateTime+']: Driver - onCallConnected'));
                $('.driver-datas #messages').append($('<br/><p style="margin-left: 15px;">').text(result.encryptValue));

                if($('.header-page.open-call-infos').hasClass('driver-data-null')){
                    $('.header-page.open-call-infos').removeClass('driver-data-null');
                    $('.customer-number').append($('<span>').text(result.numeroTelefone));
                    $('.customer-name').append($('<span>').text(result.nomeCliente));
                }
                
                docNumber = result.numeroDocumento;
                pageURL = result.urlReturned;
                screenPop(docNumber, pageURL);

            }
        },
        {escape: false}
    );
}

function screenPop(docNumber, pageURL) {
    console.log('pageURL => ' +  pageURL)
    if (pageURL != null)
    {
        //sforce.opencti.screenPop({type: sforce.opencti.SCREENPOP_TYPE.URL, params: {url: pageURL}, callback: callback  }); 
        sforce.opencti.screenPop({type: sforce.opencti.SCREENPOP_TYPE.URL, params: {url: pageURL}}); 
    }
    /*
    else
    {
        sforce.opencti.screenPop({type: sforce.opencti.SCREENPOP_TYPE.URL, params: {url:"/lightning/cmp/c__CEC_SearchAccountComponent"}, callback: callback  });                         
    }
    */
}
