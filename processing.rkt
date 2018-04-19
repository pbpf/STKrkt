#lang racket
(require "stkbase.rkt"
         "stkcmd.rkt"
         "data-provider.rkt"
         ;racket/class
         racket/gui/base
         racket/date
         )

(define main (new frame% [label "Example"][width 500][x 600][y 300]))
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
    (CloseSTK id)
    )
  (Shutdowncnn))
(define(startfunc p x)
  (define id (unbox id-box))
  (write id)
  (when id
    
    (STKCmd id (format "SetAnimation * StartAndCurrentTime ~s" (currnt-dstr)))
    (STKCmd id "Animate * Start RealTime")
    (set-box! thread-box
    (thread (lambda()
              (data-provider id  1 1 2000000))))))

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