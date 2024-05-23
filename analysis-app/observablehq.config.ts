// See https://observablehq.com/framework/config for documentation.
export default {
  // The project’s title; used in the sidebar and webpage titles.
  title: "WiserVoter Indian General Elections 2024",

  // The pages and sections in the sidebar. If you don’t specify this option,
  // all pages will be listed in alphabetical order. Listing pages explicitly
  // lets you organize them into sections and have unlisted pages.
  pages: [
    {name: "Dashboard", path: "/"},
    {name: "Felons and Fiefdoms", path: "/felons-and-fiefdoms"},
    {name: "Election Phases", path: "/election-phases"},
    {
      name: "Data",
      pages: [
        {name: "2024 Elections", path: "/2024-elections"},
        {name: "2019 Elections", path: "/2019-elections"}
      ]
    }
  ],

  // Some additional configuration options and their defaults:
  // theme: "default", // try "light", "dark", "slate", etc.
  // header: "", // what to show in the header (HTML)
  footer: "Built with WiseVoter Data (2024), Exposai and Observable.", // what to show in the footer (HTML)
  // toc: true, // whether to show the table of contents
  // pager: true, // whether to show previous & next links in the footer
  // root: "docs", // path to the source root for preview
  // output: "dist", // path to the output root for build
  // search: true, // activate search
};
