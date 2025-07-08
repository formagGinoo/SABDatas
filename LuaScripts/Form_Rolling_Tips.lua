local Form_Rolling_Tips = class("Form_Rolling_Tips", require("UI/UIFrames/Form_Rolling_TipsUI"))

function Form_Rolling_Tips:SetInitParam(param)
end

function Form_Rolling_Tips:GetRootTransformType()
  return UIRootTransformType.Top
end

function Form_Rolling_Tips:AfterInit()
  self.super.AfterInit(self)
  self.bg_width = self.m_content:GetComponent("RectTransform").rect.width
  self.m_content:SetActive(false)
  self.m_queue = {}
end

function Form_Rolling_Tips:OnActive()
  self.super.OnActive(self)
  local param = self.m_csui.m_param
  if param and type(param) == "table" then
    self.m_queue = param
  end
  self:ResetPos()
end

function Form_Rolling_Tips:OnInactive()
  self.super.OnInactive(self)
  self.m_csui.m_param = nil
  self:DestroySequence()
end

function Form_Rolling_Tips:ResetPos()
  UIUtil.setLocalPosition(self.m_txt_tips.transform, self.bg_width * 0.5)
  local sequence = Tweening.DOTween.Sequence()
  sequence:AppendInterval(self.m_csui.m_param.delay_open or 0.1)
  sequence:OnComplete(function()
    if not utils.isNull(self.m_content) then
      self.m_delay_open_sequence = nil
      self.m_content:SetActive(true)
      self:RefreshUI()
    end
  end)
  sequence:SetAutoKill(true)
end

function Form_Rolling_Tips:AddTips(data)
  table.insert(self.m_queue, data)
end

function Form_Rolling_Tips:GetTips()
  local data = self.m_queue[1]
  table.remove(self.m_queue, 1)
  return data
end

function Form_Rolling_Tips:RefreshUI()
  self:DoTipsMove()
end

function Form_Rolling_Tips:DoTipsMove()
  local data = self:GetTips()
  if data and not self:isInActivityTime(data) then
    self:RefreshUI()
    return
  end
  if data then
    self.m_content:SetActive(true)
    self.m_txt_tips_Text.text = tostring(data.sContent)
    self.m_txt_tips:GetComponent("ContentSizeFitter"):SetLayoutHorizontal()
    local width = self.m_txt_tips:GetComponent("RectTransform").rect.width
    UIUtil.setLocalPosition(self.m_txt_tips.transform, width + self.bg_width * 0.5)
    local speed = 100
    local sequence = Tweening.DOTween.Sequence()
    sequence:Append(self.m_txt_tips.transform:DOLocalMoveX(-self.bg_width * 0.5, (width + self.bg_width) / speed):SetEase(Tweening.Ease.Linear))
    sequence:OnComplete(function()
      if self and not utils.isNull(self.m_content) and data and data.iDisplayInterval ~= 0 then
        self.m_content:SetActive(false)
      end
      local sequence2 = Tweening.DOTween.Sequence()
      sequence2:AppendInterval(data.iDisplayInterval or 0)
      sequence2:AppendCallback(function()
        self.m_tips_sequence = nil
        if self.m_tips_sequence2 then
          self.m_tips_sequence2:Kill()
          self.m_tips_sequence2 = nil
        end
        self:RefreshUI()
      end)
      sequence2:SetAutoKill(true)
      self.m_tips_sequence2 = sequence2
    end)
    sequence:SetAutoKill(true)
    self.m_tips_sequence = sequence
  else
    self:CloseView()
  end
end

function Form_Rolling_Tips:isInActivityTime(data)
  if data.iBeginTime == 0 or data.iEndTime == 0 then
    return false
  end
  return TimeUtil:IsInTime(data.iBeginTime, data.iEndTime)
end

function Form_Rolling_Tips:DestroySequence()
  if self.m_delay_open_sequence then
    self.m_delay_open_sequence:Kill()
    self.m_delay_open_sequence = nil
  end
  if self.m_tips_sequence then
    self.m_tips_sequence:Kill()
    self.m_tips_sequence = nil
  end
  if self.m_tips_sequence2 then
    self.m_tips_sequence2:Kill()
    self.m_tips_sequence2 = nil
  end
end

function Form_Rolling_Tips:CloseView()
  self:DestroySequence()
  self:CloseForm()
end

function Form_Rolling_Tips:OnDestroy()
  self:DestroySequence()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_Rolling_Tips", Form_Rolling_Tips)
return Form_Rolling_Tips
