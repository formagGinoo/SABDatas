local Form_activity104_Dialogueclue = class("Form_activity104_Dialogueclue", require("UI/UIFrames/Form_activity104_DialogueclueUI"))

function Form_activity104_Dialogueclue:SetInitParam(param)
end

function Form_activity104_Dialogueclue:AfterInit()
  self.super.AfterInit(self)
end

function Form_activity104_Dialogueclue:OnActive()
  self.super.OnActive(self)
  self:addEventListener("eGameEvent_Act4ClueGetAward", handler(self, self.FreshUI))
  self:FreshUI()
end

function Form_activity104_Dialogueclue:FreshUI()
  local cfg = self.m_csui.m_param.act4ClueCfg
  local act_id = self.m_csui.m_param.iActID
  local bIsGet = false
  local data = HeroActivityManager:GetHeroActData(act_id)
  if data then
    local server_data = data.server_data
    if server_data then
      local vAwardedClue = server_data.vAwardedClue
      for _, v in ipairs(vAwardedClue) do
        if v == cfg.m_ID then
          bIsGet = true
          break
        end
      end
    end
  end
  local is_unlock = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelHavePass(cfg.m_PreLevel)
  if not bIsGet and is_unlock then
    HeroActivityManager:ReqAct4ClueGetAwardCS(act_id, cfg.m_ID)
  end
  self.m_txt_title_Text.text = cfg.m_mClueTitle
  self.m_txt_desc_Text.text = cfg.m_mClueText
  local commonRewardList = utils.changeCSArrayToLuaTable(cfg.m_Reward)
  local data = commonRewardList[1]
  if data then
    local reward_item = self:createCommonItem(self.m_itemreward)
    local processData = ResourceUtil:GetProcessRewardData({
      iID = data[1],
      iNum = data[2]
    })
    reward_item:SetItemInfo(processData)
    reward_item:SetItemHaveGetActive(bIsGet)
    self.m_itemreward:SetActive(true)
  else
    self.m_itemreward:SetActive(false)
  end
end

function Form_activity104_Dialogueclue:OnInactive()
  self.super.OnInactive(self)
  self:clearEventListener()
end

function Form_activity104_Dialogueclue:OnDestroy()
  self.super.OnDestroy(self)
  self:clearEventListener()
end

function Form_activity104_Dialogueclue:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_activity104_Dialogueclue:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_activity104_Dialogueclue", Form_activity104_Dialogueclue)
return Form_activity104_Dialogueclue
