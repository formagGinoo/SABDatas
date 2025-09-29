local Form_Activity110MiniGameReward = class("Form_Activity110MiniGameReward", require("UI/UIFrames/Form_Activity110MiniGameRewardUI"))
local MiniGameA10RewardsIns = ConfigManager:GetConfigInsByName("MiniGameA10Rewards")
local length = 3

function Form_Activity110MiniGameReward:SetInitParam(param)
end

function Form_Activity110MiniGameReward:AfterInit()
  self.super.AfterInit(self)
  self.m_levelID = nil
  self.m_curRewardCfgList = nil
  self.m_luaRewardInfinityGrid = self:CreateInfinityGrid(self.m_scrollView_InfinityGrid, "ActivityMinigame110/Minigame110RewardItem")
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_iDailyCanRewardLevel = 0
  self.m_claimedRewardDays = 0
  self.m_iDailyTakenRewardLevel = {}
  self.m_rewardListInfinityGrid = self:CreateInfinityGrid(self.m_reward_list_InfinityGrid, "UICommonItem", initGridData)
  self.m_allLevelRewardCfg = {}
  self:FreshRewardCfg()
end

function Form_Activity110MiniGameReward:FreshRewardCfg()
  local cfgList = MiniGameA10RewardsIns:GetAll()
  for _, cfg in pairs(cfgList) do
    local reward = utils.changeCSArrayToLuaTable(cfg.m_Rewards)
    if table.getn(reward) > 0 then
      self.m_allLevelRewardCfg[#self.m_allLevelRewardCfg + 1] = cfg
    end
  end
  table.sort(self.m_allLevelRewardCfg, function(a, b)
    return a.m_KeyLevel < b.m_KeyLevel
  end)
end

function Form_Activity110MiniGameReward:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_mainActId = self.m_csui.m_param.main_id
    self.m_subActId = self.m_csui.m_param.sub_id
  end
  if not self.m_mainActId or not self.m_mainActId then
    self:CloseForm()
    return
  end
  self:FreshData()
  self:FreshUI()
end

function Form_Activity110MiniGameReward:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_Activity110MiniGameReward:AddEventListeners()
  self:addEventListener("eGameEvent_ActMinigame_GetRewardLoveWhip", handler(self, self.OnDealGetReward))
end

function Form_Activity110MiniGameReward:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Activity110MiniGameReward:OnDealGetReward()
  self:FreshData()
  self:FreshUI()
end

function Form_Activity110MiniGameReward:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity110MiniGameReward:FreshData()
  local stMiniGame = HeroActivityManager:GetHeroActData(self.m_mainActId).server_data.stMiniGame
  if stMiniGame.stMGLoveWhipInfo then
    self.m_iDailyCanRewardLevel = stMiniGame.stMGLoveWhipInfo.iDailyCanRewardLevel
  end
  if stMiniGame.stMGLoveWhipInfo then
    self.m_iDailyTakenRewardLevel = stMiniGame.stMGLoveWhipInfo.iDailyTakenRewardLevel
  end
end

function Form_Activity110MiniGameReward:FreshUI()
  if not self.m_luaRewardInfinityGrid then
    return
  end
  local autoIndex = 0
  local showListData = {}
  for index, rewardCfg in ipairs(self.m_allLevelRewardCfg) do
    local state = 3
    if rewardCfg.m_KeyLevel <= self.m_iDailyTakenRewardLevel then
      state = 1
      autoIndex = index - 1
    end
    if rewardCfg.m_KeyLevel > self.m_iDailyTakenRewardLevel and rewardCfg.m_KeyLevel <= self.m_iDailyCanRewardLevel then
      state = 2
    end
    local isLast = table.getn(self.m_allLevelRewardCfg) == index
    local param = {
      cfg = rewardCfg,
      state = state,
      isLast = isLast
    }
    showListData[#showListData + 1] = param
  end
  self.m_luaRewardInfinityGrid:ShowItemList(showListData)
  local index = autoIndex + length > #showListData - 1 and #showListData - 1 or autoIndex + length
  self.m_luaRewardInfinityGrid:LocateTo(index)
  self:FreshPendingRewardList()
end

function Form_Activity110MiniGameReward:FreshPendingRewardList()
  local rewardList = self:GetPendingRewardList()
  local isShow = table.getn(rewardList) > 0
  self.m_btn_get:SetActive(isShow)
  self.m_btn_get_gary:SetActive(not isShow)
  self.m_pnl_reward:SetActive(isShow)
  self.m_z_txt_noreward:SetActive(not isShow)
  self.m_rewardListInfinityGrid:ShowItemList(rewardList)
end

function Form_Activity110MiniGameReward:GetPendingRewardList()
  local rewards = {}
  for k, cfg in ipairs(self.m_allLevelRewardCfg) do
    if cfg.m_KeyLevel > self.m_iDailyTakenRewardLevel and cfg.m_KeyLevel <= self.m_iDailyCanRewardLevel then
      local rewardList = utils.changeCSArrayToLuaTable(cfg.m_Rewards)
      for _, reward in pairs(rewardList) do
        rewards[#rewards + 1] = ResourceUtil:GetProcessRewardData(reward)
      end
    end
  end
  return rewards
end

function Form_Activity110MiniGameReward:OnItemClk(itemIndex, itemRootObj, itemIcon)
  utils.openItemDetailPop({
    iID = itemIcon.m_iItemID,
    iNum = 1
  })
end

function Form_Activity110MiniGameReward:OnBtngetClicked()
  HeroActivityManager:ReqLamiaGameRewardLoveWhipCS(self.m_mainActId, self.m_subActId)
end

function Form_Activity110MiniGameReward:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_Activity110MiniGameReward:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_Activity110MiniGameReward:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity110MiniGameReward", Form_Activity110MiniGameReward)
return Form_Activity110MiniGameReward
