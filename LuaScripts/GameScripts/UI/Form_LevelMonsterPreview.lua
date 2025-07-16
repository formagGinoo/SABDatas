local Form_LevelMonsterPreview = class("Form_LevelMonsterPreview", require("UI/UIFrames/Form_LevelMonsterPreviewUI"))
local MonsterGroupIns = ConfigManager:GetConfigInsByName("MonsterGroup")
local MonsterCfgIns = ConfigManager:GetConfigInsByName("Monster")
local SkillGroupIns = ConfigManager:GetConfigInsByName("SkillGroup")
local InGameSkillIns = ConfigManager:GetConfigInsByName("Skill")
local SkillBuffIns = ConfigManager:GetConfigInsByName("SkillBuff")
local DefaultWaveNum = 1
local DefaultChooseMonsterIndex = 1
local DefaultChooseSkillIndex = 1
local string_format = string.format

function Form_LevelMonsterPreview:SetInitParam(param)
end

function Form_LevelMonsterPreview:AfterInit()
  self.super.AfterInit(self)
  local initEnemyGridData = {
    itemClkBackFun = handler(self, self.OnMonsterIconClk)
  }
  self.m_monster_listInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_monster_list_InfinityGrid, "Monster/UIMonsterPreviewItem", initEnemyGridData)
  self.m_curWaveNum = nil
  self.m_waveDataList = {}
  self.m_skillDataList = nil
  self.m_skillItemList = {}
  self:InitSkillItem(self.m_skill_base, 1)
  self.m_contentMonsterIcon = self:createMonsterIcon(self.m_monster_content_item)
  self.m_buffItemList = {}
  self.m_buffCfgDataList = nil
  self:InitBuffItem(self.m_baseBuff, 1)
end

function Form_LevelMonsterPreview:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(162)
end

function Form_LevelMonsterPreview:OnInactive()
  self.super.OnInactive(self)
end

function Form_LevelMonsterPreview:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_LevelMonsterPreview:AddEventListeners()
end

function Form_LevelMonsterPreview:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_LevelMonsterPreview:ClearData()
end

function Form_LevelMonsterPreview:GetMonsterIDList(hideMonsterArray)
  if not hideMonsterArray then
    return
  end
  if hideMonsterArray.Length <= 0 then
    return {}
  end
  local hideMonsterIDList = {}
  local arrLen = hideMonsterArray.Length
  for i = 0, arrLen - 1 do
    hideMonsterIDList[#hideMonsterIDList + 1] = hideMonsterArray[i]
  end
  return hideMonsterIDList
end

function Form_LevelMonsterPreview:MonsterIsInList(hideMonsterIDList, monsterID)
  if not hideMonsterIDList or not next(hideMonsterIDList) then
    return false
  end
  for _, tempMonsterID in ipairs(hideMonsterIDList) do
    if tempMonsterID == monsterID then
      return true
    end
  end
  return false
end

function Form_LevelMonsterPreview:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  local battleWordID = tParam.battleWorldID
  self.m_stageStr = tParam.stageStr
  if table.getn(tParam.monsterList) > 0 then
    self.m_waveDataList = {
      {
        monsterList = tParam.monsterList
      }
    }
    return
  end
  local battleCfg = ConfigManager:GetBattleWorldCfgById(battleWordID)
  local monsterGroupArray = ConfigManager:BattleWorldMonsterGroupList(battleCfg)
  self.m_waveDataList = {}
  if not monsterGroupArray or monsterGroupArray.Length == 0 then
    return
  end
  local areaIDList = utils.changeCSArrayToLuaTable(ConfigManager:BattleWorldAreaIDList(battleCfg))
  local arrayLen = monsterGroupArray.Length
  local waveDataDic = {}
  for i = 0, arrayLen - 1 do
    local monsterGroupID = monsterGroupArray[i]
    local monsterGroupCfg = MonsterGroupIns:GetValue_ByID(monsterGroupID)
    local isShow = table.indexof(areaIDList, monsterGroupCfg.m_WaveIndex - 1)
    if not monsterGroupCfg:GetError() and isShow then
      local waveData = waveDataDic[monsterGroupCfg.m_WaveIndex]
      if waveData == nil then
        waveData = {
          waveIndex = monsterGroupCfg.m_WaveIndex,
          monsterList = {},
          monsterDic = {},
          isHaveHide = false,
          curMonsterIndex = DefaultChooseMonsterIndex
        }
        waveDataDic[monsterGroupCfg.m_WaveIndex] = waveData
      end
      local monsterList = monsterGroupCfg.m_MonsterList
      if monsterList and 0 < monsterList.Length then
        local monsterLen = monsterList.Length
        local hideMonsterArray = monsterGroupCfg.m_Hide
        local hideMonsterIDList = self:GetMonsterIDList(hideMonsterArray)
        local notShowMonsterIDList = self:GetMonsterIDList(monsterGroupCfg.m_MosterHideView) or {}
        local monsterDic = waveData.monsterDic
        for monsterIndex = 0, monsterLen - 1 do
          local monsterTemp = monsterList[monsterIndex]
          if monsterTemp and monsterTemp[1] then
            local monsterID = monsterTemp[1]
            local monsterCfg = MonsterCfgIns:GetValue_ByMonsterID(monsterID)
            if monsterCfg and not monsterCfg:GetError() and self:MonsterIsInList(notShowMonsterIDList, monsterID) ~= true and monsterDic[monsterID] == nil then
              local isHide = self:MonsterIsInList(hideMonsterIDList, monsterID)
              local battleCamp = monsterCfg.m_BattleCamp
              local isNeedCreat = true
              if isHide and waveData.isHaveHide == true then
                isNeedCreat = false
              end
              if battleCamp == 0 or battleCamp == 1 then
                isNeedCreat = false
              end
              if isNeedCreat then
                if monsterCfg and not monsterCfg:GetError() then
                  local tempEnemyTab = {
                    monsterCfg = monsterCfg,
                    isChoose = false,
                    isHide = isHide
                  }
                  monsterDic[monsterID] = tempEnemyTab
                end
                if isHide then
                  waveData.isHaveHide = true
                end
              end
            end
          end
        end
      end
    end
  end
  for _, waveData in pairs(waveDataDic) do
    local monsterDic = waveData.monsterDic
    local tempEnemyList = {}
    for _, monsterData in pairs(monsterDic) do
      tempEnemyList[#tempEnemyList + 1] = monsterData
    end
    tempEnemyList = HeroManager:GetHeroSort():GetMonsterListSort(tempEnemyList)
    if tempEnemyList[DefaultChooseMonsterIndex] then
      tempEnemyList[DefaultChooseMonsterIndex].isChoose = true
    end
    waveData.monsterList = tempEnemyList
    self.m_waveDataList[#self.m_waveDataList + 1] = waveData
  end
  table.sort(self.m_waveDataList, function(a, b)
    return a.waveIndex < b.waveIndex
  end)
end

function Form_LevelMonsterPreview:FreshUI()
  self:FreshChangeWave(DefaultWaveNum)
  self:FreshStageNum()
end

function Form_LevelMonsterPreview:FreshStageNum()
  self.m_txt_stagenum_Text.text = self.m_stageStr or ""
end

function Form_LevelMonsterPreview:FreshChangeWave(waveNum)
  if not self.m_waveDataList then
    return
  end
  local curWaveData = self.m_waveDataList[waveNum]
  if not curWaveData then
    return
  end
  self.m_curWaveNum = waveNum
  self:FreshWaveTitle()
  self:FreshShowMonsterList()
end

function Form_LevelMonsterPreview:FreshWaveTitle()
  if not self.m_curWaveNum then
    return
  end
  local curWaveNum = self.m_curWaveNum
  local allWaveNum = #self.m_waveDataList
  local waveIndex = allWaveNum == 1 and allWaveNum or self.m_waveDataList[curWaveNum].waveIndex
  self.m_txt_wave_Text.text = waveIndex .. "/" .. allWaveNum
  UILuaHelper.SetActive(self.m_light_last_node, 1 < curWaveNum)
  UILuaHelper.SetActive(self.m_light_next_node, curWaveNum < allWaveNum)
end

function Form_LevelMonsterPreview:FreshShowMonsterList()
  local curWaveData = self.m_waveDataList[self.m_curWaveNum]
  if not curWaveData then
    return
  end
  if curWaveData.monsterList then
    for i, v in ipairs(curWaveData.monsterList) do
      v.isChoose = nil
    end
  end
  local curMonsterData = curWaveData.monsterList[DefaultChooseMonsterIndex]
  if not curMonsterData then
    return
  end
  curMonsterData.isChoose = true
  self.m_monster_listInfinityGrid:ShowItemList(curWaveData.monsterList)
  curWaveData.curMonsterIndex = DefaultChooseMonsterIndex
  self:FreshMonsterContent()
end

function Form_LevelMonsterPreview:FreshMonsterContent()
  if not self.m_curWaveNum then
    return
  end
  local waveData = self.m_waveDataList[self.m_curWaveNum]
  if not waveData then
    return
  end
  local monsterData = waveData.monsterList[waveData.curMonsterIndex]
  if not monsterData then
    return
  end
  local isHide = monsterData.isHide
  UILuaHelper.SetActive(self.m_monster_hide_content, isHide)
  UILuaHelper.SetActive(self.m_monster_detail_content, not isHide)
  if not isHide then
    local monsterCfg = monsterData.monsterCfg
    self.m_txt_monster_name_Text.text = monsterCfg.m_mName
    self.m_txt_monster_desc_Text.text = monsterCfg.m_mIntroduce
    self:FreshMonsterTag(monsterCfg.m_MonsterType)
    self:FreshContentMonsterIcon(monsterData)
    self:FreshShowSkillInfo(monsterCfg.m_SkillGroupID[0])
  end
end

function Form_LevelMonsterPreview:FreshMonsterTag(monsterType)
  UILuaHelper.SetActive(self.m_boss_tag, monsterType == HeroManager.MonsterType.Boss or monsterType == HeroManager.MonsterType.RogueBossMonster)
  UILuaHelper.SetActive(self.m_elite_tag, monsterType == HeroManager.MonsterType.Elite)
  UILuaHelper.SetActive(self.m_normal_tag, monsterType == HeroManager.MonsterType.Normal)
end

function Form_LevelMonsterPreview:FreshContentMonsterIcon(monsterData)
  if not monsterData then
    return
  end
  self.m_contentMonsterIcon:SetMonsterData(monsterData.monsterCfg, monsterData.isHide)
end

function Form_LevelMonsterPreview:FreshShowSkillInfo(skillGroupID)
  if not skillGroupID then
    return
  end
  local skillGroupCfgDic = SkillGroupIns:GetValue_BySkillGroupID(skillGroupID)
  local skillCfgList = {}
  for _, v in pairs(skillGroupCfgDic) do
    local skillID = v.m_SkillID
    if skillID and GlobalConfig.SKILL_SHOW_TYPE_COMMON_TXT_ID_LIST[v.m_SkillShowType] then
      local tempSkillCfg = HeroManager:GetSkillConfigById(skillID)
      skillCfgList[#skillCfgList + 1] = tempSkillCfg
    end
  end
  self.m_skillDataList = skillCfgList
  local datalist = self.m_skillDataList
  local dataLen = #datalist
  if dataLen == 0 then
    UILuaHelper.SetActive(self.m_skill_list, false)
    UILuaHelper.SetActive(self.m_monster_skill_info, false)
    UILuaHelper.SetActive(self.m_no_skill, true)
  else
    UILuaHelper.SetActive(self.m_skill_list, true)
    UILuaHelper.SetActive(self.m_monster_skill_info, true)
    UILuaHelper.SetActive(self.m_no_skill, false)
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
    self:ChangeSkillIndex(DefaultChooseSkillIndex)
  end
end

function Form_LevelMonsterPreview:InitSkillItem(itemTran, index)
  local itemRootTrans = itemTran.transform
  local skillIcon = itemRootTrans:Find("m_icon_frame"):GetComponent(T_Image)
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

function Form_LevelMonsterPreview:FreshSkillItem(index, skillData)
  local showItem = self.m_skillItemList[index]
  if showItem == nil then
    return
  end
  showItem.itemData = skillData
  if skillData.m_Skillicon and skillData.m_Skillicon ~= "" then
    UILuaHelper.SetAtlasSprite(showItem.skillIcon, skillData.m_Skillicon)
  end
  UILuaHelper.SetActive(showItem.nodeSelect, self.m_curSkillIndex == index)
end

function Form_LevelMonsterPreview:ChangeSkillIndex(index)
  if index ~= self.m_curSkillIndex then
    if self.m_curSkillIndex then
      local lastSkillIndex = self.m_curSkillIndex
      local lastSkillItem = self.m_skillItemList[lastSkillIndex]
      if lastSkillItem then
        UILuaHelper.SetActive(lastSkillItem.nodeSelect, false)
      end
    end
    if index then
      local curSkillItem = self.m_skillItemList[index]
      if curSkillItem then
        self.m_curSkillIndex = index
        UILuaHelper.SetActive(curSkillItem.nodeSelect, true)
      end
    end
  end
  self:FreshSkillContent()
end

function Form_LevelMonsterPreview:FreshSkillContent()
  if not self.m_skillDataList then
    return
  end
  if not self.m_curSkillIndex then
    return
  end
  local skillCfg = self.m_skillDataList[self.m_curSkillIndex]
  if not skillCfg then
    return
  end
  self.m_txt_skill_name_Text.text = skillCfg.m_mName
  self.m_txt_skill_desc_Text.text = HeroManager:GetSkillDescriptionBySkillIdAndLv(skillCfg.m_SkillID, 1)
  self:FreshShowBuffInfo(skillCfg.m_BuffDescID)
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_monster_skill_info)
end

function Form_LevelMonsterPreview:FreshShowBuffInfo(buffIDArray)
  if not buffIDArray then
    return
  end
  local buffIDLen = buffIDArray.Length
  local buffCfgList = {}
  for i = 1, buffIDLen do
    local tempBuffID = buffIDArray[i - 1]
    local buffCfg = SkillBuffIns:GetValue_ByBuffID(tempBuffID)
    if buffCfg:GetError() ~= true then
      buffCfgList[#buffCfgList + 1] = buffCfg
    end
  end
  self.m_buffCfgDataList = buffCfgList
  local datalist = self.m_buffCfgDataList
  local dataLen = #datalist
  if dataLen == 0 then
    UILuaHelper.SetActive(self.m_buff_list, false)
  else
    UILuaHelper.SetActive(self.m_buff_list, true)
    local parentTrans = self.m_buff_list.transform
    local childCount = parentTrans.childCount
    local totalFreshNum = dataLen < childCount and childCount or dataLen
    for i = 1, totalFreshNum do
      if i <= childCount and i <= dataLen then
        if self.m_buffItemList[i] == nil then
          local itemTrans = parentTrans:GetChild(i - 1)
          self:InitBuffItem(itemTrans, i)
        end
        local itemTrans = self.m_buffItemList[i].rootNode
        UILuaHelper.SetActive(itemTrans, true)
        self:FreshBuffItem(i, datalist[i])
      elseif i > childCount and i <= dataLen then
        local itemTrans = parentTrans:GetChild(0)
        local newItemTrans = GameObject.Instantiate(itemTrans, parentTrans).transform
        self:InitBuffItem(newItemTrans, i)
        UILuaHelper.SetActive(newItemTrans, true)
        self:FreshBuffItem(i, datalist[i])
      elseif i <= childCount and i > dataLen then
        local itemTrans = parentTrans:GetChild(i - 1)
        UILuaHelper.SetActive(itemTrans, false)
        if self.m_buffItemList[i] ~= nil then
          self.m_buffItemList[i].itemData = nil
        end
      end
    end
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_buff_list)
end

function Form_LevelMonsterPreview:InitBuffItem(itemTran, index)
  local itemRootTrans = itemTran.transform
  local buffIcon = itemRootTrans:Find("m_img_buff_icon"):GetComponent(T_Image)
  local txt_buff_desc = itemRootTrans:Find("m_txt_buff_desc"):GetComponent(T_TextMeshProUGUI)
  local showItem = {
    buffIcon = buffIcon,
    txt_buff_desc = txt_buff_desc,
    itemData = nil,
    rootNode = itemRootTrans
  }
  self.m_buffItemList[index] = showItem
end

function Form_LevelMonsterPreview:FreshBuffItem(index, buffData)
  local showItem = self.m_buffItemList[index]
  if showItem == nil then
    return
  end
  showItem.itemData = buffData
  UILuaHelper.SetAtlasSprite(showItem.buffIcon, "Atlas_Buff/" .. buffData.m_Icon)
  local buffName = buffData.m_mName
  local showParamStr = HeroManager:GetBuffDescribeByCfg(buffData)
  showItem.txt_buff_desc.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20092), buffName, showParamStr)
end

function Form_LevelMonsterPreview:OnMonsterIconClk(monsterIndex)
  if not self.m_curWaveNum then
    return
  end
  local waveData = self.m_waveDataList[self.m_curWaveNum]
  if not waveData then
    return
  end
  local lastMonsterIndex = waveData.curMonsterIndex
  if lastMonsterIndex then
    local lastChooseMonsterItem = self.m_monster_listInfinityGrid:GetShowItemByIndex(lastMonsterIndex)
    if lastChooseMonsterItem then
      lastChooseMonsterItem:SetChooseStatus(false)
    end
  end
  if monsterIndex then
    local curChooseMonsterItem = self.m_monster_listInfinityGrid:GetShowItemByIndex(monsterIndex)
    if curChooseMonsterItem then
      curChooseMonsterItem:SetChooseStatus(true)
    end
  end
  waveData.curMonsterIndex = monsterIndex
  self:FreshMonsterContent()
end

function Form_LevelMonsterPreview:OnSkillItemClk(skillIndex)
  self:ChangeSkillIndex(skillIndex)
end

function Form_LevelMonsterPreview:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_LevelMonsterPreview:OnBtnLastClicked()
  if not self.m_curWaveNum then
    return
  end
  if self.m_curWaveNum <= 1 then
    return
  end
  local lastWaveNum = self.m_curWaveNum - 1
  self:FreshChangeWave(lastWaveNum)
end

function Form_LevelMonsterPreview:OnBtnNextClicked()
  if not self.m_curWaveNum then
    return
  end
  if self.m_curWaveNum >= #self.m_waveDataList then
    return
  end
  local nextWaveNum = self.m_curWaveNum + 1
  self:FreshChangeWave(nextWaveNum)
end

function Form_LevelMonsterPreview:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_LevelMonsterPreview", Form_LevelMonsterPreview)
return Form_LevelMonsterPreview
