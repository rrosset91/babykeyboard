/**
 * @description       : 
 * @author            : Diego Almeida
 * @group             : 
 * @last modified on  : 10-02-2021
 * @last modified by  : Diego Almeida
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   10-02-2021   Diego Almeida   Initial Version
**/
({
	  renderPDF : function(component,event,helper){
       $A.createComponent(
            "c:Viewer",
            	{
                	"pdfData": component.get("v.pdfData")
            	},
            	function(pdfViewer, status, errorMessage){
                    if (status === "SUCCESS") {
                        var pdfContainer = component.get("v.pdfContainer");
                        pdfContainer.push(pdfViewer);
                        component.set("v.pdfContainer", pdfContainer);

                	}

       			}
    	);
    }
})