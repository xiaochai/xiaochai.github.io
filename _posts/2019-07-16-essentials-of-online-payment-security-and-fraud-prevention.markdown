---
layout: post
comments: true
title: "《风控即未来》读书笔记"
date: 2019-07-16
categories:
  - Reading
description: 风控即未来：网络支付安全和反欺诈原理（Essentials of Online Payment Security and Fraud Prevention）
image: /assets/images/sina/313bd97a332387976edc1d9bb0ebd017.jpg"
image-sm: /assets/images/sina/313bd97a332387976edc1d9bb0ebd017.jpg"
---

### 第一章 了解在线支付

#### 支付框架

主要介绍以下8种支付框架，这其中除了信用卡支付外，其它的支付方式都属于替代付款方式。商家使用替代付款方式的根本驱动因素是成本、安全/信任和便利。顾客和商家使用替代方式的理由包括成本降低、技术改进、更加安全等。书中提到的最出名的替代付款方式为PayPal。

##### 信用卡支付

信用卡是基于持卡人承诺对其购买的商品和服务付款的系统的一部分。主要信用卡品牌有美国运通（American Express）、万事达信用卡（MasterCard）、维萨（Visa）、发现卡（DiscoverCard）。

信用卡是现金支付的替代付款方式，也是电商交易的主要形式。信用卡组织会根据交易金额和所在国家地区收取不同的手续费用，如2%。

##### 直接借记和银行服务

包括自动清算所（ACH）、直接借记（direct debit）、电子支付、银行汇款等。

自动清算所是批量处理大额贷记和借记交易的电子支付网络。自动清算所服务供应商通过“主动”（Push）和“被动”（Pull）两种方式从顾客处收取款项。

主动是指顾客将钱存入到供应商网络账号中，而被动是指在需要时从消费者的银行账户中提取款项转给商家。

这种服务最大的优点是降低成本并且可以限制欺诈和身份盗取，这是出于在主动方式下不需要提供个人信息的原因。

##### 支付聚合（Payment aggregators）

支付聚合的供应商代表商家收取款项，他掌握了用户的信用卡信息以快速结账，或者在账户中沉淀资金以供下次购买。

这种方式下商家可以不开立银行账户，商家的账户属于服务商，服务商与收单行签署协议。

下属的商户与服务商签订独立合同授权服务商代收款，并确保会将款项归还给商户。

支付聚合已经被电商广泛接受，成为市场的领导者。提供者如PayPal、Amazon、Bill Me Later、Google Checkout等。

##### 信用期限提供商（Credit - term providers）

这种替代付款方式不需要用户提供信用卡等敏感信息，实际是提供商为用户提供类似信用卡的信贷服务，有拖欠付款的风险。

##### 替代现金服务供应商（Cash - alternative providers）

常见的替代现金支付方式有支票、储蓄账户、汇票等。这些在电子商务中使用率并不高，但在部分如游戏、成人商品和赌博市场上却能获得巨大利益。

##### 广告替代付款

包括两种具体的方式：交易广告（如TraiPay）和为社交应用和商家提供经过整理的报价网络（如Offerpal Media）。

##### 移动支付

手机和网络状况的改善，使得移动支付已经成为目前最流行的支付方式。

##### 账单服务

账单支付是最小众的替代服务，但B2B场景下账单服务经常被用到。

##### 国际化：跨境交易

对于跨境业务的商家来说，决定使用哪种付款方式是保持竞争力和生命力所必需的。需要重点考虑两个因素：网络和移动通信技术。

进行跨境交易公司，需要关注业务拓展地区、国家和垂直市场的特殊需求。

<hr/>

### 第二章 电子商务信用卡支付的基本概念

#### 消费者角度谈电子商务支付和欺诈

消费者更加偏好信用卡之外的其它支付方式，主要以下原因：

> <strong>一些消费者不适应使用信用卡进行网上交易；</strong><br/>

> <strong>越来越多的消费者成为有影响力的买家，任何能快速结账的工具都很酷，而某些替代付款方式可简化结账流程；</strong><br/>

> <strong>网上银行和通过网上银行账户支付引发对安全性的担忧；</strong><br/>

> <strong>通信科技如网络和手机改变了个人和商家的交流方式；</strong><br/>

> <strong>08~10年的经济下行可能促进了顾客和商家开拓替代付款方式；</strong><br/>

> <strong>当前的支付系统不能服务部分特殊的小众消费群体。</strong>

消费者对网络安全的恐惧既影响他们自己，也影响商家、金融机构和市场上其他消费者。

商家和金融机构不断增加公司定制化的解决方案。而消费者对此感到失望，因为这增加了网上交易的复杂性。

#### 从商家角度谈电子商务支付和欺诈

对商家来说，安全和欺诈问题变得越来越复杂。不只局限于结账过程中，还需要关注连接点的安全性、转账的安全性、客户敏感数据的保护。

安全和欺诈问题不仅对商家和金融机构造成直接货币损失，还导致严重的短期品牌效应缩水。

需要应对的核心挑战是：这个消费者真是本人吗？

#### 发卡行

消费者获取信用卡的银行或者信用卡联盟称之为发卡行。他们通过从消费者借款中收取利息，以及从商家每笔销售中收取部分手续费来赚钱。

#### 收单行（Acquiring Bank）

处理商家的信用卡付款，并提供调解工具。他们通过商家的每笔交易赚钱。

#### 支付服务商和网关服务

商家可以直连收单行，但由信用卡支付过程中的一些技术和业务要求，商家有时会选择第三方即支付服务商和网关服务商与收单行对接。

支付服务和网关服务提供基础架构，能将所有的参与者连接在一起，他向商家收取固定交易费或者基点赚钱，有一些还提供收单行的服务。

#### 信用卡组织

负责设立交易、服务和争议解决等流程规范，他们遵守并影响着国家银行法律，且向组织会员提供部分欺诈赔偿金。

#### 资金流

信用卡资金流的参与主体：

![参与主体]({{ site.baseurl }}/assets/images/sina/ce1337f84306c548f98451a2f2cae226.jpg)

> <strong>1. 开设账户，得到信用卡和额度；</strong><br/>

> <strong>2. 挑选要购买的商品或者服务；</strong><br/>

> <strong>3. 商家拿到信用卡信息进行检测，然后发往收单行确认账户资金是否足够，发往收单行中间可能经过支付服务商或者网关服务商；</strong><br/>

> <strong>4. 收单行通过信用卡组织确认消费者账户上资金是否充足；</strong><br/>

> <strong>5. 发卡行核准消费者的信用额度，把款项划分出来，相当于预授权。</strong><br/>

信用卡现金流的步骤如下图，后续会逐一讲解

![步骤]({{ site.baseurl }}/assets/images/sina/37865206893b330443c1aa00f594bb3f.jpg)

#### 卡授权（Card Authentication）

确认提供的信用卡号有效真实。常用的方法有MOD10 check。

#### 授权（Authorization）

检查并在授信额度内预留交易资金。授权以下几个特点：

> <strong>授权只是承诺付款，没有资金转手；</strong><br/>

> <strong>授权可以累积，每一次授权都会占用额度；</strong><br/>

> <strong>授权自动到期；</strong><br/>

> <strong>授权额度是一般预期结算额度，但某些行业允许有差别。</strong><br/>

#### 撤销授权（Authorization Reversal）

如果顾客取消购买，则联系发卡行不预留资金。需要供应商和发行方支持才可取消授权。

#### 结算（Settlement）

要求客户信用卡实际支付资金。商家通过收单行发出结算请求，收单行会向发卡行收取资金。

#### 信誉/贷记调整（Credit）

将实际支付的资金返还给消费者信用卡，即退款。注意只能通过之前支付款项的途径收回款项，不然欺诈者很容易通过信用卡购买又退还现金的方式设计骗局（套现）。

#### 拒付退单（Chargeback）

由发卡行发起的为证明消费者确实进行了交易而提供的额外材料。发卡行的这些请求可以基于顾客的服务问题或者其涉嫌欺诈。

拒付退单包括消费者宣称没有下单或者没有收到商品或者服务的欺诈拒付退单和消费都对收费有异议的顾客服务拒付退单。

在无卡支付中，商家一般需要承担欺诈的成本。他们失去商品，承担花在订单的间接成本，还要承担拒付退单的费用。所以商家会尽力处理投诉，防止承担拒付退单费。

#### 再请款（Represent）

向发卡行提供额外的资料以证明消费者确实进行了交易。

----

### 第三章 企业开展网上业务的基本支欺诈知识

#### 欺诈的分类、特点、识别与预防

##### 身份盗用

特点：大量购买，短时间最大限度地透支信用卡，高频消费，成功鉴权，地址、电话、信用卡资料没有疑点；

识别：同一地址大量购买；同一地址使用多张卡，同一地址使用多个账号；

预防：检查这多个账号，查看90天内的购买记录，检查现金支出记录和跨商家交易记录。

##### 社会工程学

特点：试图通过询问商家窃取信息，或在交流中改变信息，通过改变已有信用卡账户上的物流或者账单数据劫持订单；

识别：接到询问订单流程和数量的电话，在一次购买中使用多张卡，试图更新运输或订单信息；

预防：更改信息后通过一般防风险流程，要求重新购买；在途订单变更地址，需要电话回访确认，或者不允许改变这些信息。

##### 便利陷阱（易用性欺诈）

特点：在加油站、电子下载区等安全地点进行小规模购买，以测试窃取的卡是否可用；

识别：小规模购买中使用多张卡，第一次购买为网购，或者购买却不取货；

预防：检查变更速度及使用频率，使用黑名单。


##### 联合欺诈

特点：欺诈或者协助欺诈以获得佣金；

识别：大规模的损失，同时伴随着相关的佣金支出；

预防：严格的联合审查，同进监测费用支出欺诈。

##### 内部欺诈

特点：有组织地通过企业内部一个或多个员工泄露的信息来实施欺诈；

识别：遭遇系统性的欺诈或者欺诈团伙；不断有人在你眼皮子底下侵扰你；虽然已经采取了措施，但却被屡屡攻破；

预防：严格的员工审查，员工培训、可信度和账户余额；不允许任何一个人持有能进入公司所有地方的钥匙；不允许CSR取消他们的订单。

##### 友善欺诈

特点：举报欺诈交易，但该账户合法拥有者其实就是消费者本身；

识别：过去曾与本公司存在历史交易；强调对运输地点的确认；交货确认签字；

预防：实施严格的认证流程，要求交货确认及签字。

#### 欺诈手段

##### 窃取卡号

黑市上可以买到一长串有效的信用卡号名单。

这些是从哪里来的呢？在饭店酒吧等场所偷窥，如安装摄像头等。使用信用卡算号器等检测信用卡号。身份盗用和账户盗用。

##### 一卡一商家和一卡多商家

欺诈者获取到一张信用卡信息后，只在一个商家那使用，然后便丢弃，这种被称为一卡一商家。一卡多商家是指欺诈者多次使用一张卡行骗，但是在多家商家使用，每一家只使用一次。

特点：送货地址一般是某个废弃地点或者在交货点本人不出现，而且金额较大。

反欺诈方法：对大额交易和快递交易设置特别的规则，反向查询地址和电话，使用能显示信用卡与其它商家的交易中改变频率的检测器，采用信用卡安全措施。

##### 消费者恶意欺诈

消费者声称他们没有下单或者没有收到货。

反欺诈方法：要求交货时签字，使用消费者认证技术，使用黑名单灰名单，使用信用卡安全手段。

##### 算号器欺诈

使用算号器对大量的信用卡号进行可用性试验。

反欺诈方法：审查对方的信用卡改变频率、订单变化速度 ，进行欺诈监测。

##### 消费者满意欺诈

对于那些以产品或者服务不满意为由的客户，首先，如果价格小于50美元，应该考虑给其退款，除非事实证明你毫无过错。其次使用灰名单和黑名单策略。

##### 退货返现欺诈

作案方式：欺诈者以信用卡购买商品，又退回，并要求以现金方式退款；或者欺诈者用一张信用卡购买商品，然后让他的同伙退货并索取现金。另外也有可能是在网上购物，到实体店退货的情况。

反欺诈方法：改善退款条款，信用卡退回原卡，礼品券退回礼品券；审查信用卡改变和使用频率。

##### “变体欺诈” -- 重复犯罪

一个欺诈者多次攻击同一个商家，每一次都对数据点进行轻微的改变。有以下欺诈方法：

> <strong>快速法：短时间使用大量信用卡购买，每一次订单信息都会发生改变；</strong><br/>

> <strong>缓慢法：间隔购买商品，防止引起商家注意，并在发现之前逐渐改变信用卡、地址和电话；</strong><br/>

> <strong>多重身份：使用多张信用卡创建不同的身份，每隔30~90天进行间歇性购买。</strong><br/>

反欺诈方法：

> <strong>1. 审查你们商店的购买模式，例如一般多久购买一次商品，利用这个购买频率进行审查，并注意同一邮件、电话、地址下改变信用卡号的频率；</strong><br/>

> <strong>2. 审查同一个信用卡号下关联多少名字。除了名字，还可以使用如IP地理位置等方式；</strong><br/>

> <strong>3. 使用消费者身份认证、黑名单以及信用卡安全手段。</strong><br/>

##### 欺诈团伙

反欺诈方法：审查 信用卡改变和使用频率、地理定位、消费者身份认证、黑名单、欺诈监测、货运代理 商监测、规则引擎以及信用卡安全手段。

##### 关联欺诈--内部欺诈

> <strong>1. 欺诈者建立一个商家 的关联账户，使用窃取的信用卡进行购买，商家从窃取的信用卡中获取收入，并付欺诈者佣金。</strong><br/>

> <strong>2. 欺诈者使用窃取的信用卡购买搜索引擎或者广告网站的产品，以增加某个关联商家 的购买量。</strong><br/>

反欺诈方法：审查信用卡改变和使用频率、黑名单、欺诈监测、规则引擎、实施关联监测、对主要搜索引擎进行搜索监测。

##### 合谋欺诈--内部欺诈

指商家的某一员工与欺诈者合作，该员工可能直接帮助欺诈者作案或者偷偷将商品给欺诈者。如客服人员将反欺诈方式和流程泄露给欺诈者，或者员工拿到客户的信用卡信息或者订单信息进行欺诈等。

反欺诈方法：审查信用卡改变和使用频率、黑名单 、欺诈监测、规则引擎、除了管理人员审查员外，还要进行分层审查、确保每次交易中涉及的工作人员都能记录在案。

##### 身份盗用

身份盗用是一个重大的事件，窃取数据的方法包括数据库入侵、垃圾搜寻技术、汽车租赁机构等任何你可能填表递交的申请等。

反欺诈方法：对你的客户服务代表进行培训，使其了解此类欺诈的常见手法，采取完整的客户验证，现金交易审查，使用频率和改变频率审查，跨商家交易频率欺诈监测。

当接到声称身份被盗用的欺诈者时，不要急于下结论，有可能是一个伪装的欺诈者实施的社会工程学作案。必须保持礼貌，收集证据，建议报案等。

#### 欺诈者分类

##### 黑客

动机：证明强大的技术。

可能的行为：试图验证他是否能得到信用卡数据的能力，如果能做到，那可能会增加一个订单，获取一些数据等。

黑客户本身不会产生很大的欺诈影响 ，但其获取的数据或者发现的漏洞可能被其他人利用造成更大的影响。

##### 骇客

动机：赚钱，能窃取多少信息就窃取多少。

可能的行为：解密专家可能直接试图增加一个订单，或者导出信用卡数据来实施欺诈行为。

##### 电话飞客

电话飞客是骇客的一种，主要通过窃取已经预付的手机以及里面未使用完的通话时间。

动机：赚钱，窃取电话相关的产品和服务。

可能的行为：飞盗这一类的欺诈者主要试图窃取公司预付费的手机和电话卡。

##### 黑客主义者

动机：发布声明。

可能的行为：会试图进入你的系统，植入病毒。

他们对他们的入侵或者欺诈行为有着充分理由来解释，是欺诈者中的政治活动家，是拥有议事日程的黑客。

##### 脚本小子

动机：赚钱，寻求刺激。

可能的行为：使用免费的信用卡算号器，在你的网站上购买商品。

脚本小子是一类随意性比较大的人群，他们并不一定是欺诈者，而更多的是从偷盗中寻求刺激。所以使用欺诈审查警告他们就足以把他们吓走。

##### 犯罪团伙

动机：赚钱，为他们的公司服务。

可能的行为：欺诈团伙可能会对没有保护措施的网站的订单做手脚。

他们使用的手段有偷窥获取消费者数据，使用虚假地址或者运送货物到境外；制造与ATM极像的机器替换掉真正的机器来窃取用户的卡信息的密码；制造虚假网站收集消费者的账号和密码等。

##### 白领犯罪

动机：贪婪，赚钱。

可能的行为：给个人或者犯罪团伙提供没有做好防御措施网站的信息。

分成直接通过窃取消费数据，对公司或者其它公司发出虚假订单的主动型白领犯罪和将公司的反欺诈流程和手段泄露给外部人员的被动型白领犯罪。

#### 应对欺诈

当欺诈发生时，可能通过多个方式举报，如使用互联网欺诈报告中心的举报机制。

##### 当怀疑欺诈发生时应该怎么做

> <strong>当疑心一份订单时，尝试向客户询问更多的信息来验证交易的真实性，注意应该采用更自然的方式，以帮忙持卡人免受欺诈损失为由。</strong><br/>

> <strong>如果通过电话与客户交谈，在不挂电话的情况下打电话给收单行执行Code 10，使收单行中心知道你对某项交易存在疑问。同时向客户询问对应金融机构、多次向客户确认订单信息、给客户的订单地址发送提醒，并告知运货商需要对方签字后才能交货。</strong><br/>

> <strong>如果货物运输到某个地点被窃取，应该向所在地区的USPS的邮件调查员报告欺诈事件的发生。</strong><br/>

> <strong>案件情况严重的应向当地的警方、FBI或者特工处联系，看看是否进行调查。</strong><br/>

##### 了解法律和欺诈防范

在设计反欺诈战略时，确保与法务部门有过沟通，了解应当搜集、存储、使用哪些信息。

##### 公平信用报告法

《公平信用报告法》要求授权贷款给客户的机构，当决定不再给某客户提供贷款时，需告知客户原因。

##### 欧盟个人数据保护隐私指引

这实际上是一个立法框架，各个成员国会在此指引下制定符合本国的实际法律，所以在进行跨国业务时，需要了解对应国家的特殊隐私保护要求。

##### 消费者数据保护要求

应当与法务部门共同确认如何保护消费者数据，另外应该当格外注意这些法律法规的变更。在收集和使用消费信息时，需要了解哪些事情是不得不做的，哪些事情是不能做的。

---

### 第四章 欺诈管理的核心概念

#### 欺诈术语

方案：实体工具的集合以及它们的特点和相应的技术。

策略：具有逻辑支撑的用于支持商业活动的一组技术和信号。

工具：在欺诈方案中使用的个人申请，SaaS或者数据源。

特点：某工具将数据打造成可利信号而展现出的能力。

信号：技术本身或衍生反馈（如信用卡验证服务地址验证服务返回值=“完全匹配”）。

技术：一种通过业务流程、经验、政策和逻辑来评估、预测或认定可能结果的方法。技术可以由一个或多个工具组成 ，能产生一个或多个信号。

事件：客户互动流程直接相关的工作流程一部分，如购买、退货、变更账户等。

结果：一个欺诈管理解决策略的最后部署建议，如接受、复核、拒绝。

流程与控制：针对某种交易特点的选择过程，如对下单地址和运货地址不一致的订单进一步审查。

#### 策略设计的主要阶段

##### 事先评估

回顾订单信息，确认接受的标准，通常是自动进行。

可使用的技术或行为：黑名单、白名单、变化频率、使用频率、规则、客户认证、Visa认证、MasterCard安全编码。

##### 支付 

执行接受某个订单所要求的业务流程审查。

可使用的技术或行为：授权、地址认证服务、信用卡安全审查、高级地址认证、ACH（电子审查）、记入借方。

##### 事后评估

对通过前两阶段的订单进行更高级别的审查。

可使用的技术或行为：地理位置、欺诈可能性评分、建模、反向查询地址和电话、信用卡审查。

##### 复核

这一阶段需要人工完成，可能只是简单的抽样调查，也可能是复杂的复查序列或者手动排序。

可使用的技术或行为：回访客户、致电银行、交互审查消费记录、查询订单活动。

##### 记账

订单交易完成后的12个月内都是记账阶段，包括记录信用、结算、重新授权、退款以及对反欺诈策略进行全局性调整等。

可使用的技术或行为：结账、记录贷方、退款流程、与同事或者合作伙伴共享或更新信息、经验教训、策略调整。

#### 使用商业反欺诈解决方案

商家使用反欺诈策略和方案的主要原因有：公司正在遭受欺诈或者发现潜在的欺诈、业务不断增长带来的风险订单增加、法律要求、简化已有的反欺诈流程来减少发货时间。

使用商业反欺诈解决方案的原因主要有：内部没有对应的技术积累和对应的人才专家、产品推出时间受限、初始数据少以及广度不够、缺少内部项目的支持等。

#### 如何选择管理服务提供商（MSP）--外包

了解你需要的是什么，建立一个包含有你所经营风险需求的方案地图，了解MSP能提供什么，以及他们业务的重点等。

#### 反欺诈工具/方案分类 

##### 提供担保的反欺诈方案提供方

这类方案提供商能够在行业协会的指导下管理商家的欺诈风险，同时也愿意承担商家的损失，通常收费较高，而且对体验有负面影响。

##### 鉴权提供商

这类提供商提供的方案是用来解决身份认证和验证服务。注重身份数据的真实性而非交易本身，通常这并不足以进行有效的反欺诈保护，仍然需要结合使用其它行为指标和技术手段。

##### 欺诈评分提供商

根据多个因素提供欺诈评分方案，促使商家做出更好的风险决策。注意这类服务在各个细分行业上工作的状况差别很大，需要了解提供商擅长的细分行业。

##### 共享数据的提供商

促进、运营和帮忙风险管理中的客户与交易数据共享，并可以使用其提供的公共或者私人的数据，但这类方法有一些障碍，如法律问题等。

##### 技术提供商

开发专门的技术方案来防止欺诈。这些方案在推出时会有一些障碍包括消费者的接受度、入侵性、不便性等。

他们提供的方案包括安全标记、生物验证、电话验证、设备认证、地理定位、证明和图片展示等。

##### 数据分析提供商

提供与分析数据相关的工具和服务，以便创造出定制模型与混合方案。这些定制模型包括回归模型、神经网络、贝叶斯模型等。

方案组成包括数据分析、设计以及实际建立与运行一个模型等。

##### 数据治理提供商

提供对数据进行清算、标准化以及可行性检测的工具和服务。这些服务有助于提升存储准确数据的能力、提高速度审查的能力以及减少重复率、提高运营效率。

##### 运营提供商

这类提供商提供公司所需要的核心系统，用于建立反欺诈方案和战略。他们也提供一些工具、方案以及服务，意在简化、自动化和提高人工经营流程。

<hr/>

### 第五章 反欺诈技术：身份验证

#### 地址验证服务

指使用用户已经提交的账单地址来验证与发卡行文件上的地址是否相符。

地址验证服务并不具有很高的可靠性，多种因素会导致用户填写的地址与发卡行不同，但地址验证服务可以在退款争议中起到积极的作用。

#### 高级地址验证服务

除了验证地址外，还验证电话号码、邮箱地址。此服务只有少部分供应商支持。如果验证数据匹配全部符合时，商家的风险会大降低

#### 年龄确认

在下单时确认顾客的年龄，这在对于成人、酒精、游戏等需要合规审核时广泛应用。

可以使用驾照回传或者通过在网站上弹出选择年龄的方式来实现，或者更严格让顾客提供社保号码。

#### 信用卡安全方案

使用安全码来验证顾客是否真实持卡，一般印在背面，美国运通在正面。如果验证不通过，建议直接拒绝。

#### 扣款验证

通过电话联系发卡行或者信用卡组织以验证持卡人信息真实性。发卡行或者信用卡组织会联系客户获取信息确认真实性然后回复给商家。此流程需要人工进行，而且耗时较长。

#### 支票验证服务

指检查支票以及支票填写人的过程来避免支票风险。如确认账户是否开通，之前是否有空头支票的情况，以及支票填写人是否有前科。

#### 客户认证

顾客在发卡行注册之后会得到一个密码、个人识别编号或者装置。当顾客在网上进行购物时会被要求出示这些密码或者装置来验证。

#### 信用检查

通过对比顾客提供的信息与客户信用报告上的信息来核实身份，如验证电话号码、姓名和信用卡信息等。

#### 存款检查

通过向顾客账号里存款，或者扣除信用卡小笔随机钱数（0.01~5美元之间），让顾客回传对应的账单或者金额数值来评估顾客。

#### 邮件验证

搜索公共数据资源（如社交网络）来对电邮持有者年龄等人口统计信息进行验证的工具。

#### 货运代理检查

使用货运代理检查可以检测送货地址的有效性，从而评估订单的有效性和欺诈的可能性。

#### 身份认证

电子身份认证主要是收集、验证和确认最终用户提供的一些身份信息。

#### 额外验证

通过询问顾客过去信用报告或者公共记录的问题来确认顾客，通常是5到10个多选题。

#### 反查：电话号码和地址

通过第三方资源来交叉检验顾客提供的地址和家庭座机电话信息，来证实公共记录与顾客提供的地址和电话等信息是否一致。

#### 邮件回复

在顾客购物时向他们的邮箱发送密码或者发送需要激活的链接，以此来对顾客进行校验。

#### 电话号码验证

确认顾客或者终端使用者电话类型的过程。这个技术通过反查电话号码，来确定号码是由哪里提供的，并且哪种类型的电话与此号相关。

#### 电话验证

按照顾客提供的电话回拨，以便确认这个号码是否在使用以及使用这个号码的人与下单人是否是同一个人。

<hr/>

### 第六章 反欺诈技术：担保支付

#### 电子商务保险

使用电子商务保险来拟补他们在欺诈订单上的损失，但保费可能非常高，需要建立复杂的反欺诈技术，使用一些影响体验的验证等。

#### 管理服务

管理服务在支付系统中插入一个中间人，客户的资金先进入此，在到货或者服务完成后进入商家账户。起到保护双方，防止欺诈的目的。

#### 担保支付 

担保支付通过一个第三方供应商向商家提供一个对欺诈交易付款的担保，其中包括电子商务保险、第三方反欺诈服务和顾客核查服务的供应商。

担保支付服务供应商会评估这些订单信息，然后回复商家接受还是拒绝。

----

### 第七章 反欺诈技术：欺诈评级

商家在进行非面对面交易时用欺诈评级以确定风险水平。商家通过评级来考虑是拒绝还是观察或是接受这一订单，同时也可以据此决定还要对这一订单做哪些信息验证。

使用外包公司的服务可以在数据广度，数据模型优化，拦截成攻率等多个方面更有优势。

----

### 第八章 反欺诈技术：操作管理 （企业）

#### 授权（实时）

授权是商家向客户的发卡行发起的一个申请 ，以确定客户的信用卡是否有足够的资金来支付货款。

#### 银行识别码检查

信用卡号前6位是银行识别码，可以用来确定 消费者的发卡行。通过识别可以用来验证交易，例如信用卡号显示在一个国家，而消费者付款地址却在另外一个国家，那么就需要更多的审核了。

#### 案例管理

案例管理，CSR接口是风险管理团队用来回顾高危订单，执行调查和事后处理。

#### 退款再请款

退款再请款是商家与发卡行就退款问题提出质疑，该操作允许商家提交证据证明退款是不合理的。

#### 黑名单、灰名单、白名单

名单是用来根据消费者历史交易信息，决定是否进行交易。如有多次退款记录可进入黑名单，对于存在满意度问题的消费者可进入灰名单，而最佳的消费者进入白名单。

#### 内部规则 

内部规则建立在电子商务引擎、支付处理系统或者订单管理系统中，用于拦截潜在的危险订单。例如限额、数量规则、常见名规则等等。

#### 人工审核

商家用自己的员工来进行手动审核订单，来决定其是否存在欺诈交易。

#### 规则引擎

规则引擎是一个中间应用，能够将规则创立和排序应用于反欺诈管理中。它允许商家制定用于评估订单的规则。

规则引擎可以很灵活地增改，并嵌入到交易的各个环节，附带上灰度、预投放、数据统计等功能，可以快速实现某一些规则的快速上下线而不产生重大事故。

规则引擎的类型:

<strong>1. 规则引擎允许商家增加规则，当一个订单通过引擎时，规则会逐一进行评估。这种规则很容易设立和维护。但由于失败之后后续的规则不再执行，所以审核一个失败订单时，只能知道第一个不符合的是什么，不得不额外再花时间评估其它指标来判断后续订单的操作。</strong><br/>

<strong>2. 规则引擎允许你增加规则 ，并且对规则进行赋值，使得某些规则的权重更大，揭示更大的风险。即加权得分，根据最终的得分来确认是否通过。</strong><br/>

<strong>3. 规则引擎允许在业务流程中加入规则，即运行的结果或者规则都是基于某一特定规则之上的。</strong><br/>

<strong>4. 此类引擎是一个全方位的引擎，商家在一个应用中可以设立和管理全部的反欺诈工具。这使得商家可以编写和编辑规则，并且能快速有效集成新的反欺诈工具。有了些类引擎，就可以在后台直接提高 防风险能力，从而不需要去前台系统处更改编码。</strong><br/>


#### 使用频率

检查使用频率的目的就是基于消费者相关的交易来寻找可疑的行为。基于在之前预设的时间段中，某一数据项的使用频率。在一段时间内使用的次数越多，接受订单的风险就越大。监测的数据项可以是信用卡号、订单量、商品各类和数量等。

#### 变化频率

监控变化的频率的目的是基于新旧交易的数据项变化来查找可疑的行为，某一特定时间新交易的数据项的变化率越高，订单风险就越大。监测的数据项可以是地址，电话号码，信用卡号等。

----

### 第九章 反欺诈技术：分析方法

神经网络、贝叶斯模型、回归分析、监控、历史分析 、并行对比法等。

----

### 第十章 反欺诈技术：数据质量

#### 收货地址验证

收货地址验证是检查消费者收货地址来确保地址是可以送达的。

#### MOD10检验

MDO10检查是对银行卡号进行检查的算法，确认其号码是正确的。

#### 商家黑名单检查

商家黑名单检查是用来检查对方是否在联邦政府禁止通商的名单上。其目的是自动地与美国政府提供的黑名单进行比照，确保名单上的实体没有在美国运营、销售货物或服务。


----

### 第十一章 反欺诈技术：技术工具

#### 生物识别技术

如指纹、视网膜、声纹、DNA等。

#### 地理定位

地理定位服务提供了有关消费者在世界范围内的位置、线速度、所在地域的详细信息。定位与账单地址相符的订单会更有信心；如果不符可以进一步进行审核。

可以通过多个渠道取得定位信息，如电话区号、邮政编码、IP地址查询、GEO全球定位系统、信用卡银行识别码等。

#### 电子签名

商家通过一些与电脑关联的设备，如电子笔、平板等从消费者那里获取签名。在后期可以被当成合法交易的证据。


#### 设备识别

利用一部分使用者访问你网页时被动收集的数据来标记设备。设备识别可以用来跟踪同一个账号的设备数量，以及使用设备黑名单防止下次再遇到欺诈的设备。

#### 代理检测

代理检测网页服务可以对匿名的IP地址进行瞬时检测。如果是代理IP可以进一步进行审查。

#### 安全令牌

安全令牌使用设备产生一串唯一的编号对终端客户进行验证。在进行交易时需要输入设备上的数字验证身份。

#### 芯片卡

芯片卡中嵌有可以被专门设备读取的芯片，用于验证卡的真实性。

#### 手机定位

手机定位不同于地理定位，他是靠运营商基站接入点来确认位置的，一般需要用户的同意才行。拿到定位后与用户的订单、手机号等所在区域对比，查看是否符合。

----

### 第十二章 反欺诈技术：数据共享

有专门的数据共享办公署，从众多的公司收集、汇总信息，从而通过扩大数据范围来改善欺诈检测质量的组织。它提供的服务将商家的信息汇总到一起，从而使它能够在商家自己遭遇欺诈之前就创建并识别出潜在的欺诈信息，并给所有的商家以及时的提醒。

但也遇到了许多障碍，如隐私问题、对数据泄漏的担忧、以及商家对数据的信任等问题。



















