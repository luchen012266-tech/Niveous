import 'models.dart';

/// 界面演示数据。正式版由 data/work_repository.dart 从 AO3 抓取后替换。
const List<Work> kDemoWorks = <Work>[
  Work(
    id: 1,
    title: 'the quiet hours between storms',
    titleZh: '风暴之间的静谧时刻',
    author: 'softstatic',
    fandom: 'Good Omens (TV)',
    rating: 'T',
    warnings: <String>['No Archive Warnings Apply'],
    relationship: 'Aziraphale/Crowley',
    tags: <String>['Slow Burn', 'Hurt/Comfort', 'Bookshop', 'Rain', 'Soft'],
    tagsZh: <String>['慢热', '治愈', '书店', '雨夜', '温柔'],
    summary:
        'A rainy Tuesday, a shop that should have closed an hour ago, and two beings who have been avoiding the same conversation for six thousand years.',
    summaryZh: '一个下雨的星期二，一家早该关门的书店，和两个把同一场对话回避了六千年的存在。',
    words: '12,480',
    year: 2025,
    kudos: '4,812',
    hits: '38,201',
    complete: true,
    zhReady: true,
    chapters: <Chapter>[
      Chapter('Chapter 1 · Rain, and what it washes in', <Para>[
        Para(
          'The rain started somewhere around four in the afternoon and did not stop, and by seven the street outside was a long smear of reflected light, shop signs dissolving into gold, then red, then nothing.',
          '雨是下午四点左右下起来的，之后就没停过。到七点，外面的街道已经变成一道被拉长的倒影，店铺招牌先融成金色，再融成红色，最后什么也不剩。',
        ),
        Para(
          'Aziraphale had turned the sign to CLOSED an hour ago. He had not locked the door. This was, he told himself, an oversight of the ordinary kind.',
          '阿兹拉斐尔一小时前就把牌子翻到了“已打烊”。他没有锁门。他告诉自己，这是那种再普通不过的疏忽。',
        ),
        Para(
          "The angel was halfway through reshelving the same three books for the fourth time when the bell above the door gave its small, apologetic ring.",
          '当天使把同样三本书第四次放回书架放到一半时，门上方的铃铛响起了那种小小的、带着歉意的声音。',
        ),
        Para(
          '"We\'re closed," he said, without turning around, because he already knew the footsteps, and had known them for longer than there had been a word for it.',
          '“打烊了，”他头也不回地说，因为他已经认出了那脚步，而且认得它的时间，比这世上出现“认得”这个词还要早。',
        ),
        Para(
          '"I know," said Crowley. He stood dripping on the mat with the patient air of someone who had decided, on the walk over, to be difficult in a very quiet way. "I brought you something. It\'s wet now. It was a book."',
          '“我知道，”克罗利说。他滴着水站在门垫上，带着一种耐心的神气，仿佛在走过来的路上已经决定好，要用一种非常安静的方式来找麻烦。“我给你带了点东西。现在湿了。本来是本书。”',
        ),
        Para(
          'Aziraphale turned. The book was a wreck, warped and swollen, its spine a small disaster. He looked at it for a long moment, and then at the demon holding it, and something in his chest did the thing it had been doing for six thousand years, which he had never once permitted himself to name.',
          '阿兹拉斐尔转过身。那本书惨不忍睹，翘曲、膨胀，书脊是一场小小的灾难。他看了它很久，然后看向拿着它的恶魔，胸口有什么东西又做了那件它做了六千年的事——而他一次也没允许自己为它命名。',
        ),
        Para(
          '"You could have miracled it dry," he said, and his voice came out far too gentle for the accusation he had intended.',
          '“你本可以用奇迹把它弄干的。”他说，声音里却带着远远过多的温柔，完全不像他原本想要的指责。',
        ),
        Para(
          '"Yeah," said Crowley, and did not offer the rest of it. That he had wanted to arrive with something damaged and human and real, that he had wanted to be let in on a night when nobody would see.',
          '“是啊，”克罗利说，没有把剩下的说出口——他想要带着一样受损的、属于人类的、真实的东西到来；他想在一个没人会看见的夜里被放进去。',
        ),
        Para(
          'Aziraphale stepped aside. It was not much. It was, in the accounting of Heaven, nothing at all. But the door closed behind them both, and the rain went on outside, politely, waiting.',
          '阿兹拉斐尔让开一步。这不算什么。在天堂的账本上，这压根什么都不算。但门在他们身后合上了，而外面的雨很有礼貌地继续下着，像是在等待。',
        ),
      ]),
      Chapter('Chapter 2 · Cocoa, and other small heresies', <Para>[
        Para(
          'The cocoa was, objectively, terrible. Crowley drank all of it.',
          '那杯可可，客观地说，很难喝。克罗利全喝完了。',
        ),
        Para(
          'They sat in the back room where the lamplight pooled yellow on the good rug, and neither of them said the thing that had been sitting between them on the sofa for the better part of an hour.',
          '他们坐在后间，灯光在那块好地毯上汇成一片黄色，两个人谁也没说出那件在沙发上横在他们之间将近一小时的事。',
        ),
        Para(
          '"Tomorrow," Crowley said finally, "it\'ll be sunny. You\'ll open at nine. Somebody will want a first edition they can\'t afford."',
          '“明天，”克罗利终于说，“会放晴。你九点开门。会有人想要一本他买不起的初版书。”',
        ),
        Para(
          '"And you\'ll come by at four," said the angel, "and complain about the tea."',
          '“然后你四点过来，”天使说，“抱怨茶难喝。”',
        ),
        Para(
          '"And complain about the tea," Crowley agreed, and the rain kept on, and neither of them moved for a long time.',
          '“然后抱怨茶难喝，”克罗利赞同道。雨继续下着，两个人很久都没有动。',
        ),
      ]),
    ],
  ),
  Work(
    id: 2,
    title: '第七次梦见海',
    titleZh: '第七次梦见海',
    author: '海盐柠檬',
    fandom: '魔道祖师 - 墨香铜臭',
    rating: 'M',
    warnings: <String>['Creator Chose Not To Use Archive Warnings'],
    relationship: '蓝忘机/魏无羡',
    tags: <String>['现代AU', '重逢', '双向暗恋', 'HE'],
    tagsZh: <String>['现代AU', '重逢', '双向暗恋', 'HE'],
    summary: '他们在七年里错过了六次，第七次，海把两个人一起推上了岸。',
    summaryZh: '他们在七年里错过了六次，第七次，海把两个人一起推上了岸。',
    words: '86,190',
    year: 2024,
    kudos: '21,940',
    hits: '203,551',
    complete: true,
    zhReady: true,
    chapters: <Chapter>[
      Chapter('第一章 · 潮声', <Para>[
        Para(
          '海是在凌晨三点涨起来的。',
          '海是在凌晨三点涨起来的。',
        ),
        Para(
          'He stood at the window at three in the morning, and the sea came up in the glass like a memory that had been waiting for permission.',
          '凌晨三点，他站在落地窗前，海在玻璃里涨起来，像一个等了很久才获准出现的记忆。',
        ),
        Para(
          'Somewhere behind him, the other side of the bed was still empty, still holding its shape out of habit.',
          '身后的某个地方，床的另一侧仍然空着，仍然由于习惯而保持着它的形状。',
        ),
        Para(
          '他想，七年也不算很长。人一生里能用来等一个人的时间，本来就没有多少。',
          '他想，七年也不算很长。人一生里能用来等一个人的时间，本来就没有多少。',
        ),
      ]),
    ],
  ),
  Work(
    id: 3,
    title: "The Cartographer's Apprentice",
    titleZh: '制图师的学徒',
    author: 'inkandparchment',
    fandom: 'Harry Potter - J. K. Rowling',
    rating: 'G',
    warnings: <String>['No Archive Warnings Apply'],
    relationship: 'Gen',
    tags: <String>['Post-Canon', 'Worldbuilding', 'Maps', 'Found Family'],
    tagsZh: <String>['战后', '世界观拓展', '地图', '家人般的羁绊'],
    summary:
        'After the war, Dennis Creevey maps every room of a house that no longer exists, and the house, politely, maps him back.',
    summaryZh: '战后，丹尼斯·克里维为一栋已不存在的房子绘制每一个房间的地图，而那栋房子，礼貌地，也为他绘制了一张。',
    words: '5,204',
    year: 2023,
    kudos: '1,102',
    hits: '9,833',
    complete: true,
    zhReady: false,
    chapters: <Chapter>[
      Chapter('Chapter 1', <Para>[
        Para(
          'The first map was wrong in every measurable way, which is how he knew it was honest.',
          '第一张地图在每一个可测量的方面都是错的，正因如此他知道它是诚实的。',
        ),
        Para(
          'He kept it anyway, pinned above the desk, and started the second one on a Sunday.',
          '他还是把它留下了，钉在书桌上方，然后在某个周日开始画第二张。',
        ),
        Para(
          'By the fourth map the corridors had begun to remember themselves, and he stopped needing to measure.',
          '到第四张地图的时候，走廊已经开始记起自己，他不再需要测量了。',
        ),
      ]),
    ],
  ),
  Work(
    id: 4,
    title: 'salt and static',
    titleZh: '盐与静电',
    author: 'radio_silent',
    fandom: 'Star Trek: Alternate Original Series',
    rating: 'E',
    warnings: <String>['Graphic Depictions Of Violence'],
    relationship: 'James T. Kirk/Spock',
    tags: <String>['Angst', 'Injury Recovery', 'Pining', 'Touch-Starved'],
    tagsZh: <String>['虐', '伤员恢复', '暗恋', '渴望触碰'],
    summary:
        'Spock does not leave the medbay for eleven days. Nobody thinks to ask him why, and he would not have answered.',
    summaryZh: '斯波克十一天没有离开医疗舱。没人想到要问他为什么，而他也不会回答。',
    words: '31,760',
    year: 2025,
    kudos: '8,430',
    hits: '77,120',
    complete: false,
    zhReady: false,
    chapters: <Chapter>[
      Chapter('Chapter 1', <Para>[
        Para(
          'Eleven days. He counted them the way he counted everything: precisely, and without any comfort in the counting.',
          '十一天。他像清点一切那样清点它们：精确，且从中得不到任何安慰。',
        ),
        Para(
          'The doctor told him to go home on the third day. He did not go home on the third day.',
          '第三天，医生让他回家。第三天他没有回家。',
        ),
      ]),
    ],
  ),
  Work(
    id: 5,
    title: '夜市、雨和一只不肯回家的猫',
    titleZh: '夜市、雨和一只不肯回家的猫',
    author: '阿柚',
    fandom: '原神 | Genshin Impact',
    rating: 'T',
    warnings: <String>['No Archive Warnings Apply'],
    relationship: '钟离/达达利亚',
    tags: <String>['都市', '日常', '轻喜剧'],
    tagsZh: <String>['都市', '日常', '轻喜剧'],
    summary: '璃月港的夜市收摊时下起了雨，而某人坚持说这只猫是“我们的”。',
    summaryZh: '璃月港的夜市收摊时下起了雨，而某人坚持说这只猫是“我们的”。',
    words: '2,940',
    year: 2026,
    kudos: '3,281',
    hits: '40,772',
    complete: true,
    zhReady: true,
    chapters: <Chapter>[
      Chapter('第一章', <Para>[
        Para('雨落下来的时候，最后一盏灯笼正好被摘下来。', '雨落下来的时候，最后一盏灯笼正好被摘下来。'),
        Para('猫蹲在摊位下面，一动不动，像一枚不肯被收走的硬币。', '猫蹲在摊位下面，一动不动，像一枚不肯被收走的硬币。'),
        Para('“它跟着我们走了三条街了。”达达利亚说。', '“它跟着我们走了三条街了。”达达利亚说。'),
      ]),
    ],
  ),
];
