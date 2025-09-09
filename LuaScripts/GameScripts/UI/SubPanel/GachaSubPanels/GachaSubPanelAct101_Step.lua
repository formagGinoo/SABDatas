local GachaSubPanelAct101 = require("UI/SubPanel/GachaSubPanels/GachaSubPanelAct101")
local GachaSubPanelAct101_Step = class("GachaSubPanelAct101_Step", GachaSubPanelAct101)
local isShowProgress = true
local SequencesMax = 5

function GachaSubPanelAct101_Step:OnInit()
  GachaSubPanelAct101_Step.super.OnInit(self)
  if self.m_initData.m_StepID > 0 then
    self.gachaStepCfg = GachaManager:GetStepConfigByStepID(self.m_initData.m_StepID)
    for i, v in pairs(self.gachaStepCfg) do
      local itemtext = self["m_txt_num" .. i .. "_Text"]
      if itemtext then
        itemtext.text = v.m_GachaNum
      end
      local rewardNum = self["m_txt_rewardnum" .. i .. "_Text"]
      local m_StepRewards = utils.changeCSArrayToLuaTable(v.m_StepReward)
      if rewardNum then
        rewardNum.text = "x" .. m_StepRewards[2]
      end
      ResourceUtil:CreatIconById(self["m_img_icon" .. i .. "_Image"], m_StepRewards[1])
    end
  end
  self.takenStepSeqs = {}
  for i = 1, SequencesMax do
    UILuaHelper.BindButtonClickManual(self["m_btn_reward" .. i .. "_Button"], function()
      self:ReqGetReward(i)
    end)
  end
  self:addEventListener("eGameEvent_Gacha_StepGachaGetReward", handler(self, self.OnStepGachaGetReward))
end

function GachaSubPanelAct101_Step:RefreshUI()
  GachaSubPanelAct101_Step.super.RefreshUI(self)
  self.takenStepSeqs = GachaManager:GetGachaTakenStepSeqById(self.m_initData.m_GachaID) or {}
  local gachaCount = GachaManager:GetGachaCountById(self.m_initData.m_GachaID)
  self.m_txt_extractednum_Text.text = gachaCount
  local calBetweenOver = false
  local IsAllReceived = true
  for i, v in pairs(self.gachaStepCfg) do
    UILuaHelper.SetActive(self["m_img_bg_light" .. i], false)
    UILuaHelper.SetActive(self["m_img_bg_lock" .. i], false)
    if gachaCount >= v.m_GachaNum then
      local isReceived = GachaManager:IsStepReceived(self.m_initData.m_GachaID, i)
      UILuaHelper.SetActive(self["m_img_bg_lock" .. i], isReceived)
      UILuaHelper.SetActive(self["m_img_bg_light" .. i], not isReceived)
      self:SetImageFillAmount(i - 1, 1)
      if not isReceived then
        IsAllReceived = false
      end
    elseif not calBetweenOver and i ~= 1 then
      local lastNum = GachaManager:GetCurSequencesInfo(i - 1).m_GachaNum
      local num = (gachaCount - lastNum) / (v.m_GachaNum - lastNum)
      self:SetImageFillAmount(i - 1, num)
      calBetweenOver = true
    else
      self:SetImageFillAmount(i - 1, 0)
    end
  end
  UILuaHelper.SetActive(self.m_btn_progress, not calBetweenOver and IsAllReceived)
  isShowProgress = calBetweenOver or not IsAllReceived
  self.m_pnl_progressitem:SetActive(isShowProgress)
  self.m_img_icon_r:SetActive(isShowProgress)
  self.m_img_icon_l:SetActive(not isShowProgress)
end

function GachaSubPanelAct101_Step:SetImageFillAmount(index, num)
  local image = self["m_img_line_line" .. index .. "_Image"]
  if image then
    image.fillAmount = num
  end
end

function GachaSubPanelAct101_Step:ReqGetReward(index)
  local finalSeq = {}
  local iGachaID = self.m_initData.m_GachaID
  local gachaCount = GachaManager:GetGachaCountById(iGachaID)
  for i, v in pairs(self.gachaStepCfg) do
    if i <= index and not GachaManager:IsStepReceived(iGachaID, i) and gachaCount >= v.m_GachaNum then
      table.insert(finalSeq, i)
    end
  end
  if 0 < #finalSeq then
    GachaManager:ReqGetStepReward(self.m_initData.m_GachaID, finalSeq)
  else
    local stepCfg = GachaManager:GetCurSequencesInfo(index)
    local stepReward = utils.changeCSArrayToLuaTable(stepCfg.m_StepReward)
    utils.openItemDetailPop({
      iID = stepReward[1],
      iNum = stepReward[2]
    })
  end
end

function GachaSubPanelAct101_Step:OnBtnprogressClicked()
  self.m_pnl_progressitem:SetActive(true)
  isShowProgress = not isShowProgress
  self.m_img_icon_r:SetActive(isShowProgress)
  self.m_img_icon_l:SetActive(not isShowProgress)
  if isShowProgress then
    UILuaHelper.PlayAnimationByName(self.m_pnl_progress, "ui_gacha_panel_1005_progress_in")
  else
    UILuaHelper.PlayAnimationByName(self.m_pnl_progress, "ui_gacha_panel_1005_progress_out")
  end
end

function GachaSubPanelAct101_Step:OnStepGachaGetReward(iGachaId, vReward)
  if iGachaId == self.m_initData.m_GachaID then
    utils.popUpRewardUI(vReward)
    self:OnFreshData()
  end
end

function GachaSubPanelAct101_Step:OnBtnclear10Clicked()
  self:GoGacha(10, GachaManager.GachaDiscountType.SpecialTen)
end

return GachaSubPanelAct101_Step
