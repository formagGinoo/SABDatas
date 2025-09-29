local Form_Activity110_Detail = class("Form_Activity110_Detail", require("UI/UIFrames/Form_Activity110_DetailUI"))
local levelTb = ConfigManager:GetConfigInsByName("MiniGameFlopLevelInfo")

function Form_Activity110_Detail:SetInitParam(param)
end

function Form_Activity110_Detail:AfterInit()
  self.super.AfterInit(self)
  self.m_Grid1 = self:CreateInfinityGrid(self.m_pnl_item_normal_1_InfinityGrid, "ActivityMinigame110/Activity110_DetailItem")
  self.m_Grid2 = self:CreateInfinityGrid(self.m_pnl_item_normal_2_InfinityGrid, "ActivityMinigame110/Activity110_DetailItem")
end

function Form_Activity110_Detail:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  self.is_select_vReward = tParam.is_select_vReward
  self.is_select_iClueTime = tParam.is_select_iClueTime
  self.levelCfg = levelTb:GetValue_ByLevelID(tParam.LevelId)
  local data1 = {}
  for _, v in pairs(utils.changeCSArrayToLuaTable(self.levelCfg.m_FirstRewards)) do
    table.insert(data1, {
      rewardData = v,
      is_have_get = self.is_select_vReward
    })
  end
  self.m_Grid1:ShowItemList(data1)
  local data2 = {}
  for _, v in pairs(utils.changeCSArrayToLuaTable(self.levelCfg.m_ClueRewards)) do
    table.insert(data2, {
      rewardData = v,
      is_have_get = self.is_select_iClueTime
    })
  end
  self.m_Grid2:ShowItemList(data2)
  self.m_txt_title2_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100907), self.levelCfg.m_Steps)
end

function Form_Activity110_Detail:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity110_Detail:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity110_Detail:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity110_Detail", Form_Activity110_Detail)
return Form_Activity110_Detail
