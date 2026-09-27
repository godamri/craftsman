# Content & Evidence Architecture

An interface is a communication instrument. A design cannot be judged independently of the veracity and clarity of its content. This reference governs how content is sourced, audited, reconciled, refactored, and verified under `web-design-craftsman`.

---

## 1. The Evidence Sourcing Hierarchy

When generating or structuring interface copy, content must strictly originate from the highest available tier of authority:

```text
Tier 1: VERIFIED PRODUCT DATA
        Actual database schemas, real terminal outputs, live API specs, measurable benchmarks.
   ↓
Tier 2: USER-PROVIDED SPECIFICATIONS
        Explicit requirements, brand briefs, architectural documentation supplied by the user.
   ↓
Tier 3: REPOSITORY / CODEBASE RECONNAISSANCE
        Existing code, component libraries, type definitions, package dependencies, and configs.
   ↓
Tier 4: VERIFIED TECHNICAL DOCUMENTATION
        Official standards (RFCs, W3C, language specs, framework documentation).
   ↓
Tier 5: ATTRIBUTABLE CUSTOMER EVIDENCE
        Real customer quotes with verifiable full name, company, and confirmed case studies.
   ↓
Tier 6: EXPLICIT CONSERVATIVE PLACEHOLDERS (Prototyping Only)
        Clearly bracketed placeholder tokens (e.g., `[Customer Logo: Acme Corp]`, `[Metric: Latency]`).
```

---

## 2. Evidence Conflict Resolution Protocol

When two information sources disagree (e.g., marketing brief asserts feature X, codebase shows feature X is unbuilt; or documentation cites latency A, benchmarks show latency B):

```text
SOURCE A  ──┐
            ├── [EVIDENCE CONFLICT DETECTED]
SOURCE B  ──┘
```

1. **Classify**: Mark as `[CONFLICT]`. Do NOT silently reconcile or average the claims.
2. **Isolate**: Identify the specific factual contradiction.
3. **Determine Authority**: Establish which source is authoritative for that specific domain:
   * For runtime capabilities, schemas, and performance: *Codebase and benchmark logs override marketing briefs.*
   * For pricing, roadmap, and business terms: *User/product specifications override stale documentation.*
4. **Halt or Omit**: If the conflict cannot be resolved with authoritative evidence, **do not publish the claim as fact**. Either omit the claim entirely or use conservative wording that accurately reflects verified reality.
5. **Separation Invariant**:
   > **Evidence confidence and visual presentation are separate dimensions.** A beautifully rendered claim is still unsupported if its evidence is weak. The agent must never transform factual uncertainty into polished marketing assertions.

---

## 3. Strict Anti-Fabrication Invariants (Hard Constraints)

Beautiful misinformation is a catastrophic design defect. The agent is strictly prohibited from fabricating:

1. **Customer Logos & Brand Proof**: Never insert logos of third parties unless explicitly provided as verified clients.
2. **Attributed Testimonials**: Never invent quotes and assign them to synthetic individuals.
3. **Vanity Statistics**: Never invent numbers (e.g., uptime percentages, speeds, user counts) without a direct verified benchmark or user metric.
4. **Synthetic Certifications**: Never display compliance badges (SOC 2, ISO, HIPAA) unless confirmed in the repository or brief.
5. **Simulated Product Capabilities**: Never render UI controls, flags, or features that the underlying codebase does not possess.

---

## 4. Copy Refactoring Protocol: Abstract Claims to Concrete Evidence

*(Note: The examples below are strictly illustrative templates demonstrating structural refactoring; never copy the specific metrics or capabilities below into a real implementation).*

| Abstract / Generic Claim (Anti-Pattern) | Refactored Evidence-Based Pattern |
| :--- | :--- |
| *"Revolutionize your workflow with next-gen AI"* | State the exact input, mechanism, and output of the tool. |
| *"Blazing fast performance for modern teams"* | State the actual measured latency, throughput, or resource consumption. |
| *"Enterprise-grade security you can trust"* | State the concrete encryption standards, authentication protocols, or access controls. |
| *"Seamless integration across your entire stack"* | List the specific supported protocols, webhooks, or verified native integrations. |
| *"Easy to use for developers of all skill levels"* | Describe the actual developer onboarding path (e.g., single binary, zero-config CLI). |
| *"Unlock powerful insights from your data"* | Specify the actual reports, export formats, or query capabilities provided. |

---

## 5. Handling Missing Content During Design

When necessary content is missing, choose one of these three disciplined actions:

1. **Blocking Unknown**: If the core value proposition, target user identity, or primary product mechanism is absent, **HALT and ask**. Do not build an interface on an imagined premise.
2. **Structural Redesign**: If supporting claims (e.g., customer quotes, case studies) do not exist, **remove the section entirely**. An honest, tightly scoped 3-section interface is infinitely superior to a bloated page padded with synthetic social proof.
3. **Prototyping Placeholders**: If wireframing an agreed layout before copy is drafted, use clearly marked brackets: `[Production Benchmark Data Pending]` rather than synthetic numbers.
