trigger CEC_CreateGroupByHierarchy on Hierarchy__c (after insert) {
	if(trigger.isAfter){
		if(trigger.isInsert){
			//CEC_UpdateGroupBO.createGroupByHierarchy(trigger.new);
		}
	}    
}