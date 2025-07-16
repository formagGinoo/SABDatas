local Form_MallGoodsChapterUpgradeUI = class("Form_MallGoodsChapterUpgradeUI", require("UI/Common/UIBase"))

function Form_MallGoodsChapterUpgradeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MallGoodsChapterUpgradeUI:GetID()
  return UIDefines.ID_FORM_MALLGOODSCHAPTERUPGRADE
end

function Form_MallGoodsChapterUpgradeUI:GetFramePrefabName()
  return "Form_MallGoodsChapterUpgrade"
end

return Form_MallGoodsChapterUpgradeUI
