local strfind = string.find
local operator = {}

function operator.call(fn, ...)
  return fn(...)
end

function operator.index(t, k)
  return t[k]
end

function operator.eq(a, b)
  return a == b
end

function operator.neq(a, b)
  return a ~= b
end

function operator.lt(a, b)
  return a < b
end

function operator.le(a, b)
  return a <= b
end

function operator.gt(a, b)
  return b < a
end

function operator.ge(a, b)
  return b <= a
end

function operator.len(a)
  return #a
end

function operator.add(a, b)
  return a + b
end

function operator.sub(a, b)
  return a - b
end

function operator.mul(a, b)
  return a * b
end

function operator.div(a, b)
  return a / b
end

function operator.pow(a, b)
  return a ^ b
end

function operator.mod(a, b)
  return a % b
end

function operator.concat(a, b)
  return a .. b
end

function operator.unm(a)
  return -a
end

function operator.lnot(a)
  return not a
end

function operator.land(a, b)
  return a and b
end

function operator.lor(a, b)
  return a or b
end

function operator.table(...)
  return {
    ...
  }
end

function operator.match(a, b)
  return strfind(a, b) ~= nil
end

function operator.nop(...)
  return ...
end

operator.optable = {
  ["+"] = operator.add,
  ["-"] = operator.sub,
  ["*"] = operator.mul,
  ["/"] = operator.div,
  ["%"] = operator.mod,
  ["^"] = operator.pow,
  [".."] = operator.concat,
  ["()"] = operator.call,
  ["[]"] = operator.index,
  ["<"] = operator.lt,
  ["<="] = operator.le,
  [">"] = operator.gt,
  [">="] = operator.ge,
  ["=="] = operator.eq,
  ["~="] = operator.neq,
  ["#"] = operator.len,
  ["and"] = operator.land,
  ["or"] = operator.lor,
  ["{}"] = operator.table,
  ["~"] = operator.match,
  [""] = operator.nop
}
return operator
