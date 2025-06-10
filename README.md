# STACK-VOTE

A decentralized autonomous organization (DAO) governance system for the Stacks blockchain.

## Overview

STACK-VOTE enables token-based voting on proposals, allowing communities to make decentralized decisions through transparent governance mechanisms.

## Features

- **Proposal Creation**: Token holders can create governance proposals
- **Weighted Voting**: Vote weight based on token holdings
- **Time-bound Voting**: Configurable voting periods for proposals
- **Proposal Execution**: Automatic execution tracking for passed proposals
- **Transparent Process**: All votes and proposals are publicly visible

## Contract Functions

### Public Functions

- `create-proposal(title, description)` - Create a new governance proposal
- `vote(proposal-id, support)` - Vote on a proposal (true for yes, false for no)
- `execute-proposal(proposal-id)` - Mark a successful proposal as executed
- `set-token-balance(user, balance)` - Admin function to set voting power
- `set-voting-period(new-period)` - Admin function to update voting duration

### Read-Only Functions

- `get-proposal(proposal-id)` - Get proposal details and vote counts
- `get-vote(proposal-id, voter)` - Check if and how a user voted
- `get-token-balance(user)` - Get user's voting power

## Usage

1. Ensure you have sufficient tokens for proposal creation
2. Call `create-proposal` with title and description
3. Community members vote using `vote` function
4. After voting period ends, successful proposals can be executed

## Governance

- Minimum token threshold required for proposal creation
- Voting weight proportional to token holdings
- Simple majority required for proposal passage
- Time-locked voting periods ensure fair participation