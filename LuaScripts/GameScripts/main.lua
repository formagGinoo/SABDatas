require("common/class")
local a = require("common/async")
async = a.sync
await = a.wait
awrap = a.wrap
Tweening = CS.DG.Tweening
DOTweenModuleUI = Tweening.DOTweenModuleUI
require("common/log")
require("common/Vector3")
require("common/Vector2")
json = require("common/json")
types = require("common/types")
callback = require("common/callbackx")
require("common/mathx")
geometric = require("common/geometricx")
require("common/stringx")
require("common/tablex")
require("UI/UIDefines")
list = require("common/List")
date = require("common/Date")
df = date.Format()
ugui = require("common/uguix")
common = require("common/common")
utils = require("common/utils")
ResourceUtil = require("common/ResourceUtil")
GlobalConfig = require("common/GlobalConfig")
UnlockSystemUtil = require("common/UnlockSystemUtil")
QuickOpenFuncUtil = require("common/QuickOpenFuncUtil")
RedDotDefine = require("Manager/RedDotSystem/RedDotDefine")
CombatUtil = require("common/CombatUtil")
require("CSCallLua")
require("common/TimeService")
require("common/TimeUtil")
require("common/SDKUtil")
require("common/XLua/util")
if CS.UnityEngine.Application.isPlaying then
  require("UI/Common/UIStatic")
end
for k, v in pairs(UINames) do
  CS.UIDefinesForLua.Register(k, v)
end
if CS.UnityEngine.Application.isPlaying then
  CS.System.Threading.Thread.CurrentThread.CurrentCulture = CS.System.Globalization.CultureInfo.InvariantCulture
  local success, err = pcall(function()
    local bCloseComplianceResourceSwitch = CS.UnityEngine.PlayerPrefs.GetInt("CloseComplianceResourceSwitch", 0)
    local globalFilePath = CS.MUF.Resource.ResourceLocationHelper.Instance.PersistentDataPath .. "/" .. "localization.txt"
    if not CS.System.IO.File.Exists(globalFilePath) then
      CS.System.IO.File.WriteAllText(globalFilePath, "resourceVersion = local")
    end
    local lines = CS.System.IO.File.ReadAllLines(globalFilePath)
    
    local function trim(s)
      if s == nil then
        return ""
      end
      return string.match(s, "^%s*(.-)%s*$")
    end
    
    for i = 0, lines.Length - 1 do
      local line = lines[i]
      local list = line:split("=")
      key = trim(list[1])
      value = trim(list[2])
      if key == "resourceVersion" and value == "global" then
        CS.MUF.Resource.ResourceManager.SetUseGlobalLocal(true)
        if bCloseComplianceResourceSwitch == 0 then
          CS.MUF.Resource.ResourceManager.SetUseGlobal(true)
        end
        break
      end
    end
    log.info("localization path:" .. globalFilePath .. " " .. tostring(CS.MUF.Resource.ResourceManager.GetUseGlobal()))
  end)
  if not success then
    log.info("Failed to use UseGlobal: " .. tostring(err))
  end
  CS.MUF.Download.DownloadResource.Instance:InitDownload()
  if CS.MUF.Resource.ResourceManager.GetUseGlobal() then
    local newGroupIDStr = CS.UnityEngine.PlayerPrefs.GetString("CloseComplianceResourceGroupID", "")
    if newGroupIDStr ~= "" then
      local vNewGroupID = string.split(newGroupIDStr, ";")
      local groudIdList = CS.System.Collections.Generic.List(CS.System.String)()
      for k, v in ipairs(vNewGroupID) do
        groudIdList:Add(tostring(v))
      end
      CS.MUF.Resource.ResourceManager.SetGlobalResGroup(groudIdList)
    end
  end
  StackTop:TryLoadUI(UIDefines.ID_FORM_WAITING, nil, nil)
  local bHQ = CS.MUF.Resource.ResourceManager.GetHQ2D()
  StackSpecial:TryLoadUI(UIDefines.ID_FORM_VIEDO, function()
    local cameraRoot = CS.UnityEngine.GameObject.Find("RootCamera"):GetComponent("Camera")
    local camera1 = CS.UnityEngine.GameObject.Find("Camera"):GetComponent("Camera")
    camera1.enabled = false
    CS.UI.UILuaHelper.SetMainCamera(true, cameraRoot)
    cameraRoot.enabled = true
    local videoName = "UI_Login_Main"
    local tempVideoName, prefabName, defalutPrefabName = DealPlaySelectVideo()
    if tempVideoName and CS.MUF.Resource.ResourceLocationHelper.Instance:IsFileExists(tempVideoName .. ".mp4", CS.MUF.Resource.ResourceType.Video) then
      videoName = tempVideoName
    end
    if not prefabName or not CS.MUF.Resource.ResourceLocationHelper.Instance:IsFileExists(prefabName, CS.MUF.Resource.ResourceType.UI) then
      prefabName = defalutPrefabName
    end
    CS.VideoManager.Instance:PlayFromAddResReal(videoName, "", false, nil, CS.UnityEngine.ScaleMode.ScaleAndCrop, false, true, false, false, bHQ)
    log.info("videoName:" .. videoName)
    StackFlow:Push(UIDefines.ID_FORM_LOGINNEW, {bConnectGameServer = false, prefabName = prefabName})
    local CanvasSharder = CS.UnityEngine.GameObject.Find("Canvas")
    CanvasSharder.gameObject:SetActive(false)
  end, function()
    log.error("Load Form_Video failed")
  end)
end

function MainUpdate(dt)
  TimeService:Update()
  if GameManager ~= nil then
    GameManager:update(dt)
  end
end

function DealPlaySelectVideo()
  local LoginVideoInfoIns = CS.CData_LoginVideoInfo.GetInstance()
  LoginVideoInfoIns:Init()
  local value, prefabName
  local defalutPrefabName = LoginVideoInfoIns:GetValue_ByVideoID(1).m_PrefabName
  local audioId = 0
  local order = -1
  local tempCfg = LoginVideoInfoIns:GetAll()
  for _, v in pairs(tempCfg) do
    if order < v.m_Type then
      value = v.m_VideoName
      prefabName = v.m_PrefabName
      audioId = v.m_Audio
      order = v.m_Type
    end
  end
  return value, prefabName, defalutPrefabName, audioId
end

function ViewUpdate(dt)
end

function LateUpdate(dt)
end

ScreenSafeArea = CS.UnityEngine.Screen.safeArea
CS.LuaCallCS.IsLuaFirstInit = true
LUA_RELOAD_DEBUG = false
CS.UI.UILuaHelper.SetLuaReloadDeBug(LUA_RELOAD_DEBUG)
