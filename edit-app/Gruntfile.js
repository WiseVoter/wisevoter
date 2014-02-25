'use strict';

module.exports = function (grunt) {

  // Load grunt tasks automatically
  grunt.loadNpmTasks('grunt-contrib-less');

  grunt.initConfig({
    less: {
      development: {
        files: {
          '_site/assets/stylesheets/compiled/test.css': '_site/assets/stylesheets/less/test.less',
          'public/css/compiled/app.css' : 'public/css/less/app.less'
          }
      }
    }
  })

  
  grunt.registerTask('log', "Log stuff", function(){
    grunt.log.writeln(this.target + ":", this.data)
  })

  grunt.registerTask('default', ['log', 'less'])

}