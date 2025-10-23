local LoungeFavorability = class()

function LoungeFavorability:ctor(maxFavorability)
  self._maxFavorability = maxFavorability
  self._score = {}
  self.total = 0
end

function LoungeFavorability:addFavorability(part, score, times, max)
  if not part then
    print("Invalid touch type" .. part)
  end
  local info = self._score[part]
  info = info or {times = 0, score = 0}
  local scoreToAdd = 0
  if (times == 0 or times > info.times) and (max == 0 or max > info.score) then
    info.times = info.times + 1
    if max == 0 then
      scoreToAdd = score
    else
      scoreToAdd = math.min(score, max - info.score)
    end
    scoreToAdd = math.min(score, self._maxFavorability - self.total)
    info.score = info.score + scoreToAdd
    self.total = self.total + scoreToAdd
    self._score[part] = info
  end
  return scoreToAdd
end

function LoungeFavorability:updateTotal()
  self.total = 0
  for part, info in pairs(self._score) do
    self.total = self.total + info.score
  end
end

function LoungeFavorability:clear()
  self._score = {}
  self.total = 0
end

function LoungeFavorability:saveState(heroId)
  local data = ""
  if self._score then
    for k, v in pairs(self._score) do
      data = data .. k .. "," .. v.times .. "," .. v.score .. ";"
    end
  end
  LocalDataManager:SetStringSimple("LoungeFavorability_" .. heroId, data)
end

function LoungeFavorability:loadState(heroId)
  self.total = 0
  self._score = {}
  local data = LocalDataManager:GetStringSimple("LoungeFavorability_" .. heroId, "")
  if data == "" then
    return
  end
  local parts = string.split(data, ";")
  for _, partData in ipairs(parts) do
    local items = string.split(partData, ",")
    if #items == 3 then
      local part = items[1]
      local times = tonumber(items[2]) or 0
      local score = tonumber(items[3]) or 0
      self._score[part] = {times = times, score = score}
    end
  end
  self:updateTotal()
end

function LoungeFavorability:getPercent()
  return self.total / self._maxFavorability
end

return LoungeFavorability
