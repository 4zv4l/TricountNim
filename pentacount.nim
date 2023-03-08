import std/[rdstdin,tables,strutils,strformat]
import regex
import tablelib

type Account = Table[string, float]

proc loadAccount(filename: string, reg: Regex): tuple[give, get: Account] =
  ## read `filename` line by line using the given regex to get:
  ## - `src` is who pay
  ## - `money` is the amount
  ## - `dst` is who get (can be multiple people)
  # load the Accounts of each person
  var
    file = open(filename)
    res: RegexMatch
  result = (initTable[string, float](), initTable[string, float]())
  for line in file.lines:
    if match(line, reg, res):
      var
        src = res.group("src", line)[0]
        money = parseFloat(res.group("money", line)[0])
        dst = res.group("dst", line)
      result.give[src] = result.give.getOrDefault(src) + money
      for ppl in dst:
        result.get[ppl] = result.get.getOrDefault(ppl) + money/float(dst.len)

proc getSold(give, get: Account): Account =
  ## calcul the sold of each person (get - give)
  result = initTable[string, float]()
  for ppl in get.keys:
    result[ppl] = get.getOrDefault(ppl) - give.getOrDefault(ppl)

proc showSold(sold: Account) =
  ## show the the amount each person should give or get
  echo "~ Here are the totals to send/give ~"
  echo ""
  for (ppl, money) in sold.pairs:
    if money >= 0:
      echo fmt"{ppl:<6} should give: {money:>7.2f}"
    else:
      echo fmt"{ppl:<6} should get : {abs(money):>7.2f}"
  echo ""
  echo "~ Here is the repartition ~"
  echo ""

proc processSold(sold: var Account) =
  ## process and show who should pay who and how much
  while smallest(sold).val != 0:
    var
      higher = largest(sold)
      lower = smallest(sold)
      amount = min(-lower.val, higher.val)
    echo fmt"{higher.key:<6} should pay {lower.key:<6}: {amount:>6.2f}"
    sold[lower.key] += amount
    sold[higher.key] -= amount
    if sold[lower.key] == 0:
      sold.del(lower.key)

when isMainModule:
  var
    filename = readLineFromStdin("filename: ")
    reg = re"^(?:[^\s]+)\s(?P<src>.+)\spaye\s(?P<money>\d+(\.\d+)?)\sa\s(?:(?P<dst>[^\s]+)\s?)+$"
    (give, get) = loadAccount(filename, reg)
    sold = getSold(give, get)
  showSold(sold)
  processSold(sold)
