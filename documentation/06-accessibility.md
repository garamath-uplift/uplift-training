# 06 Accessibility

Every module must be usable by every staff member. **All modules meet WCAG 2.1 AA, whatever their theme.** These requirements aren't questions in the design questionnaire, and no theme or deadline can remove them.

The starter template already handles most of this. Your job is to keep it that way as you add content and theme art.

## Requirements

### Seeing

- [ ] Text contrast is at least **4.5:1** (3:1 for large text: 24px, or 19px bold)
- [ ] Icons, control edges and focus rings have at least **3:1** against their background
- [ ] Information is never shown by **color alone**. Right and wrong have an icon and words, and links are underlined.
- [ ] Text can be zoomed to **200%** and the page reflows at **320px** wide without losing anything
- [ ] Text over art or gradients sits on a solid panel, or passes contrast everywhere it falls
- [ ] No text in images, except logos

### Keyboard and touch

- [ ] Everything works with a **keyboard only**: Tab, Shift+Tab, Enter, Space and the arrow keys where expected
- [ ] **Focus is always visible**, using the two-tone ring that passes on light and dark
- [ ] Focus order follows reading order. When a slide changes, focus moves to its heading.
- [ ] **Drag-and-drop has an alternative**: select the item, then select where it goes (works with keyboard and tap)
- [ ] Touch targets are at least **44 × 44px**
- [ ] A **skip link** jumps to the slide content
- [ ] Dropdowns and the phone menu close with **Escape** and return focus to their button

### Screen readers

- [ ] One `h1` (the module title), then `h2` for each slide heading and `h3` inside slides
- [ ] Meaningful images have **alt text**. Decorative ones are hidden (`alt=""` or `aria-hidden="true"`).
- [ ] Buttons have names that say what they do. Toggles use `aria-pressed` or `aria-expanded`.
- [ ] Feedback after an answer is **announced** (live region)
- [ ] Animated demos have a **text version**
- [ ] The page language is set (`lang="en-US"`)

### Motion, time and sound

- [ ] **`prefers-reduced-motion`** shows finished states, and nothing needed is lost
- [ ] Anything that moves for **more than 5 seconds** can be paused or stops by itself
- [ ] Nothing flashes more than **3 times a second**
- [ ] **No time limits** on activities or checks. Timed reveals (like a countdown) never block learning.
- [ ] Sound is **off by default**, and is never the only feedback
- [ ] Video and audio have **captions or a transcript**

### Checks and activities

- [ ] Questions don't depend on color, position or timing
- [ ] Learners can retry until they pass, with no penalty
- [ ] Instructions say what to do and how to unlock Next

## How to test

| Test | How |
|---|---|
| Keyboard | Unplug the mouse (or don't touch it). Go through the whole module with Tab, Enter, Space and the arrows. |
| Screen reader | NVDA (Windows) or VoiceOver (Mac and iPad: Cmd+F5). Listen to one full section and one check. |
| Zoom | Browser zoom to 200%, then shrink the window to phone width |
| Reduced motion | Windows: Settings → Accessibility → Visual effects → Animation effects **off**. Mac: System Settings → Accessibility → Display → **Reduce motion**. |
| Contrast | Ask the assistant to calculate every theme pair (see [UX/UI guide](05-ux-ui-guide.md#choosing-theme-colors)), or use a contrast checker |
| Automated | Run an accessibility checker (for example axe DevTools or Lighthouse in Edge or Chrome) on several slides. It catches some problems, not all. |
