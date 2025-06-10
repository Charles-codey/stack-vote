;; Decentralized Voting Contract
;; Enables DAO governance through proposal voting

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u200))
(define-constant err-proposal-not-found (err u201))
(define-constant err-voting-ended (err u202))
(define-constant err-already-voted (err u203))
(define-constant err-insufficient-tokens (err u204))

(define-data-var proposal-counter uint u0)
(define-data-var min-proposal-threshold uint u1000) ;; Minimum tokens to create proposal
(define-data-var voting-period uint u1440) ;; Default voting period in blocks

(define-map proposals uint {
  creator: principal,
  title: (string-ascii 100),
  description: (string-ascii 500),
  yes-votes: uint,
  no-votes: uint,
  end-block: uint,
  executed: bool
})

(define-map votes {proposal-id: uint, voter: principal} bool)
(define-map token-balances principal uint)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes {proposal-id: proposal-id, voter: voter})
)

(define-read-only (get-token-balance (user principal))
  (default-to u0 (map-get? token-balances user))
)

(define-public (set-token-balance (data {user: principal, balance: uint}))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set token-balances (get user data) (get balance data)))
  )
)

(define-public (create-proposal (data {title: (string-ascii 100), description: (string-ascii 500)}))
  (let ((user-balance (get-token-balance tx-sender))
        (proposal-id (+ (var-get proposal-counter) u1)))
    (asserts! (>= user-balance (var-get min-proposal-threshold)) err-insufficient-tokens)
    (map-set proposals proposal-id {
      creator: tx-sender,
      title: (get title data),
      description: (get description data),
      yes-votes: u0,
      no-votes: u0,
      end-block: (+ stacks-block-height (var-get voting-period)),
      executed: false
    })
    (var-set proposal-counter proposal-id)
    (ok proposal-id)
  )
)

(define-public (vote (data {proposal-id: uint, support: bool}))
  (let ((proposal-id (get proposal-id data))
        (support (get support data))
        (proposal (unwrap! (get-proposal proposal-id) err-proposal-not-found))
        (user-balance (get-token-balance tx-sender))
        (vote-key {proposal-id: proposal-id, voter: tx-sender}))
    (asserts! (< stacks-block-height (get end-block proposal)) err-voting-ended)
    (asserts! (is-none (map-get? votes vote-key)) err-already-voted)
    (map-set votes vote-key support)
    (if support
      (map-set proposals proposal-id (merge proposal {yes-votes: (+ (get yes-votes proposal) user-balance)}))
      (map-set proposals proposal-id (merge proposal {no-votes: (+ (get no-votes proposal) user-balance)}))
    )
    (ok true)
  )
)

(define-public (execute-proposal (proposal-id uint))
  (let ((proposal (unwrap! (get-proposal proposal-id) err-proposal-not-found)))
    (asserts! (>= stacks-block-height (get end-block proposal)) err-voting-ended)
    (asserts! (> (get yes-votes proposal) (get no-votes proposal)) (err u205))
    (map-set proposals proposal-id (merge proposal {executed: true}))
    (ok true)
  )
)

(define-public (set-voting-period (data {new-period: uint}))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set voting-period (get new-period data))
    (ok true)
  )
)

;; Helper function to get current proposal counter
(define-read-only (get-proposal-counter)
  (var-get proposal-counter)
)

;; Helper function to get current voting period
(define-read-only (get-voting-period)
  (var-get voting-period)
)

;; Helper function to get minimum proposal threshold
(define-read-only (get-min-proposal-threshold)
  (var-get min-proposal-threshold)
)
