const {
  DB_USER,
  DB_PASSWORD,
  DB_HOST,
  DB_PORT,
  DB_NAME,
} = process.env;

module.exports = {
  url: `mongodb://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?authSource=admin`
};

module.exports = {
  development: {
    db: `mongodb://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?authSource=admin`,
    secret: 'my_secret',
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