local Form_BossReward = class("Form_BossReward", require("UI/UIFrames/Form_BossRewardUI"))

function Form_BossReward:SetInitParam(param)
end

function Form_BossReward:AfterInit()
  self.super.AfterInit(self)
  self.m_levelID = nil
  self.m_curDungeonLevelPhaseCfgList = nil
  self.m_equipmentHelper = LevelManager:GetLevelEquipmentHelper()
  self.m_luaStageRewardInfinityGrid = self:CreateInfinityGrid(self.m_scrollView_InfinityGrid, "EquipmentBoss/UIBossRewardItem")
end

function Form_BossReward:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
  GlobalManagerIns:TriggerWwiseBGMState(35)
end

function Form_BossReward:OnInactive()
  self.super.OnInactive(self)
end

function Form_BossReward:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BossReward:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_levelID = tParam.levelID
    self.m_curDungeonLevelPhaseCfgList = self.m_equipmentHelper:GetDungeonLevelPhaseCfgListByID(self.m_levelID) or {}
  end
end

function Form_BossReward:FreshUI()
  if not self.m_luaStageRewardInfinityGrid then
    return
  end
  self.m_luaStageRewardInfinityGrid:ShowItemList(self.m_curDungeonLevelPhaseCfgList)
  self.m_luaStageRewardInfinityGrid:LocateTo()
end

function Form_BossReward:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_BossReward:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_BossReward:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_BossReward", Form_BossReward)
return Form_BossReward
