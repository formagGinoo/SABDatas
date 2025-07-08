local Form_RogueLocalBag = class("Form_RogueLocalBag", require("UI/UIFrames/Form_RogueLocalBagUI"))

function Form_RogueLocalBag:SetInitParam(param)
end

function Form_RogueLocalBag:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_luaRogueEquipInfinityGrid = self:CreateInfinityGrid(self.m_scrollview_property_InfinityGrid, "RogueChoose/UIRogueEquipItem", initGridData)
  self.m_luaRogueEquipInfinityGrid:RegisterButtonCallback("m_btn_rogue_right_item", handler(self, self.OnItemClk))
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
end

function Form_RogueLocalBag:OnActive()
  self.super.OnActive(self)
  self.m_showRogueEquipItemDataList = self.m_levelRogueStageHelper:GetRogueBagData()
  if table.getn(self.m_showRogueEquipItemDataList) > 0 then
    self.m_luaRogueEquipInfinityGrid:ShowItemList(self.m_showRogueEquipItemDataList)
  end
  self.m_scrollview_property:SetActive(table.getn(self.m_showRogueEquipItemDataList) > 0)
end

function Form_RogueLocalBag:OnInactive()
  self.super.OnInactive(self)
end

function Form_RogueLocalBag:OnItemClk(itemIndex)
  if not itemIndex then
    return
  end
  local dragEquipItemData = self.m_showRogueEquipItemDataList[itemIndex]
  if not dragEquipItemData then
    return
  end
  local heroIdList = RogueStageManager:GetFightHeros()
  utils.openRogueItemTips(dragEquipItemData.rogueStageItemCfg.m_ItemID, heroIdList)
end

function Form_RogueLocalBag:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_RogueLocalBag:IsOpenGuassianBlur()
  return true
end

function Form_RogueLocalBag:IsFullScreen()
  return false
end

function Form_RogueLocalBag:OnBtncloseClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_RogueLocalBag", Form_RogueLocalBag)
return Form_RogueLocalBag
