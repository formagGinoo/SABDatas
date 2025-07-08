local Form_GachaWishPop = class("Form_GachaWishPop", require("UI/UIFrames/Form_GachaWishPopUI"))

function Form_GachaWishPop:SetInitParam(param)
end

function Form_GachaWishPop:AfterInit()
  self.super.AfterInit(self)
end

function Form_GachaWishPop:OnActive()
  self.super.OnActive(self)
  local params = self.m_csui.m_param
  self.m_wishListID = params.wishListID
  self.m_gachaID = params.gachaID
  self.m_wishPoolID = 0
  self.m_wishData = {}
  if not self.m_wishListID or self.m_wishListID == 0 then
    self:OnBtnCloseClicked()
    return
  end
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_GachaWishPop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_GachaWishPop:AddEventListeners()
  self:addEventListener("eGameEvent_SaveGachaWishHeroList", handler(self, self.RefreshUI))
end

function Form_GachaWishPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GachaWishPop:RefreshUI()
  self:refreshLoopScroll()
  local cfg = GachaManager:GetGachaWishListConfig(self.m_wishListID)
  self.m_txt_tips_Text.text = tostring(cfg.m_mTips)
end

function Form_GachaWishPop:GenerateData()
  local data = {}
  local cfg = GachaManager:GetGachaWishListConfig(self.m_wishListID)
  self.m_wishPoolID = cfg.m_PoolID
  local listNum = utils.changeCSArrayToLuaTable(cfg.m_ListNum)
  for i, v in ipairs(listNum) do
    local campCfg = HeroManager:GetCharacterCampCfgByCamp(v[1])
    data[i] = {}
    local wishHeroList = {}
    if campCfg then
      local serverList = GachaManager:GetWishHeroIdByCamp(self.m_gachaID, v[1])
      if serverList then
        for m, n in pairs(serverList) do
          wishHeroList[#wishHeroList + 1] = GachaManager:GenerateGachaWishHeroData({n})
        end
      end
      data[i].campImg = campCfg.m_WishListIcon
      data[i].campName = campCfg.m_mCampName
      data[i].camp = v[1]
      data[i].heroNum = v[2]
      data[i].wishHeroList = wishHeroList
    end
  end
  return data
end

function Form_GachaWishPop:refreshLoopScroll()
  self.m_wishData = self:GenerateData()
  local data = self.m_wishData
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_scroll_view
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewCell(index, cell_object, cell_data)
        if self["ItemInitTimer" .. index] then
          TimeService:KillTimer(self["ItemInitTimer" .. index])
          self["ItemInitTimer" .. index] = nil
        end
        UILuaHelper.SetActive(cell_object, false)
        self["ItemInitTimer" .. index] = TimeService:SetTimer(index * 0.1, 1, function()
          UILuaHelper.SetActive(cell_object, true)
          UILuaHelper.PlayAnimationByName(cell_object, "GachaWishPop_item_in")
          if self["ItemInitTimer" .. index] then
            TimeService:KillTimer(self["ItemInitTimer" .. index])
            self["ItemInitTimer" .. index] = nil
          end
        end)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if click_name == "btn_add_hero" then
          StackPopup:Push(UIDefines.ID_FORM_GACHAWISHSECONDWINDOW, {
            wishListID = self.m_wishListID,
            camp = cell_data.camp,
            heroNum = cell_data.heroNum,
            gachaId = self.m_gachaID
          })
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data, true)
  end
end

function Form_GachaWishPop:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local wishHeroList = cell_data.wishHeroList
  for i = 1, 5 do
    local common_hero_middle = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_common_hero_middle" .. i)
    local commonHeroItem = self:createHeroIcon(common_hero_middle)
    if wishHeroList[i] then
      commonHeroItem:SetHeroData(wishHeroList[i].serverData, nil, nil, true, true)
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_common_hero_middle" .. i, wishHeroList[i])
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_hero_bg" .. i, i <= cell_data.heroNum)
  end
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_team", cell_data.campName)
  local c_img_camp = UIUtil.findImage(transform, "offset/img_campbg/m_campicon")
  CS.UI.UILuaHelper.SetAtlasSprite(c_img_camp, cell_data.campImg, nil, nil, true)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "txt_team_num", "0" .. index)
  local data = self:GenerateData()
  local lineObj = transform:Find("offset/img_bg").gameObject
  UILuaHelper.SetActive(lineObj, true)
  if data and index == #data then
    UILuaHelper.SetActive(lineObj, false)
  end
end

function Form_GachaWishPop:OnBtnCloseClicked()
  local num = 0
  for i, v in pairs(self.m_wishData) do
    num = num + (v.heroNum or 0)
  end
  local wishList = GachaManager:GetGachaWishListById(self.m_gachaID)
  local cfg = GachaManager:GetGachaWishListConfig(self.m_wishListID)
  if num > table.getn(wishList) then
    utils.popUpDirectionsUI({
      tipsID = tonumber(cfg.m_ConfirmCommonTips),
      func1 = function()
        self:CloseForm()
      end
    })
  else
    self:CloseForm()
  end
end

function Form_GachaWishPop:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_GachaWishPop:IsOpenGuassianBlur()
  return true
end

function Form_GachaWishPop:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GachaWishPop", Form_GachaWishPop)
return Form_GachaWishPop
