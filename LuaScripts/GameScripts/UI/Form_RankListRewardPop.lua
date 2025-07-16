local Form_RankListRewardPop = class("Form_RankListRewardPop", require("UI/UIFrames/Form_RankListRewardPopUI"))
local RankTabNum = 3

function Form_RankListRewardPop:SetInitParam(param)
end

function Form_RankListRewardPop:AfterInit()
  self.super.AfterInit(self)
  self.m_InfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_reward_list_InfinityGrid, "RankList/UIRankRewardItem")
  self.mAllCollectRewardCfg = GlobalRankManager:FormatAndGetAllRankCollectRewardCfg()
  self.m_pnl_bottom = self.m_csui.m_uiGameObject.transform:Find("content_node/pnl_bottom").gameObject
end

function Form_RankListRewardPop:OnActive()
  self.super.OnActive(self)
  self:InitData()
  self:RefreshUI()
  self.enterTime = TimeUtil:GetServerTimeS()
end

function Form_RankListRewardPop:OnInactive()
  self.super.OnInactive(self)
  local stayTime = TimeUtil:GetServerTimeS() - self.enterTime
  RankManager:SendRankReport(0, RankManager.RankPanelReportType.RankListReward, stayTime)
end

function Form_RankListRewardPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_RankListRewardPop:InitData()
  self.mCurSelectIdx = 1
  self.mFormatCollectRankNum = GlobalRankManager:GetCollectRankNum()
end

function Form_RankListRewardPop:RefreshUI()
  self:RefreshTab()
  local cfgList = self.mAllCollectRewardCfg[self.mCurSelectIdx]
  self.m_txt_rankpreview_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100402), cfgList[1].m_Rank)
  self.m_InfinityGrid:ShowItemList(cfgList)
  UILuaHelper.PlayAnimationByName(self.m_pnl_bottom, "RankListRewardPop_bottomin")
end

function Form_RankListRewardPop:RefreshTab()
  for i = 1, RankTabNum do
    local cfgList = self.mAllCollectRewardCfg[i]
    self["m_img_rank" .. i .. "_select"]:SetActive(self.mCurSelectIdx == i)
    self["m_txt_rank" .. i .. "_title_Text"].text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100401), cfgList[1].m_Rank)
    local cur_count = self.mFormatCollectRankNum[cfgList[1].m_Rank] or 0
    local cfg = GlobalRankManager:GetNextRewardCfg(i, cur_count)
    local next_count = cfg.m_Number
    self["m_txt_rank" .. i .. "_num_Text"].text = cur_count .. "/" .. next_count
    local rewardObj = self["m_rank" .. i .. "_item"]
    local data = utils.changeCSArrayToLuaTable(cfg.m_Reward)[1]
    local reward_item = self:createCommonItem(rewardObj)
    local processData = ResourceUtil:GetProcessRewardData({
      iID = data[1],
      iNum = data[2]
    })
    reward_item:SetItemInfo(processData)
    reward_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
      CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
      utils.openItemDetailPop({iID = itemID, iNum = itemNum})
    end)
    reward_item:SetItemHaveGetActive(cur_count >= next_count)
  end
end

function Form_RankListRewardPop:OnRewardRankClk(index)
  if not index then
    return
  end
  if index == self.mCurSelectIdx then
    return
  end
  self.mCurSelectIdx = index
  self:RefreshUI()
end

function Form_RankListRewardPop:OnPnlrewardrank1Clicked()
  self:OnRewardRankClk(1)
end

function Form_RankListRewardPop:OnPnlrewardrank2Clicked()
  self:OnRewardRankClk(2)
end

function Form_RankListRewardPop:OnPnlrewardrank3Clicked()
  self:OnRewardRankClk(3)
end

function Form_RankListRewardPop:OnBtntipsClicked()
  utils.popUpDirectionsUI({tipsID = 1163})
end

function Form_RankListRewardPop:OnBtnCloseClicked()
  self:OnBackClk()
end

function Form_RankListRewardPop:OnBtnReturnClicked()
  self:OnBackClk()
end

function Form_RankListRewardPop:OnBackClk()
  self:CloseForm()
end

function Form_RankListRewardPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_RankListRewardPop", Form_RankListRewardPop)
return Form_RankListRewardPop
