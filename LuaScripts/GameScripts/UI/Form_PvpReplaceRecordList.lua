local Form_PvpReplaceRecordList = class("Form_PvpReplaceRecordList", require("UI/UIFrames/Form_PvpReplaceRecordListUI"))

function Form_PvpReplaceRecordList:SetInitParam(param)
end

function Form_PvpReplaceRecordList:AfterInit()
  self.super.AfterInit(self)
  self.m_recordInfoList = nil
  self.m_luaRecordGrid = self:CreateInfinityGrid(self.m_scrollView_InfinityGrid, "PvpReplace/UIPvpReplaceRecordItem", nil)
  self.m_backFun = nil
end

function Form_PvpReplaceRecordList:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_PvpReplaceRecordList:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_PvpReplaceRecordList:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PvpReplaceRecordList:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_recordInfoList = tParam.battleRecordList or {}
    self.m_backFun = tParam.backFun
    table.sort(self.m_recordInfoList, function(a, b)
      return a.iTime > b.iTime
    end)
    self.m_csui.m_param = nil
  end
end

function Form_PvpReplaceRecordList:ClearCacheData()
  self.m_recordInfoList = nil
  self.m_backFun = nil
end

function Form_PvpReplaceRecordList:AddEventListeners()
end

function Form_PvpReplaceRecordList:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpReplaceRecordList:FreshUI()
  if self.m_recordInfoList and next(self.m_recordInfoList) then
    UILuaHelper.SetActive(self.m_scrollView, true)
    UILuaHelper.SetActive(self.m_img_empty, false)
    self.m_luaRecordGrid:ShowItemList(self.m_recordInfoList)
  else
    UILuaHelper.SetActive(self.m_scrollView, false)
    UILuaHelper.SetActive(self.m_img_empty, true)
  end
end

function Form_PvpReplaceRecordList:OnBtnCloseClicked()
  if self.m_backFun ~= nil then
    self.m_backFun()
  end
  self:CloseForm()
end

function Form_PvpReplaceRecordList:OnBtnReturnClicked()
  if self.m_backFun ~= nil then
    self.m_backFun()
  end
  self:CloseForm()
end

function Form_PvpReplaceRecordList:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PvpReplaceRecordList", Form_PvpReplaceRecordList)
return Form_PvpReplaceRecordList
