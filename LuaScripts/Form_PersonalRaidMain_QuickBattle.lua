local Form_PersonalRaidMain_QuickBattle = class("Form_PersonalRaidMain_QuickBattle", require("UI/UIFrames/Form_PersonalRaidMain_QuickBattleUI"))

function Form_PersonalRaidMain_QuickBattle:SetInitParam(param)
end

function Form_PersonalRaidMain_QuickBattle:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnRewardItemClk)
  }
  self.m_rewardListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scroll_reward_InfinityGrid, "UICommonItem", initGridData)
  self.m_rewardListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnRewardItemClk))
end

function Form_PersonalRaidMain_QuickBattle:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_stageCfg = tParam
  self:GenerateData()
end

function Form_PersonalRaidMain_QuickBattle:OnInactive()
  self.super.OnInactive(self)
end

function Form_PersonalRaidMain_QuickBattle:GenerateData()
  local rewardList = utils.changeCSArrayToLuaTable(self.m_stageCfg.m_ClientMustDrop)
  local proRewardList = utils.changeCSArrayToLuaTable(self.m_stageCfg.m_ClientProDrop)
  local rewardTab = {}
  local customDataTab = {}
  self.m_rewardList = {}
  for i, v in ipairs(proRewardList) do
    rewardTab[#rewardTab + 1] = {
      v[1],
      1
    }
    customDataTab[#customDataTab + 1] = {
      percentage = v[2]
    }
  end
  for i, v in ipairs(rewardList) do
    customDataTab[#customDataTab + 1] = {percentage = 100}
  end
  table.insertto(rewardTab, rewardList)
  if table.getn(rewardTab) > 0 then
    for i, v in ipairs(rewardTab) do
      local rewardData = ResourceUtil:GetProcessRewardData(v, customDataTab[i])
      self.m_rewardList[#self.m_rewardList + 1] = rewardData
    end
  end
  self.m_rewardListInfinityGrid:ShowItemList(self.m_rewardList)
end

function Form_PersonalRaidMain_QuickBattle:OnRewardItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_rewardList[fjItemIndex]
  if chooseFJItemData then
    utils.openItemDetailPop({
      iID = chooseFJItemData.data_id,
      iNum = chooseFJItemData.data_num
    })
  end
end

function Form_PersonalRaidMain_QuickBattle:OnBtnyesClicked()
  PersonalRaidManager:ReqSoloRaidMopUpCS(self.m_stageCfg.m_LevelID)
  self:CloseForm()
end

function Form_PersonalRaidMain_QuickBattle:OnBtncancelClicked()
  self:CloseForm()
end

function Form_PersonalRaidMain_QuickBattle:IsOpenGuassianBlur()
  return true
end

function Form_PersonalRaidMain_QuickBattle:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_PersonalRaidMain_QuickBattle", Form_PersonalRaidMain_QuickBattle)
return Form_PersonalRaidMain_QuickBattle
