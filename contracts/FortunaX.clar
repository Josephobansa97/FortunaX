;; LuckyDraw: A decentralized lottery contract

;; -----------------------------
;; Configuration & Data Variables
;; -----------------------------

(define-constant ticket-price u1000) ;; Price per ticket in micro-STX
;; Admin is set manually for this example.
(define-data-var admin principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Tracks the number of tickets sold.
(define-data-var ticket-counter uint u0)

;; Stores the block height when the lottery ends.
(define-data-var lottery-end-block uint u0)

;; Flag to indicate if the lottery is active.
(define-data-var lottery-active bool true)

;; Stores the winning ticket ID after drawing.
(define-data-var winner-ticket uint u0)

;; Map to store each ticket: key is ticket id, value is the owner principal.
(define-map tickets 
  {ticket-id: uint}
  {owner: principal})

;; -----------------------------
;; Public Functions
;; -----------------------------

;; Admin starts a new lottery by setting the end block.
(define-public (start-lottery (end-block uint))
  (if (is-eq tx-sender (var-get admin))
      (begin
        (var-set lottery-end-block end-block)
        (var-set lottery-active true)
        (var-set ticket-counter u0)
        (ok "Lottery started"))
      (err "Unauthorized")))

;; Users buy a ticket by sending the fixed ticket price.
(define-public (buy-ticket)
  (if (not (var-get lottery-active))
      (err u0)
      (begin
        (try! (stx-transfer? ticket-price tx-sender (as-contract tx-sender)))
        (let ((current (var-get ticket-counter)))
          (map-set tickets 
            {ticket-id: current}
            {owner: tx-sender})
          (var-set ticket-counter (+ current u1))
          (ok current)))))

;; Admin draws a winner after the lottery end block has passed.
(define-public (draw-winner)
  (if (< burn-block-height (var-get lottery-end-block))
      (err u1)
      (if (not (var-get lottery-active))
          (err u2)
          (let ((total (var-get ticket-counter)))
            (if (is-eq total u0)
                (err u3)
                (let (
                      ;; Use block height modulo total tickets for pseudo randomness.
                      (random-index (mod burn-block-height total))
                     )
                  (var-set winner-ticket random-index)
                  (var-set lottery-active false)
                  (ok random-index)))))))

;; Winner claims the prize (all funds held in the contract).
(define-public (claim-prize)
  (let ((ticket-data (map-get? tickets {ticket-id: (var-get winner-ticket)})))
    (match ticket-data
      td (if (is-eq tx-sender (get owner td))
          (let ((prize-amount ticket-price)) ;; For demonstration, prize equals one ticket price.
            (try! (stx-transfer? prize-amount (as-contract tx-sender) tx-sender))
            (ok prize-amount))
          (err u4))
      (err u5))))

;; -----------------------------
;; Read-only Functions
;; -----------------------------

;; Get current lottery status and details.
(define-read-only (get-lottery-status)
  (ok {
    ticket-counter: (var-get ticket-counter),
    lottery-active: (var-get lottery-active),
    lottery-end-block: (var-get lottery-end-block),
    winner-ticket: (var-get winner-ticket)
  }))

;; Get owner of a specific ticket.
(define-read-only (get-ticket-owner (ticket-id uint))
  (match (map-get? tickets {ticket-id: ticket-id})
    t (ok (get owner t))
    (err "Ticket not found")))
