local Form_CastleStatueLevelupTips = class("Form_CastleStatueLevelupTips", require("UI/UIFrames/Form_CastleStatueLevelupTipsUI"))

function Form_CastleStatueLevelupTips:SetInitParam(param)
end

function Form_CastleStatueLevelupTips:AfterInit()
  self.super.AfterInit(self)
end

function Form_CastleStatueLevelupTips:OnActive()
  self.super.OnActive(self)
  local pre_level = self.m_csui.m_param.pre_level
  local cur_level = self.m_csui.m_param.cur_level
  self.m_txt_lv_num_Text.text = self.m_csui.m_param.cur_level
  local all_statue_configs = StatueShowroomManager:GetAllCastleStatueCfg()
  local unlock_list = {}
  for i, v in ipairs(all_statue_configs) do
    if pre_level < v.m_StatueLevel and cur_level >= v.m_StatueLevel then
      table.insert(unlock_list, v)
    end
  end
  self.unlock_list = unlock_list
  GlobalManagerIns:TriggerWwiseBGMState(25)
end

function Form_CastleStatueLevelupTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_CastleStatueLevelupTips:OnBtnCloseClicked()
  self:CloseForm()
  if #self.unlock_list > 0 then
    TimeService:SetTimer(0.05, 1, function()
      StackPopup:Push(UIDefines.ID_FORM_CASTLESTATUEUNLOCKTIPS, self.unlock_list)
    end)
  end
end

function Form_CastleStatueLevelupTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CastleStatueLevelupTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CastleStatueLevelupTips", Form_CastleStatueLevelupTips)
return Form_CastleStatueLevelupTips
