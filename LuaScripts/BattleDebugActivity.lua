local BaseActivity = require("Base/BaseActivity")
local BattleDebugActivity = class("BattleDebugActivity", BaseActivity)

function BattleDebugActivity.getActivityType(_)
  return MTTD.ActivityType_FightDebug
end

function BattleDebugActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgFightDebug
end

function BattleDebugActivity.getStatusProto(_)
  return MTTDProto.CmdActFightDebug_Status
end

function BattleDebugActivity:OnResetSdpConfig(sdfConfig)
  local cfg = sdfConfig.stCommonCfg
  if cfg then
    CS.BattleGameManager.LogUploadUrl = cfg.sReportLink
    CS.BattleGameManager.LogUploadUser = cfg.sReportAccount
    CS.BattleGameManager.LogUploadPwd = cfg.sReportPassword
    CS.BattleGameManager.LogUploadType = cfg.iFightDebugType
  else
    CS.BattleGameManager.LogUploadUrl = nil
    CS.BattleGameManager.LogUploadUser = nil
    CS.BattleGameManager.LogUploadPwd = nil
    CS.BattleGameManager.LogUploadType = 0
  end
end

function BattleDebugActivity:dispose()
  self.super.dispose(self)
end

return BattleDebugActivity
