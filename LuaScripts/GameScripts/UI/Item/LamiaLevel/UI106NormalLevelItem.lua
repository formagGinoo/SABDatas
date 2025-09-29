local UIItemBase = require("UI/Item/LamiaLevel/UIHeroActLevelBase")
local UI106NormalLevelItem = class("UI106NormalLevelItem", UIItemBase)
local posEnum = {
  [0] = Vector2.New(0, 100),
  [1] = Vector2.New(0, -41)
}

function UI106NormalLevelItem:InitComponent()
  local itemTrans = self.m_itemRootObj.transform
  local item_nml = itemTrans:Find("item_nml")
  if not utils.isNull(item_nml) then
    self.m_itemTrans = item_nml:GetComponent("RectTransform")
  end
  self.m_normal_bg = itemTrans:Find("item_nml/bg_name")
  self.m_hard_bg = itemTrans:Find("item_nml/bg_name_hard")
  self.m_txt_level_name = self.m_itemTemplateCache:TMPPro("c_txt_name")
  self.m_txt_level_title = self.m_itemTemplateCache:TMPPro("c_txt_name_num")
  self.m_bg_lock = itemTrans:Find("item_nml/bg_lock")
  self.m_bg_lock_hard = itemTrans:Find("item_nml/bg_lock_hard")
  self.m_choose_image = self.m_itemTemplateCache:GameObject("c_img_icondone")
  self.m_repeat_tag = itemTrans:Find("item_nml/btn_icon_repeat")
  local btn_touch = itemTrans:Find("item_nml/btn_touch")
  if not utils.isNull(btn_touch) then
    self.m_btn_Extension = btn_touch:GetComponent("ButtonExtensions")
    self.m_btn_Extension.Clicked = handler(self, self.OnBtnItemClk)
  end
  local btn_repeat = itemTrans:Find("item_nml/btn_icon_repeat")
  if not utils.isNull(btn_repeat) then
    self.m_btn_repeat = btn_repeat:GetComponent("ButtonExtensions")
    self.m_btn_repeat.Clicked = handler(self, self.OnBtnRepeatClk)
  end
end

function UI106NormalLevelItem:OnBtnRewardClk()
  local clueCfg = HeroActivityManager:GetAct4ClueCfgByID(self.m_itemIndex)
  if clueCfg then
    local bIsUnlock = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelHavePass(clueCfg.m_PreLevel)
    if bIsUnlock then
      StackFlow:Push(UIDefines.ID_FORM_ACTIVITY104_DIALOGUECLUE, {
        iActID = self.m_levelCfg.m_ActivityID,
        act4ClueCfg = clueCfg
      })
    else
      local levelCfg = LevelHeroLamiaActivityManager:GetLevelHelper():GetLevelCfgByID(clueCfg.m_PreLevel)
      local bUnlockStr = HeroActivityManager:GetLevelUnlockStr(levelCfg)
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, bUnlockStr)
    end
  end
end

return UI106NormalLevelItem
