# Accessibility & Internationalization

**Scope:** A11y (WCAG 2.1 AA) and localization requirements.  
**Status:** Spec (no code). **Language:** EN.

## Accessibility
- Keyboard navigation and visible focus states.
- Form labels, aria-describedby for help/error.
- Color contrast ≥ 4.5:1; do not use color as sole indicator.
- Live regions for tx status updates (polite).
- Skip-to-content and semantic landmarks.

## i18n/l10n
- English default; German secondary.
- Copy strings externalized in `messages.(en|de).json`.
- Number/currency: use Intl APIs; 1kUSD shown with 2–4 decimals; token amounts full precision in tooltips.
- Date/time: show local time + relative (e.g., “3m ago”); include UTC in tooltips.

## Error Messages
- Map to COMMON_ERRORS.md codes; show friendly primary text + expandable technical detail.

## Testing
- Screen reader smoke tests (NVDA/VoiceOver).
- Keyboard-only navigation coverage on core flows (swap/gov).
