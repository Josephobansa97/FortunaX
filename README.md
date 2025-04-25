# FortunaX Lottery Smart Contract

A decentralized lottery system built on the Stacks blockchain using Clarity smart contracts.

## Features

- 🎟️ Fixed-price ticket system (1000 micro-STX per ticket)
- 🔒 Admin-controlled lottery lifecycle
- 🎲 Transparent winner selection using block height
- 💰 Direct prize claiming mechanism
- 📊 On-chain ticket ownership tracking

## Contract Functions

### Public Functions

```clarity
(start-lottery (end-block uint))
```
Allows admin to start a new lottery round with specified end block height.

```clarity
(buy-ticket)
```
Enables users to purchase lottery tickets for the fixed price.

```clarity
(draw-winner)
```
Selects winner using block height as randomness source after lottery end.

```clarity
(claim-prize)
```
Allows winner to claim their prize directly from contract.

### Read-Only Functions

```clarity
(get-lottery-status)
```
Returns current lottery details including:
- Ticket counter
- Lottery active status
- End block height
- Winning ticket ID

```clarity
(get-ticket-owner (ticket-id uint))
```
Queries ownership information for specific ticket ID.

## Getting Started

1. Clone the repository
2. Deploy using Clarinet or Stacks CLI
3. Interact with contract through Stacks wallet or API

## Security Considerations

- Admin controls are centralized to specified principal
- Randomness relies on block height (pseudo-random)
- Fixed ticket price in micro-STX
- All funds held in contract until claimed

