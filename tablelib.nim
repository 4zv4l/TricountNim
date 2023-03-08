import std/tables

proc largest*[K,V](t: Table[K,V]): tuple[key: K, val: V] =
  for (k, v) in t.pairs:
    if v > result.val: result = (k, v)

proc smallest*[K,V](t: Table[K,V]): tuple[key: K, val: V] =
  for (k, v) in t.pairs:
    if v < result.val: result = (k, v)
