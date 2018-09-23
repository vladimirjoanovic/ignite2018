module.exports = function (grunt) {
    'use strict';

    function pluralizeWord(word, count) {
        return word + (count !== 1 ? 's' : '');
    }

    grunt.registerMultiTask('fileExists', 'Ensures that specified files exist.', function () {
        var files = grunt.file.expand({
            nonull: true
        }, this.data);

        grunt.log.writeln('Checking %s %s for existence...', files.length, pluralizeWord('file', files.length));

        var filesExist = files.every(function (file) {
            grunt.verbose.write('Checking file: ');
            grunt.verbose.subhead(file);

            var fileExists = grunt.file.exists(file);

            if (!fileExists) {
                grunt.log.error('%s doesn’t exist!', file);
            }

            return fileExists;
        });


        if (filesExist) {
            grunt.log.ok();
        }

        return filesExist;
    });
};
