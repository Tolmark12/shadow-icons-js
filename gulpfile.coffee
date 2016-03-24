bower        = require 'gulp-bower'
browserify   = require 'gulp-browserify'
bump         = require 'gulp-bump'
clean        = require 'gulp-clean'
coffee       = require 'gulp-coffee'
concat       = require 'gulp-concat'
connect      = require 'connect'
declare      = require 'gulp-declare'
fs           = require 'fs'
haml         = require 'gulp-haml'
handlebars   = require 'gulp-handlebars'
http         = require 'http'
gulp         = require 'gulp'
git          = require 'gulp-git'
gutil        = require 'gulp-util'
livereload   = require 'gulp-livereload'
minifyCSS    = require 'gulp-minify-css'
open         = require "gulp-open"
path         = require 'path'
plumber      = require 'gulp-plumber'
prettify     = require 'gulp-prettify'
rename       = require 'gulp-rename'
replace      = require 'gulp-replace'
sass         = require 'gulp-sass'
shadow       = require 'gulp-shadow-icons'
usemin       = require 'gulp-usemin'
uglify       = require 'gulp-uglify'
watch        = require 'gulp-watch'
del          = require 'del'

# shadow       = require './gulp-shadow/gulp-shadow.coffee'
# shadow       = require 'gulp-shadow'

# Paths
svgPath = 'app/assets/compiled/*.svg'

htmlStage = ->
  gulp.src './stage/stage.haml'
    .pipe haml()
    .pipe gulp.dest('./server/')

dashboardCss = ->
  gulp.src 'app/scss/icons-dashboard.scss'
    .pipe sass({errLogToConsole: true})
    .pipe gulp.dest('./server/css')

frontSiteCss = ->
  gulp.src 'app/scss/icons-front-site.scss'
    .pipe sass({errLogToConsole: true})
    .pipe gulp.dest('./server/css')

cssStage = ->
  # Stage css - not included in build
  gulp.src './stage/stage.scss'
    .pipe sass({errLogToConsole: true})
    .pipe gulp.dest('./server/stage/css')

js = ->
  # App
  gulp.src( 'app/coffee/**/*.coffee' )
    .pipe plumber()
    .pipe coffee( bare: true ).on( 'error', gutil.log ) .on( 'error', gutil.beep )
    .pipe concat('app.js')
    .pipe gulp.dest('server/js')

jsStage = ->
  gulp.src "./stage/**/*.coffee"
    .pipe plumber()
    .pipe coffee( bare: true ).on('error', gutil.log).on( 'error', gutil.beep )
    .pipe concat('init.js')
    # .pipe browserify( insertGlobals : true, debug : !gutil.env.production )
    .pipe gulp.dest('server/stage/js')

parseSVG = ->
  gulp.src svgPath
    .pipe shadow {cssDest:'./css/', jsDest:'./js/', cssNamespace:''}
    .pipe gulp.dest('./server/')

# gulp.task 'pareseSvg', () -> parseSVG()

copyBowerLibs = ->
  bower().pipe gulp.dest('./server/bower-libs/')

copyFilesToBuild = ->
  gulp.src( './server/js/app.js' ).pipe gulp.dest('./rel/')
  # gulp.src( './server/css/*.css' ).pipe gulp.dest('./rel/')

pushViaGit = ->
  # Start out by reading the version number for commit msg, then git push, etc..
  fs.readFile './bower.json', 'utf8', (err, data) =>
    regex   = /version"\s*:\s*"(.+)"/
    version = data.match(regex)[1]
    gulp.src('./')
      .pipe git.add()
      .pipe git.commit("BUILD - #{version}")
      .pipe git.push 'origin', 'master', (err)=> console.log( err)

bumpBowerVersion = ->
  gulp.src('./bower.json')
    .pipe bump( {type:'patch'} )
    .pipe(gulp.dest('./'));

# for testing individual tasks
gulp.task 'git', -> pushViaGit()
gulp.task 'vrs', -> bumpBowerVersion()
gulp.task 'svg', -> parseSVG()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Helper method that replaces raw HEX values with the scss var name

colorsObj = require('./gulp-colors.coffee')

fixColors = () ->
  stream = gulp.src(['app/scss/*.scss', '!app/scss/_temp-colors.scss'])
  stream.setMaxListeners(1000)

  for key, color of colorsObj.scssColors
    regex = new RegExp(key,"g")
    stream.pipe replace(regex, color)

  stream.pipe gulp.dest("app/scss/")


gulp.task 'fixColors', -> fixColors()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Livereload Server
server = ->
  port      = 30123
  hostname  = null # allow to connect from anywhere
  base      = 'server'
  directory = 'server'
  app = connect()
    .use( connect.static(base) )
    .use( connect.directory(directory) )

  http.createServer(app).listen port, hostname

# Open in the browser
launch = ->
  gulp.src("./stage/stage.haml") # An actual file must be specified or gulp will overlook the task.
    .pipe(open("",
      url: "http://0.0.0.0:30123/stage.html",
      app: "google chrome"
    ))

dashCssGlob = ['app/scss/dashboard.scss', 'app/scss/dashboard/*.scss', 'app/scss/shared/*.scss']
frntCssGlob = ['app/scss/front-site.scss', 'app/scss/front-site/*.scss', 'app/scss/shared/*.scss']
# Livereload Server
watchAndCompileFiles = (cb)->
  watch {glob:'app/coffee/**/*.coffee'},    -> js().pipe            livereload(35728)
  watch {glob:'./stage/**/*.coffee',},      -> jsStage().pipe       livereload(35728)
  watch {glob:frntCssGlob},                 -> frontSiteCss().pipe  livereload(35728)
  watch {glob:dashCssGlob},                 -> dashboardCss().pipe  livereload(35728)
  watch {glob:'./stage/stage.scss'},        -> cssStage().pipe      livereload(35728)
  watch {glob:'./stage/stage.haml'},        -> htmlStage().pipe     livereload(35728)
  watch {glob:svgPath},                     -> parseSVG().pipe      livereload(35728)


# ----------- BUILD (rel) ----------- #

gulp.task 'rel:clean',        (cb) -> del ['./rel/'], cb
gulp.task 'bumpVersion',      ()   -> bumpBowerVersion()
gulp.task 'compileFiles',     (cb) -> js(); jsStage(); frontSiteCss() ;dashboardCss(); cssStage(); htmlStage(); parseSVG()
gulp.task 'copyBuiltFiles',   ()   -> copyFilesToBuild()
gulp.task 'rel', ['rel:clean', 'bumpVersion', 'compileFiles', 'copyBuiltFiles'], -> pushViaGit()


  # ----------- MAIN ----------- #

gulp.task 'clean',            (cb) -> del ['./server/*',], cb
gulp.task 'server', ['clean'], ()  -> copyBowerLibs(); watchAndCompileFiles(); server(); launch()
gulp.task 'default', ['server']
