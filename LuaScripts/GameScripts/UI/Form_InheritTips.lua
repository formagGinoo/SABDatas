local Form_InheritTips = class("Form_InheritTips", require("UI/UIFrames/Form_InheritTipsUI"))
local CommonTextIns = ConfigManager:GetConfigInsByName("CommonText")
local ConfirmCommonTipsIns = ConfigManager:GetConfigInsByName("ConfirmCommonTips")
local ConfirmCommonTipsStyle = {
  OneButton = 1,
  TwoButton = 2,
  OneButtonAutoConfirm = 3
}

function Form_InheritTips:SetInitParam(param)
end

function Form_InheritTips:AfterInit()
end

function Form_InheritTips:OnActive()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_BtnYesBack = nil
  self.m_BtnNoBack = nil
  self.m_param = tParam
  self:CheckFreshParam()
  self:CheckShowContent()
  self:CheckShowButtons()
  self:ShowLevelInfoPanel()
  self:ShowCDPanel()
  self:ShowHeroPanel()
end

function Form_InheritTips:OnInactive()
  self.m_BtnYesBack = nil
  self.m_BtnNoBack = nil
  self.m_param = nil
end

function Form_InheritTips:CheckFreshParam()
  local tipsID = self.m_param.tipsID
  if tipsID and type(tipsID) == "number" then
    local commonTextCfg = ConfirmCommonTipsIns:GetValue_ByID(tipsID)
    if not commonTextCfg:GetError() then
      self.m_param.content = commonTextCfg.m_mcontent or ""
      self.m_param.title = commonTextCfg.m_mtitle or ""
      self.m_param.funcText1 = commonTextCfg.m_mbutton1text or ""
      self.m_param.btnNum = commonTextCfg.m_style
      if commonTextCfg.m_style == 2 then
        self.m_param.funcText2 = commonTextCfg.m_mbutton2text or ""
      end
      self.m_param.fAutoConfirmDelay = commonTextCfg.m_autoConfirmDelay
    end
  end
  if self.m_param.fContentCB then
    self.m_param.content = self.m_param.fContentCB(self.m_param.content)
  end
end

function Form_InheritTips:GetShowStr(textStrOrID)
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

function Form_InheritTips:CheckShowContent()
  if not self.m_param then
    return
  end
  local contentShowStr = self:GetShowStr(self.m_param.content) or ""
  self.m_word_Text.text = contentShowStr
end

function Form_InheritTips:CheckShowTitle()
  if not self.m_param then
    return
  end
  local showTitleStr = self:GetShowStr(self.m_param.title) or ""
  self.m_txt_title_Text.text = showTitleStr
end

function Form_InheritTips:CheckShowButtons()
  if self.m_param.btnNum == ConfirmCommonTipsStyle.TwoButton then
    self.m_btn_yes:SetActive(true)
    self.m_btn_no:SetActive(true)
    self.m_BtnYesBack = self.m_param.func1
    self.m_BtnNoBack = self.m_param.func2
    self.m_txt_yes_Text.text = self:GetShowStr(self.m_param.funcText1) or "Yes"
    self.m_txt_no_Text.text = self:GetShowStr(self.m_param.funcText2) or "No"
  end
end

function Form_InheritTips:ShowHeroPanel()
  if self.m_param.heroId then
    if self.m_itemIcon == nil then
      self.m_itemIcon = self:createHeroIcon(self.m_common_hero_small)
    end
    local heroData = HeroManager:GetHeroDataByID(self.m_param.heroId)
    local level = 1
    if heroData and heroData.serverData then
      level = heroData.serverData.iLevel
    end
    self.m_itemIcon:SetHeroData(heroData.serverData)
  end
end

function Form_InheritTips:ShowLevelInfoPanel()
  local levelInfo = self.m_param.levelInfo
  if levelInfo then
    self.m_txt_lv_before_Text.text = tostring(levelInfo.oldLv)
    self.m_txt_lv_after_Text.text = tostring(levelInfo.newLv)
    self.m_txt_lv_after_red_Text.text = tostring(levelInfo.newLv)
    self.m_img_arrow_green:SetActive(levelInfo.oldLv <= levelInfo.newLv)
    self.m_img_arrow_red:SetActive(levelInfo.oldLv > levelInfo.newLv)
    self.m_txt_lv_after:SetActive(levelInfo.oldLv <= levelInfo.newLv)
    self.m_txt_lv_after_red:SetActive(levelInfo.oldLv > levelInfo.newLv)
    self.m_txt_level_after:SetActive(levelInfo.oldLv <= levelInfo.newLv)
    self.m_txt_level_after_red:SetActive(levelInfo.oldLv > levelInfo.newLv)
  end
end

function Form_InheritTips:ShowCDPanel()
  if self.m_param.cd then
    self.m_bg_cd:SetActive(true)
    self.m_txt_time_Text.text = self.m_param.cd
  else
    self.m_bg_cd:SetActive(false)
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_bg_cd)
end

function Form_InheritTips:CloseUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackTop:RemoveUIFromStack(UIDefines.ID_FORM_INHERITTIPS)
end

function Form_InheritTips:OnBtnyesClicked()
  if self.m_BtnYesBack then
    self.m_BtnYesBack()
  end
  self:CloseUI()
end

function Form_InheritTips:OnBtnnoClicked()
  if self.m_BtnNoBack then
    self.m_BtnNoBack()
  end
  self:CloseUI()
end

function Form_InheritTips:OnBtnReturnClicked()
  if self.m_BtnNoBack then
    self.m_BtnNoBack()
  end
  self:CloseUI()
end

function Form_InheritTips:OnBtnCloseClicked()
  if self.m_BtnNoBack then
    self.m_BtnNoBack()
  end
  self:CloseUI()
end

function Form_InheritTips:OnFullbackClicked()
  if self.m_param and self.m_param.bLockBack then
    return
  end
  if self.m_BtnNoBack then
    self.m_BtnNoBack()
  end
  self:CloseUI()
end

function Form_InheritTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_InheritTips", Form_InheritTips)
return Form_InheritTips
