'use strict';

var gulp = require('gulp');
var uglify = require('gulp-uglify');
var minifyCss = require('gulp-minify-css');
var inline = require('gulp-inline');
var sass = require('gulp-sass');
var htmlmin = require('gulp-htmlmin');
var del = require('del');
var through = require('through2');
var rename = require("gulp-rename");
var fs = require("fs");

gulp.task('clean', function() {
    return del(['./src/css']);
});

gulp.task('build', ['sass'], function () {
    return gulp.src('./src/index.html')
        .pipe(inline({
            base: './src',
            js: uglify,
            css: minifyCss
        }))
        .pipe(htmlmin({ collapseWhitespace: true }))
        .pipe(through.obj(function(file, enc, cb) {
            fs.readFile('./theme.lua', "utf-8", function(err, data) {
                file.contents = new Buffer(data + '\n\nSPEAK_THEME = [[' + file.contents.toString('base64') + ']]');
                cb(null, file); 
            })

        }))
        .pipe(rename('theme.lua'))
        .pipe(gulp
            .dest('./build'));
});

gulp.task('html', ['sass'], function () {
    return gulp.src('./src/index.html')
        .pipe(inline({
            base: './src',
            js: uglify,
            css: minifyCss
        }))
        .pipe(htmlmin({ collapseWhitespace: true }))
        .pipe(rename('out.html'))
        .pipe(gulp.dest('./build'));
});

gulp.task('sass', function () {
    return gulp.src('./src/sass/**/*.scss')
        .pipe(sass().on('error', sass.logError))
        .pipe(gulp.dest('./src/css'));
});

gulp.task('default', ['build']);