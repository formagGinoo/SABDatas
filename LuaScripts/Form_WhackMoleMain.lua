local Form_WhackMoleMain = class("Form_WhackMoleMain", require("UI/UIFrames/Form_WhackMoleMainUI"))

function Form_WhackMoleMain:SetInitParam(param)
end

function Form_WhackMoleMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
end

function Form_WhackMoleMain:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.main_id = tParam.main_id
  self.sub_id = tParam.sub_id
end

function Form_WhackMoleMain:OnInactive()
  self.super.OnInactive(self)
end

function Form_WhackMoleMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_WhackMoleMain:OnBackClk()
  self:CloseForm()
end

function Form_WhackMoleMain:OnBtntaskClicked()
  HeroActivityManager:GotoHeroActivity({main_id = 1030, sub_id = 1038})
end

function Form_WhackMoleMain:OnBtnstartClicked()
  local param = {
    main_id = self.main_id,
    sub_id = self.sub_id
  }
  StackPopup:Push(UIDefines.ID_FORM_WHACKMOLELEVELSELECT, param)
end

local fullscreen = true
ActiveLuaUI("Form_WhackMoleMain", Form_WhackMoleMain)
return Form_WhackMoleMain
