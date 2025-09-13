;; Content Creator Monetization Platform
;; A comprehensive smart contract for content creators to monetize their work

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant PLATFORM-FEE u5) ;; 5% platform fee
(define-constant MIN-CONTENT-PRICE u1000000) ;; 1 STX minimum
(define-constant MAX-CONTENT-PRICE u1000000000) ;; 1000 STX maximum
(define-constant SUBSCRIPTION-TIERS (list u1000000 u5000000 u10000000)) ;; Basic, Premium, VIP

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-INVALID-PRICE (err u402))
(define-constant ERR-CONTENT-NOT-FOUND (err u403))
(define-constant ERR-ALREADY-PURCHASED (err u404))
(define-constant ERR-INSUFFICIENT-FUNDS (err u405))
(define-constant ERR-CREATOR-NOT-FOUND (err u406))
(define-constant ERR-INVALID-TIER (err u407))
(define-constant ERR-SUBSCRIPTION-EXPIRED (err u408))
(define-constant ERR-ALREADY-SUBSCRIBED (err u409))

;; Data variables
(define-data-var next-content-id uint u1)
(define-data-var next-creator-id uint u1)
(define-data-var platform-earnings uint u0)
(define-data-var total-creators uint u0)
(define-data-var total-content uint u0)

;; Data maps
(define-map creators
  { creator-id: uint }
  {
    owner: principal,
    name: (string-ascii 50),
    bio: (string-ascii 200),
    avatar-url: (string-ascii 100),
    followers: uint,
    total-earnings: uint,
    content-count: uint,
    verification-status: bool,
    created-at: uint,
    tier: uint
  }
)

(define-map creator-by-principal
  { owner: principal }
  { creator-id: uint }
)

(define-map content
  { content-id: uint }
  {
    creator-id: uint,
    title: (string-ascii 100),
    description: (string-ascii 500),
    content-type: (string-ascii 20), ;; video, audio, image, text, course
    price: uint,
    thumbnail-url: (string-ascii 100),
    content-url: (string-ascii 100),
    views: uint,
    likes: uint,
    earnings: uint,
    is-premium: bool,
    created-at: uint,
    status: (string-ascii 20) ;; draft, published, archived
  }
)

(define-map content-purchases
  { buyer: principal, content-id: uint }
  {
    purchased-at: uint,
    amount-paid: uint
  }
)

(define-map subscriptions
  { subscriber: principal, creator-id: uint }
  {
    tier: uint, ;; 0=Basic, 1=Premium, 2=VIP
    start-date: uint,
    end-date: uint,
    amount-paid: uint,
    auto-renew: bool
  }
)

(define-map tips
  { tipper: principal, creator-id: uint, tip-id: uint }
  {
    amount: uint,
    message: (string-ascii 200),
    timestamp: uint
  }
)

(define-map creator-stats
  { creator-id: uint }
  {
    total-views: uint,
    total-likes: uint,
    total-tips: uint,
    subscriber-count: uint,
    monthly-earnings: uint
  }
)

;; Creator registration and management
(define-public (register-creator (name (string-ascii 50)) (bio (string-ascii 200)) (avatar-url (string-ascii 100)))
  (let
    (
      (creator-id (var-get next-creator-id))
      (existing-creator (map-get? creator-by-principal { owner: tx-sender }))
    )
    (asserts! (is-none existing-creator) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-NOT-AUTHORIZED)
    
    (map-set creators
      { creator-id: creator-id }
      {
        owner: tx-sender,
        name: name,
        bio: bio,
        avatar-url: avatar-url,
        followers: u0,
        total-earnings: u0,
        content-count: u0,
        verification-status: false,
        created-at: stacks-block-height,
        tier: u0
      }
    )
    
    (map-set creator-by-principal
      { owner: tx-sender }
      { creator-id: creator-id }
    )
    
    (map-set creator-stats
      { creator-id: creator-id }
      {
        total-views: u0,
        total-likes: u0,
        total-tips: u0,
        subscriber-count: u0,
        monthly-earnings: u0
      }
    )
    
    (var-set next-creator-id (+ creator-id u1))
    (var-set total-creators (+ (var-get total-creators) u1))
    
    (ok creator-id)
  )
)

(define-public (update-creator-profile (name (string-ascii 50)) (bio (string-ascii 200)) (avatar-url (string-ascii 100)))
  (let
    (
      (creator-lookup (map-get? creator-by-principal { owner: tx-sender }))
    )
    (asserts! (is-some creator-lookup) ERR-CREATOR-NOT-FOUND)
    
    (let
      (
        (creator-id (get creator-id (unwrap! creator-lookup ERR-CREATOR-NOT-FOUND)))
        (creator-data (unwrap! (map-get? creators { creator-id: creator-id }) ERR-CREATOR-NOT-FOUND))
      )
      (map-set creators
        { creator-id: creator-id }
        (merge creator-data {
          name: name,
          bio: bio,
          avatar-url: avatar-url
        })
      )
      (ok true)
    )
  )
)

;; Content creation and management
(define-public (create-content 
  (title (string-ascii 100))
  (description (string-ascii 500))
  (content-type (string-ascii 20))
  (price uint)
  (thumbnail-url (string-ascii 100))
  (content-url (string-ascii 100))
  (is-premium bool)
)
  (let
    (
      (content-id (var-get next-content-id))
      (creator-lookup (map-get? creator-by-principal { owner: tx-sender }))
    )
    (asserts! (is-some creator-lookup) ERR-CREATOR-NOT-FOUND)
    (asserts! (and (>= price MIN-CONTENT-PRICE) (<= price MAX-CONTENT-PRICE)) ERR-INVALID-PRICE)
    (asserts! (> (len title) u0) ERR-NOT-AUTHORIZED)
    
    (let
      (
        (creator-id (get creator-id (unwrap! creator-lookup ERR-CREATOR-NOT-FOUND)))
        (creator-data (unwrap! (map-get? creators { creator-id: creator-id }) ERR-CREATOR-NOT-FOUND))
      )
      (map-set content
        { content-id: content-id }
        {
          creator-id: creator-id,
          title: title,
          description: description,
          content-type: content-type,
          price: price,
          thumbnail-url: thumbnail-url,
          content-url: content-url,
          views: u0,
          likes: u0,
          earnings: u0,
          is-premium: is-premium,
          created-at: stacks-block-height,
          status: "draft"
        }
      )
      
      ;; Update creator content count
      (map-set creators
        { creator-id: creator-id }
        (merge creator-data {
          content-count: (+ (get content-count creator-data) u1)
        })
      )
      
      (var-set next-content-id (+ content-id u1))
      (var-set total-content (+ (var-get total-content) u1))
      
      (ok content-id)
    )
  )
)

(define-public (publish-content (content-id uint))
  (let
    (
      (content-data (unwrap! (map-get? content { content-id: content-id }) ERR-CONTENT-NOT-FOUND))
      (creator-lookup (map-get? creator-by-principal { owner: tx-sender }))
    )
    (asserts! (is-some creator-lookup) ERR-CREATOR-NOT-FOUND)
    
    (let
      (
        (creator-id (get creator-id (unwrap! creator-lookup ERR-CREATOR-NOT-FOUND)))
      )
      (asserts! (is-eq (get creator-id content-data) creator-id) ERR-NOT-AUTHORIZED)
      
      (map-set content
        { content-id: content-id }
        (merge content-data { status: "published" })
      )
      
      (ok true)
    )
  )
)

;; Content purchasing
(define-public (purchase-content (content-id uint))
  (let
    (
      (content-data (unwrap! (map-get? content { content-id: content-id }) ERR-CONTENT-NOT-FOUND))
      (existing-purchase (map-get? content-purchases { buyer: tx-sender, content-id: content-id }))
      (price (get price content-data))
      (creator-id (get creator-id content-data))
      (platform-fee (/ (* price PLATFORM-FEE) u100))
      (creator-earnings (- price platform-fee))
    )
    (asserts! (is-none existing-purchase) ERR-ALREADY-PURCHASED)
    (asserts! (is-eq (get status content-data) "published") ERR-CONTENT-NOT-FOUND)
    
    ;; Transfer payment
    (try! (stx-transfer? price tx-sender (as-contract tx-sender)))
    
    ;; Record purchase
    (map-set content-purchases
      { buyer: tx-sender, content-id: content-id }
      {
        purchased-at: stacks-block-height,
        amount-paid: price
      }
    )
    
    ;; Update content earnings and views
    (map-set content
      { content-id: content-id }
      (merge content-data {
        earnings: (+ (get earnings content-data) creator-earnings),
        views: (+ (get views content-data) u1)
      })
    )
    
    ;; Update creator earnings
    (let
      (
        (creator-data (unwrap! (map-get? creators { creator-id: creator-id }) ERR-CREATOR-NOT-FOUND))
      )
      (map-set creators
        { creator-id: creator-id }
        (merge creator-data {
          total-earnings: (+ (get total-earnings creator-data) creator-earnings)
        })
      )
    )
    
    ;; Update platform earnings
    (var-set platform-earnings (+ (var-get platform-earnings) platform-fee))
    
    (ok true)
  )
)

;; Subscription system
(define-public (subscribe-to-creator (creator-id uint) (tier uint) (months uint))
  (let
    (
      (creator-data (unwrap! (map-get? creators { creator-id: creator-id }) ERR-CREATOR-NOT-FOUND))
      (existing-sub (map-get? subscriptions { subscriber: tx-sender, creator-id: creator-id }))
      (tier-price (unwrap! (element-at SUBSCRIPTION-TIERS tier) ERR-INVALID-TIER))
      (total-price (* tier-price months))
      (platform-fee (/ (* total-price PLATFORM-FEE) u100))
      (creator-earnings (- total-price platform-fee))
      (end-date (+ stacks-block-height (* months u144))) ;; Approx 144 blocks per day
    )
    (asserts! (< tier u3) ERR-INVALID-TIER)
    (asserts! (and (>= months u1) (<= months u12)) ERR-NOT-AUTHORIZED)
    
    ;; Check if already subscribed and not expired
    (match existing-sub
      sub (asserts! (< (get end-date sub) stacks-block-height) ERR-ALREADY-SUBSCRIBED)
      true
    )
    
    ;; Transfer payment
    (try! (stx-transfer? total-price tx-sender (as-contract tx-sender)))
    
    ;; Create subscription
    (map-set subscriptions
      { subscriber: tx-sender, creator-id: creator-id }
      {
        tier: tier,
        start-date: stacks-block-height,
        end-date: end-date,
        amount-paid: total-price,
        auto-renew: false
      }
    )
    
    ;; Update creator earnings and follower count
    (map-set creators
      { creator-id: creator-id }
      (merge creator-data {
        total-earnings: (+ (get total-earnings creator-data) creator-earnings),
        followers: (+ (get followers creator-data) u1)
      })
    )
    
    ;; Update creator stats
    (let
      (
        (stats (default-to
          { total-views: u0, total-likes: u0, total-tips: u0, subscriber-count: u0, monthly-earnings: u0 }
          (map-get? creator-stats { creator-id: creator-id })
        ))
      )
      (map-set creator-stats
        { creator-id: creator-id }
        (merge stats {
          subscriber-count: (+ (get subscriber-count stats) u1),
          monthly-earnings: (+ (get monthly-earnings stats) creator-earnings)
        })
      )
    )
    
    ;; Update platform earnings
    (var-set platform-earnings (+ (var-get platform-earnings) platform-fee))
    
    (ok true)
  )
)

;; Tipping system
(define-public (tip-creator (creator-id uint) (amount uint) (message (string-ascii 200)))
  (let
    (
      (creator-data (unwrap! (map-get? creators { creator-id: creator-id }) ERR-CREATOR-NOT-FOUND))
      (platform-fee (/ (* amount PLATFORM-FEE) u100))
      (creator-earnings (- amount platform-fee))
      (tip-id (+ stacks-block-height (mod amount u1000))) ;; Simple tip ID generation
    )
    (asserts! (>= amount u100000) ERR-INVALID-PRICE) ;; Minimum 0.1 STX tip
    
    ;; Transfer payment
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    ;; Record tip
    (map-set tips
      { tipper: tx-sender, creator-id: creator-id, tip-id: tip-id }
      {
        amount: amount,
        message: message,
        timestamp: stacks-block-height
      }
    )
    
    ;; Update creator earnings
    (map-set creators
      { creator-id: creator-id }
      (merge creator-data {
        total-earnings: (+ (get total-earnings creator-data) creator-earnings)
      })
    )
    
    ;; Update creator stats
    (let
      (
        (stats (default-to
          { total-views: u0, total-likes: u0, total-tips: u0, subscriber-count: u0, monthly-earnings: u0 }
          (map-get? creator-stats { creator-id: creator-id })
        ))
      )
      (map-set creator-stats
        { creator-id: creator-id }
        (merge stats {
          total-tips: (+ (get total-tips stats) u1)
        })
      )
    )
    
    ;; Update platform earnings
    (var-set platform-earnings (+ (var-get platform-earnings) platform-fee))
    
    (ok tip-id)
  )
)

;; Creator withdrawal system
(define-public (withdraw-earnings (amount uint))
  (let
    (
      (creator-lookup (map-get? creator-by-principal { owner: tx-sender }))
    )
    (asserts! (is-some creator-lookup) ERR-CREATOR-NOT-FOUND)
    
    (let
      (
        (creator-id (get creator-id (unwrap! creator-lookup ERR-CREATOR-NOT-FOUND)))
        (creator-data (unwrap! (map-get? creators { creator-id: creator-id }) ERR-CREATOR-NOT-FOUND))
        (available-earnings (get total-earnings creator-data))
      )
      (asserts! (<= amount available-earnings) ERR-INSUFFICIENT-FUNDS)
      (asserts! (> amount u0) ERR-INVALID-PRICE)
      
      ;; Transfer earnings to creator
      (try! (as-contract (stx-transfer? amount tx-sender (get owner creator-data))))
      
      ;; Update creator earnings
      (map-set creators
        { creator-id: creator-id }
        (merge creator-data {
          total-earnings: (- available-earnings amount)
        })
      )
      
      (ok true)
    )
  )
)

;; Content interaction functions
(define-public (like-content (content-id uint))
  (let
    (
      (content-data (unwrap! (map-get? content { content-id: content-id }) ERR-CONTENT-NOT-FOUND))
    )
    (map-set content
      { content-id: content-id }
      (merge content-data {
        likes: (+ (get likes content-data) u1)
      })
    )
    
    ;; Update creator stats
    (let
      (
        (creator-id (get creator-id content-data))
        (stats (default-to
          { total-views: u0, total-likes: u0, total-tips: u0, subscriber-count: u0, monthly-earnings: u0 }
          (map-get? creator-stats { creator-id: creator-id })
        ))
      )
      (map-set creator-stats
        { creator-id: creator-id }
        (merge stats {
          total-likes: (+ (get total-likes stats) u1)
        })
      )
    )
    
    (ok true)
  )
)

(define-public (view-content (content-id uint))
  (let
    (
      (content-data (unwrap! (map-get? content { content-id: content-id }) ERR-CONTENT-NOT-FOUND))
    )
    ;; Check if content is premium and user has access
    (if (get is-premium content-data)
      (let
        (
          (creator-id (get creator-id content-data))
          (subscription (map-get? subscriptions { subscriber: tx-sender, creator-id: creator-id }))
          (purchase (map-get? content-purchases { buyer: tx-sender, content-id: content-id }))
        )
        (asserts! (or 
          (is-some purchase)
          (and (is-some subscription) (> (get end-date (unwrap! subscription ERR-SUBSCRIPTION-EXPIRED)) stacks-block-height))
        ) ERR-NOT-AUTHORIZED)
      )
      true
    )
    
    ;; Increment view count
    (map-set content
      { content-id: content-id }
      (merge content-data {
        views: (+ (get views content-data) u1)
      })
    )
    
    ;; Update creator stats
    (let
      (
        (creator-id (get creator-id content-data))
        (stats (default-to
          { total-views: u0, total-likes: u0, total-tips: u0, subscriber-count: u0, monthly-earnings: u0 }
          (map-get? creator-stats { creator-id: creator-id })
        ))
      )
      (map-set creator-stats
        { creator-id: creator-id }
        (merge stats {
          total-views: (+ (get total-views stats) u1)
        })
      )
    )
    
    (ok content-data)
  )
)

;; Admin functions
(define-public (verify-creator (creator-id uint))
  (let
    (
      (creator-data (unwrap! (map-get? creators { creator-id: creator-id }) ERR-CREATOR-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    
    (map-set creators
      { creator-id: creator-id }
      (merge creator-data { verification-status: true })
    )
    
    (ok true)
  )
)

(define-public (set-creator-tier (creator-id uint) (tier uint))
  (let
    (
      (creator-data (unwrap! (map-get? creators { creator-id: creator-id }) ERR-CREATOR-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (<= tier u3) ERR-INVALID-TIER)
    
    (map-set creators
      { creator-id: creator-id }
      (merge creator-data { tier: tier })
    )
    
    (ok true)
  )
)

(define-public (withdraw-platform-fees)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (let
      (
        (fees (var-get platform-earnings))
      )
      (asserts! (> fees u0) ERR-INSUFFICIENT-FUNDS)
      
      (try! (as-contract (stx-transfer? fees tx-sender CONTRACT-OWNER)))
      (var-set platform-earnings u0)
      
      (ok fees)
    )
  )
)

;; Read-only functions
(define-read-only (get-creator (creator-id uint))
  (map-get? creators { creator-id: creator-id })
)

(define-read-only (get-creator-by-principal (owner principal))
  (match (map-get? creator-by-principal { owner: owner })
    creator-lookup (map-get? creators { creator-id: (get creator-id creator-lookup) })
    none
  )
)

(define-read-only (get-content (content-id uint))
  (map-get? content { content-id: content-id })
)

(define-read-only (get-subscription (subscriber principal) (creator-id uint))
  (map-get? subscriptions { subscriber: subscriber, creator-id: creator-id })
)

(define-read-only (has-purchased-content (buyer principal) (content-id uint))
  (is-some (map-get? content-purchases { buyer: buyer, content-id: content-id }))
)

(define-read-only (get-creator-stats (creator-id uint))
  (map-get? creator-stats { creator-id: creator-id })
)

(define-read-only (get-platform-stats)
  {
    total-creators: (var-get total-creators),
    total-content: (var-get total-content),
    platform-earnings: (var-get platform-earnings),
    next-content-id: (var-get next-content-id),
    next-creator-id: (var-get next-creator-id)
  }
)

(define-read-only (is-subscribed (subscriber principal) (creator-id uint))
  (match (map-get? subscriptions { subscriber: subscriber, creator-id: creator-id })
    subscription (> (get end-date subscription) stacks-block-height)
    false
  )
)

(define-read-only (get-subscription-tier (subscriber principal) (creator-id uint))
  (match (map-get? subscriptions { subscriber: subscriber, creator-id: creator-id })
    subscription 
      (if (> (get end-date subscription) stacks-block-height)
        (some (get tier subscription))
        none
      )
    none
  )
)

;; Initialize contract
(begin
  (print "Content Creator Monetization Platform initialized")
  (print "Contract deployed successfully")
)