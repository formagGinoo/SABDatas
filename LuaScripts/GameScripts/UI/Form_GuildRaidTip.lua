local Form_GuildRaidTip = class("Form_GuildRaidTip", require("UI/UIFrames/Form_GuildRaidTipUI"))

function Form_GuildRaidTip:SetInitParam(param)
end

function Form_GuildRaidTip:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
end

function Form_GuildRaidTip:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_effectId = tParam.effectId
  self.m_monsterTypeCfg = tParam.cfg
  self.m_click_transform = tParam.click_transform
  self.m_parentRootTransform = tParam.rootTrans
  self.m_pivot = {x = 0, y = 0.5}
  self:RefreshUI()
  self:InitSetPos()
end

function Form_GuildRaidTip:OnInactive()
  self.super.OnInactive(self)
end

function Form_GuildRaidTip:RefreshUI()
  if self.m_effectId then
    local effectCfg = HuntingRaidManager:GetBattleGlobalEffectCfgById(self.m_effectId)
    if effectCfg then
      UILuaHelper.SetAtlasSprite(self.m_head_icon_Image, effectCfg.m_Icon)
      self.m_txt_skill_name_Text.text = effectCfg.m_mName
      local des = HeroManager:GetSkillDescribeByParam(effectCfg.m_mDesc, effectCfg.m_Param)
      self.m_txt_skill_describe_Text.text = tostring(des)
      UILuaHelper.ForceRebuildLayoutImmediate(self.m_content_node)
    end
  end
  if self.m_monsterTypeCfg then
    UILuaHelper.SetAtlasSprite(self.m_head_icon_Image, self.m_monsterTypeCfg.m_Icon)
    self.m_txt_skill_name_Text.text = self.m_monsterTypeCfg.m_mName
    self.m_txt_skill_describe_Text.text = tostring(self.m_monsterTypeCfg.m_mDesc)
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_content_node)
  end
end

function Form_GuildRaidTip:InitSetPos()
  local pos = self.m_parentRootTransform:InverseTransformPoint(self.m_click_transform.position)
  local content_w, content_h = UILuaHelper.GetUISize(self.m_content_node)
  local width, height = UILuaHelper.GetUISize(self.m_rootTrans)
  local d_pos = Vector3.New(pos.x, pos.y, pos.z)
  if self.m_pivot then
    if self.m_pivot.x ~= 0.5 then
      local clickRectW, _ = UILuaHelper.GetUISize(self.m_click_transform)
      if self.m_pivot.x == 0 then
        d_pos.x = pos.x - content_w / 2 - clickRectW / 2
      elseif self.m_pivot.x == 1 then
        d_pos.x = pos.x + content_w / 2 + clickRectW / 2
      end
    end
    if self.m_pivot.y ~= 0.5 then
      local _, clickRectH = UILuaHelper.GetUISize(self.m_click_transform)
      if self.m_pivot.y == 0 then
        d_pos.y = pos.y - content_h / 2 - clickRectH / 2
      elseif self.m_pivot.y == 1 then
        d_pos.y = pos.y + content_h / 2 + clickRectH / 2
      end
    end
  end
  d_pos.y = math.max(math.min(d_pos.y, height * 0.5 - content_h * 0.5), -height * 0.5)
  d_pos.x = math.max(math.min(d_pos.x, width * 0.5 - content_w * 0.5), -width * 0.5 + content_w * 0.5)
  UILuaHelper.SetLocalPosition(self.m_content_node, d_pos.x, d_pos.y, 0)
end

function Form_GuildRaidTip:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_GuildRaidTip:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GuildRaidTip", Form_GuildRaidTip)
return Form_GuildRaidTip
