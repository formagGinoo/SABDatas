local Form_MaterialsRewardPop = class("Form_MaterialsRewardPop", require("UI/UIFrames/Form_MaterialsRewardPopUI"))
local GoblinRewardIns = ConfigManager:GetConfigInsByName("GoblinReward")

function Form_MaterialsRewardPop:SetInitParam(param)
end

function Form_MaterialsRewardPop:AfterInit()
  self.super.AfterInit(self)
  self.m_matRewardGroupID = nil
  self.m_groupRewardCfgList = nil
  self.m_luaRewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "Level/UILevelGoblinRewardItem")
end

function Form_MaterialsRewardPop:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
end

function Form_MaterialsRewardPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_MaterialsRewardPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_MaterialsRewardPop:AddEventListeners()
end

function Form_MaterialsRewardPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_MaterialsRewardPop:ClearData()
end

function Form_MaterialsRewardPop:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_matRewardGroupID = tParam.rewardGroupID
    self.m_csui.m_param = nil
  end
end

function Form_MaterialsRewardPop:FreshRewardDataList()
  if not self.m_matRewardGroupID then
    return
  end
  self.m_groupRewardCfgList = {}
  local groupRewardCfgArray = GoblinRewardIns:GetValue_ByRewardGroupID(self.m_matRewardGroupID)
  if not groupRewardCfgArray then
    return
  end
  for i, v in pairs(groupRewardCfgArray) do
    local tempReward = {
      rewardCfg = v,
      stageID = v.m_StageID,
      nextCount = 0
    }
    self.m_groupRewardCfgList[#self.m_groupRewardCfgList + 1] = tempReward
  end
  table.sort(self.m_groupRewardCfgList, function(a, b)
    return a.stageID < b.stageID
  end)
  for i, v in ipairs(self.m_groupRewardCfgList) do
    local nextData = self.m_groupRewardCfgList[i + 1]
    if nextData then
      v.nextCount = nextData.rewardCfg.m_CountMin - 1
    else
      v.nextCount = v.rewardCfg.m_CountMin
    end
  end
end

function Form_MaterialsRewardPop:FreshUI()
  if not self.m_matRewardGroupID then
    return
  end
  self:FreshRewardDataList()
  self:FreshShowRewardList()
end

function Form_MaterialsRewardPop:FreshShowRewardList()
  if not self.m_groupRewardCfgList then
    return
  end
  self.m_luaRewardListInfinityGrid:ShowItemList(self.m_groupRewardCfgList)
end

function Form_MaterialsRewardPop:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_MaterialsRewardPop:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_MaterialsRewardPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_MaterialsRewardPop", Form_MaterialsRewardPop)
return Form_MaterialsRewardPop
