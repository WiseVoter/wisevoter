var path = require('path')
  , rootPath = path.normalize(__dirname + '/..');

module.exports = {
  development: {
    db: 'mongodb://localhost/wisevoter_dev',
    root: rootPath,
    app: {
      name: "WiseVoter Editor - Development App"
    },
    facebook: {
      clientID: "110251309083156",
      clientSecret: "e350efe7fd9302f9a9d5eb57f5bcb2eb",
      callbackURL: "http://edit.wisevoter.org/auth/facebook/callback"
    },
    gitrepo: "https://" + process.env.GH_USER + ":" + process.env.GH_PASS + "@github.com/vaibhavb/wisevoter.git",
    gitbranch: "gh-pages"
  }
}