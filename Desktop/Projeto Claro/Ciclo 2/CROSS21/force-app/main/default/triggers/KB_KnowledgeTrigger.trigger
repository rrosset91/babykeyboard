trigger KB_KnowledgeTrigger  on Knowledge__kav (before update) {
    new KB_KnowledgeTriggerHandler().run();
}