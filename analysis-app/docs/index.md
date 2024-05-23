---
toc: false
style: wisevoter-style.css
---

<style>

.hero {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-family: var(--sans-serif);
  margin: 4rem 0 8rem;
  text-wrap: balance;
  text-align: center;
}

.hero h1 {
  margin: 2rem 0;
  max-width: none;
  font-size: 14vw;
  font-weight: 900;
  line-height: 1;
  background: linear-gradient(30deg, var(--theme-foreground-focus), currentColor);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero h2 {
  margin: 0;
  max-width: 34em;
  font-size: 20px;
  font-style: initial;
  font-weight: 500;
  line-height: 1.5;
  color: var(--theme-foreground-muted);
}

@media (min-width: 640px) {
  .hero h1 {
    font-size: 90px;
  }
}

</style>

<div class="hero">
  <h1>WiseVoter Analytics Tools</h1>
  <h2>Welcome to WiseVoter Analytics.</h2>
  <span>This is an effort to showcase Indian election status using data from WiseVoter and ADRIndia. We home more data journalism efforts benefit from it.</span>
</div>


## Next steps

Here are some ideas of things you could try…

<div class="grid grid-cols-4">
  <div class="card">
    Review articles <a href="./criminals">Felons and Fiedoms</a>, this will give you inspiration to add your own articles to this citizen data journalism repository by adding a Markdown file (<code>whatever.md</code>) to the <a href="https://github.com/WiseVoter/wisevoter/tree/master/analysis-app/docs">docs</a> folder.
  </div>
  <div class="card">
    Chart the data using <a href="https://observablehq.com/framework/lib/plot"><code>Plot</code></a> and <a href="https://observablehq.com/framework/javascript/files"><code>FileAttachment</code></a>. Make it responsive using <a href="https://observablehq.com/framework/javascript/display#responsive-display"><code>resize</code></a>.
  </div>
</div>
