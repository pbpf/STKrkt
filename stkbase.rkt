#lang racket
(require ffi/unsafe
         ffi/unsafe/define)
 
(define-ffi-definer defineag (ffi-lib "AgConnect"))

; AgConInit call (AgConInit-base)
(defineag Initbase (_fun -> _int ) #:c-id AgConInit)
;AgConInit with config file call (AgConInit-config *config-file-path*)
(defineag Initconfig (_fun _string -> _int ) #:c-id AgConInit)

(defineag OpenSTKbase (_fun [id : (_ptr o _bytes)]  [unused : _pointer = #f]  _string -> (fg : _int )->(values id fg))#:c-id AgConOpenSTK)

;AgConCloseSTK
(defineag closestk(_fun (_ptr i _bytes)-> _int )#:c-id AgConCloseSTK)

;set time out

(defineag settimeout(_fun _bytes _int -> _void) #:c-id AgConSetTimeout)


(define AgCRMHAHdrIdLen 6)
(define AgCRMHAHdrTypeLen 15)

(define-cstruct _agtconreturninfo
  ([hdrType (_array _byte (+ AgCRMHAHdrTypeLen 1))]
   [transId (_array _byte (+ AgCRMHAHdrIdLen 1))]
   [numEntries _int]
   [returnList _pointer]))
#|
(define-cstruct _agtconreturninfo
  ([hdrType (_array _byte (+ AgCRMHAHdrTypeLen 1))]
   [transId (_array _byte (+ AgCRMHAHdrIdLen 1))]
   [numEntries _int]
   [returnList (_pointer (_pointer _byte))]))
|#

(defineag STKCmd (_fun  _bytes _string [info : (_ptr o _agtconreturninfo)] -> (fg : _int)-> (values info fg)) #:c-id AgConProcessSTKCmd)

;sync
(defineag sync (_fun _bytes [info : (_ptr o _agtconreturninfo)] -> (fg : _int) -> (values info fg)) #:c-id AgConGetAsync )
; 释放返回info
(defineag cleanrt(_fun (_ptr i _agtconreturninfo) -> _void) #:c-id AgConCleanupReturnInfo)

;AgConSetProperties
(define AgCConVerboseOn #x0001)
(define AgCConAckOn #x0002)
(define AgCConErrorOn #x0004)
(define AgCConAsyncOn #x0008)
(defineag setprop (_fun _bytes _uint -> _void)#:c-id AgConSetProperties)

;AgConShutdownConnect

(defineag shutdown (_fun -> _void) #:c-id AgConShutdownConnect)

;AgUtMsgReserveBuffer
(defineag setmsgbuffer (_fun _int -> _void) #:c-id AgUtMsgReserveBuffer)
                       #|
typedef struct AgTConReturnInfo
{
char hdrType[AgCRMHAHdrTypeLen+1];
char transId[AgCRMHAHdrIdLen+1];
int numEntries;
char **returnList;
} AgTConReturnInfo;|#
;test ok
;(Initconfig #f)
;(define-values(id fg)(OpenSTKbase "localhost:5001"))
;(thread (lambda()(define-values (s r)(STKCmd id  "Load / VDF \"D:\\Program Files\\AGI\\STK 11\\Data\\ExampleScenarios\\Intro_STK_Aircraft_Systems.vdf\""))(displayln r)))