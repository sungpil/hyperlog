/*
Distribute kinesis stream to firehose by gameId
*/
var AWS = require('aws-sdk');

exports.handler = (event, context, callback) => {
    
    var gameLogs = {};
    
    event.Records.forEach(function(record) {
        let row = new Buffer(record.kinesis.data, 'base64').toString('ascii');
        if(row.length > 0) {
            let log = null;
            let gameId = 0;
            if( '{' == row.charAt(0) ) {
                log = JSON.parse(row);
                if(log.hasOwnProperty('game')) {
                    gameId = log['game'];
                }
            } else {
                log = row.split(',');
        		gameId = log[0];
            }
            if(isNumeric(gameId) && gameId > 0) {
        		if(!gameLogs.hasOwnProperty(gameId)) {
        		    gameLogs[gameId] = [];
        		}
    		    gameLogs[gameId].push(row);
            } else {
                console.log(`INVALID gameId=${row}`);
            }
        }
	});
	
	let firehose = new AWS.Firehose({apiVersion: '2015-08-04', region: 'ap-northeast-1'});
	
	for( let gameId in gameLogs ) {
	    if(!isNumeric(gameId) || gameId != 29) {
	        continue;
	    }
	    let logs = gameLogs[gameId];
	    let records = logs.map(function(element) {
            return {
                Data: element
            };
        });
        
        let params = {
          DeliveryStreamName: 'hyper'+gameId,
          Records: records
        };
        
        firehose.putRecordBatch(params, function(err, data) {
            if (err) { 
                console.log(err, err.stack);
                //callback(err, err.stack);
            }
        });
	}
};

function isNumeric(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}
