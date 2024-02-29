require('dotenv').config();
var express = require('express');
var path = require('path');
var mongoose = require('mongoose');
var passport = require('passport');
var http = require('http');
var fs = require('fs');
var session = require('express-session');
var MongoStore = require('connect-mongo');
var bodyParser = require('body-parser');
var cookieParser = require('cookie-parser');
var morgan = require('morgan');
var errorHandler = require('errorhandler');
var flash = require('connect-flash');
var methodOverride = require('method-override');
const cors = require("cors");

// Load configurations
var env = process.env.APP_ENV || 'development',
    config = require('./config/config')[env];

// Database connection
var connect = function () {
  var options = {
    useNewUrlParser: true, 
    useUnifiedTopology: true,
    keepAlive: true
  };
  mongoose.connect(config.db, options).then(() => console.log('MongoDB connected...'))
    .catch(err => console.error(err));
};


mongoose.connection.on('error', console.log);
mongoose.connection.on('disconnected', connect);

// Bootstrap models
var models_path = path.join(__dirname, '/app/models');
fs.readdirSync(models_path).forEach(function (file) {
  if (file.endsWith('.js')) require(path.join(models_path, file));
});

// Passport configuration
require('./config/passport')(passport); // Assuming you have a passport configuration file

var app = express();
var corsOptions = {
  origin: "http://localhost:3000"
};

app.use(cors(corsOptions));

// Express settings
app.set('port', process.env.PORT || 3000);
app.set('views', path.join(__dirname, '/app/views'));
app.set('view engine', 'jade');

// Middleware
app.use(morgan('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(methodOverride());
app.use(cookieParser());
app.use(session({
  secret: config.secret,
  store: new MongoStore({
    mongoUrl: config.db, // Make sure config.db is your MongoDB connection string
    collection: 'sessions'
  }),
  resave: true,
  saveUninitialized: true
}));
app.use(passport.initialize());
app.use(passport.session());
app.use(flash());

app.use(function(req, res, next) {
  res.locals.pkg = require('./package.json');
  res.locals.req = req;
  next();
});

rootPath = path.normalize(__dirname + '/..');
app.use(express.static(path.join(rootPath, 'public')));

if (env === 'development') {
  app.use(errorHandler());
}

// simple route
app.get("/", (req, res) => {
  res.json({ message: "Welcome to edit application." });
});
// Routes
require('./config/routes')(app, passport); // routes configuration file

http.createServer(app).listen(app.get('port'), function() {
  console.log('Express server listening on port ' + app.get('port'));
});
