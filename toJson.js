var fs = require('fs');
var csv = require('csv');
var _ = require('lodash');
// opts is optional
var opts = {};

csv()
.from.path(__dirname+'/8- output-final-with-senate.csv', { delimiter: ',', escape: '"' })
.to.array( function(rows){
  // Remove header information from array
  rows.shift();
  var legislators = {};
  _.each(rows, function(row) {
    /*[ '1726 Kingsley Avenue',
    'Orange Park',
    'FL',
    '32073',
    '4411',
    'FL',
    '3',
    'Ted Yoho',
    'Y000065' ]*/
    var legislator_id = row[8]
    var info = {
      example_address: row[0],
      example_city: row[1],
      example_state: row[2],
      zip5: row[3],
      zip4: row[4],
      example_state: row[5],
      example_district: row[6]

    }
    legislators[legislator_id] = info;
  })

  fs.writeFileSync('legislators.json', JSON.stringify(legislators, null, 4), 'utf8')
});