import std/[rdstdin,tables,strutils,strformat]
import regex
import tablelib

var
  filename = readLineFromStdin("filename: ")
  file = open(filename)
  get  = initTable[string, float]() 
  give = initTable[string, float]()
  sold = initTable[string, float]()
  reg  = re"^(?:[^\s]+) (?P<src>.+) paye (?P<money>\d+(\.\d+)?) a (?:(?P<dst>[^\s]+)\s?)+$"
  res: RegexMatch

# load give/get money
for line in file.lines:
  if match(line, reg, res):
    var
      src = res.group("src", line)[0]
      money = parseFloat(res.group("money", line)[0])
      dst = res.group("dst", line)
    give[src] = give.getOrDefault(src) + money
    for ppl in dst:
      get[ppl] = get.getOrDefault(ppl) + money/float(dst.len)

# difference between give/get to get the sold
for ppl in get.keys:
  sold[ppl] = get.getOrDefault(ppl) - give.getOrDefault(ppl)

echo "~ Here are the totals to send/give ~"
echo ""
for (ppl, money) in sold.pairs:
  if money >= 0:
    echo fmt"{ppl:<6} should give {money:>7.2f}"
  else:
    echo fmt"{ppl:<6} should get {abs(money):>6.2f}"
echo ""
echo "~ Here is the repartition ~"
echo ""

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
