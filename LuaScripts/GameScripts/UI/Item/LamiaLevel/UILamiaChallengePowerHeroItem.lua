local UIItemBase = require("UI/Common/UIItemBase")
local UILamiaChallengePowerHeroItem = class("UILamiaChallengePowerHeroItem", UIItemBase)

function UILamiaChallengePowerHeroItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_showPowerHeroData = nil
  self.m_heroCommonItem = self:createCommonItem(self.m_common_hero_small)
end

function UILamiaChallengePowerHeroItem:OnFreshData()
  self.m_showPowerHeroData = self.m_itemData
  self:FreshItemUI()
end

function UILamiaChallengePowerHeroItem:FreshItemUI()
  if not self.m_showPowerHeroData then
    return
  end
  local processData = ResourceUtil:GetProcessRewardData({
    iID = self.m_showPowerHeroData.characterID,
    iNum = 0
  })
  self.m_heroCommonItem:SetItemInfo(processData)
  UILuaHelper.SetActive(self.m_img_border_gray, not self.m_showPowerHeroData.isHave)
  self.m_txt_heroname_Text.text = self.m_showPowerHeroData.characterCfg.m_mName
  local buffDescStr = self.m_showPowerHeroData.config.m_mBuffDes
  local buffParams = self.m_showPowerHeroData.config.m_SkillValue
  if 0 < buffParams.Length then
    buffParams = utils.changeCSArrayToLuaTable(buffParams)
    buffDescStr = string.CS_Format(buffDescStr, table.unpack(buffParams))
  end
  self.m_txt_herodes_Text.text = buffDescStr
end

return UILamiaChallengePowerHeroItem
