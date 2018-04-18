#lang racket
(require "stkbase.rkt"
         "stkcmd.rkt"
         ;racket/class
         racket/gui/base
         )

(define main (new frame% [label "Example"][width 500][x 600][y 300]))
(define id-box (box #f))
(define info-box (box #f))
(define (init)
  (Initcnn)
  (define-values(id fg)(OpenSTK "localhost:5001"))
  (set-box! id-box id)
  (New-scenario id "jhdz"
(define init (new button% [parent main][label "init"]))
(define start (new button% [parent main][label "start"]))
(define stop (new button% [parent main][label "stop"]))
(send main show #t)