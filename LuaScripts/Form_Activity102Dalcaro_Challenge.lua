local Form_Activity102Dalcaro_Challenge = class("Form_Activity102Dalcaro_Challenge", require("UI/UIFrames/Form_Activity102Dalcaro_ChallengeUI"))

function Form_Activity102Dalcaro_Challenge:SetInitParam(param)
end

function Form_Activity102Dalcaro_Challenge:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity102Dalcaro_Challenge:OnActive()
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(120)
end

function Form_Activity102Dalcaro_Challenge:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity102Dalcaro_Challenge:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity102Dalcaro_Challenge:FreshLevelDetailShow(forceHide)
  if forceHide then
    UILuaHelper.SetActive(self.m_level_detail_root, false)
    UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Dalcaro_Challenge_return")
    return
  end
  if self.m_curDetailLevelID then
    UILuaHelper.SetActive(self.m_level_detail_root, true)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(121)
    UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Dalcaro_Challenge_choose")
    if self.m_luaDetailLevel == nil then
      self:CreateSubPanel("LevelDetailDalcaroSubPanel", self.m_level_detail_root, self, {
        bgBackFun = handler(self, self.OnLevelDetailBgClick)
      }, {
        activityID = self.m_activityID,
        levelID = self.m_curDetailLevelID
      }, function(luaPanel)
        self.m_luaDetailLevel = luaPanel
        self.m_luaDetailLevel:AddEventListeners()
      end)
    else
      self.m_luaDetailLevel:FreshData({
        activityID = self.m_activityID,
        levelID = self.m_curDetailLevelID
      })
    end
  else
    UILuaHelper.SetActive(self.m_level_detail_root, false)
    CS.GlobalManager.Instance:TriggerWwiseBGMState(122)
    UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Dalcaro_Challenge_return")
  end
end

function Form_Activity102Dalcaro_Challenge:OnBtnheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_CHALLENGEHERO, {
    activityID = self.m_activityID
  })
end

function Form_Activity102Dalcaro_Challenge:OnBtnrewardClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_CHALLENGEREWARD, {
    activityID = self.m_activityID,
    activitySubID = self.m_activitySubID
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity102Dalcaro_Challenge", Form_Activity102Dalcaro_Challenge)
return Form_Activity102Dalcaro_Challenge
