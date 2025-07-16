local Form_Ending = class("Form_Ending", require("UI/UIFrames/Form_EndingUI"))

function Form_Ending:SetInitParam(param)
end

function Form_Ending:AfterInit()
  local content = CS.MultiLanguageManager.Instance:GetPlotText("PrologueEndingContent")
  self.barrageItems = {}
  for i = 1, self.m_Content.transform.childCount do
    local barrageItem = {}
    barrageItem.name = "barrageItem" .. i
    barrageItem.state = 0
    barrageItem.tf = self.m_Content.transform:GetChild(i - 1)
    barrageItem.label = barrageItem.tf:GetComponent("TextPro")
    barrageItem.label.text = content
    barrageItem.tf.gameObject:SetActive(true)
    table.insert(self.barrageItems, barrageItem)
  end
  self.rootAnimation = self.m_csui.m_uiGameObject.transform:GetComponent("Animation")
  self.lockTime = 0
end

function Form_Ending:OnActive()
  self.m_csui.m_uiGameObject:SetActive(false)
  local clipName = "VX_emding_in"
  self.rootAnimation:Play("VX_emding_in")
  local clip = self.rootAnimation:GetClip(clipName)
  self.lockTime = CS.UnityEngine.Time.realtimeSinceStartup + clip.length
  GuideManager:AddFrame(1, handler(self, self.InitView), nil, "WaitInitView")
end

function Form_Ending:OnInactive()
end

function Form_Ending:OnUpdate(dt)
end

function Form_Ending:OnDestroy()
  GuideManager:RemoveFrameByKey("ShowBarrage")
  GuideManager:RemoveTimerByKey("OnExitBattle")
  GuideManager:RemoveFrameByKey("WaitInitView")
end

function Form_Ending:InitView()
  self.m_csui.m_uiGameObject:SetActive(true)
  self.viewHeight = 650
  self.speed = 60
  self.movePos = -self.viewHeight + self.barrageItems[1].label.preferredHeight + 30
  GuideManager:AddLoopFrame(5, handler(self, self.ShowBarrage), nil, "ShowBarrage")
end

function Form_Ending:ShowBarrage()
  if self.lastBarrage and self.lastBarrage.tf.localPosition.y < self.movePos then
    return
  end
  for i = 1, #self.barrageItems do
    local barrageItem = self.barrageItems[i]
    if barrageItem.state == 0 then
      barrageItem.state = 1
      local barragePos = barrageItem.tf.localPosition
      barrageItem.tf.gameObject:SetActive(true)
      local toY = barrageItem.label.preferredHeight
      local toPos = Vector3(barragePos.x, toY, barragePos.z)
      local duration = (toY - barragePos.y) / self.speed
      CS.UI.UILuaHelper.DoMoveTween(barrageItem.tf, barragePos, toPos, duration, handler(self, self.DoMoveTweenCmp), barrageItem.name, true, false, 1)
      self.lastBarrage = barrageItem
      break
    end
  end
end

function Form_Ending:DoMoveTweenCmp(tf, fromPos, toPos)
  for i = 1, #self.barrageItems do
    local barrageItem = self.barrageItems[i]
    if barrageItem.state == 1 and barrageItem.tf == tf then
      barrageItem.state = 0
      barrageItem.tf.localPosition = Vector3(barrageItem.tf.localPosition.x, -self.viewHeight, barrageItem.tf.localPosition.z)
      barrageItem.tf.gameObject:SetActive(false)
      break
    end
  end
end

function Form_Ending:OnFightBtnClicked()
  if CS.UnityEngine.Time.realtimeSinceStartup < self.lockTime then
    return
  end
  local clipName = "VX_emding_out"
  self.rootAnimation:Play("VX_emding_out")
  local clip = self.rootAnimation:GetClip(clipName)
  local duration = clip.length
  GuideManager:AddTimer(duration, handler(self, self.OnExitBattle), nil, "OnExitBattle")
  self.lockTime = CS.UnityEngine.Time.realtimeSinceStartup + clip.length
end

function Form_Ending:OnExitBattle()
  CS.BattleGameManager.Instance:ExitBattle()
end

function Form_Ending:OnQuesBtnClicked()
  if CS.UnityEngine.Time.realtimeSinceStartup < self.lockTime then
    return
  end
end

local fullscreen = true
ActiveLuaUI("Form_Ending", Form_Ending)
return Form_Ending
