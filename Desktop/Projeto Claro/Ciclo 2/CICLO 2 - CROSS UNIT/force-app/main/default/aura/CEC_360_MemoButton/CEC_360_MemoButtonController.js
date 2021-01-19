({
	openModal : function(component, event, helper) {
		var modalBody;
        $A.createComponent("c:CEC_360_Memorandums", {
            recordId: component.get('v.recordId'),
            isAsset:true
         },
                           function (content, status) {
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   component.find('overlayLib').showCustomModal({
                                       body: modalBody,
                                       showCloseButton: true,
                                       cssClass: "mymodal",
                                       closeCallback: function () {
                                       }
                                   })
                               }
                           });
    }
	
})