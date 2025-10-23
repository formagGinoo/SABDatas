local Form_BossEquipmentPartReward = class("Form_BossEquipmentPartReward", require("UI/UIFrames/Form_BossEquipmentPartRewardUI"))
local PartDunLevelIns = ConfigManager:GetConfigInsByName("DunLevel")

function Form_BossEquipmentPartReward:SetInitParam(param)
end

function Form_BossEquipmentPartReward:AfterInit()
  self.super.AfterInit(self)
  self.m_equipmentHelper = LevelManager:GetLevelEquipmentHelper()
  self.m_luaStageRewardInfinityGrid = self:CreateInfinityGrid(self.m_scrollView_InfinityGrid, "EquipmentBoss/UIPartRewardItem")
end

function Form_BossEquipmentPartReward:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
end

function Form_BossEquipmentPartReward:OnInactive()
  self.super.OnInactive(self)
end

function Form_BossEquipmentPartReward:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BossEquipmentPartReward:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_levelID = tParam.levelID
    self.m_levelSubType = tParam.levelSubType
    self.m_showData = {}
    local effectList = StargazingManager:GetCastleStarTechEffectByType(StargazingManager.CastleStarEffectType.Boss)
    local randomPoolId = 0
    local starTechEffect = {}
    if 0 < table.getn(effectList) then
      for i, v in ipairs(effectList) do
        for m, n in ipairs(v) do
          if n[1] == self.m_levelSubType then
            randomPoolId = n[2]
          end
        end
      end
      starTechEffect = ItemManager:GetItemRandomPoolContentById(randomPoolId)
    end
    local chapterInfoAll = PartDunLevelIns:GetAll()
    for i, v in pairs(chapterInfoAll) do
      if v.m_LevelSubType == self.m_levelSubType then
        local levelData = {}
        levelData.cfg = v
        levelData.starTechEffect = starTechEffect
        table.insert(self.m_showData, levelData)
      end
    end
  end
end

function Form_BossEquipmentPartReward:FreshUI()
  if not self.m_luaStageRewardInfinityGrid then
    return
  end
  self.m_luaStageRewardInfinityGrid:ShowItemList(self.m_showData)
  self.m_luaStageRewardInfinityGrid:LocateTo()
end

function Form_BossEquipmentPartReward:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_BossEquipmentPartReward", Form_BossEquipmentPartReward)
return Form_BossEquipmentPartReward
