;; inventory-verification.clar
;; This contract validates the existence of goods in the supply chain

(define-data-var last-inventory-id uint u0)

(define-map inventories
  { inventory-id: uint }
  {
    owner: principal,
    product-id: (string-utf8 50),
    quantity: uint,
    location: (string-utf8 100),
    timestamp: uint,
    verified: bool
  }
)

(define-public (register-inventory (product-id (string-utf8 50)) (quantity uint) (location (string-utf8 100)))
  (let
    (
      (inventory-id (+ (var-get last-inventory-id) u1))
    )
    (begin
      (var-set last-inventory-id inventory-id)
      (map-set inventories
        { inventory-id: inventory-id }
        {
          owner: tx-sender,
          product-id: product-id,
          quantity: quantity,
          location: location,
          timestamp: block-height,
          verified: false
        }
      )
      (ok inventory-id)
    )
  )
)

(define-public (verify-inventory (inventory-id uint) (verifier principal))
  (let
    (
      (inventory (unwrap! (map-get? inventories { inventory-id: inventory-id }) (err u1)))
    )
    (begin
      (asserts! (is-eq tx-sender verifier) (err u2))
      (map-set inventories
        { inventory-id: inventory-id }
        (merge inventory { verified: true })
      )
      (ok true)
    )
  )
)

(define-read-only (get-inventory (inventory-id uint))
  (map-get? inventories { inventory-id: inventory-id })
)

(define-read-only (is-inventory-verified (inventory-id uint))
  (match (map-get? inventories { inventory-id: inventory-id })
    inventory (get verified inventory)
    false
  )
)
