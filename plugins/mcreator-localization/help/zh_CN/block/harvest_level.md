这是打破这个块所需要的最小工具收集等级(即挖掘等级)。

* 0为木制
* 1为石质
* 2为铁质
* 3为钻石
* 4为下界合金

只有工具收集等级高于你指定的挖掘等级才能打破你的方块。
你也可以通过将工具收集等级设置为4或更高

方块在破碎时掉落物品的条件为:

`IF BLOCK HARVEST LEVEL <= TOOL HARVEST LEVEL` (如果方块挖掘等级小于等于工具收集等级)
