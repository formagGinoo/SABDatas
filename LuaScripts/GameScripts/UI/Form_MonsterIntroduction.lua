local Form_MonsterIntroduction = class("Form_MonsterIntroduction", require("UI/UIFrames/Form_MonsterIntroductionUI"))
local MonsterCfgIns = ConfigManager:GetConfigInsByName("Monster")
local MonsterTipsCfgIns = ConfigManager:GetConfigInsByName("MonsterTips")
local InGameSkillIns = ConfigManager:GetConfigInsByName("Skill")
local CareerCfgIns = ConfigManager:GetConfigInsByName("CharacterCareer")

function Form_MonsterIntroduction:SetInitParam(param)
end

function Form_MonsterIntroduction:GetRootTransformType()
  return UIRootTransformType.Battle
end

function Form_MonsterIntroduction:AfterInit()
  self.super.AfterInit(self)
  self.m_compDisplayUGUI = self.m_pnl_videos:GetComponent(typeof(CS.RenderHeads.Media.AVProVideo.DisplayUGUI))
  self.m_skillDataList = nil
  self.m_skillItemList = {}
  self:InitSkillItem(self.m_skill_base, 1)
end

function Form_MonsterIntroduction:OnOpen()
  self.super.OnOpen(self)
  ReportManager:ReportSystemModuleOpen("Form_MonsterIntroduction")
end

local function OnVideoEvent(et, error)
end

local function OnVideoPlayStart()
end

function Form_MonsterIntroduction:OnActive()
  self.super.OnActive(self)
  self.m_compDisplayUGUI.CurrentMediaPlayer = CS.VideoManager.GlobalVideoPlayer
  CS.VideoManager.Instance:mActionVideoEvent("+", OnVideoEvent)
  CS.VideoManager.Instance:OnPlayStart("+", OnVideoPlayStart)
  self:broadcastEvent("eGameEvent_DeactiveVideoForm")
  self:FreshData()
  self:FreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(104)
end

function Form_MonsterIntroduction:OnInactive()
  self.super.OnInactive(self)
  self.m_compDisplayUGUI.CurrentMediaPlayer = nil
  if self.m_hasPlayedVideo then
    VideoManager:Stop()
  end
  self.m_hasPlayedVideo = false
  CS.VideoManager.Instance:mActionVideoEvent("-", OnVideoEvent)
  CS.VideoManager.Instance:OnPlayStart("-", OnVideoPlayStart)
  self:broadcastEvent("eGameEvent_ActiveVideoForm")
end

function Form_MonsterIntroduction:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_MonsterIntroduction:GetDownloadResourceExtra(tParam)
  local vResourceExtra
  if tParam then
    local monsterTipCfg = MonsterTipsCfgIns:GetValue_ByMonsterID(tParam)
    if not monsterTipCfg:GetError() and monsterTipCfg.m_MonsterType == 3 then
      vResourceExtra = {}
      local length = monsterTipCfg.m_Video1.Length
      for i = 0, length - 1 do
        vResourceExtra[#vResourceExtra + 1] = {
          sName = monsterTipCfg.m_Video1[i],
          eType = DownloadManager.ResourceType.Video
        }
      end
    end
  end
  return nil, vResourceExtra
end

function Form_MonsterIntroduction:AddEventListeners()
end

function Form_MonsterIntroduction:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_MonsterIntroduction:ClearData()
end

function Form_MonsterIntroduction:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_monsterID = tParam
    self.m_monsterCfg = MonsterCfgIns:GetValue_ByMonsterID(self.m_monsterID)
    self.m_monsterTipCfg = MonsterTipsCfgIns:GetValue_ByMonsterID(self.m_monsterID)
  end
end

function Form_MonsterIntroduction:FreshUI()
  if self.m_monsterCfg:GetError() or self.m_monsterTipCfg:GetError() then
    return
  end
  if self.m_monsterTipCfg.m_MonsterType == 3 then
    self:FreshBossContent()
  else
    self:FreshMonsterContent()
  end
end

function Form_MonsterIntroduction:FreshMonsterContent()
  if not self.m_monsterCfg then
    return
  end
  self.m_pnl_boss:SetActive(false)
  self.m_pnl_monster:SetActive(true)
  local monsterCfg = self.m_monsterCfg
  local monsterTipCfg = self.m_monsterTipCfg
  self.m_txt_monster_name_Text.text = monsterCfg.m_mName
  self.m_txt_monster_desc_Text.text = monsterTipCfg.m_mIntroduce
  self:FreshCareer(self.m_img_monster_career_Image, monsterCfg.m_Career)
  self:FreshPortrait(self.m_img_monster_figure_Image)
end

function Form_MonsterIntroduction:FreshBossContent()
  if not self.m_monsterCfg then
    return
  end
  self.m_pnl_boss:SetActive(true)
  self.m_pnl_monster:SetActive(false)
  local monsterCfg = self.m_monsterCfg
  local monsterTipCfg = self.m_monsterTipCfg
  self.m_txt_boss_name_Text.text = monsterCfg.m_mName
  self.m_txt_boss_desc_Text.text = monsterTipCfg.m_mIntroduce
  self:FreshCareer(self.m_img_boss_career_Image, monsterCfg.m_Career)
  self:FreshShowSkillInfo(self.m_monsterTipCfg.m_SkillCount)
  self:FreshPortrait(self.m_img_boss_figure_Image)
  self:SelectSkill(1)
end

function Form_MonsterIntroduction:FreshCareer(image, heroCareer)
  if not heroCareer then
    return
  end
  local careerCfg = CareerCfgIns:GetValue_ByCareerID(heroCareer)
  if careerCfg:GetError() then
    return
  end
  UILuaHelper.SetAtlasSprite(image, careerCfg.m_CareerIcon)
end

function Form_MonsterIntroduction:FreshPortrait(image)
  UILuaHelper.SetAtlasSprite(image, self.m_monsterTipCfg.m_MonsterIcon)
end

function Form_MonsterIntroduction:FreshShowSkillInfo(skillGroup)
  if not skillGroup then
    return
  end
  local skillCfgList = {}
  for i = 0, skillGroup.Length - 1 do
    local skillID = skillGroup[i]
    if skillID then
      local tempSkillCfg = HeroManager:GetSkillConfigById(skillID)
      skillCfgList[#skillCfgList + 1] = tempSkillCfg
    end
  end
  self.m_skillDataList = skillCfgList
  local datalist = self.m_skillDataList
  local dataLen = #datalist
  if dataLen == 0 then
    UILuaHelper.SetActive(self.m_skill_list, false)
  else
    UILuaHelper.SetActive(self.m_skill_list, true)
    local parentTrans = self.m_skill_list.transform
    local childCount = parentTrans.childCount
    local totalFreshNum = dataLen < childCount and childCount or dataLen
    for i = 1, totalFreshNum do
      if i <= childCount and i <= dataLen then
        if self.m_skillItemList[i] == nil then
          local itemTrans = parentTrans:GetChild(i - 1)
          self:InitSkillItem(itemTrans, i)
        end
        local itemTrans = self.m_skillItemList[i].rootNode
        UILuaHelper.SetActive(itemTrans, true)
        self:FreshSkillItem(i, datalist[i])
      elseif i > childCount and i <= dataLen then
        local itemTrans = parentTrans:GetChild(0)
        local newItemTrans = GameObject.Instantiate(itemTrans, parentTrans).transform
        self:InitSkillItem(newItemTrans, i)
        UILuaHelper.SetActive(newItemTrans, true)
        self:FreshSkillItem(i, datalist[i])
      elseif i <= childCount and i > dataLen then
        local itemTrans = parentTrans:GetChild(i - 1)
        UILuaHelper.SetActive(itemTrans, false)
        if self.m_skillItemList[i] ~= nil then
          self.m_skillItemList[i].itemData = nil
        end
      end
    end
  end
end

function Form_MonsterIntroduction:InitSkillItem(itemTran, index)
  local itemRootTrans = itemTran.transform
  local skillIcon = itemRootTrans:Find("img_skill"):GetComponent(T_Image)
  local nodeSelect = itemRootTrans:Find("img_skill_select")
  local btnSkill = itemRootTrans:Find("btn_Skill"):GetComponent(T_Button)
  UILuaHelper.BindButtonClickManual(self, btnSkill, function()
    self:OnSkillItemClk(index)
  end)
  local showItem = {
    skillIcon = skillIcon,
    nodeSelect = nodeSelect,
    itemData = nil,
    rootNode = itemRootTrans
  }
  self.m_skillItemList[index] = showItem
end

function Form_MonsterIntroduction:FreshSkillItem(index, skillData)
  local showItem = self.m_skillItemList[index]
  if showItem == nil then
    return
  end
  showItem.itemData = skillData
  UILuaHelper.SetAtlasSprite(showItem.skillIcon, skillData.m_Skillicon)
end

function Form_MonsterIntroduction:FreshSkillInfo(skillData, index)
  self.m_txt_skill_name_Text.text = skillData.m_mName
  self.m_txt_skill_desc_Text.text = skillData.m_mSkillDescription
  self.m_hasPlayedVideo = true
  CS.UI.UILuaHelper.PlayFromAddRes(self.m_monsterTipCfg.m_Video1[index - 1], "", false, handler(self, self.OnVideoPlayFinish), CS.UnityEngine.ScaleMode.ScaleToFit, true, false)
end

function Form_MonsterIntroduction:SelectSkill(index)
  if self.m_hasPlayedVideo then
    VideoManager:Stop()
  end
  self.m_hasPlayedVideo = false
  for k, v in ipairs(self.m_skillItemList) do
    if k == index then
      v.nodeSelect.gameObject:SetActive(true)
    else
      v.nodeSelect.gameObject:SetActive(false)
    end
  end
  self:FreshSkillInfo(self.m_skillItemList[index].itemData, index)
end

function Form_MonsterIntroduction:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_MonsterIntroduction:OnSkillItemClk(skillIndex)
  local skillItem = self.m_skillItemList[skillIndex]
  if not skillItem then
    return
  end
  self:SelectSkill(skillIndex)
end

function Form_MonsterIntroduction:IsOpenGuassianBlur()
  return true
end

function Form_MonsterIntroduction:OnBtnbgClicked()
  self:CloseForm()
end

local fullscreen = true
ActiveLuaUI("Form_MonsterIntroduction", Form_MonsterIntroduction)
return Form_MonsterIntroduction
