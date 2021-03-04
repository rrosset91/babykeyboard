trigger CEC_UserTrigger on User (after insert, after update, before insert, before update) {
  new CEC_UserTriggerHandler().run();
}