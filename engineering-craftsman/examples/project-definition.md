# Project Definition: B2B Multi-Currency Payment Gateway

## 1. Problem Statement
Enterprise B2B customers currently experience a 4.2% checkout failure rate and manual invoice reconciliation delays of 3–5 days when paying in non-USD currencies, resulting in \$1.2M annual lost revenue and high finance team overhead.

## 2. Objective & Success Metrics
- **Primary Objective**: Provide automated, multi-currency card and virtual account checkout with real-time settlement and automatic ledger reconciliation.
- **Success Metric 1**: Reduce checkout failure rate from 4.2% to < 0.5%.
- **Success Metric 2**: Eliminate manual reconciliation latency from 5 days to real-time (< 30s).
- **Target Value**: \$1.2M reclaimed revenue per year; 40 hours/month saved in finance operations.

## 3. Users & Key Beneficiaries
- **Primary Users**: International enterprise buyers completing invoice settlements.
- **Secondary Users**: Internal finance team (reconciliation) and customer support engineers.

## 4. Scope & Non-Goals
- **In Scope**: Multi-currency card processing (EUR, GBP, JPY, USD), virtual bank transfers, automated webhook notification, idempotent settlement ledger.
- **Explicit Non-Goals**: Cryptocurrency payments, consumer peer-to-peer transfers, offline cash collections.

## 5. Constraints & Economic Analysis
- **Timeline**: 8 weeks to Beta release.
- **Complexity Budget**: Built as a modular domain package within the existing modular monolith; zero extra microservices or bespoke brokers.
- **TCO Estimate**: \$450/month in cloud infrastructure; 1.5 engineer-months to build and verify.
- **Reversibility**: High; legacy USD gateway remains in place as an automatic fallback.
