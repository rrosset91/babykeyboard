var _BettaDriver_SDK_API;
var BettaDriverWS;

/**
 * Represents the API Object.
 * @returns {BettaDriverSDK} SDK Object to make the requests
 * Version: 2.0
 */
function getBettaDriverAPI() {

    _BettaDriver_SDK_API = new BettaDriverSDK();

    if (window.addEventListener) {
        addEventListener("message", _BettaDriver_SDK_API.listener, false);
    } else {
        document.attachEvent("onmessage", _BettaDriver_SDK_API.listener);
    }
	
    return _BettaDriver_SDK_API;
}

/**
 * BettaDriverSDK Object 
 * @constructor 
 */
var BettaDriverSDK = function () {

    var guid;

    var onBettaDriverOpen;
    var onDriverOpen;
    var onBettaDriverClose;
	var onBettaDriverError;

	var blnBettaDriverWS = false;
	
	var onDriverConnect;
	var onDialExternalCall;

	var onRequestLogin;
    /**
     * Event triggered when the agent enters wrapup state
     */
    var onWrapup;
    /**
     * Event triggered when the agent enters idle state
     */
    var onIdle;
    /**
     * Event triggered when the agent enters busy state
     */
    var onBusy;
    /**
     * Event triggered when the agent enters preview state
     */
    var onPreviewing;
    /**
     * Event triggered when the agent finishes the login
     */
    var onAgentLogin;
    /**
     * Event triggered when there is an inviting for a call
     */
    var onCallInviting;
    /**
     * Event triggered when the dial operation is completed
     */
    var onDialCompleted;
    /**
     * Event triggered when there is an offering for a call
     */
    var onCallOffering;
    /**
     * Event triggered when a call is extended
     */
    var onCallExtended;
    /**
     * Event triggered when a call is connected
     */
    var onCallConnected;
    /**
     * Event triggered when a call is disconnected
     */
    var onCallDisconnected;
    /**
     * Event triggered when the agent finishes the logout
     */
    var onAgentLogout;
    /**
     * Event triggered when the agent is forced logout
     */
    var onAgentForceLogout;
    /**
     * Event triggered when is set not ready
     */
    var onSetAgentNotReady;
    /**
     * Event triggered when is set ready
     */
    var onSetAgentReady;
    /**
     * Event triggered when agent session terminates
     */
    var onCallHeld;
    /**
     * Event triggered when the wrapup times out
     */
    var onSessionWrapupTimeout;
    /**
     * Event triggered when the wrapup ends
     */
    var onSessionEndWrapup;
    /**
     * Event triggered when the search result returns
     */
    var onSearchResult;
    /**
     * Event triggered on consult completed
     */
    var onConsultCompleted;
    /**
     * Event triggered on set extension completed
     */
    var onSetExtensionCompleted;
    /**
     * Event triggered on reschedule completed
     */
    var onRescheduleCompleted;
    /**
     * Event triggered on discard completed
     */
    var onDiscardCompleted;
    /**
     * Event triggered on alternate completed
     */
    var onAlternateCompleted;
    /**
     * Event triggered on conference completed
     */
    var onConferenceCompleted;
    /**
     * Event triggered on hold completed
     */
    var onHoldCompleted;
    /**
     * Event triggered on extend completed
     */
    var onExtendCompleted;
    /**
     * Event triggered on hangup completed
     */
    var onHangupCompleted;
    /**
     * Event triggered on business outcome changed
     */
    var onBusinessOutcomeChanged;
    /**
     * Event triggered on server manager suspending
     */
    var onServerManagerSuspending;
    /**
     * Event triggered on server status changed
     */
    var onServerStatusChanged;
    /**
     * Event triggered on transfer services list completed
     */
    var onTransferServicesListCompleted;
    /**
     * Eventr triggered on a response to a api request
     */
	var onUserSessionState;
	
    var onMethodResponse;
	
	var onCallBack;
	
	var onstartCallback;
	
	var onHangup;
	
	var onRetrieve;
	
	var onHold;

	var onTransferCall;
	
	var onConsultationCall;
	
	var onDialPending;
	
	var onBlindTransfer;
	
	var onConsultationFailed;
	
	var onCallFailed;
	
	var onConsultationDisconnected;
	
	var onConsultationConnected;
	
	var onConsultationRinging;
	
	
	//Conexï¿½o com Driver de integraï¿½ï¿½o Local atravï¿½s de Web Socket
	//
		BettaDriverWS = new WebSocket('ws://localhost:8025');
	//

	// open a SECURE BettaDriverWS to the Web Socket server
	// When the BettaDriverWS is open
	BettaDriverWS.onopen = function () {
		//console.log('onBettaDriverOpen');
	};

	// when the BettaDriverWS is closed by the server
	BettaDriverWS.onclose = function () {
		//console.log('onBettaDriverClose');
		blnBettaDriverWS = false;
		var result = '{"type":"onBettaDriverClose"}';
	    result = JSON.parse(result);
        _BettaDriver_SDK_API.onBettaDriverClose(result);

	};

	// Log errors
	BettaDriverWS.onerror = function (e) {
		blnBettaDriverWS = false;
		//console.log('onBettaDriverError');
		var result = '{"type":"onBettaDriverError"}';
	    result = JSON.parse(result);
        _BettaDriver_SDK_API.onBettaDriverError(result);
	};

	// Log messages from the server
	BettaDriverWS.onmessage = function (e) {
		//console.log('Received ' + e.data);
		listener(e);
	};

	register();
	
    //-------------------------------------------------------------------------------
    // Public methods
    //-------------------------------------------------------------------------------
	//* Novas funcionalidades
    function driverConnect(siteid, numRamal, descStatus, tempCallBack) {
	
        var object = new Object();
        object.type = "driverConnect";
        object.guid = guid;

        object.siteid = siteid;
        object.numRamal = numRamal;
        object.descStatus = descStatus;
		object.tempCallBack = tempCallBack;
        sendApiRequest(object);
		
    }
	
	//-------------------------------------------------------------------------------
    // Send Id Customer Interaction
    //-------------------------------------------------------------------------------
	function sendIdCustomerInteraction(idCustomerInteraction){
        
        var object = new Object();
        object.type = "sendIdCustomerInteraction";
        object.guid = guid;

        object.idCustomerInteraction = idCustomerInteraction;
        sendApiRequest(object);
    }
	
    /**
     * Get User Session State
     */
    function getUserSessionState() {

        var object = new Object();
        object.type = "getUserSessionState";
        object.guid = guid;

        sendApiRequest(object);
		
    }
    /**
     * Login
     * @param {string} agentID
     * @param {string} password
     * @param {string} extension
     */
    function login(agentID, agentPWD, extension) {
	
        var object = new Object();
        object.type = "login";
        object.guid = guid;

        object.agentID = agentID;
        object.agentPWD = agentPWD;
        object.extension = extension;

		//console.log('Login');
		//BettaDriverWS = new WebSocket('ws://localhost:8025');
        sendApiRequest(object);
		
    }

    /**
     * Login
     * @param {string} agentID
     * @param {string} password
     * @param {string} extension
     */
    function logout() {

        var object = new Object();
        object.type = "logout";
        object.guid = guid;

		//console.log('Logout');
		
        sendApiRequest(object);
    }
	
    /**
     * Requests Wrapup to a specific Agent Session
     * @param {int} agentSessionID AgentSession ID 
     */
    function requestWrapup(agentSessionID) {

        var object = new Object();
        object.type = "requestWrapup";
        object.guid = guid;

        object.agentSessionID = agentSessionID;

        sendApiRequest(object);
    }

    /**
     * End Wrapup to a specific Agent Session
     * @param {int} agentSessionID AgentSession ID 
     */
    function endWrapup(agentSessionID) {

        var object = new Object();
        object.type = "endWrapup";
        object.guid = guid;

        object.agentSessionID = agentSessionID;

        sendApiRequest(object);
    }

    /**
     * Makes an External call
     * @param {string} toAddress Destination address
     */
    function dialExternalCall(params) {
	
		var object = new Object();
        object.type = "dialExternalCall";
        object.guid = guid;
        // pode receber um objeto ou simplesmente o numero para discagem
        object.toAddress = (params.toAddress) ? params.toAddress: params; 

        object.contratoID = (params.contratoID) ? params.contratoID : ''; 
        object.nomeCliente = (params.nomeCliente) ? params.nomeCliente : '';
        object.protocolo = (params.protocolo) ? params.protocolo : ''; 
        object.recorderID = (params.recorderID) ? params.recorderID : '';

        sendApiRequest(object);
    }		 
	
	 /**
     * Makes an Consultation call
     * @param {string} toAddress Destination address
     */
    function dialConsultationCall(toAddress) {
	
		var object = new Object();
        object.type = "dialConsultationCall";
        object.guid = guid;
        object.toAddress = toAddress;
        sendApiRequest(object);
    }	 
	
    function dialAudio(toAddress, outgoingAddress) {

        var object = new Object();
        object.type = "dialAudio";
        object.guid = guid;

        object.toAddress = toAddress;
        object.outgoingAddress = outgoingAddress;

        sendApiRequest(object);
    }
    function startCallBack() {
	
		var object = new Object();
        object.type = "startCallBack";
        object.guid = guid;
        sendApiRequest(object);
    }	
    function hangup() {
	
		var object = new Object();
        object.type = "hangup";
        object.guid = guid;
        sendApiRequest(object);
    }	

    /**
     * Makes a blind tranfer of a specific interaction
     * @param {int} interactionLegID Interaction 
     * @param {string} toAddress Destination address
     * @param {string} outgoingAddress Outgoing address
     */
    function blindTransfer(toAddress) {
        var object = new Object();
        object.type = "blindTransfer";
        object.guid = guid;
        object.toAddress = toAddress;
        sendApiRequest(object);
    }

    /**
     * Makes a tranfer of a specific interaction
     * @param {int} interactionLegID Interaction
     */
    function transfer() {
        var object = new Object();
        object.type = "transfer";
        object.guid = guid;
        sendApiRequest(object);
    }

    /**
     * Makes on hold a specific interaction
     * @param {int} interactionLegID Interaction
     */
    function hold() {
        var object = new Object();
        object.type = "hold";
        object.guid = guid;
        sendApiRequest(object);
    }

    /**
     * Alternates a specific interaction
     * @param {int} interactionLegID Interaction
     */
    function alternate(interactionLegID) {
        var object = new Object();
        object.type = "alternate";
        object.guid = guid;

        object.interactionLegID = interactionLegID;

        sendApiRequest(object);
    }

    /**
     * Creates a conference of a specific interaction
     * @param {int} interactionLegID Interaction
     */
    function conference() {
        var object = new Object();
        object.type = "conference";
        object.guid = guid;

        sendApiRequest(object);
    }

    /**
     * Retrieves a specific interaction
     * @param {int} interactionLegID Interaction
     */
    function retrieve() {
        var object = new Object();
        object.type = "retrieve";
        object.guid = guid;
        sendApiRequest(object);
    }

    /**
     * Extends with mediatype audio
     * @param {string} toAddress Destination address
     * @param {string} outgoingAddress Outgoing address
     */
    function extendAudio(toAddress, outgoingAddress) {
        var object = new Object();
        object.type = "extendAudio";
        object.guid = guid;

        object.toAddress = toAddress;
        object.outgoingAddress = outgoingAddress;

        sendApiRequest(object);
    }

    /**
     * Hangs up a specific interaction
     * @param {int} interactionLegID Interaction
     */
    function hangup() {
        var object = new Object();
        object.type = "hangup";
        object.guid = guid;
        sendApiRequest(object);
    }

    /**
     * Sets ready
     */
    function setReady() {
        var object = new Object();
        object.type = "setReady";
        object.guid = guid;

        sendApiRequest(object);
    }

    /**
     * Sets not ready
     * @param {int} reasonID Not ready reason
     */
    function setNotReady(reasonID) {
        var object = new Object();
        object.type = "setNotReady";
        object.guid = guid;

        object.reasonID = reasonID;

        sendApiRequest(object);
    }

    /**
     * Starts recording the interaction
     * @param {int} interactionLegID Interaction
     */
    function startRecord(interactionLegID) {
        var object = new Object();
        object.type = "startRecord";
        object.guid = guid;

        object.interactionLegID = interactionLegID;

        sendApiRequest(object);
    }

    /**
     * Stops recording the interaction
     * @param {int} interactionLegID Interaction
     */
    function stopRecord(interactionLegID) {
        var object = new Object();
        object.type = "stopRecord";
        object.guid = guid;

        object.interactionLegID = interactionLegID;

        sendApiRequest(object);
    }

    /**
    * Discards the contact of a specific session
    * @param {int} agentSessionID AgentSession ID 
    */
    function discardContact(agentSessionID) {
        var object = new Object();
        object.type = "discardContact";
        object.guid = guid;

        object.agentSessionID = agentSessionID;

        sendApiRequest(object);
    }

    /**
    * Reschedule a contact of a specific session
    * @param {int} agentSessionID AgentSession ID
    * @param {string} address Contact address 
    * @param {string} rescheduleDate Date to reschedule 
    * @param {bool} preferredAgent is preferred agent?
    * @param {bool} topPriority is top priority?
    * @param {int} addressTypeID Address type
    */
    function rescheduleContact(agentSessionID, address, rescheduleDate, timeZone, preferredAgent, topPriority, addressTypeID) {
        var object = new Object();
        object.type = "rescheduleContact";
        object.guid = guid;

        object.agentSessionID = agentSessionID;
        object.address = address;
        object.rescheduleDate = rescheduleDate;
        object.timeZone = timeZone;
        object.preferredAgent = preferredAgent;
        object.topPriority = topPriority;
        object.addressTypeID = addressTypeID;

        sendApiRequest(object);
    }


    /**
    * Gets business outcomes for a specific service
    * @param {int} serviceID Service 
    */
    function getBusinessOutcomes(serviceID) {
        var object = new Object();
        object.type = "getBusinessOutcomes";
        object.guid = guid;

        object.serviceID = serviceID;

        sendApiRequest(object);
    }



    /**
     * Gets key performace indicators
     */
    function getKeyPerformanceIndicators() {
        var object = new Object();
        object.type = "getKeyPerformanceIndicators";
        object.guid = guid;

        sendApiRequest(object);
    }

    //-------------------------------------------------------------------------------
    // Auxiliary methods
    //-------------------------------------------------------------------------------

    function register() {

        this.guid = guidGenerator();

        var client = new Object();
        client.type = "newClient";
        client.guid = guid;

        //sendApiRequest(client);

    }

    function guidGenerator() {
        function s4() {
            return Math.floor((1 + Math.random()) * 0x10000)
              .toString(16)
              .substring(1);
        }
        return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
          s4() + '-' + s4() + s4() + s4();
    }

    function listener(event) {
		
        //console.log("%% BettaDriverSDK  listener ", event);
		var strdata = event.data;

        if (/^[\],:{}\s]*$/.test(strdata.replace(/\\["\\\/bfnrtu]/g, '@').
            replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').
            replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {
            var result = JSON.parse(strdata);
			//console.log("%% BettaDriverSDK (2) result ", result);
            if (result.guid == guid) {
				//console.log("%% BettaDriverSDK  (3) result ", result);
                switch (result.type) {
					
                    case "onWrapup":
                        if (_BettaDriver_SDK_API.onWrapup !== undefined)
                            _BettaDriver_SDK_API.onWrapup(result);
                        break;
                    case "onIdle":
                        if (_BettaDriver_SDK_API.onIdle !== undefined)
                            _BettaDriver_SDK_API.onIdle(result);
                        break;
                    case "onBusy":
                        if (_BettaDriver_SDK_API.onBusy !== undefined)
                            _BettaDriver_SDK_API.onBusy(result);
                        break;
                    case "onPreviewing":
                        if (_BettaDriver_SDK_API.onPreviewing !== undefined)
                            _BettaDriver_SDK_API.onPreviewing(result);
                        break;
                    case "onAgentLogin":
                        if (_BettaDriver_SDK_API.onAgentLogin !== undefined)
                            _BettaDriver_SDK_API.onAgentLogin(result);
                        break;
                    case "onCallInviting":
                        if (_BettaDriver_SDK_API.onCallInviting !== undefined)
                            _BettaDriver_SDK_API.onCallInviting(result);
                        break;
                    case "onDialCompleted":
                        if (_BettaDriver_SDK_API.onDialCompleted !== undefined)
                            _BettaDriver_SDK_API.onDialCompleted(result);
                        break;
                    case "onCallOffering":
                        if (_BettaDriver_SDK_API.onCallOffering !== undefined)
                            _BettaDriver_SDK_API.onCallOffering(result);
                        break;
                    case "onCallExtended":
                        if (_BettaDriver_SDK_API.onCallExtended !== undefined)
                            _BettaDriver_SDK_API.onCallExtended(result);
                        break;
                    case "onCallConnected":
                        if (_BettaDriver_SDK_API.onCallConnected !== undefined)
                            _BettaDriver_SDK_API.onCallConnected(result);
                        break;
                    case "onCallDisconnected":
                        if (_BettaDriver_SDK_API.onCallDisconnected !== undefined)
                            _BettaDriver_SDK_API.onCallDisconnected(result);
                        break;
                    case "onAgentLogout":
                        if (_BettaDriver_SDK_API.onAgentLogout !== undefined)
                            _BettaDriver_SDK_API.onAgentLogout(result);
                        break;
                    case "onAgentForceLogout":
                        if (_BettaDriver_SDK_API.onAgentForceLogout !== undefined)
                            _BettaDriver_SDK_API.onAgentForceLogout(result);
                        break;
                    case "onSetAgentNotReady":
                        if (_BettaDriver_SDK_API.onSetAgentNotReady !== undefined)
                            _BettaDriver_SDK_API.onSetAgentNotReady(result);
                        break;
                    case "onSetAgentReady":
                        if (_BettaDriver_SDK_API.onSetAgentReady !== undefined)
                            _BettaDriver_SDK_API.onSetAgentReady(result);
                        break;
                    case "onCallHeld":
                        if (_BettaDriver_SDK_API.onCallHeld !== undefined)
                            _BettaDriver_SDK_API.onCallHeld(result);
                        break;
                    case "onSessionWrapupTimeout":
                        if (_BettaDriver_SDK_API.onSessionWrapupTimeout !== undefined)
                            _BettaDriver_SDK_API.onSessionWrapupTimeout(result);
                        break;
                    case "onSessionEndWrapup":
                        if (_BettaDriver_SDK_API.onSessionEndWrapup !== undefined)
                            _BettaDriver_SDK_API.onSessionEndWrapup(result);
                        break;
                    case "onSearchResult":
                        if (_BettaDriver_SDK_API.onSearchResult !== undefined)
                            _BettaDriver_SDK_API.onSearchResult(result);
                        break;
                    case "onConsultCompleted":
                        if (_BettaDriver_SDK_API.onConsultCompleted !== undefined)
                            _BettaDriver_SDK_API.onConsultCompleted(result);
                        break;
                    case "onSetExtensionCompleted":
                        if (_BettaDriver_SDK_API.onSetExtensionCompleted !== undefined)
                            _BettaDriver_SDK_API.onSetExtensionCompleted(result);
                        break;
                    case "onRescheduleCompleted":
                        if (_BettaDriver_SDK_API.onRescheduleCompleted !== undefined)
                            _BettaDriver_SDK_API.onRescheduleCompleted(result);
                        break;
                    case "onDiscardCompleted":
                        if (_BettaDriver_SDK_API.onDiscardCompleted !== undefined)
                            _BettaDriver_SDK_API.onDiscardCompleted(result);
                        break;
                    case "onAlternateCompleted":
                        if (_BettaDriver_SDK_API.onAlternateCompleted !== undefined)
                            _BettaDriver_SDK_API.onAlternateCompleted(result);
                        break;
                    case "onConferenceCompleted":
                        if (_BettaDriver_SDK_API.onConferenceCompleted !== undefined)
                            _BettaDriver_SDK_API.onConferenceCompleted(result);
                        break;
                    case "onHoldCompleted":
                        if (_BettaDriver_SDK_API.onHoldCompleted !== undefined)
                            _BettaDriver_SDK_API.onHoldCompleted(result);
                        break;
                    case "onExtendCompleted":
                        if (_BettaDriver_SDK_API.onExtendCompleted !== undefined)
                            _BettaDriver_SDK_API.onExtendCompleted(result);
                        break;
                    case "onHangupCompleted":
                        if (_BettaDriver_SDK_API.onHangupCompleted !== undefined)
                            _BettaDriver_SDK_API.onHangupCompleted(result);
                        break;
                    case "onBusinessOutcomeChanged":
                        if (_BettaDriver_SDK_API.onBusinessOutcomeChanged !== undefined)
                            _BettaDriver_SDK_API.onBusinessOutcomeChanged(result);
                        break;
                    case "onServerManagerSuspending":
                        if (_BettaDriver_SDK_API.onServerManagerSuspending !== undefined)
                            _BettaDriver_SDK_API.onServerManagerSuspending(result);
                        break;
                    case "onServerStatusChanged":
                        if (_BettaDriver_SDK_API.onServerStatusChanged !== undefined)
                            _BettaDriver_SDK_API.onServerStatusChanged(result);
                        break;
                    case "onKeyPerformanceIndicators":
                        if (_BettaDriver_SDK_API.onKeyPerformanceIndicators !== undefined)
                            _BettaDriver_SDK_API.onKeyPerformanceIndicators(result);
                        break; 
                    case "onMethodResponse":
                        if (_BettaDriver_SDK_API.onMethodResponse !== undefined)
                            _BettaDriver_SDK_API.onMethodResponse(result.method, result);
                        break;
					case "onUserSessionState":
                        if (_BettaDriver_SDK_API.onUserSessionState !== undefined)
                            _BettaDriver_SDK_API.onUserSessionState(result);
                        break;								
                    case "onBettaDriverOpen":
                        if (_BettaDriver_SDK_API.onBettaDriverOpen !== undefined)
                            _BettaDriver_SDK_API.onBettaDriverOpen(result);
                        break;
                    case "onDriverOpen":
                        if (_BettaDriver_SDK_API.onDriverOpen !== undefined)
                            _BettaDriver_SDK_API.onDriverOpen(result);
                        break;
                    case "onBettaDriverError":
                        if (_BettaDriver_SDK_API.onBettaDriverError !== undefined)
                            _BettaDriver_SDK_API.onBettaDriverError(result);
                        break;							
                    case "onRequestLogin":
                        if (_BettaDriver_SDK_API.onRequestLogin !== undefined)
                            _BettaDriver_SDK_API.onRequestLogin(result);
                        break;	
                    case "onDriverConnect":
                        if (_BettaDriver_SDK_API.onDriverConnect !== undefined)
                            _BettaDriver_SDK_API.onDriverConnect(result);
                        break;							
                    case "onDialExternalCall":
                        if (_BettaDriver_SDK_API.onDialExternalCall !== undefined)
                            _BettaDriver_SDK_API.onDialExternalCall(result);
                        break;	
                    case "onCallBack":
                        if (_BettaDriver_SDK_API.onCallBack !== undefined)
                            _BettaDriver_SDK_API.onCallBack(result);
                        break;	
                    case "onHangup":
                        if (_BettaDriver_SDK_API.onHangup !== undefined)
                            _BettaDriver_SDK_API.onHangup(result);
                        break;	
                    case "onstartCallback":
                        if (_BettaDriver_SDK_API.onstartCallback !== undefined)
                            _BettaDriver_SDK_API.onstartCallback(result);
                        break;	
                    case "onRetrieve":
                        if (_BettaDriver_SDK_API.onRetrieve !== undefined)
                            _BettaDriver_SDK_API.onRetrieve(result);
                        break;
                    case "onHold":
                        if (_BettaDriver_SDK_API.onHold !== undefined)
                            _BettaDriver_SDK_API.onHold(result);
                        break;	
                    case "onTransferCall":
                        if (_BettaDriver_SDK_API.onTransferCall !== undefined)
                            _BettaDriver_SDK_API.onTransferCall(result);
                        break;	
                    case "onConsultationCall":
                        if (_BettaDriver_SDK_API.onConsultationCall !== undefined)
                            _BettaDriver_SDK_API.onConsultationCall(result);
                        break;	
                    case "onDialPending":
                        if (_BettaDriver_SDK_API.onDialPending !== undefined)
                            _BettaDriver_SDK_API.onDialPending(result);
                        break;	
                    case "onBlindTransfer":
                        if (_BettaDriver_SDK_API.onBlindTransfer !== undefined)
                            _BettaDriver_SDK_API.onBlindTransfer(result);
                        break;
					case "onConsultationFailed":
                        if (_BettaDriver_SDK_API.onConsultationFailed !== undefined)
                            _BettaDriver_SDK_API.onConsultationFailed(result);
                        break;	
					case "onCallFailed":
                        if (_BettaDriver_SDK_API.onCallFailed !== undefined)
                            _BettaDriver_SDK_API.onCallFailed(result);
                        break;	
					case "onConsultationDisconnected":
                        if (_BettaDriver_SDK_API.onConsultationDisconnected !== undefined)
                            _BettaDriver_SDK_API.onConsultationDisconnected(result);
                        break;	
					case "onConsultationConnected":
                        if (_BettaDriver_SDK_API.onConsultationConnected !== undefined)
                            _BettaDriver_SDK_API.onConsultationConnected(result);
                        break;	
					case "onConsultationRinging":
                        if (_BettaDriver_SDK_API.onConsultationRinging !== undefined)
                            _BettaDriver_SDK_API.onConsultationRinging(result);
                        break;	
                    default:
                        console.log("%% BettaDriverSDK %% listener invalid type:", result.type);
                        break;
                }
            } else {
                console.log("%% BettaDriverSDK %% Not for this client");
            }
            

        }

    }

    function sendApiRequest(object) {
		
		//console.log("sendApiRequest " + JSON.stringify(object));
        //window.parent.postMessage(JSON.stringify(object), "*");
		BettaDriverWS.send(JSON.stringify(object));
    }

    //-------------------------------------------------------------------------------
    // Available methods
    //-------------------------------------------------------------------------------

    return {
        'login': login,
		'logout': logout,
        'discardContact': discardContact,
        'rescheduleContact': rescheduleContact,
        'getUserSessionState': getUserSessionState,
        'requestWrapup': requestWrapup,
        'endWrapup': endWrapup,
        'extendAudio': extendAudio,
        'alternate': alternate,
        'conference': conference,
        'dialAudio': dialAudio,
        'hold': hold,
        'blindTransfer': blindTransfer,
        'transfer': transfer,
        'retrieve': retrieve,
        'hangup': hangup,
        'setReady': setReady,
        'setNotReady': setNotReady,
        'startRecord': startRecord,
        'stopRecord': stopRecord,
		'dialExternalCall': dialExternalCall,
		'dialConsultationCall': dialConsultationCall,
		'startCallBack': startCallBack,
		'hangup': hangup,
        //Listener
        'listener': listener,
		//Novas funcionalidades
        'driverConnect': driverConnect,
        'sendIdCustomerInteraction': sendIdCustomerInteraction,
		'onDriverConnect': onDriverConnect,
		'onDialExternalCall': onDialExternalCall,	
        //Events
        'onBettaDriverOpen': onBettaDriverOpen,
        'onDriverOpen': onDriverOpen,
		'onBettaDriverClose': onBettaDriverClose,
		'onBettaDriverError': onBettaDriverError,
		'onUserSessionState': onUserSessionState,
        'onWrapup': onWrapup,
        'onIdle': onIdle,
        'onBusy': onBusy,
        'onPreviewing': onPreviewing,
        'onAgentLogin': onAgentLogin,
        'onCallInviting': onCallInviting,
        'onDialCompleted': onDialCompleted,
        'onCallOffering': onCallOffering,
        'onCallExtended': onCallExtended,
        'onCallConnected': onCallConnected,
        'onCallDisconnected': onCallDisconnected,
        'onAgentLogout': onAgentLogout,
        'onAgentForceLogout': onAgentForceLogout,
        'onSetAgentNotReady': onSetAgentNotReady,
        'onSetAgentReady': onSetAgentReady,
        'onCallHeld': onCallHeld,
        'onSessionWrapupTimeout': onSessionWrapupTimeout,
        'onSessionEndWrapup': onSessionEndWrapup,
        'onSearchResult': onSearchResult,
        'onConsultCompleted': onConsultCompleted,
        'onSetExtensionCompleted': onSetExtensionCompleted,
        'onRescheduleCompleted': onRescheduleCompleted,
        'onDiscardCompleted': onDiscardCompleted,
        'onAlternateCompleted': onAlternateCompleted,
        'onConferenceCompleted': onConferenceCompleted,
        'onHoldCompleted': onHoldCompleted,
        'onExtendCompleted': onExtendCompleted,
        'onHangupCompleted': onHangupCompleted,
        'onServerStatusChanged': onServerStatusChanged,
        'onTransferServicesListCompleted': onTransferServicesListCompleted,
        'onMethodResponse': onMethodResponse,
		'onRequestLogin': onRequestLogin,
		'onCallBack': onCallBack,
		'onstartCallback': onstartCallback,
		'onHangup': onHangup,
		'onRetrieve': onRetrieve,
		'onHold': onHold,
		'onTransferCall': onTransferCall,
		'onConsultationCall': onConsultationCall,
		'onDialPending': onDialPending,
		'onBlindTransfer':onBlindTransfer,
		'onConsultationFailed': onConsultationFailed,
		'onCallFailed': onCallFailed,
		'onConsultationDisconnected': onConsultationDisconnected,
		'onConsultationConnected': onConsultationConnected,
		'onConsultationRinging': onConsultationRinging,
    };
}

Quicklinks
Profiles Chamber
Quick Console
Home
Quick Query
Execute Anonymous
Sobject fields
Quick ORG Describe
Replace API Names
Convert SF Id
Login As...
Options
Hide
