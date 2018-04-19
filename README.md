## 总体框架

- matlab 向racket 发送 udp/tcp 数据 
- 链接建立？ udp组播|udp 单播
- matlab 知道总控地址
- 发送数据内容 udp：
    - ready：准备就绪
    - id name pos x y z att x y z time: 某个名字的卫星 的位置和姿态
    - stop：终止
- 回复内容 udp
    - ok：回复 start stop setcurrenttime 时间同步和检测
    - 传输时间估计
# STKrkt

- 创建场景
- 设定RealTime模式
- 接受matlab计算数据
- **向STK发送数据**
- 接受STK返回结果 特别是时间

## STK 向前矫正

- Animate

## 遇到问题

- setpostion 设置未来时刻 返回-2
- 设置时间偏移量

## 如何获得当前时间

GetAnimTime *

## 如何获取当前其他信息
GetAnimationData [TimePeriod|Mode|RefreshMode|CurrentTime|TimeStep|RefreshDelta|RealTimeX]
## 如何设置当前

SetAnimation [CurrentTime|StartTimeOnly|...]


## 地心惯性系还是地心固连坐标系