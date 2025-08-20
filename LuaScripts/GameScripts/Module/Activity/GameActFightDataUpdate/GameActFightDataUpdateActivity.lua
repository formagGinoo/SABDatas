local BaseActivity = require("Base/BaseActivity")
local GameActFightDataUpdateActivity = class("GameActFightDataUpdateActivity", BaseActivity)

function GameActFightDataUpdateActivity.getActivityType(_)
  return MTTD.ActivityType_FightDataUpdate
end

function GameActFightDataUpdateActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgFightDataUpdate
end

function GameActFightDataUpdateActivity.getStatusProto(_)
  return MTTDProto.CmdActFightDataUpdate_Status
end

function GameActFightDataUpdateActivity:OnResetSdpConfig()
end

function GameActFightDataUpdateActivity:GetUpdateDataList()
  if not self.m_stSdpConfig then
    return
  end
  local stClientCfg = self.m_stSdpConfig.stClientCfg
  if not stClientCfg then
    return
  end
  return stClientCfg.updateData
end

function GameActFightDataUpdateActivity:CheckCanStartGame(playerIds, monsterIds)
  local updateData = self:GetUpdateDataList()
  if not updateData then
    return true
  end
  local loginTime = ReportManager:GetLoginTime()
  for k, v in pairs(updateData) do
    if loginTime < v.time then
      for k1, v1 in pairs(v.vMonsterId) do
        for monsterk, monsterv in pairs(monsterIds) do
          if v1 == monsterv then
            return false
          end
        end
      end
      for k2, v2 in pairs(v.vCharacterId) do
        for playerk, playerv in pairs(playerIds) do
          if v2 == playerv then
            return false
          end
        end
      end
    end
  end
  return true
end

return GameActFightDataUpdateActivity
