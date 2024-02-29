const LocalStrategy = require('passport-local').Strategy;
const crypto = require('crypto');
const User = require('../app/models/user'); // Adjust the path as necessary

module.exports = function(passport) {
  passport.use(new LocalStrategy({ usernameField: 'email' }, (email, password, done) => {
    User.findOne({ email: email }).then(user => {
      if (!user) {
        return done(null, false, { message: 'That email is not registered' });
      }

      // Hash the provided password with the same salt used to hash the stored password
      const hash = crypto.pbkdf2Sync(password, user.salt, 1000, 64, `sha512`).toString(`hex`);

      // Compare the hashed password with the stored hash
      if (user.hash === hash) {
        return done(null, user);
      } else {
        return done(null, false, { message: 'Password incorrect' });
      }
    }).catch(err => console.log(err));
  }));

  passport.serializeUser((user, done) => {
    done(null, user.id);
  });

  passport.deserializeUser((id, done) => {
    User.findById(id, function(err, user) {
      done(err, user);
    });
  });
};
