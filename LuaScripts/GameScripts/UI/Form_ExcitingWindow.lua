local Form_ExcitingWindow = class("Form_ExcitingWindow", require("UI/UIFrames/Form_ExcitingWindowUI"))
local PushFaceType = {SevenDayActivity = 1}

function Form_ExcitingWindow:SetInitParam(param)
end

function Form_ExcitingWindow:AfterInit()
  self.super.AfterInit(self)
  self.m_subPanelData = {
    [PushFaceType.SevenDayActivity] = {
      panelRoot = self.m_pnl_view,
      subPanelName = "ActivitySevenDaysSubPanel",
      backFun = function()
      end
    }
  }
  self.m_curType = nil
end

function Form_ExcitingWindow:OnActive()
  self:RefreshData()
  self:RefreshUI()
end

function Form_ExcitingWindow:RefreshData()
  local tParam = self.m_csui.m_param
  if tParam and tParam then
    self.m_curType = tParam
  end
end

function Form_ExcitingWindow:RefreshUI()
  self:ChangeWindowType(self.m_curType)
end

function Form_ExcitingWindow:ChangeWindowType(index)
  if index then
    self.m_curType = index
    local curSubPanelData = self.m_subPanelData[index]
    if curSubPanelData then
      if curSubPanelData.subPanelLua == nil then
        local initData = curSubPanelData.backFun and {
          backFun = curSubPanelData.backFun
        } or nil
        
        local function loadCallBack(subPanelLua)
          if subPanelLua then
            curSubPanelData.subPanelLua = subPanelLua
          end
        end
        
        SubPanelManager:LoadSubPanel(curSubPanelData.subPanelName, curSubPanelData.panelRoot, self, nil, {initData = initData}, loadCallBack)
      else
        self:RefreshCurWindowInfo()
      end
    end
  end
end

function Form_ExcitingWindow:RefreshCurWindowInfo()
  if not self.m_curType then
    return
  end
  local curSubPanelData = self.m_subPanelData[self.m_curType]
  local subPanelLua = curSubPanelData.subPanelLua
  if subPanelLua then
    subPanelLua:SetActive(true)
    subPanelLua:OnFreshData()
  end
end

function Form_ExcitingWindow:OnInactive()
  self.super.OnInactive(self)
end

function Form_ExcitingWindow:OnDestroy()
  self.super.OnDestroy(self)
  for i, v in pairs(self.m_subPanelData) do
    if v.subPanelLua then
      v.subPanelLua:dispose()
      v.subPanelLua = nil
    end
  end
end

function Form_ExcitingWindow:OnBtncloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_EXCITINGWINDOW)
  PushFaceManager:CheckShowNextPopPanel()
end

function Form_ExcitingWindow:IsOpenGuassianBlur()
  return true
end

function Form_ExcitingWindow:GetDownloadResourceExtra(tParam)
  local vSubPanelName = {
    "ActivitySevenDaysSubPanel"
  }
  local vPackage = {}
  local vResourceExtra = {}
  for _, sSubPanelName in pairs(vSubPanelName) do
    local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(sSubPanelName)
    if vPackageSub ~= nil then
      for i = 1, #vPackageSub do
        vPackage[#vPackage + 1] = vPackageSub[i]
      end
    end
    if vResourceExtraSub ~= nil then
      for i = 1, #vResourceExtraSub do
        vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[i]
      end
    end
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_ExcitingWindow", Form_ExcitingWindow)
return Form_ExcitingWindow
