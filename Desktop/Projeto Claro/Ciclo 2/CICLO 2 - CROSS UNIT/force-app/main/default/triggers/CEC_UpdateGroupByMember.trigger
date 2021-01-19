trigger CEC_UpdateGroupByMember on Member__c (after insert, after update) {
	if(trigger.isafter){
		//CEC_UpdateGroupBO.updateGroupMember(JSON.Serialize(trigger.new));
	}    
}