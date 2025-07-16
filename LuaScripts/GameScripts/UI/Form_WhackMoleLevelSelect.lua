local Form_WhackMoleLevelSelect = class("Form_WhackMoleLevelSelect", require("UI/UIFrames/Form_WhackMoleLevelSelectUI"))

function Form_WhackMoleLevelSelect:AfterInit()
  self.super.AfterInit(self)
  self.m_levelListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_level_list_InfinityGrid, "WhackMole/UIWhackMoleLevelItem")
  self:OnFirstRefreshData()
end

function Form_WhackMoleLevelSelect:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.main_id = tParam.main_id
  self.sub_id = tParam.sub_id
  self:OnRefreshLevelData()
  self:OnRefreshLevelList()
  self.m_levelCfg = nil
  self.m_miniGameServerData = nil
  self.levelDataList = {}
end

function Form_WhackMoleLevelSelect:OnInactive()
  self.super.OnInactive(self)
end

function Form_WhackMoleLevelSelect:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_WhackMoleLevelSelect:OnFirstRefreshData()
  self.m_levelConfigs = {}
  local format_configs = {}
  local tempAllCfg = HeroActivityManager:GetActWhackMoleInfoCfgByID(1036)
  for _, config in pairs(tempAllCfg) do
    local m_levelID = config.m_LevelID
    if m_levelID and 0 < m_levelID then
      format_configs[m_levelID] = config
    end
  end
  self.m_levelConfigs = format_configs
end

function Form_WhackMoleLevelSelect:OnRefreshLevelData()
  self.levelDataList = {}
  self.m_format_configs = {}
  self.m_miniGameServerData = HeroActivityManager:GetHeroActData(self.main_id).server_data.stMiniGame
  for i, v in pairs(self.m_levelConfigs) do
    local levelState = 0
    local tempData = {}
    local open_time = TimeUtil:TimeStringToTimeSec2(v.m_OpenTime) or 0
    local is_corved, t1 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
      id = self.act_id,
      m_MemoryID = v.m_MemoryID
    })
    if is_corved then
      open_time = t1
    end
    local cur_time = TimeUtil:GetServerTimeS()
    local is_in_time = open_time <= cur_time
    if is_in_time then
      local is_done = self.m_miniGameServerData.mGameStat[v.m_LevelID] == 1
      if is_done then
        levelState = 0
      else
        local is_pre_done = false
        if not v.m_PreLevel or 0 >= v.m_PreLevel then
          is_pre_done = true
          levelState = 1
        else
          local config = HeroActivityManager:GetActWhackMoleInfoCfgByIDAndLevelId(self.sub_id, v.m_PreLevel)
          if config:GetError() then
            log.error("获取打地鼠前置关卡数据配置失败，参数无效！", self.sub_id, v.m_PreLevel)
            return
          end
          is_pre_done = self.m_miniGameServerData.mGameStat[config.m_LevelID] == 1
          if is_pre_done then
            levelState = 1
          else
            levelState = 2
          end
        end
      end
      tempData = {levelCfg = v, levelState = levelState}
      table.insert(self.levelDataList, tempData)
    end
  end
end

function Form_WhackMoleLevelSelect:OnRefreshLevelList()
  self.m_levelListInfinityGrid:ShowItemList(self.levelDataList)
end

function Form_WhackMoleLevelSelect:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_WhackMoleLevelSelect:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_WhackMoleLevelSelect", Form_WhackMoleLevelSelect)
return Form_WhackMoleLevelSelect
