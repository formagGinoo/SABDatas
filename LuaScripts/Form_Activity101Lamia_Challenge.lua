local Form_Activity101Lamia_Challenge = class("Form_Activity101Lamia_Challenge", require("UI/UIFrames/Form_Activity101Lamia_ChallengeUI"))
local MaxLevelNum = 5
local LevelDetailAnimInStr = "Lamia_Challenge_in2"
local LevelDetailAnimOutStr = "Lamia_Challenge_out2"

function Form_Activity101Lamia_Challenge:AfterInit()
  self.super.AfterInit(self)
  self.m_bgTrans = self.m_pnl_effectbg.transform
end

function Form_Activity101Lamia_Challenge:OnActive()
  self.super.OnActive(self)
  GlobalManagerIns:TriggerWwiseBGMState(98)
end

function Form_Activity101Lamia_Challenge:FreshLevelDetailShow(forceHide)
  if forceHide then
    UILuaHelper.SetActive(self.m_level_detail_root, false)
    UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Lamia_Challenge_return")
    return
  end
  if self.m_curDetailLevelID then
    UILuaHelper.SetActive(self.m_level_detail_root, true)
    UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Lamia_Challenge_choose")
    if self.m_luaDetailLevel == nil then
      self:CreateSubPanel("LevelDetailLamiaSubPanel", self.m_level_detail_root, self, {
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
    UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Lamia_Challenge_return")
  end
end

function Form_Activity101Lamia_Challenge:ChooseItemTween(index)
  if not index then
    return
  end
  if index > MaxLevelNum then
    return
  end
  self.super.ChooseItemTween(self, index)
  UILuaHelper.PlayAnimationByName(self.m_rootTrans, LevelDetailAnimInStr)
end

function Form_Activity101Lamia_Challenge:BackTweenToInit()
  self.super.BackTweenToInit(self)
  UILuaHelper.PlayAnimationByName(self.m_rootTrans, LevelDetailAnimOutStr)
end

function Form_Activity101Lamia_Challenge:OnBtnheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_CHALLENGEHERO, {
    activityID = self.m_activityID
  })
end

function Form_Activity101Lamia_Challenge:OnBtnrewardClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_CHALLENGEREWARD, {
    activityID = self.m_activityID,
    activitySubID = self.m_activitySubID
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity101Lamia_Challenge", Form_Activity101Lamia_Challenge)
return Form_Activity101Lamia_Challenge
