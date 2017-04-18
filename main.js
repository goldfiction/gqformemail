/**
 * Created by happy on 4/18/17.
 */
global.gqcoffee = require("gqcoffee");

console.log("loading modules...");
return gqcoffee
    .q_load()
    .then(function () {
        try {
            var server = gqcoffee.requireFromString(coffee["coffee/app"]);
            server.runServer();
        }catch(e){
            console.log(e)
        }
    });