local GachaSubPanelAct101 = require("UI/SubPanel/GachaSubPanels/GachaSubPanelAct101")
local GachaSubPanelAct101_Step = class("GachaSubPanelAct101_Step", GachaSubPanelAct101)
local isShowProgress = true

function GachaSubPanelAct101_Step:OnInit()
  GachaSubPanelAct101_Step.super.OnInit(self)
  if self.m_initData.m_StepID > 0 then
    local stepId = self.m_initData.m_StepID
    local gachaStepIns = ConfigManager:GetConfigInsByName("GachaStep")
    self.gachaStepCfg = gachaStepIns:GetValue_ByStepID(stepId) or {}
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
      local isReceived = self:IsStepReceived(i)
      UILuaHelper.SetActive(self["m_img_bg_lock" .. i], isReceived)
      UILuaHelper.SetActive(self["m_img_bg_light" .. i], not isReceived)
      self:SetImageFillAmount(i - 1, 1)
      if not isReceived then
        IsAllReceived = false
      end
    elseif not calBetweenOver and i ~= 1 then
      local lastNum = self:GetCurStepInfo(i - 1).m_GachaNum
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

function GachaSubPanelAct101_Step:GetCurStepInfo(sequencesId)
  for id, v in pairs(self.gachaStepCfg) do
    if id == sequencesId then
      return v
    end
  end
  return nil
end

function GachaSubPanelAct101_Step:IsStepReceived(stepId)
  for _, claimedId in ipairs(self.takenStepSeqs) do
    if claimedId == stepId then
      return true
    end
  end
  return false
end

function GachaSubPanelAct101_Step:IsAllReceived()
  for i, v in pairs(self.gachaStepCfg) do
    local isReceived = self:IsStepReceived(i)
    if not isReceived then
      return false
    end
  end
  return true
end

function GachaSubPanelAct101_Step:ReqGetReward(index)
  local finalSeq = {}
  local gachaCount = GachaManager:GetGachaCountById(self.m_initData.m_GachaID)
  for i, v in pairs(self.gachaStepCfg) do
    if i <= index and not self:IsStepReceived(i) and gachaCount >= v.m_GachaNum then
      table.insert(finalSeq, i)
    end
  end
  if 0 < #finalSeq then
    local reqMsg = MTTDProto.Cmd_Gacha_TakeStepSeq_SC()
    reqMsg.iGachaId = self.m_initData.m_GachaID
    reqMsg.vSeq = finalSeq
    RPCS():Gacha_TakeStepSeq(reqMsg, function(sc)
      for _, v in pairs(sc.vSeq) do
        table.insert(self.takenStepSeqs, v)
      end
      GachaManager:SetGachaTakenStepSeqById(sc.iGachaId, self.takenStepSeqs)
      utils.popUpRewardUI(sc.vReward)
      self:OnFreshData()
      self:broadcastEvent("eGameEvent_Gacha_StepGachaGetReward", self.m_initData.m_GachaID)
    end)
  else
    local stepCfg = self:GetCurStepInfo(index)
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

function GachaSubPanelAct101_Step:OnBtnreward1Clicked()
  self:ReqGetReward(1)
end

function GachaSubPanelAct101_Step:OnBtnreward2Clicked()
  self:ReqGetReward(2)
end

function GachaSubPanelAct101_Step:OnBtnreward3Clicked()
  self:ReqGetReward(3)
end

function GachaSubPanelAct101_Step:OnBtnreward4Clicked()
  self:ReqGetReward(4)
end

function GachaSubPanelAct101_Step:OnBtnreward5Clicked()
  self:ReqGetReward(5)
end

function GachaSubPanelAct101_Step:OnBtnclear10Clicked()
  self:GoGacha(10, GachaManager.GachaDiscountType.SpecialTen)
end

return GachaSubPanelAct101_Step
