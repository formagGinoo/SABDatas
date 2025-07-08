local Form_PvpReplaceReward = class("Form_PvpReplaceReward", require("UI/UIFrames/Form_PvpReplaceRewardUI"))
local RewardType = {Hour = 1, Season = 2}
local ReplaceArenaRewardIns = ConfigManager:GetConfigInsByName("ReplaceArenaReward")

function Form_PvpReplaceReward:SetInitParam(param)
end

function Form_PvpReplaceReward:AfterInit()
  self.super.AfterInit(self)
  self.TabCfg = {
    [RewardType.Hour] = {
      selectNode = self.m_img_sel1,
      unSelectNode = self.m_z_txt_nml1,
      panelNode = self.m_pnl_hourly
    },
    [RewardType.Season] = {
      selectNode = self.m_img_sel2,
      unSelectNode = self.m_z_txt_nml2,
      panelNode = self.m_pnl_season
    }
  }
  self.m_luaHourRewardGrid = self:CreateInfinityGrid(self.m_scrollView_InfinityGrid, "PvpReplace/UIPvpReplaceHourRewardItem", nil)
  self.m_luaSeasonRewardGrid = self:CreateInfinityGrid(self.m_scrollView2_InfinityGrid, "PvpReplace/UIPvpReplaceSeasonRewardItem", nil)
  self.m_hourRewardList = nil
  self.m_seasonRewardList = nil
  self:InitFreshRewardList()
  self.m_curRewardType = RewardType.Hour
  self.m_backFun = nil
end

function Form_PvpReplaceReward:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_PvpReplaceReward:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_PvpReplaceReward:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PvpReplaceReward:InitFreshRewardList()
  local hourRewardRankCfgList = PvpReplaceManager:GetAllReplaceRankCfg() or {}
  self.m_hourRewardList = hourRewardRankCfgList
  local allCfgList = ReplaceArenaRewardIns:GetAll()
  local seasonRewardCfgList = {}
  for _, tempCfg in pairs(allCfgList) do
    seasonRewardCfgList[tempCfg.m_ID] = tempCfg
  end
  self.m_seasonRewardList = seasonRewardCfgList
end

function Form_PvpReplaceReward:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_backFun = tParam.backFun
    self.m_csui.m_param = nil
  end
end

function Form_PvpReplaceReward:ClearCacheData()
end

function Form_PvpReplaceReward:AddEventListeners()
end

function Form_PvpReplaceReward:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpReplaceReward:FreshUI()
  self.m_luaHourRewardGrid:ShowItemList(self.m_hourRewardList)
  self.m_luaSeasonRewardGrid:ShowItemList(self.m_seasonRewardList)
  self:ChangeFreshRewardShow(RewardType.Hour)
end

function Form_PvpReplaceReward:ChangeFreshRewardShow(rewardType)
  if self.m_curRewardType then
    local lastNode = self.TabCfg[self.m_curRewardType]
    if lastNode then
      UILuaHelper.SetActive(lastNode.selectNode, false)
      UILuaHelper.SetActive(lastNode.unSelectNode, true)
      UILuaHelper.SetActive(lastNode.panelNode, false)
    end
  end
  local curNode = self.TabCfg[rewardType]
  if curNode then
    UILuaHelper.SetActive(curNode.selectNode, true)
    UILuaHelper.SetActive(curNode.unSelectNode, false)
    UILuaHelper.SetActive(curNode.panelNode, true)
  end
  self.m_curRewardType = rewardType
end

function Form_PvpReplaceReward:OnBtnCloseClicked()
  if self.m_backFun ~= nil then
    self.m_backFun()
  end
  self:CloseForm()
end

function Form_PvpReplaceReward:OnBtnReturnClicked()
  if self.m_backFun ~= nil then
    self.m_backFun()
  end
  self:CloseForm()
end

function Form_PvpReplaceReward:OnTab1Clicked()
  self:OnTabClk(RewardType.Hour)
end

function Form_PvpReplaceReward:OnTab2Clicked()
  self:OnTabClk(RewardType.Season)
end

function Form_PvpReplaceReward:OnTabClk(rewardType)
  if not rewardType then
    return
  end
  if self.m_curRewardType == rewardType then
    return
  end
  self:ChangeFreshRewardShow(rewardType)
end

function Form_PvpReplaceReward:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PvpReplaceReward", Form_PvpReplaceReward)
return Form_PvpReplaceReward
