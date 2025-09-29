local Form_LoungeGuidePop2 = class("Form_LoungeGuidePop2", require("UI/UIFrames/Form_LoungeGuidePop2UI"))

function Form_LoungeGuidePop2:SetInitParam(param)
end

function Form_LoungeGuidePop2:AfterInit()
  self.super.AfterInit(self)
  self.m_DoubleTrigger = self.m_btnClose:GetComponent(typeof(CS.ButtonTriggerDoubleNew))
  if self.m_DoubleTrigger then
    self.m_DoubleTrigger.PointerDown = handler(self, self.OnPointerDown)
    self.m_DoubleTrigger.PointerUp = handler(self, self.OnBtnCloseClicked)
  end
end

function Form_LoungeGuidePop2:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_heroId = tParam.heroId
  if not self.m_heroId then
    return
  end
  self.fCLoseTimer = 0
  self.bIsTouch = false
  self:RefreshUI()
end

function Form_LoungeGuidePop2:OnUpdate(dt)
  if self.bIsTouch then
    return
  end
  self.fCLoseTimer = self.fCLoseTimer + dt
  if self.fCLoseTimer >= 2 then
    self:OnBtnCloseClicked()
  end
end

function Form_LoungeGuidePop2:OnInactive()
  self.super.OnInactive(self)
  self:broadcastEvent("eGameEvent_Lounge_GuidePop_Inactive2")
end

function Form_LoungeGuidePop2:RefreshUI()
  local idleStr = LoungeManager:GetSpineStateByIdAndState(self.m_heroId)
  local showPartList, showPartMap = LoungeManager:GetHeroUnlockPartList(self.m_heroId, idleStr)
  local heroList = LoungeManager:GetHeroChangeList()
  local idleList = LoungeManager:GetSpineAllIdleById(self.m_heroId)
  for i, v in ipairs(heroList) do
    if v.m_ID ~= self.m_heroId then
      local node = self["m_" .. tostring(v.m_ID)]
      if not utils.isNull(node) then
        node:SetActive(false)
      end
    else
      local node = self["m_" .. tostring(v.m_ID)]
      if not utils.isNull(node) then
        node:SetActive(true)
        if showPartList then
          for m = 1, #idleList do
            if idleList[m] == idleStr then
              local partNode = self["m_" .. tostring(v.m_ID) .. "_" .. tostring(idleStr)]
              if not utils.isNull(partNode) then
                partNode:SetActive(true)
              end
            else
              local partNode = self["m_" .. tostring(v.m_ID) .. "_" .. tostring(idleList[m])]
              if not utils.isNull(partNode) then
                partNode:SetActive(false)
              end
            end
          end
        end
      end
    end
  end
  self:ShowPoint(showPartMap, idleStr)
end

function Form_LoungeGuidePop2:ShowPoint(showPartMap, idleStr)
  for i = 1, self.m_uiVariables.PartMaxNum do
    if showPartMap[i] then
      local partNode2 = self["m_" .. tostring(self.m_heroId) .. "_" .. tostring(idleStr) .. "_" .. tostring(i)]
      if not utils.isNull(partNode2) then
        partNode2:SetActive(true)
      end
    else
      local partNode2 = self["m_" .. tostring(self.m_heroId) .. "_" .. tostring(idleStr) .. "_" .. tostring(i)]
      if not utils.isNull(partNode2) then
        partNode2:SetActive(false)
      end
    end
  end
end

function Form_LoungeGuidePop2:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_LoungeGuidePop2:OnPointerDown()
  self.bIsTouch = true
  local node = self["m_" .. tostring(self.m_heroId)]
  if not utils.isNull(node) then
    node:SetActive(false)
  end
end

function Form_LoungeGuidePop2:OnBtnCloseClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_LoungeGuidePop2", Form_LoungeGuidePop2)
return Form_LoungeGuidePop2
