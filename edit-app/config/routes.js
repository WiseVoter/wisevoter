// routes
var main = require('../app/controllers/main');
var users = require('../app/controllers/users');
var content = require('../app/controllers/articles');

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
  };
  
var isSuperAdmin = function(req, res, next){
    if(req.user.isSuperAdmin) {
      return next()
    }
    res.redirect('/notAuthorized') 
  };
  
module.exports = function(app, passport) {
    app.get('/index', main.index);
    app.get('/generate', requiresLogin, isSuperAdmin, main.generate);
    app.get('/generatepage', requiresLogin, isSuperAdmin, main.generatepage);
    app.get('/generatedata', requiresLogin, isSuperAdmin, main.generatedata);
    app.get('/gitcommit', requiresLogin, isSuperAdmin, main.gitcommit);
    app.get('/sitecommit', requiresLogin, isSuperAdmin, main.sitecommit);
    app.get('/updatesoftware', requiresLogin, isSuperAdmin, main.updatesoftware);
    app.get('/restart', requiresLogin, isSuperAdmin, main.siterestart);
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

    app.get('/add', requiresLogin, isSuperAdmin, content.add)
    app.get('/edit/:content/:item', requiresLogin, content.update);
    app.get('/edit/:content', requiresLogin, content.update)
    app.post('/save/:content/:item', content.save)
    app.post('/save/:content', content.save)
    app.post('/save', content.save)

}