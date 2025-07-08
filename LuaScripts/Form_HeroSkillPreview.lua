local Form_HeroSkillPreview = class("Form_HeroSkillPreview", require("UI/UIFrames/Form_HeroSkillPreviewUI"))
local SkillGroupInstance = ConfigManager:GetConfigInsByName("SkillGroup")
local InGameSkillInstance = ConfigManager:GetConfigInsByName("Skill")

function Form_HeroSkillPreview:SetInitParam(param)
end

function Form_HeroSkillPreview:AfterInit()
  self.super.AfterInit(self)
  self.m_skillListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_skill_InfinityGrid, "Skill/UIHeroSKillItem")
  self.m_ScrollContent = self.m_scrollView_skill_InfinityGrid.transform:Find("viewport/content")
end

function Form_HeroSkillPreview:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_heroCfgId = tParam.hero_cfg_id
  self.m_skill_list = tParam.skill_list or {}
  self:RefreshUI()
end

function Form_HeroSkillPreview:OnInactive()
  self.super.OnInactive(self)
  self.m_skillListInfinityGrid:DisPoseItems()
end

function Form_HeroSkillPreview:RefreshUI()
  local skillInfoList = self:FreshShowSkillInfo()
  self.m_skillListInfinityGrid:ShowItemList(skillInfoList)
  local posX, posY, posZ = UILuaHelper.GetLocalPosition(self.m_ScrollContent)
  UILuaHelper.SetLocalPosition(self.m_ScrollContent, posX, 0, posZ)
end

function Form_HeroSkillPreview:FreshShowSkillInfo()
  local heroCfg = HeroManager:GetHeroConfigByID(self.m_heroCfgId)
  local skillGroupID = heroCfg.m_SkillGroupID[0]
  local skillGroupCfgList = HeroManager:GetSkillGroupCfgList(skillGroupID)
  local OverMaxSkillTag = #HeroManager.HeroSkillTagSort + 1
  table.sort(skillGroupCfgList, function(a, b)
    local skillTagA = a.m_SkillShowType
    local skillTagB = b.m_SkillShowType
    local skillSortA = HeroManager.HeroSkillTagSort[skillTagA] or OverMaxSkillTag
    local skillSortB = HeroManager.HeroSkillTagSort[skillTagB] or OverMaxSkillTag
    return skillSortA < skillSortB
  end)
  local skillDesTab = HeroManager:GetHeroSkillDataByHeroCfgId(self.m_heroCfgId, self.m_skill_list)
  local upStarDesTab = HeroManager:GetHeroUpStarSkillDes(self.m_heroCfgId)
  local skillInfoList = {}
  for _, skillGroupCfg in ipairs(skillGroupCfgList) do
    local skillID = skillGroupCfg.m_SkillID
    if skillID then
      local skillLv = self.m_skill_list[skillID] ~= nil and self.m_skill_list[skillID] or HeroManager:GetHeroSkillLvById(self.m_heroCfgId, skillID)
      local tempSkillCfg = HeroManager:GetSkillConfigById(skillID)
      local skillTypeName, skillShowType = HeroManager:GetHeroSkillShowTypeDes(self.m_heroCfgId, skillID)
      skillInfoList[#skillInfoList + 1] = {
        skillLv = skillLv,
        skillCfg = tempSkillCfg,
        skillDes = skillDesTab[skillID],
        upStarDesTab = upStarDesTab,
        skillTypeName = skillTypeName,
        skillShowType = skillShowType,
        skillGroupID = skillGroupID
      }
    end
  end
  return skillInfoList
end

function Form_HeroSkillPreview:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HeroSkillPreview:IsOpenGuassianBlur()
  return true
end

function Form_HeroSkillPreview:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_HeroSkillPreview:OnBtnReturnClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_HeroSkillPreview", Form_HeroSkillPreview)
return Form_HeroSkillPreview
