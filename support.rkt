#lang racket
(require racket/date)
(provide currnt-dstr)
;
(define(currnt-dstr)
  (string-join (drop-right(cdr (string-split(parameterize([date-display-format 'rfc2822])
                          (date->string(seconds->date (current-seconds) #f)#t)))) 1)))