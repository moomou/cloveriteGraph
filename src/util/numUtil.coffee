exports.isNum = (n) ->
  return !isNaN(parseFloat(n)) && isFinite(n)
