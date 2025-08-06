local UIItemBase = require("UI/Item/HeroActivity/UIHeroActTaskItem")
local UI105TaskItem = class("UI105TaskItem", UIItemBase)

function UI105TaskItem:OnInit()
  UI105TaskItem.super.OnInit(self)
  self.sAniIn = "luoleilai_achievement_task_in"
  self.sAniOut = "luoleilai_achievement_task_to"
end

return UI105TaskItem
