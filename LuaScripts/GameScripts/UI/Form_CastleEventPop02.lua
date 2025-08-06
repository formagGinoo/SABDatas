local Form_CastleEventPop02 = class("Form_CastleEventPop02", require("UI/UIFrames/Form_CastleEventPop02UI"))

function Form_CastleEventPop02:SetInitParam(param)
end

function Form_CastleEventPop02:AfterInit()
  self.super.AfterInit(self)
end

function Form_CastleEventPop02:OnActive()
  self.super.OnActive(self)
  local iPlaceID = self.m_csui.m_param.cfg.m_PlaceID
  local cfg = CastleManager:GetCastlePlaceCfgByID(iPlaceID)
  self.is_FullScreen = self.m_csui.m_param.is_FullScreen
  self.m_txt_title_Text.text = cfg.m_mName
  self.m_txt_content_Text.text = cfg.m_mPlaceText
  self.m_bk_hall:SetActive(self.m_csui.m_param.is_FullScreen)
  self.m_bk_event:SetActive(not self.m_csui.m_param.is_FullScreen)
  UILuaHelper.SetAtlasSprite(self.m_event_icon_Image, cfg.m_StoryPic)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(216)
end

function Form_CastleEventPop02:OnInactive()
  self.super.OnInactive(self)
end

function Form_CastleEventPop02:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleEventPop02:OnBtnCloseClicked()
  StackFlow:Push(UIDefines.ID_FORM_CASTLEEVENTMAIN, {
    cfg = self.m_csui.m_param.cfg,
    showStoryType = self.m_csui.m_param.showStoryType
  })
  self:CloseForm()
end

function Form_CastleEventPop02:IsOpenGuassianBlur()
end

function Form_CastleEventPop02:IsFullScreen()
  return self.is_FullScreen
end

local fullscreen = true
ActiveLuaUI("Form_CastleEventPop02", Form_CastleEventPop02)
return Form_CastleEventPop02
