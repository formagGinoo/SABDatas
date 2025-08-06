local BaseManager = require("Manager/Base/BaseManager")
local KeyboardMappingManager = class("KeyboardMappingManager", BaseManager)

function KeyboardMappingManager:OnCreate()
  self.m_triggerTime = 0
  self.m_isDirty = false
  self.m_configMap = {}
  self.m_affectUIs = {}
end

function KeyboardMappingManager:RegistrySingleConfig(uiPrefabName, uiObject, bindKey, bindType)
  if uiObject == nil then
    return
  end
  if self.m_configMap[uiPrefabName] == nil then
    self.m_configMap[uiPrefabName] = {}
  end
  local bindConfig = {}
  bindConfig[1] = {
    btn = uiObject,
    bindType = bindType,
    priority = 1
  }
  self.m_configMap[uiPrefabName][bindKey] = bindConfig
end

function KeyboardMappingManager:GenerateConfig(uiPrefabName, uiInstance, isLua)
  local config = {}
  if self.m_configAll == nil then
    self.m_configAll = CS.CData_KeyboardMapping.GetInstance()
    self.m_configAll:Init()
  end
  local configArray = self.m_configAll:GetValue_ByForm(uiPrefabName)
  if configArray and configArray.Count > 0 then
    local iter = configArray:GetEnumerator()
    while iter:MoveNext() do
      local kv = iter.Current
      local key = kv.Key
      local mappingElement = kv.Value
      local mappingButton
      if mappingElement.m_Button and mappingElement.m_Button ~= "" then
        if isLua then
          mappingButton = uiInstance[mappingElement.m_Button]
        else
          local type = uiInstance:GetType()
          local field = type:GetField(mappingElement.m_Button, 20)
          if field then
            mappingButton = field:GetValue(uiInstance)
          end
        end
      end
      if mappingButton then
        local buttonLabel = mappingButton.transform:Find("c_common_item_key")
        if buttonLabel then
          if ChannelManager:IsWindows() and mappingElement.m_DisplayKey ~= "" then
            local keyboardBindComp = mappingButton:GetComponent(typeof(CS.KeyboardBindComp))
            if keyboardBindComp == nil then
              keyboardBindComp = mappingButton:AddComponent(typeof(CS.KeyboardBindComp))
            end
            keyboardBindComp.bindingObject = buttonLabel.gameObject
            buttonLabel.gameObject:SetActive(mappingButton.activeInHierarchy)
            local labelText = buttonLabel:Find("key_root/c_txt_key"):GetComponent(T_TextMeshProUGUI)
            if labelText then
              labelText.text = mappingElement.m_DisplayKey
            end
          else
            buttonLabel.gameObject:SetActive(false)
          end
        end
      end
      if ChannelManager:IsWindows() then
        local keys = string.split(mappingElement.m_Key, ",")
        for k, v in ipairs(keys) do
          if config[v] == nil then
            config[v] = {}
          end
          if mappingButton == nil and mappingElement.m_TriggerPos ~= "" then
            local pos = string.split(mappingElement.m_TriggerPos, ",")
            local posX = tonumber(pos[1])
            if posX < 0 then
              posX = CS.UnityEngine.Screen.width + posX
            end
            local posY = tonumber(pos[2])
            if posY < 0 then
              posY = CS.UnityEngine.Screen.height + posY
            end
            config[v][#config[v] + 1] = {
              pos = Vector2.New(posX, posY),
              bindType = 2,
              priority = mappingElement.m_Priority
            }
          elseif mappingButton then
            config[v][#config[v] + 1] = {
              btn = mappingButton,
              bindType = 1,
              priority = mappingElement.m_Priority
            }
          end
        end
      end
    end
  end
  return config
end

function KeyboardMappingManager:AddSubConfig(uiParentPrefabName, uiSubPrefabName, uiInstance, isLua)
  if ConfigManager.m_mConfigInstanceCache == nil then
    return
  end
  local subConfig = self:GenerateConfig(uiSubPrefabName, uiInstance, isLua)
  local config = self.m_configMap[uiParentPrefabName]
  if config ~= nil then
    if config.subUI == nil then
      config.subUI = {}
    end
    config.subUI[uiSubPrefabName] = subConfig
  end
end

function KeyboardMappingManager:RemoveSubConfig(uiParentPrefabName, uiSubPrefabName)
  if self.m_configMap[uiParentPrefabName] and self.m_configMap[uiParentPrefabName].subUI and self.m_configMap[uiParentPrefabName].subUI[uiSubPrefabName] then
    self.m_configMap[uiParentPrefabName].subUI[uiSubPrefabName] = nil
  end
end

function KeyboardMappingManager:SetSubConfigInValid(uiParentPrefabName, uiSubPrefabName, uiInstance, isLua, bInValid)
  if self.m_configMap[uiParentPrefabName] == nil then
    return
  end
  if self.m_configMap[uiParentPrefabName].subUI and self.m_configMap[uiParentPrefabName].subUI[uiSubPrefabName] then
    self.m_configMap[uiParentPrefabName].subUI[uiSubPrefabName].bInValid = bInValid
  elseif not bInValid then
    self:AddSubConfig(uiParentPrefabName, uiSubPrefabName, uiInstance, isLua)
  end
end

function KeyboardMappingManager:SetActiveConfig(uiPrefabName, uiInstance, isLua)
  if ConfigManager.m_mConfigInstanceCache == nil then
    return
  end
  local config = self:GenerateConfig(uiPrefabName, uiInstance, isLua)
  if ChannelManager:IsWindows() then
    local hasBindingEsc = false
    if config.ESC then
      hasBindingEsc = true
    end
    if not hasBindingEsc then
      local commonList = {
        "m_btn_back",
        "m_Btn_Return",
        "m_btn_Return",
        "m_Btn_Close"
      }
      local iIndex = 1
      for _, commonName in ipairs(commonList) do
        local commonButton
        if isLua then
          commonButton = uiInstance[commonName]
        else
          local type = uiInstance:GetType()
          local field = type:GetField(commonName, 20)
          if field then
            commonButton = field:GetValue(uiInstance)
          end
        end
        if commonButton then
          config.ESC = config.ESC or {}
          config.ESC[#config.ESC + 1] = {
            btn = commonButton,
            bindType = 1,
            priority = 1000 + iIndex
          }
          iIndex = iIndex + 1
        end
      end
    end
    
    local function sortByPriority(a, b)
      return a.priority < b.priority
    end
    
    for k, v in pairs(config) do
      if v and 0 < #v then
        table.sort(v, sortByPriority)
      end
    end
    self.m_configMap[uiPrefabName] = config
    self.m_isDirty = true
  end
end

function KeyboardMappingManager:DeActiveConfig(uiPrefabName)
  if ChannelManager:IsWindows() then
    self.m_isDirty = true
  end
end

function KeyboardMappingManager:SimulateClick(pos)
  CS.Util.SimulateClick(pos)
end

function KeyboardMappingManager:IsVisible(button, isExtentsion)
  if not button then
    return false
  end
  if isExtentsion then
    if not button.Interactable then
      return false
    end
  elseif not button.interactable then
    return false
  end
  local gameObject = button.gameObject
  if not gameObject or not gameObject.activeInHierarchy then
    return false
  end
  local tf = gameObject.transform
  while tf ~= nil do
    local canvasGroup = tf:GetComponent(T_CanvasGroup)
    if canvasGroup and tostring(canvasGroup):find("null") == nil then
      if not canvasGroup.interactable or canvasGroup.blocksRaycasts == false then
        return false
      end
      break
    end
    tf = tf.parent
  end
  return true
end

function KeyboardMappingManager:IsClicked(button)
  return CS.Util.IsUIElementRaycastedTop(button)
end

function KeyboardMappingManager:OnUpdate(dt)
  if not ChannelManager:IsWindows() then
    return
  end
  if self.m_isDirty then
    self.m_isDirty = false
    self.m_affectUIs = {}
    local uilist = CS.Util.GetVisibleUI()
    if uilist.Count > 0 then
      for i = 0, uilist.Count - 1 do
        self.m_affectUIs[#self.m_affectUIs + 1] = uilist[i]
      end
    end
  end
  if 0 < self.m_triggerTime then
    self.m_triggerTime = self.m_triggerTime - dt
  end
end

function KeyboardMappingManager:OnKeyboardUpdate()
  if #self.m_affectUIs > 0 then
    local hasTrigger = false
    for i, prefabName in ipairs(self.m_affectUIs) do
      local config = self.m_configMap[prefabName]
      if config then
        if config.subUI ~= nil then
          for subUIName, subConfig in pairs(config.subUI) do
            if subConfig.bInValid == true then
              break
            end
            for key, v in pairs(subConfig) do
              if U3DUtil and U3DUtil:Input_GetKeyDown(key) then
                for k2, v2 in ipairs(v) do
                  if self:TriggerEvent(v2) then
                    hasTrigger = true
                    break
                  end
                end
                break
              end
            end
            if hasTrigger then
              break
            end
          end
        end
        if not hasTrigger then
          for key, v in pairs(config) do
            if U3DUtil and U3DUtil:Input_GetKeyDown(key) then
              for k2, v2 in ipairs(v) do
                if self:TriggerEvent(v2) then
                  hasTrigger = true
                  break
                end
              end
              break
            end
          end
        end
      end
      if hasTrigger then
        break
      end
    end
    if hasTrigger then
      self.m_triggerTime = 0.1
    elseif U3DUtil and U3DUtil:Input_GetKeyDown("ESC") then
      if self.m_affectUIs[1] == "Form_Hall" then
        utils.CheckAndPushCommonTips({
          tipsID = 1753,
          func1 = function()
            CS.ApplicationManager.Instance:ExitGame()
          end
        })
      else
        self:SimulateClick(Vector2.New(20, CS.UnityEngine.Screen.height - 20))
      end
      self.m_triggerTime = 0.1
    end
  end
end

function KeyboardMappingManager:TriggerEvent(bindCfg)
  if CS.UI.UILocker.Instance.LockerImage.raycastTarget == true then
    return false
  end
  if bindCfg.bindType == 1 then
    if utils.isNull(bindCfg.btn) then
      return false
    end
    local button = bindCfg.btn:GetComponent(T_Button)
    local isExtentsion = false
    if button == nil then
      button = bindCfg.btn:GetComponent(typeof(CS.Plugins.Muf.Runtime.UI.Component.UGUI.ButtonExtensions))
      if button then
        isExtentsion = true
      end
    end
    if self:IsVisible(button, isExtentsion) and self:IsClicked(bindCfg.btn) then
      if isExtentsion then
        self:InvokePointerEvent(button.gameObject)
      else
        button.onClick:Invoke()
      end
      return true
    end
  elseif bindCfg.bindType == 2 then
    self:SimulateClick(bindCfg.pos)
    return true
  elseif bindCfg.bindType == 3 then
    if utils.isNull(bindCfg.btn) then
      return false
    end
    if self:IsClicked(bindCfg.btn) and self:InvokeEventTrigger(bindCfg.btn, CS.UnityEngine.EventSystems.EventTriggerType.PointerDown) and self:InvokeEventTrigger(bindCfg.btn, CS.UnityEngine.EventSystems.EventTriggerType.PointerUp) then
      return true
    end
  end
  return false
end

function KeyboardMappingManager:InvokePointerEvent(gameObject)
  if gameObject == nil then
    return false
  end
  CS.Util.EventHelper.TriggerPointerClick(gameObject)
  return true
end

function KeyboardMappingManager:InvokeEventTrigger(gameObject, eventTriggerType)
  if gameObject == nil or not gameObject.activeInHierarchy then
    return false
  end
  local trigger = gameObject:GetComponent(typeof(CS.UnityEngine.EventSystems.EventTrigger))
  if trigger == nil or trigger.triggers == nil then
    return false
  end
  local triggers = trigger.triggers
  for i = 0, triggers.Count - 1 do
    local entry = triggers[i]
    if entry.eventID == eventTriggerType then
      local eventData = CS.UnityEngine.EventSystems.BaseEventData(CS.UnityEngine.EventSystems.EventSystem.current)
      entry.callback:Invoke(eventData)
      return true
    end
  end
  return false
end

return KeyboardMappingManager
