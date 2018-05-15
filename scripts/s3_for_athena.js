/*
copy file to athena partition formatted directory
*/
var AWS = require('aws-sdk');
var s3 = new AWS.S3();
//var util = require('util');
exports.handler = (event, context, callback) => {
    const record = event.Records[0].s3;
    const path = record.object.key;
    let newPath = path.split("/");
    newPath[1] = `year=${newPath[1]}`;
    newPath[2] = `month=${newPath[2]}`;
    newPath[3] = `day=${newPath[3]}`;
    newPath.splice(4,1);
    let params = {
      Bucket: record.bucket.name, 
      CopySource: record.bucket.name+"/"+path, 
      Key: newPath.join("/")
    };
    //console.log("params:",util.inspect(params));
    s3.copyObject(params, function(err, data) {
        if (err) {
            console.log(err, err.stack);
        } else {
            console.log(data);
            params = {
              Bucket: record.bucket.name, 
              Key: path
            };
            // s3.deleteObject(params, function(err, data) {
            //     if (err) {
            //         console.log(err, err.stack);
            //     } else {
            //         console.log(data);
            //     }
            // });
        }
    });
    callback(null, 'Hello from Lambda');
};
