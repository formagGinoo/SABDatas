local Form_InheritLevelupPop = class("Form_InheritLevelupPop", require("UI/UIFrames/Form_InheritLevelupPopUI"))

function Form_InheritLevelupPop:SetInitParam(param)
end

function Form_InheritLevelupPop:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetNumStepper = self:createNumStepper(self.m_common_stepper)
  self.m_widgetItemIconList = {}
  for i = 1, 3 do
    local itemIcon = self:createCommonItem(self["m_common_item" .. i])
    self.m_widgetItemIconList[#self.m_widgetItemIconList + 1] = itemIcon
    itemIcon:SetItemIconClickCB(function()
      self:OnItemClk(i)
    end)
  end
end

function Form_InheritLevelupPop:OnActive()
  self.super.OnActive(self)
  self.m_iNumCur = 1
  self.m_inheritMaxLv = InheritManager:GetInheritMaxLv()
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_InheritLevelupPop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_InheritLevelupPop:AddEventListeners()
  self:addEventListener("eGameEvent_Item_Use", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_Inherit_LevelUp", handler(self, self.OnLevelUpSuccess))
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnCloseClicked))
end

function Form_InheritLevelupPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_InheritLevelupPop:RefreshUI()
  self.m_level = InheritManager:GetInheritLevel()
  self.m_levelUpMax = self:GetMaxLv()
  local afterLv = self.m_level + self.m_iNumCur
  self.m_txt_lv_before_Text.text = string.format(ConfigManager:GetCommonTextById(20033), self.m_level)
  self.m_txt_lv_after_Text.text = string.format(ConfigManager:GetCommonTextById(20033), afterLv)
  self.m_txt_lv_max:SetActive(afterLv >= self.m_inheritMaxLv)
  self:RefreshWidgetNumStepper()
  self.m_needItemList = InheritManager:GetInheritLevelUpNeedItem(self.m_level + self.m_iNumCur)
  if self.m_needItemList then
    for i, v in ipairs(self.m_needItemList) do
      local costItemWidget = self.m_widgetItemIconList[i]
      local processData = ResourceUtil:GetProcessRewardData({
        iID = v[1],
        iNum = 0
      })
      costItemWidget:SetItemInfo(processData)
      local curHaveNum = ItemManager:GetItemNum(v[1])
      local showHaveNum = curHaveNum
      if showHaveNum < 0 then
        showHaveNum = 0
      end
      costItemWidget:SetNeedNum(v[2], showHaveNum)
    end
  end
end

function Form_InheritLevelupPop:GetMaxLv()
  local expId, goldId, breakId = InheritManager:GetInheritLevelUpItemId()
  local curHaveNum = ItemManager:GetItemNum(expId)
  local curHaveNum2 = ItemManager:GetItemNum(goldId)
  local curHaveNum3 = ItemManager:GetItemNum(breakId)
  return InheritManager:GetInheritItemLevelNum({
    curHaveNum,
    curHaveNum2,
    curHaveNum3
  })
end

function Form_InheritLevelupPop:RefreshWidgetNumStepper()
  self.m_widgetNumStepper:SetNumShowMax(false)
  self.m_widgetNumStepper:SetNumMax(self.m_levelUpMax == 0 and 1 or self.m_levelUpMax)
  self.m_widgetNumStepper:SetNumCur(self.m_iNumCur)
  self.m_widgetNumStepper:SetNumChangeCB(handler(self, self.OnNumStepperChange))
end

function Form_InheritLevelupPop:OnNumStepperChange(iNumCur, iNumChange, sTag)
  self.m_iNumCur = iNumCur
  self:RefreshUI()
end

function Form_InheritLevelupPop:OnLevelUpSuccess(data)
  self.m_iNumCur = 1
  self.m_widgetNumStepper:SetNumCur(1)
  local maxLevel = InheritManager:GetInheritMaxLv()
  if maxLevel == data.iNewLevel then
    self:OnBtnCloseClicked()
    StackFlow:Push(UIDefines.ID_FORM_INHERITLEVELUPSUCCESS, data)
  else
    self:RefreshUI()
    StackFlow:Push(UIDefines.ID_FORM_INHERITLEVELUPSUCCESS, data)
  end
end

function Form_InheritLevelupPop:OnBtnbagClicked()
  if self.m_needItemList and #self.m_needItemList > 0 then
    StackPopup:Push(UIDefines.ID_FORM_POPUPQUICKBAG, {
      quickBagType = ItemManager.ItemQuickUseType.HeroLevelUp,
      costList = self.m_needItemList
    })
  end
end

function Form_InheritLevelupPop:OnItemClk(index)
  if not index then
    return
  end
  local itemID = self.m_needItemList[index][1]
  local haveNum = ItemManager:GetItemNum(itemID) or 0
  if itemID then
    utils.openItemDetailPop({iID = itemID, iNum = haveNum})
  end
end

function Form_InheritLevelupPop:OnBtnyesClicked()
  if self.m_levelUpMax == 0 or self.m_iNumCur == 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30004)
    return
  end
  InheritManager:ReqInheritLevelUp(self.m_iNumCur)
end

function Form_InheritLevelupPop:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_InheritLevelupPop:IsOpenGuassianBlur()
  return true
end

function Form_InheritLevelupPop:IsFullScreen()
  return false
end

function Form_InheritLevelupPop:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
  self:broadcastEvent("eGameEvent_Inherit_Change")
end

function Form_InheritLevelupPop:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_InheritLevelupPop", Form_InheritLevelupPop)
return Form_InheritLevelupPop
