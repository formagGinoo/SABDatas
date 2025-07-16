local BaseActivity = require("Base/BaseActivity")
local VoucherControlActivity = class("VoucherControlActivity", BaseActivity)

function VoucherControlActivity.getActivityType(_)
  return MTTD.ActivityType_VoucherControl
end

function VoucherControlActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgVoucherControl
end

function VoucherControlActivity.getStatusProto(_)
  return MTTDProto.CmdActVoucherControl_Status
end

function VoucherControlActivity:OnResetSdpConfig()
  self.m_control = false
  self.m_commonUrl = ""
  self.m_curUrl = ""
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg then
    local configList = self.m_stSdpConfig.stCommonCfg.vControlCfg
    self.m_commonUrl = self.m_stSdpConfig.stCommonCfg.sJumpLink
    local channel = ChannelManager:GetContext()
    local loginCountry = RoleManager:GetLoginRoleCountry()
    for _, v in pairs(configList) do
      if tostring(channel.Channel) == tostring(v.sChannel) then
        local areaList = v.vCountry or {}
        if 0 < #areaList then
          for m, area in ipairs(areaList) do
            if string.lower(tostring(loginCountry)) == string.lower(tostring(area)) then
              self.m_curUrl = v.sSpecialJumpLink
              self.m_control = true
              return
            end
          end
        else
          self.m_curUrl = v.sSpecialJumpLink
          self.m_control = true
          return
        end
      end
    end
  end
end

function VoucherControlActivity:checkCondition()
  if not VoucherControlActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
end

function VoucherControlActivity:GetIsControl()
  return self.m_control or false
end

function VoucherControlActivity:GetJumpUrl()
  if self.m_curUrl and self.m_curUrl ~= "" then
    return self.m_curUrl
  end
  return self.m_commonUrl
end

return VoucherControlActivity
