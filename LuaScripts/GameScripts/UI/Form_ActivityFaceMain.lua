local Form_ActivityFaceMain = class("Form_ActivityFaceMain", require("UI/UIFrames/Form_ActivityFaceMainUI"))

function Form_ActivityFaceMain:SetInitParam(param)
end

function Form_ActivityFaceMain:AfterInit()
  self.super.AfterInit(self)
  self.subPanelData = {
    [25004] = {
      obj = self.m_lamia_root,
      subPanelName = "GachaLamiaPushFaceSubPanel",
      backFun = function()
      end
    },
    [25005] = {
      obj = self.m_dalcaro_root,
      subPanelName = "GachaDalCaroPushFaceSubPanel",
      backFun = function()
      end
    },
    [27] = {
      obj = self.m_huntingnight_root,
      subPanelName = "ActivityHuntNightSubPanel",
      backFun = function()
      end
    },
    [25] = {
      obj = self.m_soloraid_root,
      subPanelName = "ActivityPersonalRaid2FaceSubPanel",
      backFun = function()
      end
    },
    [2702] = {
      obj = self.m_boqina_root,
      subPanelName = "ActivityQigeLunaSubPanel",
      backFun = function()
      end
    },
    [25006] = {
      obj = self.m_lorelei_root,
      subPanelName = "ActivityLoreleiFaceSubPanel",
      backFun = function()
      end
    },
    [25007] = {
      obj = self.m_bella_root,
      subPanelName = "ActivityBellaFaceSubPanel",
      backFun = function()
      end
    }
  }
end

function Form_ActivityFaceMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_ActivityFaceMain:OnActive()
  self.super.OnActive(self)
  self.m_isCheck = true
  self:RemoveAllEventListeners()
  self:AddEventListeners()
  if self.m_csui.m_param then
    self.activityId = tonumber(self.m_csui.m_param.activityId)
    self.m_csui.m_param = nil
  end
  for key, data in pairs(self.subPanelData) do
    if data.obj then
      UILuaHelper.SetActive(data.obj, false)
    end
  end
  local activity = ActivityManager:GetActivityByID(self.activityId)
  if activity then
    local subData = self.subPanelData[tonumber(activity:OnGetClientConfig().iJumpId)]
    if subData then
      UILuaHelper.SetActive(subData.obj, true)
      if subData.subPanelLua == nil then
        local initData = subData.backFun and {
          backFun = subData.backFun
        } or nil
        
        local function loadCallBack(subPanelLua)
          if subPanelLua then
            subData.subPanelLua = subPanelLua
          end
        end
        
        SubPanelManager:LoadSubPanel(subData.subPanelName, subData.obj, self, self.activityId, {initData = initData}, loadCallBack)
      else
        subData.subPanelLua:OnFreshData()
      end
    end
  end
end

function Form_ActivityFaceMain:AddEventListeners()
  self:addEventListener("eGameEvent_ActivityFace_CloseNoCheck", handler(self, self.OnCloseNoCheck))
end

function Form_ActivityFaceMain:OnCloseNoCheck()
  self.m_isCheck = false
  self:CloseForm()
end

function Form_ActivityFaceMain:OnDestroy()
  self.super.OnDestroy(self)
  if self.subPanelData then
    for i, panelData in pairs(self.subPanelData) do
      if panelData.subPanelLua and panelData.subPanelLua.dispose then
        panelData.subPanelLua:dispose()
        panelData.subPanelLua = nil
      end
    end
  end
end

function Form_ActivityFaceMain:OnInactive()
  self.super.OnInactive(self)
  if self.subPanelData then
    for i, info in pairs(self.subPanelData) do
      if info.subPanelLua and info.subPanelLua.OnInactive then
        info.subPanelLua:OnInactive()
      end
    end
  end
  self:RemoveAllEventListeners()
  if self.m_isCheck then
    PushFaceManager:CheckShowNextPopPanel()
  else
    PushFaceManager:CheckClearPopPanelStatus()
  end
end

function Form_ActivityFaceMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActivityFaceMain:GetDownloadResourceExtra(tParam)
  if tParam.activityId then
    local activity = ActivityManager:GetActivityByID(tParam.activityId)
    local subPanelData = {
      [25004] = {
        subPanelName = "GachaLamiaPushFaceSubPanel"
      },
      [25005] = {
        subPanelName = "GachaDalCaroPushFaceSubPanel"
      },
      [2702] = {
        subPanelName = "ActivityQigeLunaSubPanel"
      },
      [25] = {
        subPanelName = "ActivityPersonalRaid2FaceSubPanel"
      },
      [27] = {
        subPanelName = "ActivityHuntNightSubPanel"
      },
      [25006] = {
        subPanelName = "ActivityLoreleiFaceSubPanel"
      },
      [25007] = {
        subPanelName = "ActivityBellaFaceSubPanel"
      }
    }
    if activity then
      local subData = subPanelData[tonumber(activity:OnGetClientConfig().iJumpId)]
      if subData then
        local vPackage = {}
        local vResourceExtra = {}
        local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(subData.subPanelName)
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
        return vPackage, vResourceExtra
      end
    end
  end
end

function Form_ActivityFaceMain:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_ActivityFaceMain", Form_ActivityFaceMain)
return Form_ActivityFaceMain
