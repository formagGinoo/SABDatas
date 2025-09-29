local Form_LoungeAdditionPopUI = class("Form_LoungeAdditionPopUI", require("UI/Common/UIBase"))

function Form_LoungeAdditionPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoungeAdditionPopUI:GetID()
  return UIDefines.ID_FORM_LOUNGEADDITIONPOP
end

function Form_LoungeAdditionPopUI:GetFramePrefabName()
  return "Form_LoungeAdditionPop"
end

return Form_LoungeAdditionPopUI
