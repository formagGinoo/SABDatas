local PopMessageEventHandler = {
  EvnetTypeID = CS.LogicActExplore.ActExploreEventID.PopMessage
}

function PopMessageEventHandler.OnEvent(world, entity, event)
  CS.UI.UILuaHelper.ShowClientMessage(event.ID)
end

return PopMessageEventHandler
