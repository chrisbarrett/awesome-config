local utils = {}

function utils.pips_of_pct(number, disabled)
  if number == 0 or disabled then return "off "
  elseif number <= 25 then return "·";
  elseif number <= 50 then return "··";
  elseif number <= 75 then return "···";
  else return "····";
  end
end

return utils
