({
	getOptions : function(component,event,helper) {
		var action = component.get("c.getMetadata");
        let critics = [];
        let nocritics = [];
        let recordId = component.get("v.recordId");
        action.setParams({
            caseId:recordId
        });
        action.setCallback(this,function(response){
 			let state = response.getState();
        	if (state === "SUCCESS"){ 
                let ret =  response.getReturnValue().lJourneyLst;
                console.log('retorno selectJouney',ret);                
                for(let i = 0;i<ret.length;i++){
                    if(ret[i].agrupador != '' && ret[i].agrupador !== undefined && ret[i].agrupador != null){
                        critics.push(ret[i]);
                    }else{
                        nocritics.push(ret[i]);
                    }
                }
                component.set("v.CanaisCriticos", critics);
                component.set("v.canais",nocritics);                    
                var lCaseFields =  response.getReturnValue().lCaseFields;
                console.log('Journey lCaseFields ------------> ' + lCaseFields);
                if(lCaseFields.lLastAccessedSystem != undefined || lCaseFields.lSystemResponse != undefined){
                    component.set("v.caseFields",lCaseFields);              
                    component.set("v.showUraDetails",true);      
                }
        	}     	
        });
        $A.enqueueAction(action);
	},
    changeRecord: function(component, event,helper){
       var action = component.get("c.changeRecordType");
       let recordId = component.get("v.recordId");
       let recordTypeName = component.get('v.valueSelected');
       component.set("v.isLoading",true);
       debugger;
       action.setParams({
            id : recordId,
            RecordType : recordTypeName
        });
        
        action.setCallback(this, function(response) {
						let state = response.getState();
						if (state === "SUCCESS") {
                           let returned = response.getReturnValue();
                            if(returned == 'Ok'){
                				$A.get('e.force:refreshView').fire();
                            }else if(returned == 'Error'){                          
                                component.set('v.openModal',false);
                                component.set('v.openModalError',true);
                            }
                        }
        });        
        $A.enqueueAction(action);
    }
})