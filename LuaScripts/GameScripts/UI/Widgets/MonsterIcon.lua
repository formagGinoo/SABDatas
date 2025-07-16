local MonsterIcon = class("MonsterIcon")
local PresentationIns = ConfigManager:GetConfigInsByName("Presentation")
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")

function MonsterIcon:ctor(goRoot)
  self.m_objRoot = goRoot
  self.m_goRootTrans = goRoot.transform
  UILuaHelper.BindViewObjectsManual(self, self.m_objRoot, "MonsterIcon")
  self:InitComponents()
  self.m_monsterID = nil
end

function MonsterIcon:OnDestroy()
  self.m_monsterID = nil
  UILuaHelper.UnbindViewObjectsManual(self, self.m_objRoot, "BackButton")
end

function MonsterIcon:InitComponents()
  if not self.m_goRootTrans then
    return
  end
  if self.m_img_bg_selected then
    UILuaHelper.SetActive(self.m_img_bg_selected, false)
  end
end

function MonsterIcon:OnUpdate(dt)
end

function MonsterIcon:SetMonsterData(monsterCfg, isHide)
  self.m_monsterID = nil
  if not monsterCfg then
    return
  end
  self.m_monsterCfg = monsterCfg
  self.m_monsterID = monsterCfg.m_MonsterID
  self.m_isHide = isHide
  self:FreshMonsterShow()
end

function MonsterIcon:FreshMonsterShow()
  if not self.m_monsterCfg then
    return
  end
  UILuaHelper.SetActive(self.m_monster_detail, self.m_isHide ~= true)
  UILuaHelper.SetActive(self.m_monster_unknow, self.m_isHide == true)
  if self.m_isHide ~= true then
    self:FreshHeadIcon(self.m_monsterCfg.m_PerformanceID[0])
    self:FreshMonsterBorder(self.m_monsterCfg)
    self:FreshShowCareer(self.m_monsterCfg.m_Career)
  end
end

function MonsterIcon:FreshHeadIcon(performanceID)
  if not performanceID then
    return
  end
  local presentationData = PresentationIns:GetValue_ByPerformanceID(performanceID)
  if not presentationData.m_UIkeyword then
    return
  end
  local szIcon = presentationData.m_UIkeyword .. "001"
  UILuaHelper.SetAtlasSprite(self.m_img_head_Image, szIcon)
end

function MonsterIcon:FreshShowCareer(careerID)
  if not careerID then
    return
  end
  local careerCfg = CareerCfgIns:GetValue_ByCareerID(careerID)
  if careerCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_icon_career_Image, careerCfg.m_CareerIcon)
end

function MonsterIcon:FreshMonsterBorder(monsterCfg)
  if not monsterCfg then
    return
  end
  local monsterType = monsterCfg.m_MonsterType
  UILuaHelper.SetActive(self.m_img_border_boss, monsterType == HeroManager.MonsterType.Boss or monsterType == HeroManager.MonsterType.RogueBossMonster)
  UILuaHelper.SetActive(self.m_img_border_elite, monsterType == HeroManager.MonsterType.Elite)
end

function MonsterIcon:SetParent(parentTrans)
  if not parentTrans then
    return
  end
  if not self.m_objRoot then
    return
  end
  UILuaHelper.SetParent(self.m_objRoot, parentTrans)
end

function MonsterIcon:SetActive(isActive)
  if not self.m_objRoot then
    return
  end
  self.m_objRoot:SetActive(isActive)
end

function MonsterIcon:SetClickCB(fClickCB)
  if fClickCB then
    self.m_btnClickBack = fClickCB
  end
end

function MonsterIcon:OnBtnClickClicked()
  if self.m_btnClickBack then
    self.m_btnClickBack(self.m_monsterID)
  end
end

return MonsterIcon
