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
  local bCloseComplianceResourceSwitch = CS.UnityEngine.PlayerPrefs.GetInt("CloseComplianceResourceSwitch", 0)
  local gloablFilePath = CS.MUF.Resource.ResourceLocationHelper.Instance.PersistentDataPath .. "/" .. "localization.txt"
  if not CS.System.IO.File.Exists(gloablFilePath) then
    local file = io.open(gloablFilePath, "w")
    file:write("resourceVersion = local")
    file:close()
  end
  local file = io.open(gloablFilePath, "r")
  if file then
    local function trim(s)
      if s == nil then
        return ""
      end
      return string.match(s, "^%s*(.-)%s*$")
    end
    
    for line in file:lines() do
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
    file:close()
  end
  log.info("localization path:" .. gloablFilePath .. " " .. tostring(CS.MUF.Resource.ResourceManager.GetUseGlobal()))
  CS.MUF.Download.DownloadResource.Instance:InitDownload()
  StackTop:TryLoadUI(UIDefines.ID_FORM_WAITING, nil, nil)
  local bHQ = CS.MUF.Resource.ResourceManager.GetHQ2D()
  StackSpecial:TryLoadUI(UIDefines.ID_FORM_VIEDO, function()
    local cameraRoot = CS.UnityEngine.GameObject.Find("RootCamera"):GetComponent("Camera")
    local camera1 = CS.UnityEngine.GameObject.Find("Camera"):GetComponent("Camera")
    camera1.enabled = false
    CS.UI.UILuaHelper.SetMainCamera(true, cameraRoot)
    cameraRoot.enabled = true
    CS.VideoManager.Instance:PlayFromAddResReal("UI_Login_Main", "", false, nil, CS.UnityEngine.ScaleMode.ScaleAndCrop, false, true, false, false, bHQ)
    StackFlow:Push(UIDefines.ID_FORM_LOGINNEW)
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

function ViewUpdate(dt)
end

function LateUpdate(dt)
end

ScreenSafeArea = CS.UnityEngine.Screen.safeArea
CS.LuaCallCS.IsLuaFirstInit = true
LUA_RELOAD_DEBUG = false
CS.UI.UILuaHelper.SetLuaReloadDeBug(LUA_RELOAD_DEBUG)
