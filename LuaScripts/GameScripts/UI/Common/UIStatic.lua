CsUi = CS.UI
local LuaManagerInstance = CS.LuaManager.Instance
local WeakReference = CS.System.WeakReference
UIForms = {}

function ActiveLuaUI(name, obj)
  UIForms[name] = obj
end

function NewUIForm(name)
  local form = UIForms[name]
  if form == nil then
    return nil
  end
  return form.new()
end

require("UI/Common/AllFrames")
UIRootTransformType = {
  Battle = 0,
  Cutin = 1,
  Story = 2,
  Top = 3,
  Main = 4,
  Lagacy = 5
}

function BindLuaUI(csui, uiname)
  local luaui = NewUIForm(uiname)
  if csui ~= nil and luaui ~= nil then
    csui.LuaTable = luaui
    if luaui.Init ~= nil then
      csui:SetLuaInitCallback(callback.handler(luaui, luaui.Init))
    end
    if luaui.AfterInit ~= nil then
      csui:SetLuaAfterInitCallback(callback.handler(luaui, luaui.AfterInit))
    end
    if luaui.OnActive ~= nil then
      csui:SetLuaOnActiveCallback(callback.handler(luaui, luaui.OnActive))
    end
    if luaui.OnActiveTransitionDone ~= nil then
      csui:SetLuaOnActiveTransitionDoneCallback(callback.handler(luaui, luaui.OnActiveTransitionDone))
    end
    if luaui.OnActiveEx ~= nil then
      csui:SetLuaOnActiveExCallback(callback.handler(luaui, luaui.OnActiveEx))
    end
    if luaui.OnActiveSame ~= nil then
      csui:SetLuaOnActiveSameCallback(callback.handler(luaui, luaui.OnActiveSame))
    end
    if luaui.OnUncoverd ~= nil then
      csui:SetLuaOnUncoverdCallback(callback.handler(luaui, luaui.OnUncoverd))
    end
    if luaui.OnOpen ~= nil then
      csui:SetLuaOnOpenCallBack(callback.handler(luaui, luaui.OnOpen))
    end
    if luaui.OnUncoverdTransitionDone ~= nil then
      csui:SetLuaOnUncoverdTransitionDoneCallback(callback.handler(luaui, luaui.OnUncoverdTransitionDone))
    end
    if luaui.BeforeActive ~= nil then
      csui:SetLuaBeforeActiveCallback(callback.handler(luaui, luaui.BeforeActive))
    end
    if luaui.OnInactive ~= nil then
      csui:SetLuaOnInactiveCallback(callback.handler(luaui, luaui.OnInactive))
    end
    if luaui.OnInactiveEx ~= nil then
      csui:SetLuaOnInactiveExCallback(callback.handler(luaui, luaui.OnInactiveEx))
    end
    if luaui.dispose ~= nil then
      csui:SetLuaOnDestroyCallback(callback.handler(luaui, luaui.dispose))
    elseif luaui.OnDestroy ~= nil then
      csui:SetLuaOnDestroyCallback(callback.handler(luaui, luaui.OnDestroy))
    end
    if luaui.InitEventListener ~= nil then
      csui:SetLuaInitEventListenerCallback(callback.handler(luaui, luaui.InitEventListener))
    end
    if luaui.RemoveEventListener ~= nil then
      csui:SetLuaRemoveEventListenerCallback(callback.handler(luaui, luaui.RemoveEventListener))
    end
    if luaui.update ~= nil then
      csui:SetLuaOnUpdateCallback(callback.handler(luaui, luaui.update))
    elseif luaui.OnUpdate ~= nil then
      csui:SetLuaOnUpdateCallback(callback.handler(luaui, luaui.OnUpdate))
    end
    if luaui.OnFixedUpdate ~= nil then
      csui:SetLuaOnFixedUpdateCallback(callback.handler(luaui, luaui.OnFixedUpdate))
    end
    if luaui.IsFullScreen ~= nil then
      csui:SetLuaIsFullScreenCallback(callback.handler(luaui, luaui.IsFullScreen))
    end
    if luaui.IsOpenGuassianBlur ~= nil then
      csui:SetLuaLuaIsOpenGuassianBlurCallback(callback.handler(luaui, luaui.IsOpenGuassianBlur))
    end
    if luaui.GetRootTransformType ~= nil then
      csui:SetLuaRootTransformTypeCallback(callback.handler(luaui, luaui.GetRootTransformType))
    end
    if luaui.DownloadResource ~= nil then
      csui:SetLuaDownloadResourceCallback(callback.handler(luaui, luaui.DownloadResource))
    end
    luaui.__params = {}
    local ref = WeakReference(csui)
    
    local function resetCallback()
      if ref.IsAlive then
        ref.Target:ResetLua()
      end
    end
    
    LuaManagerInstance:AddResetCallback(resetCallback, ref)
  end
end

function UnbindLuaUI(luaUI)
  if luaUI.m_csui ~= nil then
    CS.UI.UILuaHelper.UnbindViewObjects(luaUI, luaUI.m_csui)
    luaUI.m_csui = nil
  end
end

CS.UI.UIBase.SetLuaBinder(BindLuaUI)
CS.UI.UIBase.SetLuaUnbinder(UnbindLuaUI)

local function resetCallback()
  CS.UI.UIBase.SetLuaBinder(nil)
end

LuaManagerInstance:AddResetCallback(resetCallback)
StackBottom = CS.UI.UIStatic.StackBottom
StackFlow = CS.UI.UIStatic.StackFlow
StackPopup = CS.UI.UIStatic.StackPopup
StackTop = CS.UI.UIStatic.StackTop
StackSpecial = CS.UI.UIStatic.StackSpecial
