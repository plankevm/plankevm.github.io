---
layout: default
title: Home
---

<section class="hero">
  <h1>Plank</h1>
  <p class="hero-subtitle">A smart contract language for the EVM.</p>
  <div class="install-box">
      <code id="install-cmd"><span class="sh-cmd">curl</span> <span class="sh-flag">-L</span> <span class="sh-url">https://raw.githubusercontent.com/plankevm/plank-monorepo/main/plankup/install.sh</span> <span class="sh-op">|</span> <span class="sh-cmd">bash</span> <span class="sh-op">&amp;&amp;</span> <span class="sh-cmd">plankup</span></code>
      <button class="install-copy" aria-label="Copy" onclick="navigator.clipboard.writeText(document.getElementById('install-cmd').textContent);this.classList.add('copied');setTimeout(()=>this.classList.remove('copied'),1500)">
        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
      </button>
    </div>
</section>

