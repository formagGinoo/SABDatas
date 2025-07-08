local LevelMaterialItem = class("LevelMaterialItem")
local MaxProgressNum = LevelManager.GoblinMaxProgressNum

function LevelMaterialItem:ctor(goRoot)
  self.m_goRoot = goRoot
  self.m_goRootTrans = goRoot.transform
  UILuaHelper.BindViewObjectsManual(self, self.m_goRoot, "LevelMaterialItem")
  self.m_fItemClkBack = nil
  self.m_levelCfg = nil
  self.m_levelGoblinHelper = LevelManager:GetLevelGoblinHelper()
end

function LevelMaterialItem:OnUpdate(dt)
end

function LevelMaterialItem:OnDestroy()
  UILuaHelper.UnbindViewObjectsManual(self, self.m_goRoot, "LevelMaterialItem")
end

function LevelMaterialItem:FreshMaterialLevel(levelCfg)
  if not levelCfg then
    return
  end
  self.m_levelCfg = levelCfg
  self:FreshLevelNum()
  self:FreshRedShow()
  self:FreshMonsterIcon()
  self:FreshLockStatus()
end

function LevelMaterialItem:FreshLevelNum()
  if not self.m_levelCfg then
    return
  end
  self.m_txt_level_num_Text.text = self.m_levelCfg.m_mName
end

function LevelMaterialItem:FreshRedShow()
  if not self.m_levelCfg then
    return
  end
  UILuaHelper.SetActive(self.m_img_red, self.m_levelGoblinHelper:IsLevelHaveRedDot(LevelManager.GoblinSubType.Skill, self.m_levelCfg.m_LevelID) > 0)
end

function LevelMaterialItem:FreshMonsterIcon()
  if not self.m_levelCfg then
    return
  end
  if self.m_levelCfg.m_Icon == nil or self.m_levelCfg.m_Icon == "" then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_monster_icon, self.m_levelCfg.m_Icon)
end

function LevelMaterialItem:FreshLockStatus()
  if not self.m_levelCfg then
    return
  end
  local isUnlock = self.m_levelGoblinHelper:IsLevelUnLock(self.m_levelCfg.m_LevelID)
  UILuaHelper.SetActive(self.m_img_lock, not isUnlock)
  UILuaHelper.SetActive(self.m_node_progress, isUnlock)
  if isUnlock then
    self:FreshShowScoreProcess()
  end
end

function LevelMaterialItem:SetActive(isActive)
  UILuaHelper.SetActive(self.m_goRoot, isActive)
end

function LevelMaterialItem:FreshShowScoreProcess()
  local goblinHelper = LevelManager:GetLevelGoblinHelper()
  local curStageIndex, rewardStageNum, scoreNum = goblinHelper:GetGoblinRewardIndex(self.m_levelCfg)
  curStageIndex = curStageIndex or 0
  rewardStageNum = rewardStageNum or 0
  UILuaHelper.SetActive(self.m_node_progress, 0 < scoreNum)
  if scoreNum <= 0 then
    return
  end
  for i = 1, MaxProgressNum do
    UILuaHelper.SetActive(self["m_pnl_item" .. i], i <= rewardStageNum)
    if i <= rewardStageNum then
      UILuaHelper.SetActive(self["m_unfinish_item" .. i], i > curStageIndex)
      UILuaHelper.SetActive(self["m_finish_item" .. i], i <= curStageIndex)
      if 2 <= curStageIndex then
        local processNum = curStageIndex - 1
        local maxProcessNum = MaxProgressNum - 1
        local percentNum = processNum / maxProcessNum
        self.m_img_line_progress_Image.fillAmount = percentNum
      else
        self.m_img_line_progress_Image.fillAmount = 0
      end
    end
  end
end

function LevelMaterialItem:SetItemClkBack(clkBackFun)
  if not clkBackFun then
    return
  end
  self.m_fItemClkBack = clkBackFun
end

function LevelMaterialItem:OnBtnLevelItemClicked()
  if self.m_fItemClkBack then
    self.m_fItemClkBack(self.m_levelCfg.m_LevelID)
  end
end

return LevelMaterialItem
