# Browser Privacy Setup

Privacy-focused browser configuration for Fedora.

**Goal:** Block cross-site tracking and prevent advertisers from building user profiles across websites.

---

## Overview

**Strategy:** Multi-browser isolation + extensions
- Firefox (main) - Maximum privacy
- Chrome (isolated) - Google services only

**Result:** 85-90% reduction in tracking

---

## Installation

### Firefox

```bash
# Already installed on Fedora Workstation
firefox --version

# If needed:
sudo dnf install -y firefox
```

### Chrome (Optional - for Google services)

```bash
# Enable Chrome repo
sudo dnf install -y fedora-workstation-repositories
sudo dnf config-manager --set-enabled google-chrome

# Install
sudo dnf install -y google-chrome-stable
```

---

## Firefox Configuration

### Basic Privacy Settings

**Open:** `about:preferences#privacy`

**Set these:**
```
Enhanced Tracking Protection: STRICT
Cookies: Delete when Firefox closes
Do Not Track: Always send

Disable all Firefox data collection:
☐ Uncheck all boxes under "Firefox Data Collection"
```

### Install Extensions

**Click these links in Firefox to install:**

1. **[uBlock Origin](https://addons.mozilla.org/firefox/addon/ublock-origin/)** - Block ads & trackers
2. **[Privacy Badger](https://privacybadger.org)** - Learn & block trackers automatically
3. **[Multi-Account Containers](https://addons.mozilla.org/firefox/addon/multi-account-containers/)** - Isolate cookies per activity
4. **[Cookie AutoDelete](https://addons.mozilla.org/firefox/addon/cookie-autodelete/)** (Optional) - Auto-delete cookies

**Installation:** Click "Add to Firefox" on each page (~10 seconds each)

### Configure uBlock Origin

**Add custom filters to block Google tracking:**

1. Click uBlock icon → Dashboard (⚙️)
2. Go to "My filters" tab
3. Add these lines:

```
! Block Google tracking
||fonts.googleapis.com^$third-party
||fonts.gstatic.com^$third-party
||googletagmanager.com^$third-party
||google-analytics.com^$third-party
||doubleclick.net^$third-party
```

4. Click "Apply changes"

---

## Container Setup

**Containers isolate cookies to prevent tracking across different types of websites.**

### Create Containers

Click Containers icon → Manage Containers → Add

**Recommended containers:**

```
Personal (Blue)
├─ General browsing, news, research

Shopping (Orange)
├─ Amazon, shopping sites

Social (Red)
├─ Facebook, Twitter, Reddit

AI Tools (Purple)
├─ Claude.ai, ChatGPT, Perplexity

Banking (Green)
├─ Financial sites

Work (Turquoise)
├─ LinkedIn, work-related
```

### Assign Sites to Containers

**Automatic assignment:**

1. Visit a site (e.g., claude.ai)
2. Right-click address bar area
3. "Open in new container tab" → Choose "AI Tools"
4. Check "Always open in AI Tools"

**Example assignments:**
```
AI Tools:
- claude.ai
- chat.openai.com
- perplexity.ai

Social:
- facebook.com
- twitter.com  
- reddit.com
- instagram.com

Shopping:
- amazon.com
- ebay.com
```

---

## Chrome Setup (Isolated)

**Use Chrome ONLY for Google services to contain their tracking.**

### Usage Rules

**✅ Use Chrome for:**
- Gmail
- Google Drive
- Google Calendar
- YouTube
- Google Maps

**❌ NEVER use Chrome for:**
- General browsing
- Shopping
- Social media
- AI tools
- Anything else

**Why:** Google tracks everything in Chrome. By isolating to Chrome, they only see Google services usage, not your entire browsing history.

---

## Daily Usage Guide

### Browser Selection

```
Need Google service? → Chrome
Everything else → Firefox
```

### Firefox Container Selection

```
Shopping? → Shopping Container
Social media? → Social Container
AI tools? → AI Tools Container
Banking? → Banking Container
Work/LinkedIn? → Work Container
General browsing? → Personal Container
```

---

## Verification

### Test 1: Tracker Blocking

Visit: `https://claude.ai`

1. Click uBlock Origin icon
2. Should see 10-15 blocked requests
3. Blocked domains: `googletagmanager.com`, `google-analytics.com`

### Test 2: Privacy Check

Visit: `https://coveryourtracks.eff.org`

1. Click "Test Your Browser"
2. Good results:
   - ✅ Blocking Tracking Ads
   - ✅ Blocking Invisible Trackers
   - ✅ Fingerprinting Protection

### Test 3: Container Isolation

1. Open `facebook.com` in Social container
2. Open `nytimes.com` in Personal container
3. Click Privacy Badger on NYTimes
4. Facebook should be blocked/different user
5. ✅ Containers working!

---

## Troubleshooting

### Website Broken

**Solution:**
1. Click uBlock icon → Disable for this site
2. Or click Privacy Badger → Disable sliders

### Can't Login

**Solution:**
- Add site to Cookie AutoDelete whitelist
- Or temporarily disable Cookie AutoDelete

### Google Services Not Working in Firefox

**Solution:**
- Use Chrome for Google services (by design)
- Or disable extensions for `google.com` domains

---

## Maintenance

**Monthly:**
- Check extension updates: `about:addons`
- Clear cache: `Ctrl+Shift+Del`

**As needed:**
- Review Cookie AutoDelete whitelist
- Update uBlock custom filters

---

## Privacy Level Achieved

**Before:**
```
Cross-site tracking: YES
User profiling: Complete behavioral profile
Tracking level: 100%
```

**After:**
```
Cross-site tracking: BLOCKED
User profiling: Fragmented (unusable for targeting)
Tracking level: 10-15%
Reduction: 85-90%
```

---

## Setup Checklist

- [ ] Firefox installed
- [ ] Enhanced Tracking Protection set to STRICT
- [ ] uBlock Origin installed & custom filters added
- [ ] Privacy Badger installed
- [ ] Multi-Account Containers installed
- [ ] 5+ containers created
- [ ] Sites assigned to containers
- [ ] Chrome installed (optional)
- [ ] Tested on coveryourtracks.eff.org
- [ ] Verified trackers blocking

---

## Next Steps

- [Development Fundamentals](02-development-fundamentals.md)

---

**Status:** ✅ Browser privacy configured