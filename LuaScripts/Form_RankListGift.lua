local Form_RankListGift = class("Form_RankListGift", require("UI/UIFrames/Form_RankListGiftUI"))
local StateEnum = {
  CanGet = 0,
  Normal = 1,
  Got = 2
}

function Form_RankListGift:SetInitParam(param)
end

function Form_RankListGift:AfterInit()
  self.super.AfterInit(self)
  local initGiftGridData1 = {
    itemClkBackFun = handler(self, self.OnCheckClk)
  }
  self.m_TargetList_InfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_InfinityGrid, "RankList/UIRankTargetListItem", initGiftGridData1)
  self.m_TopTen_InfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollViewlistinfor_InfinityGrid, "RankList/UIRankTopTenItem")
  self.m_pnl_listinfor:SetActive(false)
end

function Form_RankListGift:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:InitData()
  self:RefreshUI()
  self.enterTime = TimeUtil:GetServerTimeS()
end

function Form_RankListGift:OnInactive()
  self.super.OnInactive(self)
  self.m_pnl_listinfor:SetActive(false)
  self.curSelectIdx = nil
  self:RemoveAllEventListeners()
  local stayTime = TimeUtil:GetServerTimeS() - self.enterTime
  RankManager:SendRankReport(0, RankManager.RankPanelReportType.RankListGift, stayTime)
  if self.timer then
    TimeService:KillTimer(self.timer)
  end
end

function Form_RankListGift:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_RankListGift:AddEventListeners()
  self:addEventListener("eGameEvent_DrawTargetReward", handler(self, self.OnDrawTargetReward))
  self:addEventListener("eGameEvent_GetTargetRank", handler(self, self.OnGetTargetRank))
end

function Form_RankListGift:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_RankListGift:OnDrawTargetReward(data)
  self:InitData()
  self:RefreshUI()
end

function Form_RankListGift:OnGetTargetRank(vRankRole)
  if not vRankRole or #vRankRole == 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(44001))
    self:OnBtnReturnlistinforClicked()
    return
  end
  self.m_pnl_listinfor:SetActive(true)
  UILuaHelper.PlayAnimationByName(self.m_pnl_listinfor, "RankListGift_listinforin")
  self.datas[self.curSelectIdx].isSelect = true
  self.m_TargetList_InfinityGrid:ReBind(self.curSelectIdx)
  self.m_TopTen_InfinityGrid:ShowItemList(vRankRole)
  self.m_TopTen_InfinityGrid:LocateTo(0)
  local list = self.m_TopTen_InfinityGrid:GetAllShownItemList()
  for k, v in ipairs(list) do
    v:RefreshItemFx((k - 1) * 0.1)
  end
end

function Form_RankListGift:InitData()
  local param = self.m_csui.m_param or {}
  self.rankID = param.rankID
  local allCfg = GlobalRankManager:FormatAndGetAllRankTargetRewardCfg()[self.rankID]
  local mmTargetRankTopRole = GlobalRankManager:GetTargetRankTopRole()
  local curRankTopRole = mmTargetRankTopRole[self.rankID]
  local mvDrawnTargetReward = GlobalRankManager:GetDrawnTargetRewardData()
  local curRewardData = mvDrawnTargetReward[self.rankID]
  local datas = {}
  local cur_target_text
  for i, cfg in ipairs(allCfg) do
    local state = StateEnum.Normal
    local topRole = curRankTopRole and curRankTopRole[cfg.m_TargetID]
    if not curRewardData or not curRewardData[i] then
      if topRole then
        state = StateEnum.CanGet
      elseif not cur_target_text then
        cur_target_text = cfg.m_mTargerDesc
      end
    else
      for _, v in ipairs(curRewardData) do
        if v == cfg.m_TargetID then
          state = StateEnum.Got
        end
      end
    end
    datas[#datas + 1] = {
      cfg = cfg,
      state = state,
      topRole = topRole
    }
  end
  self.m_txt_rankName_Text.text = cur_target_text or ConfigManager:GetCommonTextById(100414)
  table.sort(datas, function(a, b)
    if a.state ~= b.state then
      return a.state < b.state
    else
      return a.cfg.m_TargetID < b.cfg.m_TargetID
    end
  end)
  self.datas = datas
end

function Form_RankListGift:RefreshUI()
  self.m_TargetList_InfinityGrid:ShowItemList(self.datas)
  self.m_TargetList_InfinityGrid:LocateTo(0)
  local list = self.m_TargetList_InfinityGrid:GetAllShownItemList()
  for k, v in ipairs(list) do
    v:RefreshItemFx((k - 1) * 0.1)
  end
end

function Form_RankListGift:OnCheckClk(index, go)
  local idx = index + 1
  if self.curSelectIdx == idx then
    return
  end
  if self.datas[self.curSelectIdx] then
    self.datas[self.curSelectIdx].isSelect = false
    self.m_TargetList_InfinityGrid:ReBind(self.curSelectIdx)
  end
  self.curSelectIdx = idx
  local data = self.datas[idx]
  GlobalRankManager:RqsRankGetTargetRank(data.cfg.m_RankID, data.cfg.m_TargetID)
end

function Form_RankListGift:OnBtnCloseClicked()
  self:OnBackClk()
end

function Form_RankListGift:OnBtnReturnClicked()
  self:OnBackClk()
end

function Form_RankListGift:OnBackClk()
  self:CloseForm()
end

function Form_RankListGift:OnBtntipsClicked()
  utils.popUpDirectionsUI({tipsID = 1164})
end

function Form_RankListGift:OnBtnReturnlistinforClicked()
  if self.datas[self.curSelectIdx] then
    self.datas[self.curSelectIdx].isSelect = false
    self.m_TargetList_InfinityGrid:ReBind(self.curSelectIdx)
    self.curSelectIdx = nil
    UILuaHelper.PlayAnimationByName(self.m_pnl_listinfor, "RankListGift_listinforout")
    local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_pnl_listinfor, "RankListGift_listinforout")
    self.timer = TimeService:SetTimer(aniLen, 1, function()
      self.m_pnl_listinfor:SetActive(false)
    end)
  end
end

function Form_RankListGift:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_RankListGift", Form_RankListGift)
return Form_RankListGift
