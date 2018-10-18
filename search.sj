var filesystem = require('fs');
var path = require('path');
const args = process.argv.slice(2);
const FILE_EXTENSION = args[0];
const TEXT_TO_SEARCH = args[1];

var isTextExist = function(file , txt){
    var words = [];
    
    try{
        words = filesystem.readFileSync(file, 'utf-8').split(' ').filter(Boolean);
    }catch(err){
        console.log('Cannot open file for string search ' + file)
        return false;
    }
    
    for(var i = 0; i < words.length;i++){
        
        var indexOf = words[i].indexOf(txt);

        if ( indexOf > -1) {
            return true;
        }
    }

    return false;
};

var goOverFiles = function(dir, done) {
  var results = [];

  filesystem.readdir(dir, function(err, list) {
   
    if (err){
        console.log('Error :' + err);
        return done(err);
    }
    
    var pending = list.length;

    //if length is 0 no files in it
    if (!pending){
        console.log('No files in directory');
        return done(null, results);
    }

    list.forEach(function(file) {
        
      file = path.resolve(dir, file);

      filesystem.stat(file, function(err, stat) {

        if (stat && stat.isDirectory()) {
            goOverFiles(file, function(err, res) {
                results = results.concat(res);
                if (!--pending){
                    done(null, results);
                }
            });
        } else {
            
            var fileExt = path.extname(file);
            var fullExt = '.' + FILE_EXTENSION;
            
            if(fileExt == fullExt){
                
                var exist = isTextExist(file , TEXT_TO_SEARCH )

                if(exist){
                    results.push(file);
                }
                if (!--pending){
                    done(null, results);
                }
            }else{
                pending -= 1;
            }
        }
      });
    });
  });
};

goOverFiles(__dirname /* Current directory*/ , function(err, results) {
        if (err){ 
            console.log('walk() Error : ' + err);
            throw err;
        }
        if(results.length == 0){
            console.log('No file was found');
        }else{
            for(var i = 0; i < results.length;i++){
                console.log(results[i]);
            }
        }
  });
