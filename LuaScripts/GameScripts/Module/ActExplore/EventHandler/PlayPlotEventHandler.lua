local PlayPlotEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.EntityPlayPlotEvent
}

function PlayPlotEventHandler.OnEvent(world, entity, event)
  if event.Type == CS.LogicActExplore.PlotType.Bubble then
    local element = CS.CData_BattleCineStep.GetInstance():GetValue_ByInBattleCineStepID(event.PlotID)
    if element:GetError() then
      log.error("播放气泡对话失败，配置表ID错误, ID = " .. event.PlotID)
      return
    end
    local stEventParam = {
      iCineStepID = event.PlotID,
      iSubCineStepID = element.m_InBattleCineSubStepID,
      fWaitTimeMax = element.m_WaitMax,
      bottomOffset = 150
    }
    StackBottom:Push(UIDefines.ID_FORM_DIALOGUE_POPO, stEventParam)
    world.form:broadcastEvent("eGameEvent_CineVoiceInBattle_AddDialoguePop", stEventParam)
  else
    world.form:SetVisable(not event.IsStart)
  end
end

return PlayPlotEventHandler
