// Load configurations
// if test env, load example file
var env = process.env.APP_ENV || 'development'
  , config = require('../config/config')[env]
  , mongoose = require('mongoose');

mongoose.connect(config.db);

require('../app/models/user.js');

var User = mongoose.model('User');

var query = {email: 'vaibhavb@lib13.com'};
User.update(query, {roles: ['superadmin']}, function(err, res){console.log(res)});
