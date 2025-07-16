local M = {}
local COMBAT_COEFFICIENT = 10000.0

function M:CalculateCombatsByAttrList(attrList)
  local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
  local fvAllNum = 0
  local fvAllPercent = 0
  for i, attr in pairs(attrList) do
    local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(attr[1])
    local paramNum = math.floor(attr[2]) or 0
    if propertyIndexCfg.m_Type == 2 then
      paramNum = paramNum / COMBAT_COEFFICIENT
    end
    local fvNum = propertyIndexCfg.m_FVNum / COMBAT_COEFFICIENT
    local fvPercent = propertyIndexCfg.m_FVPercent / COMBAT_COEFFICIENT
    fvAllNum = fvAllNum + paramNum * fvNum
    fvAllPercent = fvAllPercent + paramNum * fvPercent
  end
  local totalPower = fvAllNum * (1 + fvAllPercent)
  return totalPower
end

function M:CalculateCombatsByAttrMap(attrMap)
  local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
  local allPropertyIndexCfg = PropertyIndexIns:GetAll()
  local fvAllNum = 0
  local fvAllPercent = 0
  for _, propertyIndexCfg in pairs(allPropertyIndexCfg) do
    if propertyIndexCfg.m_Compute == 1 then
      local paramStr = propertyIndexCfg.m_ENName
      local tempNum = attrMap[paramStr]
      if tempNum == nil then
        log.warn("CombatUtil CalculateCombatsByAttrMap Param is nil paramStr: " .. paramStr)
      end
      local paramNum = math.floor(tempNum or 0)
      if propertyIndexCfg.m_Type == 2 then
        paramNum = paramNum / COMBAT_COEFFICIENT
      end
      local fvNum = propertyIndexCfg.m_FVNum / COMBAT_COEFFICIENT
      local fvPercent = propertyIndexCfg.m_FVPercent / COMBAT_COEFFICIENT
      fvAllNum = fvAllNum + paramNum * fvNum
      fvAllPercent = fvAllPercent + paramNum * fvPercent
    end
  end
  local totalPower = fvAllNum * (1 + fvAllPercent)
  return totalPower
end

function M:CalculateEquipCombatsByLv(equipId, equipLv, campAdd)
  local _, attrList = EquipManager:GetEquipBaseAttr(equipId, equipLv, campAdd)
  local totalPower = CombatUtil:CalculateCombatsByAttrList(attrList)
  return math.floor(totalPower)
end

function M:CalculateSkillCombats(skillTab)
  local skillPotency = 0
  local skillPotencyParam = 0
  for skillId, level in pairs(skillTab) do
    local tempSkillCfg = HeroManager:GetSkillConfigById(skillId)
    if tempSkillCfg then
      local m_SkillPotencyParam = utils.changeCSArrayToLuaTable(tempSkillCfg.m_SkillPotencyParam)
      if m_SkillPotencyParam[level] then
        skillPotencyParam = skillPotencyParam + m_SkillPotencyParam[level]
      end
      local m_SkillPotency = utils.changeCSArrayToLuaTable(tempSkillCfg.m_SkillPotency)
      if m_SkillPotency[level] then
        skillPotency = skillPotency + m_SkillPotency[level]
      end
    end
  end
  return skillPotency, skillPotencyParam / 10000
end

return M
