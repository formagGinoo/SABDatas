local Form_PersonalRaidBattleInfo = class("Form_PersonalRaidBattleInfo", require("UI/UIFrames/Form_PersonalRaidBattleInfoUI"))

function Form_PersonalRaidBattleInfo:SetInitParam(param)
end

function Form_PersonalRaidBattleInfo:AfterInit()
  self.super.AfterInit(self)
end

function Form_PersonalRaidBattleInfo:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  local stTargetId = self.m_csui.m_param.stTargetId
  local from_rank = self.m_csui.m_param.from_rank
  if stTargetId.iUid == RoleManager:GetUID() and not from_rank then
    self:RefreshSelfData()
  else
    PersonalRaidManager:ReqSoloRaidPlayerRecordCS(self.m_csui.m_param.stTargetId)
  end
end

function Form_PersonalRaidBattleInfo:OnInactive()
  self:RemoveAllEventListeners()
end

function Form_PersonalRaidBattleInfo:AddEventListeners()
  self:addEventListener("eGameEvent_SoloRaid_GetPlayerRecord", handler(self, self.RefreshOtherData))
end

function Form_PersonalRaidBattleInfo:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PersonalRaidBattleInfo:RefreshSelfData()
  local raidData = PersonalRaidManager:GetPersonalRaidData()
  local mRecord
  if raidData and raidData.stCurRaid then
    local iRaidId = raidData.stCurRaid.iRaidId
    for i, v in pairs(raidData.mRecord) do
      if v.iRaidId == iRaidId then
        mRecord = v
        break
      end
    end
  end
  local recordList = {}
  if mRecord then
    local vRecordHero = mRecord.vRecordHero
    local vDamage = mRecord.vDamage or {}
    for i, v in ipairs(vRecordHero) do
      recordList[i] = {}
      recordList[i].heroList = v
      recordList[i].damage = vDamage[i] or 0
    end
  end
  self.m_common_empty:SetActive(#recordList == 0)
  self:refreshLoopScroll(recordList)
  self.m_scroll_view:GetComponent("ScrollRect").normalizedPosition = CS.UnityEngine.Vector2(0, 1)
end

function Form_PersonalRaidBattleInfo:RefreshOtherData(data)
  local mRecord = data.stRecord
  local recordList = {}
  if mRecord then
    local vRecordHero = mRecord.vRecordHero
    local vDamage = mRecord.vDamage or {}
    for i, v in ipairs(vRecordHero) do
      recordList[i] = {}
      recordList[i].heroList = v
      recordList[i].damage = vDamage[i] or 0
    end
  end
  self.m_common_empty:SetActive(#recordList == 0)
  self:refreshLoopScroll(recordList)
  self.m_scroll_view:GetComponent("ScrollRect").normalizedPosition = CS.UnityEngine.Vector2(0, 1)
end

function Form_PersonalRaidBattleInfo:refreshLoopScroll(recordList)
  local data = recordList
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_scroll_view
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if click_name == "m_btn_copyteam" then
          StackPopup:Push(UIDefines.ID_FORM_PERSONALRAIDCOPYTEAM, {
            otherPlayerTeam = cell_data.heroList
          })
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data)
  end
end

function Form_PersonalRaidBattleInfo:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local heroList = cell_data.heroList
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  for i = 1, 5 do
    local common_hero_small = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_common_hero_small" .. i)
    local commonHeroItem = self:createHeroIcon(common_hero_small)
    if heroList[i] then
      commonHeroItem:SetHeroData(heroList[i])
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_common_hero_small" .. i, heroList[i])
  end
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_power", cell_data.damage)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "txt_team_num", index)
end

function Form_PersonalRaidBattleInfo:IsOpenGuassianBlur()
  return true
end

function Form_PersonalRaidBattleInfo:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_PersonalRaidBattleInfo", Form_PersonalRaidBattleInfo)
return Form_PersonalRaidBattleInfo
