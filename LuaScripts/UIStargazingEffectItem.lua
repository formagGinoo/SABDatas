local UIItemBase = require("UI/Common/UIItemBase")
local UIStargazingEffectItem = class("UIStargazingEffectItem", UIItemBase)

function UIStargazingEffectItem:OnInit()
end

function UIStargazingEffectItem:OnFreshData()
  local transform = self.m_itemRootObj.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local iStarID = self.m_itemData.iStarID
  local iConstellationID = self.m_itemData.iConstellationID
  local starInfo = StargazingManager:GetStarInfo(iConstellationID, iStarID)
  if StargazingManager:IsStarUnlock(iConstellationID, iStarID) then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_pnl_unlock", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_pnl_lock", false)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_desc_unlock", starInfo.m_mEffectDes)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_title_unlock", starInfo.m_mStarName)
  else
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_pnl_lock", true)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_pnl_unlock", false)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_desc_lock", starInfo.m_mEffectDes)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_title_lock", starInfo.m_mStarName)
  end
end

function UIStargazingEffectItem:dispose()
  UIStargazingEffectItem.super.dispose(self)
end

function UIStargazingEffectItem:PlayEffectIn()
  UILuaHelper.PlayAnimationByName(self.m_itemRootObj, "CastleStarMain_sctollview_item_in")
end

return UIStargazingEffectItem
