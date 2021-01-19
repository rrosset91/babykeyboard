trigger KB_KnowledgeTrigger  on Knowledge__kav (after insert, after update) {
    new KB_KnowledgeTriggerHandler().run();
}