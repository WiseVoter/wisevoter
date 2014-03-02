'use strict';

module.exports = function (grunt) {

  // Load grunt tasks automatically
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-copy');

  grunt.initConfig({
    
    // Less options
    less: {
      development: {
        files: [{
          '../site/assets/stylesheets/compiled/wisevoter.css': '../site/assets/stylesheets/less/wisevoter.less',
          'public/css/compiled/app.css' : 'public/css/less/app.less'
          }]
      }
    },

    // Copy files
    copy: {
      sitestyles : {
        files: [{
          cwd: '../site/assets/stylesheets/compiled/',
          dest: './_site/assets/stylesheets/compiled/',
          expand: true,
          src: [
            '*.css'
          ]
        }]
      }
    },

    // Log
    log: {
      info: [1,2]
    },

    // Connect
    connect: {
      options: {
        port: 3030,
        livereload: 35729,
        hostname: 'localhost',
        base: ['_site']
      },
      livereload: {
        options: {
          open: true
        }
      }
    },

    // Watch options
    watch: {
      styles: {
        files: ['../site/assets/stylesheets/less/**/*.less'],
        tasks: ['less', 'copy:sitestyles']
      },
      options: {
        livereload: true
      }
    }

  })

  
  grunt.registerMultiTask('log', "Log stuff.", function(){
    grunt.log.writeln(this.target, this.data)
  })

  grunt.registerTask('default', ['log','connect:livereload','watch'])

}