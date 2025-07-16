local Form_CommonTips = class("Form_CommonTips", require("UI/UIFrames/Form_CommonTipsUI"))
local CommonTextIns = ConfigManager:GetConfigInsByName("CommonText")
local ConfirmCommonTipsIns = ConfigManager:GetConfigInsByName("ConfirmCommonTips")
local ConfirmCommonTipsStyle = {
  OneButton = 1,
  TwoButton = 2,
  OneButtonAutoConfirm = 3,
  TwoButtonAutoConfirm = 6
}

function Form_CommonTips:SetInitParam(param)
end

function Form_CommonTips:GetRootTransformType()
  return UIRootTransformType.Top
end

function Form_CommonTips:AfterInit()
end

function Form_CommonTips:OnActive()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self:SetLockTop(tParam.bLockTop)
  self.m_BtnYesBack = nil
  self.m_BtnNoBack = nil
  self.m_BtnYes2Back = nil
  self.m_param = tParam
  self.m_contentOri = nil
  self:CheckFreshParam()
  self:CheckShowContent()
  self:CheckShowTitle()
  self:CheckShowButtons()
  self:CheckShowConsumePanel()
  if self.m_param.btnNum == ConfirmCommonTipsStyle.OneButtonAutoConfirm then
    self.m_bShowAutoConfirm = true
    self.m_txt_yes_countdown_02:SetActive(true)
    self.m_txt_yes_countdown:SetActive(false)
    self.m_fAutoConfirmTime = 0
    self.m_sAutoConfirmText = CommonTextIns:GetValue_ById(20024).m_mMessage
    self:RefreshAutoConfirm(0)
  elseif self.m_param.btnNum == ConfirmCommonTipsStyle.TwoButtonAutoConfirm then
    self.m_bShowAutoConfirm = true
    self.m_txt_yes_countdown_02:SetActive(false)
    self.m_txt_yes_countdown:SetActive(true)
    self.m_fAutoConfirmTime = 0
    self.m_sAutoConfirmText = CommonTextIns:GetValue_ById(20024).m_mMessage
    self:RefreshAutoConfirm(0)
  else
    self.m_bShowAutoConfirm = false
    self.m_txt_yes_countdown_02:SetActive(false)
    self.m_txt_yes_countdown:SetActive(false)
  end
  self.m_bAutoClose = true
  if self.m_param.bAutoClose ~= nil then
    self.m_bAutoClose = self.m_param.bAutoClose
  end
  self.m_Btn_Close:SetActive(not self.m_param.bLockBack)
end

function Form_CommonTips:OnInactive()
  self:SetLockTop(false)
  self.m_BtnYesBack = nil
  self.m_BtnNoBack = nil
  self.m_BtnYes2Back = nil
  self.m_param = nil
  utils.CheckAndPushCommonTips()
end

function Form_CommonTips:OnUpdate(dt)
  if self.m_param then
    if self.m_param.btnNum == ConfirmCommonTipsStyle.OneButtonAutoConfirm or self.m_param.btnNum == ConfirmCommonTipsStyle.TwoButtonAutoConfirm then
      self:RefreshAutoConfirm(dt)
    end
    if self.m_param.bUpdateContent then
      self:CheckFreshParam()
      self:CheckShowContent()
    end
  end
end

function Form_CommonTips:SetLockTop(enable)
  if self.m_isLockTop == enable then
    return
  end
  self.m_isLockTop = enable
  if enable then
    self.m_csui.RootCanvas.sortingOrder = 11000
    self.m_csui.AnimatorTranser.enabled = false
  else
    self.m_csui.RootCanvas.sortingOrder = self.m_csui.SortingOrder
    self.m_csui.AnimatorTranser.enabled = true
  end
end

function Form_CommonTips:CheckFreshParam()
  if self.m_contentOri == nil then
    local tipsID = self.m_param.tipsID
    if tipsID and type(tipsID) == "number" then
      local commonTextCfg = ConfirmCommonTipsIns:GetValue_ByID(tipsID)
      if not commonTextCfg:GetError() then
        self.m_param.content = commonTextCfg.m_mcontent or ""
        self.m_param.title = commonTextCfg.m_mtitle or ""
        self.m_param.funcText1 = commonTextCfg.m_mbutton1text or ""
        self.m_param.btnNum = commonTextCfg.m_style
        self.m_param.m_isShowTitle = commonTextCfg.m_isShowTitle or 0
        if commonTextCfg.m_style == ConfirmCommonTipsStyle.TwoButton or commonTextCfg.m_style == ConfirmCommonTipsStyle.TwoButtonAutoConfirm then
          self.m_param.funcText2 = commonTextCfg.m_mbutton2text or ""
        end
        self.m_param.fAutoConfirmDelay = commonTextCfg.m_autoConfirmDelay
        if not self.m_param.bLockBack then
          self.m_param.bLockBack = commonTextCfg.m_NoClosing ~= 0
        end
        self.m_Btn_Close:SetActive(not self.m_param.bLockBack)
      end
    end
    self.m_contentOri = self.m_param.content or ""
  end
  if self.m_param.fContentCB then
    self.m_param.content = self.m_param.fContentCB(self.m_contentOri)
  end
end

function Form_CommonTips:RefreshAutoConfirm(dt)
  local bShowAutoConfirm = true
  if self.m_param.fRefreshAutoConfirmCB then
    bShowAutoConfirm = self.m_param.fRefreshAutoConfirmCB()
  end
  if self.m_bShowAutoConfirm ~= bShowAutoConfirm then
    if bShowAutoConfirm then
      if self.m_param.btnNum == ConfirmCommonTipsStyle.OneButtonAutoConfirm then
        self.m_txt_yes_countdown_02:SetActive(true)
      else
        self.m_txt_yes_countdown:SetActive(true)
      end
      self.m_fAutoConfirmTime = 0
    else
      self.m_txt_yes_countdown_02:SetActive(false)
      self.m_txt_yes_countdown:SetActive(false)
    end
    self.m_bShowAutoConfirm = bShowAutoConfirm
  end
  if self.m_bShowAutoConfirm then
    self.m_fAutoConfirmTime = self.m_fAutoConfirmTime + dt
    local fRemainTime = self.m_param.fAutoConfirmDelay - self.m_fAutoConfirmTime
    if self.m_param.btnNum == ConfirmCommonTipsStyle.OneButtonAutoConfirm then
      self.m_txt_yes_countdown_02_Text.text = string.gsub(self.m_sAutoConfirmText, "{num}", math.ceil(fRemainTime))
    else
      self.m_txt_yes_countdown_Text.text = string.gsub(self.m_sAutoConfirmText, "{num}", math.ceil(fRemainTime))
    end
    if fRemainTime <= 0 then
      self.m_fAutoConfirmTime = 0
      if self.m_param.btnNum == ConfirmCommonTipsStyle.OneButtonAutoConfirm then
        self:OnBtnyes02Clicked(true)
      else
        self:OnBtnyesClicked(true)
      end
    end
  end
end

function Form_CommonTips:GetShowStr(textStrOrID)
  if not textStrOrID then
    return
  end
  local showStr = textStrOrID or ""
  if type(textStrOrID) == "number" then
    local showMessageCfg = CommonTextIns:GetValue_ById(textStrOrID)
    if showMessageCfg and showMessageCfg.m_mMessage then
      showStr = showMessageCfg.m_mMessage
    end
  end
  return showStr
end

function Form_CommonTips:CheckShowContent()
  if not self.m_param then
    return
  end
  local contentShowStr = self:GetShowStr(self.m_param.content) or ""
  self.m_word_Text.text = contentShowStr
  local contentAlign = self.m_param.contentAlign
  if contentAlign == nil then
    contentAlign = CS.TMPro.TextAlignmentOptions.Center
  end
  self.m_word_Text.alignment = contentAlign
end

function Form_CommonTips:CheckShowTitle()
  self.m_txt_title_bg:SetActive(false)
  if not self.m_param then
    return
  end
  if self.m_param.m_isShowTitle and self.m_param.m_isShowTitle == 1 and self.m_param.title then
    self.m_txt_title_bg:SetActive(true)
    self.m_txt_title_Text.text = tostring(self.m_param.title)
  end
end

function Form_CommonTips:CheckShowConsumePanel()
  if not self.m_param then
    return
  end
  self.m_consume_node:SetActive(self.m_param.consumeData)
  if self.m_param.consumeData then
    local consumeData = self.m_param.consumeData
    ResourceUtil:CreatIconById(self.m_consume_icon_Image, consumeData[1])
    local userNum = ItemManager:GetItemNum(tonumber(consumeData[1]), true)
    self.m_consume_num_Text.text = tostring(consumeData[2])
    if userNum < tonumber(consumeData[2]) then
      UILuaHelper.SetColor(self.m_consume_num_Text, 255, 0, 0, 1)
    else
      UILuaHelper.SetColor(self.m_consume_num_Text, 255, 255, 255, 1)
    end
  end
end

function Form_CommonTips:CheckShowButtons()
  if self.m_param.btnNum == ConfirmCommonTipsStyle.TwoButton or self.m_param.btnNum == ConfirmCommonTipsStyle.TwoButtonAutoConfirm then
    self.m_btn_yes_02:SetActive(false)
    self.m_btn_yes:SetActive(true)
    self.m_btn_no:SetActive(true)
    self.m_BtnYesBack = self.m_param.func1
    self.m_BtnNoBack = self.m_param.func2
    self.m_txt_yes_Text.text = self:GetShowStr(self.m_param.funcText1) or "Yes"
    self.m_txt_no_Text.text = self:GetShowStr(self.m_param.funcText2) or "No"
  else
    self.m_btn_yes_02:SetActive(true)
    self.m_btn_yes:SetActive(false)
    self.m_btn_no:SetActive(false)
    self.m_BtnYes2Back = self.m_param.func1
    self.m_BtnNoBack = self.m_param.func2
    self.m_txt_yes_01_Text.text = self:GetShowStr(self.m_param.funcText1) or "Yes"
  end
  local sizeDelta = self.m_word:GetComponent("RectTransform").sizeDelta
  if self.m_param.showToggle then
    self.m_Toggle:SetActive(true)
    self.m_Toggle_Toggle.isOn = false
    if self.m_param.toggleText then
      self.m_toggle_txt_Text.text = self.m_param.toggleText
    else
      self.m_toggle_txt_Text.text = ConfigManager:GetCommonTextById(20095)
    end
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_Toggle)
    sizeDelta.y = 290
    self.m_word:GetComponent("RectTransform").sizeDelta = sizeDelta
  else
    self.m_Toggle:SetActive(false)
    sizeDelta.y = 350
    self.m_word:GetComponent("RectTransform").sizeDelta = sizeDelta
  end
  if self.m_param.bShowToggleYes then
    self.m_toggle_yes:SetActive(true)
    self.m_toggle_yes_Toggle.isOn = self.m_param.bToggleYesDefault
    self.m_txt_toggle_yes_Text.text = self.m_param.sToggleYesDesc or ""
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_toggle_yes)
  else
    self.m_toggle_yes:SetActive(false)
  end
  self.m_btn_Return:SetActive(not self.m_param.bLockBack)
end

function Form_CommonTips:CloseUI()
  CS.UI.UILuaHelper.StartPlaySFX("Play_ui_button_confirm")
  self:SetDayCount()
  StackTop:RemoveUIFromStack(UIDefines.ID_FORM_COMMONTIPS)
end

function Form_CommonTips:OnBtnyesClicked(bAutoConfirm)
  if self.m_BtnYesBack then
    self.m_BtnYesBack(bAutoConfirm)
    self:SetToggleStateCB()
  end
  self:SaveToggleYes()
  if self.m_bAutoClose then
    self:CloseUI()
  end
end

function Form_CommonTips:OnBtnnoClicked()
  if self.m_BtnNoBack then
    self.m_BtnNoBack()
  end
  if self.m_bAutoClose then
    self:CloseUI()
  end
end

function Form_CommonTips:OnBtnyes02Clicked(bAutoConfirm)
  if self.m_BtnYes2Back then
    self.m_BtnYes2Back(bAutoConfirm)
    self:SetToggleStateCB()
  end
  if self.m_bAutoClose then
    self:CloseUI()
  end
end

function Form_CommonTips:OnBtnCloseClicked()
  if self.m_param and self.m_param.bLockBack then
    return
  end
  if self.m_BtnNoBack and not self.m_param.onlyCancleCB then
    self.m_BtnNoBack()
  end
  self:CloseUI()
end

function Form_CommonTips:OnBtnReturnClicked()
  if self.m_param and self.m_param.bLockBack then
    return
  end
  if self.m_BtnNoBack and not self.m_param.onlyCancleCB then
    self.m_BtnNoBack()
  end
  self:CloseUI()
end

function Form_CommonTips:SetDayCount()
  if self.m_Toggle_Toggle.isOn and self.m_param and not string.IsNullOrEmpty(self.m_param.systemKey) then
    CS.UI.UILuaHelper.SetDayCount(self.m_param.systemKey, 1)
  end
end

function Form_CommonTips:SetToggleStateCB()
  if self.m_param and self.m_param.toggleCallBack then
    self.m_param.toggleCallBack(self.m_Toggle_Toggle.isOn)
  end
end

function Form_CommonTips:SaveToggleYes()
  if self.m_param and self.m_param.bShowToggleYes and self.m_param.fToggleYesCB then
    self.m_param.fToggleYesCB(self.m_toggle_yes_Toggle.isOn)
  end
end

function Form_CommonTips:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_CommonTips", Form_CommonTips)
return Form_CommonTips
