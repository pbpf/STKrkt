#lang racket
(require "stkcmd.rkt"
         "stkbase.rkt"
         "support.rkt"
         racket/date)
(provide datacallback)
;
(define(datacallback id  bs)
 ; (write bs)
  (match-define (list x0 y0 r0)(map string->number (string-split (bytes->string/utf-8 bs))))
  (STKCmd id (format "SetPosition */Satellite/sat1 ECI ~s ~a ~a ~a" (currnt-dstr)
                       x0 y0 0 ))
  ;(displayln (list x0 y0 r0))
  )