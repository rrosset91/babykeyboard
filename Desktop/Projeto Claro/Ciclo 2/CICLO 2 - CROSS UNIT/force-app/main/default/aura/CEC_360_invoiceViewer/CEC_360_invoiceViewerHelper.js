({
	  renderPDF : function(component,event,helper){
       $A.createComponent(
            "c:pdfViewer",
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