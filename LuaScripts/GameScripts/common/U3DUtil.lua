U3DUtil = {}
local M = U3DUtil
local KEY_CODE_W = CS.UnityEngine.KeyCode.W
local KEY_CODE_S = CS.UnityEngine.KeyCode.S
local KEY_CODE_A = CS.UnityEngine.KeyCode.A
local KEY_CODE_D = CS.UnityEngine.KeyCode.D
local KEY_CODE_O = CS.UnityEngine.KeyCode.O
local KEY_CODE_E = CS.UnityEngine.KeyCode.E
local KEY_CODE_P = CS.UnityEngine.KeyCode.P
local KEY_CODE_Q = CS.UnityEngine.KeyCode.Q
local KEY_CODE_Z = CS.UnityEngine.KeyCode.Z
local KEY_CODE_R = CS.UnityEngine.KeyCode.R
local KEY_CODE_F = CS.UnityEngine.KeyCode.F
local KEY_CODE_G = CS.UnityEngine.KeyCode.G
local KEY_CODE_J = CS.UnityEngine.KeyCode.J
local KEY_CODE_C = CS.UnityEngine.KeyCode.C
local KEY_CODE_B = CS.UnityEngine.KeyCode.B
local KEY_CODE_KeypadMultiply = CS.UnityEngine.KeyCode.KeypadMultiply
local KEY_CODE_KeypadMinus = CS.UnityEngine.KeyCode.KeypadMinus
local KEY_CODE_BackQuote = CS.UnityEngine.KeyCode.BackQuote
local KEY_CODE_Alpha1 = CS.UnityEngine.KeyCode.Alpha1
local KEY_CODE_Alpha2 = CS.UnityEngine.KeyCode.Alpha2
local KEY_CODE_Alpha3 = CS.UnityEngine.KeyCode.Alpha3
local KEY_CODE_KeypadPlus = CS.UnityEngine.KeyCode.KeypadPlus
local KEY_CODE_LeftAlt = CS.UnityEngine.KeyCode.LeftAlt
local KEY_CODE_F1 = CS.UnityEngine.KeyCode.F1
local KEY_CODE_F2 = CS.UnityEngine.KeyCode.F2
local KEY_CODE_F3 = CS.UnityEngine.KeyCode.F3
local KEY_CODE_F4 = CS.UnityEngine.KeyCode.F4
local KEY_CODE_ESC = CS.UnityEngine.KeyCode.Escape
local KEY_CODE_SPACE = CS.UnityEngine.KeyCode.Space
local KEY_CODE_TAB = CS.UnityEngine.KeyCode.Tab

function M:init()
end

function M:Input_GetKeyDown(keyCode)
  local u3d_keycode
  if keyCode == "w" then
    u3d_keycode = KEY_CODE_W
  elseif keyCode == "s" then
    u3d_keycode = KEY_CODE_S
  elseif keyCode == "a" then
    u3d_keycode = KEY_CODE_A
  elseif keyCode == "d" then
    u3d_keycode = KEY_CODE_D
  elseif keyCode == "o" then
    u3d_keycode = KEY_CODE_O
  elseif keyCode == "e" then
    u3d_keycode = KEY_CODE_E
  elseif keyCode == "p" then
    u3d_keycode = KEY_CODE_P
  elseif keyCode == "q" then
    u3d_keycode = KEY_CODE_Q
  elseif keyCode == "z" then
    u3d_keycode = KEY_CODE_Z
  elseif keyCode == "r" then
    u3d_keycode = KEY_CODE_R
  elseif keyCode == "f" then
    u3d_keycode = KEY_CODE_F
  elseif keyCode == "g" then
    u3d_keycode = KEY_CODE_G
  elseif keyCode == "j" then
    u3d_keycode = KEY_CODE_J
  elseif keyCode == "c" then
    u3d_keycode = KEY_CODE_C
  elseif keyCode == "b" then
    u3d_keycode = KEY_CODE_B
  elseif keyCode == "*" then
    u3d_keycode = KEY_CODE_KeypadMultiply
  elseif keyCode == "-" then
    u3d_keycode = KEY_CODE_KeypadMinus
  elseif keyCode == "`" then
    u3d_keycode = KEY_CODE_BackQuote
  elseif keyCode == "1" then
    u3d_keycode = KEY_CODE_Alpha1
  elseif keyCode == "2" then
    u3d_keycode = KEY_CODE_Alpha2
  elseif keyCode == "3" then
    u3d_keycode = KEY_CODE_Alpha3
  elseif keyCode == "+" then
    u3d_keycode = KEY_CODE_KeypadPlus
  elseif keyCode == "left-alt" then
    u3d_keycode = KEY_CODE_LeftAlt
  elseif keyCode == "f1" then
    u3d_keycode = KEY_CODE_F1
  elseif keyCode == "f2" then
    u3d_keycode = KEY_CODE_F2
  elseif keyCode == "f3" then
    u3d_keycode = KEY_CODE_F3
  elseif keyCode == "f4" then
    u3d_keycode = KEY_CODE_F4
  elseif keyCode == "ESC" then
    u3d_keycode = KEY_CODE_ESC
  elseif keyCode == "space" then
    u3d_keycode = KEY_CODE_SPACE
  elseif keyCode == "tab" then
    u3d_keycode = KEY_CODE_TAB
  end
  if u3d_keycode and CS.UnityEngine.Input.GetKeyDown(u3d_keycode) then
    return true
  else
    return false
  end
end

function M:Input_GetKeyUp(keyCode)
  local u3d_keycode
  if keyCode == "w" then
    u3d_keycode = KEY_CODE_W
  elseif keyCode == "s" then
    u3d_keycode = KEY_CODE_S
  elseif keyCode == "a" then
    u3d_keycode = KEY_CODE_A
  elseif keyCode == "d" then
    u3d_keycode = KEY_CODE_D
  elseif keyCode == "o" then
    u3d_keycode = KEY_CODE_O
  elseif keyCode == "e" then
    u3d_keycode = KEY_CODE_E
  elseif keyCode == "p" then
    u3d_keycode = KEY_CODE_P
  elseif keyCode == "q" then
    u3d_keycode = KEY_CODE_Q
  elseif keyCode == "z" then
    u3d_keycode = KEY_CODE_Z
  elseif keyCode == "r" then
    u3d_keycode = KEY_CODE_R
  elseif keyCode == "f" then
    u3d_keycode = KEY_CODE_F
  elseif keyCode == "g" then
    u3d_keycode = KEY_CODE_G
  elseif keyCode == "j" then
    u3d_keycode = KEY_CODE_J
  elseif keyCode == "c" then
    u3d_keycode = KEY_CODE_C
  elseif keyCode == "b" then
    u3d_keycode = KEY_CODE_B
  elseif keyCode == "*" then
    u3d_keycode = KEY_CODE_KeypadMultiply
  elseif keyCode == "-" then
    u3d_keycode = KEY_CODE_KeypadMinus
  elseif keyCode == "`" then
    u3d_keycode = KEY_CODE_BackQuote
  elseif keyCode == "1" then
    u3d_keycode = KEY_CODE_Alpha1
  elseif keyCode == "2" then
    u3d_keycode = KEY_CODE_Alpha2
  elseif keyCode == "3" then
    u3d_keycode = KEY_CODE_Alpha3
  elseif keyCode == "+" then
    u3d_keycode = KEY_CODE_KeypadPlus
  elseif keyCode == "left-alt" then
    u3d_keycode = KEY_CODE_LeftAlt
  elseif keyCode == "f1" then
    u3d_keycode = KEY_CODE_F1
  elseif keyCode == "f2" then
    u3d_keycode = KEY_CODE_F2
  elseif keyCode == "f3" then
    u3d_keycode = KEY_CODE_F3
  elseif keyCode == "f4" then
    u3d_keycode = KEY_CODE_F4
  elseif keyCode == "ESC" then
    u3d_keycode = KEY_CODE_ESC
  elseif keyCode == "space" then
    u3d_keycode = KEY_CODE_SPACE
  elseif keyCode == "tab" then
    u3d_keycode = KEY_CODE_TAB
  end
  if u3d_keycode and CS.UnityEngine.Input.GetKeyUp(u3d_keycode) then
    return true
  else
    return false
  end
end

function M:Input_GetMouseButtonDown(value)
  return CS.UnityEngine.Input.GetMouseButtonDown(value)
end

function M:Input_GetMouseButtonUp(value)
  return CS.UnityEngine.Input.GetMouseButtonUp(value)
end

function M:Input_GetMouseAxis(value)
  return CS.UnityEngine.Input.GetAxis(value)
end

function M:GetMousePosition()
  return CS.UnityEngine.Input.mousePosition
end

function M:Get_EventTriggerType(type_name)
  if type_name == "PointerDown" then
    return CS.UnityEngine.EventSystems.EventTriggerType.PointerDown
  elseif type_name == "PointerUp" then
    return CS.UnityEngine.EventSystems.EventTriggerType.PointerUp
  elseif type_name == "PointerEnter" then
    return CS.UnityEngine.EventSystems.EventTriggerType.PointerEnter
  elseif type_name == "PointerExit" then
    return CS.UnityEngine.EventSystems.EventTriggerType.PointerExit
  elseif type_name == "Drag" then
    return CS.UnityEngine.EventSystems.EventTriggerType.Drag
  end
end

function M:GetSystemLanguageID()
  return CS.LuaCallCS.GetSystemLanguageID()
end

return M
