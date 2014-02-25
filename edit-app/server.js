var express = require('express')
  , path = require('path')
  , mongoose = require('mongoose')
  , passport = require('passport')
  , LocalStrategy = require('passport-local').Strategy
  , FacebookStrategy = require('passport-facebook').Strategy
  , http = require('http')
  , fs = require('fs')
  , MongoStore = require('connect-mongo')(express);

// Load configurations
// if test env, load example file
var env = process.env.APP_ENV || 'development'
  , config = require('./config/config')[env]
  , mongoose = require('mongoose')
  
// Database
// Bootstrap db connection
// Connect to mongodb
var connect = function () {
  var options = { server: { socketOptions: { keepAlive: 1 } } }
  mongoose.connect(config.db, options)
}
connect()

// Error handler
mongoose.connection.on('error', function (err) {
  console.log(err)
})

// Reconnect when closed
mongoose.connection.on('disconnected', function () {
  connect()
})

// Bootstrap models
var models_path = config.root + '/app/models'
fs.readdirSync(models_path).forEach(function (file) {
  if (~file.indexOf('.js')) require(models_path + '/' + file)
})

// Setup Passport
// serialize sessions
var User = mongoose.model('User');
passport.serializeUser(function(user, done) {
  done(null, user.id)
})

passport.deserializeUser(function(id, done) {
  User.findOne({ _id: id }, function (err, user) {
    done(err, user)
  })
})

// use local strategy
passport.use(new LocalStrategy({
    usernameField: 'email',
    passwordField: 'password'
  },
  function(email, password, done) {
    User.findOne({ email: email }, function (err, user) {
      if (err) { return done(err) }
      if (!user) {
        return done(null, false, { message: 'Unknown user' })
      }
      if (!user.authenticate(password)) {
        return done(null, false, { message: 'Invalid password' })
      }
      return done(null, user)
    })
  }
))

// use facebook strategy
passport.use(new FacebookStrategy({
    clientID: config.facebook.clientID,
    clientSecret: config.facebook.clientSecret,
    callbackURL: config.facebook.callbackURL
  },
  function(accessToken, refreshToken, profile, done) {
    User.findOne({ 'facebook.id': profile.id }, function (err, user) {
      if (err) { return done(err) }
      if (!user) {
        user = new User({
          name: profile.displayName,
          email: profile.emails[0].value,
          username: profile.username,
          provider: 'facebook',
          facebook: profile._json
        })
        user.save(function (err) {
          if (err) console.log(err)
          return done(err, user)
        })
      }
      else {
        return done(err, user)
      }
    })
  }
))

// Setup Express
var app = express()
  , flash = require('connect-flash')
  , pkg = require('./package.json');

// all environments and express configuration
app.set('port', process.env.PORT || 3030);
app.set('views', config.root + '/app/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());

app.use(express.cookieParser(pkg.name));
app.use(express.session({
    secret: pkg.name,
    store: new MongoStore({
      url: config.db,
      collection: 'sessions'
    })
  })
);

// use passport session
app.use(passport.initialize())
app.use(passport.session())

// connect flash for flash messages - should be declared after sessions
app.use(flash())

//expose package.json and req to views
app.use(function(req,res,next){
  res.locals.pkg = pkg;
  res.locals.req = req;
  next();
});

app.use(app.router);
app.use(express.static(path.join(__dirname, '_site')));
app.use("/public", express.static(path.join(__dirname, 'public')));

// development only
if ('development' == env) {
  app.use(express.errorHandler());
}

//auth
var requiresLogin = function (req, res, next) {
  if (req.isAuthenticated()) {
    if(req.user.roles.indexOf('superadmin') >= 0) {
      req.user.isSuperAdmin = true;
    }
    return next()
  }
  if (req.method == 'GET') req.session.returnTo = req.originalUrl
  res.redirect('/login')
}

var isSuperAdmin = function(req, res, next){
  if(req.user.isSuperAdmin) {
    return next()
  }
  res.redirect('/notAuthorized') 
}

// routes
var main = require('./app/controllers/main');
var users = require('./app/controllers/users');
var content = require('./app/controllers/articles');
app.get('/index', main.index);
app.get('/generate', requiresLogin, isSuperAdmin, main.generate);
app.get('/articles', main.articles);
app.get('/login', users.login);
app.get('/logout', users.logout);
app.get('/notAuthorized', main.notAuthorized);
app.get('/signup', users.signup);
app.post('/users', users.create);
app.get('/users/:userId', users.show);
app.post('/users/session', passport.authenticate('local',{
  failureRedirect: '/login',
  failureFlash: 'Invalid email or password.'
}), users.session);
app.get('/auth/facebook',
  passport.authenticate('facebook', {
    scope: [ 'email', 'user_about_me'],
    failureRedirect: '/login'
  }), users.signin);
app.get('/auth/facebook/callback',
  passport.authenticate('facebook', {
    failureRedirect: '/login'
  }), users.authCallback);

app.get('/edit/:content/:item', requiresLogin, content.update);
app.get('/edit/:content', requiresLogin, content.update)
app.post('/save/:content/:item', content.save)
app.post('/save/:content', content.save)

// run the server
http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
