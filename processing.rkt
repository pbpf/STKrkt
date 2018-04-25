#lang racket
(require "stkbase.rkt"
         "stkcmd.rkt"
         "data-provider.rkt"
         "matlab.rkt"
         "callback.rkt"
         ;racket/class
         racket/gui/base
         racket/date
         )
(define udp1 (udp-open-socket	"127.0.0.1" 8866));仅仅决定协议栈
(define udp2 (udp-open-socket	"127.0.0.1" 7766));仅仅决定协议栈
(udp-bind! udp1 	 "127.0.0.1" 8866);真正绑定
(udp-bind! udp2 	 "127.0.0.1" 7766);真正绑定
(udp-connect! udp1 	"127.0.0.1" 6519)
(udp-connect! udp2 	"127.0.0.1" 4519)
(define main (new myframe% [label "Example"][width 500][x 600][y 300][rudp udp2][wudp udp1][readcallback datacallback]))
(define id-box (box #f))
(define info-box (box #f))
(define thread-box (box #f))
(define sat1-file "")
(define sat2-file "")
(define(configure-sat name file)
  #f)
(define (initfunc p x)
  (Initcnn)
  (define-values(id fg)(OpenSTK "localhost:5001"))
  (set-box! id-box id)
  (New-scenario id "jhdz")
  (New-Satellite id "sat1")
  ;(New-Satellite id "sat2")
  
  (STKCmd id "SetTimePeriod * \"Now\" \"+1 day\"")
  (STKCmd id "SetEpoch * \"Now\"")
  ;(STKCms id "Realtime */Satellite/sat2 SetLookAhead DeadReckon 600 60 300")
  ;(configure-sat "sat1" sat1-file)
  ;(configure-sat "sat1" sat1-file)
  (STKCmd id "Realtime  */Satellite/sat1 SetProp")
  (STKCmd id "Realtime  */Satellite/sat1 SetHistory 100 5")
  (STKCmd id "Realtime */Satellite/sat1 SetLookAhead J4Perturbation 4 0.1 3")
  (STKCmd id "Animate * SetValues \"Now\" 0.1 0.1 \"+1 day\"")
  )
(define(stopfunc p x)
  (define id (unbox id-box))
  (when id
    (kill-thread  (unbox thread-box))
    (send main stopall)
    (CloseSTK id)
    )
  (Shutdowncnn))
(define(startfunc p x)
  (define id (unbox id-box))
  (write id)
  (when id
    (send main set-id! id)
    (STKCmd id (format "SetAnimation * StartAndCurrentTime ~s" (currnt-dstr)))
    (STKCmd id "Animate * Start RealTime")
    (send main startread)
    (send main startsend)
    ))

(define(connectfunc p x)
  (Initcnn)
  (define-values(id fg)(OpenSTK "localhost:5001"))
  (set-box! id-box id))
    
(define init (new button% [parent main][label "Initialize"][callback initfunc]))
(define connect (new button% [parent main][label "recnn"][callback connectfunc]))
(define config (new button% [parent main][label "config"]));configure-sat
(define start (new button% [parent main][label "start"][callback startfunc]))
(define stop (new button% [parent main][label "End Cnn"][callback stopfunc]))
(send main show #t)