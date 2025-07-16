local LegacySkillIcon = class("LegacySkillIcon")
local SkillIns = ConfigManager:GetConfigInsByName("Skill")

function LegacySkillIcon:ctor(goRoot)
  self.m_goRoot = goRoot
  self.m_goRootTrans = goRoot.transform
  self:InitComponents()
  self.m_itemClkBack = nil
  self.m_skillID = nil
  self.m_skillLv = nil
end

function LegacySkillIcon:InitComponents()
  if not self.m_goRootTrans then
    return
  end
  self.m_pnl_btn = self.m_goRootTrans:Find("pnl_btn"):GetComponent(T_Button)
  if self.m_pnl_btn then
    self.m_pnl_btn.onClick:RemoveAllListeners()
    self.m_pnl_btn.onClick:AddListener(function()
      self:OnItemClicked()
    end)
  end
  self.m_icon_Image = self.m_goRootTrans:Find("offset/c_icon"):GetComponent(T_Image)
  self.m_img_rectangle = self.m_goRootTrans:Find("offset/c_img_rectangle")
  self.m_txt_lv_num_Text = self.m_goRootTrans:Find("offset/c_img_rectangle/c_txt_lv_num_skill"):GetComponent(T_TextMeshProUGUI)
  self.m_img_lock = self.m_goRootTrans:Find("offset/c_img_lock")
  self.m_img_icon_Image = self.m_goRootTrans:Find("offset/c_img_lock/c_img_icon"):GetComponent(T_Image)
end

function LegacySkillIcon:FreshSkillInfo(skillID, skillLv)
  if not skillID then
    return
  end
  local skillCfg = SkillIns:GetValue_BySkillID(skillID)
  if not skillCfg or skillCfg:GetError() == true then
    return
  end
  self.m_txt_lv_num_Text.text = skillLv or 0
  UILuaHelper.SetAtlasSprite(self.m_icon_Image, skillCfg.m_Skillicon)
  UILuaHelper.SetAtlasSprite(self.m_img_icon_Image, skillCfg.m_Skillicon)
end

function LegacySkillIcon:FreshSkillIsLock(isLock)
  self.m_isLock = isLock
  UILuaHelper.SetActive(self.m_img_lock, isLock)
  UILuaHelper.SetActive(self.m_img_rectangle, not isLock)
end

function LegacySkillIcon:SetActive(isActive)
  UILuaHelper.SetActive(self.m_goRoot, isActive)
end

function LegacySkillIcon:GetRootTrans()
  return self.m_goRoot.transform
end

function LegacySkillIcon:SetItemClickBack(itemClkBack)
  if not itemClkBack then
    return
  end
  self.m_itemClkBack = itemClkBack
end

function LegacySkillIcon:OnItemClicked()
  if self.m_itemClkBack then
    if self.m_clkTimer then
      TimeService:KillTimer(self.m_clkTimer)
      self.m_clkTimer = nil
    end
    self.m_clkTimer = TimeService:SetTimer(0.03, 1, function()
      self.m_clkTimer = nil
      self.m_itemClkBack(self.m_skillID, self.m_skillLv, self.m_isLock)
    end)
  end
end

function LegacySkillIcon:OnDestroy()
  if self.m_clkTimer then
    TimeService:KillTimer(self.m_clkTimer)
    self.m_clkTimer = nil
  end
end

return LegacySkillIcon
