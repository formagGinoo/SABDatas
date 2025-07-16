local Form_AttractTimelineTransform = class("Form_AttractTimelineTransform", require("UI/UIFrames/Form_AttractTimelineTransformUI"))

function Form_AttractTimelineTransform:SetInitParam(param)
end

function Form_AttractTimelineTransform:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
end

function Form_AttractTimelineTransform:OnActive()
  self.super.OnActive(self)
  self:InitView()
end

function Form_AttractTimelineTransform:OnInactive()
  self.super.OnInactive(self)
end

function Form_AttractTimelineTransform:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_AttractTimelineTransform:InitView()
  local tParam = self.m_csui.m_param
  local stStoryData = tParam.stStoryData
  local curShowHeroData = tParam.curShowHeroData
  self.m_txt_title1_Text.text = stStoryData.m_mSectionTitle
  self.m_txt_shortdesc_Text.text = stStoryData.m_mText
  local animLen = UILuaHelper.GetAnimationLengthByName(self.m_rootTrans, "AttractTimelineTransform_in")
  TimeService:SetTimer(animLen, 1, function()
    CS.VisualFavorability.LoadFavorability(stStoryData.m_TimelineType, stStoryData.m_TimelineId, function()
      if not AttractManager:HasSawStory(curShowHeroData.serverData.iHeroId, stStoryData.m_StoryId) then
        AttractManager:ReqSeeStory(curShowHeroData.serverData.iHeroId, stStoryData.m_StoryId)
      end
      CS.UI.UILuaHelper.HideMainUI()
    end, function()
      CS.UI.UILuaHelper.ShowMainUI()
      self:CloseForm()
    end)
  end)
end

function Form_AttractTimelineTransform:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_AttractTimelineTransform", Form_AttractTimelineTransform)
return Form_AttractTimelineTransform
